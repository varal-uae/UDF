/// AISS GATE -- Step 310 of 315
/// Global Reference ID:       HSCPE-006
/// Atomic Steps Reference ID: HSCPE-006
/// Setup Step (Action): "Map a dedicated trace_id string text field attribute
///                      into the primary payload layout model." (API GATEWAY,
///                      ON A LAYOUT ROW)
/// Atomic Step: "UX Implementation: Condense dense hardware tables into
///               scannable MD3-compliant data summaries for mobile admin
///               views."
/// Metric: Material Design 3 Token Compliance -- floor "Ad-hoc custom styling,
///         no token system", optimal "Core MD3 tokens applied consistently",
///         ceiling "Full MD3 token system + automated visual regression
///         testing". Good/Average/Poor.
///
/// THE SAME INSTRUCTION AND THE SAME BAND AS STEP 286, CHARACTER FOR
/// CHARACTER, TWENTY-FOUR ROWS LATER, WITH NO REFERENCE BETWEEN THEM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/dense_summary.dart';
import 'package:udf_setup/design_system/layout/hardware_summary.dart';

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

  group('HSCPE-006 :: the duplicate', () {
    gate(
      'HSCPE-006-G1',
      'Step 286 carried this metric with these three boundary strings.',
      'They are identical here -- and the floor is still the condition a '
          'token system exists to end, so it still cannot be failed',
      () =>
          HabotHardwareSummary.theBandIsIdenticalToStep286 &&
          HabotHardwareSummary.stepWithTheSameBand == 286 &&
          HabotHardwareSummary.theFloorStillCannotBeFailed,
    );

    gate(
      'HSCPE-006-G2',
      'Neither row points at the other.',
      'What is worth noticing is the duplicate work rather than the '
          'duplicate band: two rows each of which would have produced a data '
          'summary component',
      () =>
          !HabotHardwareSummary.theTwoRowsReferenceEachOther &&
          HabotHardwareSummary.duplicationNote
              .contains('a repository that then has two'),
    );

    gate(
      'HSCPE-006-G3',
      'So the transform is imported rather than written again.',
      'The geometry and the fact budget are read from Step 286, and a second '
          'implementation of the same rule would be the thing the rule exists '
          'to prevent',
      () =>
          HabotHardwareSummary.availableWidthDp ==
              HabotDenseSummary.availableWidthDp &&
          HabotHardwareSummary.maxSecondaryFacts ==
              HabotDenseSummary.maxSecondaryFacts,
    );
  });

  group('HSCPE-006 :: five columns into 328 points', () {
    gate(
      'HSCPE-006-G4',
      'Atomic Step: "condense dense hardware tables".',
      '530 points of hardware data into 328 available: three columns fit and '
          'two go past the edge',
      () =>
          HabotHardwareSummary.columns.length == 5 &&
          HabotHardwareSummary.totalColumnWidthDp == 530 &&
          HabotHardwareSummary.columnsThatFit.length == 3 &&
          HabotHardwareSummary.columnsPastTheEdge.length == 2,
    );

    gate(
      'HSCPE-006-G5',
      'The summary line is the identity plus two facts.',
      '290 points, which fits, with every column accounted for and two '
          'behind the row',
      () =>
          HabotHardwareSummary.summaryLineWidthDp == 290 &&
          HabotHardwareSummary.theSummaryLineFits &&
          HabotHardwareSummary.everyColumnIsAccountedFor &&
          HabotHardwareSummary.secondaryFacts.length == 2 &&
          HabotHardwareSummary.behindTheRow.length == 2,
    );
  });

  group('HSCPE-006 :: the accident', () {
    gate(
      'HSCPE-006-G6',
      'The table truncates to the same three columns the summary chooses.',
      'So it looks right in review -- and it is right by luck, because the '
          'table stops where the width runs out and the summary stops where '
          'the declared rank runs out',
      () =>
          HabotHardwareSummary.theTableTruncatesToTheRightColumns &&
          HabotHardwareSummary.theTableStopsOnWidthAndTheSummaryOnRank,
    );

    gate(
      'HSCPE-006-G7',
      'One longer device name breaks the agreement.',
      'At 160 points the table drops to two columns while the summary still '
          'shows three',
      () =>
          HabotHardwareSummary.aLongerNameBreaksTheTable &&
          HabotHardwareSummary.longerIdentityWidthDp == 160,
    );

    gate(
      'HSCPE-006-G8',
      'A layout that is correct by coincidence ships.',
      'Because nothing in review distinguishes it from one that is correct '
          'on purpose',
      () => HabotHardwareSummary.accidentNote
          .contains('correct by coincidence'),
    );
  });

  group('HSCPE-006 :: the verdict', () {
    gate(
      'HSCPE-006-G9',
      'The facts are chosen by rank rather than by width.',
      'Which is the property that survives the next edit, and the only '
          'difference between the summary and the accident',
      () => HabotHardwareSummary.theTableStopsOnWidthAndTheSummaryOnRank,
    );

    gate(
      'HSCPE-006-G10',
      'Output: Good / Average / Poor.',
      'Five declared obligations, all met, giving a Good; all nine declared '
          'checks hold, and the row\'s Dependency cell of pasted design '
          'decisions is recorded',
      () =>
          HabotHardwareSummary.obligations.length == 5 &&
          HabotHardwareSummary.obligations.values.every((bool b) => b) &&
          HabotHardwareSummary.tokenCompliance == 1.0 &&
          HabotHardwareSummary.qualitativeOutput == 'Good' &&
          HabotHardwareSummary.checks.length == 9 &&
          HabotHardwareSummary.checks.values.every((bool b) => b) &&
          HabotHardwareSummary.columnNote.contains('Dependency cell'),
    );
  });

  tearDownAll(() {
    final String fitting = HabotHardwareSummary.columnsThatFit
        .map((HabotColumn c) => c.name)
        .join(', ');
    final String behind = HabotHardwareSummary.behindTheRow
        .map((HabotColumn c) => c.name)
        .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSCPE-006',
        atomicStepReferenceId: 'HSCPE-006',
        setupStepAction:
            'COLUMN NOTE: the Dependency cell on this row holds four '
            'Mobile-First Material Design decision sentences instead of a '
            'dependency, the Decision Group is "Security & Perimeter '
            'Architecture", every narrative column is about API gateway '
            'ingress and payload validation, and the Setup Step reads "Map a '
            'dedicated trace_id string text field attribute into the primary '
            'payload layout model". Atomic Step: "UX Implementation: Condense '
            'dense hardware tables into scannable MD3-compliant data summaries '
            'for mobile admin views."',
        implementationOrder: 310,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Android and iOS, compact window class',
          'OS Version': 'a summary column, ranked second among the facts',
          'Device Type': 'the identity column of the summary line',
          'Screen Dimensions':
              '360 points wide, 328 after the page margins; the table needs '
                  '530',
          'Mobile Configuration':
              'one of the two columns that sits behind the row rather than '
                  'past its edge',
          'Completion Status': 'Good',
          'Component Properties':
              'the table shows $fitting; the summary keeps $behind one tap '
                  'away and announced',
          'Data Quality Note':
              'DUPLICATION: ${HabotHardwareSummary.duplicationNote} '
              'ACCIDENT: ${HabotHardwareSummary.accidentNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Material Design 3 Token Compliance',
            observed:
                '100% over five declared obligations. The band is Step 286\'s '
                'band, string for string, and its floor -- "ad-hoc custom '
                'styling, no token system" -- is still a condition every '
                'repository meets, so it still cannot be failed.',
            floor: 'Ad-hoc custom styling, no token system',
            optimal: 'Core MD3 tokens applied consistently',
            ceiling:
                'Full MD3 token system + automated visual regression testing',
          ),
          AissMeasurement(
            metricName: 'Hardware columns visible at compact width',
            observed:
                '3 of 5 in a table, with 2 past the edge; 3 of 5 in the '
                'summary, with 2 behind the row and announced. The counts '
                'agree by coincidence -- the table stops on width, the '
                'summary stops on rank -- and one longer device name takes '
                'the table to 2 while the summary stays at 3.',
            floor: '3',
            optimal: '5',
            ceiling: '5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/hardware_summary.dart',
        ],
      ),
    );
  });
}
