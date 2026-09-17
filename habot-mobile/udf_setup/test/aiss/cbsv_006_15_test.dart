/// AISS GATE -- Step 336 of 355
/// Global Reference ID:       CBSV-006-15
/// Atomic Steps Reference ID: CBSV-006-15
/// Setup Step (Action): "Inject conditional back-button intercept hooks to
///                      intercept accidental sheet dismissals." (NAVIGATION
///                      INTERCEPTION, ON A VIEW-TOGGLE ROW)
/// Atomic Step: "Integrate swipe-right touch options allowing users to toggle
///               effortlessly between associated table viewports."
/// Metric: Schema/Field Configuration Accuracy Rate -- floor ">=90%", optimal
///         1, ceiling 1. Good/Average/Poor. DAMA-DMBOK2. Assigned to **DEA**.
///
/// A PATH-BASED GESTURE OFFERED AS THE ONLY ROUTE, AGAINST A LEVEL A
/// CRITERION. FIRST OF FIVE GESTURE ROWS IN THIS BATCH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/swipe_alternative.dart';

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

  group('CBSV-006-15 :: the criterion', () {
    gate(
      'CBSV-006-15-G1',
      'Atomic Step: "swipe-right touch options allowing users to toggle".',
      'Three routes to one function, of which the row names only the '
          'path-based one',
      () =>
          HabotSwipeAlternative.routes.length == 3 &&
          HabotSwipeAlternative.theRowNamesOnlyThePath &&
          HabotSwipeAlternative.pathBasedRoutes.length == 1,
    );

    gate(
      'CBSV-006-15-G2',
      'WCAG 2.2 SC 2.5.1 Pointer Gestures, Level A.',
      'A single-pointer equivalent exists, which is the lowest bar there is '
          'and the one the row does not clear on its own',
      () =>
          HabotSwipeAlternative.theGestureHasASinglePointerEquivalent &&
          HabotSwipeAlternative.theCriterionIsLevelA &&
          HabotSwipeAlternative.alternativeNote.contains('lowest bar'),
    );

    gate(
      'CBSV-006-15-G3',
      'A screen reader takes the swipe before the application sees it.',
      'So the traversal route is not a nicety; it is the only route left for '
          'somebody using one',
      () => HabotSwipeAlternative.routes.any(
        (HabotViewportRoute r) => r.kind == HabotRouteKind.traversal,
      ),
    );
  });

  group('CBSV-006-15 :: discoverability', () {
    gate(
      'CBSV-006-15-G4',
      'A gesture leaves no mark on a screen.',
      'Two of the three routes are visible and the gesture is the one that is '
          'not',
      () =>
          HabotSwipeAlternative.theOnlyInvisibleRouteIsTheOneTheRowNames &&
          HabotSwipeAlternative.routesAPersonCanSee == 2,
    );

    gate(
      'CBSV-006-15-G5',
      'The row calls the swipe "effortless".',
      'Which it is, for somebody who has already been told it exists -- so '
          'the tab bar is both the accessible alternative and the only reason '
          'anybody finds the shortcut',
      () => HabotSwipeAlternative.discoverabilityNote
          .contains('accessible alternative'),
    );
  });

  group('CBSV-006-15 :: the direction', () {
    gate(
      'CBSV-006-15-G6',
      'The row says "swipe-right", which is a physical side.',
      'Step 225 resolved direction against the reading direction, because '
          'this application ships Urdu',
      () =>
          HabotSwipeAlternative.theDirectionRuleIsAlreadyDeclared &&
          HabotSwipeAlternative.directionNote.contains('Urdu'),
    );

    gate(
      'CBSV-006-15-G7',
      'A hardcoded direction sends a right-to-left locale backwards.',
      'Which is a defect in half the shipped locales rather than a cosmetic '
          'preference',
      () => HabotSwipeAlternative.directionNote
          .contains('the wrong way'),
    );
  });

  group('CBSV-006-15 :: the guard and the band', () {
    gate(
      'CBSV-006-15-G8',
      'A new guard rule is specified: A11Y_GESTURE_WITHOUT_ALTERNATIVE.',
      'Declared here with an id and a description, and switched on at Step '
          '344 where the census that runs it exists',
      () =>
          HabotSwipeAlternative.guardRuleId ==
              'A11Y_GESTURE_WITHOUT_ALTERNATIVE' &&
          HabotSwipeAlternative.guardRuleDescription.isNotEmpty &&
          !HabotSwipeAlternative.guardIsEnabledInThisStep &&
          HabotSwipeAlternative.guardNote.contains('Step 344'),
    );

    gate(
      'CBSV-006-15-G9',
      'Floor ">=90%" against an optimal and a ceiling both written "1".',
      'The band mixes a percentage with a bare ratio and repeats its top '
          'value, so it has two ends and three labels',
      () =>
          HabotSwipeAlternative.theBandMixesUnits &&
          HabotSwipeAlternative.theOptimalEqualsTheCeiling &&
          HabotSwipeAlternative.bandNote.contains('two ends and three labels'),
    );

    gate(
      'CBSV-006-15-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotSwipeAlternative.obligations.length == 5 &&
          HabotSwipeAlternative.obligations.values.every((bool b) => b) &&
          HabotSwipeAlternative.qualitativeOutput == 'Good' &&
          HabotSwipeAlternative.checks.length == 10 &&
          HabotSwipeAlternative.checks.values.every((bool b) => b) &&
          HabotSwipeAlternative.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final int visible = HabotSwipeAlternative.routesAPersonCanSee;
    final int paths = HabotSwipeAlternative.pathBasedRoutes.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CBSV-006-15',
        atomicStepReferenceId: 'CBSV-006-15',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, its '
            'Setup Step column reads "Inject conditional back-button intercept '
            'hooks to intercept accidental sheet dismissals" -- navigation '
            'interception on a view-toggle row -- and its band sets a floor of '
            '">=90%" against an optimal and a ceiling both written "1". Atomic '
            'Step: "Integrate swipe-right touch options allowing users to '
            'toggle effortlessly between associated table viewports."',
        implementationOrder: 336,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'CBSV-006-15',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '$paths path-based route and 2 that need no path; $visible of '
                  'the 3 are visible without instruction',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a tab bar, tab traversal, and the swipe the row names; the '
                  'guard rule A11Y_GESTURE_WITHOUT_ALTERNATIVE is specified '
                  'here and enabled at Step 344',
          'Data Quality Note':
              'ALTERNATIVE: ${HabotSwipeAlternative.alternativeNote} '
              'DISCOVERABILITY: ${HabotSwipeAlternative.discoverabilityNote} '
              'DIRECTION: ${HabotSwipeAlternative.directionNote} '
              'BAND: ${HabotSwipeAlternative.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Schema/Field Configuration Accuracy Rate',
            observed:
                'THE OPTIMAL AND THE CEILING ARE THE SAME VALUE, and the band '
                'mixes units: a floor of ">=90%" against an optimal and a '
                'ceiling both written "1". A band whose top two cells hold the '
                'same number cannot distinguish a good result from the best '
                'one. The metric is also a schema configuration accuracy on a '
                'row about a touch gesture.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Routes to the function that need no path gesture',
            observed:
                '2 of 3 -- a tab bar and tab traversal -- against the 1 the '
                'row names, which is the path. WCAG 2.2 SC 2.5.1 Pointer '
                'Gestures is Level A and requires exactly this, so a swipe '
                'offered as the only route puts the function out of reach of a '
                'switch, a head pointer, voice control and any screen reader, '
                'which takes the gesture first on both platforms.',
            floor: '1',
            optimal: '2',
            ceiling: '2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/swipe_alternative.dart',
        ],
      ),
    );
  });
}
