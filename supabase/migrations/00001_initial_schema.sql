-- ============================================================================
-- 00001_initial_schema.sql
-- Money Ideas | أفكار المال
-- Module 1: Enums, Profiles, Multi-Role Architecture, and Audit Logs
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- Enums
-- ----------------------------------------------------------------------------

CREATE TYPE app_role AS ENUM (
  'individual',       -- شخص عادي
  'investor',         -- مستثمر
  'project_owner',    -- صاحب فكرة أو مشروع
  'company',          -- شركة
  'admin'             -- مدير المنصة
);

CREATE TYPE user_goal AS ENUM (
  'invest_money',          -- أريد استثمار أموالي
  'discover_idea',         -- لا أملك فكرة وأريد اكتشاف فرصة
  'develop_project',       -- تطوير مشروعي القائم
  'find_partner_investor', -- إيجاد شريك أو مستثمر
  'find_service'           -- البحث عن خدمات وأسعار
);

CREATE TYPE experience_level AS ENUM (
  'beginner',     -- مبتدئ
  'intermediate', -- متوسط
  'advanced'      -- خبير
);

CREATE TYPE risk_tolerance AS ENUM (
  'low',          -- منخفض: لا أتحمل خسائر
  'medium',       -- متوسط: أتحمل تقلبات معتدلة
  'high'          -- مرتفع: أتحمل مخاطر عالية مقابل عائد محتمل
);

CREATE TYPE liquidity_need AS ENUM (
  'immediate',    -- حاجة للسيولة خلال 3-6 أشهر
  'medium_term',  -- 1 إلى 3 سنوات
  'long_term'     -- أكثر من 3 سنوات
);

-- ----------------------------------------------------------------------------
-- Core User Profiles (Linked 1:1 with auth.users)
-- ----------------------------------------------------------------------------

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  country_code VARCHAR(3) DEFAULT 'AE',
  city TEXT DEFAULT 'Dubai',
  preferred_language VARCHAR(5) DEFAULT 'ar',
  preferred_currency VARCHAR(5) DEFAULT 'AED',
  is_verified BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Multi-Role Support (A user can have multiple active roles without re-registering)
-- ----------------------------------------------------------------------------

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role app_role NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

-- ----------------------------------------------------------------------------
-- User Goals (User can select multiple goals)
-- ----------------------------------------------------------------------------

CREATE TABLE public.user_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  goal user_goal NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, goal)
);

-- ----------------------------------------------------------------------------
-- User Preferences & Analytical Profile (For AI Assistant & Rules Matcher)
-- ----------------------------------------------------------------------------

CREATE TABLE public.user_preferences (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  has_no_capital BOOLEAN DEFAULT FALSE,
  budget_amount NUMERIC(14, 2) DEFAULT 0 CHECK (budget_amount >= 0),
  budget_currency VARCHAR(5) DEFAULT 'AED',
  budget_ceiling NUMERIC(14, 2),
  experience_level experience_level DEFAULT 'beginner',
  weekly_available_hours SMALLINT DEFAULT 5 CHECK (weekly_available_hours BETWEEN 0 AND 80),
  wants_active_management BOOLEAN DEFAULT TRUE,
  risk_tolerance risk_tolerance DEFAULT 'low',
  liquidity_need liquidity_need DEFAULT 'medium_term',
  skills TEXT[] DEFAULT '{}',
  target_markets TEXT[] DEFAULT '{"UAE"}',
  profile_completion_percentage SMALLINT DEFAULT 20 CHECK (profile_completion_percentage BETWEEN 0 AND 100),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- User Privacy & Notification Settings
-- ----------------------------------------------------------------------------

CREATE TABLE public.privacy_settings (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  show_profile_to_investors BOOLEAN DEFAULT TRUE,
  show_profile_to_companies BOOLEAN DEFAULT TRUE,
  allow_contact_requests BOOLEAN DEFAULT TRUE,
  show_financial_details_publicly BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  opportunity_updates BOOLEAN DEFAULT TRUE,
  offer_expirations BOOLEAN DEFAULT TRUE,
  contact_requests BOOLEAN DEFAULT TRUE,
  chat_messages BOOLEAN DEFAULT TRUE,
  marketing_notifications BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Audit Logs (Mandatory for transparency, tracking sensitive changes)
-- ----------------------------------------------------------------------------

CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Triggers: Auto create profile on auth signup
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, preferred_language, preferred_currency)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
    COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'ar'),
    COALESCE(NEW.raw_user_meta_data->>'preferred_currency', 'AED')
  );

  -- Assign default 'individual' role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'individual');

  -- Create initial preferences row
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id);

  -- Create default privacy & notifications
  INSERT INTO public.privacy_settings (user_id)
  VALUES (NEW.id);

  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper function to check admin status in RLS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin' AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
