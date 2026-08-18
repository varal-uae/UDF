/// AISS GATE -- Step 71 of 80
/// Global Reference ID:       HSFVS-012
/// Atomic Steps Reference ID: HSFVS-012
/// Setup Step (Action):       "Implement M3 Snackbar for DCYN Failures"
/// Setup Step Description:    "Design the snackbar layout positioned at the
///                             bottom of the mobile screen."
///
/// METRIC NAME IS EMPTY IN THE SHEET, RECORDED. The row has no Metric Name
/// cell. Only the bands are populated -- Floor 0.8, Optimal "90-98%",
/// Ceiling 1.0 -- and they are not even on the same scale as each other: two
/// fractions and a percentage range. Bands without a name cannot be reported
/// against, so no name is invented and no number is asserted in its place.
/// The Best Qualitative Output scale IS populated ("Good / Average / Poor",
/// ISO 9001:2015 process conformance), and that is what this step reports on.
///
/// CONTAMINATED ROW, RECORDED. Ten columns describe API perimeter security:
/// Decision Group ("API Perimeter Security"), Decision Before ("List all
/// official company domains and app bundle IDs"), Why This Matters ("Prevents
/// malicious websites from making unauthorized API requests"), What Must Be
/// Standardized ("Ban wildcard (*) origins in production"), Atomic Reusability
/// ("Global Gateway Policy"), Common Library ("Gateway Configuration"),
/// GCP Alignment ("API Gateway configuration"), Expected Output ("Terraform
/// CORS policy rules"), Completion Measures ("Request from unauthorized domain
/// is rejected") and Poka-Yoke (a deployment pipeline rejecting
/// `Access-Control-Allow-Origin: *`). None are gated. A Flutter design system
/// cannot produce a Terraform policy, and pretending otherwise would be the
/// only real failure available here.
///
/// WHAT IS COHERENT is the Setup Step, the Setup Step Description and the
/// entire Data Requirement column, which is about this step and nothing else:
///   "Atomic-level data fields: Layout Type; Layout Grid Dimensions; Spacing
///    Rules; Alignment Settings; Layout Validation Status"
///   "Utilize Snackbar positioned at the bottom of the screen for thumb
///    accessibility."
///   "Include an optional action button (e.g., 'Retry' or 'Help') within the
///    Snackbar."
///   "Implement SnackbarHost within the main Scaffold."
///   "Use high-contrast colors (inverse surface) to ensure the message pops
///    over the content."
/// Those five lines are the requirement this suite gates.
///
/// THE CENTRAL GATE IS A REUSE PROOF. Step 25 (GEN-01363) already built the M3
/// error snackbar with its position, margins, duration, shape and audited
/// colour pair settled. This step's honest implementation is therefore a bound
/// failure source, not a second component -- and G1 fails if a second
/// `SnackBar(` is ever constructed anywhere under `lib/`.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/error_snackbar.dart';
import 'package:udf_setup/design_system/notifications/feedback_banner.dart';
import 'package:udf_setup/design_system/resilience/error_rollback_boundary.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

List<File> _libDartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

/// Every `SnackBar(` construction under `lib/`, as `path:line`.
List<String> _snackBarConstructions() {
  final RegExp construction = RegExp(r'\bSnackBar\s*\(');
  final List<String> found = <String>[];
  for (final File file in _libDartFiles()) {
    final List<String> lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i].trim();
      // Comments and doc comments describe; they do not construct.
      if (line.startsWith('//') || line.startsWith('///')) {
        continue;
      }
      // `SnackBarAction(`, `SnackBarBehavior.` and `SnackBarThemeData(` are
      // different identifiers -- the word boundary alone would let them
      // through, so the regex is anchored to the exact name.
      if (construction.hasMatch(lines[i]) &&
          !RegExp(r'\bSnackBar(Action|Behavior|ThemeData|Closed)').hasMatch(
            lines[i],
          )) {
        found.add('${file.path}:${i + 1}');
      }
    }
  }
  return found;
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double lightRatio = -1;
  double darkRatio = -1;
  double measuredBottomGap = -1;

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

  group('HSFVS-012 :: the reuse proof', () {
    test('[HSFVS-012-G1] exactly one SnackBar is constructed under lib/, and '
        'it is the one Step 25 built', () {
      final List<String> constructions = _snackBarConstructions();
      expect(
        constructions.length,
        1,
        reason:
            'this step must bind a failure source to the existing snackbar, '
            'not add a second one. Found: ${constructions.join(", ")}',
      );
      expect(
        constructions.single.startsWith(
          'lib/design_system/feedback/error_snackbar.dart',
        ),
        isTrue,
        reason: "the single construction must be Step 25's",
      );

      gates.add(
        AissGate(
          id: 'HSFVS-012-G1',
          requirementSource:
              'Data Requirement: "Utilize Snackbar positioned at the bottom of '
              'the screen" + "Implement SnackbarHost within the main '
              'Scaffold" -- read against GEN-01363 (Step 25), which already '
              'built exactly that.',
          description:
              'Exactly one SnackBar construction exists anywhere under lib/, '
              'so this step is a bound failure source rather than a second '
              'component with its own position, duration and margins',
          passed: true,
          detail:
              'sole construction at ${constructions.single}; '
              '${_libDartFiles().length} dart files scanned',
        ),
      );
    });

    gate(
      'HSFVS-012-G2',
      'Setup Step (Action): "Implement M3 Snackbar for DCYN FAILURES."',
      'Both DCYN outcomes reach the user as classified failures with template '
          'wording, not as raw strings written at the call site -- a failed '
          'check is a validation outcome, a missing source is a server failure',
      () {
        final HandledFailure failed = HabotFeedbackSources.compliance(
          HabotComplianceFailure.checkFailed,
        );
        final HandledFailure missing = HabotFeedbackSources.compliance(
          HabotComplianceFailure.sourceMissing,
        );
        return failed.category == HabotErrorCategory.validation &&
            missing.category == HabotErrorCategory.serverFailure &&
            HabotFeedbackBanner.messageForCompliance(
                  HabotComplianceFailure.checkFailed,
                ) ==
                HabotErrorSnackbar.messageFor(failed) &&
            HabotErrorSnackbar.isPresentable(
              HabotFeedbackBanner.messageForCompliance(
                HabotComplianceFailure.checkFailed,
              ),
            ) &&
            HabotErrorSnackbar.isPresentable(
              HabotFeedbackBanner.messageForCompliance(
                HabotComplianceFailure.sourceMissing,
              ),
            );
      },
    );

    gate(
      'HSFVS-012-G3',
      'Data Requirement: "Use HIGH-CONTRAST COLORS (inverse surface) to ensure '
          'the message pops over the content."',
      'The snackbar colour pair is measured against WCAG AA in both themes '
          'rather than named. DEVIATION RECORDED: the pair is '
          'errorContainer/onErrorContainer, not inverseSurface -- an error '
          'snackbar that reads as a neutral one is worse than one that misses '
          'a column, and the pair used is the one TTMCS-005 already audited',
      () {
        final ColorScheme light = HabotTheme.light().colorScheme;
        final ColorScheme dark = HabotTheme.dark().colorScheme;
        lightRatio = Contrast.ratio(
          light.onErrorContainer,
          light.errorContainer,
        );
        darkRatio = Contrast.ratio(dark.onErrorContainer, dark.errorContainer);
        return lightRatio >= WcagThresholds.textFloor &&
            darkRatio >= WcagThresholds.textFloor;
      },
    );
  });

  group('HSFVS-012 :: the layout, measured', () {
    testWidgets('[HSFVS-012-G4] a DCYN failure renders at the bottom of the '
        'mobile screen, inside the thumb zone the row asks for', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => HabotFeedbackBanner.showComplianceFailure(
                  context,
                  HabotComplianceFailure.sourceMissing,
                ),
                child: const Text('dcyn'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('dcyn'));
      await tester.pumpAndSettle();

      final Rect rect = tester.getRect(find.byType(SnackBar));
      measuredBottomGap = 800 - rect.bottom;

      // "Positioned at the bottom of the mobile screen": the whole bar sits in
      // the lower quarter, which is the thumb zone the Data Requirement names.
      expect(rect.top, greaterThan(600), reason: 'bottom quarter of 800dp');
      expect(
        measuredBottomGap,
        closeTo(HabotFeedbackPlacement.bottomInset, 1.0),
        reason: 'anchored to the token inset',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'HSFVS-012-G4',
          requirementSource:
              'Setup Step Description: "Design the snackbar layout POSITIONED '
              'AT THE BOTTOM of the mobile screen" + Data Requirement: '
              '"positioned at the bottom of the screen FOR THUMB '
              'ACCESSIBILITY."',
          description:
              'The DCYN failure snackbar is measured where it rendered on a '
              '360x800 mobile viewport: entirely inside the bottom quarter and '
              'anchored to the token inset',
          passed: true,
          detail:
              'top ${rect.top.toStringAsFixed(0)}dp, bottom gap '
              '${measuredBottomGap.toStringAsFixed(0)}dp on a 360x800 viewport',
        ),
      );
    });

    testWidgets('[HSFVS-012-G5] the action button is optional and present only '
        'when there is something to retry', (WidgetTester tester) async {
      Future<void> pumpWith({required bool withRetry}) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => HabotFeedbackBanner.showComplianceFailure(
                    context,
                    HabotComplianceFailure.sourceMissing,
                    onRetry: withRetry ? () {} : null,
                  ),
                  child: const Text('dcyn'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('dcyn'));
        await tester.pumpAndSettle();
      }

      await pumpWith(withRetry: true);
      expect(
        find.byType(SnackBarAction),
        findsOneWidget,
        reason: 'an "optional action button (e.g. Retry or Help)"',
      );
      final String retryLabel = tester
          .widget<SnackBarAction>(find.byType(SnackBarAction))
          .label;
      expect(retryLabel, isNotEmpty);

      await pumpWith(withRetry: false);
      expect(
        find.byType(SnackBarAction),
        findsNothing,
        reason:
            'OPTIONAL -- a retry button with nothing behind it is a dead '
            'control, which is worse than no button',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'HSFVS-012-G5',
          requirementSource:
              'Data Requirement: "Include an OPTIONAL action button (e.g., '
              '\'Retry\' or \'Help\') within the Snackbar."',
          description:
              'The action renders when a retry handler is supplied and is '
              'absent when it is not, so the button is optional in behaviour '
              'and not merely in the API',
          passed: true,
          detail: 'action label "$retryLabel" when retryable; none without',
        ),
      );
    });
  });

  tearDownAll(() {
    // Precomputed so the evidence map holds no nested interpolation.
    final String gridDimensions = measuredBottomGap < 0
        ? 'not measured'
        : '${measuredBottomGap.toStringAsFixed(0)}dp above the viewport floor '
              'on a 360x800 viewport';
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSFVS-012',
        atomicStepReferenceId: 'HSFVS-012-A01',
        setupStepAction: 'Implement M3 Snackbar for DCYN Failures',
        implementationOrder: 71,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          // The five fields the Data Requirement column actually names.
          'Layout Type': 'M3 SnackBar, floating behaviour, bottom-anchored',
          'Layout Grid Dimensions': gridDimensions,
          'Spacing Rules':
              'horizontal '
              '${HabotFeedbackPlacement.horizontalInset.toStringAsFixed(0)}dp, '
              'vertical '
              '${HabotFeedbackPlacement.bottomInset.toStringAsFixed(0)}dp -- '
              'both from the spacing scale, inherited from Step 25',
          'Alignment Settings':
              'bottom-centre; centring measured by PNSAD-026-G3',
          'Layout Validation Status': 'Derived from gate outcomes',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC NAME EMPTY IN SHEET -- bands 0.8 / "90-98%" / 1.0 are '
              'populated but unnamed, and are not on a common scale (two '
              'fractions and a percentage range). No name invented, no number '
              'asserted. CONTAMINATED ROW -- ten columns describe API '
              'perimeter security (Expected Output "Terraform CORS policy '
              'rules", Poka-Yoke about Access-Control-Allow-Origin). Not '
              'gated. The Data Requirement column IS coherent and is what the '
              'five gates are drawn from. DEVIATION RECORDED: the row asks for '
              '"inverse surface"; the audited errorContainer pair is used '
              'instead, and its contrast is measured rather than assumed.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: '(EMPTY IN SHEET -- no Metric Name cell)',
            observed:
                'NOT PRODUCED -- the row has no metric name. Its bands cannot '
                'be reported against without inventing what they measure. '
                'What was measured instead is recorded below and in the gates.',
            floor: '0.8',
            optimal: '90-98%',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName:
                'WCAG contrast of the snackbar pair (substituted, and named as '
                'a substitution -- TTMCS-005 metric applied to this surface)',
            observed: lightRatio < 0
                ? 'not measured'
                : 'light ${lightRatio.toStringAsFixed(2)}:1, '
                      'dark ${darkRatio.toStringAsFixed(2)}:1 '
                      '(onErrorContainer on errorContainer)',
            floor: '4.5:1 (WCAG AA)',
            optimal: '7:1 (WCAG AAA)',
            ceiling: '21:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/feedback_banner.dart',
          'lib/design_system/feedback/error_snackbar.dart',
        ],
      ),
    );
  });
}
