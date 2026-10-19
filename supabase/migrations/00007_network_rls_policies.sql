-- ============================================================================
-- 00007_network_rls_policies.sql
-- Money Ideas | أفكار المال
-- Module 7: Network & Investor Profiles RLS Policies
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Investor Profiles
-- ----------------------------------------------------------------------------

CREATE POLICY "Investor profiles viewable by everyone"
  ON public.investor_profiles FOR SELECT
  USING (TRUE);

CREATE POLICY "Users can manage own investor profile"
  ON public.investor_profiles FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- Project Documents
-- ----------------------------------------------------------------------------

CREATE POLICY "Public project documents viewable by everyone"
  ON public.project_documents FOR SELECT
  USING (
    is_public = TRUE OR
    EXISTS (
      SELECT 1 FROM public.projects p
      WHERE p.id = project_documents.project_id AND p.owner_id = auth.uid()
    )
  );

CREATE POLICY "Project owners can manage documents"
  ON public.project_documents FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.projects p
      WHERE p.id = project_documents.project_id AND p.owner_id = auth.uid()
    )
  );
