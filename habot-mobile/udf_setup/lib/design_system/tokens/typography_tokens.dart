/// AISS: RCGLA-001-A01 -- "Gather all brand identity assets -- color palette,
/// typography, spacing, iconography, elevation."
///
/// Captures the atomic data fields the spec names for this step:
/// Font Name; Font Size; Line Height; Font Weight; Font File Path.
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
library;

import 'package:flutter/material.dart';

/// One entry of the Material 3 type scale, carrying exactly the fields the
/// spreadsheet's "Data Collected by System" column requires.
@immutable
class HabotTypeToken {
  const HabotTypeToken({
    required this.name,
    required this.sizeSp,
    required this.lineHeightSp,
    required this.weight,
    required this.tracking,
  });

  final String name;
  final double sizeSp;
  final double lineHeightSp;
  final int weight;
  final double tracking;

  /// Flutter expresses line height as a unitless multiple of font size.
  double get heightMultiple => lineHeightSp / sizeSp;

  FontWeight get fontWeight {
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        throw ArgumentError.value(weight, 'weight', 'Not a Material weight');
    }
  }

  TextStyle toTextStyle(String fontFamily) => TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSp,
    height: heightMultiple,
    fontWeight: fontWeight,
    letterSpacing: tracking,
  );
}

class HabotTypography {
  const HabotTypography._();

  /// Data field: Font Name.
  static const String fontName = 'Roboto';

  /// Data field: Font File Path. Roboto is the platform-bundled Material type
  /// face, so there is no asset to ship. Recorded explicitly rather than left
  /// blank so the AISS evidence record is complete.
  static const String fontFilePath =
      'platform-bundled (Flutter default Material type face); no external asset required';

  static const HabotTypeToken displayLarge = HabotTypeToken(
    name: 'displayLarge',
    sizeSp: 57,
    lineHeightSp: 64,
    weight: 400,
    tracking: -0.25,
  );
  static const HabotTypeToken displayMedium = HabotTypeToken(
    name: 'displayMedium',
    sizeSp: 45,
    lineHeightSp: 52,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken displaySmall = HabotTypeToken(
    name: 'displaySmall',
    sizeSp: 36,
    lineHeightSp: 44,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken headlineLarge = HabotTypeToken(
    name: 'headlineLarge',
    sizeSp: 32,
    lineHeightSp: 40,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken headlineMedium = HabotTypeToken(
    name: 'headlineMedium',
    sizeSp: 28,
    lineHeightSp: 36,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken headlineSmall = HabotTypeToken(
    name: 'headlineSmall',
    sizeSp: 24,
    lineHeightSp: 32,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken titleLarge = HabotTypeToken(
    name: 'titleLarge',
    sizeSp: 22,
    lineHeightSp: 28,
    weight: 400,
    tracking: 0,
  );
  static const HabotTypeToken titleMedium = HabotTypeToken(
    name: 'titleMedium',
    sizeSp: 16,
    lineHeightSp: 24,
    weight: 500,
    tracking: 0.15,
  );
  static const HabotTypeToken titleSmall = HabotTypeToken(
    name: 'titleSmall',
    sizeSp: 14,
    lineHeightSp: 20,
    weight: 500,
    tracking: 0.1,
  );
  static const HabotTypeToken bodyLarge = HabotTypeToken(
    name: 'bodyLarge',
    sizeSp: 16,
    lineHeightSp: 24,
    weight: 400,
    tracking: 0.5,
  );
  static const HabotTypeToken bodyMedium = HabotTypeToken(
    name: 'bodyMedium',
    sizeSp: 14,
    lineHeightSp: 20,
    weight: 400,
    tracking: 0.25,
  );
  static const HabotTypeToken bodySmall = HabotTypeToken(
    name: 'bodySmall',
    sizeSp: 12,
    lineHeightSp: 16,
    weight: 400,
    tracking: 0.4,
  );
  static const HabotTypeToken labelLarge = HabotTypeToken(
    name: 'labelLarge',
    sizeSp: 14,
    lineHeightSp: 20,
    weight: 500,
    tracking: 0.1,
  );
  static const HabotTypeToken labelMedium = HabotTypeToken(
    name: 'labelMedium',
    sizeSp: 12,
    lineHeightSp: 16,
    weight: 500,
    tracking: 0.5,
  );
  static const HabotTypeToken labelSmall = HabotTypeToken(
    name: 'labelSmall',
    sizeSp: 11,
    lineHeightSp: 16,
    weight: 500,
    tracking: 0.5,
  );

  static const List<HabotTypeToken> all = <HabotTypeToken>[
    displayLarge,
    displayMedium,
    displaySmall,
    headlineLarge,
    headlineMedium,
    headlineSmall,
    titleLarge,
    titleMedium,
    titleSmall,
    bodyLarge,
    bodyMedium,
    bodySmall,
    labelLarge,
    labelMedium,
    labelSmall,
  ];

  /// The complete Material 3 [TextTheme], generated from the tokens above so
  /// the type scale can never drift from the token file.
  static TextTheme textTheme() => TextTheme(
    displayLarge: displayLarge.toTextStyle(fontName),
    displayMedium: displayMedium.toTextStyle(fontName),
    displaySmall: displaySmall.toTextStyle(fontName),
    headlineLarge: headlineLarge.toTextStyle(fontName),
    headlineMedium: headlineMedium.toTextStyle(fontName),
    headlineSmall: headlineSmall.toTextStyle(fontName),
    titleLarge: titleLarge.toTextStyle(fontName),
    titleMedium: titleMedium.toTextStyle(fontName),
    titleSmall: titleSmall.toTextStyle(fontName),
    bodyLarge: bodyLarge.toTextStyle(fontName),
    bodyMedium: bodyMedium.toTextStyle(fontName),
    bodySmall: bodySmall.toTextStyle(fontName),
    labelLarge: labelLarge.toTextStyle(fontName),
    labelMedium: labelMedium.toTextStyle(fontName),
    labelSmall: labelSmall.toTextStyle(fontName),
  );
}
