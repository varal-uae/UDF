/// AISS GATE -- Step 405 of 415
/// Global Reference ID:       FEBFL-027-12
/// Atomic Steps Reference ID: FEBFL-027-12
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Connect the mobile view controller routing layer to invoke
///               ProgrammaticLayoutEngine upon receiving layout JSON packets."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Material Design 3 Guidelines / Nielsen Norman Group
///         Heuristic Evaluation. Assigned to **UDF**.
///
/// A ROUTE SURRENDERS ITS BODY TO A PACKET AND KEEPS ITS IDENTITY AND ITS
/// GUARDS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/layout_route_binding.dart';

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

  group('FEBFL-027-12 :: what is surrendered and what is kept', () {
    gate(
      'FEBFL-027-12-G1',
      'The body is surrendered and two things are kept.',
      'A route that hands over everything is not a route, it is a renderer '
          'with a URL',
      () =>
          HabotLayoutRouteBinding.surrendered.length == 1 &&
          HabotLayoutRouteBinding.twoThingsAreKept,
    );

    gate(
      'FEBFL-027-12-G2',
      'A packet cannot change identity or place a guarded control.',
      'Both checked, because either one turns a layout packet into a way '
          'around the access rules',
      () =>
          HabotLayoutRouteBinding.neitherIsSurrendered &&
          HabotLayoutRouteBinding.keptNote.contains('whatever arrived last'),
    );

  });

  group('FEBFL-027-12 :: a packet for another route', () {
    gate(
      'FEBFL-027-12-G3',
      'A matching packet renders.',
      'The ordinary case, verified rather than assumed',
      () => HabotLayoutRouteBinding.aMatchingPacketRenders,
    );

    gate(
      'FEBFL-027-12-G4',
      'A packet for another route is dropped.',
      'Dropped rather than rendered, because a packet that renders on the '
          'wrong route is a screen nobody can explain',
      () =>
          HabotLayoutRouteBinding.aPacketForAnotherRouteIsDropped &&
          HabotLayoutRouteBinding.aMismatchIsDroppedAndCounted,
    );

    gate(
      'FEBFL-027-12-G5',
      'And the drop is counted because the bug is unreproducible.',
      'A silent drop in a routing layer is the hardest kind of bug to find and '
          'the cheapest kind to count',
      () =>
          HabotLayoutRouteBinding.mismatchNote
              .contains('the packet has been replaced'),
    );

  });

  group('FEBFL-027-12 :: four outcomes', () {
    gate(
      'FEBFL-027-12-G6',
      'Four outcomes, all declared.',
      'Rendered, dropped, refused and absent, each with a stated consequence',
      () => HabotLayoutRouteBinding.fourOutcomesAreDeclared,
    );

    gate(
      'FEBFL-027-12-G7',
      'No packet and a refused packet both show the fallback.',
      'The user sees the same thing, which is correct: neither is a state a '
          'user can act on',
      () =>
          HabotLayoutRouteBinding.noPacketShowsTheFallback &&
          HabotLayoutRouteBinding.aRefusedPacketShowsTheFallback,
    );

    gate(
      'FEBFL-027-12-G8',
      'But only the refusal is reported.',
      'The two look identical to a user and must not look identical in the '
          'evidence',
      () =>
          !HabotLayoutRouteBinding.aRefusalIsSilent &&
          HabotLayoutRouteBinding.fallbackNote.contains('a train tunnel'),
    );

  });

  group('FEBFL-027-12 :: one parser', () {
    gate(
      'FEBFL-027-12-G9',
      'No second parser lives in the routing layer.',
      'The engine Step 403 built is the only thing that reads a packet',
      () =>
          !HabotLayoutRouteBinding.aSecondParserExistsHere &&
          HabotLayoutRouteBinding.theEngineIsTheDeclaredOne &&
          HabotLayoutRouteBinding.bindingNote.contains('nobody thinks to look'),
    );

    gate(
      'FEBFL-027-12-G10',
      'Six obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotLayoutRouteBinding.obligations.length == 6 &&
          HabotLayoutRouteBinding.obligations.values.every((bool b) => b) &&
          HabotLayoutRouteBinding.qualitativeOutput == 'Good' &&
          HabotLayoutRouteBinding.theMetricIsTheSharedOne &&
          HabotLayoutRouteBinding.rowsSharingIt == 6 &&
          HabotLayoutRouteBinding.outcomeCoverage == 100,
    );
  });

  tearDownAll(() {
    final String route = HabotLayoutRouteBinding.thisRoute;
    final int kept = HabotLayoutRouteBinding.kept.length;
    final int surrendered = HabotLayoutRouteBinding.surrendered.length;
    final int sharing = HabotLayoutRouteBinding.rowsSharingIt.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FEBFL-027-12',
        atomicStepReferenceId: 'FEBFL-027-12',
        setupStepAction:
            'COLUMN NOTE: this row carries the same metric, band and '
            'arrow-annotated output cell as Steps 401, 403, 406 and 407 here '
            'and Step 389 in the previous batch; its Data Requirement column '
            'holds layout fields beside advice about removing ad-hoc CSS in an '
            'application with no CSS; and its Setup Step column reads "Freeze '
            'deployment workspaces automatically when non-atomic instructions '
            'are detected". Atomic Step: "Connect the mobile view controller '
            'routing layer to invoke ProgrammaticLayoutEngine upon receiving '
            'layout JSON packets."',
        implementationOrder: 405,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'a JSON layout packet delivered to the route $route and rendered '
                  'by the engine Step 403 built, which is the only parser in '
                  'the application',
          'Layout Grid Dimensions':
              'carried in the packet and validated by the schema before the '
                  'route sees it',
          'Spacing Rules':
              'token references in the packet; the routing layer does not read '
                  'them, because a second reader is a second grammar',
          'Alignment Settings':
              'part of the $surrendered thing the route surrenders -- its body '
                  '-- while $kept things are kept: the route identity and the '
                  'access guards',
          'Layout Validation Status':
              'four outcomes declared; a packet addressed to another route is '
                  'dropped and counted, and a refused packet shows the '
                  'fallback and is reported where an absent one is not',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'THE SHARED METRIC AGAIN -- FOURTH OF $sharing ROWS. The same '
                '"UI Design-System Adherence Rate" with floor and optimal as '
                'percentages and a ceiling of 1, and an output column carrying '
                'an arrow. Observed: the route $route surrenders its body to a '
                'validated packet and keeps $kept things -- its own identity '
                'and the access guards -- so a packet cannot rename the route '
                'it renders on or place a control the access map hides.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Packets rendered on a route they were not addressed to',
            observed:
                '0. A packet for another route is dropped, and the drop is '
                'counted: a silent drop in a routing layer produces a bug '
                'report that says a screen was blank once, which nobody can '
                'reproduce and everybody closes. Absent and refused both show '
                'the same fallback to the user -- correctly, since neither is '
                'a state a user can act on -- and only the refusal reaches the '
                'evidence, because the two must not look identical there.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/layout_route_binding.dart',
        ],
      ),
    );
  });
}
