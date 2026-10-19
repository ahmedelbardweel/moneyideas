# إرشادات تشغيل قاعدة بيانات Supabase | Money Ideas

تم إعداد هيكلة قاعدة البيانات في 5 ملفات Migration منظمة حسب الأنظمة + ملف البيانات الأولية `seed.sql`.

---

## ملفات التهيئة (Migrations)

| الملف | المحتوى |
| :--- | :--- |
| [`00001_initial_schema.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/migrations/00001_initial_schema.sql) | الجداول الأساسية: الحسابات (`profiles`)، الأدوار المتعددة (`user_roles`)، الأهداف (`user_goals`)، التفضيلات التحليلية (`user_preferences`)، الخصوصية والإشعارات، سجل التدقيق (`audit_logs`)، وتريجر الإنشاء التلقائي للمستخدم. |
| [`00002_categories_and_opportunities.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/migrations/00002_categories_and_opportunities.sql) | المجالات الشجرية (`categories`)، المصادر الرسمية (`data_sources`)، الفرص والأفكار (`opportunities`)، التكاليف الموثقة والتقديرية (`opportunity_costs`)، المخاطر وأسئلة التحقق (`opportunity_risks`)، خطوات البدء (`opportunity_steps`)، المحفوظات والملاحظات، وخطة خطواتي التالية (`next_step_tasks`). |
| [`00003_companies_and_offers.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/migrations/00003_companies_and_offers.sql) | حسابات الشركات وتوثيق التراخيص (`companies`)، مستندات التوثيق، صلاحيات أعضاء الفريق، دورة حياة العروض التجارية (`company_offers`)، العملاء المهتمون (`offer_leads`)، والحملات الإعلانية المفصولة عن المطابقة الموضوعية (`ad_campaigns`). |
| [`00004_network_and_chat.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/migrations/00004_network_and_chat.sql) | دليل المستثمرين وقائمة الملاحظات السرية (`investor_watchlist`)، دليل المشاريع ورواد الأعمال مع الفصل الدقيق بين (فكرة / مشروع قائم / طلب استثمار)، بوابة طلبات التواصل المتبادل (`contact_requests`)، المحادثات اللحظية (`messages`)، الحظر، والبلاغات (`reports`). |
| [`00005_matching_engine_and_security.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/migrations/00005_matching_engine_and_security.sql) | دالة المحرك الخادمية `match_opportunities` (قائمة على القواعد وتفسير المعايير دون نسب مئوية وهمية) + سياسات الأمان التامة وحماية الصفوف (Row Level Security - RLS) على جميع الجداول. |
| [`seed.sql`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/supabase/seed.sql) | بيانات أولية واقعية وموثقة لسوق الإمارات: المجالات الرئيسية والفرعية، المصادر الرسمية (اقتصادية دبي، TDRA، DLD)، ونماذج أفكار وفرص عملية مع تفاصيل تكاليفها ومخاطرها وخطوات تنفيذها. |

---

## طريقة التطبيق على مشروعك في Supabase

### الطريقة الأولى: من لوحة تحكم Supabase (SQL Editor) — الأسهل
1. افتح مشروعك في [Supabase Dashboard](https://supabase.com/dashboard).
2. ادخل إلى قسم **SQL Editor** من القائمة الجانبية.
3. انسخ محتويات كل ملف بالترتيب من `00001` إلى `00005` ثم اضغط **Run**.
4. انسخ محتوى `seed.sql` واضغط **Run** لتعبئة البيانات الأولية.

### الطريقة الثانية: عبر Supabase CLI (إن كان مثبتاً لديك)
```bash
supabase db push
# أو
supabase db reset
```

---

## ربط التطبيق بالمشروع

أنشئ ملف `env/dev.json` (وهو مستبعد تلقائياً من Git لحماية مفاتيحك) وضع فيه القيم التالية:
```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_KEY",
  "APP_ENV": "dev",
  "AUTH_REDIRECT_URL": "io.moneyideas.app://login-callback"
}
```

وشغّل التطبيق بالأمر:
```bash
flutter run --dart-define-from-file=env/dev.json
```
