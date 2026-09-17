/// AISS GATE -- Step 315 of 315
/// Global Reference ID:       RTVMA-016
/// Atomic Steps Reference ID: RTVMA-016
/// Setup Step (Action): "Freeze all interface form inputs and action buttons
///                      immediately when the timer reaches zero." (A LEVEL A
///                      FAILURE IN ITS OWN RIGHT -- SC 2.2.1)
/// Atomic Step: "Conduct a cross-browser accessibility test to ensure the
///               red-highlighting and error text meet contrast standards."
/// Metric: WCAG Contrast Ratio (1:1) -- floor 4.5, optimal 7, ceiling 21.
///         Pass/Fail. WCAG 2.1 Level AA.
///
/// 1:1 IS NO CONTRAST AT ALL. AND THERE IS NO BROWSER TO TEST ACROSS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/error_contrast_audit.dart';

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

  group('RTVMA-016 :: the name against the boundaries', () {
    gate(
      'RTVMA-016-G1',
      'Metric: "WCAG Contrast Ratio (1:1)".',
      'A ratio of 1:1 is two identical colours, 3.5 below the row\'s own '
          'floor of 4.5, and it is the single value at which the requirement '
          'cannot be met by anything',
      () =>
          HabotErrorContrastAudit.theNameContradictsTheBoundaries &&
          HabotErrorContrastAudit.nameImpliesRatio == 1.0 &&
          (HabotErrorContrastAudit.howFarBelowTheFloorTheNameIs - 3.5).abs() <
              1e-9 &&
          !HabotErrorContrastAudit.textIsVisibleAtTheNamedRatio,
    );

    gate(
      'RTVMA-016-G2',
      'The three boundaries are right.',
      '4.5 is the AA floor for body text, 7 is AAA, 21 is black on white; '
          'read as the specification it claims to be, the name asks for '
          'invisible text at Level AA',
      () =>
          HabotErrorContrastAudit.floor == 4.5 &&
          HabotErrorContrastAudit.optimal == 7.0 &&
          HabotErrorContrastAudit.ceiling == 21 &&
          HabotErrorContrastAudit.nameNote
              .contains('invisible text at Level AA'),
    );
  });

  group('RTVMA-016 :: the axis that exists', () {
    gate(
      'RTVMA-016-G3',
      'Atomic Step: "Conduct a cross-browser accessibility test".',
      'Flutter rasterises its own text: no user stylesheet, no browser zoom, '
          'no forced-colours mode reached through browser settings -- the '
          'twelfth foreign stack in this track',
      () =>
          !HabotErrorContrastAudit.thereIsABrowser &&
          HabotErrorContrastAudit.foreignStackNumber == 12,
    );

    gate(
      'RTVMA-016-G4',
      'And unlike most of them it translates.',
      'Three real axes -- scheme brightness, platform high contrast, '
          'platform inversion -- which change what the person sees without '
          'the application being consulted',
      () =>
          HabotErrorContrastAudit.theInstructionTranslates &&
          HabotErrorContrastAudit.axesThatExist.length == 3 &&
          HabotErrorContrastAudit.crossBrowserNote
              .contains('not three browsers'),
    );
  });

  group('RTVMA-016 :: the figures', () {
    gate(
      'RTVMA-016-G5',
      'Four scheme pairs, read from Step 306 rather than measured twice.',
      'All four clear the 4.5 floor, the weakest at 6.38',
      () =>
          HabotErrorContrastAudit.pairs.length == 4 &&
          HabotErrorContrastAudit.everyPairPassesAa &&
          HabotErrorContrastAudit.worstPair == 6.38 &&
          HabotErrorContrastAudit.theFiguresAreReadRatherThanRemeasured,
    );

    gate(
      'RTVMA-016-G6',
      'Three of the four reach the 7:1 optimal.',
      'And none approaches the ceiling, the best pair being 12.77',
      () =>
          HabotErrorContrastAudit.pairsAboveTheOptimal.length == 3 &&
          (HabotErrorContrastAudit.shareReachingTheOptimal - 0.75).abs() <
              1e-9 &&
          HabotErrorContrastAudit.pairsAtTheCeiling.isEmpty &&
          HabotErrorContrastAudit.bestPair == 12.77,
    );

    gate(
      'RTVMA-016-G7',
      'Ceiling 21 is the arithmetic maximum, not a design goal.',
      'Step 272 recorded why: at that ratio a light background bleeds into '
          'the glyph edges, and body text set that way is harder to read for '
          'several of the groups given as the reason for setting it',
      () =>
          !HabotErrorContrastAudit.theCeilingIsSomethingToAimFor &&
          HabotErrorContrastAudit.stepThatRecordedTheCeiling == 272 &&
          HabotErrorContrastAudit.ceilingNote.contains('halation'),
    );
  });

  group('RTVMA-016 :: red, for the fourth time', () {
    gate(
      'RTVMA-016-G8',
      'Atomic Step: "red-highlighting".',
      'Steps 300, 306 and 309 each reached SC 1.4.1 from a different '
          'direction, and this row makes four in one batch of twenty',
      () =>
          HabotErrorContrastAudit.fourRowsInOneBatchReachedTheSameCriterion &&
          HabotErrorContrastAudit.criterion.contains('1.4.1') &&
          !HabotErrorContrastAudit.colourIsTheSoleCarrier,
    );

    gate(
      'RTVMA-016-G9',
      'The pairing was settled at Step 309.',
      'A marker, a sentence, and the colour as reinforcement -- read from '
          'there rather than decided again',
      () => HabotErrorContrastAudit.theCarriers.contains('reinforcement'),
    );
  });

  group('RTVMA-016 :: the Setup Step, and the verdict', () {
    gate(
      'RTVMA-016-G10',
      'Setup Step: freeze inputs when the timer reaches zero.',
      'WCAG 2.1 SC 2.2.1 Timing Adjustable is Level A and requires a '
          'warning, a way to extend, and the work preserved -- because the '
          'people who run out of time are the ones who needed longer',
      () =>
          HabotErrorContrastAudit.setupStepLevel == 'A' &&
          HabotErrorContrastAudit.setupStepCriterion.contains('2.2.1') &&
          HabotErrorContrastAudit.theTimerObligationsAreNamed &&
          !HabotErrorContrastAudit.inputsAreFrozenWithoutWarning &&
          HabotErrorContrastAudit.setupStepNote.contains('needed longer'),
    );

    gate(
      'RTVMA-016-G11',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all eleven declared '
          'checks hold, and the row\'s access-control data column is recorded',
      () =>
          HabotErrorContrastAudit.obligations.length == 6 &&
          HabotErrorContrastAudit.obligations.values.every((bool b) => b) &&
          HabotErrorContrastAudit.qualitativeOutput == 'Pass' &&
          HabotErrorContrastAudit.checks.length == 11 &&
          HabotErrorContrastAudit.checks.values.every((bool b) => b) &&
          HabotErrorContrastAudit.columnNote.contains('signed URLs'),
    );
  });

  tearDownAll(() {
    final String weakest = HabotErrorContrastAudit.worstPair.toString();
    final String best = HabotErrorContrastAudit.bestPair.toString();
    final String belowOptimal =
        HabotErrorContrastAudit.pairs.entries
            .where((MapEntry<String, double> e) =>
                e.value < HabotErrorContrastAudit.optimal)
            .map((MapEntry<String, double> e) => e.key)
            .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RTVMA-016',
        atomicStepReferenceId: 'RTVMA-016',
        setupStepAction:
            'COLUMN NOTE: Data Collected on this row is an access-control '
            'vocabulary -- Access Type, User Role, Permission Level, Access '
            'Log, Access Timestamp -- every narrative column is about '
            'time-limited signed URLs for cloud storage, and the Setup Step '
            'reads "Freeze all interface form inputs and action buttons '
            'immediately when the timer reaches zero", which is a WCAG 2.1 SC '
            '2.2.1 failure at Level A. Atomic Step: "Conduct a cross-browser '
            'accessibility test to ensure the red-highlighting and error text '
            'meet contrast standards."',
        implementationOrder: 315,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Access Type': 'not applicable -- this row is about contrast',
          'User Role': 'not applicable',
          'Permission Level': 'not applicable',
          'Access Log':
              'the five access-control fields are this row\'s Data Collected '
                  'column and belong to a different subject',
          'Access Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Pass',
          'Component Properties':
              'four scheme pairs audited, weakest $weakest:1, best $best:1; '
                  'below the 7:1 optimal: $belowOptimal',
          'Data Quality Note':
              'NAME: ${HabotErrorContrastAudit.nameNote} '
              'BROWSER: ${HabotErrorContrastAudit.crossBrowserNote} '
              'CEILING: ${HabotErrorContrastAudit.ceilingNote} '
              'RED: ${HabotErrorContrastAudit.redNote} '
              'TIMER: ${HabotErrorContrastAudit.setupStepNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'WCAG Contrast Ratio (1:1)',
            observed:
                'All four audited pairs clear the 4.5 floor and three of the '
                'four clear the 7 optimal; the weakest is $weakest:1 and the '
                'best $best:1. The metric\'s NAME gives 1:1, which is two '
                'identical colours and 3.5 below the floor on the same row -- '
                'the first metric in this track whose name and boundaries '
                'contradict each other inside one cell. The ceiling of 21 is '
                'the formula\'s maximum and not a target, which Step 272 '
                'recorded.',
            floor: '4.5',
            optimal: '7',
            ceiling: '21',
          ),
          AissMeasurement(
            metricName: 'Axes a real version of this test would sweep',
            observed:
                '3 -- scheme brightness, platform high contrast, platform '
                'inversion -- in place of the browsers the row names, of '
                'which this application has none. The instruction translates, '
                'which most of the twelve foreign-stack rows in this track do '
                'not.',
            floor: '3',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/error_contrast_audit.dart',
        ],
      ),
    );
  });
}
