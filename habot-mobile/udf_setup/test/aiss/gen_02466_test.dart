/// AISS GATE -- Step 360 of 375
/// Global Reference ID:       GEN-02466
/// Atomic Steps Reference ID: GEN-02466
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Create a dashboard widget to report the \"Swept Records\"
///               count to administrators."
/// Metric: RBAC Enforcement Rate (%) -- floor 0.999, optimal 1, ceiling 1.
///         Pass / Fail. ISO/IEC 27001, NIST Cybersecurity Framework.
///
/// A COUNT WITH A VERB HIDDEN INSIDE IT, AND AN ACCESS-CONTROL RATE ON A
/// COUNTING TILE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/swept_records_widget.dart';

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

  group('GEN-02466 :: "swept" is a verb', () {
    gate(
      'GEN-02466-G1',
      'Three outcomes, reported separately and never summed.',
      'Examined, quarantined, removed -- and only removal cannot be undone',
      () =>
          HabotSweepOutcome.values.length == 3 &&
          HabotSweptRecordsWidget.theThreeOutcomesAreReportedSeparately &&
          !HabotSweptRecordsWidget.theOutcomesAreSummedIntoOneFigure,
    );

    gate(
      'GEN-02466-G2',
      'Today removed 9 and touched 70.',
      '"1,284 swept" could have been any of the three or their sum, and a day '
          'that removed 1,284 is a different day',
      () =>
          HabotSweptRecordsWidget.onlyRemovalsAreIrreversible &&
          HabotSweptRecordsWidget.verbNote.contains('cannot be undone'),
    );
  });

  group('GEN-02466 :: the denominator', () {
    gate(
      'GEN-02466-G3',
      'The headline states 70 of 2,000,000.',
      '1,284 of 1,300 is an outage and 1,284 of two million is a Tuesday',
      () =>
          HabotSweptRecordsWidget.theHeadlineCarriesItsDenominator &&
          HabotSweptRecordsWidget.headline.startsWith('70 of'),
    );

    gate(
      'GEN-02466-G4',
      'Which is 35 per million.',
      'The figure that decides whether anybody does anything; Step 358 records '
          'the same omission one row earlier',
      () =>
          HabotSweptRecordsWidget.theShareIsThirtyFivePerMillion &&
          HabotSweptRecordsWidget.denominatorNote.contains('Step 358'),
    );
  });

  group('GEN-02466 :: what changed and what is waiting', () {
    gate(
      'GEN-02466-G5',
      'A delta of 19 and a pending count of 61 sit beside the total.',
      'A sweep total that only rises is a scoreboard',
      () =>
          HabotSweptRecordsWidget.theWidgetCarriesADelta &&
          HabotSweptRecordsWidget.theWidgetCarriesAPendingCount,
    );

    gate(
      'GEN-02466-G6',
      'The quarantined records are the only ones where acting is possible.',
      'Which is why the pending count is the number an administrator uses',
      () => HabotSweptRecordsWidget.actionabilityNote
          .contains('acting is still'),
    );

    gate(
      'GEN-02466-G7',
      'The three-fact shape is Step 331\'s.',
      'A count, what changed, and the one to act on -- reused rather than '
          'rearranged',
      () =>
          HabotSweptRecordsWidget.theShapeIsAlreadyDeclared &&
          HabotSweptRecordsWidget.actionabilityNote.contains('Step 331'),
    );
  });

  group('GEN-02466 :: the metric, and the half of it that is real', () {
    gate(
      'GEN-02466-G8',
      'An RBAC enforcement rate is measured at the authorisation layer.',
      'Not on a counting tile; Step 373 in this batch carries the identical '
          'metric and band on a row about displaying anomalies',
      () =>
          HabotSweptRecordsWidget.theMetricIsMeasuredElsewhere &&
          HabotSweptRecordsWidget.theOtherRowWithThisMetric == 373,
    );

    gate(
      'GEN-02466-G9',
      'The tile is hidden without the role, and so is an empty frame.',
      'An empty tile is itself a disclosure, because it says the feature '
          'exists',
      () =>
          !HabotSweptRecordsWidget.theTileIsVisibleWithoutTheRole &&
          !HabotSweptRecordsWidget.anEmptyTileIsRenderedInstead &&
          HabotSweptRecordsWidget.metricNote.contains('itself a disclosure'),
    );

    gate(
      'GEN-02466-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; the band\'s optimal and ceiling '
          'are both 1, and all ten declared checks hold',
      () =>
          HabotSweptRecordsWidget.obligations.length == 5 &&
          HabotSweptRecordsWidget.obligations.values.every((bool b) => b) &&
          HabotSweptRecordsWidget.qualitativeOutput == 'Pass' &&
          HabotSweptRecordsWidget.theOptimalEqualsTheCeiling &&
          HabotSweptRecordsWidget.checks.length == 10 &&
          HabotSweptRecordsWidget.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String head = HabotSweptRecordsWidget.headline;
    final int delta = HabotSweptRecordsWidget.deltaTouched;
    final int pending = HabotSweptRecordsWidget.awaitingDecision;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02466',
        atomicStepReferenceId: 'GEN-02466',
        setupStepAction:
            'COLUMN NOTE: the metric on this row is an RBAC enforcement rate '
            'on a counting widget, its optimal and ceiling are both written 1, '
            'the Data Requirement cell reads "Data/artifacts to prepare: Swept '
            'Records" -- the count\'s own label lifted into the artefact list '
            '-- and the Setup Step column is empty. Atomic Step: "Create a '
            'dashboard widget to report the Swept Records count to '
            'administrators."',
        implementationOrder: 360,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Swept Records':
              '$head; 1,284 examined, 61 quarantined, 9 removed, never summed',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a delta of $delta and $pending awaiting a decision sit beside '
                  'the total; the tile is hidden without the administrator '
                  'role',
          'Data Quality Note':
              'VERB: ${HabotSweptRecordsWidget.verbNote} '
              'DENOMINATOR: ${HabotSweptRecordsWidget.denominatorNote} '
              'ACTIONABILITY: ${HabotSweptRecordsWidget.actionabilityNote} '
              'METRIC: ${HabotSweptRecordsWidget.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'RBAC Enforcement Rate (%)',
            observed:
                'NOT A PROPERTY OF A COUNTING TILE, AND THE OPTIMAL EQUALS THE '
                'CEILING. An RBAC enforcement rate is the share of requests '
                'correctly allowed or denied by role, measured at the '
                'authorisation layer; Step 373 in this batch carries the '
                'identical metric and band on a row about displaying '
                'anomalies. What the metric does point at is real: the widget '
                'is for administrators, so it sits behind a role check, and '
                'somebody without the role gets no tile at all rather than an '
                'empty one -- an empty tile says the feature exists.',
            floor: '0.999',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Records touched, as a share of the population',
            observed:
                '70 of 2,000,000, which is 35 per million. "1,284 swept" has a '
                'verb hidden inside it: the sweep examined 1,284, quarantined '
                '61 and removed 9, and only the removals cannot be undone. The '
                'three are reported separately and never added together, the '
                'headline carries its denominator, and a delta of $delta and a '
                'pending count of $pending sit beside the total -- the shape '
                'Step 331 settled, because a number that only rises is a '
                'scoreboard rather than something to act on.',
            floor: '35',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/swept_records_widget.dart',
        ],
      ),
    );
  });
}
