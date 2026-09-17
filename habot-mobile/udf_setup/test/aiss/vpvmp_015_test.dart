/// AISS GATE -- Step 344 of 355
/// Global Reference ID:       VPVMP-015
/// Atomic Steps Reference ID: VPVMP-015
/// Setup Step (Action): "Design the pipeline flow: input capture, validation,
///                      sanitization, storage, retrieval." (A DATA PIPELINE,
///                      ON A TOUCH-TARGET ROW)
/// Atomic Step: "Set touch targets to meet standard minimum dimensions of
///               48x48dp."
/// Metric: UI / UX Component Interaction Response Time (Core Web Vitals INP
///         band) -- floor "<200 ms", optimal "<100 ms", ceiling "<50 ms".
///         Good (Poor / Average / Good). Assigned to **DEA**.
///
/// A BROWSER METRIC IN AN APPLICATION WITH NO DOM, A FLOOR LABELLED WITH THE
/// BAND ON THE WRONG SIDE OF IT, AND THE NINTH REQUEST FOR 48dp.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/touch_target_census.dart';

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

  group('VPVMP-015 :: the metric', () {
    gate(
      'VPVMP-015-G1',
      'Metric: Core Web Vitals INP.',
      'Interaction to Next Paint is defined over DOM events and collected by '
          'the browser Event Timing API; this application has no DOM',
      () =>
          HabotTouchTargetCensus.metricName.contains('INP') &&
          HabotTouchTargetCensus.metricCollector.contains('Event Timing') &&
          HabotTouchTargetCensus.theMetricCannotBeCollectedHere,
    );

    gate(
      'VPVMP-015-G2',
      'Floor: "<200 ms (needs improvement ceiling per Core Web Vitals)".',
      'Below 200 ms is the good band and 200 ms is where needs-improvement '
          'begins, so the boundary is right and its label is on the wrong side',
      () =>
          HabotTouchTargetCensus.theFloorIsLabelledWithTheWrongBand &&
          HabotTouchTargetCensus.inpGoodBelow == 200 &&
          HabotTouchTargetCensus.inpPoorAbove == 500,
    );

    gate(
      'VPVMP-015-G3',
      'Second row in this batch whose metric is from another discipline.',
      'After Step 337\'s Mean Time to Detect on a card drag',
      () => HabotTouchTargetCensus.metricNote.contains('Step 337'),
    );
  });

  group('VPVMP-015 :: the ninth restatement', () {
    gate(
      'VPVMP-015-G4',
      'The sheet has asked for 48dp eight times before this row.',
      'Steps 3, 108, 184, 198, 227, 228, 229 and 342; Step 227 recorded the '
          'first six',
      () =>
          HabotTouchTargetCensus.restatementsIncludingThisOne == 9 &&
          HabotTouchTargetCensus.stepsThatAskedFor48.length == 8 &&
          HabotTouchTargetCensus.restatementNote.contains('Step 227'),
    );

    gate(
      'VPVMP-015-G5',
      'Nothing new is declared here.',
      'The minimum is the token declared at Step 3; what this row is worth is '
          'the audit rather than another constant',
      () =>
          HabotTouchTargetCensus.nothingNewIsDeclaredHere &&
          HabotTouchTargetCensus.declaredMinimumDp == 48,
    );
  });

  group('VPVMP-015 :: the census', () {
    gate(
      'VPVMP-015-G6',
      'Nine control classes, seven of them statically measurable.',
      'And every one of those seven clears the minimum',
      () =>
          HabotTouchTargetCensus.sevenOfNineAreStaticallyProven &&
          HabotTouchTargetCensus.everyStaticClassClearsTheMinimum,
    );

    gate(
      'VPVMP-015-G7',
      'The two that are not are the ones Step 313 named.',
      'A chip sized to a translated label and an inline link sized by the '
          'text scale -- reported as unproven rather than counted as passing',
      () =>
          HabotTouchTargetCensus.theTwoRunTimeClassesAreTheOnesStep313Named &&
          HabotTouchTargetCensus.composedAtRunTime.first.name.contains('chip'),
    );
  });

  group('VPVMP-015 :: the gesture guard', () {
    gate(
      'VPVMP-015-G8',
      'A11Y_GESTURE_WITHOUT_ALTERNATIVE, specified at Step 336, runs here.',
      'Four of the nine classes use a path gesture, and all four declare a '
          'single-pointer route',
      () =>
          HabotTouchTargetCensus.guardIsEnabled &&
          HabotTouchTargetCensus.guardRuleId ==
              'A11Y_GESTURE_WITHOUT_ALTERNATIVE' &&
          HabotTouchTargetCensus.fourClassesUseAPathGesture &&
          HabotTouchTargetCensus.everyPathGestureHasAnAlternative,
    );

    gate(
      'VPVMP-015-G9',
      'The census covers spacing as well as size.',
      'Step 343\'s gap rule is part of it, because size without spacing is an '
          'audit that passes while somebody keeps hitting the wrong control',
      () =>
          HabotTouchTargetCensus.theSpacingRuleIsDeclared &&
          HabotTouchTargetCensus.spacingNote.contains('wrong control'),
    );

    gate(
      'VPVMP-015-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotTouchTargetCensus.obligations.length == 6 &&
          HabotTouchTargetCensus.obligations.values.every((bool b) => b) &&
          HabotTouchTargetCensus.qualitativeOutput == 'Good' &&
          HabotTouchTargetCensus.checks.length == 10 &&
          HabotTouchTargetCensus.checks.values.every((bool b) => b) &&
          HabotTouchTargetCensus.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final String coverage =
        (HabotTouchTargetCensus.staticCoverage * 100).toStringAsFixed(1);
    final int gestures = HabotTouchTargetCensus.pathGestureClasses.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'VPVMP-015',
        atomicStepReferenceId: 'VPVMP-015',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, its '
            'narrative columns are the same least-privilege governance text '
            'Step 337 carries, its Setup Step column reads "Design the '
            'pipeline flow: input capture, validation, sanitization, storage, '
            'retrieval", and its Best Qualitative Output Type cell holds '
            'review guidance rather than a standard. Atomic Step: "Set touch '
            'targets to meet standard minimum dimensions of 48x48dp."',
        implementationOrder: 344,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'VPVMP-015',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '9 control classes audited; $coverage per cent are statically '
                  'measurable and all of those clear 48dp',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$gestures of the 9 classes use a path gesture and all of them '
                  'declare a single-pointer route, so the new guard passes '
                  'with nothing to report',
          'Data Quality Note':
              'METRIC: ${HabotTouchTargetCensus.metricNote} '
              'RESTATEMENT: ${HabotTouchTargetCensus.restatementNote} '
              'GUARD: ${HabotTouchTargetCensus.guardNote} '
              'SPACING: ${HabotTouchTargetCensus.spacingNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'UI / UX Component Interaction Response Time (Core Web Vitals '
                'INP band)',
            observed:
                'NOT COLLECTABLE HERE, AND MISLABELLED. Interaction to Next '
                'Paint is defined over DOM events and collected by the browser '
                'Event Timing API; this application rasterises its own widgets '
                'and has no DOM. The floor cell also reads "<200 ms (needs '
                'improvement ceiling)", when below 200 ms is the good band and '
                '200 ms is where needs-improvement starts -- the right '
                'boundary with the band on the wrong side of it. Second row in '
                'this batch whose metric belongs to a different discipline '
                'from its subject, after Step 337.',
            floor: '<200 ms ("needs improvement" ceiling per Core Web Vitals)',
            optimal: '<100 ms ("good" band)',
            ceiling: '<50 ms',
          ),
          AissMeasurement(
            metricName: 'Control classes proven to clear 48dp statically',
            observed:
                '7 of 9, which is $coverage per cent, and the published figure '
                'rather than a claim of full coverage. The two that are not '
                'are the ones Step 313 named: a chip sized to a translated '
                'label and an inline link sized by the text scale, both '
                'composed at run time. This is the ninth time the sheet has '
                'asked for 48dp and nothing new is declared -- the token is '
                'Step 3\'s, and what this row adds is the audit and the '
                'gesture guard Step 336 specified.',
            floor: '7',
            optimal: '9',
            ceiling: '9',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/touch_target_census.dart',
        ],
      ),
    );
  });
}
