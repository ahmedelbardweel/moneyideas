import 'package:flutter/widgets.dart';

/// Material 3 corner-radius scale.
/// https://m3.material.io/styles/shape/corner-radius-scale
///
/// | Token        | dp  | Typical usage                                  |
/// |--------------|-----|------------------------------------------------|
/// | none         | 0   | Full-bleed images, app bars                    |
/// | extraSmall   | 4   | Snackbars, tooltips, text field top corners    |
/// | small        | 8   | Chips, small badges                            |
/// | medium       | 12  | Cards, menus, small dialogs                    |
/// | large        | 16  | FABs, navigation drawers, large cards          |
/// | largeIncr.   | 20  | Hero cards                                     |
/// | extraLarge   | 28  | Dialogs, bottom sheets, search bar             |
/// | extraLargeI. | 32  | Large containers                               |
/// | extraExtraL. | 48  | Expressive surfaces                            |
/// | full         | 999 | Buttons, pills, avatars, navigation indicator  |
abstract final class AppRadius {
  static const double none = 5;
  static const double extraSmall = 5;
  static const double small = 5;
  static const double medium = 5;
  static const double large = 5;
  static const double largeIncreased = 5;
  static const double extraLarge = 5;
  static const double extraLargeIncreased = 5;
  static const double extraExtraLarge = 5;
  static const double full = 5;

  static const BorderRadius noneAll = BorderRadius.zero;
  static const BorderRadius extraSmallAll = BorderRadius.all(
    Radius.circular(extraSmall),
  );
  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius largeIncreasedAll = BorderRadius.all(
    Radius.circular(largeIncreased),
  );
  static const BorderRadius extraLargeAll = BorderRadius.all(
    Radius.circular(extraLarge),
  );
  static const BorderRadius extraLargeIncreasedAll = BorderRadius.all(
    Radius.circular(extraLargeIncreased),
  );
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // Shorthand aliases
  static const BorderRadius xsAll = extraSmallAll;
  static const BorderRadius smAll = smallAll;
  static const BorderRadius mdAll = mediumAll;
  static const BorderRadius lgAll = largeAll;
  static const BorderRadius xlAll = extraLargeAll;

  /// Bottom sheets: rounded top corners only.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(extraLarge),
  );

  /// Chat bubbles (start/end aware so they flip correctly in RTL).
  static const BorderRadiusDirectional bubbleOutgoing =
      BorderRadiusDirectional.only(
        topStart: Radius.circular(largeIncreased),
        topEnd: Radius.circular(largeIncreased),
        bottomStart: Radius.circular(largeIncreased),
        bottomEnd: Radius.circular(extraSmall),
      );
  static const BorderRadiusDirectional bubbleIncoming =
      BorderRadiusDirectional.only(
        topStart: Radius.circular(largeIncreased),
        topEnd: Radius.circular(largeIncreased),
        bottomStart: Radius.circular(extraSmall),
        bottomEnd: Radius.circular(largeIncreased),
      );
}
