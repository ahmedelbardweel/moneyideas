import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/home/presentation/widgets/admin_home_view.dart';
import 'package:moneyideas/features/home/presentation/widgets/company_home_view.dart';
import 'package:moneyideas/features/home/presentation/widgets/home_role_badge.dart';
import 'package:moneyideas/features/home/presentation/widgets/individual_home_view.dart';
import 'package:moneyideas/features/home/presentation/widgets/investor_home_view.dart';
import 'package:moneyideas/features/home/presentation/widgets/project_owner_home_view.dart';

/// Screen 16: Primary Role-Dispatched Home Screen.
/// Dynamically renders a completely dedicated, customized dashboard experience
/// depending on the user's active role:
/// - 'admin'         -> [AdminHomeView]
/// - 'company'       -> [CompanyHomeView]
/// - 'project_owner' -> [ProjectOwnerHomeView]
/// - 'investor'      -> [InvestorHomeView]
/// - 'individual'    -> [IndividualHomeView]
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeRole = ref.watch(activeRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.appName,
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            const HomeRoleBadge(),
          ],
        ),
        actions: [
          if (activeRole == 'company')
            IconButton(
              tooltip: 'إعدادات الشركة',
              icon: const Icon(Icons.business_center_outlined),
              onPressed: () => unawaited(context.push('/company/settings')),
            ),
          if (activeRole == 'admin')
            IconButton(
              tooltip: 'لوحة الرقابة الشاملة',
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () => unawaited(context.push(AppRoutes.admin)),
            ),
          IconButton(
            tooltip: 'الإشعارات والتنبيهات',
            icon: const Icon(AppIcons.notifications),
            onPressed: () => unawaited(context.push(AppRoutes.notifications)),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (activeRole) {
          'admin' => const AdminHomeView(),
          'company' => const CompanyHomeView(),
          'project_owner' => const ProjectOwnerHomeView(),
          'investor' => const InvestorHomeView(),
          _ => const IndividualHomeView(),
        },
      ),
    );
  }
}
