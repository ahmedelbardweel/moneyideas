import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'أفكار المال'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'منصة أعمال واستثمار ذكية متكاملة'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف'**
  String get navDiscover;

  /// No description provided for @navAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد'**
  String get navAssistant;

  /// No description provided for @navNetwork.
  ///
  /// In ar, this message translates to:
  /// **'الشبكة'**
  String get navNetwork;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @commonContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get commonContinue;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

  /// No description provided for @commonEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get commonFilter;

  /// No description provided for @commonClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get commonClear;

  /// No description provided for @commonSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get commonSeeAll;

  /// No description provided for @commonSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get commonSkip;

  /// No description provided for @commonStartNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get commonStartNow;

  /// No description provided for @errorRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get errorRequired;

  /// No description provided for @errorMinLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يقل عن {min} أحرف'**
  String errorMinLength(int min);

  /// No description provided for @errorMaxLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يتجاوز {max} حرفاً'**
  String errorMaxLength(int max);

  /// No description provided for @errorInvalidName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم يجب أن يحتوي على أحرف ومسافات فقط'**
  String get errorInvalidName;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get errorInvalidEmail;

  /// No description provided for @errorWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب ألا تقل عن 8 خانات وتحتوي على حرف كبير وصغير ورقم'**
  String get errorWeakPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get errorPasswordMismatch;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق يجب أن يتكون من {length} أرقام'**
  String errorInvalidOtp(int length);

  /// No description provided for @errorInvalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم صحيح'**
  String get errorInvalidNumber;

  /// No description provided for @errorOutOfRange.
  ///
  /// In ar, this message translates to:
  /// **'القيمة المدخلة خارج النطاق المسموح'**
  String get errorOutOfRange;

  /// No description provided for @errorTooManyDecimals.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للمنازل العشرية هو {max}'**
  String errorTooManyDecimals(int max);

  /// No description provided for @errorInvalidUrl.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رابط إنترنت صحيح'**
  String get errorInvalidUrl;

  /// No description provided for @errorInsecureUrl.
  ///
  /// In ar, this message translates to:
  /// **'الرابط يجب أن يبدأ بـ https لحماية أمانك'**
  String get errorInsecureUrl;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح'**
  String get errorInvalidPhone;

  /// No description provided for @errorInvalidLicense.
  ///
  /// In ar, this message translates to:
  /// **'رقم الرخصة التجارية غير صحيح'**
  String get errorInvalidLicense;

  /// No description provided for @errorForbiddenClaim.
  ///
  /// In ar, this message translates to:
  /// **'لا يُسمح باستخدام ادعاءات أرباح مضمونة أو خالية من المخاطر'**
  String get errorForbiddenClaim;

  /// No description provided for @errorMustAccept.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على الشروط والأحكام للمتابعة'**
  String get errorMustAccept;

  /// No description provided for @errorSelectionRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد اختيار واحد على الأقل'**
  String get errorSelectionRequired;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم الملف يتجاوز الحد المسموح (10 ميجابايت)'**
  String get errorFileTooLarge;

  /// No description provided for @errorFileTypeNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'صيغة الملف غير مدعومة'**
  String get errorFileTypeNotAllowed;

  /// No description provided for @networkErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالخادم. يمكنك تصفح البيانات المحفوظة محلياً أو إعادة المحاولة.'**
  String get networkErrorMessage;

  /// No description provided for @serverErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get serverErrorTitle;

  /// No description provided for @serverErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'واجهنا مشكلة أثناء معالجة طلبك، يرجى المحاولة لاحقاً.'**
  String get serverErrorMessage;

  /// No description provided for @emptyStateTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرب تعديل معايير البحث أو الفلاتر لعرض مزيد من الخيارات.'**
  String get emptyStateMessage;

  /// No description provided for @unauthorizedTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصول غير مصرح به'**
  String get unauthorizedTitle;

  /// No description provided for @unauthorizedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج لتسجيل الدخول أو امتلاك الصلاحيات المناسبة لعرض هذا المحتوى.'**
  String get unauthorizedMessage;

  /// No description provided for @dataNeedsUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج المعلومات إلى تحديث'**
  String get dataNeedsUpdate;

  /// No description provided for @dataVerified.
  ///
  /// In ar, this message translates to:
  /// **'بيانات موثقة ومتحقق منها'**
  String get dataVerified;

  /// No description provided for @dataEstimated.
  ///
  /// In ar, this message translates to:
  /// **'أرقام تقديرية قابلة للتغيير'**
  String get dataEstimated;

  /// No description provided for @sponsoredAd.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مروج'**
  String get sponsoredAd;

  /// No description provided for @languageTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغيير لغة التطبيق في أي وقت من الإعدادات'**
  String get languageSubtitle;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية (Arabic)'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English (الإنجليزية)'**
  String get english;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In ar, this message translates to:
  /// **'مستشارك الذكي للأعمال'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In ar, this message translates to:
  /// **'يحلل إمكاناتك وميزانيتك وخبرتك لاقتراح خيارات مبنية على بيانات موثقة دون ادعاءات غير حقيقية.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In ar, this message translates to:
  /// **'سوق متكامل للفرص التجارية'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In ar, this message translates to:
  /// **'استكشف أفكار المشاريع، تفاصيل التكاليف، المخاطر، وعروض الشركات في مكان واحد مع المقارنة.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In ar, this message translates to:
  /// **'شبكة الشراكات والاستثمار'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع رواد الأعمال والمستثمرين والشركات المعتمدة لبناء وتطوير مشاريعك بنجاح.'**
  String get onboardingSlide3Desc;

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في أفكار المال'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بوابتك الذكية لتحويل طموحاتك وميزانيتك إلى مشاريع واستثمارات مدروسة وموثقة.'**
  String get welcomeSubtitle;

  /// No description provided for @authLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get authFullName;

  /// No description provided for @authGuest.
  ///
  /// In ar, this message translates to:
  /// **'الاستكشاف كزائر'**
  String get authGuest;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من البريد الإلكتروني'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى {email}'**
  String authVerifyEmailDesc(String email);

  /// No description provided for @authResendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get authResendOtp;

  /// No description provided for @authResendInSeconds.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ثانية'**
  String authResendInSeconds(int seconds);

  /// No description provided for @authAgreeTerms.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط الاستخدام وسياسة الخصوصية'**
  String get authAgreeTerms;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني المسجل وسنرسل لك تعليمات الاستعادة.'**
  String get authResetPasswordDesc;

  /// No description provided for @authSendResetLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الاستعادة'**
  String get authSendResetLink;

  /// No description provided for @authResetSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح.'**
  String get authResetSuccess;

  /// No description provided for @authRememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكر تسجيل الدخول'**
  String get authRememberMe;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authDontHaveAccount;

  /// No description provided for @setupTitle.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص تجربتك'**
  String get setupTitle;

  /// No description provided for @setupStepRole.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحساب'**
  String get setupStepRole;

  /// No description provided for @setupStepRoleDesc.
  ///
  /// In ar, this message translates to:
  /// **'حدد صفاتك في المنصة (يمكنك اختيار أكثر من دور):'**
  String get setupStepRoleDesc;

  /// No description provided for @roleIndividual.
  ///
  /// In ar, this message translates to:
  /// **'فرد / باحث عن فرصة'**
  String get roleIndividual;

  /// No description provided for @roleIndividualDesc.
  ///
  /// In ar, this message translates to:
  /// **'أريد استثمار مالي أو اكتشاف فكرة مشروع مناسبة لإمكاناتي.'**
  String get roleIndividualDesc;

  /// No description provided for @roleInvestor.
  ///
  /// In ar, this message translates to:
  /// **'مستثمر'**
  String get roleInvestor;

  /// No description provided for @roleInvestorDesc.
  ///
  /// In ar, this message translates to:
  /// **'أبحث عن مشاريع قائمة أو أفكار واعدة لتمويلها كشريك مالي.'**
  String get roleInvestorDesc;

  /// No description provided for @roleProjectOwner.
  ///
  /// In ar, this message translates to:
  /// **'صاحب فكرة أو مشروع'**
  String get roleProjectOwner;

  /// No description provided for @roleProjectOwnerDesc.
  ///
  /// In ar, this message translates to:
  /// **'أريد تطوير مشروعي أو البحث عن شريك تنفيذي أو مستثمر.'**
  String get roleProjectOwnerDesc;

  /// No description provided for @roleCompany.
  ///
  /// In ar, this message translates to:
  /// **'شركة أو مزود خدمات'**
  String get roleCompany;

  /// No description provided for @roleCompanyDesc.
  ///
  /// In ar, this message translates to:
  /// **'أريد تقديم عروض وخدمات رسمية لرواد الأعمال والمستثمرين.'**
  String get roleCompanyDesc;

  /// No description provided for @setupStepGoal.
  ///
  /// In ar, this message translates to:
  /// **'ما هو هدفك الأساسي؟'**
  String get setupStepGoal;

  /// No description provided for @setupStepGoalDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختر الأهداف التي تود تحقيقها عبر التطبيق:'**
  String get setupStepGoalDesc;

  /// No description provided for @goalInvest.
  ///
  /// In ar, this message translates to:
  /// **'أريد استثمار مبلغ مالي متاح'**
  String get goalInvest;

  /// No description provided for @goalDiscover.
  ///
  /// In ar, this message translates to:
  /// **'لا أملك فكرة وأريد اكتشاف فرصة تناسبني'**
  String get goalDiscover;

  /// No description provided for @goalDevelop.
  ///
  /// In ar, this message translates to:
  /// **'تطوير مشروعي القائم وزيادة أرباحه'**
  String get goalDevelop;

  /// No description provided for @goalPartner.
  ///
  /// In ar, this message translates to:
  /// **'إيجاد شريك أو مستثمر لمشروعي'**
  String get goalPartner;

  /// No description provided for @goalService.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن خدمات تجارية واستشارات تأسيس'**
  String get goalService;

  /// No description provided for @setupStepLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع والأسواق'**
  String get setupStepLocation;

  /// No description provided for @setupStepLocationDesc.
  ///
  /// In ar, this message translates to:
  /// **'حدد السوق المستهدف للبحث عن فرص ملائمة محلياً:'**
  String get setupStepLocationDesc;

  /// No description provided for @setupCountry.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get setupCountry;

  /// No description provided for @setupCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get setupCity;

  /// No description provided for @setupCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة المفضلة'**
  String get setupCurrency;

  /// No description provided for @setupStepBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية ورأس المال'**
  String get setupStepBudget;

  /// No description provided for @setupStepBudgetDesc.
  ///
  /// In ar, this message translates to:
  /// **'حدد قدرتك المالية التقريبية لفرز الفرص المناسبة:'**
  String get setupStepBudgetDesc;

  /// No description provided for @setupBudgetAmount.
  ///
  /// In ar, this message translates to:
  /// **'رأس المال المتاح للبدء'**
  String get setupBudgetAmount;

  /// No description provided for @setupNoCapital.
  ///
  /// In ar, this message translates to:
  /// **'لا أملك رأس مال حالياً (أعتمد على مهارتي ووقتي)'**
  String get setupNoCapital;

  /// No description provided for @setupBudgetCeiling.
  ///
  /// In ar, this message translates to:
  /// **'سقف الإنفاق الأقصى (اختياري)'**
  String get setupBudgetCeiling;

  /// No description provided for @setupStepExperience.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة والوقت المتاح'**
  String get setupStepExperience;

  /// No description provided for @setupStepExperienceDesc.
  ///
  /// In ar, this message translates to:
  /// **'يساعدنا ذلك على اختيار مشاريع لا تتطلب جهداً يتجاوز إمكاناتك:'**
  String get setupStepExperienceDesc;

  /// No description provided for @setupExperienceLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى خبرتك السابقة في إدارة المشاريع'**
  String get setupExperienceLevel;

  /// No description provided for @expBeginner.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ (أول تجربة لي)'**
  String get expBeginner;

  /// No description provided for @expIntermediate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط (لدي اطلاع أو تجارب سابقة)'**
  String get expIntermediate;

  /// No description provided for @expAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'متقدم (أدرت وأطلقت مشاريع تجارية)'**
  String get expAdvanced;

  /// No description provided for @setupWeeklyHours.
  ///
  /// In ar, this message translates to:
  /// **'ساعات العمل المتاحة لك أسبوعياً'**
  String get setupWeeklyHours;

  /// No description provided for @setupManagementPref.
  ///
  /// In ar, this message translates to:
  /// **'طبيعة الإدارة المفضلة'**
  String get setupManagementPref;

  /// No description provided for @managementActive.
  ///
  /// In ar, this message translates to:
  /// **'أريد تشغيل وإدارة المشروع بنفسي'**
  String get managementActive;

  /// No description provided for @managementPassive.
  ///
  /// In ar, this message translates to:
  /// **'أفضل استثماراً ماليًا لا يتطلب إدارة يومية'**
  String get managementPassive;

  /// No description provided for @setupStepRisk.
  ///
  /// In ar, this message translates to:
  /// **'المخاطر والسيولة'**
  String get setupStepRisk;

  /// No description provided for @setupStepRiskDesc.
  ///
  /// In ar, this message translates to:
  /// **'الموازنة بين العائد المحتمل ودرجة الأمان المالي:'**
  String get setupStepRiskDesc;

  /// No description provided for @setupRiskTolerance.
  ///
  /// In ar, this message translates to:
  /// **'درجة تحملك للمخاطر'**
  String get setupRiskTolerance;

  /// No description provided for @riskLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفضة (الحفاظ على رأس المال أهم أولوياتي)'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة (أتحمل تقلبات معتدلة مقابل عائد أفضل)'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In ar, this message translates to:
  /// **'مرتفعة (مستعد للمخاطرة العالية سعياً لنمو سريع)'**
  String get riskHigh;

  /// No description provided for @setupLiquidity.
  ///
  /// In ar, this message translates to:
  /// **'المدى الزمني لاسترداد أو سحب السيولة'**
  String get setupLiquidity;

  /// No description provided for @liquidityShort.
  ///
  /// In ar, this message translates to:
  /// **'قصير الأجل (أقل من سنة واحدة)'**
  String get liquidityShort;

  /// No description provided for @liquidityMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأجل (من سنة إلى 3 سنوات)'**
  String get liquidityMedium;

  /// No description provided for @liquidityLong.
  ///
  /// In ar, this message translates to:
  /// **'طويل الأجل (أكثر من 3 سنوات)'**
  String get liquidityLong;

  /// No description provided for @setupRiskHelp.
  ///
  /// In ar, this message translates to:
  /// **'المخاطرة تعني احتمال تذبذب أو فقد جزء من المال، والسيولة تعني سرعة تحويل الاستثمار إلى كاش.'**
  String get setupRiskHelp;

  /// No description provided for @setupStepReview.
  ///
  /// In ar, this message translates to:
  /// **'ملخص تفضيلاتك'**
  String get setupStepReview;

  /// No description provided for @setupStepReviewDesc.
  ///
  /// In ar, this message translates to:
  /// **'راجع إجاباتك قبل الانتقال لاستكشاف الفرص المطابقة:'**
  String get setupStepReviewDesc;

  /// No description provided for @setupCompletionScore.
  ///
  /// In ar, this message translates to:
  /// **'اكتمال الملف التحليلي'**
  String get setupCompletionScore;

  /// No description provided for @setupShowOptions.
  ///
  /// In ar, this message translates to:
  /// **'اعرض الخيارات والفرص المناسبة'**
  String get setupShowOptions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
