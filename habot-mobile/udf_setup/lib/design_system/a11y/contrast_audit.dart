/// AISS: TTMCS-004-A01 completion measure -- "Automated verification confirming
/// a minimum 4.5:1 contrast ratio across all dynamic layout color pairs."
/// AISS: TTMCS-005-A01 poka-yoke -- "Build validation blocks compilation if
/// color ratios test below a hard 4.5:1 ratio threshold."
///
/// This file is the executable form of both requirements. It enumerates every
/// meaningful token pair in both schemes and grades it. `flutter test` runs it;
/// `tool/verify_aiss.sh` fails the build on any FAIL.
library;

import 'dart:ui' show Color;

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import 'contrast.dart';

/// A pair the audit must check, declared once and reused across both schemes.
class AuditPair {
  const AuditPair(this.foreground, this.background, {this.isText = true});

  final String foreground;
  final String background;
  final bool isText;
}

class ContrastAudit {
  const ContrastAudit._();

  /// Text pairs -- gated at 4.5:1 (AA floor), 7:1 is the stated optimum.
  static const List<AuditPair> textPairs = <AuditPair>[
    AuditPair('onPrimary', 'primary'),
    AuditPair('onPrimaryContainer', 'primaryContainer'),
    AuditPair('onSecondary', 'secondary'),
    AuditPair('onSecondaryContainer', 'secondaryContainer'),
    AuditPair('onTertiary', 'tertiary'),
    AuditPair('onTertiaryContainer', 'tertiaryContainer'),
    AuditPair('onError', 'error'),
    AuditPair('onErrorContainer', 'errorContainer'),
    AuditPair('onSurface', 'surface'),
    AuditPair('onSurfaceVariant', 'surface'),
    AuditPair('onSurface', 'surfaceContainerLowest'),
    AuditPair('onSurface', 'surfaceContainerLow'),
    AuditPair('onSurface', 'surfaceContainer'),
    AuditPair('onSurface', 'surfaceContainerHigh'),
    AuditPair('onSurface', 'surfaceContainerHighest'),
    AuditPair('onInverseSurface', 'inverseSurface'),
  ];

  /// Meaning-bearing non-text pairs -- gated at 3:1 (WCAG 2.1 SC 1.4.11).
  static const List<AuditPair> nonTextPairs = <AuditPair>[
    AuditPair('outline', 'surface', isText: false),
    AuditPair('primary', 'surface', isText: false),
  ];

  /// Documented exemption. `outlineVariant` is MD3's decorative divider tint.
  /// SC 1.4.11 covers graphical objects *required to understand content*; a
  /// divider never carries meaning on its own, and the meaning-bearing boundary
  /// token (`outline`) is gated above. Recorded here rather than silently
  /// omitted so a reviewer can challenge the call.
  static const List<String> decorativeExempt = <String>['outlineVariant'];

  static const String decorativeExemptRationale =
      'WCAG 2.1 SC 1.4.11 applies to graphical objects required to understand '
      'content. outlineVariant is MD3 decorative divider tint and is never the '
      'sole carrier of meaning; the meaning-bearing boundary token is "outline", '
      'gated at 3.0:1.';

  static List<ContrastResult> auditScheme(
    String schemeName,
    HabotColorScheme scheme,
  ) {
    final Map<String, Color> roles = scheme.roles;
    final List<ContrastResult> results = <ContrastResult>[];

    for (final AuditPair pair in <AuditPair>[...textPairs, ...nonTextPairs]) {
      final Color? fg = roles[pair.foreground];
      final Color? bg = roles[pair.background];
      if (fg == null || bg == null) {
        throw StateError(
          'Audit pair references an unknown role in $schemeName: '
          '${pair.foreground} / ${pair.background}',
        );
      }
      results.add(
        Contrast.evaluate(
          foregroundName: '$schemeName.${pair.foreground}',
          backgroundName: '$schemeName.${pair.background}',
          foreground: fg,
          background: bg,
          isText: pair.isText,
        ),
      );
    }
    return results;
  }

  /// TTMCS-005 specifically: body text must stay legible on every rung of the
  /// dark elevation ladder, including level 5 which no ColorScheme role exposes.
  static List<ContrastResult> auditDarkElevationLadder() {
    return HabotElevationLevel.values.map((HabotElevationLevel level) {
      return Contrast.evaluate(
        foregroundName: 'dark.onSurface',
        backgroundName: 'dark.elevation.${level.name}',
        foreground: HabotColors.dark.onSurface,
        background: HabotElevation.darkSurfaceFor(level),
      );
    }).toList();
  }

  /// Everything, in one call. This is what the gate asserts on.
  static List<ContrastResult> auditAll() => <ContrastResult>[
    ...auditScheme('light', HabotColors.light),
    ...auditScheme('dark', HabotColors.dark),
    ...auditDarkElevationLadder(),
  ];

  static List<ContrastResult> failures() =>
      auditAll().where((ContrastResult r) => !r.passes).toList();

  /// Human-readable report, written to `build/aiss/contrast_audit.txt` by the
  /// gate so there is a durable artefact per run.
  static String report() {
    final List<ContrastResult> all = auditAll();
    final int failed = all.where((ContrastResult r) => !r.passes).length;
    final int aaa = all
        .where((ContrastResult r) => r.grade == ContrastGrade.aaa)
        .length;
    final double worst = all
        .map((ContrastResult r) => r.ratio)
        .reduce((double a, double b) => a < b ? a : b);

    final StringBuffer buffer = StringBuffer()
      ..writeln('HABOT DESIGN SYSTEM -- WCAG CONTRAST AUDIT')
      ..writeln('AISS gates: TTMCS-004-A01, TTMCS-005-A01')
      ..writeln('Text floor ${WcagThresholds.textFloor}:1  '
          'optimal ${WcagThresholds.textOptimal}:1  '
          'non-text floor ${WcagThresholds.nonTextFloor}:1')
      ..writeln('Decorative exemptions: ${decorativeExempt.join(", ")}')
      ..writeln('  rationale: $decorativeExemptRationale')
      ..writeln('-' * 78);

    for (final ContrastResult r in all) {
      buffer.writeln('  $r');
    }

    buffer
      ..writeln('-' * 78)
      ..writeln('pairs=${all.length}  AAA=$aaa  '
          'worst=${worst.toStringAsFixed(2)}:1  FAILURES=$failed')
      ..writeln(failed == 0 ? 'RESULT: PASS' : 'RESULT: FAIL');
    return buffer.toString();
  }
}
