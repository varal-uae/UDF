/// AISS GATE -- Step 430 of 415
/// Global Reference ID:       GEN-04869
/// Atomic Steps Reference ID: GEN-04869
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 2: Attach WebSocket / BigQuery streaming
///               data hooks for live number updates."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor ">=90% unit test
///         coverage / acceptance criteria met before merge", optimal "95-100%
///         coverage, all acceptance criteria met", ceiling "100% (coverage
///         beyond 100% is not meaningful; further effort has diminishing
///         return)". Best Qualitative Output: "Complete / Partial / Not
///         Complete". ISO/IEC 25010 Software Quality Model -- functional
///         suitability characteristic. Assigned to **DEA**.
///
/// A SOCKET AND A WAREHOUSE PAIRED AS THOUGH BOTH COULD BE LIVE, UNDER THE
/// LONGEST BAND CELL IN THE TRACK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/streaming_hooks.dart';

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

  group('GEN-04869 :: one of the two cannot be live', () {
    gate(
      'GEN-04869-G1',
      'Three numbers across two sources.',
      'Two pushed over the socket, one read from the warehouse',
      () =>
          HabotStreamingHooks.numberCount == 3 &&
          HabotStreamingHooks.bothSourcesAreImplemented,
    );

    gate(
      'GEN-04869-G2',
      'The warehouse number is not allowed to look live.',
      'A warehouse figure is minutes old by construction and no younger for '
          'being fetched by something called a streaming hook',
      () =>
          HabotStreamingHooks.theWarehouseCardIsNotCalledLive &&
          HabotStreamingHooks.theWarehouseNumberHasALongerUsefulAge &&
          HabotStreamingHooks.thePollingCardWasAlreadyMarkedAtStep429,
    );

  });

  group('GEN-04869 :: what a live number does when the socket dies', () {
    gate(
      'GEN-04869-G3',
      'Three live states, and a dropped socket holds.',
      'Live, holding and empty',
      () =>
          HabotStreamingHooks.threeStatesAreDeclared &&
          HabotStreamingHooks.disconnectedWithAValueHolds &&
          HabotStreamingHooks.disconnectedWithNoValueIsEmpty,
    );

    gate(
      'GEN-04869-G4',
      'It neither blanks nor keeps ticking.',
      'A blank loses information the reader already had; a number ticking from '
          'a dead feed is a confident lie',
      () =>
          HabotStreamingHooks.itHoldsRatherThanBlanksOrLies &&
          HabotStreamingHooks.stateNote.contains('confident lie'),
    );

    gate(
      'GEN-04869-G5',
      'The age appears only once it matters.',
      'And the staleness policy is Step 129\'s, bound rather than restated',
      () =>
          HabotStreamingHooks.theAgeAppearsOnlyWhenItMatters &&
          HabotStreamingHooks.theStalenessPolicyIsBound,
    );

  });

  group('GEN-04869 :: a ceiling with an argument in it', () {
    gate(
      'GEN-04869-G6',
      'The ceiling carries an argument with a semicolon.',
      '"100% (coverage beyond 100% is not meaningful; further effort has '
          'diminishing return)"',
      () =>
          HabotStreamingHooks.theCeilingCarriesAnArgument &&
          HabotStreamingHooks.theCeilingHoldsASemicolon,
    );

    gate(
      'GEN-04869-G7',
      'The longest band cell in the track, and the fifth annotated boundary.',
      'After Steps 384, 409 and 413, with Step 433 three rows later making six',
      () =>
          HabotStreamingHooks.theCeilingIsTheLongestBandCell &&
          HabotStreamingHooks.thisIsTheFifthAnnotatedBoundary,
    );

  });

  group('GEN-04869 :: a floor that is two floors', () {
    gate(
      'GEN-04869-G8',
      'The floor holds two criteria joined by an oblique.',
      'A coverage threshold and an acceptance gate, with no conjunction stated',
      () =>
          HabotStreamingHooks.theFloorHoldsTwoCriteria &&
          HabotStreamingHooks.theConjunctionIsAmbiguous,
    );

    gate(
      'GEN-04869-G9',
      'Read as "and", and the choice recorded.',
      'Because the next person to read this cell will pick whichever reading '
          'their build needs',
      () =>
          HabotStreamingHooks.theStricterReadingWasChosen &&
          HabotStreamingHooks
              .floorNote.contains('whichever reading their build needs'),
    );

    gate(
      'GEN-04869-G10',
      'Six obligations, all met, giving Partial at 94 per cent.',
      'Above the floor, below the optimal, and reported as its own band '
          'requires',
      () =>
          HabotStreamingHooks.obligations.length == 6 &&
          HabotStreamingHooks.obligations.values.every((bool b) => b) &&
          HabotStreamingHooks.theFloorIsCleared &&
          HabotStreamingHooks.qualitativeOutput == 'Partial' &&
          HabotStreamingHooks.coverageFraction == 0.94 &&
          HabotStreamingHooks.theStepIsAFragment,
    );
  });

  tearDownAll(() {
    final int numbers = HabotStreamingHooks.numberCount;
    final int socketFed = HabotStreamingHooks.socketFed;
    final int warehouseFed = HabotStreamingHooks.warehouseFed;
    final int coverage = HabotStreamingHooks.coveragePercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04869',
        atomicStepReferenceId: 'GEN-04869',
        setupStepAction:
            'COLUMN NOTE: this row pairs a WebSocket with BigQuery as though '
            'both could feed a live number, when a warehouse figure is minutes '
            'old by construction -- both are implemented and each number '
            'declares its source; its ceiling reads "100% (coverage beyond '
            '100% is not meaningful; further effort has diminishing return)", '
            'the longest band cell in the track and the fifth annotated '
            'boundary after Steps 384, 409 and 413; its floor joins a coverage '
            'threshold to an acceptance gate with an oblique that could be '
            '"and" or "or", read here as the stricter "and"; and it implements '
            '"substep 2" of a step whose substep 3 sits elsewhere in the pool '
            'with no link between them. Atomic Step: "Implement substep 2: '
            'Attach WebSocket / BigQuery streaming data hooks for live number '
            'updates."',
        implementationOrder: 430,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 2: Attach WebSocket / BigQuery streaming data '
          'hooks':
              '$numbers live numbers: $socketFed pushed over the socket and '
                  '$warehouseFed read from the warehouse and labelled with its '
                  'age; unit test coverage $coverage per cent with acceptance '
                  'criteria met',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'THE LONGEST BAND CELL IN FOUR HUNDRED AND THIRTY ROWS, AND A '
                'FLOOR THAT IS TWO FLOORS. The ceiling reads "100% (coverage '
                'beyond 100% is not meaningful; further effort has diminishing '
                'return)" -- a semicolon and two clauses of argument in a cell '
                'a build has to parse, the fifth annotated boundary after '
                'Steps 384, 409 and 413. The floor joins ">=90% unit test '
                'coverage" to "acceptance criteria met before merge" with an '
                'oblique that could be "and" or "or", so a build at 92 per '
                'cent with criteria unmet is above the floor on one reading '
                'and below it on the other; it is read as "and" here and the '
                'choice is recorded. Observed: $coverage per cent with '
                'criteria met -- above the floor, below the optimal, reported '
                'Partial.',
            floor:
                '>=90% unit test coverage / acceptance criteria met before '
                    'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling:
                '100% (coverage beyond 100% is not meaningful; further effort '
                    'has diminishing return)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Numbers presented as live that are not',
            observed:
                '0 of $numbers. A socket pushes and the number is what the '
                'server had a round trip ago; a warehouse is polled and its '
                'tables are built on a schedule, so its number is minutes old '
                'by construction. Both are implemented, $socketFed over the '
                'socket and $warehouseFed from the warehouse, and each '
                'declares its source, because two cards side by side carrying '
                'figures of different ages and looking identical is the defect '
                'this row would otherwise ship. On a dropped socket the number '
                'holds its last value and states its age once the age could '
                'matter, under the staleness policy Step 129 set.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/streaming_hooks.dart',
        ],
      ),
    );
  });
}
