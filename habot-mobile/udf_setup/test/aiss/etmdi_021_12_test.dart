/// AISS GATE -- Step 296 of 315
/// Global Reference ID:       ETMDI-021-12
/// Atomic Steps Reference ID: ETMDI-021-12
/// Setup Step (Action): "Confirm that single-handed ergonomic thumb access is
///                      maintained on handheld mobile screens." (A LOADING
///                      INDICATOR IS NOT A CONTROL)
/// Atomic Step: "Ensure app screens show clear background loading items during
///               routing."
/// Metric: Process Execution Quality Score -- floor >=90%, optimal >=98%,
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// SHOW IT ON EVERY ROUTE AND FOUR OF SIX FLASH. THE ROW ALSO ASKS FOR FOUR
/// TOOLTIPS, WHICH THE GUARD HAS FORBIDDEN SINCE STEP 4.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/route_loading.dart';

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

  group('ETMDI-021-12 :: which routes show anything', () {
    gate(
      'ETMDI-021-12-G1',
      'Atomic Step: "show clear background loading items during routing".',
      'Six routes, three of which never show an indicator because they '
          'finish inside the 300ms delay',
      () =>
          HabotRouteLoading.routes.length == 6 &&
          HabotRouteLoading.routesThatShow.length == 3 &&
          HabotRouteLoading.routesThatStaySilent.length == 3 &&
          HabotRouteLoading.shareSilent == 0.5,
    );

    gate(
      'ETMDI-021-12-G2',
      'The naive reading of the instruction.',
      'Shown on every route, four of the six appear for less than the '
          'minimum readable time -- 40ms on settings, 90ms on profile',
      () =>
          HabotRouteLoading.routesThatWouldFlash.length == 4 &&
          HabotRouteLoading.naiveVisibleMsFor(HabotRouteLoading.routes[2]) ==
              40,
    );

    gate(
      'ETMDI-021-12-G3',
      'Two thresholds, both already tokens.',
      'Nothing shown can appear for less than 500ms, and the longest route '
          'holds its indicator for the work itself rather than for a fixed '
          'window',
      () =>
          HabotRouteLoading.noIndicatorEverFlashes &&
          HabotRouteLoading.visibleMsFor(HabotRouteLoading.routes[1]) == 500 &&
          HabotRouteLoading.visibleMsFor(HabotRouteLoading.routes[4]) == 2700,
    );

    gate(
      'ETMDI-021-12-G4',
      'The scope was built at Step 194 and is not rebuilt.',
      'The delay and the minimum are read from the motion tokens rather '
          'than written here',
      () =>
          HabotRouteLoading.appearAfter.inMilliseconds == 300 &&
          HabotRouteLoading.minimumVisible.inMilliseconds == 500 &&
          HabotRouteLoading.thresholdNote.contains('Step 194'),
    );
  });

  group('ETMDI-021-12 :: what "clear" means', () {
    gate(
      'ETMDI-021-12-G5',
      'Atomic Step: "clear background loading items".',
      'Every visible indicator names its own operation and describes the '
          'work in words, so a scope that never closes can say what it is '
          'waiting for',
      () =>
          HabotRouteLoading.everyVisibleIndicatorHasWords &&
          HabotRouteLoading.everyDescriptionNamesTheWork,
    );

    gate(
      'ETMDI-021-12-G6',
      'An unlabelled circle cannot be wrong and cannot help.',
      'The reason is recorded rather than assumed',
      () => HabotRouteLoading.clarityNote.contains('cannot be wrong'),
    );
  });

  group('ETMDI-021-12 :: the instructions that are refused', () {
    gate(
      'ETMDI-021-12-G7',
      'Four configuration cells ask for Material Tooltips.',
      'A tooltip is a hover affordance and HOVER_TOOLTIP has forbidden it '
          'since Step 4; the instruction is recorded with its reason rather '
          'than written and linted out later',
      () =>
          !HabotRouteLoading.tooltipsAreWrittenHere &&
          HabotRouteLoading.guardRule == 'HOVER_TOOLTIP' &&
          HabotRouteLoading.tooltipNote.contains('there is no hover'),
    );

    gate(
      'ETMDI-021-12-G8',
      'Setup Step: "single-handed ergonomic thumb access".',
      'A loading indicator is not a control, so the reach band says nothing '
          'about where it sits; reach belongs to the controls the route lands '
          'on, which Step 176 measures',
      () =>
          !HabotRouteLoading.theIndicatorIsInteractive &&
          HabotRouteLoading.reachNote.contains('Step 176'),
    );
  });

  group('ETMDI-021-12 :: the band', () {
    gate(
      'ETMDI-021-12-G9',
      'Ceiling "1" against a floor of ">=90%".',
      'Read as a rate the ceiling is the optimal; read as a count it is a '
          'different unit from both, and it is recorded rather than scored '
          'against',
      () => HabotRouteLoading.ceilingNote.contains('not in the same unit'),
    );

    gate(
      'ETMDI-021-12-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving 1.0 and a Good; all nine '
          'declared checks hold',
      () =>
          HabotRouteLoading.obligations.length == 6 &&
          HabotRouteLoading.obligations.values.every((bool b) => b) &&
          HabotRouteLoading.executionQuality == 1.0 &&
          HabotRouteLoading.qualitativeOutput == 'Good' &&
          HabotRouteLoading.checks.length == 9 &&
          HabotRouteLoading.checks.values.every((bool b) => b) &&
          HabotRouteLoading.columnNote.contains('tooltips'),
    );
  });

  tearDownAll(() {
    final String silent = HabotRouteLoading.routesThatStaySilent
        .map((HabotRoute r) => r.name)
        .join(', ');
    final String longest =
        '${HabotRouteLoading.visibleMsFor(HabotRouteLoading.routes[4])}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-021-12',
        atomicStepReferenceId: 'ETMDI-021-12',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Confirm '
            'that single-handed ergonomic thumb access is maintained on '
            'handheld mobile screens", which is a reach question about a '
            'thing nobody taps, and all four Mobile UX/UI configuration cells '
            'are about tooltips. Atomic Step: "Ensure app screens show clear '
            'background loading items during routing."',
        implementationOrder: 296,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'ETMDI-021-12',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '${HabotRouteLoading.routes.length} routes, '
                  '${HabotRouteLoading.routesThatShow.length} of which show an '
                  'indicator; the silent ones are $silent',
          'User ID': 'Fredrick',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THRESHOLDS: ${HabotRouteLoading.thresholdNote} '
              'CLARITY: ${HabotRouteLoading.clarityNote} '
              'TOOLTIPS: ${HabotRouteLoading.tooltipNote} '
              'REACH: ${HabotRouteLoading.reachNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotRouteLoading.obligations.length} declared '
                'obligations. The ceiling is written as 1 against a floor of '
                '">=90%", so the three boundaries are not in one unit; '
                'recorded rather than scored against.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Routes whose indicator could flash',
            observed:
                '0 of ${HabotRouteLoading.routes.length} with the two '
                'thresholds applied, against 4 without them. The longest '
                'route holds its indicator for ${longest}ms, which is the '
                'work rather than a fixed window.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/route_loading.dart',
        ],
      ),
    );
  });
}
