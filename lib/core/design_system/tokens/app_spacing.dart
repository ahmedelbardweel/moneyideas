import 'package:flutter/widgets.dart';

/// 4dp spacing grid used for padding, margins and gaps.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Horizontal page margin for compact screens (M3 guideline: 16dp).
  static const double pageHorizontal = lg;

  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: lg,
  );
  static const EdgeInsets pageHorizontalOnly = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets cardDense = EdgeInsets.all(md);
  static const EdgeInsets listTile = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(xl, sm, xl, xl);
  static const EdgeInsets dialog = EdgeInsets.all(xl);
}

/// Fixed empty space along the main axis of a Flex (Row/Column).
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  const Gap.xxs({super.key}) : size = AppSpacing.xxs;
  const Gap.xs({super.key}) : size = AppSpacing.xs;
  const Gap.sm({super.key}) : size = AppSpacing.sm;
  const Gap.md({super.key}) : size = AppSpacing.md;
  const Gap.lg({super.key}) : size = AppSpacing.lg;
  const Gap.xl({super.key}) : size = AppSpacing.xl;
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;
  const Gap.xxxl({super.key}) : size = AppSpacing.xxxl;
  const Gap.huge({super.key}) : size = AppSpacing.huge;

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}
