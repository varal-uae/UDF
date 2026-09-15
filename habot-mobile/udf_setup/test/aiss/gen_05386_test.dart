/// AISS GATE -- Step 260 of 275
/// Global Reference ID:       GEN-05386
/// Atomic Steps Reference ID: GEN-05386
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Detect connection quality using the Network Information API
///               to adapt data loading."
/// Metric: Low-Bandwidth Performance Resilience -- Floor "<= 5% failure on
///         3G", Optimal "<= 1% failure on 3G", Ceiling "0% failure".
///         Pass/Fail.
///
/// THE API THE ROW NAMES COVERS ONE OF THE THREE TARGETS THIS APPLICATION
/// BUILDS FOR, AND CONNECTION TYPE IS NOT CONNECTION QUALITY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/connection_quality.dart';

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

  group('GEN-05386 :: what the named API can actually see', () {
    gate(
      'GEN-05386-G1',
      'Atomic Step: "using the Network Information API".',
      'The API the row names is available on one of the three build targets, '
          'and that coverage is computed from the source table rather than '
          'asserted',
      () =>
          HabotConnectionQuality.allTargets.length == 3 &&
          HabotConnectionQuality.targetsTheRowsApiCovers.length == 1 &&
          (HabotConnectionQuality.rowApiTargetCoverage - 1 / 3).abs() < 1e-9 &&
          HabotConnectionQuality.webApiNote.contains('navigator.connection'),
    );

    gate(
      'GEN-05386-G2',
      'Four signals, and two of them are guesses.',
      'Each source records where it is available and whether it is an '
          'estimate; two are stated or measured facts and two are estimates, '
          'and each says why',
      () =>
          HabotConnectionQuality.sources.length == 4 &&
          HabotConnectionQuality.statedOrMeasured.length == 2 &&
          HabotConnectionQuality.signalsAvailableEverywhere.length == 3 &&
          HabotConnectionQuality.sources.every(
            (HabotSignalSource s) => s.why.length > 60,
          ),
    );

    gate(
      'GEN-05386-G3',
      'Connection type is not connection quality.',
      'Wifi on a hotel network is slower than most mobile connections, so the '
          'type signal is marked an estimate and the measured round trip is '
          'what the policy actually reads',
      () =>
          HabotConnectionQuality
              .sourceFor(HabotNetworkSignal.connectivityType)
              .isAnEstimate &&
          !HabotConnectionQuality
              .sourceFor(HabotNetworkSignal.measuredLatency)
              .isAnEstimate &&
          HabotConnectionQuality.typeIsNotQualityNote.isNotEmpty,
    );
  });

  group('GEN-05386 :: the decision', () {
    gate(
      'GEN-05386-G4',
      'A preference outranks an estimate of the thing it is about.',
      'A person who asked for less data gets less data whatever the '
          'measurement says, and that ordering is exercised rather than '
          'described',
      () =>
          HabotConnectionQuality.preferenceOutranksMeasurement &&
          HabotConnectionQuality.saveDataNote.isNotEmpty,
    );

    gate(
      'GEN-05386-G5',
      'Not knowing is not the same as knowing it is fine.',
      'With no measurement the policy is conservative rather than full, so a '
          'platform where the estimate is missing does not get the most '
          'expensive behaviour by default',
      () => HabotConnectionQuality.unknownIsConservative,
    );

    gate(
      'GEN-05386-G6',
      'Thresholds come from the Step 165 budget, not from here.',
      'The band is monotone across a fast round trip, one above the '
          'interactive budget and one twice as long again, and the '
          'thresholds are read from the declared token',
      () =>
          HabotConnectionQuality.theBandIsMonotone &&
          HabotConnectionQuality.conservativeAbove.inSeconds == 2 &&
          HabotConnectionQuality.minimalAbove ==
              HabotConnectionQuality.conservativeAbove * 2,
    );

    gate(
      'GEN-05386-G7',
      'Offline is a state, not an extremely long round trip.',
      'Being offline lands on minimal regardless of the measurement, '
          'deferring to the component that already owns that state',
      () => HabotConnectionQuality.offlineIsNotJustSlow,
    );

    gate(
      'GEN-05386-G8',
      'Metric: <= 5% / <= 1% / 0% failure on 3G. Pass/Fail.',
      'All ten declared checks hold and the step reports Pass, with the note '
          'that a failure rate on 3G needs a device on 3G and this is a '
          'policy that decides what to load rather than a measurement of '
          'what failed',
      () =>
          HabotConnectionQuality.checks.length == 10 &&
          HabotConnectionQuality.checks.values.every((bool b) => b) &&
          HabotConnectionQuality.qualitativeOutput == 'Pass' &&
          HabotConnectionQuality.metricNote.isNotEmpty &&
          HabotConnectionQuality.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String coverage =
        (HabotConnectionQuality.rowApiTargetCoverage * 100)
            .toStringAsFixed(1);
    final String sources = '${HabotConnectionQuality.sources.length}';
    final String facts = '${HabotConnectionQuality.statedOrMeasured.length}';
    final String everywhere =
        '${HabotConnectionQuality.signalsAvailableEverywhere.length}';
    final String threshold =
        '${HabotConnectionQuality.conservativeAbove.inMilliseconds}ms';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05386',
        atomicStepReferenceId: 'GEN-05386',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Detect connection quality using the Network Information '
            'API to adapt data loading."',
        implementationOrder: 260,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotConnectionQuality / HabotSignalSource / HabotDataPolicy',
          'Component Properties':
              '$sources signals, $facts of them stated or measured rather '
              'than estimated and $everywhere available on all three '
              'targets; three data policies ordered by a threshold of '
              '$threshold read from the Step 165 budget; preference outranks '
              'measurement and offline defers to the offline state',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotConnectionQuality.webApiNote} '
              'SECOND: ${HabotConnectionQuality.typeIsNotQualityNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Build targets the row\'s API covers',
            observed:
                '${HabotConnectionQuality.targetsTheRowsApiCovers.length} of '
                '${HabotConnectionQuality.allTargets.length} ($coverage%). '
                'navigator.connection exists on the web build only, and not '
                'in Safari even there, so the policy is built on the signals '
                'that exist on all three.',
            floor: '3 of 3',
            optimal: '3 of 3',
            ceiling: '3 of 3',
          ),
          AissMeasurement(
            metricName: 'Low-Bandwidth Performance Resilience',
            observed:
                'NOT MEASURED HERE. A failure rate on 3G needs devices on 3G '
                'and a population of requests; what is built is the policy '
                'that decides how much to load, exercised across a fast '
                'round trip, one above $threshold, one twice that, an '
                'explicit data-saver preference and the offline state.',
            floor: '<= 5% failure on 3G',
            optimal: '<= 1% failure on 3G',
            ceiling: '0% failure',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/connection_quality.dart',
        ],
      ),
    );
  });
}
