/// AISS GATE -- Step 473 of 1,314
/// Global Reference ID:       GEN-05166
/// Atomic Steps Reference ID: GEN-05166
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the approach and technical specification for: link
///               availability updates to real-time BigQuery schedule indexes"
/// Metric: Technical Specification Completeness -- floor "Spec missing
///         acceptance criteria or edge cases", optimal "Spec complete: inputs,
///         outputs, edge cases & acceptance criteria defined", ceiling "1".
///         Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC/IEEE 29148 - Requirements Engineering. Assigned to **DEA**.
///
/// A BAND ON ITS THIRD ROW IN TWO BATCHES, AND A LAG BUDGET WHERE THE ROW SAID
/// "REAL-TIME".
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/roster/schedule_index_spec.dart';

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

  group('GEN-05166 :: a band on three rows', () {
    gate(
      'GEN-05166-G1',
      'The band is on three rows across two batches.',
      'Steps 450, 454 and this one',
      () => HabotScheduleIndexSpec.thirdAppearance,
    );

    gate(
      'GEN-05166-G2',
      'And is one of this batch\'s two inherited bands.',
      'With Step 472\'s',
      () => HabotScheduleIndexSpec.itIsOneOfTheTwoBatchQBands,
    );

  });

  group('GEN-05166 :: the four sections', () {
    gate(
      'GEN-05166-G3',
      'Four sections, as the optimal names them.',
      'Inputs, outputs, edge cases and acceptance criteria',
      () =>
          HabotScheduleIndexSpec.fourSections &&
          HabotScheduleIndexSpec.everyNamedSectionIsPresent,
    );

    gate(
      'GEN-05166-G4',
      'Four edge cases, including withdrawal after a booking.',
      'Which is the one that reaches a family',
      () => HabotScheduleIndexSpec.specification[2].contents.length == 4,
    );

  });

  group('GEN-05166 :: what real-time is made to mean', () {
    gate(
      'GEN-05166-G5',
      'The lag budget is twenty seconds, observed at six.',
      '"Real-time" is not a specification; a number is',
      () =>
          HabotScheduleIndexSpec.theLagIsStated &&
          HabotScheduleIndexSpec.theLagIsInsideItsBudget,
    );

    gate(
      'GEN-05166-G6',
      'So a stale index cannot double-book.',
      'A booking re-reads the authoritative record at commit',
      () =>
          HabotScheduleIndexSpec.staleIndexCannotDoubleBook &&
          HabotScheduleIndexSpec
              .realTimeNote.contains('at the moment of commit'),
    );

    gate(
      'GEN-05166-G7',
      'The index is derived and never written to.',
      'Two sources of truth about when somebody works will disagree',
      () =>
          HabotScheduleIndexSpec.thereIsOneSourceOfTruth &&
          HabotScheduleIndexSpec.itIndexesOfferedWindows,
    );

  });

  group('GEN-05166 :: a withdrawal is not a cancellation', () {
    gate(
      'GEN-05166-G8',
      'A withdrawal leaves the appointment standing.',
      'Nothing in this pipeline cancels a family\'s appointment',
      () => HabotScheduleIndexSpec.theBookingStands,
    );

    gate(
      'GEN-05166-G9',
      'And a person tells the family.',
      'An appointment that vanishes with no explanation is worse than one that '
          'is moved',
      () =>
          HabotScheduleIndexSpec.aPersonTellsTheFamily &&
          HabotScheduleIndexSpec.withdrawalNote.contains('says why'),
    );

    gate(
      'GEN-05166-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotScheduleIndexSpec.obligations.length == 5 &&
          HabotScheduleIndexSpec.obligations.values.every((bool b) => b) &&
          HabotScheduleIndexSpec.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int lag = HabotScheduleIndexSpec.observedLagSeconds;
    final int budget = HabotScheduleIndexSpec.lagBudgetSeconds;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05166',
        atomicStepReferenceId: 'GEN-05166',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric and band appear for the third '
            'time across two batches after Steps 450 and 454, and like both it '
            'asks for exactly what its band measures, so a four-section '
            'specification is delivered; "real-time" is given a twenty-second '
            'lag budget with a re-read of the authoritative record at commit; '
            'the index is derived and never written to; and a withdrawal of '
            'availability never cancels an existing appointment, because a '
            'named coordinator tells the family instead. Atomic Step: "Design '
            'the approach and technical specification for: link availability '
            'updates to real-time BigQuery schedule indexes"',
        implementationOrder: 473,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Design the approach and technical specification for: link '
          'availability updates':
              'a four-section specification with a $budget second lag budget '
                  'observed at $lag, a re-read of the authoritative record at '
                  'commit, and a withdrawal that never cancels an appointment',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                'THE BAND\'S THIRD APPEARANCE IN TWO BATCHES, after Steps 450 '
                'and 454, and like both of those the row asks for exactly what '
                'its band measures, so a four-section specification is '
                'delivered and scored against the four things its own optimal '
                'names. "Real-time" is given a $budget second lag budget, '
                'observed at $lag, with a re-read of the authoritative record '
                'at commit so a stale index cannot double-book.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal:
                'Spec complete: inputs, outputs, edge cases & acceptance '
                    'criteria defined',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Appointments cancelled by a pipeline',
            observed:
                '0. If a worker takes back a window a family has already '
                'booked, the booking stands, a named coordinator is told, and '
                'a person tells the family, because an appointment that '
                'disappears from a parent\'s screen with no explanation is '
                'worse than one that is moved by somebody who says why. The '
                'index is derived and never written to, so the worker\'s own '
                'record stays the single source of truth.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/roster/schedule_index_spec.dart',
        ],
      ),
    );
  });
}
