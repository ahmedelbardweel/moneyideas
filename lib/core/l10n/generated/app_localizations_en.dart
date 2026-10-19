// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Money Ideas';

  @override
  String get appTagline => 'Smart Business & Investment Platform';

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navNetwork => 'Network';

  @override
  String get navAccount => 'Account';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStartNow => 'Start Now';

  @override
  String get errorRequired => 'This field is required';

  @override
  String errorMinLength(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String errorMaxLength(int max) {
    return 'Must not exceed $max characters';
  }

  @override
  String get errorInvalidName => 'Name must contain letters and spaces only';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address';

  @override
  String get errorWeakPassword =>
      'Password must be at least 8 chars with uppercase, lowercase, and a digit';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String errorInvalidOtp(int length) {
    return 'Verification code must be $length digits';
  }

  @override
  String get errorInvalidNumber => 'Please enter a valid number';

  @override
  String get errorOutOfRange => 'Entered value is out of allowed range';

  @override
  String errorTooManyDecimals(int max) {
    return 'Maximum decimal places allowed is $max';
  }

  @override
  String get errorInvalidUrl => 'Please enter a valid web URL';

  @override
  String get errorInsecureUrl => 'URL must begin with https for your security';

  @override
  String get errorInvalidPhone => 'Please enter a valid phone number';

  @override
  String get errorInvalidLicense => 'Invalid trade license format';

  @override
  String get errorForbiddenClaim =>
      'Guaranteed profit or risk-free claims are not permitted';

  @override
  String get errorMustAccept => 'You must accept the terms to continue';

  @override
  String get errorSelectionRequired => 'Please select at least one option';

  @override
  String get errorFileTooLarge => 'File exceeds the allowed size limit (10MB)';

  @override
  String get errorFileTypeNotAllowed => 'File type is not supported';

  @override
  String get networkErrorTitle => 'No Internet Connection';

  @override
  String get networkErrorMessage =>
      'Could not connect to the server. You can view offline saved data or retry.';

  @override
  String get serverErrorTitle => 'Unexpected Error';

  @override
  String get serverErrorMessage =>
      'We encountered a problem processing your request. Please try again later.';

  @override
  String get emptyStateTitle => 'No Matching Results';

  @override
  String get emptyStateMessage =>
      'Try adjusting your search criteria or filters to explore more options.';

  @override
  String get unauthorizedTitle => 'Unauthorized Access';

  @override
  String get unauthorizedMessage =>
      'You need to log in or have appropriate permissions to view this content.';

  @override
  String get dataNeedsUpdate => 'Information needs update';

  @override
  String get dataVerified => 'Verified data source';

  @override
  String get dataEstimated => 'Estimated figures subject to variation';

  @override
  String get sponsoredAd => 'Sponsored Ad';

  @override
  String get languageTitle => 'Choose App Language';

  @override
  String get languageSubtitle =>
      'You can change the language anytime from settings';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get english => 'English (الإنجليزية)';

  @override
  String get onboardingSlide1Title => 'Smart Business Advisor';

  @override
  String get onboardingSlide1Desc =>
      'Analyzes your capacity, budget, and experience to propose data-verified options without false claims.';

  @override
  String get onboardingSlide2Title => 'Integrated Opportunity Marketplace';

  @override
  String get onboardingSlide2Desc =>
      'Explore business ideas, operational cost breakdowns, risks, and verified company offers with ease.';

  @override
  String get onboardingSlide3Title => 'Partnership & Investor Network';

  @override
  String get onboardingSlide3Desc =>
      'Connect with entrepreneurs, investors, and vetted companies to build and scale ventures together.';

  @override
  String get welcomeTitle => 'Welcome to Money Ideas';

  @override
  String get welcomeSubtitle =>
      'Your intelligent portal to transform ambitions and budget into verified, well-studied ventures.';

  @override
  String get authLogin => 'Log In';

  @override
  String get authRegister => 'Create Account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authGuest => 'Explore as Guest';

  @override
  String get authVerifyEmailTitle => 'Verify Your Email';

  @override
  String authVerifyEmailDesc(String email) {
    return 'Enter the 6-digit verification code sent to $email';
  }

  @override
  String get authResendOtp => 'Resend Code';

  @override
  String authResendInSeconds(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get authAgreeTerms =>
      'I agree to the Terms of Service & Privacy Policy';

  @override
  String get authResetPasswordTitle => 'Reset Password';

  @override
  String get authResetPasswordDesc =>
      'Enter your registered email and we\'ll send password recovery instructions.';

  @override
  String get authSendResetLink => 'Send Recovery Link';

  @override
  String get authResetSuccess =>
      'Password recovery instructions have been sent to your email.';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get setupTitle => 'Personalize Your Experience';

  @override
  String get setupStepRole => 'Account Role';

  @override
  String get setupStepRoleDesc =>
      'Select roles that match your intent (multi-selection supported):';

  @override
  String get roleIndividual => 'Individual / Explorer';

  @override
  String get roleIndividualDesc =>
      'I want to invest capital or discover a suitable business idea.';

  @override
  String get roleInvestor => 'Investor';

  @override
  String get roleInvestorDesc =>
      'I seek established businesses or promising concepts for co-funding.';

  @override
  String get roleProjectOwner => 'Founder / Project Owner';

  @override
  String get roleProjectOwnerDesc =>
      'I want to grow my existing business or find partners and investors.';

  @override
  String get roleCompany => 'Company / Service Provider';

  @override
  String get roleCompanyDesc =>
      'I provide formal services and B2B solutions to founders and investors.';

  @override
  String get setupStepGoal => 'What is your main goal?';

  @override
  String get setupStepGoalDesc =>
      'Select what you want to achieve through Money Ideas:';

  @override
  String get goalInvest => 'Invest available capital';

  @override
  String get goalDiscover =>
      'I don\'t have an idea and want to discover opportunities';

  @override
  String get goalDevelop => 'Grow and scale my existing business';

  @override
  String get goalPartner => 'Find a partner or co-investor';

  @override
  String get goalService => 'Find corporate services and setup solutions';

  @override
  String get setupStepLocation => 'Location & Target Markets';

  @override
  String get setupStepLocationDesc =>
      'Choose your operational market for localized insights:';

  @override
  String get setupCountry => 'Country';

  @override
  String get setupCity => 'City';

  @override
  String get setupCurrency => 'Preferred Currency';

  @override
  String get setupStepBudget => 'Budget & Capital';

  @override
  String get setupStepBudgetDesc =>
      'Specify your financial range to filter viable opportunities:';

  @override
  String get setupBudgetAmount => 'Available Starting Capital';

  @override
  String get setupNoCapital =>
      'I have no capital right now (relying on skills and time)';

  @override
  String get setupBudgetCeiling => 'Maximum spending ceiling (optional)';

  @override
  String get setupStepExperience => 'Experience & Available Time';

  @override
  String get setupStepExperienceDesc =>
      'Helps us recommend ventures matching your bandwidth:';

  @override
  String get setupExperienceLevel => 'Previous business management experience';

  @override
  String get expBeginner => 'Beginner (First endeavor)';

  @override
  String get expIntermediate => 'Intermediate (Familiar with business basics)';

  @override
  String get expAdvanced => 'Advanced (Have founded and managed businesses)';

  @override
  String get setupWeeklyHours => 'Weekly hours available to dedicate';

  @override
  String get setupManagementPref => 'Preferred management involvement';

  @override
  String get managementActive =>
      'I want to actively operate the business myself';

  @override
  String get managementPassive =>
      'I prefer a passive investment with minimal daily management';

  @override
  String get setupStepRisk => 'Risk & Liquidity';

  @override
  String get setupStepRiskDesc =>
      'Balance potential return against capital security:';

  @override
  String get setupRiskTolerance => 'Risk Tolerance Level';

  @override
  String get riskLow => 'Low (Capital preservation is my priority)';

  @override
  String get riskMedium =>
      'Medium (Accept moderate fluctuations for better yields)';

  @override
  String get riskHigh => 'High (Comfortable with volatility for high growth)';

  @override
  String get setupLiquidity => 'Time horizon for capital liquidity';

  @override
  String get liquidityShort => 'Short-term (Under 1 year)';

  @override
  String get liquidityMedium => 'Medium-term (1 to 3 years)';

  @override
  String get liquidityLong => 'Long-term (Over 3 years)';

  @override
  String get setupRiskHelp =>
      'Risk measures capital fluctuation, while liquidity measures how quickly your investment can be liquidated.';

  @override
  String get setupStepReview => 'Review Your Profile';

  @override
  String get setupStepReviewDesc =>
      'Review your answers before exploring matching opportunities:';

  @override
  String get setupCompletionScore => 'Analytical Profile Completeness';

  @override
  String get setupShowOptions => 'Show Matching Opportunities';
}
