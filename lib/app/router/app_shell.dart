import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/account/presentation/screens/account_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_companies_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_offers_screen.dart';
import 'package:moneyideas/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:moneyideas/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_campaigns_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_leads_screen.dart';
import 'package:moneyideas/features/company/presentation/screens/company_offers_screen.dart';
import 'package:moneyideas/features/deals/presentation/screens/deals_hub_screen.dart';
import 'package:moneyideas/features/discover/presentation/screens/discover_screen.dart';
import 'package:moneyideas/features/home/presentation/screens/home_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/my_projects_screen.dart';
import 'package:moneyideas/features/network/presentation/screens/network_screen.dart';

/// Central application shell with role-exclusive BottomNavigationBar and persistent state across tabs.
/// Every user role enjoys a completely customized set of 5 destinations and dedicated screens:
/// - Company:       [لوحة التحكم, العروض, الطلبات Leads, الحملات, حسابي]
/// - Project Owner: [مساحة المؤسس, مشاريعي, صفقات الضمان, المستثمرون, حسابي]
/// - Investor:      [محفظتي, صفقات المشاريع, صفقات الضمان, المستشار الذكي, حسابي]
/// - Admin:         [مركز القيادة, تدقيق العروض, توثيق الشركات, الرقابة والبلاغات, حسابي]
/// - Individual:    [الرئيسية, سوق الفرص, المستشار الذكي, شبكة الأعمال, حسابي]
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    this.navigationShell,
  });

  final StatefulNavigationShell? navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(activeRoleProvider);
    final currentIndex = ref.watch(roleNavIndexProvider);

    // Reset index to Home (0) if the user switches active role
    ref.listen(activeRoleProvider, (previous, next) {
      if (previous != next) {
        ref.read(roleNavIndexProvider.notifier).setIndex(0);
      }
    });

    final screens = _getScreensForRole(activeRole);
    final destinations = _getDestinationsForRole(activeRole, context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: (index) {
          ref.read(roleNavIndexProvider.notifier).setIndex(index);
        },
        destinations: destinations,
      ),
    );
  }

  static List<Widget> _getScreensForRole(String role) {
    return switch (role) {
      'admin' => const [
          HomeScreen(),
          AdminOffersScreen(),
          AdminCompaniesScreen(),
          AdminReportsScreen(),
          AccountScreen(),
        ],
      'company' => const [
          HomeScreen(),
          CompanyOffersScreen(),
          CompanyLeadsScreen(),
          CompanyCampaignsScreen(),
          AccountScreen(),
        ],
      'project_owner' => const [
          HomeScreen(),
          MyProjectsScreen(),
          DealsHubScreen(),
          NetworkScreen(),
          AccountScreen(),
        ],
      'investor' => const [
          HomeScreen(),
          NetworkScreen(),
          DealsHubScreen(),
          AssistantScreen(),
          AccountScreen(),
        ],
      _ => const [
          HomeScreen(),
          DiscoverScreen(),
          AssistantScreen(),
          NetworkScreen(),
          AccountScreen(),
        ],
    };
  }

  static List<NavigationDestination> _getDestinationsForRole(
    String role,
    BuildContext context,
  ) {
    return switch (role) {
      'admin' => const [
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings_rounded),
            label: 'مركز القيادة',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_folder_outlined),
            selectedIcon: Icon(Icons.rule_folder_rounded),
            label: 'تدقيق العروض',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user_rounded),
            label: 'توثيق الشركات',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'الرقابة والبلاغات',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.account),
            selectedIcon: Icon(AppIcons.account),
            label: 'حسابي',
          ),
        ],
      'company' => const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'لوحة التحكم',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'العروض',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind_rounded),
            label: 'الطلبات Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'الحملات',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center_rounded),
            label: 'حسابي',
          ),
        ],
      'project_owner' => const [
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded),
            label: 'مساحة المؤسس',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_shared_outlined),
            selectedIcon: Icon(Icons.folder_shared_rounded),
            label: 'مشاريعي',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'صفقات الضمان',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'المستثمرون',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.account),
            selectedIcon: Icon(AppIcons.account),
            label: 'حسابي',
          ),
        ],
      'investor' => const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'محفظتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'صفقات المشاريع',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'صفقات الضمان',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.assistant),
            selectedIcon: Icon(AppIcons.assistant),
            label: 'المستشار الذكي',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.account),
            selectedIcon: Icon(AppIcons.account),
            label: 'حسابي',
          ),
        ],
      _ => const [
          NavigationDestination(
            icon: Icon(AppIcons.home),
            selectedIcon: Icon(AppIcons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.discover),
            selectedIcon: Icon(AppIcons.discover),
            label: 'سوق الفرص',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.assistant),
            selectedIcon: Icon(AppIcons.assistant),
            label: 'المستشار الذكي',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.network),
            selectedIcon: Icon(AppIcons.network),
            label: 'شبكة الأعمال',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.account),
            selectedIcon: Icon(AppIcons.account),
            label: 'حسابي',
          ),
        ],
    };
  }
}
