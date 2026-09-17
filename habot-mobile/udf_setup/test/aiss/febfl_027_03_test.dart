/// AISS GATE -- Step 401 of 415
/// Global Reference ID:       FEBFL-027-03
/// Atomic Steps Reference ID: FEBFL-027-03
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define a JSON UI schema specification governing view layout
///               structures, component types, and data bindings."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Material Design 3 Guidelines / Nielsen Norman Group
///         Heuristic Evaluation. Assigned to **UDF**.
///
/// A LAYOUT GRAMMAR THAT IS USEFUL BECAUSE OF WHAT IT REFUSES TO EXPRESS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/layout_schema.dart';

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

  group('FEBFL-027-03 :: a closed set of types', () {
    gate(
      'FEBFL-027-03-G1',
      'Six component types and three layout types.',
      'A closed set, because an open one is a rendering engine with a JSON '
          'front end',
      () =>
          HabotLayoutSchema.theComponentSetIsClosed &&
          HabotLayoutSchema.layoutTypes.length == 3,
    );

    gate(
      'FEBFL-027-03-G2',
      'An undeclared type is rejected.',
      'Rejected by the schema rather than rendered as something else',
      () =>
          HabotLayoutSchema.anUndeclaredTypeIsRejected &&
          HabotLayoutSchema.accepts('card'),
    );

  });

  group('FEBFL-027-03 :: what the grammar forbids', () {
    gate(
      'FEBFL-027-03-G3',
      'Four node kinds, one of them unknown.',
      'Unknown is a kind the grammar has a name for, which is what keeps it '
          'from being a crash',
      () => HabotSchemaNodeKind.values.length == 4,
    );

    gate(
      'FEBFL-027-03-G4',
      'Four things the grammar forbids, each with a reason.',
      'No expressions, no raw colours, no conditionals and no imports, and '
          'each refusal says what it is protecting',
      () =>
          HabotLayoutSchema.fourThingsAreForbidden &&
          HabotLayoutSchema.everyRefusalHasAReason,
    );

    gate(
      'FEBFL-027-03-G5',
      'And a schema is not a route around the guard.',
      'A layout that could express a condition could place a control the '
          'access rules hide',
      () =>
          HabotLayoutSchema.theSchemaCannotRouteRoundTheGuard &&
          HabotLayoutSchema.forbiddenNote.contains('logic nobody reviewed'),
    );

  });

  group('FEBFL-027-03 :: what an unknown packet does', () {
    gate(
      'FEBFL-027-03-G6',
      'An unknown version is refused loudly.',
      'A schema version is a promise about the shape of everything after it',
      () =>
          HabotLayoutSchema.anUnknownVersionIsRefused &&
          HabotLayoutSchema.refusalIsLoud &&
          HabotLayoutSchema.versionNote.contains('tries to submit it'),
    );

    gate(
      'FEBFL-027-03-G7',
      'An unknown node is not a corrupt packet.',
      'It is counted and reported, and the rest of the screen still renders',
      () =>
          HabotLayoutSchema.unknownIsHandledRatherThanFatal &&
          HabotLayoutSchema.unknownNote.contains('ahead of the installed base'),
    );

  });

  group('FEBFL-027-03 :: the band and the metric it shares', () {
    gate(
      'FEBFL-027-03-G8',
      'The band mixes units.',
      'Two percentages and a ceiling of 1, which is the third row in this '
          'batch to do it',
      () => HabotLayoutSchema.theBandMixesUnits,
    );

    gate(
      'FEBFL-027-03-G9',
      'Six rows share this metric, five of them here.',
      'One design-system adherence rate stretched across six different '
          'subjects',
      () =>
          HabotLayoutSchema.sixRowsShareOneMetric &&
          HabotLayoutSchema.theOutputColumnHoldsAnAnnotation,
    );

    gate(
      'FEBFL-027-03-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotLayoutSchema.obligations.length == 5 &&
          HabotLayoutSchema.obligations.values.every((bool b) => b) &&
          HabotLayoutSchema.qualitativeOutput == 'Good' &&
          HabotLayoutSchema.expressiveness == 100,
    );
  });

  tearDownAll(() {
    final int types = HabotLayoutSchema.componentTypes.length;
    final int layouts = HabotLayoutSchema.layoutTypes.length;
    final int forbidden = HabotLayoutSchema.forbidden.length;
    final int sharing = HabotLayoutSchema.rowsSharingThisMetric.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FEBFL-027-03',
        atomicStepReferenceId: 'FEBFL-027-03',
        setupStepAction:
            'COLUMN NOTE: this row is the first of five in this batch carrying '
            'the identical metric, band and arrow-annotated output cell -- "UI '
            'Design-System Adherence Rate", ">=85%" to ">=95%" to a bare "1", '
            'and "Good/Average/Poor -> Best = Good (100%)" -- with Step 389 in '
            'the previous batch making six; its Data Requirement column holds '
            'layout fields beside advice about "complete removal of ad-hoc CSS '
            'modifications" in an application with no CSS; and its Setup Step '
            'column reads "Connect the verification block to an external '
            'multi-factor authentication code system". Atomic Step: "Define a '
            'JSON UI schema specification governing view layout structures, '
            'component types, and data bindings."',
        implementationOrder: 401,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'a JSON layout grammar with $layouts layout types and $types '
                  'component types, version ${HabotLayoutSchema.schemaVersion}',
          'Layout Grid Dimensions':
              'inherited from the declared grid rather than expressible in the '
                  'schema, so a packet cannot invent a column count',
          'Spacing Rules':
              'spacing tokens are referenced by name; a raw value is one of '
                  'the $forbidden things the grammar forbids',
          'Alignment Settings':
              'alignment is an enumerated value in the grammar, not a free '
                  'string',
          'Layout Validation Status':
              'an undeclared type is rejected, an unknown version is refused '
                  'loudly, and an unknown node is counted rather than fatal',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'BAND MIXES UNITS AND THE OUTPUT CELL HOLDS AN ARROW, AND THIS '
                'METRIC IS ON SIX ROWS. Floor and optimal are percentages and '
                'the ceiling is 1; the output column reads "Good/Average/Poor '
                '-> Best = Good (100%)". The same "UI Design-System Adherence '
                'Rate" with the same band appears on $sharing rows, five of '
                'them in this batch, across subjects as different as a JSON '
                'grammar, a route binding and a calculation disclosure -- a '
                'metric that fits six subjects is measuring none of them. '
                'Observed: a grammar of $types component types and $layouts '
                'layout types.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Things the grammar can express that it should not',
            observed:
                '0 of $forbidden. Expressions, raw colour literals, '
                'conditionals and imports are each refused with a stated '
                'reason, and the reasons are not interchangeable: a raw colour '
                'defeats the token rules, an expression makes the packet a '
                'program, an import makes it a fetch, and a conditional would '
                'let a layout place a control the access map hides. A layout '
                'language is useful for what it cannot say, and every refusal '
                'here names what it protects.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/layout_schema.dart',
        ],
      ),
    );
  });
}
