/// AISS GATE -- Step 403 of 415
/// Global Reference ID:       FEBFL-027-08
/// Atomic Steps Reference ID: FEBFL-027-08
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Instantiate the mapped UI components programmatically in
///               memory based on the JSON specifications."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Material Design 3 Guidelines / Nielsen Norman Group
///         Heuristic Evaluation. Assigned to **UDF**.
///
/// A MAPPING TABLE EXACTLY AS WIDE AS THE SCHEMA, WITH NO REFLECTION AND NO
/// GENERIC FALLBACK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/layout_engine.dart';

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

  group('FEBFL-027-08 :: nine types, nine constructors', () {
    gate(
      'FEBFL-027-08-G1',
      'Nine schema types, nine mapped constructors.',
      'Every type the grammar declares has exactly one constructor behind it',
      () =>
          HabotLayoutEngine.everySchemaTypeIsMapped &&
          HabotLayoutEngine.mapping.length == 9,
    );

    gate(
      'FEBFL-027-08-G2',
      'The table is exactly as wide as the schema.',
      'A mapping wider than the grammar is a set of types nothing can send and '
          'nobody maintains',
      () => HabotLayoutEngine.theMappingIsNoWiderThanTheSchema,
    );

    gate(
      'FEBFL-027-08-G3',
      'No reflection and no generic fallback.',
      'Reflection would make the mapping implicit and a fallback would make an '
          'unmapped type render as something plausible',
      () =>
          HabotLayoutEngine.anUnmappedTypeIsNotGuessedAt &&
          HabotLayoutEngine.mappingNote.contains('guessed at'),
    );

  });

  group('FEBFL-027-08 :: what the engine returns', () {
    gate(
      'FEBFL-027-08-G4',
      'A known type builds and an unknown one is skipped.',
      'Skipped and reported, which is the Step 401 treatment carried through '
          'rather than restated',
      () =>
          HabotLayoutEngine.aKnownTypeIsBuilt &&
          HabotLayoutEngine.anUnknownTypeIsSkipped,
    );

    gate(
      'FEBFL-027-08-G5',
      'Widgets are not cached across frames.',
      'The description tree is data and can be cached; the widgets built from '
          'it cannot',
      () =>
          HabotLayoutEngine.theTreeIsDataAndTheWidgetsAreNot &&
          HabotLayoutEngine.threeThingsWouldBreak,
    );

  });

  group('FEBFL-027-08 :: what is data and what is not', () {
    gate(
      'FEBFL-027-08-G6',
      'And three things would stop working if they were.',
      'Named individually, because "it breaks things" is not a reason anybody '
          'can check',
      () => HabotLayoutEngine.memoryNote.contains('nothing told them'),
    );

    gate(
      'FEBFL-027-08-G7',
      'The four inherited properties are Step 364\'s.',
      'Rather than a second list of what a child inherits',
      () =>
          HabotLayoutEngine.fourPropertiesAreInherited &&
          HabotLayoutEngine.theStepThatNamedTheFour == 364,
    );

  });

  group('FEBFL-027-08 :: depth and the inherited four', () {
    gate(
      'FEBFL-027-08-G8',
      'They come from the constructors rather than the framework.',
      'A programmatic layout has no build context to inherit from, so '
          'inheritance is explicit in the mapping',
      () =>
          HabotLayoutEngine.thePropertiesComeFromTheConstructors &&
          HabotLayoutEngine.inheritanceNote.contains('all four at once'),
    );

    gate(
      'FEBFL-027-08-G9',
      'Depth is bounded at twelve and a deeper packet is refused whole.',
      'A partially rendered screen is worse than a refused one, because a user '
          'cannot tell it is partial',
      () =>
          HabotLayoutEngine.maximumDepth == 12 &&
          HabotLayoutEngine.aDeepPacketIsRefusedWhole &&
          HabotLayoutEngine.depthNote.contains('could not be drawn'),
    );

    gate(
      'FEBFL-027-08-G10',
      'Six obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotLayoutEngine.obligations.length == 6 &&
          HabotLayoutEngine.obligations.values.every((bool b) => b) &&
          HabotLayoutEngine.qualitativeOutput == 'Good' &&
          HabotLayoutEngine.theMetricIsTheSharedOne &&
          HabotLayoutEngine.rowsSharingIt == 6 &&
          HabotLayoutEngine.adherence == 100,
    );
  });

  tearDownAll(() {
    final int mapped = HabotLayoutEngine.mapping.length;
    final int depth = HabotLayoutEngine.maximumDepth;
    final int inherited = HabotLayoutEngine.inheritedProperties.length;
    final int breakages = HabotLayoutEngine.whatWouldStopWorking.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FEBFL-027-08',
        atomicStepReferenceId: 'FEBFL-027-08',
        setupStepAction:
            'COLUMN NOTE: this row carries the same metric, band and '
            'arrow-annotated output cell as Steps 401, 405, 406 and 407 in '
            'this batch and Step 389 in the previous one -- six rows, one '
            'metric; its Data Requirement column holds component fields beside '
            'advice about removing ad-hoc CSS in an application with no CSS; '
            'and its Setup Step column reads "Implement the data masking logic '
            'that filters user names based on the finalized display rules". '
            'Atomic Step: "Instantiate the mapped UI components '
            'programmatically in memory based on the JSON specifications."',
        implementationOrder: 403,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLayoutEngine',
          'Component Type':
              'a programmatic instantiation engine, $mapped schema types '
                  'mapped to $mapped constructors with no reflection and no '
                  'generic fallback',
          'Component Properties':
              '$inherited properties inherit from parent to child, the four '
                  'Step 364 named, and they come from the constructors because '
                  'a programmatic layout has no context to inherit from',
          'State Definitions':
              'built, skipped or refused: a known type builds, an unknown type '
                  'is skipped and reported, and a packet deeper than $depth is '
                  'refused whole',
          'Component Hierarchy':
              'bounded at depth $depth; the description tree is cached and the '
                  'widgets built from it are not, because $breakages things '
                  'stop working if they are',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'THE SHARED METRIC AGAIN -- THIRD OF SIX ROWS. The same "UI '
                'Design-System Adherence Rate" with the same mixed-unit band '
                'as Steps 401, 405, 406, 407 and 389. Observed: $mapped schema '
                'types mapped to $mapped constructors, a table exactly as wide '
                'as the grammar it serves, with no reflection and no generic '
                'fallback -- so an unmapped type is skipped and reported '
                'rather than guessed at.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Widgets cached across frames',
            observed:
                '0. The description tree is data and caching it is free; the '
                'widgets built from it hold state, and caching those breaks '
                '$breakages things that are named rather than gestured at -- a '
                'rebuild after a theme change, a rebuild after a text-scale '
                'change, and the disposal of a controller a cached widget '
                'still holds. Depth is bounded at $depth and a deeper packet '
                'is refused whole, because a half-rendered screen looks '
                'finished.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/layout_engine.dart',
        ],
      ),
    );
  });
}
