/// AISS GATE -- Step 4 of 10
/// Global Reference ID:      TTMCS-005
/// Atomic Steps Reference ID: TTMCS-005-A01
/// Setup Step (Action):      "Mobile Dark Mode Contrast Enforcement"
///
/// Poka-Yoke from the sheet: "Build validation blocks compilation if color
/// ratios test below a hard 4.5:1 ratio threshold."
/// Metric: WCAG Colour Contrast Ratio -- Floor 4.5:1, Optimal 7:1.
/// Best Qualitative Output: Pass / Fail.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/a11y/contrast_audit.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/theme/habot_theme_extension.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/elevation_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('TTMCS-005-A01 :: dark mode contrast enforcement', () {
    // ---- Substep 1: surface elevation tokens ------------------------------
    gate(
      'TTMCS-005-G1',
      '4 Substeps #1: "Surface elevation tokens." + TTMCS-004 UX Decision: '
          '"Utilize structural elevation overlays instead of deep drop shadows '
          'to indicate component layering in dark configurations."',
      'Dark ladder is strictly lightening across all 6 levels (layering is '
          'readable without any shadow)',
      () {
        double previous = -1;
        for (final HabotElevationLevel level in HabotElevationLevel.values) {
          final double luminance = Contrast.relativeLuminance(
            HabotElevation.darkSurfaceFor(level),
          );
          if (luminance <= previous) {
            return false;
          }
          previous = luminance;
        }
        return true;
      },
    );

    gate(
      'TTMCS-005-G2',
      'Atomic Reusability: "Centralized design token parameters managed by a '
          'Theme Provider Component stored in the UI Core Lib."',
      'Committed dark surface literals re-derive exactly from the documented '
          'overlay alphas (no hand-edited drift)',
      () {
        for (final HabotElevationLevel level in HabotElevationLevel.values) {
          final Color committed = HabotElevation.darkSurfaceFor(level);
          final Color derived = HabotElevation.deriveDarkSurface(level);
          if (committed.toARGB32() != derived.toARGB32()) {
            return false;
          }
        }
        return true;
      },
    );

    // ---- Substep 2: text contrast thresholds ------------------------------
    gate(
      'TTMCS-005-G3',
      'Poka-Yoke: "Build validation blocks compilation if color ratios test '
          'below a hard 4.5:1 ratio threshold." + Metric Floor 4.5:1.',
      'Body text clears the 4.5:1 floor on every rung of the dark elevation '
          'ladder, including level 5',
      () {
        for (final ContrastResult result
            in ContrastAudit.auditDarkElevationLadder()) {
          if (result.ratio < WcagThresholds.textFloor) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'TTMCS-005-G4',
      'Metric row: Optimal Target "7:1 (WCAG 2.1 Level AAA target)".',
      'Every rung of the dark ladder also clears the 7:1 AAA optimum',
      () {
        for (final ContrastResult result
            in ContrastAudit.auditDarkElevationLadder()) {
          if (result.ratio < WcagThresholds.textOptimal) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'TTMCS-005-G5',
      'Metric row: Ceiling "No upper bound required -- avoid glare/over-contrast '
          'beyond 21:1".',
      'No audited pair exceeds the physical 21:1 maximum',
      () {
        for (final ContrastResult result in ContrastAudit.auditAll()) {
          if (result.ratio > 21.0001) {
            return false;
          }
        }
        return true;
      },
    );

    // ---- Substep 3: brand colour adjustments ------------------------------
    gate(
      'TTMCS-005-G6',
      '4 Substeps #3: "Brand color adjustments."',
      'Brand roles are re-toned for dark rather than reused from light',
      () {
        return HabotColors.dark.primary != HabotColors.light.primary &&
            HabotColors.dark.secondary != HabotColors.light.secondary &&
            HabotColors.dark.error != HabotColors.light.error &&
            // A dark-scheme brand colour must be light enough to read on the
            // dark surface.
            Contrast.ratio(
                  HabotColors.dark.primary,
                  HabotColors.dark.surface,
                ) >=
                WcagThresholds.nonTextFloor;
      },
    );

    // ---- No drop shadows in dark ------------------------------------------
    gate(
      'TTMCS-005-G7',
      'TTMCS-004 UX Decision: elevation overlays "instead of deep drop shadows" '
          'in dark configurations.',
      'Dark theme suppresses shadow colour and enables the elevation overlay',
      () {
        final ThemeData dark = HabotTheme.dark();
        final ThemeData light = HabotTheme.light();
        return dark.shadowColor.a == 0.0 &&
            dark.applyElevationOverlayColor &&
            light.shadowColor.a > 0.0;
      },
    );

    // ---- Theme provider carries the ladder --------------------------------
    gate(
      'TTMCS-005-G8',
      'Expected Output: "CSS Token Variables" (Flutter equivalent: the typed '
          'ThemeExtension carried on ThemeData).',
      'HabotTokens exposes the correct ladder for each brightness',
      () {
        final HabotTokens dark = HabotTokens.forBrightness(Brightness.dark);
        final HabotTokens light = HabotTokens.forBrightness(Brightness.light);
        for (final HabotElevationLevel level in HabotElevationLevel.values) {
          if (dark.surfaceAt(level) !=
                  HabotElevation.darkSurfaceLadder[level] ||
              light.surfaceAt(level) !=
                  HabotElevation.lightSurfaceLadder[level]) {
            return false;
          }
        }
        // Dark page frame must be flat, not a light wash (OLED power).
        return dark.pageFrameStart == dark.pageFrameEnd &&
            light.pageFrameStart != light.pageFrameEnd;
      },
    );
  });

  test('contrast audit report is written for the record', () {
    final String report = ContrastAudit.report();
    expect(report, contains('RESULT: PASS'));
    try {
      final Directory dir = Directory('build/aiss');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      File('build/aiss/contrast_audit.txt').writeAsStringSync(report);
    } on FileSystemException catch (e) {
      stderr.writeln('AISS: could not write contrast_audit.txt ($e)');
    }
  });

  tearDownAll(() {
    final List<ContrastResult> ladder = ContrastAudit.auditDarkElevationLadder();
    final double worstRung = ladder
        .map((ContrastResult r) => r.ratio)
        .reduce((double a, double b) => a < b ? a : b);
    final bool allPass = ContrastAudit.failures().isEmpty;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TTMCS-005',
        atomicStepReferenceId: 'TTMCS-005-A01',
        setupStepAction: 'Mobile Dark Mode Contrast Enforcement',
        implementationOrder: 4,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Definition Name': 'Habot dark surface elevation ladder',
          'Definition Parameters':
              'levels 0-5; overlay alpha 0.00/0.05/0.08/0.11/0.12/0.14 of '
              'dark.primary over dark.surface',
          'Definition Type': 'Design token set (ThemeExtension: HabotTokens)',
          'Validation Status': allPass ? 'Validated' : 'Rejected',
          'Definition ID': 'TTMCS-005-A01/dark-elevation-ladder',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'WCAG Colour Contrast Ratio (dark elevation ladder)',
            observed:
                'worst rung ${worstRung.toStringAsFixed(2)}:1 '
                'across ${ladder.length} levels',
            floor: '4.5:1 (WCAG 2.1 Level AA minimum for normal text)',
            optimal: '7:1 (WCAG 2.1 Level AAA target)',
            ceiling:
                'No upper bound required -- avoid glare/over-contrast beyond 21:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/elevation_tokens.dart',
          'lib/design_system/theme/habot_theme_extension.dart',
          'lib/design_system/a11y/contrast_audit.dart',
          'build/aiss/contrast_audit.txt',
        ],
      ),
    );
  });
}
