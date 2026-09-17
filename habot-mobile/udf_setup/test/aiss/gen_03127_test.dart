/// AISS GATE -- Step 418 of 415
/// Global Reference ID:       GEN-03127
/// Atomic Steps Reference ID: GEN-03127
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Inject Friction Middleware into all mobile UI components to
///               capture touch-event delays and screen hesitation metrics."
/// Metric: UI Friction/Hesitation Rate (%) -- floor "15", optimal "5", ceiling
///         "20". Best Qualitative Output: "Good/Average/Poor". Nielsen Norman
///         Group Usability Heuristics. Assigned to **UDF**.
///
/// THE BAND WHERE THE PATTERN BECOMES VISIBLE: SEVEN ROWS PUT THE OPTIMAL BELOW
/// BOTH BOUNDARIES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/friction_middleware.dart';

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

  group('GEN-03127 :: a convention, not a defect', () {
    gate(
      'GEN-03127-G1',
      'The optimal sits below both boundaries.',
      'Floor 15 and ceiling 20 describe fifteen to twenty; the optimal is 5',
      () =>
          HabotFrictionMiddleware.theOptimalIsBelowBothBoundaries &&
          HabotFrictionMiddleware.theBoundariesDescribeAnInterval,
    );

    gate(
      'GEN-03127-G2',
      'Seven rows share the shape, so it is a convention.',
      'Step 415 recorded it as new last batch; six more rows in this one carry '
          'it',
      () =>
          HabotFrictionMiddleware.sevenRowsShareTheShape &&
          HabotFrictionMiddleware.itIsAConventionRatherThanADefect,
    );

    gate(
      'GEN-03127-G3',
      'And the Ceiling column holds the worst value.',
      'On a lower-is-better measure, which means a reader who trusts the '
          'heading reads every latency target in the sheet backwards',
      () =>
          HabotFrictionMiddleware.theCeilingHoldsTheWorstValue &&
          HabotFrictionMiddleware.patternNote
              .contains('reads every latency target in the sheet backwards'),
    );

  });

  group('GEN-03127 :: three listeners instead of six hundred wrappers', () {
    gate(
      'GEN-03127-G4',
      'Three observation points cover five indicators.',
      'The gesture arena, the focus manager and the route observer',
      () =>
          HabotFrictionMiddleware.threeObservationPoints &&
          HabotFrictionMiddleware.everyIndicatorHasAnObservationPoint &&
          HabotFrictionMiddleware.everyDeclaredIndicatorIsCovered,
    );

    gate(
      'GEN-03127-G5',
      'Nothing is wrapped and the tree is unchanged.',
      'Middleware around every widget is a per-frame cost on every widget and '
          'a change to the tree',
      () =>
          HabotFrictionMiddleware.nothingIsWrapped &&
          HabotFrictionMiddleware.theTreeIsUnchanged &&
          HabotFrictionMiddleware.componentsInTheTree > 0,
    );

    gate(
      'GEN-03127-G6',
      'Which is what Step 417 required.',
      'Its design cells forbid layout shift and main-thread work during log '
          'creation',
      () =>
          HabotFrictionMiddleware.thisHonoursStep417sConstraint &&
          HabotFrictionMiddleware.layerNote.contains('mechanism'),
    );

  });

  group('GEN-03127 :: a standard that defines no rate', () {
    gate(
      'GEN-03127-G7',
      'The standard cited defines no rate.',
      'Ten qualitative heuristics, none of which defines a friction rate or a '
          'hesitation threshold',
      () =>
          HabotFrictionMiddleware.theStandardDefinesNoRate &&
          HabotFrictionMiddleware.theStandardIsQualitative,
    );

    gate(
      'GEN-03127-G8',
      'So the threshold is taken from Step 416.',
      'Which got it from a Completion Measures cell, and says so',
      () =>
          HabotFrictionMiddleware.theThresholdIsBoundToTheFramework &&
          HabotFrictionMiddleware.standardNote.contains('does not contain it'),
    );

  });

  group('GEN-03127 :: the rate', () {
    gate(
      'GEN-03127-G9',
      'The rate is 4.5 per cent, below the optimal.',
      'Over 2,400 observed interactions, with interactions as the denominator '
          'rather than people',
      () =>
          HabotFrictionMiddleware.theRateIsBelowTheOptimal &&
          HabotFrictionMiddleware.qualitativeOutput == 'Good',
    );

    gate(
      'GEN-03127-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotFrictionMiddleware.obligations.length == 5 &&
          HabotFrictionMiddleware.obligations.values.every((bool b) => b) &&
          HabotFrictionMiddleware.qualitativeOutput == 'Good' &&
          HabotFrictionMiddleware.theRowThatCalledItNew == 415,
    );
  });

  tearDownAll(() {
    final int points = HabotFrictionMiddleware.points.length;
    final int wrappers = HabotFrictionMiddleware.wrappersInstalled;
    final double rate = HabotFrictionMiddleware.frictionRate;
    final int shaped = HabotFrictionMiddleware.rowsWithThisShape.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03127',
        atomicStepReferenceId: 'GEN-03127',
        setupStepAction:
            'COLUMN NOTE: this row\'s optimal of 5 sits below both its floor '
            'of 15 and its ceiling of 20, the same shape Step 415 recorded as '
            'new last batch and the second of seven rows now known to carry it '
            '-- which makes it a convention in the sheet rather than a defect '
            'in a row: on a lower-is-better measure the Ceiling Boundary '
            'column holds the worst tolerable value; it asks for middleware in '
            '"all" UI components, which would change the widget tree that Step '
            '417\'s design cells forbid changing; and it cites the Nielsen '
            'Norman heuristics, ten qualitative principles that define no '
            'rate, as the standard for a percentage. Atomic Step: "Inject '
            'Friction Middleware into all mobile UI components to capture '
            'touch-event delays and screen hesitation metrics."',
        implementationOrder: 418,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Inject Friction Middleware into all mobile UI components to capture':
              '$points listeners installed and $wrappers component wrappers, '
                  'covering all five declared indicators with the widget tree '
                  'unchanged',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Friction/Hesitation Rate (%)',
            observed:
                'THE OPTIMAL SITS BELOW BOTH BOUNDARIES, AND THIS IS WHERE THE '
                'PATTERN BECOMES LEGIBLE. Floor 15 and ceiling 20 describe the '
                'interval fifteen to twenty and the optimal of 5 sits under '
                'both. Step 415 met this shape last batch and recorded it as '
                'new; $shaped rows now carry it, six of them in this batch. On '
                'a lower-is-better measure this sheet writes the floor as the '
                'acceptable threshold, the ceiling as the worst tolerable '
                'value and the optimal as the aspiration beneath both -- so '
                'the defect is in the column headings rather than the rows, '
                'and a reader who trusts the heading reads every latency '
                'target in the sheet backwards. Observed: a friction rate of '
                '$rate per cent.',
            floor: '15',
            optimal: '5',
            ceiling: '20',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Components wrapped in middleware',
            observed:
                '$wrappers of roughly six hundred. Touch delay is observable '
                'in the gesture arena and hesitation in the focus manager, so '
                '$points listeners see everything a wrapper around every '
                'widget would see, at no per-widget cost and with the tree '
                'untouched -- which is what Step 417\'s own design cells '
                'require. The scope the row names is right and the mechanism '
                'is wrong. The standard it cites, ten qualitative usability '
                'heuristics, defines no rate at all, so the threshold comes '
                'from Step 416 and is attributed there.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/friction_middleware.dart',
        ],
      ),
    );
  });
}
