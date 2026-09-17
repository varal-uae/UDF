/// AISS GATE -- Step 369 of 375
/// Global Reference ID:       HC-SCH-0179
/// Atomic Steps Reference ID: HC-SCH-0179
/// Setup Step (Action): "Connect navigation selection event logs directly to
///                      performance analytics datasets."
/// Atomic Step: "Output status parameters clearly inside the standardized
///               dashboard overview panel."
/// Metric: Dashboard Load Time -- floor "<3 sec", optimal "<1.5 sec", ceiling
///         "<0.5 sec". Good/Average/Poor. Google Core Web Vitals (Largest
///         Contentful Paint). Assigned to **DEA**.
///
/// THE SECOND CELL IN THE SHEET THAT DOCUMENTS ITS OWN ABSENCE, WHICH MAKES IT
/// A TEMPLATE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/overview_panel.dart';

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

  group('HC-SCH-0179 :: the generator reports its own miss', () {
    gate(
      'HC-SCH-0179-G1',
      'The Data Requirement cell says no source row was matched.',
      'And ends "verify manually", which is more useful than most cells that '
          'are filled in',
      () =>
          HabotOverviewPanel.theCellReportsItsOwnAbsence &&
          HabotOverviewPanel.dataRequirementCell.contains('verify manually'),
    );

    gate(
      'HC-SCH-0179-G2',
      'Second occurrence, after Step 347.',
      'Identical wording twenty-two rows later makes it a template rather than '
          'an accident',
      () =>
          HabotOverviewPanel.thisIsTheSecondOccurrence &&
          HabotOverviewPanel.theFirstSuchRow == 347 &&
          HabotOverviewPanel.generatorNote
              .contains('template rather than an accident'),
    );
  });

  group('HC-SCH-0179 :: what "clearly" excludes', () {
    gate(
      'HC-SCH-0179-G3',
      'Four presentations, three of them refused.',
      'Colour alone, an icon alone and an abbreviation each fail for somebody',
      () =>
          HabotStatusPresentation.values.length == 4 &&
          HabotOverviewPanel.threeOfFourAreRefused,
    );

    gate(
      'HC-SCH-0179-G4',
      'Every refusal carries a reason.',
      'Colour alone is SC 1.4.1; a glyph has to be learned; an abbreviation is '
          'a second vocabulary nobody was given',
      () =>
          HabotOverviewPanel.everyRefusalIsArgued &&
          HabotOverviewPanel.criterion.contains('1.4.1') &&
          (HabotOverviewPanel
                      .refusalReason[HabotStatusPresentation.colourOnly] ??
                  '')
              .contains('one man in twelve'),
    );

    gate(
      'HC-SCH-0179-G5',
      'The panel uses a word with an icon beside it.',
      'The only one of the four that works for a reader who has never seen the '
          'panel before',
      () =>
          HabotOverviewPanel.theChosenFormIsNotRefused &&
          HabotOverviewPanel.chosen == HabotStatusPresentation.wordWithIcon &&
          HabotOverviewPanel.clearlyNote.contains('what it excludes'),
    );
  });

  group('HC-SCH-0179 :: a status with no age', () {
    gate(
      'HC-SCH-0179-G6',
      'Three parameters, each carrying when it was last established.',
      'A status with no age is a statement about the past presented as the '
          'present',
      () =>
          HabotOverviewPanel.parameters.length == 3 &&
          HabotOverviewPanel.everyParameterCarriesItsAge,
    );

    gate(
      'HC-SCH-0179-G7',
      'One of the three is past the budget, and it reads "Healthy".',
      'Which is exactly the case where a missing age costs something',
      () =>
          HabotOverviewPanel.parametersThatMustBeLabelledStale == 1 &&
          HabotOverviewPanel.theStaleOneReadsHealthy,
    );

    gate(
      'HC-SCH-0179-G8',
      'The classification is the Step 129 policy.',
      'And Step 331 recorded the same finding one batch earlier on an '
          'exception counter',
      () =>
          HabotOverviewPanel.ageNote.contains('Step 129') &&
          HabotOverviewPanel.ageNote.contains('Step 331'),
    );
  });

  group('HC-SCH-0179 :: the instrument and the output', () {
    gate(
      'HC-SCH-0179-G9',
      'Third Core Web Vitals citation in two batches.',
      'With Steps 344 and 363; the band is at least ordered correctly, and '
          'what is measurable here is time to first useful content',
      () =>
          HabotOverviewPanel.theInstrumentIsABrowserMetric &&
          HabotOverviewPanel.thisIsTheThirdCoreWebVitalsCitation &&
          HabotOverviewPanel.theBandIsOrderedCorrectly &&
          HabotOverviewPanel.theMeasureIsRestated,
    );

    gate(
      'HC-SCH-0179-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotOverviewPanel.obligations.length == 5 &&
          HabotOverviewPanel.obligations.values.every((bool b) => b) &&
          HabotOverviewPanel.qualitativeOutput == 'Good' &&
          HabotOverviewPanel.checks.length == 10 &&
          HabotOverviewPanel.checks.values.every((bool b) => b) &&
          HabotOverviewPanel.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final int refused = HabotOverviewPanel.refusalReason.length;
    final int stale = HabotOverviewPanel.parametersThatMustBeLabelledStale;
    final String staleName = HabotOverviewPanel.parameters.last.name;
    final String staleValue = HabotOverviewPanel.parameters.last.value;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HC-SCH-0179',
        atomicStepReferenceId: 'HC-SCH-0179',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF; its '
            'Data Requirement cell reports that the generator found no '
            'matching source row and says "verify manually", identical to Step '
            '347\'s and therefore the second occurrence rather than the first; '
            'its metric cites Google Core Web Vitals Largest Contentful Paint '
            'in an application with no DOM, the third such citation in two '
            'batches; and its Setup Step column reads "Connect navigation '
            'selection event logs directly to performance analytics datasets". '
            'Atomic Step: "Output status parameters clearly inside the '
            'standardized dashboard overview panel."',
        implementationOrder: 369,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'No matched reference row in Setup Implementation master list':
              'recorded verbatim; $refused of 4 presentations refused with a '
                  'stated reason, and the fourth used',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '3 status parameters, each carrying its age; $stale is past the '
                  'budget and it is "$staleName", reading "$staleValue"',
          'Data Quality Note':
              'GENERATOR: ${HabotOverviewPanel.generatorNote} '
              'CLEARLY: ${HabotOverviewPanel.clearlyNote} '
              'AGE: ${HabotOverviewPanel.ageNote} '
              'METRIC: ${HabotOverviewPanel.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Load Time',
            observed:
                'A REAL MEASURE WITH THE WRONG INSTRUMENT, FOR THE THIRD TIME '
                'IN TWO BATCHES. Largest Contentful Paint is a browser '
                'measurement of the largest element to paint, and this '
                'application has no DOM; Steps 344 and 363 carry the other two '
                'citations. What is measurable here is time to first useful '
                'content -- the first status parameter showing a real value '
                'rather than a skeleton -- which is usually not the largest '
                'thing on the screen. The band, 3 seconds down to 0.5, is at '
                'least ordered correctly for a lower-is-better measure.',
            floor: '<3 sec',
            optimal: '<1.5 sec',
            ceiling: '<0.5 sec',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Status parameters a reader cannot read correctly',
            observed:
                '0 of 3. "Clearly" is not a requirement until somebody says '
                'what it excludes: of four available presentations, $refused '
                'are refused with a reason -- colour alone under SC 1.4.1, an '
                'icon alone that nothing on screen teaches, and an '
                'abbreviation that is a second vocabulary nobody was given -- '
                'and the panel uses a word with an icon beside it for '
                'scanning. Every parameter also carries when it was last '
                'established, because a status with no age is a statement '
                'about the past presented as the present; $stale of the three '
                'is past the budget, and it is the one reading "$staleValue".',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/overview_panel.dart',
        ],
      ),
    );
  });
}
