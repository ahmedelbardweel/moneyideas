-- ============================================================================
-- 00012_allow_users_read_roles.sql
-- Money Ideas | أفكار المال
-- Fix: Allow authenticated users to read their own roles from user_roles table
-- ============================================================================

-- 1. Ensure user_roles has a SELECT policy for non-admin users to view their own roles
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (user_id = auth.uid() OR public.is_admin());

-- 2. Ensure privacy_settings and notification_preferences can be managed by their owner
DROP POLICY IF EXISTS "Users can manage own privacy settings" ON public.privacy_settings;
CREATE POLICY "Users can manage own privacy settings"
  ON public.privacy_settings FOR ALL
  USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "Users can manage own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users can manage own notification preferences"
  ON public.notification_preferences FOR ALL
  USING (user_id = auth.uid() OR public.is_admin());
