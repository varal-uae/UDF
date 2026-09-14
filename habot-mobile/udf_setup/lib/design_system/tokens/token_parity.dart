/// AISS Step 178 -- GEN-04528
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Validate visual output parity between token definitions and
///               Figma source components."
/// Metric: Design Token Adoption Rate -- Floor 0.9, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// **PARITY NEEDS TWO SIDES, AND FIGMA IS NOT ONE THIS BUILD CAN READ.** What
/// is checkable here is the same class of defect the row is about --
/// *definition does not equal output* -- on the pair this repository owns both
/// ends of: **the token as declared, and the colour a widget is actually
/// handed.**
///
/// **AND THAT PAIR CAN DIVERGE SILENTLY, WHICH IS WHY IT IS WORTH A STEP.**
/// `HabotTheme` builds its `ColorScheme` with `ColorScheme.fromSeed` and then
/// overrides each audited role with the exact brand token. A role that is
/// declared in `HabotColorScheme` but missed in that override list does not
/// fail, does not warn, and does not look wrong: it quietly resolves to
/// whatever the MD3 tonal algorithm produced from the seed. Every existing
/// check misses it — the Step 4 contrast audit reads `HabotColorScheme`, not
/// the built theme, so it audits the token that was declared rather than the
/// colour that shipped.
///
/// **THAT IS THE ONE DEFECT IN THIS BATCH NOTHING ELSE WOULD CATCH**, and it
/// is the same shape as the Step 174 duplicate-value finding: a value that is
/// wrong in a way every existing gate is looking past.
///
/// **"DESIGN TOKEN ADOPTION RATE" ALREADY HAS AN OWNER.** Step 60's
/// `HabotWidgetTokenAudit` measures how much of the widget layer sources its
/// values from tokens. This step does not re-measure that; it measures the
/// hop *before* it — whether the token a widget adopts is the token that was
/// declared. Both numbers are reported, because a codebase can score 1.0 on
/// adoption while adopting the wrong values.
library;

import 'package:flutter/material.dart';

import '../theme/habot_theme.dart';
import 'color_tokens.dart';

/// One role, compared across the boundary.
class HabotParityFinding {
  const HabotParityFinding({
    required this.role,
    required this.declared,
    required this.delivered,
  });

  final String role;

  /// What `HabotColorScheme` says, and what the Step 4 contrast audit read.
  final Color declared;

  /// What a widget is actually handed by the built theme.
  final Color delivered;

  @override
  String toString() =>
      '$role: declared ${_hex(declared)}, delivered ${_hex(delivered)}. The '
      'contrast audit read the declared value; the user saw the delivered '
      'one.';

  static String _hex(Color c) =>
      '0x${(c.toARGB32() & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

/// Compares what the token package declares with what the theme delivers.
class HabotTokenParity {
  const HabotTokenParity._();

  /// The delivered side: every audited role, read off a real `ColorScheme`.
  ///
  /// Written as an explicit map rather than by reflection so that a role added
  /// to `HabotColorScheme` and forgotten here is REPORTED as unwired rather
  /// than silently skipped -- the failure mode this step exists for.
  static Map<String, Color> deliveredRoles(ColorScheme s) => <String, Color>{
        'primary': s.primary,
        'onPrimary': s.onPrimary,
        'primaryContainer': s.primaryContainer,
        'onPrimaryContainer': s.onPrimaryContainer,
        'secondary': s.secondary,
        'onSecondary': s.onSecondary,
        'secondaryContainer': s.secondaryContainer,
        'onSecondaryContainer': s.onSecondaryContainer,
        'tertiary': s.tertiary,
        'onTertiary': s.onTertiary,
        'tertiaryContainer': s.tertiaryContainer,
        'onTertiaryContainer': s.onTertiaryContainer,
        'error': s.error,
        'onError': s.onError,
        'errorContainer': s.errorContainer,
        'onErrorContainer': s.onErrorContainer,
        'surface': s.surface,
        'onSurface': s.onSurface,
        'onSurfaceVariant': s.onSurfaceVariant,
        'surfaceContainerLowest': s.surfaceContainerLowest,
        'surfaceContainerLow': s.surfaceContainerLow,
        'surfaceContainer': s.surfaceContainer,
        'surfaceContainerHigh': s.surfaceContainerHigh,
        'surfaceContainerHighest': s.surfaceContainerHighest,
        'outline': s.outline,
        'outlineVariant': s.outlineVariant,
        'inverseSurface': s.inverseSurface,
        'onInverseSurface': s.onInverseSurface,
      };

  /// Roles declared in the token package but not read back from the built
  /// theme at all. A role nothing delivers is a token that does nothing.
  static List<String> unwiredRoles(
    HabotColorScheme declared,
    ColorScheme built,
  ) {
    final Map<String, Color> delivered = deliveredRoles(built);
    return declared.roles.keys
        .where((String role) => !delivered.containsKey(role))
        .toList();
  }

  /// Roles whose declared value is not the value a widget receives.
  ///
  /// **This is the finding.** A role missed in the theme's override list
  /// resolves to the MD3 tonal value derived from the seed, which is a valid
  /// Material colour, is not obviously wrong, and was never audited.
  static List<HabotParityFinding> drift(
    HabotColorScheme declared,
    ColorScheme built,
  ) {
    final Map<String, Color> delivered = deliveredRoles(built);
    final List<HabotParityFinding> out = <HabotParityFinding>[];
    for (final MapEntry<String, Color> e in declared.roles.entries) {
      final Color? got = delivered[e.key];
      if (got == null) {
        continue;
      }
      if (got.toARGB32() != e.value.toARGB32()) {
        out.add(
          HabotParityFinding(
            role: e.key,
            declared: e.value,
            delivered: got,
          ),
        );
      }
    }
    return out;
  }

  /// Every scheme the app ships, checked in one call.
  static List<HabotParityFinding> auditAll() => <HabotParityFinding>[
        ...drift(HabotColors.light, HabotTheme.light().colorScheme),
        ...drift(HabotColors.dark, HabotTheme.dark().colorScheme),
      ];

  // ---- the row's metric ---------------------------------------------------

  /// The share of declared roles that arrive at a widget unchanged.
  ///
  /// Read as parity rather than as adoption -- see the header. Adoption is
  /// Step 60's figure and answers a different question.
  static double parityRate(HabotColorScheme declared, ColorScheme built) {
    final int total = declared.roles.length;
    if (total == 0) {
      return 1;
    }
    final int bad =
        drift(declared, built).length + unwiredRoles(declared, built).length;
    return (total - (bad > total ? total : bad)) / total;
  }

  static double get overallParityRate {
    final double light =
        parityRate(HabotColors.light, HabotTheme.light().colorScheme);
    final double dark =
        parityRate(HabotColors.dark, HabotTheme.dark().colorScheme);
    return (light + dark) / 2;
  }

  static const double floor = 0.9;
  static const double optimal = 1.0;

  static String get qualitativeOutput {
    final double r = overallParityRate;
    if (r >= optimal) {
      return 'Complete';
    }
    return r >= floor ? 'Partial' : 'Not Complete';
  }

  static const String figmaBoundaryNote =
      'Parity needs two sides and Figma is not one this build can read. What '
      'is checked is the same class of defect on the pair this repository owns '
      'both ends of: the token as declared, and the colour a widget is '
      'actually handed.';

  static const String silentDriftNote =
      'A role declared in HabotColorScheme but missed in the theme\'s override '
      'list does not fail, does not warn, and does not look wrong: it resolves '
      'to whatever the MD3 tonal algorithm produced from the seed. The Step 4 '
      'contrast audit reads HabotColorScheme rather than the built theme, so '
      'it audits the token that was declared rather than the colour that '
      'shipped. Nothing else in this repository compares the two.';

  static const String adoptionIsAnotherNumberNote =
      'Step 60\'s HabotWidgetTokenAudit measures how much of the widget layer '
      'sources its values from tokens. This step measures the hop before it: '
      'whether the token a widget adopts is the token that was declared. A '
      'codebase can score 1.0 on adoption while adopting the wrong values, so '
      'both numbers are reported.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
