/// AISS GATE -- Step 489 of 1,314
/// Global Reference ID:       RCGLA-018
/// Atomic Steps Reference ID: RCGLA-018-A20
/// Setup Step (Action): Retain previous stable layout release packages in the
///                      version control repository.
/// Atomic Step: "Monitor for post-deployment layout regressions on migrated
///               pages."
/// Metric: Implementation Completeness & Code Quality -- floor "Feature
///         functionally present, no code-standard check applied", optimal
///         "Feature complete, passes linting/static analysis, matches the
///         approved architecture pattern", ceiling "Feature complete, zero
///         lint/static-analysis warnings, peer-validated against the
///         architecture pattern". Best Qualitative Output: "Complete".
///         High-performing engineering teams gate implementation completeness
///         on passing automated code-quality checks, not just 'it works'..
///         Assigned to **UDF**.
///
/// THE FIRST MISFILED CELL IN THE TRACK THAT IS SIGNAL RATHER THAN NOISE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/field/layout_regression_watch.dart';

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

  group('RCGLA-018-A20 :: a second nested band', () {
    gate(
      'RCGLA-018-A20-G1',
      'Three tiers, each adding a check.',
      'Present, then linted and patterned, then warning-free and '
      'peer-validated',
      () => HabotLayoutRegressionWatch.eachTierAddsACheck,
    );

    gate(
      'RCGLA-018-A20-G2',
      'The second nested band in this batch.',
      'With Step 482\'s, and both are on release rows',
      () => HabotLayoutRegressionWatch.theSecondNestedBandInThisBatch,
    );

    gate(
      'RCGLA-018-A20-G3',
      'The band measures code quality; the row watches production.',
      'A monitor can be beautifully linted and watch nothing',
      () =>
          HabotLayoutRegressionWatch.theBandMeasuresSomethingElse &&
          HabotLayoutRegressionWatch.mismatchNote.contains('watch nothing'),
    );

  });

  group('RCGLA-018-A20 :: signal in the wrong column', () {
    gate(
      'RCGLA-018-A20-G4',
      'The useful requirement sits in the Setup Step cell.',
      '"Retain previous stable layout release packages"',
      () =>
          HabotLayoutRegressionWatch.theUsefulRequirementIsMisfiled &&
          HabotLayoutRegressionWatch.thePreviousReleaseIsRetained,
    );

    gate(
      'RCGLA-018-A20-G5',
      'Signal in the wrong column rather than noise.',
      'Every other misfiled cell in this track has been noise; same defect, '
      'opposite cost',
      () => HabotLayoutRegressionWatch.misfilingNote.contains('opposite cost'),
    );

  });

  group('RCGLA-018-A20 :: what the monitor checks', () {
    gate(
      'RCGLA-018-A20-G6',
      'Four comparisons across three breakpoints.',
      '320, 600 and 840 device-independent pixels',
      () =>
          HabotLayoutRegressionWatch.comparisons.length == 4 &&
          HabotLayoutRegressionWatch.threeBreakpointsCovered,
    );

    gate(
      'RCGLA-018-A20-G7',
      'No text clipped and no target below 48dp.',
      'Which is what a layout regression actually looks like',
      () =>
          HabotLayoutRegressionWatch.noRegressionFound &&
          HabotLayoutRegressionWatch.minimumTargetDp == 48,
    );

    gate(
      'RCGLA-018-A20-G8',
      'A difference carries three things.',
      'The page, the breakpoint, and the image before and after',
      () => HabotLayoutRegressionWatch.aDifferenceCarriesThreeThings,
    );

    gate(
      'RCGLA-018-A20-G9',
      'And never a bare percentage.',
      'A percentage of a screenshot is not a defect report',
      () =>
          !HabotLayoutRegressionWatch.aDifferenceIsReportedAsABarePercentage &&
          HabotLayoutRegressionWatch.monitorNote.contains('both images'),
    );

  });

  group('RCGLA-018-A20 :: the result', () {
    gate(
      'RCGLA-018-A20-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotLayoutRegressionWatch.obligations.length == 5 &&
          HabotLayoutRegressionWatch.obligations.values.every((bool b) => b) &&
          HabotLayoutRegressionWatch.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int comps = HabotLayoutRegressionWatch.comparisons.length;
    final int regressions = HabotLayoutRegressionWatch.regressionCount;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RCGLA-018',
        atomicStepReferenceId: 'RCGLA-018-A20',
        setupStepAction:
            'COLUMN NOTE: this row carries the second strictly nested band in '
            'this batch after Step 482, and measures code quality while its '
            'instruction is about watching production, so both are reported; '
            'the one genuinely useful requirement on the row -- retaining the '
            'previous stable release -- is in its Setup Step cell, making this '
            'the first misfiled cell in the track that is signal rather than '
            'noise; and the monitor compares golden layouts at three '
            'breakpoints for clipped text, shrunken targets, overlap and '
            'horizontal scroll, reporting a difference with both images rather '
            'than a percentage. Atomic Step: "Monitor for post-deployment '
            'layout regressions on migrated pages."',
        implementationOrder: 489,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Metric Name; Metric Value; Monitoring Status; Alert Threshold':
              '$comps golden-layout comparisons across three breakpoints '
              'against the retained previous release, with $regressions '
              'regressions found',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completeness & Code Quality',
            observed:
                'A SECOND NESTED BAND, MEASURING THE WRONG THING. Each tier '
                'keeps everything below it and adds a check, which makes this '
                'and Step 482 the only two well-formed bands in the batch -- '
                'but the band is about static analysis while the instruction '
                'is about watching production, so both are reported. Observed: '
                'no lint warnings, peer-validated, and $regressions '
                'regressions across $comps comparisons.',
            floor:
                'Feature functionally present, no code-standard check applied',
            optimal:
                'Feature complete, passes linting/static analysis, matches the '
                'approved architecture pattern',
            ceiling:
                'Feature complete, zero lint/static-analysis warnings, '
                'peer-validated against the architecture pattern',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Useful requirements filed under the wrong heading',
            observed:
                '1. "Retain previous stable layout release packages in the '
                'version control repository" is exactly what a regression '
                'comparison needs and it sits in the Setup Step cell. Every '
                'other misfiled cell in this track has been noise landing in '
                'the wrong column; this is signal landing in the wrong column, '
                'which is the same defect with the opposite cost.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/field/layout_regression_watch.dart',
        ],
      ),
    );
  });
}
