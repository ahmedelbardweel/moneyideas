-- ============================================================================
-- 00006_company_rls_policies.sql
-- Money Ideas | أفكار المال
-- Module 6: Additional RLS Policies for Companies, Documents, Members & Offers
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Companies Table Policies
-- ----------------------------------------------------------------------------

-- Public can view registered companies
CREATE POLICY "Public companies viewable by everyone"
  ON public.companies FOR SELECT
  USING (TRUE);

-- Authenticated users can register their own company
CREATE POLICY "Users can create company"
  ON public.companies FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Company owners can update their company profile
CREATE POLICY "Company owners can update own company"
  ON public.companies FOR UPDATE
  USING (auth.uid() = owner_id OR public.is_admin())
  WITH CHECK (auth.uid() = owner_id OR public.is_admin());

-- ----------------------------------------------------------------------------
-- Company Verification Documents
-- ----------------------------------------------------------------------------

CREATE POLICY "Company members can view documents"
  ON public.company_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = company_documents.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

CREATE POLICY "Company owners can upload documents"
  ON public.company_documents FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = company_documents.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

-- ----------------------------------------------------------------------------
-- Company Members
-- ----------------------------------------------------------------------------

CREATE POLICY "Company members viewable by members or owners"
  ON public.company_members FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = company_members.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

CREATE POLICY "Company owners can manage members"
  ON public.company_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = company_members.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

-- ----------------------------------------------------------------------------
-- Offer Media
-- ----------------------------------------------------------------------------

CREATE POLICY "Offer media viewable by everyone"
  ON public.offer_media FOR SELECT
  USING (TRUE);

CREATE POLICY "Offer owners can manage offer media"
  ON public.offer_media FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.company_offers co
      JOIN public.companies c ON c.id = co.company_id
      WHERE co.id = offer_media.offer_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

-- ----------------------------------------------------------------------------
-- Ad Campaigns
-- ----------------------------------------------------------------------------

CREATE POLICY "Active ad campaigns viewable by everyone"
  ON public.ad_campaigns FOR SELECT
  USING (is_active = TRUE AND admin_approved = TRUE);

CREATE POLICY "Company owners can view own campaigns"
  ON public.ad_campaigns FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = ad_campaigns.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );

CREATE POLICY "Company owners can manage campaigns"
  ON public.ad_campaigns FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.companies c
      WHERE c.id = ad_campaigns.company_id AND c.owner_id = auth.uid()
    ) OR public.is_admin()
  );
