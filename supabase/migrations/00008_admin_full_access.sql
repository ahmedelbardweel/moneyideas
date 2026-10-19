-- ============================================================================
-- 00008_admin_full_access.sql
-- Money Ideas | أفكار المال
-- Module 8: Full Super-Admin RLS Policies across all tables
-- ============================================================================

-- Ensure public.is_admin() exists and is up to date
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin' AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Profiles: Admin can view and manage all profiles
DROP POLICY IF EXISTS "Admins have full access on profiles" ON public.profiles;
CREATE POLICY "Admins have full access on profiles"
  ON public.profiles FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- User Roles: Admin can view and manage all user roles
DROP POLICY IF EXISTS "Admins have full access on user_roles" ON public.user_roles;
CREATE POLICY "Admins have full access on user_roles"
  ON public.user_roles FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Categories: Admin can manage categories
DROP POLICY IF EXISTS "Admins have full access on categories" ON public.categories;
CREATE POLICY "Admins have full access on categories"
  ON public.categories FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Opportunities: Admin can manage opportunities and sub-items
DROP POLICY IF EXISTS "Admins have full access on opportunities" ON public.opportunities;
CREATE POLICY "Admins have full access on opportunities"
  ON public.opportunities FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on opportunity_costs" ON public.opportunity_costs;
CREATE POLICY "Admins have full access on opportunity_costs"
  ON public.opportunity_costs FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on opportunity_risks" ON public.opportunity_risks;
CREATE POLICY "Admins have full access on opportunity_risks"
  ON public.opportunity_risks FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on opportunity_steps" ON public.opportunity_steps;
CREATE POLICY "Admins have full access on opportunity_steps"
  ON public.opportunity_steps FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on opportunity_sources" ON public.opportunity_sources;
CREATE POLICY "Admins have full access on opportunity_sources"
  ON public.opportunity_sources FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Companies: Admin can manage companies and verification documents
DROP POLICY IF EXISTS "Admins have full access on companies" ON public.companies;
CREATE POLICY "Admins have full access on companies"
  ON public.companies FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on company_documents" ON public.company_documents;
CREATE POLICY "Admins have full access on company_documents"
  ON public.company_documents FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Offers: Admin can manage all company offers and audit reviews
DROP POLICY IF EXISTS "Admins have full access on company_offers" ON public.company_offers;
CREATE POLICY "Admins have full access on company_offers"
  ON public.company_offers FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on offer_media" ON public.offer_media;
CREATE POLICY "Admins have full access on offer_media"
  ON public.offer_media FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Projects: Admin can manage all projects and regulatory approvals
DROP POLICY IF EXISTS "Admins have full access on projects" ON public.projects;
CREATE POLICY "Admins have full access on projects"
  ON public.projects FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on project_documents" ON public.project_documents;
CREATE POLICY "Admins have full access on project_documents"
  ON public.project_documents FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Investor Profiles: Admin can manage investor profiles
DROP POLICY IF EXISTS "Admins have full access on investor_profiles" ON public.investor_profiles;
CREATE POLICY "Admins have full access on investor_profiles"
  ON public.investor_profiles FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Campaigns: Admin can approve/manage sponsored campaigns
DROP POLICY IF EXISTS "Admins have full access on ad_campaigns" ON public.ad_campaigns;
CREATE POLICY "Admins have full access on ad_campaigns"
  ON public.ad_campaigns FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Reports & Audit Logs: Admin has full access
DROP POLICY IF EXISTS "Admins have full access on reports" ON public.reports;
CREATE POLICY "Admins have full access on reports"
  ON public.reports FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins have full access on audit_logs" ON public.audit_logs;
CREATE POLICY "Admins have full access on audit_logs"
  ON public.audit_logs FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());
