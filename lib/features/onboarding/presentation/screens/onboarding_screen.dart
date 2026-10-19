import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen 03: Interactive Onboarding slides explaining AI Advisor, Market, and Network.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      unawaited(
        _pageController.nextPage(
          duration: AppMotion.medium2,
          curve: AppMotion.emphasized,
        ),
      );
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final slides = [
      _SlideData(
        title: l10n.onboardingSlide1Title,
        description: l10n.onboardingSlide1Desc,
        icon: AppIcons.assistant,
      ),
      _SlideData(
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Desc,
        icon: AppIcons.commerce,
      ),
      _SlideData(
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Desc,
        icon: AppIcons.network,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.welcome),
            child: Text(l10n.commonSkip),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: AppSizes.appLogo,
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                        const Gap.xxl(),
                        Text(
                          slide.title,
                          style: context.textStyles.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap.md(),
                        Text(
                          slide.description,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Indicator and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // M3 pill/dot indicators
                  Row(
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: AppMotion.short3,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? context.colors.primary
                              : context.colors.outlineVariant,
                          borderRadius: AppRadius.fullAll,
                        ),
                      ),
                    ),
                  ),

                  AppButton(
                    text: _currentIndex == 2 ? l10n.commonStartNow : l10n.commonContinue,
                    onPressed: _onNext,
                  ),
                ],
              ),
              const Gap.lg(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
