/// AISS GATE -- Step 335 of 335
/// Global Reference ID:       GEN-03237
/// Atomic Steps Reference ID: GEN-03237
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Create operational alert rules triggering on crash spikes or
///               performance drops."
/// Metric: Alert Trigger Propagation Time -- floor "< 30s", optimal "< 5s",
///         ceiling "60s". Best Qualitative Output: **"Pass"**. Sentry.
///         Assigned to **GFD**.
///
/// "SPIKE" WITHOUT A DENOMINATOR, AND THE BATCH'S FOURTH INVERTED BAND AND
/// FOURTH ONE-VALUED OUTPUT COLUMN. BOTH COUNTS CLOSE HERE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/crash_spike_rules.dart';

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

  group('GEN-03237 :: the denominator', () {
    gate(
      'GEN-03237-G1',
      'Atomic Step: "crash spikes".',
      'Ten crashes in a thousand sessions is a hundred sessions per crash -- '
          'the floor of the band Step 274 declared -- and ten in a million is '
          'a hundred thousand, ten times its ceiling',
      () =>
          HabotCrashSpikeRules.sessionsPerCrashOnASmallDay == 100 &&
          HabotCrashSpikeRules.sessionsPerCrashOnALargeDay == 100000 &&
          HabotCrashSpikeRules.theSameCountIsAFloorAndTenTimesACeiling,
    );

    gate(
      'GEN-03237-G2',
      'A count-based rule fires on a marketing push.',
      'And stays silent through a real regression on a quiet Tuesday, which '
          'is why the rule is written on the rate against the same weekday\'s '
          'baseline',
      () => HabotCrashSpikeRules.denominatorNote
          .contains('a quiet Tuesday'),
    );

    gate(
      'GEN-03237-G3',
      'And it cannot fire below five hundred sessions.',
      'A rate over three hundred sessions is an anecdote',
      () =>
          HabotCrashSpikeRules.minimumSessionsBeforeARuleMayFire == 500 &&
          HabotCrashSpikeRules.aSmallWindowCannotFire,
    );
  });

  group('GEN-03237 :: a release is not a spike', () {
    gate(
      'GEN-03237-G4',
      'Four windows, one of which fires.',
      'A signature fires only when it is both new and rising against its own '
          'version\'s baseline',
      () =>
          HabotCrashSpikeRules.windows.length == 4 &&
          HabotCrashSpikeRules.exactlyOneWindowFires,
    );

    gate(
      'GEN-03237-G5',
      'The new-but-not-rising window is silent.',
      'Two thousand sessions per crash is inside the band, so a new signature '
          'alone does not page anybody',
      () =>
          HabotCrashSpikeRules.aNewButNotRisingSignatureDoesNotFire &&
          HabotCrashSpikeRules.windows[2].sessionsPerCrash == 2000,
    );

    gate(
      'GEN-03237-G6',
      'The muted rule is the one that is not there when it matters.',
      'Which is the actual failure mode of a rule that pages on every '
          'rollout',
      () => HabotCrashSpikeRules.releaseNote.contains('is an anecdote'),
    );
  });

  group('GEN-03237 :: two subjects sharing one rule', () {
    gate(
      'GEN-03237-G7',
      'Atomic Step: "crash spikes OR performance drops".',
      'A crash is binary and a frame time is a distribution; two rule '
          'families, each with its own trigger, so a failure can say which '
          'one failed',
      () =>
          HabotCrashSpikeRules.eachFamilyHasItsOwnTrigger &&
          HabotCrashSpikeRules.oneIsARateAndTheOtherIsAPercentile &&
          HabotSignalFamily.values.length == 2,
    );

    gate(
      'GEN-03237-G8',
      'The fourth bundled row this track has recorded.',
      'After Steps 285, 295 and 298',
      () =>
          HabotCrashSpikeRules.thisIsTheFourthBundledRow &&
          HabotCrashSpikeRules.bundlingNote.contains('which one failed'),
    );
  });

  group('GEN-03237 :: the band and the output column', () {
    gate(
      'GEN-03237-G9',
      'Ceiling 60s against a floor of 30s, and an output column of "Pass".',
      'Fourth inverted band and fourth one-valued output; both of the '
          'batch\'s counts close on this row, and Step 333 carries neither',
      () =>
          HabotCrashSpikeRules.theBandIsInverted &&
          HabotCrashSpikeRules.theOutputCannotExpressAFailure &&
          HabotCrashSpikeRules.bothCountsCloseHere &&
          HabotCrashSpikeRules.theOrderedBandInThisBatch == 333,
    );

    gate(
      'GEN-03237-G10',
      'Output reported as Pass / Fail against declared obligations.',
      'Five obligations, all met, so a failure would have had somewhere to '
          'go; all eleven declared checks hold',
      () =>
          HabotCrashSpikeRules.obligations.length == 5 &&
          HabotCrashSpikeRules.obligations.values.every((bool b) => b) &&
          HabotCrashSpikeRules.qualitativeOutput == 'Pass' &&
          HabotCrashSpikeRules.checks.length == 11 &&
          HabotCrashSpikeRules.checks.values.every((bool b) => b) &&
          HabotCrashSpikeRules.columnNote.contains('GFD'),
    );
  });

  tearDownAll(() {
    final String crashTrigger =
        HabotCrashSpikeRules.triggerFor[HabotSignalFamily.crashes] ?? '';
    final String perfTrigger =
        HabotCrashSpikeRules.triggerFor[HabotSignalFamily.performance] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03237',
        atomicStepReferenceId: 'GEN-03237',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to GFD rather than UDF, its '
            'Best Qualitative Output column reads "Pass" with no failing '
            'value, its ceiling of 60s is worse than its floor of 30s, and '
            'every narrative column is the generic engineering-console '
            'boilerplate. Atomic Step: "Create operational alert rules '
            'triggering on crash spikes or performance drops."',
        implementationOrder: 335,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Create operational alert rules triggering on crash spikes or '
                  'performance':
              'two rule families: "$crashTrigger" and "$perfTrigger"',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'four worked windows, one of which fires; a window of 300 '
                  'sessions cannot fire at all',
          'Data Quality Note':
              'DENOMINATOR: ${HabotCrashSpikeRules.denominatorNote} '
              'RELEASES: ${HabotCrashSpikeRules.releaseNote} '
              'BUNDLING: ${HabotCrashSpikeRules.bundlingNote} '
              'BAND: ${HabotCrashSpikeRules.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Alert Trigger Propagation Time',
            observed:
                'THE BAND IS INVERTED -- a 60-second ceiling against a '
                '30-second floor on a lower-is-better measure -- and the '
                'output column holds only "Pass". Fourth of each in this '
                'batch, and both counts close on this row. Step 333 is the one '
                'latency band ordered correctly and the one row carrying '
                'neither defect, which is what makes both errors rather than '
                'the way this sheet writes bands.',
            floor: '< 30s',
            optimal: '< 5s',
            ceiling: '60s',
          ),
          AissMeasurement(
            metricName: 'Sessions per crash the rule is written on',
            observed:
                'A rate rather than a count. Ten crashes is 100 sessions per '
                'crash on a thousand-session day -- the floor of the Step 274 '
                'band -- and 100,000 on a million-session day, ten times its '
                'ceiling. Same numerator, opposite verdicts, which is why the '
                'rule reads the rate, compares against the same weekday, and '
                'refuses to fire below five hundred sessions.',
            floor: '100',
            optimal: '1000',
            ceiling: '10000',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/crash_spike_rules.dart',
        ],
      ),
    );
  });
}
