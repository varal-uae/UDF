/// AISS GATE -- Step 70 of 80
/// Global Reference ID:       PNSAD-026
/// Atomic Steps Reference ID: PNSAD-026-A01
/// Setup Step (Action):       "Build Floating Bottom Snackbar Feedback
///                             Banner."
/// Setup Step Description:    "Apply CSS positioning rules to anchor the
///                             component to the bottom-center of the viewport
///                             (e.g. position: fixed; bottom: 16px;)."
/// Metric: UI Element Placement Accuracy (%) -- Floor 98.0, Optimal 99.9,
///         Ceiling 100.0.
///
/// CONTAMINATED ROW, RECORDED. Nine columns describe BigQuery row-level
/// security: Decision Before ("How are super-admin or cross-tenant reporting
/// roles handled within the RLS framework?"), Why This Matters ("Prevents
/// catastrophic data leaks in a SaaS environment"), Expected Output ("Enforced
/// RLS Policies"), Completion Measures ("A query run by Tenant A's service
/// account returns 0 rows belonging to Tenant B, even with a SELECT *
/// command"), UX Translation, Flow Impact, Dashboard Implication, What Must Be
/// Standardized and Atomic Reusability. None are gated.
///
/// The Setup Step, the Setup Step Description and the Metric are coherent --
/// and the metric fits this step EXACTLY, which is rare in this batch. Anchor
/// the component, then measure where it landed.
///
/// TRANSLATION, RECORDED: the description is written in CSS. This is Flutter,
/// so "position: fixed; bottom: 16px" becomes a floating SnackBarBehavior with
/// a bottom margin from the spacing scale -- which is what Step 25 already
/// configured. Stated rather than quietly performed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/error_snackbar.dart';
import 'package:udf_setup/design_system/notifications/feedback_banner.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredAccuracy = -1;

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

  group('PNSAD-026-A01 :: the placement policy', () {
    gate(
      'PNSAD-026-G1',
      'Setup Step Description: "anchor the component to the BOTTOM-CENTER of '
          'the viewport (e.g. position: fixed; BOTTOM: 16PX)."',
      'The bottom inset is the spacing token Step 25 already configured the '
          'snackbar with, not a 16 written again here, and the horizontal '
          'inset comes from the same scale',
      () =>
          HabotFeedbackPlacement.bottomInset ==
              HabotFeedback.snackbarVerticalMargin &&
          HabotFeedbackPlacement.horizontalInset ==
              HabotFeedback.snackbarHorizontalMargin &&
          HabotFeedbackPlacement.bottomInset > 0,
    );

    gate(
      'PNSAD-026-G2',
      'Metric: UI Element Placement Accuracy (%) -- Floor 98.0, Optimal 99.9, '
          'Ceiling 100.0.',
      'A perfectly anchored rect measures 100%, and the measure falls off with '
          'the error rather than being a pass/fail in disguise -- a banner '
          '100dp too high scores below the floor',
      () {
        const Size viewport = Size(360, 800);
        final double perfect = HabotFeedbackPlacement.accuracyFor(
          rendered: Rect.fromLTRB(
            16,
            800 - HabotFeedbackPlacement.bottomInset - 48,
            344,
            800 - HabotFeedbackPlacement.bottomInset,
          ),
          viewport: viewport,
        );
        final double tooHigh = HabotFeedbackPlacement.accuracyFor(
          rendered: const Rect.fromLTRB(16, 600, 344, 700),
          viewport: viewport,
        );
        final double offCentre = HabotFeedbackPlacement.accuracyFor(
          rendered: Rect.fromLTRB(
            60,
            800 - HabotFeedbackPlacement.bottomInset - 48,
            388,
            800 - HabotFeedbackPlacement.bottomInset,
          ),
          viewport: viewport,
        );
        return perfect == 100 &&
            HabotFeedbackPlacement.meetsOptimal(perfect) &&
            !HabotFeedbackPlacement.meetsFloor(tooHigh) &&
            !HabotFeedbackPlacement.meetsFloor(offCentre) &&
            HabotFeedbackPlacement.placementFloor == 98.0 &&
            HabotFeedbackPlacement.placementOptimal == 99.9;
      },
    );
  });

  group('PNSAD-026-A01 :: measured on screen', () {
    testWidgets('[PNSAD-026-G3] the rendered snackbar sits bottom-centre, and '
        'the accuracy is measured rather than asserted', (
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
                  HabotComplianceFailure.checkFailed,
                ),
                child: const Text('fail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('fail'));
      await tester.pumpAndSettle();

      final Finder bar = find.byType(SnackBar);
      expect(bar, findsOneWidget);
      final Rect rect = tester.getRect(bar);
      measuredAccuracy = HabotFeedbackPlacement.accuracyFor(
        rendered: rect,
        viewport: const Size(360, 800),
      );

      expect(
        rect.center.dx,
        closeTo(180, HabotFeedbackPlacement.centreToleranceDp),
        reason: 'bottom-CENTER',
      );
      expect(
        HabotFeedbackPlacement.meetsFloor(measuredAccuracy),
        isTrue,
        reason: 'measured ${measuredAccuracy.toStringAsFixed(2)}% against a '
            '98.0 floor',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'PNSAD-026-G3',
          requirementSource:
              'Setup Step Description + Metric: UI Element Placement Accuracy '
              '(%), Floor 98.0, Optimal 99.9.',
          description:
              'The rendered snackbar is measured where it actually landed: '
              'horizontally centred inside a 1dp tolerance and anchored to the '
              'bottom inset',
          passed: true,
          detail:
              'rect ${rect.left.toStringAsFixed(0)},'
              '${rect.top.toStringAsFixed(0)} to '
              '${rect.right.toStringAsFixed(0)},'
              '${rect.bottom.toStringAsFixed(0)} in a 360x800 viewport; '
              'accuracy ${measuredAccuracy.toStringAsFixed(2)}%',
        ),
      );
    });

    testWidgets('[PNSAD-026-G4] a bottom-anchored control is not covered by '
        'feedback about itself', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotFeedbackHost(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('submit'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect control = tester.getRect(find.text('submit'));
      expect(
        800 - control.bottom,
        greaterThanOrEqualTo(HabotSnackbarInsets.reservedBottomSpace - 1),
        reason: 'the host reserves the band the floating snackbar occupies',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'PNSAD-026-G4',
          requirementSource:
              'GEN-00055 (Step 21) reserved-space policy, applied to the '
              'floating banner this step positions.',
          description:
              'A control anchored to the bottom of a screen sits above the '
              'band the snackbar will occupy, so feedback never covers the '
              'thing it is about',
          passed: true,
          detail:
              'reserved '
              '${HabotSnackbarInsets.reservedBottomSpace.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PNSAD-026',
        atomicStepReferenceId: 'PNSAD-026-A01',
        setupStepAction: 'Build Floating Bottom Snackbar Feedback Banner.',
        implementationOrder: 70,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFeedbackPlacement / HabotErrorSnackbar',
          'Component Properties':
              'bottom inset '
              '${HabotFeedbackPlacement.bottomInset.toStringAsFixed(0)}dp, '
              'horizontal inset '
              '${HabotFeedbackPlacement.horizontalInset.toStringAsFixed(0)}dp, '
              'floating behaviour -- all inherited from Step 25',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED ROW -- nine columns describe BigQuery row-level '
              'security (Expected Output "Enforced RLS Policies", Completion '
              'Measures about tenant isolation). Not gated. The Setup Step, '
              'the Description and the Metric are coherent, and the metric '
              'fits this step exactly. TRANSLATION RECORDED: the CSS in the '
              'description becomes a floating SnackBarBehavior with a token '
              'bottom margin.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Element Placement Accuracy (%)',
            observed: measuredAccuracy < 0
                ? 'not measured'
                : '${measuredAccuracy.toStringAsFixed(2)}% -- measured on the '
                      'rendered rect in a 360x800 viewport, horizontally '
                      'centred within 1dp and anchored to the bottom inset',
            floor: '98.0',
            optimal: '99.9',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/feedback_banner.dart',
        ],
      ),
    );
  });
}
