/// AISS GATE -- Step 343 of 355
/// Global Reference ID:       CBSV-005-14
/// Atomic Steps Reference ID: CBSV-005-14
/// Setup Step (Action): "Wrap the application's individual native interface
///                      containers cleanly within this central AppShell
///                      container."
/// Atomic Step: "Add padding spacing blocks around target objects to ensure
///               mobile touch accuracy."
/// Metric: Process Execution Quality Score -- floor ">=90%", optimal ">=98%",
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// NINE TOUCH ROWS IN THIS TRACK HAVE BEEN ABOUT SIZE. THIS IS THE FIRST
/// ABOUT THE GAP BETWEEN TWO TARGETS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/target_spacing.dart';

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

  group('CBSV-005-14 :: size is not spacing', () {
    gate(
      'CBSV-005-14-G1',
      'Four adjacent pairs, all of which clear every size rule.',
      'Two of the four fail on the gap, which no size rule in this repository '
          'can see',
      () =>
          HabotTargetSpacing.pairs.length == 4 &&
          HabotTargetSpacing.pairsClearingSize == 4 &&
          HabotTargetSpacing.sizePassesEverywhereAndSpacingDoesNot,
    );

    gate(
      'CBSV-005-14-G2',
      'Two 48dp targets sharing an edge are a coin toss.',
      'Size decides whether a target can be hit; spacing decides whether the '
          'right one is',
      () =>
          HabotTargetSpacing.theTouchingPairIsTheWorstCase &&
          HabotTargetSpacing.failingPairs.length == 2,
    );

    gate(
      'CBSV-005-14-G3',
      'Nine previous touch rows were all about size.',
      'Steps 3, 108, 184, 198, 227, 228, 229, 313 and 342; this is the first '
          'about the gap',
      () => HabotTargetSpacing.sizeVersusSpacingNote
          .contains('Steps 3, 108, 184'),
    );
  });

  group('CBSV-005-14 :: why 8dp', () {
    gate(
      'CBSV-005-14-G4',
      'The gap comes from the spacing scale declared at Step 2.',
      'Nothing new is invented; what is added is the rule that adjacent '
          'interactive targets may not share an edge',
      () =>
          HabotTargetSpacing.minimumGapDp == 8 &&
          HabotTargetSpacing.minimumSizeDp == 48,
    );

    gate(
      'CBSV-005-14-G5',
      'A contact patch is wider than the gap, and that is not a paradox.',
      'The gap separates the reported centroids rather than the fingers, and '
          'a centroid drifts a few millimetres from where a person aimed',
      () =>
          HabotTargetSpacing.thePatchIsWiderThanTheGap &&
          HabotTargetSpacing.patchNote
              .contains('separates the reported centroids'),
    );
  });

  group('CBSV-005-14 :: the long-press in the Data Requirement cell', () {
    gate(
      'CBSV-005-14-G6',
      'The row buries a long-press-to-copy in a list about masked values.',
      'A long-press is not path-based, so SC 2.5.1 does not reach it -- what '
          'reaches it is that nothing says it exists',
      () =>
          !HabotTargetSpacing.theLongPressIsPathBased &&
          HabotTargetSpacing.hiddenAffordance.contains('long-press'),
    );

    gate(
      'CBSV-005-14-G7',
      'The copy action keeps the long-press and gains a visible route.',
      'An overflow action on the same element, so the function is available '
          'to somebody who has not been told about it',
      () =>
          HabotTargetSpacing.theCopyActionHasAVisibleRoute &&
          HabotTargetSpacing.longPressNote.contains('have been told'),
    );
  });

  group('CBSV-005-14 :: units and the band', () {
    gate(
      'CBSV-005-14-G8',
      'The row asks for a "Unit Type (px/rem)" field.',
      'Neither is a unit this application has: px varies with density and rem '
          'is relative to a root font size that exists only in a browser',
      () =>
          HabotTargetSpacing.bothListedUnitsAreForeign &&
          HabotTargetSpacing.unitsWithNoMeaningHere.length == 2 &&
          HabotTargetSpacing.unitsNote.contains('Step 342'),
    );

    gate(
      'CBSV-005-14-G9',
      'Floor ">=90%", optimal ">=98%", ceiling "1".',
      'Two percentages and a bare ratio, the same mixture Step 336 carries; '
          'the published score names its denominator',
      () =>
          HabotTargetSpacing.theBandMixesUnits &&
          HabotTargetSpacing.score == 0.5,
    );

    gate(
      'CBSV-005-14-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotTargetSpacing.obligations.length == 5 &&
          HabotTargetSpacing.obligations.values.every((bool b) => b) &&
          HabotTargetSpacing.qualitativeOutput == 'Good' &&
          HabotTargetSpacing.checks.length == 10 &&
          HabotTargetSpacing.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int failing = HabotTargetSpacing.failingPairs.length;
    final String patch =
        HabotTargetSpacing.contactPatchMinDp.toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CBSV-005-14',
        atomicStepReferenceId: 'CBSV-005-14',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement column on this row asks for a '
            '"Unit Type (px/rem)" field, neither of which is a unit this '
            'application uses, and buries a long-press-to-copy affordance in a '
            'list about masked reference values; the Setup Step column is '
            'about wrapping native containers in a central AppShell. Atomic '
            'Step: "Add padding spacing blocks around target objects to ensure '
            'mobile touch accuracy."',
        implementationOrder: 343,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Spacing Value': '8dp, from the Step 2 spacing scale',
          'Unit Type (px/rem)':
              'neither; everything here is in dp, and the row\'s two listed '
                  'units have no meaning in this application',
          'Application Level': 'adjacent interactive targets',
          'Spacing Scale': 'Step 2',
          'Mobile Platform': 'Android and iOS',
          'OS Version': 'not device-specific',
          'Device Type': 'compact handset',
          'Screen Dimensions': '328dp content width',
          'Mobile Configuration':
              '4 adjacent pairs, $failing of which share too little edge',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Data Quality Note':
              'SIZE VS SPACING: ${HabotTargetSpacing.sizeVersusSpacingNote} '
              'PATCH: ${HabotTargetSpacing.patchNote} '
              'LONG-PRESS: ${HabotTargetSpacing.longPressNote} '
              'UNITS: ${HabotTargetSpacing.unitsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                'THE BAND MIXES UNITS -- two percentages against a bare ratio '
                '"1" -- which is the same mixture Step 336 carries and the '
                'second of five in this batch. The three values are at least '
                'ordered. What the score counts is not stated by the row, so '
                'the denominator is named here: 0.5, the share of adjacent '
                'interactive pairs clearing both the size rule and the gap '
                'rule.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Minimum gap between adjacent interactive targets, dp',
            observed:
                '8, from the spacing scale declared at Step 2 rather than a '
                'new number. Two 48dp targets sharing an edge pass every size '
                'rule this repository enforces and a finger on the seam hits '
                'one at random. A contact patch is about $patch dp across, far '
                'wider than the gap, which is the point: the gap separates the '
                'reported centroids, not the fingers.',
            floor: '8',
            optimal: '8',
            ceiling: '16',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/target_spacing.dart',
        ],
      ),
    );
  });
}
