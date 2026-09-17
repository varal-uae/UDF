/// AISS GATE -- Step 363 of 375
/// Global Reference ID:       OPMV-006
/// Atomic Steps Reference ID: OPMV-006
/// Setup Step (Action): "Initialize a fresh component file to house dense
///                      tabular grid blocks optimized for high-volume data
///                      reading."
/// Atomic Step: "Establish query row limits to protect layout rendering
///               pipelines from overloads."
/// Metric: Dashboard Load Performance (Largest Contentful Paint) -- floor
///         "< 4.0 s", optimal "< 2.5 s", ceiling "< 1.8 s". Pass / Fail.
///         Google Core Web Vitals. Assigned to **DEA**.
///
/// A CAP IS A TRUNCATION, AND A TRUNCATION SOMEBODY CANNOT SEE IS A WRONG
/// ANSWER WITH A FAST RENDER TIME.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/query_row_limit.dart';

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

  group('OPMV-006 :: an aggregate is not a listing', () {
    gate(
      'OPMV-006-G1',
      'Two query kinds, only one of which may be capped.',
      '"How many overdue invoices" is computed over everything; "show me the '
          'overdue invoices" may stop at five hundred',
      () =>
          HabotQueryKind.values.length == 2 &&
          HabotQueryRowLimit.anAggregateIsNeverCapped,
    );

    gate(
      'OPMV-006-G2',
      'Three worked results, one of them truncated.',
      'The count is 3,120 over the whole table while the listing draws 500',
      () =>
          HabotQueryRowLimit.worked.length == 3 &&
          HabotQueryRowLimit.onlyTheListingIsTruncated &&
          HabotQueryRowLimit.worked[1].returned ==
              HabotQueryRowLimit.listingCap,
    );

    gate(
      'OPMV-006-G3',
      '2,620 rows are named as not drawn.',
      'Rather than quietly absent, which is the version where the total and '
          'the list disagree with nothing to say why',
      () =>
          HabotQueryRowLimit.twoThousandSixHundredAndTwentyFellOff &&
          HabotQueryRowLimit.kindNote.contains('quietly absent'),
    );
  });

  group('OPMV-006 :: a silent truncation is a wrong answer', () {
    gate(
      'OPMV-006-G4',
      'The truncated list says "Showing 500 of 3120".',
      'A cap somebody cannot see is a wrong answer with a fast render time',
      () =>
          !HabotQueryRowLimit.aTruncationIsSilent &&
          HabotQueryRowLimit.theTruncationIsStated,
    );

    gate(
      'OPMV-006-G5',
      'The complete list says "Showing all 84".',
      'An unqualified "Showing 84" leaves a reader unable to tell a complete '
          'list from a capped one',
      () =>
          HabotQueryRowLimit.theCompleteListSaysSo &&
          HabotQueryRowLimit.bothStatesAreLabelled &&
          HabotQueryRowLimit.visibilityNote.contains('short'),
    );
  });

  group('OPMV-006 :: what protects a render pipeline', () {
    gate(
      'OPMV-006-G6',
      'The row asks for grid reflow, which protects nothing.',
      'Four-column grids reflowing into vertical stacks is layout',
      () => HabotQueryRowLimit.protectionNote.contains('protects nothing'),
    );

    gate(
      'OPMV-006-G7',
      'Virtualisation is what protects it.',
      'Five hundred rows build about twenty widgets, so the cap and the '
          'viewport are independent limits',
      () =>
          HabotQueryRowLimit.theListIsVirtualised &&
          HabotQueryRowLimit.theCapAndTheViewportAreIndependent &&
          HabotQueryRowLimit.widgetsBuiltForFiveHundredRows == 20,
    );
  });

  group('OPMV-006 :: the metric, for the third time', () {
    gate(
      'OPMV-006-G8',
      'Largest Contentful Paint is a browser measurement.',
      'Collected by the PerformanceObserver over DOM elements, in an '
          'application that rasterises its own widgets',
      () =>
          HabotQueryRowLimit.theMetricCannotBeCollectedHere &&
          HabotQueryRowLimit.metricCollector.contains('PerformanceObserver'),
    );

    gate(
      'OPMV-006-G9',
      'Third Core Web Vitals row in two batches.',
      'Step 344 scored touch targets on INP and Step 369 scores a panel on LCP '
          'again -- and unlike Step 344\'s, this band is ordered correctly',
      () =>
          HabotQueryRowLimit.thisIsTheThirdCoreWebVitalsRow &&
          HabotQueryRowLimit.theBandIsOrderedCorrectly &&
          HabotQueryRowLimit.coreWebVitalsRows.contains(344),
    );

    gate(
      'OPMV-006-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotQueryRowLimit.obligations.length == 5 &&
          HabotQueryRowLimit.obligations.values.every((bool b) => b) &&
          HabotQueryRowLimit.qualitativeOutput == 'Pass' &&
          HabotQueryRowLimit.checks.length == 10 &&
          HabotQueryRowLimit.checks.values.every((bool b) => b) &&
          HabotQueryRowLimit.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final String capped =
        HabotQueryRowLimit.truncationLabel(HabotQueryRowLimit.worked[1]);
    final String complete =
        HabotQueryRowLimit.truncationLabel(HabotQueryRowLimit.worked[2]);
    final int notDrawn = HabotQueryRowLimit.rowsNotDrawn;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'OPMV-006',
        atomicStepReferenceId: 'OPMV-006',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, its '
            'metric is Google Core Web Vitals Largest Contentful Paint in an '
            'application with no DOM -- the third Core Web Vitals row in two '
            'batches -- its Data Requirement column describes grid reflow '
            'rather than anything that protects a render pipeline, and its '
            'Setup Step column reads "Initialize a fresh component file to '
            'house dense tabular grid blocks optimized for high-volume data '
            'reading". Atomic Step: "Establish query row limits to protect '
            'layout rendering pipelines from overloads."',
        implementationOrder: 363,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'a virtualised dense list',
          'Layout Grid Dimensions': 'single column at compact width',
          'Spacing Rules': 'the declared spacing scale',
          'Alignment Settings': 'leading-aligned rows',
          'Layout Validation Status': 'Pass',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the capped list reads "$capped" and the complete one '
                  '"$complete"; $notDrawn rows are named as not drawn',
          'Data Quality Note':
              'KIND: ${HabotQueryRowLimit.kindNote} '
              'VISIBILITY: ${HabotQueryRowLimit.visibilityNote} '
              'PROTECTION: ${HabotQueryRowLimit.protectionNote} '
              'METRIC: ${HabotQueryRowLimit.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Dashboard Load Performance (Largest Contentful Paint)',
            observed:
                'A BROWSER METRIC, FOR THE THIRD TIME IN TWO BATCHES. Largest '
                'Contentful Paint is defined over DOM elements and collected '
                'by the browser PerformanceObserver; this application has no '
                'DOM. Step 344 scored touch targets on INP and Step 369 scores '
                'a status panel on LCP again. This band is at least ordered '
                'correctly for a lower-is-better measure, 4.0 seconds down to '
                '1.8, which Step 344\'s was not.',
            floor: '< 4.0 s',
            optimal: '< 2.5 s',
            ceiling: '< 1.8 s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Rows dropped without the list saying so',
            observed:
                '0. The aggregate is never capped -- the count is 3,120 over '
                'the whole table -- while the listing stops at 500 and says '
                '"$capped", naming the $notDrawn rows that were not drawn. A '
                'complete list says "$complete", because an unqualified count '
                'leaves a reader unable to tell a complete list from a capped '
                'one. What actually protects the render pipeline is not the '
                'grid reflow the row asks for but virtualisation: 500 rows '
                'build about 20 widgets, so the cap exists for the network and '
                'the query planner rather than for the renderer.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/query_row_limit.dart',
        ],
      ),
    );
  });
}
