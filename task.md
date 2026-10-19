# Money Ideas — Task Tracker

## S0 الأساس ✅ (مكتمل بنسبة 100%)
- [x] Dependencies + lints (very_good_analysis strict mode, 0 issues)
- [x] Env config (env.dart, dev.json template, .gitignore)
- [x] Design system (colors, radius, spacing, typography, elevation, motion, sizes, icons, component themes, theme context)
- [x] docs/DESIGN_SYSTEM.md (دليل تصميم M3 كامل وشامل)
- [x] Fonts & Google fonts (Google Sans & Noto Sans Arabic)
- [x] Localization (ar/en ARB files + code generation)
- [x] Result / Failure / error mapper
- [x] Validators + comprehensive unit tests (14/14 tests passing)
- [x] Shared widgets + state widgets (AppButton, AppTextField, Loading, Empty, Error, Offline, Unauthorized, DataQualityBadge)
- [x] Router skeleton + 5-tab Shell with M3 NavigationBar
- [x] Bootstrap + main entry point

## S1 قاعدة البيانات Supabase ✅ (مكتمل بنسبة 100%)
- [x] Migrations 00001 (Profiles, Multi-role, Goals, Preferences, Privacy, Audit logs, Auth triggers)
- [x] Migrations 00002 (Hierarchical Categories, Data sources, Opportunities, Costs, Risks, Steps, Saved, Tasks)
- [x] Migrations 00003 (Companies, Verification docs, Member delegations, Commercial offers lifecycle, Leads, Ad campaigns)
- [x] Migrations 00004 (Investors, Startups, Projects, Mutual contact requests gate, Realtime chat & messages, Reports)
- [x] Migrations 00005 (Explainable Matching Engine Postgres RPC, Complete RLS policies on all 20+ tables)
- [x] seed.sql (بيانات أولية واقعية وموثقة لسوق الإمارات)
- [x] supabase/README.md (دليل التطبيق والتشغيل)

## S2 التدفق الكامل للبداية والحساب والملف التحليلي (01–15) ✅ (مكتمل بنسبة 100%)
- [x] 01 شاشة التحميل والشعار (SplashScreen)
- [x] 02 شاشة اختيار اللغة الفوري (LanguageScreen - AR/EN مع قلب RTL/LTR لحظي)
- [x] 03 شرائح التعريف التفاعلية (OnboardingScreen مع 3 شرائح تفاعلية)
- [x] 04 شاشة الترحيب ونقاط الدخول (WelcomeScreen)
- [x] 05 إنشاء حساب جديد (RegisterScreen مع التحقق اللحظي)
- [x] 06 التحقق من البريد الإلكتروني OTP المؤقت (VerifyEmailScreen)
- [x] 07 تسجيل الدخول (LoginScreen)
- [x] 08 استعادة كلمة المرور (ResetPasswordScreen)
- [x] 09 اختيار الأدوار المتعددة (StepRolesWidget)
- [x] 10 تحديد الأهداف الاستثمارية (StepGoalsWidget)
- [x] 11 الدولة والسوق والعملة (StepLocationWidget)
- [x] 12 الميزانية ورأس المال مع خيار الصفر رأس مال (StepBudgetWidget)
- [x] 13 الخبرة والوقت وطبيعة الإدارة (StepExperienceWidget)
- [x] 14 درجة المخاطرة وأفق السيولة مع الدليل التعليمي (StepRiskWidget)
- [x] 15 ملخص الملف التحليلي ونسبة الاكتمال (StepReviewWidget)
- [x] حاوية المعالج الشاملة (ProfileSetupStepperScreen) وتكامل المسارات بالكامل في GoRouter
- [x] خلو كامل من المشاكل (Zero linter issues عبر very_good_analysis + 100% اختبارات ناجحة)

## S3 الرئيسية وسوق اكتشاف الفرص والمقارنة (16–31) ✅ (مكتمل بنسبة 100%)
- [x] 16 لوحة التحكم والرئيسية (HomeScreen مع شريط صحة الملف التحليلي والاختصارات والفرص المطابقة)
- [x] 17 سوق استكشاف الفرص (DiscoverScreen مع التصنيفات وقائمة البطاقات والشريط العائم للمقارنة)
- [x] 18 البحث المتقدم واللحظي (SearchScreen مع الكلمات الشائعة والاقتراحات التفاعلية)
- [x] 19 نافذة الفلاتر المتطورة (OpportunityFilterSheet مع نطاق رأس المال والمخاطرة والتوثيق)
- [x] 20 تفاصيل الفرصة - النظرة العامة (OverviewTab مع قسم "لماذا تناسبك؟" وجدول المواصفات)
- [x] 21 تفاصيل الفرصة - التكاليف ورأس المال (CostsTab مع التمييز بين الموثق والتقديري والإجمالي)
- [x] 22 تفاصيل الفرصة - مصفوفة المخاطر وأسئلة التحقق الحرجة (RisksTab مع خطط التفادي والأسئلة الحاسمة)
- [x] 23 تفاصيل الفرصة - المصادر الموثقة والمراجع الحكومية (SourcesTab مع تواريخ التوثيق والروابط)
- [x] 24 تفاصيل الفرصة - خريطة الطريق والخطوات التنفيذية (RoadmapTab مع التكلفة والمدة والترقيم)
- [x] 25 تفاصيل الفرصة - العروض والخدمات المرتبطة ودمج التبويبات (OpportunityDetailsScreen الكاملة)
- [x] 26 مصفوفة مقارنة الفرص جنبًا إلى جنب (CompareScreen مع جدول مقارنة تفاعلي حتى 3 فرص)
- [x] 27 الفرص المحفوظة والمفضلة (SavedScreen مع الحفظ والإلغاء اللحظي)
- [x] 28 خطة العمل والمهام الشخصية (NextStepsScreen مع نسبة الإنجاز وإضافة خطوات جديدة)
- [x] 29 مركز الإشعارات والتنبيهات (NotificationsScreen مع حالة القراءة والتصنيفات)
- [x] 30 شاشات عدم وجود نتائج وتوسيع الفلاتر (EmptyState المتكاملة مع زر إعادة الضبط)
- [x] 31 دعم التصفح في وضع عدم الاتصال (Offline State مع البيانات المحلية الموثقة لسوق الإمارات)
- [x] تطهير كامل من أي بيانات وهمية أو تجريبية (Zero Mock Data) والاعتماد التام على Supabase
- [x] ربط المشروع بقاعدة بيانات Supabase الحية عبر `env/dev.json`
- [x] تشغيل التطبيق بنجاح على Google Chrome وتوصيل خادم التطوير اللحظي
- [x] Zero Linter issues عبر very_good_analysis + اختبارات شاملة ناجحة 100%

## المراحل القادمة (S4 – S11)
- [x] S4 المساعد الذكي وحوار الأسئلة والمطابقة التفسيرية (32–39) ✅ (مكتمل)
- [x] S5 حساب المستخدم وإدارة الأدوار والإعدادات (70–78) ✅ (مكتمل)
- [x] S6 لوحة الشركات وإدارة العروض التجارية (40–52) ✅ (مكتمل)
- [x] S7 شبكة الأعمال والمستثمرون والمشاريع (53–64) ✅ (مكتمل)
- [x] S8 المحادثات اللحظية ومشاركة الملفات (65–69) ✅ (مكتمل)
- [x] S9 الصفقات والتمويل وحساب الضمان المالي المعتمد (79–82) ✅ (مكتمل)
- [x] S10 لوحة إدارة المنصة والتحكم الشامل Super Admin (83–94) ✅ (مكتمل)
- [ ] S11 الصقل النهائي والتأكيد على المزامنة الحية والاختبارات الشاملة
