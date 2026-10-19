// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أفكار المال';

  @override
  String get appTagline => 'منصة أعمال واستثمار ذكية متكاملة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navDiscover => 'اكتشف';

  @override
  String get navAssistant => 'المساعد';

  @override
  String get navNetwork => 'الشبكة';

  @override
  String get navAccount => 'حسابي';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDone => 'تم';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonFilter => 'تصفية';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonStartNow => 'ابدأ الآن';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String errorMinLength(int min) {
    return 'يجب ألا يقل عن $min أحرف';
  }

  @override
  String errorMaxLength(int max) {
    return 'يجب ألا يتجاوز $max حرفاً';
  }

  @override
  String get errorInvalidName => 'الاسم يجب أن يحتوي على أحرف ومسافات فقط';

  @override
  String get errorInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get errorWeakPassword =>
      'كلمة المرور يجب ألا تقل عن 8 خانات وتحتوي على حرف كبير وصغير ورقم';

  @override
  String get errorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String errorInvalidOtp(int length) {
    return 'رمز التحقق يجب أن يتكون من $length أرقام';
  }

  @override
  String get errorInvalidNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get errorOutOfRange => 'القيمة المدخلة خارج النطاق المسموح';

  @override
  String errorTooManyDecimals(int max) {
    return 'الحد الأقصى للمنازل العشرية هو $max';
  }

  @override
  String get errorInvalidUrl => 'يرجى إدخال رابط إنترنت صحيح';

  @override
  String get errorInsecureUrl => 'الرابط يجب أن يبدأ بـ https لحماية أمانك';

  @override
  String get errorInvalidPhone => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get errorInvalidLicense => 'رقم الرخصة التجارية غير صحيح';

  @override
  String get errorForbiddenClaim =>
      'لا يُسمح باستخدام ادعاءات أرباح مضمونة أو خالية من المخاطر';

  @override
  String get errorMustAccept => 'يجب الموافقة على الشروط والأحكام للمتابعة';

  @override
  String get errorSelectionRequired => 'يرجى تحديد اختيار واحد على الأقل';

  @override
  String get errorFileTooLarge => 'حجم الملف يتجاوز الحد المسموح (10 ميجابايت)';

  @override
  String get errorFileTypeNotAllowed => 'صيغة الملف غير مدعومة';

  @override
  String get networkErrorTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get networkErrorMessage =>
      'تعذر الاتصال بالخادم. يمكنك تصفح البيانات المحفوظة محلياً أو إعادة المحاولة.';

  @override
  String get serverErrorTitle => 'حدث خطأ غير متوقع';

  @override
  String get serverErrorMessage =>
      'واجهنا مشكلة أثناء معالجة طلبك، يرجى المحاولة لاحقاً.';

  @override
  String get emptyStateTitle => 'لا توجد نتائج مطابقة';

  @override
  String get emptyStateMessage =>
      'جرب تعديل معايير البحث أو الفلاتر لعرض مزيد من الخيارات.';

  @override
  String get unauthorizedTitle => 'وصول غير مصرح به';

  @override
  String get unauthorizedMessage =>
      'تحتاج لتسجيل الدخول أو امتلاك الصلاحيات المناسبة لعرض هذا المحتوى.';

  @override
  String get dataNeedsUpdate => 'تحتاج المعلومات إلى تحديث';

  @override
  String get dataVerified => 'بيانات موثقة ومتحقق منها';

  @override
  String get dataEstimated => 'أرقام تقديرية قابلة للتغيير';

  @override
  String get sponsoredAd => 'إعلان مروج';

  @override
  String get languageTitle => 'اختر لغة التطبيق';

  @override
  String get languageSubtitle =>
      'يمكنك تغيير لغة التطبيق في أي وقت من الإعدادات';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get english => 'English (الإنجليزية)';

  @override
  String get onboardingSlide1Title => 'مستشارك الذكي للأعمال';

  @override
  String get onboardingSlide1Desc =>
      'يحلل إمكاناتك وميزانيتك وخبرتك لاقتراح خيارات مبنية على بيانات موثقة دون ادعاءات غير حقيقية.';

  @override
  String get onboardingSlide2Title => 'سوق متكامل للفرص التجارية';

  @override
  String get onboardingSlide2Desc =>
      'استكشف أفكار المشاريع، تفاصيل التكاليف، المخاطر، وعروض الشركات في مكان واحد مع المقارنة.';

  @override
  String get onboardingSlide3Title => 'شبكة الشراكات والاستثمار';

  @override
  String get onboardingSlide3Desc =>
      'تواصل مع رواد الأعمال والمستثمرين والشركات المعتمدة لبناء وتطوير مشاريعك بنجاح.';

  @override
  String get welcomeTitle => 'مرحباً بك في أفكار المال';

  @override
  String get welcomeSubtitle =>
      'بوابتك الذكية لتحويل طموحاتك وميزانيتك إلى مشاريع واستثمارات مدروسة وموثقة.';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authRegister => 'إنشاء حساب جديد';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authGuest => 'الاستكشاف كزائر';

  @override
  String get authVerifyEmailTitle => 'التحقق من البريد الإلكتروني';

  @override
  String authVerifyEmailDesc(String email) {
    return 'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى $email';
  }

  @override
  String get authResendOtp => 'إعادة إرسال الرمز';

  @override
  String authResendInSeconds(int seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get authAgreeTerms => 'أوافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get authResetPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get authResetPasswordDesc =>
      'أدخل بريدك الإلكتروني المسجل وسنرسل لك تعليمات الاستعادة.';

  @override
  String get authSendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get authResetSuccess =>
      'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح.';

  @override
  String get authRememberMe => 'تذكر تسجيل الدخول';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get setupTitle => 'تخصيص تجربتك';

  @override
  String get setupStepRole => 'نوع الحساب';

  @override
  String get setupStepRoleDesc =>
      'حدد صفاتك في المنصة (يمكنك اختيار أكثر من دور):';

  @override
  String get roleIndividual => 'فرد / باحث عن فرصة';

  @override
  String get roleIndividualDesc =>
      'أريد استثمار مالي أو اكتشاف فكرة مشروع مناسبة لإمكاناتي.';

  @override
  String get roleInvestor => 'مستثمر';

  @override
  String get roleInvestorDesc =>
      'أبحث عن مشاريع قائمة أو أفكار واعدة لتمويلها كشريك مالي.';

  @override
  String get roleProjectOwner => 'صاحب فكرة أو مشروع';

  @override
  String get roleProjectOwnerDesc =>
      'أريد تطوير مشروعي أو البحث عن شريك تنفيذي أو مستثمر.';

  @override
  String get roleCompany => 'شركة أو مزود خدمات';

  @override
  String get roleCompanyDesc =>
      'أريد تقديم عروض وخدمات رسمية لرواد الأعمال والمستثمرين.';

  @override
  String get setupStepGoal => 'ما هو هدفك الأساسي؟';

  @override
  String get setupStepGoalDesc => 'اختر الأهداف التي تود تحقيقها عبر التطبيق:';

  @override
  String get goalInvest => 'أريد استثمار مبلغ مالي متاح';

  @override
  String get goalDiscover => 'لا أملك فكرة وأريد اكتشاف فرصة تناسبني';

  @override
  String get goalDevelop => 'تطوير مشروعي القائم وزيادة أرباحه';

  @override
  String get goalPartner => 'إيجاد شريك أو مستثمر لمشروعي';

  @override
  String get goalService => 'البحث عن خدمات تجارية واستشارات تأسيس';

  @override
  String get setupStepLocation => 'الموقع والأسواق';

  @override
  String get setupStepLocationDesc =>
      'حدد السوق المستهدف للبحث عن فرص ملائمة محلياً:';

  @override
  String get setupCountry => 'الدولة';

  @override
  String get setupCity => 'المدينة';

  @override
  String get setupCurrency => 'العملة المفضلة';

  @override
  String get setupStepBudget => 'الميزانية ورأس المال';

  @override
  String get setupStepBudgetDesc =>
      'حدد قدرتك المالية التقريبية لفرز الفرص المناسبة:';

  @override
  String get setupBudgetAmount => 'رأس المال المتاح للبدء';

  @override
  String get setupNoCapital =>
      'لا أملك رأس مال حالياً (أعتمد على مهارتي ووقتي)';

  @override
  String get setupBudgetCeiling => 'سقف الإنفاق الأقصى (اختياري)';

  @override
  String get setupStepExperience => 'الخبرة والوقت المتاح';

  @override
  String get setupStepExperienceDesc =>
      'يساعدنا ذلك على اختيار مشاريع لا تتطلب جهداً يتجاوز إمكاناتك:';

  @override
  String get setupExperienceLevel => 'مستوى خبرتك السابقة في إدارة المشاريع';

  @override
  String get expBeginner => 'مبتدئ (أول تجربة لي)';

  @override
  String get expIntermediate => 'متوسط (لدي اطلاع أو تجارب سابقة)';

  @override
  String get expAdvanced => 'متقدم (أدرت وأطلقت مشاريع تجارية)';

  @override
  String get setupWeeklyHours => 'ساعات العمل المتاحة لك أسبوعياً';

  @override
  String get setupManagementPref => 'طبيعة الإدارة المفضلة';

  @override
  String get managementActive => 'أريد تشغيل وإدارة المشروع بنفسي';

  @override
  String get managementPassive => 'أفضل استثماراً ماليًا لا يتطلب إدارة يومية';

  @override
  String get setupStepRisk => 'المخاطر والسيولة';

  @override
  String get setupStepRiskDesc =>
      'الموازنة بين العائد المحتمل ودرجة الأمان المالي:';

  @override
  String get setupRiskTolerance => 'درجة تحملك للمخاطر';

  @override
  String get riskLow => 'منخفضة (الحفاظ على رأس المال أهم أولوياتي)';

  @override
  String get riskMedium => 'متوسطة (أتحمل تقلبات معتدلة مقابل عائد أفضل)';

  @override
  String get riskHigh => 'مرتفعة (مستعد للمخاطرة العالية سعياً لنمو سريع)';

  @override
  String get setupLiquidity => 'المدى الزمني لاسترداد أو سحب السيولة';

  @override
  String get liquidityShort => 'قصير الأجل (أقل من سنة واحدة)';

  @override
  String get liquidityMedium => 'متوسط الأجل (من سنة إلى 3 سنوات)';

  @override
  String get liquidityLong => 'طويل الأجل (أكثر من 3 سنوات)';

  @override
  String get setupRiskHelp =>
      'المخاطرة تعني احتمال تذبذب أو فقد جزء من المال، والسيولة تعني سرعة تحويل الاستثمار إلى كاش.';

  @override
  String get setupStepReview => 'ملخص تفضيلاتك';

  @override
  String get setupStepReviewDesc =>
      'راجع إجاباتك قبل الانتقال لاستكشاف الفرص المطابقة:';

  @override
  String get setupCompletionScore => 'اكتمال الملف التحليلي';

  @override
  String get setupShowOptions => 'اعرض الخيارات والفرص المناسبة';
}
