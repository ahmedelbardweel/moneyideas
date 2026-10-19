-- ============================================================================
-- 00003_companies_and_offers.sql
-- Money Ideas | أفكار المال
-- Module 3: Companies, Commercial Offers Lifecycle, Leads, and Ad Campaigns
-- ============================================================================

CREATE TYPE verification_status AS ENUM (
  'unverified',     -- لم يتم التوثيق
  'pending_review', -- قيد المراجعة والتدقيق
  'verified',       -- موثقة برخصة تجارية سارية
  'rejected'        -- مرفوضة لعدم استيفاء الشروط
);

CREATE TYPE offer_status AS ENUM (
  'draft',          -- مسودة
  'in_review',      -- قيد المراجعة الإدارية
  'needs_changes',  -- تحتاج تعديل ملاحظات الإدارة
  'approved',       -- مقبولة ومنشورة
  'rejected',       -- مرفوضة
  'paused',         -- متوقفة مؤقتاً بطلب من الشركة
  'expired',        -- انتهت صلاحية العرض
  'archived'        -- مؤرشفة
);

CREATE TYPE lead_status AS ENUM (
  'new',            -- طلب جديد
  'contacted',      -- تم التواصل
  'in_negotiation', -- قيد التفاوض
  'closed',         -- مغلق
  'spam'            -- بلاغ احتيال / سبام
);

CREATE TYPE company_member_role AS ENUM (
  'owner',          -- مالك الشركة
  'admin',          -- مدير
  'support_agent'   -- موظف للرد على طلبات التواصل فقط
);

-- ----------------------------------------------------------------------------
-- Registered Companies (حسابات الشركات وملفاتها القانونية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  legal_name TEXT NOT NULL,
  trade_name TEXT NOT NULL,
  business_type TEXT NOT NULL,           -- نوع النشاط (e.g. تقنية، تسويق، استشارات)
  country_code VARCHAR(3) DEFAULT 'AE',
  city TEXT DEFAULT 'Dubai',
  trade_license_number TEXT NOT NULL UNIQUE,
  license_issuing_authority TEXT,        -- دائرة الاقتصاد، المنطقة الحرة...
  license_expiry_date DATE,
  official_email TEXT NOT NULL,
  official_phone TEXT,
  website_url TEXT,
  logo_url TEXT,
  bio TEXT,
  verification_status verification_status DEFAULT 'pending_review',
  verification_notes TEXT,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Company Verification Documents (مستندات التوثيق)
-- ----------------------------------------------------------------------------

CREATE TABLE public.company_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,           -- 'trade_license', 'incorporation_cert', 'power_of_attorney'
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size_bytes INT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Company Team Members & Role Delegations (أعضاء الفريق والصلاحيات)
-- ----------------------------------------------------------------------------

CREATE TABLE public.company_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role company_member_role DEFAULT 'support_agent',
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, user_id)
);

-- ----------------------------------------------------------------------------
-- Company Commercial Offers (العروض التجارية والخدمات)
-- ----------------------------------------------------------------------------

CREATE TABLE public.company_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  service_type TEXT NOT NULL,

  -- Pricing
  price NUMERIC(12, 2),                  -- NULL if "السعر عند الطلب"
  price_currency VARCHAR(5) DEFAULT 'AED',
  additional_fees_description TEXT,

  -- Target audience & geographic scope
  target_cities TEXT[] DEFAULT '{"Dubai"}',
  terms_and_conditions TEXT NOT NULL,
  valid_from DATE DEFAULT CURRENT_DATE,
  valid_until DATE NOT NULL,

  -- Lifecycle & Admin review
  status offer_status DEFAULT 'draft',
  admin_review_notes TEXT,
  reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,

  -- Performance metrics
  views_count INT DEFAULT 0,
  details_opened_count INT DEFAULT 0,
  leads_count INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Offer Media Attachments (صور ومرفقات العرض)
-- ----------------------------------------------------------------------------

CREATE TABLE public.offer_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id UUID NOT NULL REFERENCES public.company_offers(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  display_order INT DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- Leads / Interested Clients (العملاء المهتمون بالعروض)
-- ----------------------------------------------------------------------------

CREATE TABLE public.offer_leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id UUID NOT NULL REFERENCES public.company_offers(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  inquiry_message TEXT NOT NULL,
  status lead_status DEFAULT 'new',
  company_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Commercial Ad Campaigns (الحملات الإعلانية الممولة - مفصولة كلياً عن نتائج المطابقة)
-- ----------------------------------------------------------------------------

CREATE TABLE public.ad_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  offer_id UUID REFERENCES public.company_offers(id) ON DELETE SET NULL,
  campaign_title TEXT NOT NULL,
  target_cities TEXT[] DEFAULT '{"Dubai"}',
  target_categories UUID[] DEFAULT '{}',
  banner_url TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  admin_approved BOOLEAN DEFAULT FALSE,
  total_impressions INT DEFAULT 0,
  total_clicks INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
