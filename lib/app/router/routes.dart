/// Centralized route paths for typed navigation.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify';
  static const String resetPassword = '/auth/reset';

  // Setup
  static const String setup = '/setup';

  // Core 5 tabs
  static const String home = '/';
  static const String discover = '/discover';
  static const String assistant = '/assistant';
  static const String assistantChat = '/assistant/chat';
  static const String assistantAnalyzing = '/assistant/analyzing';
  static const String assistantResults = '/assistant/results';
  static const String network = '/network';
  static const String account = '/account';
  static const String editProfile = '/account/edit';
  static const String accountRoles = '/account/roles';
  static const String accountPreferences = '/account/preferences';
  static const String accountPrivacy = '/account/privacy';
  static const String accountSupport = '/account/support';
  static const String accountSubscription = '/account/subscription';

  // Opportunities
  static const String search = '/search';
  static const String opportunityDetails = '/opportunity/:id';
  static const String compare = '/compare';
  static const String saved = '/saved';
  static const String nextSteps = '/next-steps';
  static const String notifications = '/notifications';

  // Company & Commercial Offers
  static const String companyDashboard = '/company/dashboard';
  static const String companyCreate = '/company/create';
  static const String companyVerify = '/company/verify';
  static const String companyCreateOffer = '/company/offers/new';
  static const String companyOffers = '/company/offers';
  static const String companyLeads = '/company/leads';
  static const String companyStats = '/company/stats';
  static const String companyCampaigns = '/company/campaigns';
  static const String companySettings = '/company/settings';
  static const String offerReviewStatus = '/company/offers/:id/review';
  static const String offerDetails = '/offer/:id';
  static const String companyPublicProfile = '/company/:id';

  // Network & Chat
  static const String chatList = '/chat';
  static const String chatRoom = '/chat/:id';
  static const String createProject = '/project/new';
  static const String projectDetails = '/network/project/:id';
  static const String investorProfile = '/network/investor/:id';
  static const String editInvestorProfile = '/network/investor/edit';
  static const String contactRequests = '/network/requests';
  static const String myProjects = '/my-projects';

  // Super Admin
  static const String admin = '/admin';
  static const String adminCompanies = '/admin/companies';
  static const String adminOffers = '/admin/offers';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';

  // Deals & Regulatory Escrow (Screens 79-82)
  static const String deals = '/deals';
  static const String dealDetails = '/deals/:id';
  static const String dealContract = '/deals/:id/contract';
  static const String dealEscrow = '/deals/:id/escrow';
}
