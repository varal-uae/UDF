/// AISS GATE -- Step 109 of 115
/// Global Reference ID:       GEN-00179
/// Atomic Steps Reference ID: GEN-00179-A01
/// Setup Step (Action):       "Place the recovery action button in a clear,
///                             thumb-accessible mobile screen position."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED: "General Task Completion Quality" is generic
/// project tracking on a step that names a specific, measurable property. It
/// is reported as NOT PRODUCED. What is gated is the placement, measured
/// against the Step 39 thumb-band geometry and the Step 108 reach model.
library;

import 'dart:ui' show Rect, Size;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/semantic_hints.dart';
import 'package:udf_setup/design_system/interaction/recovery_action_placement.dart';
import 'package:udf_setup/design_system/interaction/tap_accuracy.dart';
import 'package:udf_setup/design_system/interaction/touch_target.dart';
import 'package:udf_setup/design_system/shell/dashboard_grid.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void record(String id, String source, String description, bool passed) {
    gates.add(
      AissGate(
        id: id,
        requirementSource: source,
        description: description,
        passed: passed,
      ),
    );
  }

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  void widgetGate(
    String id,
    String source,
    String description,
    Future<bool> Function(WidgetTester tester) run,
  ) {
    testWidgets('[$id] $description', (WidgetTester tester) async {
      bool passed = false;
      try {
        passed = await run(tester);
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  const Size viewport = Size(393, 851);

  group('GEN-00179-A01 :: the placement rule', () {
    gate(
      'GEN-00179-G1',
      'Setup Step (Action): "in a clear, THUMB-ACCESSIBLE mobile screen '
          'position". Step 39 already defines reachable.',
      'A control inside the Step 39 thumb band is accepted and one above it '
          'is refused, with the refusal naming where the band starts -- and '
          '"reachable" is delegated to Step 39 rather than redefined',
      () {
        final HabotPlacementResult good = HabotRecoveryPlacement.evaluate(
          control: const Rect.fromLTWH(160, 760, 72, 56),
          viewport: viewport,
          grip: HabotGrip.rightThumb,
        );
        final HabotPlacementResult bad = HabotRecoveryPlacement.evaluate(
          control: const Rect.fromLTWH(160, 80, 72, 56),
          viewport: viewport,
          grip: HabotGrip.rightThumb,
        );
        return good.acceptable &&
            !bad.acceptable &&
            bad.defects.contains(HabotPlacementDefect.outsideThumbBand) &&
            bad.detail.contains('thumb band') &&
            HabotDashboardGrid.isWithinThumbZone(760, viewport.height);
      },
    );

    gate(
      'GEN-00179-G2',
      'Step 108: a compliant 48dp control is still missed out of reach.',
      'A control pushed to a position the model cannot reach is required to '
          'be LARGER, so a bad placement grows the target rather than quietly '
          'becoming harder to hit',
      () {
        final HabotPlacementResult natural = HabotRecoveryPlacement.evaluate(
          control: const Rect.fromLTWH(160, 760, 48, 48),
          viewport: viewport,
          grip: HabotGrip.rightThumb,
        );
        final HabotPlacementResult far = HabotRecoveryPlacement.evaluate(
          control: const Rect.fromLTWH(8, 40, 48, 48),
          viewport: viewport,
          grip: HabotGrip.rightThumb,
        );
        return natural.requiredSizeDp == TouchTargetPolicy.minimumDp &&
            far.band == HabotReachBand.outOfReach &&
            far.requiredSizeDp > TouchTargetPolicy.minimumDp &&
            far.defects.contains(HabotPlacementDefect.belowRequiredSize);
      },
    );

    gate(
      'GEN-00179-G3',
      'A user who has just lost work, reaching one-handed, must not have '
          '"Discard" within a thumb wobble of "Retry".',
      'A destructive neighbour needs twice the Step 10 safety margin, and a '
          'placement that breaches it is refused with the measured gap named',
      () {
        final HabotPlacementResult tooClose =
            HabotRecoveryPlacement.evaluate(
              control: const Rect.fromLTWH(160, 760, 72, 56),
              viewport: viewport,
              grip: HabotGrip.rightThumb,
              destructiveNeighbours: <Rect>[
                Rect.fromLTWH(236, 760, 72, 56),
              ],
            );
        final HabotPlacementResult farEnough =
            HabotRecoveryPlacement.evaluate(
              control: const Rect.fromLTWH(160, 760, 72, 56),
              viewport: viewport,
              grip: HabotGrip.rightThumb,
              destructiveNeighbours: <Rect>[
                Rect.fromLTWH(260, 760, 72, 56),
              ],
            );
        return HabotRecoveryPlacement.destructiveClearanceDp ==
                TouchTargetPolicy.safetyMarginDp * 2 &&
            tooClose.defects.contains(
              HabotPlacementDefect.tooCloseToDestructive,
            ) &&
            tooClose.detail.contains('destructive') &&
            farEnough.acceptable;
      },
    );
  });

  group('GEN-00179-A01 :: the control itself', () {
    widgetGate(
      'GEN-00179-G4',
      'A rule in a review comment is a rule that gets forgotten.',
      'The widget has no alignment parameter: it anchors bottom-centre by '
          'construction, so a caller cannot place the recovery control in the '
          'top-left corner',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: HabotRecoveryAction(label: 'Retry', onPressed: () {}),
            ),
          ),
        );
        final Align align = tester.widget<Align>(
          find
              .descendant(
                of: find.byType(HabotRecoveryAction),
                matching: find.byType(Align),
              )
              .first,
        );
        final Rect box = tester.getRect(
          find.byKey(HabotRecoveryAction.actionKey),
        );
        final Size screen = tester.view.physicalSize /
            tester.view.devicePixelRatio;
        return align.alignment == Alignment.bottomCenter &&
            HabotDashboardGrid.isWithinThumbZone(box.top, screen.height);
      },
    );

    widgetGate(
      'GEN-00179-G5',
      'Bottom-RIGHT is comfortable for a right thumb and a stretch for a left '
          'one. This is the control a left-handed user reaches for at the '
          'worst moment.',
      'The anchor is bottom-CENTRE, which is inside the natural reach band '
          'for both hands on this viewport',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: HabotRecoveryAction(label: 'Retry', onPressed: () {}),
            ),
          ),
        );
        final Rect box = tester.getRect(
          find.byKey(HabotRecoveryAction.actionKey),
        );
        final Size screen = tester.view.physicalSize /
            tester.view.devicePixelRatio;
        return HabotTapAccuracy.bandFor(
              box.center,
              HabotGrip.rightThumb,
              screen,
            ) ==
                HabotReachBand.natural &&
            HabotTapAccuracy.bandFor(
                  box.center,
                  HabotGrip.leftThumb,
                  screen,
                ) ==
                HabotReachBand.natural;
      },
    );

    widgetGate(
      'GEN-00179-G6',
      'Step 99: a recovery control must say what pressing it does, because '
          'the user reaching for it has just had something go wrong.',
      'The control carries the Step 99 retry hint and fires its callback',
      (WidgetTester tester) async {
        int pressed = 0;
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: HabotRecoveryAction(
                  label: 'Retry',
                  onPressed: () => pressed++,
                ),
              ),
            ),
          );
          final SemanticsNode node = tester.getSemantics(
            find.byType(HabotHintedAction),
          );
          final bool announces =
              node.label == 'Retry' &&
              node.hint == HabotHints.of(HabotActionKind.retryFailed).hint;
          await tester.tap(find.byKey(HabotRecoveryAction.actionKey));
          await tester.pump();
          return announces &&
              pressed == 1 &&
              HabotRecoveryAction.minimumSizeDp >= TouchTargetPolicy.minimumDp;
        } finally {
          handle.dispose();
        }
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00179',
        atomicStepReferenceId: 'GEN-00179-A01',
        setupStepAction:
            'Place the recovery action button in a clear, thumb-accessible '
            'mobile screen position.',
        implementationOrder: 109,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotRecoveryPlacement / HabotRecoveryAction',
          'Component Properties':
              'anchored bottom-centre with no alignment parameter; minimum '
              '${HabotRecoveryAction.minimumSizeDp}dp; destructive clearance '
              '${HabotRecoveryPlacement.destructiveClearanceDp}dp (twice the '
              'Step 10 margin); reach band from Step 108, thumb band from '
              'Step 39',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row, and the metric is generic '
              'project tracking.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Recovery control position, measured on the rendered '
                'widget',
            observed:
                'Inside the Step 39 thumb band and inside the natural reach '
                'band for BOTH grips. Bottom-centre rather than '
                'bottom-right, because bottom-right is a stretch for a left '
                'thumb and this is the control reached for at the worst '
                'moment.',
            floor: 'inside the thumb band',
            optimal: 'natural reach band, both grips',
            ceiling: 'natural reach band, both grips',
          ),
          const AissMeasurement(
            metricName: 'General Task Completion Quality (the sheet metric)',
            observed:
                'NOT PRODUCED. It is generic project tracking -- "task '
                'completed with documented exceptions" -- on a step that '
                'names a specific geometric property. The property is what '
                'was measured; no completion-quality figure is invented.',
            floor: 'Task completed with documented exceptions',
            optimal: '100% completion matching stated implementation-step '
                'intent',
            ceiling: '100%',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/recovery_action_placement.dart',
        ],
      ),
    );
  });
}
