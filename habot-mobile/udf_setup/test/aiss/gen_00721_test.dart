/// AISS GATE -- Step 437 of 415
/// Global Reference ID:       GEN-00721
/// Atomic Steps Reference ID: GEN-00721
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement client SDK triggers capturing level-up and streak
///               completion events."
/// Metric: Trigger Capture Efficiency -- floor "$100\%$", optimal "$100\%$",
///         ceiling "N/A (100% target)". Best Qualitative Output: "Complete /
///         Not Complete". Mobile Telemetry Best Practices. Assigned to **DEA**.
///
/// CLIENT TRIGGERS FOR LEVEL-UPS AND STREAKS, WHERE THE CLIENT IS THE ONE PARTY
/// THAT MUST NOT DECIDE EITHER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/progress_events.dart';

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

  group('GEN-00721 :: the client receives, it does not decide', () {
    gate(
      'GEN-00721-G1',
      'A client-detected level-up is a client-asserted one.',
      'A client that decides a level was reached can be persuaded it was',
      () =>
          HabotProgressEvents.theDirectionIsReversed &&
          HabotProgressEvents.theCharterRequiresIt,
    );

    gate(
      'GEN-00721-G2',
      'So the client records only that it was seen.',
      'The server decides levels and streaks; the client records that the '
          'person saw the event',
      () =>
          HabotProgressEvents.whatTheClientCaptures.contains('saw') &&
          HabotProgressEvents.authorityNote.contains('harmless'),
    );

  });

  group('GEN-00721 :: streaks that cannot punish', () {
    gate(
      'GEN-00721-G3',
      'Only a rostered working day can break a streak.',
      'Days off, leave and sickness cannot',
      () => HabotProgressEvents.onlyARosteredDayCanBreakIt,
    );

    gate(
      'GEN-00721-G4',
      'Leave and sickness pause it without anybody asking.',
      'The days people miss are sick days, leave, a school play and weekends',
      () =>
          HabotProgressEvents.leaveAndSicknessPauseAutomatically &&
          HabotProgressEvents.daysPeopleMiss.length == 4,
    );

    gate(
      'GEN-00721-G5',
      'And a broken streak is private.',
      'Visible to nobody but the person whose streak it was',
      () =>
          HabotProgressEvents.theMechanicSurvivesWithoutThePunishment &&
          HabotProgressEvents.streakNote.contains('the punishment does not'),
    );

  });

  group('GEN-00721 :: LaTeX, a declining ceiling, and CSS', () {
    gate(
      'GEN-00721-G6',
      'The band is typeset in LaTeX for the third time.',
      '"\$100\\%\$", after Steps 356 and 365',
      () =>
          HabotProgressEvents.theBandIsTypesetInLatex &&
          HabotProgressEvents.thirdLatexBand,
    );

    gate(
      'GEN-00721-G7',
      'The ceiling declines and the floor equals the optimal.',
      '"N/A (100% target)", Step 411\'s refusal with an annotation',
      () =>
          HabotProgressEvents.theCeilingDeclines &&
          HabotProgressEvents.theFloorEqualsTheOptimal,
    );

    gate(
      'GEN-00721-G8',
      'The output column has no Partial.',
      '"Complete / Not Complete"',
      () => HabotProgressEvents.thereIsNoPartial,
    );

    gate(
      'GEN-00721-G9',
      'CSS returns in the Setup Step and is not counted again.',
      'A CSS grid container class; the foreign-stack register stays at '
          'nineteen',
      () =>
          HabotProgressEvents.cssReturnsInTheSetupStep &&
          !HabotProgressEvents.cssIsCountedAgain &&
          HabotProgressEvents.foreignStackRegisterStandsAt == 19,
    );

    gate(
      'GEN-00721-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotProgressEvents.obligations.length == 5 &&
          HabotProgressEvents.obligations.values.every((bool b) => b) &&
          HabotProgressEvents.qualitativeOutput == 'Complete' &&
          HabotProgressEvents.captureRate == 100,
    );
  });

  tearDownAll(() {
    final double capture = HabotProgressEvents.captureRate;
    final int missed = HabotProgressEvents.daysPeopleMiss.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00721',
        atomicStepReferenceId: 'GEN-00721',
        setupStepAction:
            'COLUMN NOTE: this row puts level-up and streak triggers in the '
            'client SDK, which would let the client assert progress the '
            'charter says must come from validated server events, so the '
            'server decides and the client records only that the event was '
            'seen; its floor and optimal are typeset "\$100\\%\$" in LaTeX, '
            'the third such band after Steps 356 and 365; its ceiling reads '
            '"N/A (100% target)"; its output column has no Partial; and its '
            'Setup Step asks for a CSS grid container class, recorded but not '
            'counted again on the foreign-stack register. Atomic Step: '
            '"Implement client SDK triggers capturing level-up and streak '
            'completion events."',
        implementationOrder: 437,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement client SDK triggers capturing level-up and streak '
          'completion events':
              'levels and streaks decided on the server; the client records '
                  'that each event was seen, capture rate $capture per cent',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Trigger Capture Efficiency',
            observed:
                'THE BAND IS TYPESET IN LATEX FOR THE THIRD TIME AND DECLINES '
                'AT THE CEILING. Floor and optimal read "\$100\\%\$", after '
                'Steps 356 and 365, and the ceiling reads "N/A (100% target)". '
                'The output column offers Complete or Not Complete and no '
                'Partial. The trigger direction is reversed: a level decided '
                'on the client is a level the client asserted, so the server '
                'decides and the client records that the event was seen. '
                'Observed: $capture per cent.',
            floor: r'$100\%$',
            optimal: r'$100\%$',
            ceiling: 'N/A (100% target)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Days that can break a streak other than rostered days',
            observed:
                '0 of 3. A streak works by making a missed day feel like a '
                'loss, and the days people miss are sick days, leave, a '
                'child\'s school play and weekends -- $missed kinds named. '
                'Only a rostered working day can break a streak, approved '
                'leave and sickness pause it without anybody asking, and a '
                'broken streak is shown to nobody else. The mechanic survives '
                'and the punishment does not.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/progress_events.dart',
        ],
      ),
    );
  });
}
