import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/app_shell.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/features/account/presentation/screens/account_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/edit_profile_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/help_support_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/investment_preferences_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/manage_roles_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/privacy_security_screen.dart';
import 'package:moneyideas/features/account/presentation/screens/subscription_screen.dart';
import 'package:moneyideas/features/assistant/presentation/screens/assistant_analyzing_screen.dart';
import 'package:moneyideas/features/assistant/presentation/screens/assistant_chat_screen.dart';
import 'package:moneyideas/features/assistant/presentation/screens/assistant_results_screen.dart';
import 'package:moneyideas/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:moneyideas/features/auth/presentation/screens/login_screen.dart';
import 'package:moneyideas/features/auth/presentation/screens/register_screen.dart';
import 'package:moneyideas/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:moneyideas/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/compare_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/discover_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/next_steps_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/notifications_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/opportunity_details_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/saved_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/search_screen.dart';
import 'package:moneyideas/features/home/presentation/screens/home_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/network_screen.dart';
import 'package:moneyideas/features/onboarding/presentation/screens/language_screen.dart';
import 'package:moneyideas/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:moneyideas/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:moneyideas/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:moneyideas/features/profile_setup/presentation/screens/profile_setup_stepper_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_campaigns_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_create_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_dashboard_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_leads_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_offers_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_public_profile_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_settings_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_stats_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_verify_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/create_offer_stepper_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/offer_details_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/offer_review_status_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_companies_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_offers_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/create_project_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/project_details_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/investor_profile_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/edit_investor_profile_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/contact_requests_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/my_projects_screen.dart';
import 'package:moneyideas/features/chat/presentation/screens/conversations_screen.dart';
import 'package:moneyideas/features/chat/presentation/screens/chat_screen.dart';
import 'package:moneyideas/features/deals/presentation/screens/deals_hub_screen.dart';
import 'package:moneyideas/features/deals/presentation/screens/deal_details_screen.dart';
import 'package:moneyideas/features/deals/presentation/screens/deal_contract_screen.dart';
import 'package:moneyideas/features/deals/presentation/screens/deal_escrow_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Primary GoRouter configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) {
        final email = state.extra as String? ??
            state.uri.queryParameters['email'] ??
            '';
        return VerifyEmailScreen(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.setup,
      builder: (context, state) => const ProfileSetupStepperScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.opportunityDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OpportunityDetailsScreen(opportunityId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.compare,
      builder: (context, state) => const CompareScreen(),
    ),
    GoRoute(
      path: AppRoutes.saved,
      builder: (context, state) => const SavedScreen(),
    ),
    GoRoute(
      path: AppRoutes.nextSteps,
      builder: (context, state) => const NextStepsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.assistantChat,
      builder: (context, state) => const AssistantChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.assistantAnalyzing,
      builder: (context, state) => const AssistantAnalyzingScreen(),
    ),
    GoRoute(
      path: AppRoutes.assistantResults,
      builder: (context, state) => const AssistantResultsScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountRoles,
      builder: (context, state) => const ManageRolesScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountPreferences,
      builder: (context, state) => const InvestmentPreferencesScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountPrivacy,
      builder: (context, state) => const PrivacySecurityScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountSupport,
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountSubscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    // Company routes
    GoRoute(
      path: AppRoutes.companyDashboard,
      builder: (context, state) => const CompanyDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyCreate,
      builder: (context, state) => const CompanyCreateScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyVerify,
      builder: (context, state) => const CompanyVerifyScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyCreateOffer,
      builder: (context, state) => const CreateOfferStepperScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyOffers,
      builder: (context, state) => const CompanyOffersScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyLeads,
      builder: (context, state) => const CompanyLeadsScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyStats,
      builder: (context, state) => const CompanyStatsScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyCampaigns,
      builder: (context, state) => const CompanyCampaignsScreen(),
    ),
    GoRoute(
      path: AppRoutes.companySettings,
      builder: (context, state) => const CompanySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.offerReviewStatus,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OfferReviewStatusScreen(offerId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.offerDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OfferDetailsScreen(offerId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.companyPublicProfile,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CompanyPublicProfileScreen(companyId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminCompanies,
      builder: (context, state) => const AdminCompaniesScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminOffers,
      builder: (context, state) => const AdminOffersScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminReports,
      builder: (context, state) => const AdminReportsScreen(),
    ),
    GoRoute(
      path: AppRoutes.createProject,
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: AppRoutes.projectDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectDetailsScreen(projectId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.investorProfile,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return InvestorProfileScreen(investorId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.editInvestorProfile,
      builder: (context, state) => const EditInvestorProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.contactRequests,
      builder: (context, state) => const ContactRequestsScreen(),
    ),
    GoRoute(
      path: AppRoutes.myProjects,
      builder: (context, state) => const MyProjectsScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatList,
      builder: (context, state) => const ConversationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatRoom,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ChatScreen(conversationId: id);
      },
    ),
    // Deals & Regulatory Escrow (Screens 79-82)
    GoRoute(
      path: AppRoutes.deals,
      builder: (context, state) => const DealsHubScreen(),
    ),
    GoRoute(
      path: AppRoutes.dealDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DealDetailsScreen(dealId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.dealContract,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DealContractScreen(dealId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.dealEscrow,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DealEscrowScreen(dealId: id);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.discover,
              builder: (context, state) => const DiscoverScreen(),
            ),
          ],
        ),
        // Tab 2: Assistant
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.assistant,
              builder: (context, state) => const AssistantScreen(),
            ),
          ],
        ),
        // Tab 3: Network
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.network,
              builder: (context, state) => const NetworkScreen(),
            ),
          ],
        ),
        // Tab 4: Account
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
