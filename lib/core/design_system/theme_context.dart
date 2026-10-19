import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_colors.dart';

/// Short-hands so widgets read tokens without repeating `Theme.of(context)`.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
