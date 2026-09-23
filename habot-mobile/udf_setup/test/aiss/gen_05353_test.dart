/// AISS GATE -- Step 491 of 1,314
/// Global Reference ID:       GEN-05353
/// Atomic Steps Reference ID: GEN-05353
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the approach and technical specification for: create an
///               automated friction identification algorithm flagging stations
///               where user drop-off or delay exceeds norms"
/// Metric: Technical Specification Completeness -- floor "Spec missing
///         acceptance criteria or edge cases", optimal "Spec complete: inputs,
///         outputs, edge cases & acceptance criteria defined", ceiling "1".
///         Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC/IEEE 29148 - Requirements Engineering. Assigned to **UDF**.
///
/// A SIXTH NOUN FOR ONE IDEA, AND A NORM THAT HAS TO BE THE STATION'S OWN.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/field/friction_algorithm_spec.dart';

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

  group('GEN-05353 :: the band, a fourth time', () {
    gate(
      'GEN-05353-G1',
      'The fourth appearance of this band.',
      'Steps 450, 454, 473 and 491',
      () => HabotFrictionAlgorithmSpec.fourthAppearance,
    );

    gate(
      'GEN-05353-G2',
      'Four sections, as the optimal names them.',
      'Inputs, outputs, edge cases and acceptance criteria',
      () =>
          HabotFrictionAlgorithmSpec.fourSections &&
          HabotFrictionAlgorithmSpec.everyNamedSectionIsPresent,
    );

    gate(
      'GEN-05353-G3',
      'And four edge cases, including a station slow by design.',
      'A safeguarding check should take longer than a tick box',
      () => HabotFrictionAlgorithmSpec.fourEdgeCases,
    );

  });

  group('GEN-05353 :: six nouns for one idea', () {
    gate(
      'GEN-05353-G4',
      '"Station" is the sixth noun for one idea.',
      'After friction, hesitation, drop-off, bottleneck and complexity '
      'bottleneck',
      () =>
          HabotFrictionAlgorithmSpec.sixNounsNow &&
          HabotFrictionAlgorithmSpec.theFrameworkAlreadyNamedFive,
    );

    gate(
      'GEN-05353-G5',
      'Which is how two teams build two systems.',
      'Six names for a place in a flow where people stop',
      () =>
          HabotFrictionAlgorithmSpec.nounNote
              .contains('two systems for one problem'),
    );

  });

  group('GEN-05353 :: a station compared with itself', () {
    gate(
      'GEN-05353-G6',
      'Three stations, one flag.',
      'Measured against their own trailing medians',
      () =>
          HabotFrictionAlgorithmSpec.readings.length == 3 &&
          HabotFrictionAlgorithmSpec.oneFlag,
    );

    gate(
      'GEN-05353-G7',
      'The slow but steady station is not flagged.',
      'Forty-one seconds against a trailing median of thirty-nine',
      () => HabotFrictionAlgorithmSpec.theSlowButSteadyStationIsNotFlagged,
    );

    gate(
      'GEN-05353-G8',
      'The station that got worse is flagged.',
      'Thirty-four seconds against a trailing median of twelve',
      () =>
          HabotFrictionAlgorithmSpec.theStationThatGotWorseIsFlagged &&
          HabotFrictionAlgorithmSpec.normNote.contains('worse than it was'),
    );

    gate(
      'GEN-05353-G9',
      'The forty-two-session station is not flagged.',
      'Below the minimum session count, whatever its numbers look like',
      () =>
          HabotFrictionAlgorithmSpec.theThinStationIsNotFlagged &&
          HabotFrictionAlgorithmSpec.minimumSessions == 100,
    );

  });

  group('GEN-05353 :: the result', () {
    gate(
      'GEN-05353-G10',
      'Five obligations met, flagging without deciding, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotFrictionAlgorithmSpec.obligations.length == 5 &&
          HabotFrictionAlgorithmSpec.obligations.values.every((bool b) => b) &&
          HabotFrictionAlgorithmSpec.itFlagsRatherThanDecides &&
          HabotFrictionAlgorithmSpec.limitNote
              .contains('flags rather than decides') &&
          HabotFrictionAlgorithmSpec.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int stations = HabotFrictionAlgorithmSpec.readings.length;
    final int nouns = HabotFrictionAlgorithmSpec.nounsForOneIdea.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05353',
        atomicStepReferenceId: 'GEN-05353',
        setupStepAction:
            'COLUMN NOTE: this row carries the Technical Specification '
            'Completeness band for the fourth time after Steps 450, 454 and '
            '473, and like all three it asks for exactly what its band '
            'measures, so a four-section specification is delivered; its '
            '"station" is the sixth noun in this track for a place in a flow '
            'where people stop; its "exceeds norms" is read as each station '
            'against its own trailing median rather than against other '
            'stations, because a medication check should take longer than a '
            'tick box; and the algorithm flags without disabling anything and '
            'without attributing a flag to a person. Atomic Step: "Design the '
            'approach and technical specification for: create an automated '
            'friction identification algorithm flagging stations where user '
            'drop-off or delay exceeds norms"',
        implementationOrder: 491,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Design the approach and technical specification for: create an '
          'automated':
              'a four-section specification over $stations worked stations '
              'compared against their own trailing medians, producing one '
              'flag; $nouns nouns now in use for one idea',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                'THE FOURTH ROW TO CARRY THIS BAND, AND THE SIXTH NOUN FOR ONE '
                'IDEA. Steps 450, 454, 473 and 491 all ask for exactly what '
                'the band measures, so a four-section specification is '
                'delivered; and "station" joins friction, hesitation, '
                'drop-off, bottleneck and complexity bottleneck, making $nouns '
                'names for a place in a flow where people stop.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal:
                'Spec complete: inputs, outputs, edge cases & acceptance '
                'criteria defined',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Stations judged against other stations',
            observed:
                '0 of $stations. A medication check should take longer than a '
                'tick box, so comparing every station against the mean of all '
                'stations flags the careful ones and hides the broken ones. '
                'Each station is compared against its own trailing median over '
                'four weeks, a station below one hundred sessions is not '
                'flagged at all, no flag is attributed to a person, and the '
                'algorithm flags without disabling anything.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/field/friction_algorithm_spec.dart',
        ],
      ),
    );
  });
}
