-- ============================================================================
-- 00002_categories_and_opportunities.sql
-- Money Ideas | أفكار المال
-- Module 2: Categories, Sources, Opportunities, Costs, Risks, and User Tracking
-- ============================================================================

CREATE TYPE opportunity_kind AS ENUM (
  'idea',         -- فكرة تعليمية
  'opportunity'   -- فرصة قابلة للتحقق
);

CREATE TYPE task_status AS ENUM (
  'not_started',  -- لم أبدأ
  'in_progress',  -- جارٍ
  'completed'     -- مكتملة
);

-- ----------------------------------------------------------------------------
-- Hierarchical Categories (المجالات والتصنيفات الفرعية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
  slug TEXT NOT NULL UNIQUE,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_ar TEXT,
  description_en TEXT,
  icon_name TEXT,
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Data Sources & Reliability (إدارة المصادر والموثوقية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.data_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  official_url TEXT NOT NULL,
  data_type TEXT,                      -- e.g. 'government_registry', 'official_pricing'
  reliability_score SMALLINT DEFAULT 95 CHECK (reliability_score BETWEEN 0 AND 100),
  validity_days INT DEFAULT 90,        -- عدد أيام صلاحية المعلومة قبل الحاجة لإعادة التحقق
  last_verified_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Opportunities & Ideas (الأفكار والفرص الاستثمارية والتجارية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  kind opportunity_kind NOT NULL DEFAULT 'idea',
  slug TEXT NOT NULL UNIQUE,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  summary_ar TEXT NOT NULL,
  summary_en TEXT NOT NULL,
  full_description_ar TEXT NOT NULL,
  full_description_en TEXT NOT NULL,

  -- Financial constraints
  min_budget NUMERIC(14, 2) NOT NULL DEFAULT 0,
  max_budget NUMERIC(14, 2),
  currency VARCHAR(5) DEFAULT 'AED',

  -- Time & effort constraints
  min_weekly_hours SMALLINT DEFAULT 5,
  knowledge_level_required experience_level DEFAULT 'beginner',
  risk_level risk_tolerance DEFAULT 'low',

  -- Geographical applicability
  target_country VARCHAR(3) DEFAULT 'AE',
  target_cities TEXT[] DEFAULT '{"Dubai", "Abu Dhabi"}',

  -- Quality & freshness status
  is_verified BOOLEAN DEFAULT TRUE,
  is_published BOOLEAN DEFAULT TRUE,
  needs_update BOOLEAN DEFAULT FALSE,
  last_data_check_at TIMESTAMPTZ DEFAULT NOW(),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Opportunity Costs Analysis (تحليل التكاليف: موثق vs تقديري)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunity_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  item_name_ar TEXT NOT NULL,
  item_name_en TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL,
  currency VARCHAR(5) DEFAULT 'AED',
  is_mandatory BOOLEAN DEFAULT TRUE,
  is_documented BOOLEAN DEFAULT TRUE, -- TRUE = موثق من مصدر رسمي | FALSE = تقديري
  source_reference TEXT,
  display_order INT DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- Opportunity Risks & Verification Questions (تحليل المخاطر والأسئلة الحرجة)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunity_risks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  risk_type TEXT NOT NULL,           -- e.g. 'liquidity', 'market_demand', 'operational'
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_ar TEXT NOT NULL,
  description_en TEXT NOT NULL,
  verification_question_ar TEXT NOT NULL, -- أسئلة يجب التحقق منها قبل اتخاذ القرار
  verification_question_en TEXT NOT NULL,
  display_order INT DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- Opportunity Step-by-Step Roadmaps (خطوات البدء والتنفيذ)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunity_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  step_number INT NOT NULL,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_ar TEXT NOT NULL,
  description_en TEXT NOT NULL,
  estimated_days INT DEFAULT 7
);

-- ----------------------------------------------------------------------------
-- Opportunity Sources Association (ربط الفرصة بمصادرها وتواريخ التحقق)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunity_sources (
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  source_id UUID NOT NULL REFERENCES public.data_sources(id) ON DELETE RESTRICT,
  published_date DATE,
  last_verified_at TIMESTAMPTZ DEFAULT NOW(),
  missing_data_notes TEXT,             -- إظهار البيانات الناقصة بدل اختراع قيم لها
  PRIMARY KEY (opportunity_id, source_id)
);

-- ----------------------------------------------------------------------------
-- Opportunity Revisions (سجل تغيّر المعلومات والأسعار)
-- ----------------------------------------------------------------------------

CREATE TABLE public.opportunity_revisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  change_summary TEXT NOT NULL,
  old_min_budget NUMERIC(14, 2),
  new_min_budget NUMERIC(14, 2),
  changed_fields JSONB,
  revised_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- User Saved Opportunities & Personal Notes (الفرص المحفوظة)
-- ----------------------------------------------------------------------------

CREATE TABLE public.saved_opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
  personal_note TEXT,
  folder_name TEXT DEFAULT 'عام',
  saved_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, opportunity_id)
);

-- ----------------------------------------------------------------------------
-- User Action Plan Tasks (خطة خطواتي التالية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.next_step_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  opportunity_id UUID REFERENCES public.opportunities(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  status task_status DEFAULT 'not_started',
  due_date DATE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
