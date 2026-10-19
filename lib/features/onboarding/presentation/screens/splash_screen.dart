import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/role_navigation.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_checkSession());
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    if (Env.isConfigured) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          try {
            final rolesData = await Supabase.instance.client
                .from('user_roles')
                .select('role')
                .eq('user_id', session.user.id);
            final roles = (rolesData as List<dynamic>)
                .map((r) => (r as Map<String, dynamic>)['role'] as String)
                .toList();
            if (mounted) {
              RoleNavigationHelper.dispatchUser(context, roles);
              return;
            }
          } catch (_) {
            if (mounted) {
              RoleNavigationHelper.dispatchUser(context, const ['individual']);
              return;
            }
          }
        }
      } on Object catch (_) {
        // Not initialized in unit tests or offline
      }
    }

    // New or unauthenticated visitor -> Language -> Onboarding -> Welcome
    if (!mounted) return;
    context.go(AppRoutes.language);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.budget,
                size: AppSizes.appLogo,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const Gap.xl(),
            Text(
              l10n.appName,
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const Gap.xs(),
            Text(
              l10n.appTagline,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.xxl(),
            CircularProgressIndicator(
              color: context.colors.primary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
