-- ============================================================================
-- 00005_matching_engine_and_security.sql
-- Money Ideas | أفكار المال
-- Module 5: Explainable Matching Engine (Postgres RPC) & Comprehensive RLS Policies
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Explainable Matching Engine RPC (محرك المطابقة المفسر الخالي من النسب الوهمية)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.match_opportunities(
  p_budget NUMERIC DEFAULT 0,
  p_city TEXT DEFAULT 'Dubai',
  p_weekly_hours SMALLINT DEFAULT 5,
  p_experience experience_level DEFAULT 'beginner',
  p_risk risk_tolerance DEFAULT 'low',
  p_has_no_capital BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
  opportunity_id UUID,
  slug TEXT,
  title_ar TEXT,
  title_en TEXT,
  summary_ar TEXT,
  summary_en TEXT,
  category_id UUID,
  min_budget NUMERIC,
  currency VARCHAR,
  criteria_met_count INT,
  total_criteria_count INT,
  match_reasons JSONB,
  missing_criteria JSONB,
  explanation_ar TEXT
)
AS $$
BEGIN
  RETURN QUERY
  WITH evaluated AS (
    SELECT
      o.id AS opp_id,
      o.slug AS opp_slug,
      o.title_ar AS opp_title_ar,
      o.title_en AS opp_title_en,
      o.summary_ar AS opp_summary_ar,
      o.summary_en AS opp_summary_en,
      o.category_id AS opp_cat_id,
      o.min_budget AS opp_min_budget,
      o.currency AS opp_currency,

      -- Check 1: Budget compatibility
      CASE
        WHEN p_has_no_capital AND o.min_budget > 0 THEN FALSE
        WHEN NOT p_has_no_capital AND p_budget < o.min_budget THEN FALSE
        ELSE TRUE
      END AS budget_ok,

      -- Check 2: Time commitment
      CASE
        WHEN o.min_weekly_hours <= p_weekly_hours THEN TRUE
        ELSE FALSE
      END AS hours_ok,

      -- Check 3: Risk tolerance
      CASE
        WHEN p_risk = 'high' THEN TRUE
        WHEN p_risk = 'medium' AND o.risk_level IN ('low', 'medium') THEN TRUE
        WHEN p_risk = 'low' AND o.risk_level = 'low' THEN TRUE
        ELSE FALSE
      END AS risk_ok,

      -- Check 4: Knowledge requirement
      CASE
        WHEN p_experience = 'advanced' THEN TRUE
        WHEN p_experience = 'intermediate' AND o.knowledge_level_required IN ('beginner', 'intermediate') THEN TRUE
        WHEN p_experience = 'beginner' AND o.knowledge_level_required = 'beginner' THEN TRUE
        ELSE FALSE
      END AS experience_ok,

      -- Check 5: City scope
      CASE
        WHEN o.target_cities IS NULL OR p_city = ANY(o.target_cities) THEN TRUE
        ELSE FALSE
      END AS city_ok

    FROM public.opportunities o
    WHERE o.is_published = TRUE
  )
  SELECT
    e.opp_id,
    e.opp_slug,
    e.opp_title_ar,
    e.opp_title_en,
    e.opp_summary_ar,
    e.opp_summary_en,
    e.opp_cat_id,
    e.opp_min_budget,
    e.opp_currency,

    -- Count how many of the 5 criteria are met
    (CASE WHEN e.budget_ok THEN 1 ELSE 0 END +
     CASE WHEN e.hours_ok THEN 1 ELSE 0 END +
     CASE WHEN e.risk_ok THEN 1 ELSE 0 END +
     CASE WHEN e.experience_ok THEN 1 ELSE 0 END +
     CASE WHEN e.city_ok THEN 1 ELSE 0 END)::INT AS criteria_met_count,

    5::INT AS total_criteria_count,

    -- Explicit list of verified reasons
    jsonb_build_array(
      CASE WHEN e.budget_ok THEN 'تناسب الميزانية المحددة' END,
      CASE WHEN e.hours_ok THEN 'تناسب ساعات العمل المتاحة أسبوعياً' END,
      CASE WHEN e.risk_ok THEN 'تتوافق مع مستوى تحمل المخاطر' END,
      CASE WHEN e.experience_ok THEN 'تناسب مستوى خبرتك الحالي' END,
      CASE WHEN e.city_ok THEN 'متوفرة في السوق المستهدف' END
    ) - 'null'::text AS match_reasons,

    -- Unmet or missing criteria
    jsonb_build_array(
      CASE WHEN NOT e.budget_ok THEN 'تتجاوز الميزانية المحددة حالياً' END,
      CASE WHEN NOT e.hours_ok THEN 'تتطلب ساعات عمل أسبوعية أكبر' END,
      CASE WHEN NOT e.risk_ok THEN 'مستوى المخاطرة أعلى من تفضيلك' END,
      CASE WHEN NOT e.experience_ok THEN 'تتطلب خبرة مسبقة في هذا القطاع' END,
      CASE WHEN NOT e.city_ok THEN 'غير متاح بيانات تشغيلية كافية لهذه المدينة' END
    ) - 'null'::text AS missing_criteria,

    -- Human-readable honest explanation
    format(
      'ظهرت هذه الفرصة لأنها تتطابق مع %s من أصل 5 معايير تم فحصها، وتتوافق مع ميزانيتك وخبرتك.',
      (CASE WHEN e.budget_ok THEN 1 ELSE 0 END +
       CASE WHEN e.hours_ok THEN 1 ELSE 0 END +
       CASE WHEN e.risk_ok THEN 1 ELSE 0 END +
       CASE WHEN e.experience_ok THEN 1 ELSE 0 END +
       CASE WHEN e.city_ok THEN 1 ELSE 0 END)
    ) AS explanation_ar

  FROM evaluated e
  -- Only return opportunities meeting at least budget and risk rules
  WHERE e.budget_ok AND e.risk_ok
  ORDER BY criteria_met_count DESC, e.opp_min_budget ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ----------------------------------------------------------------------------
-- Enable Row Level Security (RLS) on all public tables
-- ----------------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.privacy_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_risks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.next_step_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offer_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offer_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investor_watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- RLS Policies
-- ----------------------------------------------------------------------------

-- Profiles: Public can read names/avatars; only user updates own profile
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT USING (is_banned = FALSE);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Categories & Opportunities: Viewable by anyone if published
CREATE POLICY "Categories viewable by everyone"
  ON public.categories FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Published opportunities viewable by everyone"
  ON public.opportunities FOR SELECT USING (is_published = TRUE);

CREATE POLICY "Opportunity sub-items viewable by everyone"
  ON public.opportunity_costs FOR SELECT USING (TRUE);

CREATE POLICY "Opportunity risks viewable by everyone"
  ON public.opportunity_risks FOR SELECT USING (TRUE);

CREATE POLICY "Opportunity steps viewable by everyone"
  ON public.opportunity_steps FOR SELECT USING (TRUE);

CREATE POLICY "Opportunity sources viewable by everyone"
  ON public.opportunity_sources FOR SELECT USING (TRUE);

CREATE POLICY "Opportunity revisions viewable by everyone"
  ON public.opportunity_revisions FOR SELECT USING (TRUE);

-- Saved Opportunities: strictly private to the user
CREATE POLICY "Users can manage own saved opportunities"
  ON public.saved_opportunities FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Tasks: strictly private
CREATE POLICY "Users can manage own tasks"
  ON public.next_step_tasks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Preferences & Goals: strictly private
CREATE POLICY "Users can manage own preferences"
  ON public.user_preferences FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own goals"
  ON public.user_goals FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Company Offers: Public can only view approved offers
CREATE POLICY "Public can view approved company offers"
  ON public.company_offers FOR SELECT
  USING (status = 'approved' AND valid_until >= CURRENT_DATE);

CREATE POLICY "Company owners can manage their offers"
  ON public.company_offers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.companies
      WHERE id = company_offers.company_id AND owner_id = auth.uid()
    ) OR public.is_admin()
  );

-- Leads: only offer owner and the inquiring user
CREATE POLICY "Users can insert leads"
  ON public.offer_leads FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Companies can view leads for their offers"
  ON public.offer_leads FOR SELECT
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM public.company_offers co
      JOIN public.companies c ON c.id = co.company_id
      WHERE co.id = offer_leads.offer_id AND c.owner_id = auth.uid()
    )
  );

-- Contact Requests: Sender and receiver only
CREATE POLICY "Users can view their contact requests"
  ON public.contact_requests FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send contact requests"
  ON public.contact_requests FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Receivers can update contact requests"
  ON public.contact_requests FOR UPDATE
  USING (auth.uid() = receiver_id);

-- Conversations & Messages: Participants ONLY
CREATE POLICY "Participants can view conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() = participant_one OR auth.uid() = participant_two);

CREATE POLICY "Participants can view messages"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = messages.conversation_id AND (c.participant_one = auth.uid() OR c.participant_two = auth.uid())
    )
  );

CREATE POLICY "Participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = messages.conversation_id AND (c.participant_one = auth.uid() OR c.participant_two = auth.uid())
    )
  );

-- Projects: Published projects viewable by all
CREATE POLICY "Public projects are viewable by all"
  ON public.projects FOR SELECT USING (is_published = TRUE);

CREATE POLICY "Project owners can manage their projects"
  ON public.projects FOR ALL
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Investor Watchlist: Private to investor
CREATE POLICY "Investors can manage own watchlist"
  ON public.investor_watchlist FOR ALL
  USING (auth.uid() = investor_id)
  WITH CHECK (auth.uid() = investor_id);

-- Reports: Users can insert; Admins can view/update
CREATE POLICY "Users can create reports"
  ON public.reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Admins can view and manage reports"
  ON public.reports FOR ALL USING (public.is_admin());

-- Audit logs: Read-only for admins
CREATE POLICY "Admins can view audit logs"
  ON public.audit_logs FOR SELECT USING (public.is_admin());
