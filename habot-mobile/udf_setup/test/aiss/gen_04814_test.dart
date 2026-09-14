/// AISS GATE -- Step 193 of 195
/// Global Reference ID:       GEN-04814
/// Atomic Steps Reference ID: GEN-04814
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 1: Position M3 Extended FAB in the primary
///               thumb zone (bottom-right on portrait viewports)."
/// Metric: Substep Definition-of-Done Adherence Rate -- Floor ">=90% unit test
///         coverage / acceptance criteria met before merge", Optimal "95-100%
///         coverage, all acceptance criteria met", Ceiling "100%".
///         Complete / Partial / Not Complete.
///
/// "BOTTOM-RIGHT" ASSUMES TWO THINGS AND ONE OF THEM THE APP CANNOT KNOW. The
/// locale is knowable and is honoured; handedness is not, and that is recorded
/// as a limitation with the mitigation that exists rather than as a solved
/// problem.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/interaction/fab_thumb_zone.dart';
import 'package:udf_setup/design_system/interaction/keyboard_aware_fab.dart';
import 'package:udf_setup/design_system/layout/bottom_action_bar.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  const HabotWindowInsets gestureBarOnly = HabotWindowInsets(
    viewPaddingBottom: 34,
    viewInsetsBottom: 0,
  );
  const HabotWindowInsets keyboardOpen = HabotWindowInsets(
    viewPaddingBottom: 34,
    viewInsetsBottom: 336,
  );

  group('GEN-04814 :: a direction, not a side', () {
    gate(
      'GEN-04814-G1',
      'Atomic Step: "...in the primary thumb zone (BOTTOM-RIGHT on portrait '
          'viewports)." MD3 anchors the FAB to the trailing edge in reading '
          'order.',
      'The anchor is the bottom trailing corner and resolves to the right in '
          'English and the left in Urdu -- so the row\'s wording is satisfied '
          'where it was written and is satisfied correctly where it was not',
      () =>
          HabotFabThumbZone.anchor == HabotFabAnchor.bottomTrailing &&
          HabotFabThumbZone.sideFor(
                HabotFabAnchor.bottomTrailing,
                HabotTextDirectionality.leftToRight,
              ) ==
              HabotScreenSide.right &&
          HabotFabThumbZone.sideFor(
                HabotFabAnchor.bottomTrailing,
                HabotTextDirectionality.rightToLeft,
              ) ==
              HabotScreenSide.left &&
          HabotFabThumbZone.literalRightIsCorrect(
            HabotTextDirectionality.leftToRight,
          ) &&
          !HabotFabThumbZone.literalRightIsCorrect(
            HabotTextDirectionality.rightToLeft,
          ) &&
          HabotFabThumbZone.directionNote.contains('Third occurrence'),
    );

    gate(
      'GEN-04814-G2',
      'A centre-docked FAB is a different MD3 pattern, not a variation on the '
          'default.',
      'The alternative anchors are declared so that choosing one is a decision '
          'rather than a mistake, and the centre anchor resolves to neither '
          'side in either direction',
      () =>
          HabotFabAnchor.values.length == 3 &&
          HabotScreenSide.values.length == 3 &&
          HabotFabThumbZone.sideFor(
                HabotFabAnchor.bottomCentre,
                HabotTextDirectionality.leftToRight,
              ) ==
              HabotScreenSide.centre &&
          HabotFabThumbZone.sideFor(
                HabotFabAnchor.bottomCentre,
                HabotTextDirectionality.rightToLeft,
              ) ==
              HabotScreenSide.centre &&
          HabotFabThumbZone.sideFor(
                HabotFabAnchor.bottomLeading,
                HabotTextDirectionality.leftToRight,
              ) ==
              HabotScreenSide.left,
    );

    gate(
      'GEN-04814-G3',
      '"Around one person in ten is left-handed. The platform does not expose '
          'handedness and this app does not ask."',
      'The limitation is stated rather than implied, with the mitigation that '
          'actually exists -- every action reachable from a FAB is also '
          'reachable from the screen\'s own content, so an unreachable corner '
          'inconveniences rather than blocks',
      () =>
          HabotFabThumbZone.handednessLimitation.contains('one person in ten') &&
          HabotFabThumbZone.handednessLimitation
              .contains('never the only route') &&
          HabotFabThumbZone.handednessLimitation
              .contains('inconvenienced rather than blocked') &&
          HabotFabThumbZone.fabIsNeverTheOnlyRoute,
    );
  });

  group('GEN-04814 :: the corner it shares', () {
    gate(
      'GEN-04814-G4',
      '"A bottom action bar with a confirm button and a FAB in the same corner '
          'are two primary actions on one screen."',
      'The two cannot coexist, and the rule is expressed as something a '
          'composition can be checked against rather than as guidance',
      () =>
          !HabotFabThumbZone.mayCoexistWithBottomBar &&
          !HabotFabThumbZone.compositionIsValid(
            hasFab: true,
            hasBottomActionBar: true,
          ) &&
          HabotFabThumbZone.compositionIsValid(
            hasFab: true,
            hasBottomActionBar: false,
          ) &&
          HabotFabThumbZone.compositionIsValid(
            hasFab: false,
            hasBottomActionBar: true,
          ) &&
          HabotFabThumbZone.compositionIsValid(
            hasFab: false,
            hasBottomActionBar: false,
          ) &&
          HabotFabThumbZone.onePrimaryActionNote
              .contains('at least one of them is not primary'),
    );

    gate(
      'GEN-04814-G5',
      'Step 154 owns the keyboard behaviour: the FAB leaves the tree when the '
          'keyboard opens.',
      'This step places the FAB and does not get a second opinion about when '
          'it exists -- presence is read from the Step 154 rule, and the '
          'anchor clears the system gesture area rather than chasing the '
          'keyboard',
      () =>
          HabotFabThumbZone.isPresent(gestureBarOnly) &&
          !HabotFabThumbZone.isPresent(keyboardOpen) &&
          HabotKeyboardAwareFab.hidesOnKeyboardAlways &&
          HabotFabThumbZone.bottomOffsetFor(gestureBarOnly) ==
              gestureBarOnly.viewPaddingBottom +
                  HabotFabThumbZone.edgeMargin &&
          HabotFabThumbZone.bottomOffsetFor(gestureBarOnly) == 50 &&
          HabotFabThumbZone.edgeMargin == HabotSpacing.md,
    );

    gate(
      'GEN-04814-G6',
      'MD3 specifies a 56dp Extended FAB; Step 184 gives the band that says '
          'whether that is acceptable rather than merely conventional.',
      'The Extended FAB height sits inside the Step 184 touch band, at its '
          'ceiling -- which is the check the ceiling was added for',
      () =>
          HabotFabThumbZone.heightIsWithinTouchBand &&
          HabotFabThumbZone.extendedFabHeightDp ==
              HabotTouchBand.ceilingDp &&
          HabotFabThumbZone.extendedFabHeightDp > HabotTouchBand.optimalDp,
    );

    gate(
      'GEN-04814-G7',
      'Metric: "unit test coverage / acceptance criteria met before merge" -- '
          'two different things joined by a slash.',
      'The acceptance-criteria half is computed and reaches 1.0; the coverage '
          'half is recorded as not producible on a host with no Dart toolchain '
          'rather than a percentage being invented for it',
      () {
        adherence = HabotFabThumbZone.adherenceRate;
        return HabotFabThumbZone.acceptanceCriteria.length == 9 &&
            HabotFabThumbZone.acceptanceCriteria.values.every((bool b) => b) &&
            adherence == 1.0 &&
            adherence >= HabotFabThumbZone.floor &&
            HabotFabThumbZone.qualitativeOutput == 'Complete' &&
            HabotFabThumbZone.coverageReadingNote
                .contains('nothing runs and nothing is instrumented') &&
            HabotFabThumbZone.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04814',
        atomicStepReferenceId: 'GEN-04814',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement substep 1: Position M3 Extended FAB in the '
            'primary thumb zone (bottom-right on portrait viewports)."',
        implementationOrder: 193,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFabThumbZone',
          'Component Properties':
              '${HabotFabAnchor.values.length} declared anchors, resolved to a '
              'side by text direction; edge margin '
              '${HabotFabThumbZone.edgeMargin.toStringAsFixed(0)}dp; Extended '
              'FAB height ${HabotFabThumbZone.extendedFabHeightDp'
              '.toStringAsFixed(0)}dp; presence delegated to the Step 154 '
              'keyboard rule; mutually exclusive with a bottom action bar',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "bottom-right" assumes a left-to-right locale. MD3 '
              'anchors the FAB to the trailing edge in reading order, which is '
              'the right in English and the LEFT in Urdu -- so hard-coding '
              '"right" puts the primary action under nobody\'s thumb in a '
              'language this product already ships. Third occurrence of the '
              'same defect: Step 150\'s swipe direction and Step 167\'s frozen '
              'column were both written as sides. LIMITATION RECORDED, NOT '
              'SOLVED: around one person in ten is left-handed, the platform '
              'does not expose handedness and this app does not ask. The '
              'trailing-edge anchor is wrong for them on every screen; the '
              'mitigation is that the FAB is never the only route to its '
              'action. SUBSTITUTION: the metric joins coverage and acceptance '
              'criteria with a slash; there is no Dart toolchain on this host, '
              'so nothing runs and nothing is instrumented, and the '
              'acceptance-criteria half is what is reported.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate '
                '(acceptance criteria)',
            observed:
                '${adherence.toStringAsFixed(2)} over '
                '${HabotFabThumbZone.acceptanceCriteria.length} criteria, '
                'including the two the row\'s own wording would have broken: '
                'the anchor resolves to the right in a left-to-right locale '
                'and to the LEFT in a right-to-left one. The coverage half of '
                'the metric is not producible here and is recorded as such '
                'rather than invented.',
            floor: '>=90% unit test coverage / acceptance criteria met before '
                'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling: '100%',
          ),
          AissMeasurement(
            metricName: 'Primary actions per screen',
            observed:
                '1, enforced. A FAB and a bottom action bar cannot both be '
                'declared on one screen; the composition check refuses it at '
                'the call site rather than leaving it to review. The Extended '
                'FAB\'s 56dp height sits at the Step 184 touch band ceiling, '
                'which is the check that ceiling was added for.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/fab_thumb_zone.dart',
        ],
      ),
    );
  });
}
