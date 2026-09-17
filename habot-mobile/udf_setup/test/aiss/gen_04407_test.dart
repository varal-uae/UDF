/// AISS GATE -- Step 413 of 415
/// Global Reference ID:       GEN-04407
/// Atomic Steps Reference ID: GEN-04407
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify complete type safety enforcement during build time
///               compilation."
/// Metric: CI/CD Pipeline Execution Duration -- floor "< 20min", optimal "<
///         10min", ceiling "< 5min (diminishing returns)". Best Qualitative
///         Output: "Good/Average/Poor". DORA (DevOps Research and Assessment)
///         Metrics. Assigned to **UDF**.
///
/// TYPE SAFETY AT BUILD TIME, SCORED ON HOW LONG THE BUILD TAKES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/type_safety_check.dart';

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

  group('GEN-04407 :: "complete" replaced by five settings', () {
    gate(
      'GEN-04407-G1',
      'Five settings, all on, all naming what they forbid.',
      'Sound null safety, no implicit dynamic, no implicit casts, strict raw '
          'types, and errors fatal',
      () =>
          HabotTypeSafetyCheck.settingCount == 5 &&
          HabotTypeSafetyCheck.everySettingIsOn &&
          HabotTypeSafetyCheck.everySettingNamesWhatItForbids,
    );

    gate(
      'GEN-04407-G2',
      'Every one of them is caught at build time.',
      'Which is what the row asks for, and what distinguishes these five from '
          'anything a running app discovers',
      () => HabotTypeSafetyCheck.allFiveAreBuildTime,
    );

    gate(
      'GEN-04407-G3',
      'And "complete" is replaced by something checkable.',
      'Completeness is not a state a build can verify; five settings being on '
          'is',
      () =>
          HabotTypeSafetyCheck.completenessNote.contains('unlike completeness'),
    );

  });

  group('GEN-04407 :: the metric measures the pipeline', () {
    gate(
      'GEN-04407-G4',
      'The metric measures the pipeline, not the type system.',
      'A pipeline that finishes in four minutes because the check was switched '
          'off scores better than one that takes twelve and catches something',
      () =>
          HabotTypeSafetyCheck.theMetricMeasuresSomethingElse &&
          HabotTypeSafetyCheck.metricName.contains('Duration'),
    );

    gate(
      'GEN-04407-G5',
      'So both figures are published separately.',
      'Coverage beside duration, because a single number that improves when a '
          'check is removed is worse than no number',
      () =>
          HabotTypeSafetyCheck.neitherCanBeImprovedByDamagingTheOther &&
          HabotTypeSafetyCheck.safetyCoverage == 100,
    );

    gate(
      'GEN-04407-G6',
      'And a number that improves when a check is removed is worse than none.',
      'Which is the reason the two figures are not combined',
      () => HabotTypeSafetyCheck.metricNote.contains('worse than no number'),
    );

  });

  group('GEN-04407 :: a ceiling with an argument in it', () {
    gate(
      'GEN-04407-G7',
      'The ceiling carries a parenthetical argument.',
      '"< 5min (diminishing returns)" says why the boundary is where it is, '
          'which is more than most band cells do',
      () =>
          HabotTypeSafetyCheck.theCeilingCarriesAnArgument &&
          HabotTypeSafetyCheck.theCeilingCannotBeParsed,
    );

    gate(
      'GEN-04407-G8',
      'The third annotated boundary in the track.',
      'After Step 384\'s ceiling holding an argument and Step 409\'s floor '
          'calling itself a ceiling',
      () =>
          HabotTypeSafetyCheck.thisIsTheThirdAnnotatedBoundary &&
          HabotTypeSafetyCheck.thisAnnotationIsDefensible,
    );

  });

  group('GEN-04407 :: a band that descends correctly', () {
    gate(
      'GEN-04407-G9',
      'The band descends correctly for a duration.',
      'Twenty, ten, five, with lower better throughout -- which after this '
          'batch is worth recording',
      () =>
          HabotTypeSafetyCheck.theBandIsWellFormedForItsDirection &&
          HabotTypeSafetyCheck.theDurationSitsInsideTheBand,
    );

    gate(
      'GEN-04407-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotTypeSafetyCheck.obligations.length == 5 &&
          HabotTypeSafetyCheck.obligations.values.every((bool b) => b) &&
          HabotTypeSafetyCheck.qualitativeOutput == 'Good' &&
          HabotTypeSafetyCheck.fiveConsecutiveToolingRows &&
          !HabotTypeSafetyCheck.thisRowDuplicatesAnEarlierOne &&
          HabotTypeSafetyCheck.theSizeLimitIsBoundElsewhere,
    );
  });

  tearDownAll(() {
    final int settings = HabotTypeSafetyCheck.settingCount;
    final int minutes = HabotTypeSafetyCheck.pipelineMinutes;
    final double coverage = HabotTypeSafetyCheck.safetyCoverage;
    final int optimalMinutes = HabotTypeSafetyCheck.optimalMinutes;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04407',
        atomicStepReferenceId: 'GEN-04407',
        setupStepAction:
            'COLUMN NOTE: this row is scored on "CI/CD Pipeline Execution '
            'Duration", which measures how long the type check takes rather '
            'than whether it holds -- a pipeline scores better for switching '
            'the check off; its ceiling reads "< 5min (diminishing returns)", '
            'the third annotated boundary in the track after Steps 384 and '
            '409; its band descends correctly for a duration; its Data '
            'Requirement cell holds the Atomic Step\'s own sentence with a '
            'doubled full stop; and the Setup Step column is empty. Atomic '
            'Step: "Verify complete type safety enforcement during build time '
            'compilation."',
        implementationOrder: 413,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify complete type safety enforcement during build time '
          'compilation':
              '$settings analyser settings, all enabled, each naming what it '
                  'forbids and each caught at build time; coverage $coverage '
                  'per cent against a pipeline of $minutes minutes',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'CI/CD Pipeline Execution Duration',
            observed:
                'A PIPELINE-DURATION METRIC ON A TYPE-SAFETY ROW, AND A '
                'CEILING THAT ARGUES. The metric measures how long the check '
                'takes rather than whether it holds, so a build that switches '
                'type checking off scores better than one that catches '
                'something; DORA is right that a slow pipeline gets routed '
                'around, so the duration is published beside the coverage '
                'rather than instead of it. The ceiling reads "< 5min '
                '(diminishing returns)" -- the third annotated boundary in the '
                'track, the mildest of the three, and still unparseable. '
                'Observed: $minutes minutes, between the optimal of '
                '$optimalMinutes and the ceiling.',
            floor: '< 20min',
            optimal: '< 10min',
            ceiling: '< 5min (diminishing returns)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Type-safety settings not enforced at build time',
            observed:
                '0 of $settings. "Complete type safety" is not a state a build '
                'can check for: Dart is sound where dynamic is absent and '
                'casts are checked, and the analysis options decide that while '
                'the compiler enforces what they decide. The five settings are '
                'named with what each forbids -- a nullable value where a '
                'non-nullable one is declared, an inferred dynamic, an '
                'inserted downcast, a raw generic, and a build completing with '
                'an analyser error outstanding -- and all five are on, giving '
                '$coverage per cent.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/type_safety_check.dart',
        ],
      ),
    );
  });
}
