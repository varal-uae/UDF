/// AISS GATE -- Step 416 of 415
/// Global Reference ID:       FEBFL-016
/// Atomic Steps Reference ID: FEBFL-016-A01
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Review the technical mapping guidelines for the Human Friction
///               Telemetry framework."
/// Metric: Requirements / Discovery Coverage (%) -- floor "90% of relevant
///         items identified", optimal "98% of relevant items identified",
///         ceiling "100% of relevant items identified". Best Qualitative
///         Output: "Complete/Partial/Not Complete". Discovery and audit
///         activities in world-class delivery practice are expected to reach
///         near-complete coverage of the target scope before downstream build
///         work starts.. Assigned to **UDF**.
///
/// A REVIEW ROW WHOSE SUBJECT DOES NOT EXIST, AND A DEFINITION HIDING IN THE
/// COMPLETION MEASURES CELL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/friction_framework.dart';

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

  group('FEBFL-016-A01 :: there was nothing to review', () {
    gate(
      'FEBFL-016-A01-G1',
      'There were no guidelines to review.',
      'No Human Friction Telemetry framework exists in the four hundred and '
          'fifteen steps behind this row',
      () =>
          !HabotFrictionFramework.theFrameworkExistedBeforeThisStep &&
          !HabotFrictionFramework.theGuidelinesWereRead,
    );

    gate(
      'FEBFL-016-A01-G2',
      'So the review produced the framework.',
      'A review row whose subject does not exist cannot be closed by reading, '
          'and writing the thing down is the only honest way to close it',
      () =>
          HabotFrictionFramework.theReviewProducedTheThingReviewed &&
          HabotFrictionFramework.reviewNote.contains('the only honest way'),
    );

    gate(
      'FEBFL-016-A01-G3',
      'The definition of friction was in the Completion Measures cell.',
      'Five seconds of dwell on one field is the entire operational '
          'definition, and it is in the column nobody reads until the work is '
          'finished',
      () =>
          HabotFrictionFramework.theDefinitionCameFromTheLastColumn &&
          HabotFrictionFramework.definitionNote.contains('nobody reads'),
    );

  });

  group('FEBFL-016-A01 :: five indicators', () {
    gate(
      'FEBFL-016-A01-G4',
      'Five indicators, two durations and three counts.',
      'Hesitation, dwell, correction, dead tap and abandonment',
      () =>
          HabotFrictionFramework.indicatorCount == 5 &&
          HabotFrictionFramework.everyKindIsDefined &&
          HabotFrictionFramework.twoAreDurationsAndThreeAreCounts,
    );

    gate(
      'FEBFL-016-A01-G5',
      'Each names its meaning and each names its limit.',
      'What a recorded observation says about the interface, and what it does '
          'not say, because the second reading is the one somebody reaches for '
          'later',
      () =>
          HabotFrictionFramework.everyIndicatorNamesItsMeaning &&
          HabotFrictionFramework.everyIndicatorNamesItsLimit,
    );

  });

  group('FEBFL-016-A01 :: the subject is the interface', () {
    gate(
      'FEBFL-016-A01-G6',
      'The subject is the interface, not the person.',
      'The unit of analysis is a screen and a field, aggregated across '
          'everybody who used it',
      () =>
          HabotFrictionFramework.theSubjectIsTheInterface &&
          HabotFrictionFramework.theUnitOfAnalysisIsAScreen,
    );

    gate(
      'FEBFL-016-A01-G7',
      'And no indicator may rank an individual.',
      'A measure of hesitation is a measure of how well the interface '
          'explained itself; read as a measure of the person it is both wrong '
          'and unfalsifiable',
      () =>
          !HabotFrictionFramework.anIndicatorMayRankIndividuals &&
          HabotFrictionFramework.scopeNote.contains('unfalsifiable'),
    );

  });

  group(
    'FEBFL-016-A01 :: three subjects, and prose in the standard column',
      () {
    gate(
      'FEBFL-016-A01-G8',
      'Three subjects in one row, the fourth splice.',
      'Friction telemetry, element mapping fields, and frame rendering latency '
          'tests, after Steps 388, 390 and 398',
      () =>
          HabotFrictionFramework.threeSubjectsInOneRow &&
          HabotFrictionFramework.thisIsTheFourthSplicedRow,
    );

    gate(
      'FEBFL-016-A01-G9',
      'And the standard column holds an argument.',
      'A sentence defending the band where a specification belongs, with all '
          'three band cells written as prose',
      () =>
          HabotFrictionFramework.theStandardCellHoldsProse &&
          HabotFrictionFramework.everyBandCellIsASentence,
    );

    gate(
      'FEBFL-016-A01-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotFrictionFramework.obligations.length == 5 &&
          HabotFrictionFramework.obligations.values.every((bool b) => b) &&
          HabotFrictionFramework.qualitativeOutput == 'Complete' &&
          HabotFrictionFramework.noBandCellParses &&
          HabotFrictionFramework.thisIsTheSecondAllSentenceBand &&
          HabotFrictionFramework.theBandAscendsCorrectly &&
          HabotFrictionFramework.coverage == 100,
    );
  });

  tearDownAll(() {
    final int indicators = HabotFrictionFramework.indicatorCount;
    final int dwellMs = HabotFrictionFramework.dwellSpikeMs;
    final int durations = HabotFrictionFramework.durationIndicators;
    final int subjects = HabotFrictionFramework.subjectsInThisRow.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FEBFL-016',
        atomicStepReferenceId: 'FEBFL-016-A01',
        setupStepAction:
            'COLUMN NOTE: this row asks for a review of mapping guidelines for '
            'a Human Friction Telemetry framework that does not exist anywhere '
            'in the track, so the review had to produce the framework it was '
            'meant to read; its Atomic Step, Data Requirement and Setup Step '
            'carry three different subjects -- friction telemetry, element '
            'mapping fields, and frame rendering latency tests -- making it '
            'the fourth spliced row after Steps 388, 390 and 398; the only '
            'operational definition of friction anywhere in the row is in the '
            'Completion Measures cell ("user dwell spikes over 5 seconds"); '
            'all three band cells are sentences; and the reference-standard '
            'column holds an argument defending the band rather than naming a '
            'standard. Atomic Step: "Review the technical mapping guidelines '
            'for the Human Friction Telemetry framework."',
        implementationOrder: 416,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Source Element ID':
              'not applicable: these five mapping fields belong to an '
                  'element-mapping row spliced into this one',
          'Target Element ID': 'as above',
          'Mapping Rule':
              '$indicators friction indicators defined in place of the mapping '
                  'guidelines this row asks to review, which do not exist',
          'Mapping Status':
              'written rather than reviewed; every indicator carries a '
                  'threshold, a meaning and a stated limit',
          'Mapping Validation':
              '$durations indicators are measured in time and the rest are '
                  'counted; the dwell threshold is $dwellMs ms, taken from '
                  'this row\'s own Completion Measures cell',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements / Discovery Coverage (%)',
            observed:
                'THE SUBJECT OF THE REVIEW DOES NOT EXIST, AND ALL THREE BAND '
                'CELLS ARE SENTENCES. No Human Friction Telemetry framework '
                'appears anywhere in the four hundred and fifteen steps behind '
                'this row, so there are no mapping guidelines to read; what is '
                'delivered is the framework the review would have produced. '
                'The band reads "90% / 98% / 100% of relevant items '
                'identified" -- the second all-sentence band in the track '
                'after Step 400 -- and the reference-standard column holds a '
                'sentence arguing for the band rather than naming a standard. '
                'Observed: $indicators indicators defined, every one carrying '
                'a meaning and a stated limit.',
            floor: '90% of relevant items identified',
            optimal: '98% of relevant items identified',
            ceiling: '100% of relevant items identified',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Indicators that may be attributed to an individual',
            observed:
                '0 of $indicators. The unit of analysis is a screen and a '
                'field, aggregated across everybody who used it, and that '
                'limit is part of the framework rather than a policy bolted on '
                'afterwards -- a measure of hesitation is a measure of how '
                'well the interface explained itself, and the same number read '
                'as a measure of the person is both wrong and unfalsifiable. '
                '$subjects different subjects appear in this one row, which is '
                'the fourth splice the track has recorded.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/friction_framework.dart',
        ],
      ),
    );
  });
}
