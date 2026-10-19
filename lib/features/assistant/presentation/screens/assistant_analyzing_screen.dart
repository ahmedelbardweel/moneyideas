import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/assistant/presentation/controllers/assistant_controller.dart';

/// Screen 35: Dynamic multi-step analysis progress screen.
class AssistantAnalyzingScreen extends ConsumerStatefulWidget {
  const AssistantAnalyzingScreen({super.key});

  @override
  ConsumerState<AssistantAnalyzingScreen> createState() =>
      _AssistantAnalyzingScreenState();
}

class _AssistantAnalyzingScreenState
    extends ConsumerState<AssistantAnalyzingScreen> {
  int _currentPhase = 0;
  Timer? _timer;

  static const List<(String, IconData)> _phases = [
    ('فحص الميزانية ورأس المال الأدنى', Icons.account_balance_wallet_rounded),
    ('مقارنة الوقت والجهد الأسبوعي المطلوب', Icons.schedule_rounded),
    ('مطابقة درجة تحمل المخاطر والخبرة', Icons.shield_rounded),
    ('التحقق من السوق والبيانات المعتمدة', Icons.verified_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      if (_currentPhase < _phases.length - 1) {
        setState(() => _currentPhase++);
      } else {
        timer.cancel();
        _proceedToResults();
      }
    });
  }

  void _proceedToResults() {
    final state = ref.read(assistantControllerProvider);
    if (!state.isAnalyzing) {
      context.pushReplacement(AppRoutes.assistantResults);
    } else {
      // If RPC is still in flight, wait a bit
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) context.pushReplacement(AppRoutes.assistantResults);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
              const Gap.xl(),
              Text(
                'جاري التحليل والمطابقة المباشرة',
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap.sm(),
              Text(
                'يتم فحص المعايير بدقة وفق محرك المطابقة المعتمد دون أي تقديرات وهمية.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap.xxl(),
              ...List.generate(_phases.length, (index) {
                final isDone = index < _currentPhase;
                final isCurrent = index == _currentPhase;
                final phase = _phases[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : (isCurrent
                                ? phase.$2
                                : Icons.radio_button_unchecked),
                        color: isDone
                            ? context.appColors.success.color
                            : (isCurrent
                                ? context.colors.primary
                                : context.colors.outlineVariant),
                      ),
                      const Gap.sm(),
                      Expanded(
                        child: Text(
                          phase.$1,
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? context.colors.onSurface
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
