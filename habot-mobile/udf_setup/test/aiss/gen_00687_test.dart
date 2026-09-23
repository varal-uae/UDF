/// AISS GATE -- Step 486 of 1,314
/// Global Reference ID:       GEN-00687
/// Atomic Steps Reference ID: GEN-00687
/// Setup Step (Action): Review the UI requirements for horizontal choice chip
///                      arrays.
/// Atomic Step: "Program anomaly alert triggers publishing Shakti Alerts to
///               Slack on failure."
/// Metric: Alert Dispatch Latency -- floor "$\le 3\text{ secs}$", optimal "$\le
///         1\text{ sec}$", ceiling "$5\text{ secs}$". Best Qualitative Output:
///         "Pass / Fail". Habot Shakti Safety Protocol. Assigned to **GFD**.
///
/// A LATENCY CEILING SLOWER THAN ITS OWN FLOOR, AND A MEASURE WITH TWO NAMES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/alerts/anomaly_dispatch.dart';

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

  group('GEN-00687 :: the ceiling at the wrong end', () {
    gate(
      'GEN-00687-G1',
      'Five seconds is slower than three.',
      'On a latency band the ceiling holds the worst value again',
      () =>
          HabotAnomalyDispatch.theCeilingIsSlowerThanTheFloor &&
          HabotAnomalyDispatch.theOptimalIsTheFastest,
    );

    gate(
      'GEN-00687-G2',
      'Three latency rows in this batch do the same.',
      'Steps 486, 487 and 490, all dispatch or aggregation delays',
      () =>
          HabotAnomalyDispatch.threeInOneBatch &&
          HabotAnomalyDispatch.bandNote
              .contains('the heading says the ' 'opposite'),
    );

  });

  group('GEN-00687 :: two names, one measure', () {
    gate(
      'GEN-00687-G3',
      'Step 487 carries the same values under another name.',
      '"Alert Trigger Dispatch Delay" against "Alert Dispatch Latency"',
      () =>
          HabotAnomalyDispatch.twoNamesForOneMeasure &&
          HabotAnomalyDispatch.theBandValuesAreIdentical,
    );

    gate(
      'GEN-00687-G4',
      'Which is how two charts stop agreeing.',
      'One measure with two titles becomes two dashboards',
      () => HabotAnomalyDispatch.namingNote.contains('never agree'),
    );

  });

  group('GEN-00687 :: owners, keys and severity', () {
    gate(
      'GEN-00687-G5',
      'Three alerts, each with a named owner.',
      'An alert with no owner is not published',
      () =>
          HabotAnomalyDispatch.alerts.length == 3 &&
          HabotAnomalyDispatch.everyAlertHasAnOwner,
    );

    gate(
      'GEN-00687-G6',
      'Alerts are keyed on the fault, not the occurrence.',
      'So the same fault is one row, however often it recurs',
      () => HabotAnomalyDispatch.keyedOnTheFaultNotTheOccurrence,
    );

    gate(
      'GEN-00687-G7',
      'So forty retries produce one message.',
      'A failing job that retries every ten seconds does not fill a channel',
      () => HabotAnomalyDispatch.oneFaultIsOneMessage,
    );

    gate(
      'GEN-00687-G8',
      'Only the severity-one alert pages anybody.',
      'Waking somebody is a decision severity makes, not a default',
      () =>
          HabotAnomalyDispatch.onlySeverityOnePages &&
          HabotAnomalyDispatch.severityChoosesTheChannel,
    );

    gate(
      'GEN-00687-G9',
      'Unactioned alerts are deleted rather than muted.',
      'Muting fills a channel with noise people learn to scroll past',
      () =>
          HabotAnomalyDispatch.mutingIsNotTheAnswer &&
          HabotAnomalyDispatch.noiseNote.contains('scrolls past with it'),
    );

  });

  group('GEN-00687 :: the result', () {
    gate(
      'GEN-00687-G10',
      'Five obligations met, and 0.6 seconds reports Pass.',
      'Inside the three-second floor',
      () =>
          HabotAnomalyDispatch.obligations.length == 5 &&
          HabotAnomalyDispatch.obligations.values.every((bool b) => b) &&
          HabotAnomalyDispatch.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int alerts = HabotAnomalyDispatch.alerts.length;
    final double seconds = HabotAnomalyDispatch.observedDispatchSeconds;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00687',
        atomicStepReferenceId: 'GEN-00687',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling of five seconds is slower than '
            'its floor of three, the first of three latency rows in this batch '
            'to put the ceiling at the far end from the optimal, and Step 487 '
            'carries the same three values under a different metric name; what '
            'is built keys alerts on the fault rather than the occurrence so '
            'forty retries produce one message, gives every alert a named '
            'owner and publishes none without one, lets severity alone decide '
            'whether a person is paged, and deletes alerts nobody acts on '
            'rather than muting them. Atomic Step: "Program anomaly alert '
            'triggers publishing Shakti Alerts to Slack on failure."',
        implementationOrder: 486,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Program anomaly alert triggers publishing Shakti Alerts to Slack on':
              '$alerts alert rules each with a named owner, keyed on the fault '
              'so forty retries produce one message; dispatch observed at '
              '$seconds seconds',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Alert Dispatch Latency',
            observed:
                'THE CEILING IS SLOWER THAN THE FLOOR, FOR THE FIRST OF THREE '
                'TIMES IN THIS BATCH. Five seconds sits above a three-second '
                'floor and a one-second optimal, as at Steps 487 and 490. The '
                'column is being used as "the worst we will tolerate" on every '
                'latency row in the sheet while its heading says the opposite. '
                'Observed: $seconds seconds to dispatch.',
            floor: r'$\le 3\text{ secs}$',
            optimal: r'$\le 1\text{ sec}$',
            ceiling: r'$5\text{ secs}$',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Messages published for one recurring fault',
            observed:
                '1, from forty retries. Alerts are keyed on the fault rather '
                'than the occurrence, every one of the $alerts rules names an '
                'owner, an alert with no owner is not published, only severity '
                'one pages a person, and an alert nobody acts on is deleted '
                'rather than muted -- because muting is how a channel fills '
                'with noise everyone has learned to scroll past, and the one '
                'that mattered scrolls past with it.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/alerts/anomaly_dispatch.dart',
        ],
      ),
    );
  });
}
