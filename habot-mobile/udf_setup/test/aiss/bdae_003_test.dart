/// AISS GATE -- Step 285 of 295
/// Global Reference ID:       BDAE-003
/// Atomic Steps Reference ID: BDAE-003
/// Setup Step (Action): "Launch the gamified mobile learning portal to the
///                      corporate app store." (DIFFERENT SUBJECT)
/// Atomic Step: "Set spatial gaps to standard metric increments for touch
///               targets."
/// Metric: WCAG 2.2 Touch Target & Contrast Compliance -- Floor "24x24px /
///         3:1", Optimal "48x48dp / 4.5:1", Ceiling ">=48dp / 7:1".
///         Pass / Fail.
///
/// A GAP IS NOT A SECOND REQUIREMENT, IT IS THE WAY OUT OF THE FIRST -- AND
/// THIS ROW'S FLOOR IS THE FIGURE STEP 276'S FLOOR GOT WRONG.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/spatial_gaps.dart';

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

  group('BDAE-003 :: the spacing exception', () {
    gate(
      'BDAE-003-G1',
      'Atomic Step: "spatial gaps ... for touch targets".',
      'SC 2.5.8 asks for a 24-point target OR enough space around a smaller '
          'one, so the rule is one predicate with two branches rather than '
          'two rules somebody has to remember to apply together',
      () =>
          HabotSpatialGaps.minimumTargetDp == 24 &&
          HabotSpatialGaps.exceptionNote.contains('half-applied'),
    );

    gate(
      'BDAE-003-G2',
      'A corpus where everything passes tests nothing.',
      'The predicate agrees with the expected verdict on every case, and the '
          'corpus contains one the criterion must refuse',
      () =>
          HabotSpatialGaps.classifierAccuracy == 1.0 &&
          HabotSpatialGaps.theCorpusContainsARefusal &&
          HabotSpatialGaps.corpus.length == 4,
    );

    gate(
      'BDAE-003-G3',
      'Small and spaced passes; small and crowded does not.',
      'An 18-point inline link with 12 points around it passes on spacing, '
          'and two 20-point chips two points apart fail with no size change '
          'that would rescue them',
      () =>
          HabotSpatialGaps.theInlineLinkIsSavedBySpacing &&
          HabotSpatialGaps.theCrowdedChipsFail,
    );

    gate(
      'BDAE-003-G4',
      'The corpus is a test, not a population.',
      'Three of the four cases pass, and that share is published beside the '
          'classifier accuracy with the distinction stated -- the line Step '
          '262 drew for attachment validation',
      () =>
          HabotSpatialGaps.passing.length == 3 &&
          (HabotSpatialGaps.shareOfTheCorpusThatPasses - 0.75).abs() < 1e-9 &&
          HabotSpatialGaps.corpusIsNotAPopulationNote
              .contains('tests nothing'),
    );
  });

  group('BDAE-003 :: increments, citations and bundles', () {
    gate(
      'BDAE-003-G5',
      'Atomic Step: "standard metric increments".',
      'The increment is already declared -- an 8-point baseline with a '
          '4-point sub-baseline -- and every value on the scale is measured '
          'against it rather than against the phrase',
      () =>
          HabotSpatialGaps.everyValueIsOnTheGrid &&
          HabotSpatialGaps.mostValuesAreOnTheBaseline &&
          HabotSpatialGaps.baseline == 8 &&
          HabotSpatialGaps.subBaseline == 4,
    );

    gate(
      'BDAE-003-G6',
      'This row and Step 276 cite the same standard and disagree.',
      'This one says 24x24 for Level AA, which is SC 2.5.8 exactly; Step 276 '
          'says 44 for AA, which is the AAA figure. They cannot both be '
          'right, and the pair is recorded together',
      () =>
          HabotSpatialGaps.theTwoRowsDisagreeAboutAa &&
          HabotSpatialGaps.thisRowsFloorIsTheCorrectAaFigure &&
          HabotSpatialGaps.disagreementNote
              .contains('cannot both be right'),
    );

    gate(
      'BDAE-003-G7',
      'The band mixes px and dp inside one cell.',
      'Floor in px, optimal and ceiling in dp, for the same quantity; read as '
          'points and recorded rather than converted',
      () => HabotSpatialGaps.unitsNote.contains('inside one'),
    );

    gate(
      'BDAE-003-G8',
      'Two success criteria, one Pass/Fail.',
      'Target size and contrast are evaluated separately so a failure says '
          'which one failed, demonstrated on a low-contrast case rather than '
          'argued',
      () =>
          HabotSpatialGaps.oneVerdictHidesWhichHalfFailed &&
          HabotSpatialGaps.bundledCriteriaNote
              .contains('which half is wrong') &&
          HabotSpatialGaps.contrastFloor == 3 &&
          HabotSpatialGaps.contrastOptimal == 4.5 &&
          HabotSpatialGaps.contrastCeiling == 7,
    );

    gate(
      'BDAE-003-G9',
      'Output: Pass / Fail.',
      'All twelve declared checks hold and the step reports Pass, on the '
          'classifier and the grid rather than on a corpus chosen to include '
          'a failure; the row\'s other columns are recorded as a different '
          'subject',
      () =>
          HabotSpatialGaps.checks.length == 12 &&
          HabotSpatialGaps.checks.values.every((bool b) => b) &&
          HabotSpatialGaps.qualitativeOutput == 'Pass' &&
          HabotSpatialGaps.wrongRowNote.contains('two rows'),
    );
  });

  tearDownAll(() {
    final String onBaseline = '${HabotSpatialGaps.onTheBaseline.length}';
    final String onSub = '${HabotSpatialGaps.onTheSubBaselineOnly.length}';
    final String scale = '${HabotSpatialGaps.scale.length}';
    final String saved = '${HabotSpatialGaps.savedByTheirSpacing.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BDAE-003',
        atomicStepReferenceId: 'BDAE-003',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Launch the '
            'gamified mobile learning portal to the corporate app store", and '
            'every narrative column is about TLS 1.3 and edge load balancers. '
            'Atomic Step: "Set spatial gaps to standard metric increments for '
            'touch targets."',
        implementationOrder: 285,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSpatialGaps / HabotControlGap',
          'Component Properties':
              '$scale spacing values, $onBaseline on the 8-point baseline and '
              '$onSub on the 4-point sub-baseline; '
              '${HabotSpatialGaps.corpus.length} classified controls of which '
              '$saved pass on spacing alone; target size and contrast '
              'evaluated separately',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSpatialGaps.exceptionNote} '
              'DISAGREEMENT: ${HabotSpatialGaps.disagreementNote} '
              'BUNDLE: ${HabotSpatialGaps.bundledCriteriaNote} '
              'UNITS: ${HabotSpatialGaps.unitsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'WCAG 2.2 Touch Target & Contrast Compliance',
            observed:
                'Target size is decided by one predicate with two branches, '
                'which agrees with every expected verdict across four cases '
                'including the one it must refuse. Contrast is evaluated '
                'separately, so a combined failure says which half failed. '
                'This row\'s 24x24 floor is the correct Level AA figure; Step '
                '276\'s 44 is the AAA figure labelled AA.',
            floor: '24x24px / 3:1',
            optimal: '48x48dp / 4.5:1',
            ceiling: '>=48dp / 7:1',
          ),
          AissMeasurement(
            metricName: 'Spacing values off the declared grid',
            observed:
                '0 of $scale. Seven are multiples of the 8-point baseline and '
                'two are the 4-point sub-baseline and its odd multiple, which '
                'is why the sub-baseline exists.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/spatial_gaps.dart',
        ],
      ),
    );
  });
}
