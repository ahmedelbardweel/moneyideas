# نظام التصميم | Money Ideas Design System (Material 3)

تم بناء نظام التصميم للتطبيق بالاعتماد على معايير **Material 3 (M3)** الرسمية من Google، مع التركيز على البساطة، التناسق، ودعم اللغتين العربية والإنجليزية (RTL/LTR) بشكل كامل ومثالي.

---

## 1. الألوان (Color Tokens)

- **اللون الأساسي للعلامة التجارية (Seed Color):** `#0B6E4F` (أخضر زمردي يعبر عن المال والاستقرار والثقة).
- جميع الأدوار اللونية مشتقة بالكامل وفق خوارزمية M3 Tonal Palette ومثبتة في الكود في ملف:
  [`lib/core/design_system/tokens/app_color_schemes.dart`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/lib/core/design_system/tokens/app_color_schemes.dart)

### جدول مقارنة الأدوار اللونية (Light vs Dark)

| الدور اللوني (Role) | الفاتح (Light Mode) | الداكن (Dark Mode) | الاستخدام الأساسي |
| :--- | :--- | :--- | :--- |
| **primary** | `#1E6A4F` | `#8CD5B3` | الأزرار الرئيسية، المؤشرات النشطة، العلامات البارزة |
| **onPrimary** | `#FFFFFF` | `#003826` | النصوص والأيقونات فوق اللون الأساسي |
| **primaryContainer** | `#A8F2CF` | `#005139` | أزرار FAB، الحاويات المظللة، البطاقات المميزة |
| **onPrimaryContainer** | `#005139` | `#A8F2CF` | العناصر فوق primaryContainer |
| **secondary** | `#4D6358` | `#B3CCBE` | العناصر التكميلية الأقل أهمية |
| **secondaryContainer** | `#CFE9D9` | `#354B40` | مؤشر التبويب السفلي المختار، الشرائح (Chips) المختارة |
| **onSecondaryContainer** | `#354B40` | `#CFE9D9` | أيقونات ونصوص التبويب النشط والشرائح |
| **surface** | `#F5FBF5` | `#0F1512` | خلفية الشاشات والقوائم الرئيسية |
| **onSurface** | `#171D1A` | `#DEE4DE` | النصوص الأساسية والعناوين |
| **surfaceContainerLowest** | `#FFFFFF` | `#0A0F0C` | الأسطح الأكثر بروزاً أو انفصالاً |
| **surfaceContainerLow** | `#EFF5EF` | `#171D1A` | البطاقات العادية (Cards) والـ Bottom Sheets |
| **surfaceContainer** | `#EAEFEA` | `#1B211E` | شريط التنقل السفلي (NavigationBar) |
| **surfaceContainerHigh** | `#E4EAE4` | `#252B28` | شريط البحث (SearchBar) ومربعات الحوار (Dialogs) |
| **surfaceContainerHighest** | `#DEE4DE` | `#303632` | خلفيات حقول الإدخال (Text Fields Fill) |
| **onSurfaceVariant** | `#404944` | `#BFC9C2` | النصوص الفرعية، الأيقونات الثانوية، علامات التلميح |
| **outline** | `#707973` | `#8A938D` | الحدود الخارجية، الأزرار المفرغة |
| **outlineVariant** | `#BFC9C2` | `#404944` | الفواصل الرفيعة (Dividers)، حدود الشرائح غير المختارة |
| **error** | `#BA1A1A` | `#FFB4AB` | الأخطاء، البلاغات، الحذف، التنبيهات الحرجة |

### الألوان الدلالية المخصصة (AppColors Extension)
تمت إضافتها كـ `ThemeExtension` لدعم جودة البيانات والإعلانات:
- **Success (موثق / مكتمل):**
  - Light: `#3C6939` (Container: `#BCF0B4`)
  - Dark: `#A1D39A` (Container: `#245024`)
- **Warning (تقديري / يحتاج تحديث):**
  - Light: `#855317` (Container: `#FFDCBD`)
  - Dark: `#FCB974` (Container: `#693C00`)
- **Info (تعليمي / معلومات إضافية):**
  - Light: `#495D92` (Container: `#DAE2FF`)
  - Dark: `#B2C5FF` (Container: `#304578`)
- **Sponsored (إعلان تجاري ممول):**
  - Light: `#815512` (Container: `#FFDDB7`)
  - Dark: `#F7BB70` (Container: `#653E00`)

---

## 2. مقياس زوايا الانحناء (Corner Radius Tokens)

موجودة في: [`lib/core/design_system/tokens/app_radius.dart`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/lib/core/design_system/tokens/app_radius.dart)

| التوكن (Token) | القيمة (dp) | الاستخدام الشائع |
| :--- | :--- | :--- |
| **none** | `0` | الصور التي تغطي الشاشة، الأشرطة الملتصقة |
| **extraSmall** | `4` | أشرطة التنبيه (Snackbars)، التلميحات (Tooltips)، مؤشرات التقدم |
| **small** | `8` | الشرائح (Chips)، الشارات الصغيرة (Badges) |
| **medium** | `12` | البطاقات (Cards)، حقول الإدخال (Inputs)، القوائم المنسدلة |
| **large** | `16` | الأزرار العائمة (FAB)، القوائم الجانبية (Navigation Drawer) |
| **largeIncreased** | `20` | البطاقات البارزة والبطاقات الترحيبية (Hero Cards) |
| **extraLarge** | `28` | مربعات الحوار (Dialogs)، شريط البحث، القوائم المنبثقة من الأسفل (Sheets) |
| **extraLargeIncreased** | `32` | الحاويات الكبيرة |
| **extraExtraLarge** | `48` | الأسطح التعبيرية واللوحات الفنية |
| **full** | `999` (دائري كلياً) | الأزرار (Buttons)، الكبسولات (Pill Indicators)، الصور الرمزية (Avatars) |

---

## 3. مقياس المسافات والشبكة (Spacing & 4dp Grid)

موجودة في: [`lib/core/design_system/tokens/app_spacing.dart`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/lib/core/design_system/tokens/app_spacing.dart)

- **شبكة مضاعفات 4dp:**
  - `xxs`: 2dp
  - `xs`: 4dp
  - `sm`: 8dp
  - `md`: 12dp
  - `lg`: 16dp *(الهامش الأفقي الافتراضي للشاشات M3 Guideline)*
  - `xl`: 24dp
  - `xxl`: 32dp
  - `xxxl`: 48dp
  - `huge`: 64dp
- **ويدجت Gap الجاهزة:** للاستخدام المباشر داخل Row و Column بدلاً من تكرار SizedBox (`Gap.xs()`, `Gap.sm()`, `Gap.md()`, `Gap.lg()`, `Gap.xl()`, `Gap.xxl()`).

---

## 4. الخطوط والطباعة (Typography)

موجودة في: [`lib/core/design_system/tokens/app_typography.dart`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/lib/core/design_system/tokens/app_typography.dart)

- **الخط اللاتيني/الإنجليزي:** **Google Sans** من عائلة جوجل الرسمية.
- **الخط العربي:** **Noto Sans Arabic** من جوجل، مع إلغاء تباعد الأحرف (`letterSpacing = 0`) لمنع تقطيع الحروف العربية المتصلة.
- تطبيق المقياس الكامل لـ M3 (15 نمطاً):
  - `displayLarge`, `displayMedium`, `displaySmall`
  - `headlineLarge`, `headlineMedium`, `headlineSmall`
  - `titleLarge`, `titleMedium`, `titleSmall`
  - `bodyLarge`, `bodyMedium`, `bodySmall`
  - `labelLarge`, `labelMedium`, `labelSmall`

---

## 5. الأيقونات (Icons)

موجودة في: [`lib/core/design_system/tokens/app_icons.dart`](file:///c:/Users/Ahmed/AndroidStudioProjects/moneyideas/lib/core/design_system/tokens/app_icons.dart)

- الاعتماد على **Google Material Symbols (Rounded)** بأسماء دلالية موحدة لكل استخدام داخل التطبيق:
  - التبويبات: `home`, `discover`, `assistant`, `network`, `account`
  - الإجراءات: `search`, `filter`, `compare`, `save`, `share`...
  - الثقة والمصادر: `verified`, `sponsored`, `estimated`, `needsUpdate`, `expired`...

---

## 6. مكونات الواجهة المعيارية (Component Themes)

- **الأزرار (Buttons):** جميع الأزرار كبسولية كاملة الانحناء (`StadiumBorder` / `AppRadius.full`) بارتفاع معياري 40dp (أو 56dp للأزرار العريضة الأساسية)، مع منطقة لمس لا تقل عن 48dp.
- **حقول الإدخال (Inputs):** أسلوب M3 Filled مع حواف ناعمة 12dp وخلفية `surfaceContainerHighest` وحدود ملونة عند التركيز أو الخطأ، مع دعم حتى 3 أسطر لرسائل التحقق.
- **البطاقات (Cards):** سطح منخفض `surfaceContainerLow` بدون ظلال صناعية ثقيلة (الاعتماد على تناغم الأسطح Tonal Surfaces).
- **التنقل السفلي (NavigationBar):** شريط M3 حديث بارتفاع 80dp مع مؤشر كبسولي للتبويب النشط وأيقونات معبأة عند التحديد ومفرغة عند عدم التحديد.
