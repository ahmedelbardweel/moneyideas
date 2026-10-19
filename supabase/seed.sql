-- ============================================================================
-- seed.sql — Money Ideas | أفكار المال
-- Comprehensive Production-Grade Ecosystem Seeder
-- ============================================================================
-- Contains:
-- 1. Official Categories & Verified UAE Data Sources
-- 2. 3 Fully Documented Investment Opportunities (Costs, Risks, Steps)
-- 3. 5 Dedicated User Accounts (Admin, Company, Founder, Investor, Seeker)
--    * Standard Password for ALL accounts is: Test@123456
-- 4. Complete Company Profile, 3 Commercial Offers (approved, in_review, draft), Leads & Ad Campaign
-- 5. 2 Startups/Projects with Pitch Deck Documents & Specific Needs
-- 6. Investor Profile & Private Watchlist
-- 7. Mutual Contact Requests & Realtime Chat Conversations
-- 8. Investment Deal, Digital Contract, Milestones & Escrow Funding
-- 9. Moderation Reports & Admin Audits
-- ============================================================================

-- ============================================================================
-- SECTION 1: Categories & Official Data Sources
-- ============================================================================

INSERT INTO public.categories (id, slug, title_ar, title_en, description_ar, description_en, icon_name, display_order)
VALUES
  ('c0000001-0000-0000-0000-000000000001', 'real-estate', 'العقارات والتطوير', 'Real Estate & Property', 'استثمارات عقارية وإيجارات وتطوير', 'Real estate property and rental investments', 'apartment_rounded', 1),
  ('c0000001-0000-0000-0000-000000000002', 'markets', 'الأسواق المالية', 'Financial Markets', 'صناديق استثمارية وأسواق منظمة ومؤشرات', 'Funds, organized exchange indices and securities', 'candlestick_chart_rounded', 2),
  ('c0000001-0000-0000-0000-000000000003', 'commerce', 'التجارة والتجزئة', 'Commerce & Retail', 'مشاريع تجارية واستيراد وتوزيع', 'Retail, distribution, and commercial trade', 'storefront_rounded', 3),
  ('c0000001-0000-0000-0000-000000000004', 'digital', 'المشاريع الرقمية', 'Digital Ventures', 'متاجر إلكترونية وحلول برمجية وخدمات سحابية', 'E-commerce, SaaS, apps and digital products', 'devices_rounded', 4),
  ('c0000001-0000-0000-0000-000000000005', 'partnerships', 'الشراكات والاستثمار', 'Partnerships & Investment', 'شراكات تشغيلية وتمويل نمو المشاريع', 'Operational partnerships and venture co-funding', 'handshake_rounded', 5),
  ('c0000001-0000-0000-0000-000000000006', 'services', 'الخدمات والأعمال الحرة', 'Services & Freelance', 'خدمات الأعمال والاستشارات والعمل المستقل', 'Business services, consulting and freelance', 'design_services_rounded', 6)
ON CONFLICT (slug) DO UPDATE
SET title_ar = EXCLUDED.title_ar, description_ar = EXCLUDED.description_ar;

-- Sub-categories
INSERT INTO public.categories (id, parent_id, slug, title_ar, title_en, description_ar, description_en, display_order)
VALUES
  ('c0000002-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000004', 'ecommerce', 'التجارة الإلكترونية المتخصصة', 'Niche E-Commerce', 'متاجر إلكترونية لقطاعات وسلع محددة', 'Targeted niche online stores', 1),
  ('c0000002-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000004', 'micro-saas', 'البرمجيات المصغرة والذكاء الاصطناعي', 'Micro-SaaS & AI', 'أدوات أتمتة وخدمات اشتراك رقمية للمؤسسات', 'Cloud tools and automated subscriptions', 2),
  ('c0000002-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000006', 'digital-consulting', 'خدمات التسويق وتأسيس الأعمال', 'Corporate & Marketing Services', 'خدمات متخصصة لتأسيس الشركات والنمو التجاري', 'Business setup and marketing growth', 1)
ON CONFLICT (slug) DO UPDATE
SET title_ar = EXCLUDED.title_ar;

-- Official UAE Data Sources
INSERT INTO public.data_sources (id, name, official_url, data_type, reliability_score, validity_days, notes)
VALUES
  ('d0000001-0000-0000-0000-000000000001', 'اقتصادية دبي (DET)', 'https://www.ded.ae', 'government_registry', 99, 180, 'المصدر الرسمي لاشتراطات ورسوم التراخيص التجارية ورخصة تاجر إلكتروني'),
  ('d0000001-0000-0000-0000-000000000002', 'هيئة تنظيم الاتصالات والحكومة الرقمية (TDRA)', 'https://tdra.gov.ae', 'government_regulator', 98, 365, 'لوائح التجارة الرقمية وحماية بيانات المستهلك في الإمارات'),
  ('d0000001-0000-0000-0000-000000000003', 'صندوق خليفة لتطوير المشاريع', 'https://www.khalifafund.ae', 'official_pricing', 96, 180, 'دراسات الجدوى المعتمدة ونماذج تمويل المشروعات الناشئة'),
  ('d0000001-0000-0000-0000-000000000004', 'سوق أبوظبي العالمي (ADGM)', 'https://www.adgm.com', 'government_regulator', 99, 365, 'اللوائح التنظيمية للشركات الناشئة والاستثمار الجريء')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 2: Verified Investment Opportunities
-- ============================================================================

-- Opportunity 1: متجر القهوة المختصة
INSERT INTO public.opportunities (
  id, category_id, kind, slug, title_ar, title_en, summary_ar, summary_en,
  full_description_ar, full_description_en, min_budget, max_budget, currency,
  min_weekly_hours, knowledge_level_required, risk_level, target_country, target_cities,
  is_verified, is_published, needs_update
) VALUES (
  'e0000001-0000-0000-0000-000000000001',
  'c0000002-0000-0000-0000-000000000001',
  'opportunity',
  'specialty-coffee-ecommerce-uae',
  'متجر إلكتروني متخصص بأدوات القهوة المختصة والتحميص المنزلي',
  'Specialty Home Coffee Niche E-Commerce',
  'مشروع تجارة إلكترونية برأس مال منخفض يعتمد على رخصة تاجر دبي وتوصيل محلي فوري لعشاق القهوة المختصة.',
  'Lean e-commerce venture delivering specialty coffee gear and fresh local beans with next-day UAE fulfillment.',
  'يستهدف المشروع شريحة واسعة من المستهلكين المهتمين بتحضير القهوة المختصة في المنزل. يعتمد النموذج على شراكة مع محامص محلية معتمدة في دبي والشارقة دون الحاجة لتجميد رأس مال ضخم في المخزون، مع الاستفادة من بوابات الدفع الرقمية (Apple Pay، تمارا، تابي).',
  'Targets the booming specialty coffee market in the UAE through dropshipping and on-demand local roaster fulfillment.',
  4500.00, 15000.00, 'AED', 8, 'beginner', 'low', 'AE', '{"Dubai", "Abu Dhabi", "Sharjah"}',
  TRUE, TRUE, FALSE
) ON CONFLICT (slug) DO NOTHING;

-- Costs for Opp 1
INSERT INTO public.opportunity_costs (opportunity_id, item_name_ar, item_name_en, amount, currency, is_mandatory, is_documented, source_reference)
VALUES
  ('e0000001-0000-0000-0000-000000000001', 'رخصة تاجر إلكتروني (DED E-Trader)', 'E-Trader License (DED)', 1070.00, 'AED', TRUE, TRUE, 'اقتصادية دبي DET'),
  ('e0000001-0000-0000-0000-000000000001', 'اشتراك المنصة السحابية والنطاق (.ae)', 'Platform & .ae Domain', 650.00, 'AED', TRUE, TRUE, 'أسعار موثقة للنطاقات والمنصات'),
  ('e0000001-0000-0000-0000-000000000001', 'الدفعة الأولى من المخزون التجريبي', 'Initial Test Inventory Batch', 2000.00, 'AED', TRUE, FALSE, 'تسعير الموردين المحليين'),
  ('e0000001-0000-0000-0000-000000000001', 'ميزانية إعلانات الإطلاق والتجربة', 'Launch Ads Budget', 800.00, 'AED', FALSE, FALSE, 'تقديري لاختبار أول 100 طلب')
ON CONFLICT DO NOTHING;

-- Risks for Opp 1
INSERT INTO public.opportunity_risks (opportunity_id, risk_type, title_ar, title_en, description_ar, description_en, verification_question_ar, verification_question_en, display_order)
VALUES
  (
    'e0000001-0000-0000-0000-000000000001', 'operational',
    'تأخر التوصيل وتلف بعض الأدوات الزجاجية', 'Shipping Delays & Glass Breakage',
    'احتمالية كسر الأدوات الزجاجية الحساسة أثناء الشحن وتأخر الموزع عن موعد التسليم.',
    'Risk of fragile glass tools breaking during transit and courier delays.',
    'هل تعاقدت مع شركة توصيل محلية توفر تغليفاً آمناً وضمان تعويض في حال الكسر؟',
    'Have you partnered with a local courier that provides insured parcel handling?',
    1
  ),
  (
    'e0000001-0000-0000-0000-000000000001', 'market_demand',
    'ارتفاع تكلفة الاستحواذ على العميل (CAC)', 'High Customer Acquisition Cost',
    'المنافسة الإعلانية الشرسة على منصات التواصل قد تؤدي لتآكل هامش الربح التشغيلي.',
    'Heavy ad auction competition driving customer acquisition costs higher.',
    'هل تملك استراتيجية لصناعة محتوى فيديو عضوي (Reels/TikTok) يخفف الاعتماد على الإعلانات؟',
    'Do you have an organic video content pipeline to drive traffic without high ad spend?',
    2
  )
ON CONFLICT DO NOTHING;

-- Steps for Opp 1
INSERT INTO public.opportunity_steps (opportunity_id, step_number, title_ar, title_en, description_ar, description_en, estimated_days)
VALUES
  ('e0000001-0000-0000-0000-000000000001', 1, 'استخراج رخصة تاجر إلكتروني من اقتصادية دبي', 'Issue DED E-Trader License', 'التقديم الإلكتروني السريع عبر بوابة Invest in Dubai وسداد الرسوم الرسمية.', 'Apply online via Invest in Dubai portal and pay government fees.', 2),
  ('e0000001-0000-0000-0000-000000000001', 2, 'إعداد المتجر وربط بوابة الدفع والشحن', 'Store Setup & Payment Integration', 'تصميم واجهة المتجر وربط بوابات الدفع (Apple Pay / Tamara) وتعيين شركة التوصيل.', 'Set up storefront, connect payment gateways, and configure local courier delivery.', 4),
  ('e0000001-0000-0000-0000-000000000001', 3, 'إطلاق أول حملة ترويجية واستقبال الطلبات', 'Launch Promotion & Orders', 'بدء النشر التسويقي وتوزيع عينات للمؤثرين لاختبار تدفق الطلبات الأولية.', 'Initiate targeted promo campaigns and fulfill initial customer orders.', 7)
ON CONFLICT DO NOTHING;

-- Opportunity 2: وكالة أتمتة الذكاء الاصطناعي (B2B AI Automation Agency)
INSERT INTO public.opportunities (
  id, category_id, kind, slug, title_ar, title_en, summary_ar, summary_en,
  full_description_ar, full_description_en, min_budget, max_budget, currency,
  min_weekly_hours, knowledge_level_required, risk_level, target_country, target_cities,
  is_verified, is_published, needs_update
) VALUES (
  'e0000001-0000-0000-0000-000000000002',
  'c0000002-0000-0000-0000-000000000002',
  'opportunity',
  'ai-automation-agency-uae',
  'وكالة حلول أتمتة خدمة العملاء والمبيعات بالذكاء الاصطناعي للشركات',
  'B2B AI Customer Operations Agency',
  'تأسيس وكالة متخصصة لبناء روبوتات محادثة ذكية وتكاملات CRM لقطاع العقارات والعيادات في الإمارات.',
  'High-margin agency setting up automated WhatsApp and CRM workflows for local businesses.',
  'تقدم الوكالة خدمات متطورة لأتمتة الردود على العملاء عبر الواتساب وربطها بنظام إدارة علاقات العملاء (HubSpot / Salesforce). السوق المحلي في دبي وأبوظبي يشهد طلباً غير مسبوق من شركات العقارات والمراكز الطبية لتقليل زمن الاستجابة للمستفسرين.',
  'Empowers UAE real estate and medical clinics with 24/7 intelligent CRM and WhatsApp lead response bots.',
  2500.00, 8000.00, 'AED', 12, 'intermediate', 'low', 'AE', '{"Dubai", "Abu Dhabi"}',
  TRUE, TRUE, FALSE
) ON CONFLICT (slug) DO NOTHING;

-- Opportunity 3: مطبخ سحابي للوجبات الصحية
INSERT INTO public.opportunities (
  id, category_id, kind, slug, title_ar, title_en, summary_ar, summary_en,
  full_description_ar, full_description_en, min_budget, max_budget, currency,
  min_weekly_hours, knowledge_level_required, risk_level, target_country, target_cities,
  is_verified, is_published, needs_update
) VALUES (
  'e0000001-0000-0000-0000-000000000003',
  'c0000001-0000-0000-0000-000000000003',
  'opportunity',
  'cloud-kitchen-healthy-meals',
  'علامة اشتراكات وجبات غذائية صحية عبر المطابخ السحابية المشتركة',
  'Healthy Subscription Cloud Kitchen Brand',
  'نموذج اشتراكات أسبوعية وشهرية لوجبات اللياقة والتخسيس مع التوصيل اليومي للموظفين في دبي.',
  'Subscription-based fitness food delivery operating out of shared commercial cloud kitchens.',
  'يعتمد المشروع على استئجار مساحة طهي مجهزة في مطبخ سحابي مركزي (Kitopi أو Deliveroo Editions) لتقليل تكلفة التأسيس. الاشتراكات المدفوعة مقدماً تضمن تدفقاً نقدياً إيجابياً وتفادي هدر المكونات.',
  'Leverages shared commercial cloud kitchen infrastructure with prepaid monthly recurring subscriber subscriptions.',
  25000.00, 65000.00, 'AED', 20, 'intermediate', 'medium', 'AE', '{"Dubai", "Sharjah"}',
  TRUE, TRUE, FALSE
) ON CONFLICT (slug) DO NOTHING;

-- ============================================================================
-- SECTION 3: Dedicated User Accounts (5 Specific Isolated Roles)
-- Standard Password for all 5 accounts: Test@123456
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Fix any NULL token columns in auth.users that crash GoTrue scanner with "converting NULL to string is unsupported"
UPDATE auth.users
SET confirmation_token = COALESCE(confirmation_token, ''),
    recovery_token = COALESCE(recovery_token, ''),
    email_change_token_new = COALESCE(email_change_token_new, ''),
    email_change = COALESCE(email_change, ''),
    email_change_token_current = COALESCE(email_change_token_current, ''),
    phone_change = COALESCE(phone_change, ''),
    phone_change_token = COALESCE(phone_change_token, ''),
    reauthentication_token = COALESCE(reauthentication_token, ''),
    last_sign_in_at = COALESCE(last_sign_in_at, NOW())
WHERE email IN (
  'admin@moneyideas.ae',
  'company@moneyideas.ae',
  'founder@moneyideas.ae',
  'investor@moneyideas.ae',
  'seeker@moneyideas.ae'
);

-- User 1: Super Admin (سالم المنصوري - الإدارة العليا)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_sso_user, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token,
  last_sign_in_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '11111111-1111-1111-1111-111111111111',
  'authenticated', 'authenticated',
  'admin@moneyideas.ae',
  crypt('Test@123456', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"سالم المنصوري (مدير النظام)"}'::jsonb,
  FALSE,
  NOW(), NOW(),
  '', '', '', '', '', '', '', '',
  NOW()
) ON CONFLICT (id) DO UPDATE
SET encrypted_password = crypt('Test@123456', gen_salt('bf')),
    email_confirmed_at = NOW(),
    confirmation_token = '',
    recovery_token = '',
    email_change = '',
    email_change_token_new = '',
    email_change_token_current = '',
    phone_change = '',
    phone_change_token = '',
    reauthentication_token = '',
    last_sign_in_at = NOW(),
    raw_app_meta_data = EXCLUDED.raw_app_meta_data,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- User 2: Company / Service Provider (شركة الرواد لحلول الأعمال)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_sso_user, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token,
  last_sign_in_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '22222222-2222-2222-2222-222222222222',
  'authenticated', 'authenticated',
  'company@moneyideas.ae',
  crypt('Test@123456', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"شركة الرواد لحلول الأعمال"}'::jsonb,
  FALSE,
  NOW(), NOW(),
  '', '', '', '', '', '', '', '',
  NOW()
) ON CONFLICT (id) DO UPDATE
SET encrypted_password = crypt('Test@123456', gen_salt('bf')),
    email_confirmed_at = NOW(),
    confirmation_token = '',
    recovery_token = '',
    email_change = '',
    email_change_token_new = '',
    email_change_token_current = '',
    phone_change = '',
    phone_change_token = '',
    reauthentication_token = '',
    last_sign_in_at = NOW(),
    raw_app_meta_data = EXCLUDED.raw_app_meta_data,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- User 3: Project Owner / Founder (راشد الكتبي - رائد أعمال)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_sso_user, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token,
  last_sign_in_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '33333333-3333-3333-3333-333333333333',
  'authenticated', 'authenticated',
  'founder@moneyideas.ae',
  crypt('Test@123456', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"راشد الكتبي (رائد أعمال)"}'::jsonb,
  FALSE,
  NOW(), NOW(),
  '', '', '', '', '', '', '', '',
  NOW()
) ON CONFLICT (id) DO UPDATE
SET encrypted_password = crypt('Test@123456', gen_salt('bf')),
    email_confirmed_at = NOW(),
    confirmation_token = '',
    recovery_token = '',
    email_change = '',
    email_change_token_new = '',
    email_change_token_current = '',
    phone_change = '',
    phone_change_token = '',
    reauthentication_token = '',
    last_sign_in_at = NOW(),
    raw_app_meta_data = EXCLUDED.raw_app_meta_data,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- User 4: Investor (منصور الهاشمي - مستثمر ملائكي)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_sso_user, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token,
  last_sign_in_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '44444444-4444-4444-4444-444444444444',
  'authenticated', 'authenticated',
  'investor@moneyideas.ae',
  crypt('Test@123456', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"منصور الهاشمي (مستثمر ملائكي)"}'::jsonb,
  FALSE,
  NOW(), NOW(),
  '', '', '', '', '', '', '', '',
  NOW()
) ON CONFLICT (id) DO UPDATE
SET encrypted_password = crypt('Test@123456', gen_salt('bf')),
    email_confirmed_at = NOW(),
    confirmation_token = '',
    recovery_token = '',
    email_change = '',
    email_change_token_new = '',
    email_change_token_current = '',
    phone_change = '',
    phone_change_token = '',
    reauthentication_token = '',
    last_sign_in_at = NOW(),
    raw_app_meta_data = EXCLUDED.raw_app_meta_data,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- User 5: Individual Seeker (لينا برديل - باحثة عن فرصة)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, is_sso_user, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token,
  last_sign_in_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '55555555-5555-5555-5555-555555555555',
  'authenticated', 'authenticated',
  'seeker@moneyideas.ae',
  crypt('Test@123456', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"لينا برديل (باحثة عن فرصة)"}'::jsonb,
  FALSE,
  NOW(), NOW(),
  '', '', '', '', '', '', '', '',
  NOW()
) ON CONFLICT (id) DO UPDATE
SET encrypted_password = crypt('Test@123456', gen_salt('bf')),
    email_confirmed_at = NOW(),
    confirmation_token = '',
    recovery_token = '',
    email_change = '',
    email_change_token_new = '',
    email_change_token_current = '',
    phone_change = '',
    phone_change_token = '',
    reauthentication_token = '',
    last_sign_in_at = NOW(),
    raw_app_meta_data = EXCLUDED.raw_app_meta_data,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- Supabase GoTrue Auth Identities (Must match user_id for email provider)
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    jsonb_build_object('sub', '11111111-1111-1111-1111-111111111111', 'email', 'admin@moneyideas.ae', 'email_verified', true),
    'email',
    '11111111-1111-1111-1111-111111111111',
    NOW(), NOW(), NOW()
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    jsonb_build_object('sub', '22222222-2222-2222-2222-222222222222', 'email', 'company@moneyideas.ae', 'email_verified', true),
    'email',
    '22222222-2222-2222-2222-222222222222',
    NOW(), NOW(), NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    jsonb_build_object('sub', '33333333-3333-3333-3333-333333333333', 'email', 'founder@moneyideas.ae', 'email_verified', true),
    'email',
    '33333333-3333-3333-3333-333333333333',
    NOW(), NOW(), NOW()
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    '44444444-4444-4444-4444-444444444444',
    jsonb_build_object('sub', '44444444-4444-4444-4444-444444444444', 'email', 'investor@moneyideas.ae', 'email_verified', true),
    'email',
    '44444444-4444-4444-4444-444444444444',
    NOW(), NOW(), NOW()
  ),
  (
    '55555555-5555-5555-5555-555555555555',
    '55555555-5555-5555-5555-555555555555',
    jsonb_build_object('sub', '55555555-5555-5555-5555-555555555555', 'email', 'seeker@moneyideas.ae', 'email_verified', true),
    'email',
    '55555555-5555-5555-5555-555555555555',
    NOW(), NOW(), NOW()
  )
ON CONFLICT (id) DO UPDATE
SET identity_data = EXCLUDED.identity_data,
    provider_id = EXCLUDED.provider_id,
    last_sign_in_at = NOW();

-- Public Profiles (Ensure they exist and are correctly populated)
INSERT INTO public.profiles (id, full_name, is_verified, city, phone)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'سالم المنصوري (مدير النظام)', TRUE, 'Dubai', '+971501112233'),
  ('22222222-2222-2222-2222-222222222222', 'شركة الرواد لحلول الأعمال', TRUE, 'Dubai', '+97148889900'),
  ('33333333-3333-3333-3333-333333333333', 'راشد الكتبي (رائد أعمال)', TRUE, 'Dubai', '+971507778899'),
  ('44444444-4444-4444-4444-444444444444', 'منصور الهاشمي (مستثمر ملائكي)', TRUE, 'Abu Dhabi', '+971509990011'),
  ('55555555-5555-5555-5555-555555555555', 'لينا برديل (باحثة عن فرصة)', FALSE, 'Dubai', '+971554443322')
ON CONFLICT (id) DO UPDATE
SET full_name = EXCLUDED.full_name,
    is_verified = EXCLUDED.is_verified,
    city = EXCLUDED.city,
    phone = EXCLUDED.phone;

-- ============================================================================
-- SECTION 4: Strictly Separate User Roles
-- ============================================================================

-- Ensure users can read their own roles from user_roles table
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (user_id = auth.uid() OR public.is_admin());

-- Clean accidental roles to guarantee strict role separation
DELETE FROM public.user_roles WHERE user_id IN (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222',
  '33333333-3333-3333-3333-333333333333',
  '44444444-4444-4444-4444-444444444444',
  '55555555-5555-5555-5555-555555555555'
);

-- Insert exact isolated single role for each user:
INSERT INTO public.user_roles (user_id, role, is_active)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'admin', TRUE),
  ('22222222-2222-2222-2222-222222222222', 'company', TRUE),
  ('33333333-3333-3333-3333-333333333333', 'project_owner', TRUE),
  ('44444444-4444-4444-4444-444444444444', 'investor', TRUE),
  ('55555555-5555-5555-5555-555555555555', 'individual', TRUE);

-- Update Analytical Preferences for Seeker (Lina)
INSERT INTO public.user_preferences (
  user_id, has_no_capital, budget_amount, budget_ceiling, experience_level,
  weekly_available_hours, wants_active_management, risk_tolerance, liquidity_need, profile_completion_percentage
) VALUES (
  '55555555-5555-5555-5555-555555555555',
  FALSE, 15000.00, 25000.00, 'intermediate', 10, TRUE, 'medium', 'medium_term', 100
) ON CONFLICT (user_id) DO UPDATE
SET budget_amount = 15000.00, weekly_available_hours = 10, profile_completion_percentage = 100;

-- Goals for Seeker
INSERT INTO public.user_goals (user_id, goal)
VALUES
  ('55555555-5555-5555-5555-555555555555', 'discover_idea'),
  ('55555555-5555-5555-5555-555555555555', 'find_service')
ON CONFLICT DO NOTHING;

-- Saved Opportunity for Seeker
INSERT INTO public.saved_opportunities (user_id, opportunity_id, personal_note, folder_name)
VALUES
  ('55555555-5555-5555-5555-555555555555', 'e0000001-0000-0000-0000-000000000001', 'فكرة ممتازة جداً وأرغب في مراجعة التكلفة مع شركة الرواد', 'أفكاري المفضلة')
ON CONFLICT DO NOTHING;

-- Next Steps Tasks for Seeker
INSERT INTO public.next_step_tasks (user_id, opportunity_id, title, description, status, due_date)
VALUES
  ('55555555-5555-5555-5555-555555555555', 'e0000001-0000-0000-0000-000000000001', 'مراجعة شروط رخصة تاجر في دبي عبر الموقع الرسمي', 'التحقق من الرسوم الرسمية لاقتصادية دبي', 'completed', CURRENT_DATE - INTERVAL '1 day'),
  ('55555555-5555-5555-5555-555555555555', 'e0000001-0000-0000-0000-000000000001', 'التواصل مع شركة الرواد لبحث باقة المتجر الإلكتروني الجاهز', 'الاستفسار عن الشحن المحلي وبوابة الدفع', 'in_progress', CURRENT_DATE + INTERVAL '2 days'),
  ('55555555-5555-5555-5555-555555555555', 'e0000001-0000-0000-0000-000000000001', 'اختيار 3 أصناف قهوة من المحامص المحلية وبدء التصوير', 'تحضير النماذج الأولية للمنتجات', 'not_started', CURRENT_DATE + INTERVAL '7 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 5: Company Ecosystem (الرواد لحلول الأعمال)
-- ============================================================================

INSERT INTO public.companies (
  id, owner_id, legal_name, trade_name, business_type, country_code, city,
  trade_license_number, license_issuing_authority, license_expiry_date,
  official_email, official_phone, website_url, bio, verification_status, verified_at
) VALUES (
  'aaaaaaaa-2222-2222-2222-222222222222',
  '22222222-2222-2222-2222-222222222222',
  'شركة الرواد للحلول المؤسسية وتطوير الأعمال ذ.م.م',
  'الرواد لتأسيس الأعمال (Al-Rowad Corporate)',
  'تأسيس شركات، حلول رقمية، وتراخيص تجارية',
  'AE', 'Dubai',
  'CN-2894103', 'اقتصادية دبي DET', '2027-06-30',
  'contact@alrowad-corp.ae', '+97148889900', 'https://alrowad-corp.ae',
  'شريكك المعتمد لتأسيس وترخيص المشاريع الناشئة والتحول الرقمي في دولة الإمارات العربية المتحدة بخبرة تمتد لأكثر من 8 سنوات.',
  'verified', NOW()
) ON CONFLICT (id) DO UPDATE
SET verification_status = 'verified';

-- Company Team Member
INSERT INTO public.company_members (company_id, user_id, role)
VALUES
  ('aaaaaaaa-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'owner')
ON CONFLICT (company_id, user_id) DO NOTHING;

-- Offer 1: Approved & Published Offer (تأسيس رخصة دبي شامل)
INSERT INTO public.company_offers (
  id, company_id, category_id, title, description, service_type,
  price, price_currency, additional_fees_description, target_cities,
  terms_and_conditions, valid_from, valid_until, status, views_count, leads_count
) VALUES (
  'bbbbbbbb-0001-2222-2222-222222222222',
  'aaaaaaaa-2222-2222-2222-222222222222',
  'c0000002-0000-0000-0000-000000000003',
  'باقة تأسيس رخصة تجارية شاملة في دبي مع إقامة مستثمر وحساب بنكي مضمون',
  'تشمل الباقة: إصدار الرخصة التجارية الفورية، الموافقة المبدئية، عقد التأسيس الموثق، إقامة مستثمر لمدة سنتين، وتنسيق فتح الحساب البنكي التجاري في بنك الإمارات دبي الوطني أو بنك المشرق.',
  'تأسيس أعمال وخدمات قانونية',
  12500.00, 'AED', 'لا تشمل رسوم فحص اللياقة الطبية وبطاقة الهوية (حوالي 850 درهم تدفع للهيئة مباشرة)',
  '{"Dubai", "Abu Dhabi", "Sharjah"}',
  'تسليم كافة المعاملات والمستندات خلال 5 إلى 7 أيام عمل رسمية، مع ضمان استرداد الرسوم في حال عدم صدور الموافقة.',
  CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '180 days',
  'approved', 420, 18
) ON CONFLICT (id) DO NOTHING;

-- Offer 2: Under Review Offer (برمجة متجر إلكتروني احترافي)
INSERT INTO public.company_offers (
  id, company_id, category_id, title, description, service_type,
  price, price_currency, additional_fees_description, target_cities,
  terms_and_conditions, valid_from, valid_until, status, views_count, leads_count
) VALUES (
  'bbbbbbbb-0002-2222-2222-222222222222',
  'aaaaaaaa-2222-2222-2222-222222222222',
  'c0000002-0000-0000-0000-000000000001',
  'تصميم وبرمجة متجر إلكتروني متكامل متوافق مع Apple Pay وتمارا وتوصيل محلي',
  'بناء متجر إلكتروني سريع يدعم اللغتين العربية والإنجليزية، مربوط بالكامل مع شركات الشحن المحلية في الإمارات وبوابات الدفع بالتقسيط مع لوحة تحكم ذكية.',
  'برمجة وتجارة رقمية',
  7900.00, 'AED', 'رسوم اشتراك المنصة السحابية تدفع سنوياً',
  '{"Dubai", "Abu Dhabi"}',
  'مدة التسليم 14 يوم عمل مع فترة دعم فني مجاني لمدة 3 أشهر.',
  CURRENT_DATE, CURRENT_DATE + INTERVAL '90 days',
  'in_review', 65, 3
) ON CONFLICT (id) DO NOTHING;

-- Offer 3: Draft Offer (استشارات ضريبة الشركات)
INSERT INTO public.company_offers (
  id, company_id, category_id, title, description, service_type,
  price, price_currency, terms_and_conditions, valid_from, valid_until, status
) VALUES (
  'bbbbbbbb-0003-2222-2222-222222222222',
  'aaaaaaaa-2222-2222-2222-222222222222',
  'c0000001-0000-0000-0000-000000000006',
  'حزمة الامتثال لضريبة الشركات وضريبة القيمة المضافة وإعداد القوائم المالية',
  'استشارات وإعداد الدفاتر المحاسبية والتسجيل لضريبة الشركات في الهيئة الاتحادية للضرائب FTA مع خبير معتمد.',
  'استشارات مالية وضريبية',
  3500.00, 'AED', 'يحدد العقد نطاق العمل بدقة والتقارير الشهرية المطلوبة',
  CURRENT_DATE, CURRENT_DATE + INTERVAL '60 days',
  'draft'
) ON CONFLICT (id) DO NOTHING;

-- Company Leads
INSERT INTO public.offer_leads (id, offer_id, user_id, inquiry_message, status, company_notes)
VALUES
  ('11111111-cccc-0001-0000-000000000001', 'bbbbbbbb-0001-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', 'أرغب بالاستفسار عن رخصة تاجر وإمكانية بيع المنتجات الغذائية والقهوة.', 'contacted', 'تم الرد وطلب المستندات'),
  ('11111111-cccc-0002-0000-000000000002', 'bbbbbbbb-0001-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'هل تشمل الباقة إضافة شركاء أجانب وتوثيق الاتفاقيات في دبي؟', 'new', NULL)
ON CONFLICT (id) DO NOTHING;

-- Commercial Ad Campaign
INSERT INTO public.ad_campaigns (id, company_id, offer_id, campaign_title, target_cities, start_date, end_date, is_active, admin_approved, total_impressions, total_clicks)
VALUES (
  'dddddddd-0001-2222-2222-222222222222',
  'aaaaaaaa-2222-2222-2222-222222222222',
  'bbbbbbbb-0001-2222-2222-222222222222',
  'حملة إطلاق عروض التأسيس لرواد الأعمال في دبي',
  '{"Dubai", "Abu Dhabi"}',
  CURRENT_DATE - INTERVAL '5 days',
  CURRENT_DATE + INTERVAL '25 days',
  TRUE,
  TRUE,
  18500,
  890
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 6: Projects Ecosystem (راشد الكتبي - رائد أعمال)
-- ============================================================================

-- Project 1: SwiftCart (سويفت كارت - تطبيق لوجستي سريع)
INSERT INTO public.projects (
  id, owner_id, category_id, type, stage, name, summary,
  problem_statement, solution_statement, target_audience, revenue_model,
  help_needed_type, regulatory_approval_status, is_published
) VALUES (
  '99999999-0001-3333-3333-333333333333',
  '33333333-3333-3333-3333-333333333333',
  'c0000002-0000-0000-0000-000000000001',
  'investment_request',
  'prototype',
  'سويفت كارت (SwiftCart) - لوجستيات التجارة الفورية في دبي',
  'منصة ذكية لتجميع وإدارة التوصيل في نفس الساعة للمتاجر الإلكترونية المحلية بأسطول دراجات كهربائية صديقة للبيئة.',
  'معظم المتاجر الإلكترونية المحلية في الإمارات تعاني من تأخر التوصيل لليوم التالي وارتفاع تكلفة الشحن السريع للطلبات الفردية.',
  'نظام ذكي يوزع الشحنات عبر مراكز توزيع مصغرة (Micro-Hubs) داخل أحياء دبي الرئيسية لتحقيق توصيل مضمون خلال 60 دقيقة بتكلفة مخفضة.',
  'أصحاب المتاجر الإلكترونية في قطاعات الأزياء، الهدايا، العطور، والأغذية الفاخرة في دبي.',
  'عمولة ثابتة 15 درهم لكل شحنة + اشتراك شهري مخفض للشركات المتعاقدة.',
  'استثمار',
  'verified', TRUE
) ON CONFLICT (id) DO NOTHING;

-- Project Documents
INSERT INTO public.project_documents (project_id, title, file_url, is_public)
VALUES
  ('99999999-0001-3333-3333-333333333333', 'عرض المستثمرين التقديمي (Pitch Deck 2026)', 'https://storage.moneyideas.ae/docs/swiftcart-deck.pdf', TRUE),
  ('99999999-0001-3333-3333-333333333333', 'دراسة الجدوى المالية وخطة التدفقات النقدية 3 سنوات', 'https://storage.moneyideas.ae/docs/swiftcart-financials.pdf', FALSE)
ON CONFLICT DO NOTHING;

-- Project 2: تطبيق راشن (B2B HORECA Supply)
INSERT INTO public.projects (
  id, owner_id, category_id, type, stage, name, summary,
  problem_statement, solution_statement, target_audience, revenue_model,
  help_needed_type, regulatory_approval_status, is_published
) VALUES (
  '99999999-0002-3333-3333-333333333333',
  '33333333-3333-3333-3333-333333333333',
  'c0000002-0000-0000-0000-000000000002',
  'idea',
  'concept',
  'تطبيق راشن (Rashen) - توريد وتزويد المقاهي والمطاعم',
  'منصة B2B تربط المقاهي والمطاعم المستقلة بالمزارع والموردين المباشرين للمواد الخام مع جدولة دورية مؤتمتة.',
  'المقاهي والمطاعم الصغيرة تهدر ساعات أسبوعياً في التعامل مع عشرات الموردين يدوياً بأسعار غير شفافة.',
  'لوحة موحدة لطلب جميع الاحتياجات بضغطة زر وفاتورة مجمعة وأسعار جملة منافسة.',
  'أكثر من 3500 مقهى ومطعم مستقل في دبي وأبوظبي.',
  'هامش ربح تجاري 8% على قيمة التوريدات + اشتراك برمجيات للموردين.',
  'شريك تقني',
  'unverified', TRUE
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 7: Investor Ecosystem (منصور الهاشمي - مستثمر ملائكي)
-- ============================================================================

INSERT INTO public.investor_profiles (
  id, user_id, investor_type, bio, sectors_of_interest, target_markets,
  preferred_stages, show_financial_range_publicly, min_ticket_size, max_ticket_size,
  currency, contact_conditions, is_verified
) VALUES (
  '88888888-0001-4444-4444-444444444444',
  '44444444-4444-4444-4444-444444444444',
  'مستثمر ملائكي ورائد أعمال سابق',
  'أبحث عن مشاريع ريادية واعدة في قطاعات اللوجستيات، التجارة الإلكترونية، والتقنية المالية ذات نموذج عمل واضح وقابل للتوسع في دول الخليج.',
  '{"التجارة الإلكترونية", "اللوجستيات", "التقنية المالية (FinTech)", "الأغذية والمشروبات"}',
  '{"UAE", "KSA"}',
  '{prototype, generating_revenue}',
  TRUE, 50000.00, 500000.00, 'AED',
  'يشترط وجود نموذج أولي يعمل وخطة واضحة لاستخدام رأس المال مع فريق متفرغ.',
  TRUE
) ON CONFLICT (user_id) DO UPDATE
SET is_verified = TRUE;

-- Investor Watchlist
INSERT INTO public.investor_watchlist (investor_id, project_id, private_notes)
VALUES (
  '44444444-4444-4444-4444-444444444444',
  '99999999-0001-3333-3333-333333333333',
  'مشروع ممتاز، قابل للتوسع بسرعة في دبي، الفريق نشط جداً وتكاليف التشغيل واقعية. بدأت جولة تفاوض على 150 ألف درهم.'
) ON CONFLICT (investor_id, project_id) DO NOTHING;

-- ============================================================================
-- SECTION 8: Contact Requests & Realtime Messaging
-- ============================================================================

-- Contact request from Investor to Founder
INSERT INTO public.contact_requests (
  id, sender_id, receiver_id, project_id, reason, introduction_message, status, responded_at
) VALUES (
  '77777777-0001-0000-0000-000000000001',
  '44444444-4444-4444-4444-444444444444',
  '33333333-3333-3333-3333-333333333333',
  '99999999-0001-3333-3333-333333333333',
  'مناقشة الاستثمار والشراكة في سويفت كارت',
  'مرحباً راشد، اطلعت على مشروع سويفت كارت ونموذج العمل في دبي، مهتم جداً بتمويل المرحلة الأولى وتقديم الدعم الاستراتيجي.',
  'accepted', NOW() - INTERVAL '3 days'
) ON CONFLICT (id) DO NOTHING;

-- Conversation 1: Investor & Founder
INSERT INTO public.conversations (id, contact_request_id, participant_one, participant_two, last_message_at)
VALUES (
  '66666666-0001-0000-0000-000000000001',
  '77777777-0001-0000-0000-000000000001',
  '44444444-4444-4444-4444-444444444444',
  '33333333-3333-3333-3333-333333333333',
  NOW() - INTERVAL '1 hour'
) ON CONFLICT (participant_one, participant_two) DO NOTHING;

INSERT INTO public.messages (conversation_id, sender_id, body, is_read, created_at)
VALUES
  ('66666666-0001-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', 'السلام عليكم أخي راشد، أود مراجعة مسودة العقد الرقمي التي تم إيداعها عبر منصة أفكار المال.', TRUE, NOW() - INTERVAL '2 days'),
  ('66666666-0001-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333', 'أهلاً وسهلاً أستاذ منصور، يسعدني ذلك جداً. اطلعت على شروط المعالم وهي مناسبة جداً للجدول الزمني للإطلاق.', TRUE, NOW() - INTERVAL '1 day'),
  ('66666666-0001-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', 'تم توقيع العقد من طرفي بنجاح، وتم إيداع الدفعة الأولى بحساب الضمان المالي المعتمد.', FALSE, NOW() - INTERVAL '1 hour')
ON CONFLICT DO NOTHING;

-- Conversation 2: Seeker & Company
INSERT INTO public.conversations (id, participant_one, participant_two, last_message_at)
VALUES (
  '66666666-0002-0000-0000-000000000002',
  '55555555-5555-5555-5555-555555555555',
  '22222222-2222-2222-2222-222222222222',
  NOW() - INTERVAL '5 hours'
) ON CONFLICT (participant_one, participant_two) DO NOTHING;

INSERT INTO public.messages (conversation_id, sender_id, body, is_read, created_at)
VALUES
  ('66666666-0002-0000-0000-000000000002', '55555555-5555-5555-5555-555555555555', 'مرحباً شركة الرواد، هل يمكن لرخصة تاجر تغطية بيع حبوب القهوة المحمصة محلياً؟', TRUE, NOW() - INTERVAL '6 hours'),
  ('66666666-0002-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'أهلاً بك لينا، نعم بالتأكيد! نشاط تجارة البن والمشروبات مشمول بنشاط التاجر الإلكتروني في دبي وتصدر الموافقة خلال 48 ساعة.', FALSE, NOW() - INTERVAL '5 hours')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 9: Active Investment Deal, Digital Contract & Escrow
-- ============================================================================

-- Ensure tables exist (from migration 00010_deals_and_escrow.sql)
CREATE TABLE IF NOT EXISTS public.deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  investor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  deal_type TEXT NOT NULL DEFAULT 'equity',
  target_amount NUMERIC(14, 2) NOT NULL DEFAULT 0,
  equity_percentage NUMERIC(5, 2) DEFAULT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  terms_summary TEXT,
  investor_signed_at TIMESTAMPTZ DEFAULT NULL,
  creator_signed_at TIMESTAMPTZ DEFAULT NULL,
  escrow_account_id TEXT DEFAULT NULL,
  escrow_status TEXT NOT NULL DEFAULT 'not_initiated',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_deal_type CHECK (deal_type IN ('equity', 'convertible_note', 'debt_financing', 'franchise_partnership', 'acquisition')),
  CONSTRAINT chk_deal_status CHECK (status IN ('draft', 'negotiation', 'contract_pending', 'escrow_funded', 'in_progress', 'completed', 'cancelled')),
  CONSTRAINT chk_escrow_status CHECK (escrow_status IN ('not_initiated', 'pending_deposit', 'held_in_escrow', 'released', 'disputed'))
);

CREATE TABLE IF NOT EXISTS public.deal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID NOT NULL REFERENCES public.deals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  amount NUMERIC(14, 2) NOT NULL DEFAULT 0,
  order_index INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  proof_url TEXT DEFAULT NULL,
  due_date DATE DEFAULT NULL,
  completed_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_milestone_status CHECK (status IN ('pending', 'submitted_for_approval', 'approved', 'released', 'disputed'))
);

CREATE TABLE IF NOT EXISTS public.deal_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID NOT NULL REFERENCES public.deals(id) ON DELETE CASCADE,
  contract_version INTEGER NOT NULL DEFAULT 1,
  legal_clauses JSONB NOT NULL DEFAULT '[]'::jsonb,
  governing_law TEXT NOT NULL DEFAULT 'قوانين وإجراءات مركز دبي المالي العالمي (DIFC) / سوق أبوظبي العالمي (ADGM) ودولة الإمارات العربية المتحدة',
  dispute_mechanism TEXT NOT NULL DEFAULT 'الوساطة والتحكيم المالي المعتمد',
  investor_signature TEXT DEFAULT NULL,
  creator_signature TEXT DEFAULT NULL,
  investor_signed_at TIMESTAMPTZ DEFAULT NULL,
  creator_signed_at TIMESTAMPTZ DEFAULT NULL,
  is_finalized BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_contracts ENABLE ROW LEVEL SECURITY;

-- Basic View & Manage Policies for Deals (Idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'deals' AND policyname = 'Participants and admins can view deals') THEN
    CREATE POLICY "Participants and admins can view deals" ON public.deals FOR SELECT
      USING (investor_id = auth.uid() OR creator_id = auth.uid() OR public.is_admin());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'deal_milestones' AND policyname = 'Participants and admins can view deal milestones') THEN
    CREATE POLICY "Participants and admins can view deal milestones" ON public.deal_milestones FOR SELECT
      USING (EXISTS (SELECT 1 FROM public.deals d WHERE d.id = deal_milestones.deal_id AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'deal_contracts' AND policyname = 'Participants and admins can view deal contracts') THEN
    CREATE POLICY "Participants and admins can view deal contracts" ON public.deal_contracts FOR SELECT
      USING (EXISTS (SELECT 1 FROM public.deals d WHERE d.id = deal_contracts.deal_id AND (d.investor_id = auth.uid() OR d.creator_id = auth.uid() OR public.is_admin())));
  END IF;
END $$;

INSERT INTO public.deals (
  id, project_id, investor_id, creator_id, title, deal_type,
  target_amount, equity_percentage, status, terms_summary,
  investor_signed_at, creator_signed_at, escrow_account_id, escrow_status
) VALUES (
  '55555555-dead-0001-0000-000000000001',
  '99999999-0001-3333-3333-333333333333',
  '44444444-4444-4444-4444-444444444444',
  '33333333-3333-3333-3333-333333333333',
  'جولة التمويل الأولي لمنصة سويفت كارت اللوجستية (Pre-Seed)',
  'equity',
  150000.00, 12.00,
  'escrow_funded',
  'تمويل بقيمة 150,000 درهم إماراتي مقابل 12% حصة ملكية، مقسمة على 3 معالم تنفيذية مرتبطة بمخرجات تقنية وتشغيلية موثقة.',
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '2 days',
  'ESCROW-DXB-98421',
  'held_in_escrow'
) ON CONFLICT (id) DO NOTHING;

-- Deal Contract
INSERT INTO public.deal_contracts (
  id, deal_id, contract_version, governing_law, dispute_mechanism,
  investor_signature, creator_signature, investor_signed_at, creator_signed_at, is_finalized
) VALUES (
  '55555555-c001-0001-0000-000000000001',
  '55555555-dead-0001-0000-000000000001',
  1,
  'قوانين مركز دبي المالي العالمي (DIFC) ودولة الإمارات العربية المتحدة',
  'التحكيم المالي المعتمد لفض النزاعات الاستثمارية',
  'منصور بن حمد الهاشمي - توقيع رقمي معتمد',
  'راشد بن سعيد الكتبي - توقيع رقمي معتمد',
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '2 days',
  TRUE
) ON CONFLICT (id) DO NOTHING;

-- Deal Milestones
INSERT INTO public.deal_milestones (
  id, deal_id, title, description, amount, order_index, status, completed_at
) VALUES
  (
    '55555555-0001-0001-0000-000000000001',
    '55555555-dead-0001-0000-000000000001',
    'المعلم الأول: إطلاق النسخة التجريبية MVP وربط أول 20 متجراً في دبي',
    'اكتمال تطبيق السائق وتطبيق التاجر والتشغيل التجريبي بنجاح.',
    50000.00, 1, 'released', NOW() - INTERVAL '1 day'
  ),
  (
    '55555555-0002-0001-0000-000000000002',
    '55555555-dead-0001-0000-000000000001',
    'المعلم الثاني: الوصول إلى 500 طلب يومي واكتمال 3 مراكز توزيع مصغرة',
    'تحقيق متوسط 500 طلب توصيل يومياً بنسبة تسليم ناجح تتجاوز 98%.',
    60000.00, 2, 'pending', NULL
  ),
  (
    '55555555-0003-0001-0000-000000000003',
    '55555555-dead-0001-0000-000000000001',
    'المعلم الثالث: التوسع التشغيلي ليشمل أبوظبي والشارقة',
    'افتتاح أول مركز توزيع في أبوظبي وربط المتاجر الإلكترونية في العاصمة.',
    40000.00, 3, 'pending', NULL
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 10: Platform Moderation & Audit Reports (for Super Admin)
-- ============================================================================

INSERT INTO public.reports (
  id, reporter_id, reported_entity_type, reported_entity_id, reason, details, status
) VALUES (
  '44444444-ffff-0001-0000-000000000001',
  '44444444-4444-4444-4444-444444444444',
  'offer',
  'bbbbbbbb-0002-2222-2222-222222222222',
  'طلب تدقيق إضافي على شروط التسليم والضمان',
  'يرجى من الإدارة التأكد من توافق العقد مع الشروط القياسية لتسليم الشيفرات المصدرية لضمان حق المستثمر.',
  'pending'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.audit_logs (actor_id, action, entity_type, entity_id, new_data)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'SYSTEM_SEED',
    'ecosystem',
    '11111111-1111-1111-1111-111111111111',
    '{"status":"System seeded with 5 dedicated role accounts, UAE market opportunities, and active escrow deal"}'::jsonb
  );
