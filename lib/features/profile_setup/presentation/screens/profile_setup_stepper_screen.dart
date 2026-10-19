import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/role_navigation.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_budget_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_experience_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_goals_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_location_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_review_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_risk_widget.dart';
import 'package:moneyideas/features/profile_setup/presentation/widgets/step_roles_widget.dart';

/// Stepper container screen orchestrating the 7 analytical profile setup steps (Screens 09-15).
class ProfileSetupStepperScreen extends ConsumerStatefulWidget {
  const ProfileSetupStepperScreen({super.key});

  @override
  ConsumerState<ProfileSetupStepperScreen> createState() =>
      _ProfileSetupStepperScreenState();
}

class _ProfileSetupStepperScreenState
    extends ConsumerState<ProfileSetupStepperScreen> {
  int _currentStep = 0;
  bool _isSaving = false;
  static const int _totalSteps = 7;

  void _goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      setState(() => _currentStep = step);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      unawaited(_finishSetup());
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  Future<void> _finishSetup() async {
    setState(() => _isSaving = true);
    try {
      final selectedRoles =
          ref.read(profileSetupProvider).selectedRoles.toList();
      await ref.read(profileSetupProvider.notifier).saveProfile();
      ref.invalidate(userProfileProvider);
      if (mounted) {
        RoleNavigationHelper.dispatchUser(context, selectedRoles);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return const StepRolesWidget();
      case 1:
        return const StepGoalsWidget();
      case 2:
        return const StepLocationWidget();
      case 3:
        return const StepBudgetWidget();
      case 4:
        return const StepExperienceWidget();
      case 5:
        return const StepRiskWidget();
      case 6:
        return StepReviewWidget(
          onEditStep: _goToStep,
          onSubmit: () => unawaited(_finishSetup()),
          isSubmitting: _isSaving,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الخطوة ${_currentStep + 1} من $_totalSteps',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: _prevStep,
        ),
        actions: [
          if (_currentStep < _totalSteps - 1)
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(
                l10n.commonSkip,
                style: context.textStyles.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            minHeight: 4,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ),
            if (_currentStep < 6)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: context.colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: AppButton.outlined(
                          text: l10n.commonBack,
                          onPressed: _prevStep,
                        ),
                      ),
                      const Gap.md(),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: l10n.commonContinue,
                        icon: AppIcons.forward,
                        onPressed: _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
