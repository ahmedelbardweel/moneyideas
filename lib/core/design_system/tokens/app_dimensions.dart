import 'package:flutter/animation.dart';

/// Material 3 elevation levels (dp). M3 prefers tonal surfaces over shadows,
/// so most components use level0–level2.
abstract final class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;
}

/// Material 3 motion tokens.
/// https://m3.material.io/styles/motion/easing-and-duration
abstract final class AppMotion {
  static const Duration short1 = Duration(milliseconds: 50);
  static const Duration short2 = Duration(milliseconds: 100);
  static const Duration short3 = Duration(milliseconds: 150);
  static const Duration short4 = Duration(milliseconds: 200);
  static const Duration medium1 = Duration(milliseconds: 250);
  static const Duration medium2 = Duration(milliseconds: 300);
  static const Duration medium3 = Duration(milliseconds: 350);
  static const Duration medium4 = Duration(milliseconds: 400);
  static const Duration long1 = Duration(milliseconds: 450);
  static const Duration long2 = Duration(milliseconds: 500);
  static const Duration extraLong1 = Duration(milliseconds: 700);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve standardDecelerate = Cubic(0, 0, 0, 1);
  static const Curve standardAccelerate = Cubic(0.3, 0, 1, 1);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

/// Component and icon sizes.
abstract final class AppSizes {
  static const double iconSmall = 18;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;
  static const double illustration = 120;

  static const double buttonHeight = 40;
  static const double buttonHeightLarge = 56;
  static const double minTouchTarget = 48;
  static const double inputHeight = 56;

  static const double avatarSmall = 32;
  static const double avatarMedium = 40;
  static const double avatarLarge = 56;
  static const double avatarXLarge = 96;

  static const double appLogo = 96;
  static const double navigationBarHeight = 80;
  static const double maxContentWidth = 640;
  static const double adminSidebarWidth = 280;
  static const double strokeThin = 1;
  static const double progressStroke = 4;
}
