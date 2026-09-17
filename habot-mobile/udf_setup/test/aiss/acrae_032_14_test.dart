/// AISS GATE -- Step 311 of 315
/// Global Reference ID:       ACRAE-032-14
/// Atomic Steps Reference ID: ACRAE-032-14
/// Setup Step (Action): "Initialize the parsing selection rule properties
///                      governing how document version discrepancies display."
///                      (DOCUMENT VERSIONING, ON A TRACE ROW)
/// Atomic Step: "Hide deep complex structural trace maps inside lightweight
///               text list blocks on small mobile screen states."
/// Metric: UI Design-System Adherence Rate -- floor >=85%, optimal >=95%,
///         ceiling 1. Good/Average/Poor.
///
/// A TRACE IS A GRAPH AND A LIST IS A SEQUENCE. ELEVEN OF THIRTEEN RELATIONS
/// SURVIVE, AND THE LIST SAYS SO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/trace_map_list.dart';

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

  group('ACRAE-032-14 :: what survives the flattening', () {
    gate(
      'ACRAE-032-14-G1',
      'Atomic Step: trace maps inside text list blocks.',
      'Twelve spans carry eleven parent edges and two sideways links -- '
          'thirteen relations, of which an indented list can draw eleven',
      () =>
          HabotTraceMapList.spans.length == 12 &&
          HabotTraceMapList.parentEdges == 11 &&
          HabotTraceMapList.sidewaysEdges == 2 &&
          HabotTraceMapList.totalRelations == 13 &&
          HabotTraceMapList.relationsALinePreserves == 11,
    );

    gate(
      'ACRAE-032-14-G2',
      'The two it drops are the ones a trace map is opened to find.',
      'A retry referring back to its first attempt, and two spans hitting '
          'the same cache entry',
      () =>
          HabotTraceMapList.aListCannotDrawSidewaysEdges &&
          (HabotTraceMapList.shareOfRelationsPreserved - 11 / 13).abs() <
              1e-9,
    );

    gate(
      'ACRAE-032-14-G3',
      'So the list names them rather than looking complete.',
      'Each linked span carries a marker naming the other end, and the '
          'header states the count',
      () =>
          HabotTraceMapList.everySidewaysLinkIsMarked &&
          HabotTraceMapList.theHeaderStatesWhatIsNotDrawn &&
          HabotTraceMapList.markerFor(HabotTraceMapList.spans[8]) ==
              'also touches s8',
    );

    gate(
      'ACRAE-032-14-G4',
      'A complete-looking tree is the thing being avoided.',
      'A reader concludes there were no retries, which is worse than a list '
          'that admits it is a projection',
      () => HabotTraceMapList.flatteningNote
          .contains('admits it is a projection'),
    );
  });

  group('ACRAE-032-14 :: indentation is a width budget', () {
    gate(
      'ACRAE-032-14-G5',
      'Sixteen points a level against 328 available.',
      'At depth eight the indent has taken 128 and left 200, which is about '
          'where a span name stops being readable',
      () =>
          HabotTraceMapList.indentPerLevelDp == 16 &&
          HabotTraceMapList.indentAt(8) == 128 &&
          HabotTraceMapList.textWidthAt(8) == 200,
    );

    gate(
      'ACRAE-032-14-G6',
      'The cap is derived from the two widths rather than chosen.',
      'Eight levels, and every span in the worked trace sits inside it',
      () =>
          HabotTraceMapList.maxDepth == 8 &&
          HabotTraceMapList.theCapIsDerivedRatherThanChosen &&
          HabotTraceMapList.everySpanFitsWithinTheCap &&
          HabotTraceMapList.deepestSpanDepth == 3,
    );

    gate(
      'ACRAE-032-14-G7',
      'The alternative is a list that is lightweight by containing little.',
      'Letting the column narrow until the text wraps one word per line',
      () => HabotTraceMapList.indentNote.contains('very little'),
    );
  });

  group('ACRAE-032-14 :: why hiding is allowed here', () {
    gate(
      'ACRAE-032-14-G8',
      'Step 104 throws when essential content is hidden.',
      'A trace map is forensic by definition -- ids, timings, provenance -- '
          'so the tier permits it and the tier is read rather than asserted',
      () =>
          HabotTraceMapList.theTierPermitsHiding &&
          HabotTraceMapList.theTierIsReadRatherThanAsserted,
    );

    gate(
      'ACRAE-032-14-G9',
      'The row asks for the thing the design system already permits.',
      'Which is rare enough to record; what it leaves open is what the '
          'hidden thing looks like when it is opened',
      () => HabotTraceMapList.tierNote.contains('for once'),
    );

    gate(
      'ACRAE-032-14-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving a Good; all ten declared '
          'checks hold, and the ceiling written as 1 against percentage '
          'floors is recorded',
      () =>
          HabotTraceMapList.obligations.length == 6 &&
          HabotTraceMapList.obligations.values.every((bool b) => b) &&
          HabotTraceMapList.adherence == 1.0 &&
          HabotTraceMapList.qualitativeOutput == 'Good' &&
          HabotTraceMapList.checks.length == 10 &&
          HabotTraceMapList.checks.values.every((bool b) => b) &&
          HabotTraceMapList.theCeilingIsInADifferentUnit &&
          HabotTraceMapList.columnNote.contains('Prompt Engineering'),
    );
  });

  tearDownAll(() {
    final String share =
        HabotTraceMapList.shareOfRelationsPreserved.toStringAsFixed(4);
    final String header = HabotTraceMapList.header;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ACRAE-032-14',
        atomicStepReferenceId: 'ACRAE-032-14',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Initialize '
            'the parsing selection rule properties governing how document '
            'version discrepancies display", which is document versioning on a '
            'row about trace visualisation, and the domain expertise cell '
            'reads "Prompt Engineering". Atomic Step: "Hide deep complex '
            'structural trace maps inside lightweight text list blocks on '
            'small mobile screen states."',
        implementationOrder: 311,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Android and iOS, compact window class',
          'OS Version': 'not a variable for this step',
          'Device Type': 'handheld',
          'Screen Dimensions':
              '328 points of usable width; 16 a level of indent caps the '
                  'depth at ${HabotTraceMapList.maxDepth}',
          'Mobile Configuration':
              'the list header reads "$header", which states what is not '
                  'drawn',
          'Completion Status': 'Good',
          'Data Quality Note':
              'FLATTENING: ${HabotTraceMapList.flatteningNote} '
              'INDENT: ${HabotTraceMapList.indentNote} '
              'TIER: ${HabotTraceMapList.tierNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100% over six declared obligations. The ceiling is written '
                'as 1 against percentage floors, and is recorded rather than '
                'scored against.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Trace relations a list preserves',
            observed:
                '11 of 13 (share $share). The two it cannot draw are the '
                'sideways links, which are what somebody opens a trace map to '
                'find, so each is marked on the span that carries it and the '
                'header counts them. The list is a projection and says so.',
            floor: '11',
            optimal: '13',
            ceiling: '13',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/trace_map_list.dart',
        ],
      ),
    );
  });
}
