/// AISS GATE -- Step 286 of 295
/// Global Reference ID:       HSCPE-019
/// Atomic Steps Reference ID: HSCPE-019
/// Setup Step (Action): "Locate the typographic specification sections within
///                      the design documents." (DIFFERENT SUBJECT)
/// Atomic Step: "UX Implementation: Present dense pod scheduling arrays under
///               simple, scannable MD3 data summaries for small viewports."
/// Metric: Material Design 3 Token Compliance -- Floor "Ad-hoc custom styling,
///         no token system", Optimal "Core MD3 tokens applied consistently",
///         Ceiling "Full MD3 token system + automated visual regression
///         testing". Good / Average / Poor.
///
/// THE FLOOR IS THE FAILURE STATE, SO THE BAND CANNOT FAIL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/dense_summary.dart';

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

  group('HSCPE-019 :: the table that does not fit', () {
    gate(
      'HSCPE-019-G1',
      'Atomic Step: "dense pod scheduling arrays ... for small viewports".',
      'Eight columns need about 690 points and a compact window has about 328 '
          'after padding, so three fit and five go past the edge',
      () =>
          HabotDenseSummary.columns.length == 8 &&
          HabotDenseSummary.mostOfTheTableIsOffScreen &&
          (HabotDenseSummary.shareVisibleInATable - 0.375).abs() < 1e-9,
    );

    gate(
      'HSCPE-019-G2',
      'Off-screen is not compressed, it is hidden.',
      'The table is more than twice the available width, and the cost -- a '
          'reader who believes they have seen the row -- is recorded',
      () =>
          HabotDenseSummary.theTableIsWiderThanThePhone &&
          HabotDenseSummary.tableNote.contains('they are hidden'),
    );

    gate(
      'HSCPE-019-G3',
      'Atomic Step: "simple, scannable data summaries".',
      'The summary line fits in the available width and every column is '
          'accounted for: one identity, two secondary facts, five behind the '
          'row',
      () =>
          HabotDenseSummary.theSummaryLineFits &&
          HabotDenseSummary.everyColumnIsAccountedFor &&
          HabotDenseSummary.behindTheRow.length == 5,
    );

    gate(
      'HSCPE-019-G4',
      'The two facts shown are chosen by rank, not by what fitted.',
      'Status and restart count are the two that decide whether anybody needs '
          'to look further, taken by declared rank',
      () =>
          HabotDenseSummary.theFactsAreChosenByRankNotByWidth &&
          HabotDenseSummary.maxSecondaryFacts == 2,
    );

    gate(
      'HSCPE-019-G5',
      'The summary says there is more and the table does not.',
      'Everything is reachable without a horizontal gesture, which is the '
          'difference that matters rather than the count of values on screen',
      () =>
          HabotDenseSummary.everythingIsReachableWithoutAHorizontalGesture &&
          HabotDenseSummary.summaryNote.contains('the table does not'),
    );
  });

  group('HSCPE-019 :: the band that cannot fail', () {
    gate(
      'HSCPE-019-G6',
      'Floor: "Ad-hoc custom styling, no token system".',
      'That is the condition a token system exists to end, so every '
          'repository meets the floor -- including one that has never heard '
          'of tokens',
      () =>
          HabotDenseSummary.theFloorIsTheFailureState &&
          HabotDenseSummary.theBandCannotFail,
    );

    gate(
      'HSCPE-019-G7',
      'Step 263 refused to report Pass over an empty population.',
      'The same defect written into a band is recorded rather than scored '
          'against, and the step reports what it can actually show',
      () => HabotDenseSummary.bandNote.contains('never heard of tokens'),
    );

    gate(
      'HSCPE-019-G8',
      'What the step reports instead.',
      'Four presentational sources, every one of them a declared token or a '
          'declared breakpoint, giving 1.0 and a Good',
      () =>
          HabotDenseSummary.tokenSources.length == 4 &&
          HabotDenseSummary.tokenSources.values.every((bool b) => b) &&
          HabotDenseSummary.tokenCompliance == 1.0 &&
          HabotDenseSummary.qualitativeOutput == 'Good',
    );

    gate(
      'HSCPE-019-G9',
      'The row\'s narrative columns are about IAM pruning.',
      'Why it matters, the mobile implication, the expected output and the '
          'poka-yoke are all about revoking worker logins on a schedule; all '
          'ten declared checks hold',
      () =>
          HabotDenseSummary.wrongRowNote.contains('nothing else') &&
          HabotDenseSummary.checks.length == 10 &&
          HabotDenseSummary.checks.values.every((bool b) => b) &&
          HabotDenseSummary.columnNote.contains('typographic'),
    );
  });

  tearDownAll(() {
    final String total =
        HabotDenseSummary.totalColumnWidthDp.toStringAsFixed(0);
    final String avail =
        HabotDenseSummary.availableWidthDp.toStringAsFixed(0);
    final String line =
        HabotDenseSummary.summaryLineWidthDp.toStringAsFixed(0);
    final String fit = '${HabotDenseSummary.columnsThatFit.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSCPE-019',
        atomicStepReferenceId: 'HSCPE-019',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Locate the '
            'typographic specification sections within the design documents", '
            'and every narrative column is about automated IAM pruning of '
            'inactive workers. Atomic Step: "UX Implementation: Present dense '
            'pod scheduling arrays under simple, scannable MD3 data summaries '
            'for small viewports."',
        implementationOrder: 286,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDenseSummary / HabotColumn',
          'Component Properties':
              '${HabotDenseSummary.columns.length} columns totalling '
              '${total}dp against ${avail}dp available; $fit fit as a table; '
              'the summary '
              'line is ${line}dp and carries the identity plus '
              '${HabotDenseSummary.maxSecondaryFacts} ranked facts, with '
              '${HabotDenseSummary.behindTheRow.length} behind the row',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotDenseSummary.bandNote} '
              'TABLE: ${HabotDenseSummary.tableNote} '
              'SUMMARY: ${HabotDenseSummary.summaryNote} '
              'ROW: ${HabotDenseSummary.wrongRowNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Material Design 3 Token Compliance',
            observed:
                'THE BAND CANNOT FAIL: its floor is "ad-hoc custom styling, '
                'no token system", which is the absence of the thing being '
                'measured. Reported instead over what this component can '
                'show: four presentational sources, all of them declared '
                'tokens or breakpoints, 100%.',
            floor: 'Ad-hoc custom styling, no token system',
            optimal: 'Core MD3 tokens applied consistently',
            ceiling: 'Full MD3 token system + automated visual regression '
                'testing',
          ),
          AissMeasurement(
            metricName: 'Columns visible without a horizontal gesture',
            observed:
                'As a table, $fit of ${HabotDenseSummary.columns.length}; as a '
                'summary, all of them -- three on the line and '
                '${HabotDenseSummary.behindTheRow.length} one tap away and '
                'announced.',
            floor: 'all reachable',
            optimal: 'all reachable',
            ceiling: 'all reachable',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/dense_summary.dart',
        ],
      ),
    );
  });
}
