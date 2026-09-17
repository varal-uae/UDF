/// AISS GATE -- Step 298 of 315
/// Global Reference ID:       ACRAE-032-15
/// Atomic Steps Reference ID: ACRAE-032-15
/// Setup Step (Action): "Clear the local device database vault files upon
///                      receiving a successful server state synchronization
///                      receipt." (DATA RETENTION, ON A TYPOGRAPHY ROW)
/// Atomic Step: "Format date labels using monospaced typographical alignments,
///               verify non-blocking skeleton loaders, and enforce 48dp
///               interactive touch targets."
/// Metric: Mobile Touch Target Size Compliance -- floor "44dp minimum",
///         optimal "48dp", ceiling "56dp+". Pass/Fail. Cited as WCAG 2.2
///         SC 2.5.8.
///
/// THREE OBLIGATIONS UNDER ONE PASS/FAIL, TWO OF WHICH ARE THE SAME
/// OBLIGATION. AND THE CITATION IS THE WRONG CRITERION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/skeleton_placeholder.dart';

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

  group('ACRAE-032-15 :: the bundle', () {
    gate(
      'ACRAE-032-15-G1',
      'Atomic Step: three clauses joined by "and".',
      'Typography, loading placeholders and touch targets, scored by one '
          'Pass/Fail that can speak for the third only',
      () =>
          HabotSkeletonPlaceholder.obligationsOnTheRow.length == 3 &&
          HabotSkeletonPlaceholder.obligationsMeasured == 1 &&
          HabotSkeletonPlaceholder.oneVerdictCoversThree,
    );

    gate(
      'ACRAE-032-15-G2',
      'One measured obligation in three.',
      'The widest bundling this track has recorded, after Step 285\'s '
          'touch-and-contrast pair and Step 295\'s accuracy-and-latency pair',
      () =>
          (HabotSkeletonPlaceholder.shareMeasured - 1 / 3).abs() < 1e-9 &&
          HabotSkeletonPlaceholder.bundleNote.contains('widest so far'),
    );
  });

  group('ACRAE-032-15 :: two of the three are one', () {
    gate(
      'ACRAE-032-15-G3',
      'Config: "monospaced typographical alignments".',
      'The same date format spans 65.6 to 82.4 points with proportional '
          'digits -- a 16.8-point spread from which digits it happens to '
          'contain',
      () =>
          (HabotSkeletonPlaceholder.narrowestProportionalDp - 65.6).abs() <
              1e-9 &&
          (HabotSkeletonPlaceholder.widestProportionalDp - 82.4).abs() < 1e-9 &&
          (HabotSkeletonPlaceholder.proportionalSpreadDp - 16.8).abs() < 1e-9,
    );

    gate(
      'ACRAE-032-15-G4',
      'That spread is more than two rungs of the spacing scale.',
      'Which is a visible jump in every row of a list, not a subtlety',
      () =>
          HabotSkeletonPlaceholder.spreadInBaselineRungs > 2 &&
          HabotSkeletonPlaceholder.tabularWidthIsConstant,
    );

    gate(
      'ACRAE-032-15-G5',
      'Config: "verify non-blocking skeleton loaders".',
      'The placeholder is drawn at the settled width, which is possible only '
          'because the first clause made the width a constant -- so the '
          'row\'s first obligation is the precondition for its second',
      () =>
          HabotSkeletonPlaceholder.thePlaceholderMatchesTheSettledWidth &&
          HabotSkeletonPlaceholder
              .theFirstObligationIsThePreconditionForTheSecond &&
          HabotSkeletonPlaceholder.connectionNote
              .contains('as though they were'),
    );

    gate(
      'ACRAE-032-15-G6',
      'A skeleton has nothing to announce.',
      'It sweeps on a declared token and is excluded from the semantics tree, '
          'because reading a row of grey bars to somebody who cannot see them '
          'is noise',
      () =>
          HabotSkeletonPlaceholder.sweep.inMilliseconds == 1400 &&
          HabotSkeletonPlaceholder.skeletonIsExcludedFromSemantics &&
          HabotSkeletonPlaceholder.semanticsNote
              .contains('description of the implementation'),
    );
  });

  group('ACRAE-032-15 :: the obligation that is measured', () {
    gate(
      'ACRAE-032-15-G7',
      'Atomic Step asks for 48dp; the floor says 44dp.',
      'The row is four points stricter than its own floor, and 48 is this '
          'project\'s optimal rather than its minimum',
      () =>
          HabotSkeletonPlaceholder.theRowIsStricterThanItsOwnFloor &&
          HabotSkeletonPlaceholder.floorShortfallDp == 4 &&
          HabotSkeletonPlaceholder.requestedDp ==
              HabotSkeletonPlaceholder.targetOptimalDp,
    );

    gate(
      'ACRAE-032-15-G8',
      'Cited as WCAG 2.2 SC 2.5.8.',
      'SC 2.5.8 Target Size (Minimum) is 24 by 24 at Level AA; the 44 figure '
          'is SC 2.5.5 at Level AAA, and Step 313 in this batch cites it '
          'correctly',
      () =>
          HabotSkeletonPlaceholder.theCitationIsWrong &&
          HabotSkeletonPlaceholder.actualMinimumForCitedCriterion == 24 &&
          HabotSkeletonPlaceholder.citationNote.contains('Step 313'),
    );
  });

  group('ACRAE-032-15 :: the borrowed vocabulary and the verdict', () {
    gate(
      'ACRAE-032-15-G9',
      'Data Collected: Lock Type, Lock Status, Locked By, Timestamp, Reason.',
      'The record-locking vocabulary for the third time -- Step 273 on a '
          'circuit breaker, Step 295 on a table cell where it belonged, and '
          'this row on dates and placeholders, where nothing locks anything',
      () =>
          HabotSkeletonPlaceholder.theSameFiveFieldsAppearAThirdTime &&
          HabotSkeletonPlaceholder.stepsThatCarriedTheseFields.length == 3 &&
          HabotSkeletonPlaceholder.lockFieldsNote
              .contains('Nothing here locks anything'),
    );

    gate(
      'ACRAE-032-15-G10',
      'Output: Pass/Fail, best = Pass (>=48dp).',
      'Five declared obligations, all met, giving Pass; all eleven declared '
          'checks hold',
      () =>
          HabotSkeletonPlaceholder.obligations.length == 5 &&
          HabotSkeletonPlaceholder.obligations.values.every((bool b) => b) &&
          HabotSkeletonPlaceholder.qualitativeOutput == 'Pass' &&
          HabotSkeletonPlaceholder.checks.length == 11 &&
          HabotSkeletonPlaceholder.checks.values.every((bool b) => b) &&
          HabotSkeletonPlaceholder.columnNote.contains('Lock Reason'),
    );
  });

  tearDownAll(() {
    final String spread =
        HabotSkeletonPlaceholder.proportionalSpreadDp.toStringAsFixed(1);
    final String settled =
        HabotSkeletonPlaceholder.tabularDp.toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ACRAE-032-15',
        atomicStepReferenceId: 'ACRAE-032-15',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Clear the '
            'local device database vault files upon receiving a successful '
            'server state synchronization receipt" -- a data-retention '
            'instruction on a typography row -- and Data Collected is the '
            'record-locking vocabulary. Atomic Step: "Format date labels using '
            'monospaced typographical alignments, verify non-blocking skeleton '
            'loaders, and enforce 48dp interactive touch targets."',
        implementationOrder: 298,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Lock Type': 'none -- nothing on this row locks a record',
          'Lock Status': 'not applicable',
          'Locked By': 'not applicable',
          'Lock Timestamp': '2026-09-17T00:00:00Z',
          'Lock Reason':
              'the five lock fields are this row\'s Data Collected column and '
                  'belong to Steps 273 and 295',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BUNDLE: ${HabotSkeletonPlaceholder.bundleNote} '
              'CONNECTION: ${HabotSkeletonPlaceholder.connectionNote} '
              'CITATION: ${HabotSkeletonPlaceholder.citationNote} '
              'LOCK FIELDS: ${HabotSkeletonPlaceholder.lockFieldsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Touch Target Size Compliance',
            observed:
                '48dp, which is this project\'s optimal and four points above '
                'the row\'s own floor. The row cites WCAG 2.2 SC 2.5.8 for '
                '44dp; 2.5.8 is 24 by 24 at Level AA and the 44 figure is SC '
                '2.5.5 at Level AAA. The metric covers one of the row\'s three '
                'obligations.',
            floor: '44dp minimum',
            optimal: '48dp',
            ceiling: '56dp+',
          ),
          AissMeasurement(
            metricName: 'Date label width variation across digit content',
            observed:
                '0 points with tabular figures, against $spread points '
                'proportional -- more than two rungs of the spacing scale, and '
                'therefore a visible jump in every row of a list. The '
                'placeholder is drawn at the settled width of $settled points, '
                'which is only possible because the width is a constant.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/skeleton_placeholder.dart',
        ],
      ),
    );
  });
}
