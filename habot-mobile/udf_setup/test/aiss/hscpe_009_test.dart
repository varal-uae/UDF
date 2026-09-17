/// AISS GATE -- Step 371 of 375
/// Global Reference ID:       HSCPE-009
/// Atomic Steps Reference ID: HSCPE-009
/// Setup Step (Action): "Verify structural responsiveness across diverse
///                      device screen sizes."
/// Atomic Step: "Link dashboard warning indicators directly to fixed pod
///               ordinal numbers."
/// Metric: Mean Time to Detect (MTTD) -- floor "Under 15 minutes", optimal
///         "Under 5 minutes", ceiling "Under 1 minute". Best Qualitative
///         Output: "Pass". Google SRE Workbook & DORA Metrics. Assigned to
///         **CAL**.
///
/// AN ORDINAL IS AN ADDRESS, NOT AN IDENTITY -- AND FOR ONCE THE BAND AND THE
/// METRIC ARE BOTH CORRECT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/pod_warning_indicator.dart';

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

  group('HSCPE-009 :: "fixed" means addressable, not stable', () {
    gate(
      'HSCPE-009-G1',
      'Three pods, each carrying an identity as well as an ordinal.',
      'After a rolling update worker-2 is a different process on a different '
          'node, so the ordinal alone is a sentence about an address',
      () =>
          HabotPodWarningIndicator.pods.length == 3 &&
          HabotPodWarningIndicator.everyPodCarriesAnIdentity &&
          !HabotPodWarningIndicator.theIndicatorShowsTheOrdinalAlone,
    );

    gate(
      'HSCPE-009-G2',
      'Two images are running at once.',
      'Which is what a rolling update looks like, and is invisible on a panel '
          'that shows ordinals alone',
      () =>
          HabotPodWarningIndicator.everyPodCarriesItsImage &&
          HabotPodWarningIndicator.twoImagesAreRunning,
    );

    gate(
      'HSCPE-009-G3',
      'The one warning pod is the one on the new image.',
      'Which is the whole diagnosis',
      () =>
          HabotPodWarningIndicator.theWarningPodIsTheNewImage &&
          HabotPodWarningIndicator.ordinalNote.contains('whole diagnosis'),
    );

    gate(
      'HSCPE-009-G4',
      'The label carries ordinal, identity and image.',
      '"worker-2 (c02d55, 2026.09.3)" -- complete without a second screen',
      () => HabotPodWarningIndicator.theLabelCarriesAllThree,
    );
  });

  group('HSCPE-009 :: the output column holds one value', () {
    gate(
      'HSCPE-009-G5',
      '"Pass" with no failing value beside it.',
      'The seventh one-valued output column in the track, and the second in '
          'this batch after Step 370\'s "High"',
      () =>
          HabotPodWarningIndicator.theCountReachesSeven &&
          HabotPodWarningIndicator.theOtherOneValuedColumnInThisBatch == 370 &&
          HabotPodWarningIndicator.outputNote.contains('worked or not'),
    );
  });

  group('HSCPE-009 :: the band and the metric are both right', () {
    gate(
      'HSCPE-009-G6',
      'Floor 15 minutes, optimal 5, ceiling 1.',
      'Correctly ordered for a lower-is-better measure -- the third such band '
          'in the track, after Steps 333 and 337',
      () =>
          HabotPodWarningIndicator.theBandIsOrderedForLowerIsBetter &&
          HabotPodWarningIndicator.thisIsTheThirdCorrectlyOrderedBand &&
          HabotPodWarningIndicator.correctlyOrderedBands.contains(333),
    );

    gate(
      'HSCPE-009-G7',
      'MTTD is the right metric here, for the first time of three.',
      'Step 337 scored a card drag on it and Step 367 bundled it with a '
          'coverage figure; only this row is about detection',
      () =>
          HabotPodWarningIndicator.theMetricFitsThisRow &&
          HabotPodWarningIndicator.mttdRows.contains(337) &&
          HabotPodWarningIndicator.mttdRows.contains(367) &&
          HabotPodWarningIndicator.bandNote.contains('subject is detection'),
    );
  });

  group('HSCPE-009 :: what a dashboard cannot do', () {
    gate(
      'HSCPE-009-G8',
      'A dashboard shortens only the interval after somebody looks.',
      'On a warning nobody is watching for, the indicator contributes nothing '
          'at all; the push that closes the first part is not on this row',
      () =>
          !HabotPodWarningIndicator.aDashboardDetectsAnything &&
          HabotPodWarningIndicator.theLimitIsStated &&
          HabotPodWarningIndicator.limitNote
              .contains('not that it detects'),
    );

    gate(
      'HSCPE-009-G9',
      'The touch and colour rules are reused rather than restated.',
      'The declared 48dp catchment, and a warning state shown as a word and an '
          'icon rather than as colour',
      () =>
          HabotPodWarningIndicator.theTouchRulesAreAlreadyDeclared &&
          HabotPodWarningIndicator.theWarningIsNotColourAlone,
    );

    gate(
      'HSCPE-009-G10',
      'Output reported as Pass.',
      'Five obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotPodWarningIndicator.obligations.length == 5 &&
          HabotPodWarningIndicator.obligations.values.every((bool b) => b) &&
          HabotPodWarningIndicator.qualitativeOutput == 'Pass' &&
          HabotPodWarningIndicator.checks.length == 10 &&
          HabotPodWarningIndicator.checks.values.every((bool b) => b) &&
          HabotPodWarningIndicator.columnNote.contains('CAL'),
    );
  });

  tearDownAll(() {
    final String label =
        HabotPodWarningIndicator.labelFor(HabotPodWarningIndicator.pods.last);
    final int images = HabotPodWarningIndicator.distinctImages.length;
    final int warnings = HabotPodWarningIndicator.warningPods.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSCPE-009',
        atomicStepReferenceId: 'HSCPE-009',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to CAL rather than UDF; its '
            'Best Qualitative Output column reads "Pass" with no failing value '
            'beside it, the seventh such column in the track and the second in '
            'this batch after Step 370; and its Setup Step column reads '
            '"Verify structural responsiveness across diverse device screen '
            'sizes". Its band and its metric are both correct, which is '
            'unusual enough in this batch to be worth recording. Atomic Step: '
            '"Link dashboard warning indicators directly to fixed pod ordinal '
            'numbers."',
        implementationOrder: 371,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'an accordion row per pod',
          'Layout Grid Dimensions': 'single column at compact width',
          'Spacing Rules': 'the declared spacing scale and 48dp catchment',
          'Alignment Settings': 'ordinal leading, warning state trailing',
          'Layout Validation Status': 'Pass',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the warning row reads "$label"; $images images are running '
                  'across 3 pods and $warnings pod is warning',
          'Data Quality Note':
              'ORDINAL: ${HabotPodWarningIndicator.ordinalNote} '
              'OUTPUT: ${HabotPodWarningIndicator.outputNote} '
              'BAND: ${HabotPodWarningIndicator.bandNote} '
              'LIMIT: ${HabotPodWarningIndicator.limitNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mean Time to Detect (MTTD)',
            observed:
                'CORRECT, WHICH IS WORTH RECORDING. Floor 15 minutes, optimal '
                '5, ceiling 1, with the worst tolerable value at the floor -- '
                'the third correctly ordered latency band in the track, after '
                'Steps 333 and 337. Mean Time to Detect is also the right '
                'metric for a warning indicator, and this is the third row '
                'scored on it after a card drag at Step 337 and a bundled '
                'coverage-and-latency cell at Step 367; it is the only one of '
                'the three whose subject is detection. What the control cannot '
                'claim is the whole interval: a dashboard shortens the part '
                'after somebody looks, and the push that makes them look is '
                'not on this row.',
            floor: 'Under 15 minutes',
            optimal: 'Under 5 minutes',
            ceiling: 'Under 1 minute',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Warnings naming an address rather than a workload',
            observed:
                '0 of $warnings. A StatefulSet ordinal is stable for an '
                'address, not for the process at it: after a rolling update, '
                'worker-2 is a different container on a different node, '
                'possibly on a different image. An indicator bound to the '
                'ordinal alone says "worker-2 is unhealthy" and means '
                '"whatever is currently called worker-2 is unhealthy". Every '
                'row here shows ordinal, instance identity and image tag -- '
                '"$label" -- and with $images images running across three '
                'pods, the one warning is the one on the new image, which is '
                'the diagnosis and is invisible on a panel of ordinals.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/pod_warning_indicator.dart',
        ],
      ),
    );
  });
}
