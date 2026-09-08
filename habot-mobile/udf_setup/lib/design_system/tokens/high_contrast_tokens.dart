/// AISS Step 105 -- GEN-00368
/// "Confirm pixel-perfect token alignment across light, dark, and
///  high-contrast modes."
/// Metric: WCAG Contrast Ratio -- 3:1 large text / UI, 4.5:1 normal, 7:1 AAA.
///
/// Light and dark already exist and are gated by Step 4 (28 pairs, worst
/// 6.54:1 light and 7.18:1 dark). High contrast did not exist. This declares
/// it as a THIRD SCHEME OF THE SAME SHAPE, so it flows through the Step 4
/// contrast engine and the Step 96 audit with no second calculator anywhere.
///
/// The design rule for this scheme, stated so it can be checked rather than
/// admired: **every audited pair clears 7:1**, not merely the 4.5:1 AA floor.
/// A high-contrast mode that only just passes AA is not a high-contrast mode;
/// it is the normal mode with the same problems and a different name.
/// `HabotHighContrast.textFloor` is that promise as a number, and
/// GEN-00368-G1 fails the build if any pair falls under it.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// "Pixel-perfect token alignment" is read as: the three schemes declare the
/// SAME role set, no more and no less. A scheme missing a role is a widget
/// falling back to a Material default, which is exactly the drift the token
/// system exists to stop. GEN-00368-G2 checks that alignment.
library;

import 'dart:ui' show Color;

import 'color_tokens.dart';

/// The high-contrast schemes, plus the promise they are held to.
class HabotHighContrast {
  const HabotHighContrast._();

  /// This scheme's own floor, deliberately at the WCAG AAA figure rather than
  /// the AA one. See the library comment.
  static const double textFloor = 7.0;

  /// SC 1.4.11's floor for meaning-bearing non-text. Unchanged -- what changes
  /// in this scheme is how far above it the tokens sit.
  static const double nonTextFloor = 3.0;

  /// High-contrast light. Pure white ground, pure black text, and every
  /// container tinted only as far as it can go while still clearing 7:1
  /// against `onSurface`.
  static const HabotColorScheme light = HabotColorScheme(
    primary: Color(0xFF00325A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD6E4F7),
    onPrimaryContainer: Color(0xFF001A33),
    secondary: Color(0xFF00363A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCFE9EB),
    onSecondaryContainer: Color(0xFF001417),
    tertiary: Color(0xFF3A2B45),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE8DEF0),
    onTertiaryContainer: Color(0xFF1C1122),
    error: Color(0xFF8C0009),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF2D0001),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onSurfaceVariant: Color(0xFF1A1C1E),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F9FC),
    surfaceContainer: Color(0xFFF1F4F8),
    surfaceContainerHigh: Color(0xFFE9EDF2),
    surfaceContainerHighest: Color(0xFFE1E6EC),
    outline: Color(0xFF2E3134),
    outlineVariant: Color(0xFF5C6166),
    inverseSurface: Color(0xFF000000),
    onInverseSurface: Color(0xFFFFFFFF),
  );

  /// High-contrast dark. The mirror of the above: pure black ground, pure
  /// white text, containers lifted only as far as 7:1 allows.
  ///
  /// NOTE on the elevation ladder: the normal dark scheme lifts surfaces with
  /// a translucent white overlay (Step 3). That technique is deliberately NOT
  /// used here -- an overlay narrows the gap between a surface and the text on
  /// it, which is the one thing this scheme exists to widen. The ladder here
  /// is five opaque steps, each re-measured.
  static const HabotColorScheme dark = HabotColorScheme(
    primary: Color(0xFFAFD2FF),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF003257),
    onPrimaryContainer: Color(0xFFDEEBFF),
    secondary: Color(0xFF9BE9EE),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF00363A),
    onSecondaryContainer: Color(0xFFD6F6F8),
    tertiary: Color(0xFFDCC6E8),
    onTertiary: Color(0xFF000000),
    tertiaryContainer: Color(0xFF3A2B45),
    onTertiaryContainer: Color(0xFFF1E6F6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF6B0007),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFE6E9EE),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF0A0C0E),
    surfaceContainer: Color(0xFF121417),
    surfaceContainerHigh: Color(0xFF1A1D21),
    surfaceContainerHighest: Color(0xFF23272B),
    outline: Color(0xFFD2D6DB),
    outlineVariant: Color(0xFF9AA0A6),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF000000),
  );

  /// Every scheme this project ships, keyed by the name the audit reports.
  ///
  /// Adding a scheme here is the only thing needed to bring it under the Step
  /// 96 audit, the Step 4 contrast engine and the Step 107 re-audit. That is
  /// the point of the shape being identical.
  static const Map<String, HabotColorScheme> allSchemes =
      <String, HabotColorScheme>{
        'light': HabotColors.light,
        'dark': HabotColors.dark,
        'highContrastLight': light,
        'highContrastDark': dark,
      };

  static const Map<String, HabotColorScheme> highContrastSchemes =
      <String, HabotColorScheme>{
        'highContrastLight': light,
        'highContrastDark': dark,
      };

  /// True when [a] and [b] declare exactly the same role names.
  ///
  /// This is what "pixel-perfect token alignment across modes" is read to
  /// mean, and it is checkable rather than aspirational.
  static bool rolesAlign(HabotColorScheme a, HabotColorScheme b) {
    final Set<String> ka = a.roles.keys.toSet();
    final Set<String> kb = b.roles.keys.toSet();
    return ka.length == kb.length && ka.containsAll(kb);
  }

  /// Role names present in [reference] but missing from [candidate].
  static List<String> missingRoles(
    HabotColorScheme reference,
    HabotColorScheme candidate,
  ) {
    final Set<String> have = candidate.roles.keys.toSet();
    return reference.roles.keys
        .where((String k) => !have.contains(k))
        .toList();
  }
}
