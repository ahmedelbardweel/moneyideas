import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';

/// Centralized role-based route dispatcher ensuring seamless landing on the role's dedicated Home view.
abstract final class RoleNavigationHelper {
  /// Resolves the dedicated landing route based on active user roles in Supabase.
  /// All roles now land cleanly on the role-dispatched Home screen inside AppShell.
  static String getRouteForRoles(List<String> roles) {
    return AppRoutes.home;
  }

  /// Dispatches the user to their dedicated role-based home screen.
  static void dispatchUser(BuildContext context, List<String> roles) {
    const route = AppRoutes.home;
    try {
      final currentLoc = GoRouterState.of(context).matchedLocation;
      if (currentLoc == route) return;
    } on Object {
      // Fallback if router state not yet available
    }
    context.go(route);
  }
}
