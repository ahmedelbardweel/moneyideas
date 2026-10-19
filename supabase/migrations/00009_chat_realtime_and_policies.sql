-- ============================================================================
-- 00009_chat_realtime_and_policies.sql
-- Money Ideas | أفكار المال
-- Module 9: Chat — conversation auto-creation, read receipts, blocking, realtime
-- Idempotent: safe to run more than once.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Auto-create a conversation when a contact request is accepted.
--    conversations has no INSERT policy for clients (by design), so creation
--    happens server-side here. Participants are stored in a canonical order
--    (LEAST/GREATEST) so UNIQUE(participant_one, participant_two) holds.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_contact_request_accepted()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'accepted' AND OLD.status IS DISTINCT FROM 'accepted' THEN
    INSERT INTO public.conversations (contact_request_id, participant_one, participant_two)
    VALUES (
      NEW.id,
      LEAST(NEW.sender_id, NEW.receiver_id),
      GREATEST(NEW.sender_id, NEW.receiver_id)
    )
    ON CONFLICT (participant_one, participant_two)
    DO UPDATE SET contact_request_id = EXCLUDED.contact_request_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_contact_request_accepted ON public.contact_requests;
CREATE TRIGGER on_contact_request_accepted
  AFTER UPDATE OF status ON public.contact_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_contact_request_accepted();

-- Backfill: requests accepted before this trigger existed.
INSERT INTO public.conversations (contact_request_id, participant_one, participant_two)
SELECT cr.id, LEAST(cr.sender_id, cr.receiver_id), GREATEST(cr.sender_id, cr.receiver_id)
FROM public.contact_requests cr
WHERE cr.status = 'accepted'
ON CONFLICT (participant_one, participant_two) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. Keep conversations.last_message_at in sync (drives list ordering).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.touch_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_message_created ON public.messages;
CREATE TRIGGER on_message_created
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.touch_conversation_on_message();

-- ----------------------------------------------------------------------------
-- 3. Blocking helpers. SECURITY DEFINER so a blocked user can't bypass the
--    check just because RLS hides other people's block rows from them.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_blocked_between(a UUID, b UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_blocks
    WHERE (user_id = a AND blocked_user_id = b)
       OR (user_id = b AND blocked_user_id = a)
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

-- Returns 'none' | 'blocked_by_me' | 'blocked_me' for the current user.
CREATE OR REPLACE FUNCTION public.chat_block_state(p_other_user UUID)
RETURNS TEXT AS $$
  SELECT CASE
    WHEN EXISTS (SELECT 1 FROM public.user_blocks
                 WHERE user_id = auth.uid() AND blocked_user_id = p_other_user)
      THEN 'blocked_by_me'
    WHEN EXISTS (SELECT 1 FROM public.user_blocks
                 WHERE user_id = p_other_user AND blocked_user_id = auth.uid())
      THEN 'blocked_me'
    ELSE 'none'
  END;
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

DROP POLICY IF EXISTS "Users can manage own blocks" ON public.user_blocks;
CREATE POLICY "Users can manage own blocks"
  ON public.user_blocks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Messages: participants can send only when neither side has blocked the other.
DROP POLICY IF EXISTS "Participants can send messages" ON public.messages;
CREATE POLICY "Participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = messages.conversation_id
        AND (c.participant_one = auth.uid() OR c.participant_two = auth.uid())
        AND NOT public.is_blocked_between(c.participant_one, c.participant_two)
    )
  );

-- Contact requests: can't send to someone with an active block either way.
DROP POLICY IF EXISTS "Users can send contact requests" ON public.contact_requests;
CREATE POLICY "Users can send contact requests"
  ON public.contact_requests FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id AND
    NOT public.is_blocked_between(sender_id, receiver_id)
  );

-- ----------------------------------------------------------------------------
-- 4. Read receipts via RPC (only marks messages *received* by the caller,
--    so clients never get a general UPDATE right on message bodies).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_conversation_read(p_conversation_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.messages m
  SET is_read = TRUE, read_at = NOW()
  WHERE m.conversation_id = p_conversation_id
    AND m.sender_id <> auth.uid()
    AND m.is_read = FALSE
    AND EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = p_conversation_id
        AND (c.participant_one = auth.uid() OR c.participant_two = auth.uid())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.mark_conversation_read(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.chat_block_state(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_blocked_between(UUID, UUID) TO authenticated;

-- ----------------------------------------------------------------------------
-- 5. Realtime: publish messages + conversations (RLS still applies to events).
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'conversations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
  END IF;
END $$;
