/// AISS GATE -- Step 74 of 80
/// Global Reference ID:       ARCPE-009-02
/// Atomic Steps Reference ID: ARCPE-009-02
/// Setup Step (Action):       "Set Context Pruning Warning Overlays"
/// Setup Step Description:    "Initialize an alert element layout layer
///                             designated as the warning overlay."
/// Metric: Touch Target Size & Accessibility Compliance --
///         Floor 44px / WCAG AA, Optimal 48px / WCAG AA, Ceiling 56px /
///         WCAG AAA. Standard: "Google Material Design 3 Accessibility
///         Guidelines; WCAG 2.1 AA (min. 4.5:1 contrast, 44-48dp touch
///         target)".
///
/// A SPARSE ROW, RECORDED: like Step 73, roughly twenty columns are empty. The
/// populated ones are the Setup Step, its Description, the metric row, and a
/// Data Requirement column that is half about this step and half about
/// something else:
///   coherent -- "Atomic-level data fields: Layout Type; Layout Grid
///     Dimensions; Spacing Rules; Alignment Settings; Layout Validation
///     Status"; "Educates users on AI limitations visually."
///   not this step -- "Standard progress bar with dynamic color shifting";
///     "CSS width transitions bound to token count state"; "Cost control and
///     hallucination prevention." Those describe a context-window meter, which
///     is a different component from the overlay that warns about it. Not
///     gated, and not quietly built as if it were the same thing.
///
/// THE METRIC IS A RESTATEMENT, AND IS GATED AS ONE. 44 / 48 / 56 is the touch
/// target standard TTMAC-011 already set and Step 10 already gated. Declaring
/// those numbers a second time is how two sources of truth start. So the
/// overlay reads `HabotDensity.minTouchTarget`, and G2 asserts the optimal
/// band EQUALS that token -- if Step 10's number ever moves, this gate fails
/// rather than silently disagreeing.
///
/// Same file as Step 73, because a warning layer and a critical layer that do
/// not share geometry will drift apart. Different gates, because the whole
/// point of the severity is that they behave differently.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/alert_panel.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredDismissSide = -1;

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

  group('ARCPE-009-02 :: the bands', () {
    gate(
      'ARCPE-009-02-G1',
      'Metric: Touch Target Size & Accessibility Compliance -- Floor "44px / '
          'WCAG AA", Optimal "48px / WCAG AA", Ceiling "56px / WCAG AAA".',
      'All three bands are declared and ordered, and a size is graded into the '
          'band it actually falls in rather than into pass or fail',
      () =>
          HabotAlertTouchTargets.floorPx == 44 &&
          HabotAlertTouchTargets.ceilingPx == 56 &&
          HabotAlertTouchTargets.floorPx < HabotAlertTouchTargets.optimalPx &&
          HabotAlertTouchTargets.optimalPx < HabotAlertTouchTargets.ceilingPx &&
          HabotAlertTouchTargets.bandFor(40) == 'below floor' &&
          HabotAlertTouchTargets.bandFor(44) == 'AA (floor)' &&
          HabotAlertTouchTargets.bandFor(48) == 'AA (optimal)' &&
          HabotAlertTouchTargets.bandFor(56) == 'AAA' &&
          !HabotAlertTouchTargets.meetsFloor(43) &&
          HabotAlertTouchTargets.meetsFloor(44) &&
          !HabotAlertTouchTargets.meetsOptimal(47),
    );

    gate(
      'ARCPE-009-02-G2',
      'THIS ROW RESTATES TTMAC-011, gated in Step 10. Recorded rather than '
          'declared twice: the optimal band must BE the existing token, not a '
          'second 48 written here.',
      'The optimal band is HabotDensity.minTouchTarget itself, so the two '
          'cannot drift apart -- if Step 10 moves its number, this gate fails',
      () => HabotAlertTouchTargets.optimalPx == HabotDensity.minTouchTarget,
    );
  });

  group('ARCPE-009-02 :: the layer', () {
    testWidgets('[ARCPE-009-02-G3] the overlay is a layer that takes the body '
        'and returns it wrapped, and disappears entirely when there is nothing '
        'to warn about', (WidgetTester tester) async {
      Future<void> pumpWith(String? message) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: HabotWarningOverlay(
                message: message,
                onDismiss: () {},
                child: const Center(child: Text('screen')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpWith(null);
      expect(
        find.byKey(HabotWarningOverlay.overlayKey),
        findsNothing,
        reason:
            'no message means no layer -- an empty warning strip is still a '
            'warning strip',
      );
      expect(find.text('screen'), findsOneWidget);

      await pumpWith('Older turns are being pruned to stay inside the '
          'context window.');
      expect(find.byKey(HabotWarningOverlay.overlayKey), findsOneWidget);
      expect(
        find.text('screen'),
        findsOneWidget,
        reason: 'the body is wrapped, not replaced',
      );

      final Rect overlay = tester.getRect(
        find.byKey(HabotWarningOverlay.overlayKey),
      );
      final Rect body = tester.getRect(find.text('screen'));
      expect(
        overlay.bottom,
        lessThanOrEqualTo(body.top),
        reason: 'the layer sits above the content it warns about',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'ARCPE-009-02-G3',
          requirementSource:
              'Setup Step Description: "Initialize an alert element LAYOUT '
              'LAYER designated as the warning overlay."',
          description:
              'The overlay wraps a body rather than sitting inside a screen: '
              'with no message it renders nothing at all, with one it sits '
              'above the content and the content is still there',
          passed: true,
        ),
      );
    });

    testWidgets('[ARCPE-009-02-G4] the dismiss control is measured against the '
        'bands, on the rendered widget', (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotWarningOverlay(
              message: 'Context pruning is active.',
              onDismiss: () => dismissed++,
              child: const Center(child: Text('screen')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect dismiss = tester.getRect(
        find.byKey(HabotWarningOverlay.dismissKey),
      );
      measuredDismissSide = dismiss.shortestSide;

      expect(
        HabotAlertTouchTargets.meetsFloor(measuredDismissSide),
        isTrue,
        reason:
            'measured ${measuredDismissSide.toStringAsFixed(1)}dp against a '
            '44dp floor',
      );
      expect(
        HabotAlertTouchTargets.meetsOptimal(measuredDismissSide),
        isTrue,
        reason: 'and against the 48dp optimal band',
      );

      await tester.tap(find.byKey(HabotWarningOverlay.dismissKey));
      await tester.pump();
      expect(dismissed, 1, reason: 'a warning IS dismissible -- unlike Step 73');
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'ARCPE-009-02-G4',
          requirementSource:
              'Metric: Touch Target Size & Accessibility Compliance, applied '
              'to the only control the overlay owns.',
          description:
              'The dismiss control is measured where it rendered and graded '
              'into a band, and it works -- a warning the user cannot clear '
              'would become permanent furniture',
          passed: true,
          detail:
              'measured ${measuredDismissSide.toStringAsFixed(1)}dp square, '
              'band ${HabotAlertTouchTargets.bandFor(measuredDismissSide)}',
        ),
      );
    });
  });

  tearDownAll(() {
    final String observed = measuredDismissSide < 0
        ? 'not measured'
        : '${measuredDismissSide.toStringAsFixed(1)}dp square, graded '
              '${HabotAlertTouchTargets.bandFor(measuredDismissSide)} -- '
              'measured on the rendered dismiss control, not read off a '
              'parameter';
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ARCPE-009-02',
        atomicStepReferenceId: 'ARCPE-009-02-A01',
        setupStepAction: 'Set Context Pruning Warning Overlays',
        implementationOrder: 74,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'full-width warning layer above the body, same geometry as the '
              'critical panel it shares a file with',
          'Layout Grid Dimensions':
              'stretches to the width of whatever it wraps; height follows the '
              'message, which wraps rather than truncating (Step 46)',
          'Spacing Rules': 'HabotSpacing.sm padding, from the spacing scale',
          'Alignment Settings':
              'message leading, dismiss trailing, both vertically centred',
          'Layout Validation Status': 'Derived from gate outcomes',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SPARSE ROW -- roughly twenty columns are empty; nothing was '
              'invented to fill them. HALF-RELEVANT COLUMN RECORDED: the Data '
              'Requirement mixes this overlay with a context-window meter '
              '("Standard progress bar with dynamic color shifting", "CSS '
              'width transitions bound to token count state"). That is a '
              'different component and was not built here. METRIC IS A '
              'RESTATEMENT of TTMAC-011 (Step 10): the optimal band reads the '
              'existing token instead of declaring 48 again, and G2 asserts '
              'the equality.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size & Accessibility Compliance',
            observed: observed,
            floor: '44px / WCAG AA',
            optimal: '48px / WCAG AA',
            ceiling: '56px / WCAG AAA',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/alert_panel.dart',
        ],
      ),
    );
  });
}
