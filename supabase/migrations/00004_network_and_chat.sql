-- ============================================================================
-- 00004_network_and_chat.sql
-- Money Ideas | أفكار المال
-- Module 4: Network (Investors, Projects), Mutual Contact Requests, Chat & Moderation
-- ============================================================================

CREATE TYPE project_type AS ENUM (
  'idea',                -- فكرة مشروع
  'existing_business',   -- مشروع قائم يعمل
  'investment_request'   -- طلب استثمار أو تمويل (مشروط بمراجعة تنظيمية)
);

CREATE TYPE project_stage AS ENUM (
  'concept',             -- مرحلة الفكرة
  'prototype',           -- نموذج أولي
  'generating_revenue',  -- يحقق إيرادات
  'scaling'              -- مرحلة التوسع والنمو
);

CREATE TYPE contact_request_status AS ENUM (
  'pending',             -- بانتظار موافقة الطرف الآخر
  'accepted',            -- مقبول وتفتح المحادثة
  'rejected',            -- مرفوض
  'cancelled'            -- ملغى من الراسل
);

CREATE TYPE report_status AS ENUM (
  'pending',             -- قيد الاستلام
  'under_investigation', -- قيد التحقيق
  'action_taken',        -- تم اتخاذ الإجراء المناسب (حظر/إزالة)
  'dismissed'            -- بلاغ غير صحيح
);

-- ----------------------------------------------------------------------------
-- Investor Profiles (دليل المستثمرين)
-- ----------------------------------------------------------------------------

CREATE TABLE public.investor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  investor_type TEXT NOT NULL DEFAULT 'مستثمر فردي', -- فرد، صندوق، مكتب عائلي
  bio TEXT,
  sectors_of_interest TEXT[] DEFAULT '{}',
  target_markets TEXT[] DEFAULT '{"UAE"}',
  preferred_stages project_stage[] DEFAULT '{prototype, generating_revenue}',

  -- Financial range disclosures (Optional/Configurable)
  show_financial_range_publicly BOOLEAN DEFAULT FALSE,
  min_ticket_size NUMERIC(12, 2),
  max_ticket_size NUMERIC(12, 2),
  currency VARCHAR(5) DEFAULT 'AED',

  contact_conditions TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Investor Private Watchlist (مشاريع قيد الدراسة مع ملاحظات سرية للمستثمر)
-- ----------------------------------------------------------------------------

CREATE TABLE public.investor_watchlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  investor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  project_id UUID NOT NULL, -- references projects
  private_notes TEXT,
  saved_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(investor_id, project_id)
);

-- ----------------------------------------------------------------------------
-- Projects & Startups (دليل المشاريع ورواد الأعمال)
-- ----------------------------------------------------------------------------

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  type project_type NOT NULL DEFAULT 'idea',
  stage project_stage NOT NULL DEFAULT 'concept',
  name TEXT NOT NULL,
  summary TEXT NOT NULL,
  problem_statement TEXT NOT NULL,
  solution_statement TEXT NOT NULL,
  target_audience TEXT,
  revenue_model TEXT,
  help_needed_type TEXT NOT NULL,       -- 'شريك تقني', 'شريك تسويق', 'استثمار', 'مرشد أعمال'

  -- Regulatory check for investment requests
  regulatory_approval_status verification_status DEFAULT 'unverified',
  is_published BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Complete foreign key on investor_watchlist
ALTER TABLE public.investor_watchlist
  ADD CONSTRAINT fk_watchlist_project
  FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;

-- ----------------------------------------------------------------------------
-- Project Documents (مستندات المشروع: عامة وخاصة بإذن)
-- ----------------------------------------------------------------------------

CREATE TABLE public.project_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  file_url TEXT NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,      -- FALSE = وثيقة خاصة تتطلب موافقة صريحة
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Contact Requests (طلبات التواصل وبوابة الحماية من الإزعاج)
-- ----------------------------------------------------------------------------

CREATE TABLE public.contact_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  reason TEXT NOT NULL,                 -- سبب التواصل
  introduction_message TEXT NOT NULL,
  status contact_request_status DEFAULT 'pending',
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (sender_id != receiver_id)
);

-- ----------------------------------------------------------------------------
-- Real-time Conversations & Messaging (المحادثات الفردية)
-- ----------------------------------------------------------------------------

CREATE TABLE public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contact_request_id UUID REFERENCES public.contact_requests(id) ON DELETE SET NULL,
  participant_one UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  participant_two UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(participant_one, participant_two)
);

CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  attachment_url TEXT,
  attachment_type TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- User Blocks & Moderation Reports (الحظر والإبلاغ عن المخالفات)
-- ----------------------------------------------------------------------------

CREATE TABLE public.user_blocks (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  blocked_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY(user_id, blocked_user_id)
);

CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reported_entity_type TEXT NOT NULL,   -- 'offer', 'project', 'user', 'message'
  reported_entity_id TEXT NOT NULL,
  reason TEXT NOT NULL,                 -- 'احتيال', 'أرباح غير مثبتة', 'محتوى مخالف'
  details TEXT,
  status report_status DEFAULT 'pending',
  admin_notes TEXT,
  resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
