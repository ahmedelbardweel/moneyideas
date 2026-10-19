-- ============================================================================
-- 00011_fix_admin_roles.sql
-- Money Ideas | أفكار المال
-- Fix: Remove accidental admin role from standard users and protect admin assignment
-- ============================================================================

-- 1. Remove admin role from standard users (e.g. lina)
DELETE FROM public.user_roles
WHERE role = 'admin'
  AND user_id IN (
    SELECT id FROM public.profiles WHERE full_name = 'lina'
  );

-- 2. Ensure each user has their default 'individual' role if they have no active roles
INSERT INTO public.user_roles (user_id, role, is_active)
SELECT p.id, 'individual', TRUE
FROM public.profiles p
WHERE NOT EXISTS (
  SELECT 1 FROM public.user_roles ur WHERE ur.user_id = p.id
)
ON CONFLICT (user_id, role) DO NOTHING;

-- 3. Prevent clients from assigning 'admin' role through RLS:
-- Only existing super admins can insert or update 'admin' role in user_roles table
DROP POLICY IF EXISTS "Prevent non-admins from assigning admin role" ON public.user_roles;
CREATE POLICY "Prevent non-admins from assigning admin role"
  ON public.user_roles FOR INSERT
  WITH CHECK (
    (role != 'admin' AND user_id = auth.uid()) OR public.is_admin()
  );

DROP POLICY IF EXISTS "Prevent non-admins from updating to admin role" ON public.user_roles;
CREATE POLICY "Prevent non-admins from updating to admin role"
  ON public.user_roles FOR UPDATE
  USING (user_id = auth.uid() OR public.is_admin())
  WITH CHECK (
    (role != 'admin' AND user_id = auth.uid()) OR public.is_admin()
  );
