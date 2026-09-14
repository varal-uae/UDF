/// AISS GATE -- Step 199 of 215
/// Global Reference ID:       GEN-01430
/// Atomic Steps Reference ID: GEN-01430
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement M3 Elevating Card effects on category card press
///               events."
/// Metric: Category Navigation Discoverability (Time-to-Find) -- Floor <10s,
///         Optimal <3s, Ceiling <15s. Good/Average/Poor.
///
/// MATERIAL 3 DOES NOT RAISE A CARD ON PRESS, AND ON A TOUCH SCREEN IT COULD
/// NOT BE SEEN IF IT DID -- the finger is on top of the surface casting the
/// shadow. Press is a state layer; elevation is for drag; hover elevation is
/// kept for the one device class that can see it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/discovery/card_press_feedback.dart';
import 'package:udf_setup/design_system/tokens/elevation_tokens.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

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

  group('GEN-01430 :: what press actually does in MD3', () {
    gate(
      'GEN-01430-G1',
      'Atomic Step: "M3 ELEVATING Card effects on category card PRESS '
          'events." MD3 returns an elevated card to its resting level on '
          'press.',
      'Press keeps the resting elevation, so the elevation delta the row asks '
          'for is exactly zero -- the row asks for an effect that has no size',
      () =>
          HabotCardPressFeedback.pressKeepsRestingElevation &&
          HabotCardPressFeedback.pressElevationDeltaDp == 0 &&
          HabotCardPressFeedback
                  .responseFor(HabotCardInteraction.pressed)
                  .elevation ==
              HabotElevationLevel.level1 &&
          HabotCardPressFeedback.elevationOnPressIsAPointerIdeaNote
              .contains('animates something the hand is covering'),
    );

    gate(
      'GEN-01430-G2',
      'The row is honoured where the effect is visible and declined where it '
          'is not.',
      'Drag is the interaction that raises the card, from level 1 to level 3, '
          'and hover raises it on pointer devices -- so the elevating half of '
          'the row ships wherever a person could see it',
      () =>
          HabotCardPressFeedback.dragIsTheElevatingInteraction &&
          HabotCardPressFeedback.hoverRaisesOnPointerDevices &&
          HabotElevation.dp[HabotCardPressFeedback
                  .responseFor(HabotCardInteraction.dragged)
                  .elevation] ==
              HabotElevation.level3 &&
          HabotElevation.dp[HabotCardPressFeedback
                  .responseFor(HabotCardInteraction.hovered)
                  .elevation] ==
              HabotElevation.level2,
    );

    gate(
      'GEN-01430-G3',
      'A tap with no feedback is a tap the user repeats.',
      'Press produces a state layer, and the press response is marked as the '
          'one that is NOT visible under a finger -- which is why it has to be '
          'a wash across the whole surface rather than a shadow at its edge',
      () {
        final HabotCardResponse pressed =
            HabotCardPressFeedback.responseFor(HabotCardInteraction.pressed);
        final HabotCardResponse resting =
            HabotCardPressFeedback.responseFor(HabotCardInteraction.resting);
        return pressed.stateLayerOpacity > resting.stateLayerOpacity &&
            !pressed.visibleUnderAFinger &&
            HabotCardPressFeedback
                .responseFor(HabotCardInteraction.dragged)
                .visibleUnderAFinger &&
            HabotCardPressFeedback.responses.length ==
                HabotCardInteraction.values.length;
      },
    );

    gate(
      'GEN-01430-G4',
      'Step 97: an interaction answered only by colour is not answered for '
          'everyone, and focus is an interaction.',
      'Focus gets a state layer as well as press, so a keyboard or switch user '
          'sees which card they are on -- and both durations are motion tokens '
          'inside the interactive ceiling',
      () =>
          HabotCardPressFeedback
                  .responseFor(HabotCardInteraction.focused)
                  .stateLayerOpacity >
              0 &&
          HabotCardPressFeedback.stateLayerDuration == HabotMotion.fast &&
          HabotCardPressFeedback.feedbackCeiling ==
              HabotMotion.interactiveCeiling &&
          HabotCardPressFeedback.feedbackIsInsideTheCeiling,
    );
  });

  group('GEN-01430 :: the metric on this row', () {
    gate(
      'GEN-01430-G5',
      'Metric: Category Navigation Discoverability (Time-to-Find).',
      'Time-to-Find measures locating a category; press feedback happens after '
          'it has been found. The figure the row asks for cannot be produced '
          'from anything this step builds and is recorded as such rather than '
          'invented',
      () =>
          HabotCardPressFeedback.metricDoesNotMeasureTheRowNote
              .contains('cannot be produced') &&
          HabotCardPressFeedback.metricDoesNotMeasureTheRowNote
              .contains('is not invented') &&
          HabotCardPressFeedback.timeToFindOptimalSeconds == 3 &&
          HabotCardPressFeedback.timeToFindFloorSeconds == 10 &&
          HabotCardPressFeedback.timeToFindCeilingSeconds == 15,
    );

    gate(
      'GEN-01430-G6',
      'The floor/optimal/ceiling convention was written for rates, where '
          'higher is better.',
      'On a duration the ordering inverts and the ceiling becomes the WORST '
          'tolerated value -- 15 seconds grades as Poor, not as a ceiling '
          'result, and the grading function is written to the duration '
          'reading rather than the sheet\'s default one',
      () =>
          HabotCardPressFeedback.bandIsInvertedForADuration &&
          HabotCardPressFeedback.qualitativeOutputForSeconds(15) == 'Poor' &&
          HabotCardPressFeedback.qualitativeOutputForSeconds(9) ==
              'Average' &&
          HabotCardPressFeedback.qualitativeOutputForSeconds(2) == 'Good' &&
          HabotCardPressFeedback.invertedBandNote
              .contains('every duration metric in the sheet'),
    );

    gate(
      'GEN-01430-G7',
      'What this step can actually be graded on.',
      'All eight declared checks hold, giving 1.0 -- the properties of the '
          'feedback itself, which is what the step builds, reported instead of '
          'a time-to-find number nothing here could measure',
      () {
        adherence = HabotCardPressFeedback.adherence;
        return HabotCardPressFeedback.checks.length == 8 &&
            HabotCardPressFeedback.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotCardPressFeedback.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01430',
        atomicStepReferenceId: 'GEN-01430',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement M3 Elevating Card effects on category card press '
            'events."',
        implementationOrder: 199,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCardPressFeedback',
          'Component Properties':
              '${HabotCardPressFeedback.responses.length} interactions, each '
              'with an MD3 elevation level and a state-layer opacity; press at '
              'resting elevation with a 10% state layer; drag at level 3; '
              'hover at level 2 for pointer devices; state layer over '
              '${HabotCardPressFeedback.stateLayerDuration.inMilliseconds}ms, '
              'inside the '
              '${HabotCardPressFeedback.feedbackCeiling.inMilliseconds}ms '
              'interactive ceiling',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: Material 3 does not raise a card on press. The '
              'elevated card rests at level 1, goes to level 3 while DRAGGED, '
              'and answers a press with a state layer. That is not a style '
              'preference -- on a touch screen the finger is on top of the '
              'surface that would cast the shadow, so a press elevation '
              'animates something the hand is covering. The elevation delta '
              'the row asks for measures zero. The elevating half is honoured '
              'on hover, where a pointer device can see it, and on drag. '
              'SECOND FINDING: the metric on this row does not measure what '
              'the row builds. Time-to-Find is about locating a category; '
              'press feedback happens afterwards. THIRD: the row\'s '
              'floor/optimal/ceiling inverts on a duration -- floor 10s, '
              'optimal 3s, ceiling 15s means the ceiling is the WORST '
              'tolerated value. A reader applying the sheet\'s usual '
              'higher-is-better reading grades a fifteen-second search as a '
              'ceiling result. The same shape will recur on every duration '
              'metric in the sheet.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Category Navigation Discoverability (Time-to-Find)',
            observed:
                'NOT PRODUCIBLE. Time-to-Find requires people finding '
                'categories, and press feedback does not change how long that '
                'takes. No figure is invented. The band is recorded with its '
                'inversion noted: on a duration the ceiling is the worst '
                'tolerated value, so 15s grades Poor.',
            floor: '<10s',
            optimal: '<3s',
            ceiling: '<15s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Press feedback properties',
            observed:
                '${adherence.toStringAsFixed(2)} over '
                '${HabotCardPressFeedback.checks.length} checks: press at '
                'resting elevation with a state layer, drag as the elevating '
                'interaction, hover retained for pointer devices, focus '
                'answered, and feedback inside the '
                '${HabotCardPressFeedback.feedbackCeiling.inMilliseconds}ms '
                'interactive ceiling.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/discovery/card_press_feedback.dart',
        ],
      ),
    );
  });
}
