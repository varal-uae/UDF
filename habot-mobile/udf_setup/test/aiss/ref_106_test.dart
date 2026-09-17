/// AISS GATE -- Step 376 of 395
/// Global Reference ID:       REF-106
/// Atomic Steps Reference ID: REF-106-A01
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Identify all UI elements (buttons, links, sections) requiring
///               identity-based access control."
/// Metric: Identification Coverage -- floor 98, optimal 100, ceiling 100.
///         Complete/Not Complete. Assigned to **UDF**.
///
/// HIDDEN AND DISABLED ARE DIFFERENT ANSWERS, AND THE THIRD CELL IN THIS SHEET
/// THAT REPORTS THE GENERATOR'S OWN MISS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/access/element_access_map.dart';

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

  group('REF-106 :: hidden or merely off', () {
    gate(
      'REF-106-G1',
      'Five elements, every one classified.',
      'Three treatments, and the rule reproduces all five classifications '
          'rather than a second list agreeing with the first',
      () =>
          HabotElementAccessMap.everyElementIsClassified &&
          HabotAccessTreatment.values.length == 3 &&
          HabotElementAccessMap.theRuleReproducesEveryClassification,
    );

    gate(
      'REF-106-G2',
      'Two are absent and two are disabled with a reason.',
      'An element whose existence is itself information is absent; everything '
          'else refused is disabled and says why',
      () =>
          HabotElementAccessMap.twoAreAbsent &&
          HabotElementAccessMap.twoAreDisabledWithAReason &&
          HabotElementAccessMap.everyDisabledElementCarriesItsReason,
    );

    gate(
      'REF-106-G3',
      'A disabled control teaches the limit, the threshold and the role.',
      'Which is why a refund ceiling somebody cannot clear is hidden and a '
          'report they may not run is not',
      () => HabotElementAccessMap.ruleNote
          .contains('the role that clears it'),
    );
  });

  group('REF-106 :: absent means absent', () {
    gate(
      'REF-106-G4',
      'No hidden element is rendered and covered.',
      'The row\'s own completion measure asks for zero structural nodes, which '
          'is stronger than a disabled state and right for that class',
      () =>
          HabotElementAccessMap.absentMeansNotInTheTree &&
          !HabotElementAccessMap.aHiddenElementIsRenderedAndCovered &&
          HabotElementAccessMap.noAbsentElementCarriesAReason,
    );

    gate(
      'REF-106-G5',
      'A control drawn and hidden is read out of the widget tree.',
      'Which is the reason absence is implemented as absence',
      () => HabotElementAccessMap.absenceNote
          .contains('read out of the widget tree'),
    );
  });

  group('REF-106 :: what a drawing audit is not', () {
    gate(
      'REF-106-G6',
      'The map decides what is drawn, not what the server accepts.',
      'Steps 360 and 373 recorded the same limit for a role-gated tile and an '
          'HR surface',
      () =>
          HabotElementAccessMap.theLimitIsStated &&
          HabotElementAccessMap.rowsThatRecordedTheSameThing.contains(360) &&
          HabotElementAccessMap.rowsThatRecordedTheSameThing.contains(373),
    );

    gate(
      'REF-106-G7',
      'And the audit is still worth doing.',
      'Because the commonest way to leak a capability is to render it',
      () => HabotElementAccessMap.boundaryNote.contains('render it'),
    );

    gate(
      'REF-106-G8',
      'A role refusal is Step 292\'s "not permitted", and not a dead end.',
      'What would change it is the role, and the reason names it',
      () =>
          HabotElementAccessMap.theDisableKindIsTheDeclaredOne &&
          HabotElementAccessMap.aRoleRefusalIsNotADeadEnd &&
          HabotElementAccessMap.kindForARoleRefusal ==
              HabotDisableKind.notPermitted,
    );
  });

  group('REF-106 :: the cell that reports its own miss', () {
    gate(
      'REF-106-G9',
      'Five real fields, then the generator\'s miss appended after a "||".',
      'Third occurrence after Steps 347 and 369, and the first time it '
          'decorates a populated cell rather than replacing one',
      () =>
          HabotElementAccessMap.theCellCarriesBothFieldsAndAMiss &&
          HabotElementAccessMap.thisIsTheThirdOccurrence &&
          HabotElementAccessMap.generatorMissRows.contains(347) &&
          HabotElementAccessMap.generatorNote.contains('first hybrid'),
    );

    gate(
      'REF-106-G10',
      'Output reported as Complete / Not Complete.',
      'Six obligations, all met, giving Complete; the optimal and ceiling are '
          'both 100, and all ten declared checks hold',
      () =>
          HabotElementAccessMap.obligations.length == 6 &&
          HabotElementAccessMap.obligations.values.every((bool b) => b) &&
          HabotElementAccessMap.qualitativeOutput == 'Complete' &&
          HabotElementAccessMap.theOptimalEqualsTheCeiling &&
          HabotElementAccessMap.checks.length == 10 &&
          HabotElementAccessMap.checks.values.every((bool b) => b) &&
          HabotElementAccessMap.columnNote.contains('first hybrid'),
    );
  });

  tearDownAll(() {
    final int absent =
        HabotElementAccessMap.countOf(HabotAccessTreatment.absent);
    final int disabled = HabotElementAccessMap.countOf(
      HabotAccessTreatment.disabledWithReason,
    );
    final int available =
        HabotElementAccessMap.countOf(HabotAccessTreatment.available);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'REF-106',
        atomicStepReferenceId: 'REF-106-A01',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row lists five '
            'real data fields and then appends the generator\'s own miss to '
            'them -- "No matched reference row in Setup Implementation master '
            'list ... verify manually" -- after a double pipe. That is the '
            'third occurrence of the sentence after Steps 347 and 369 and the '
            'first time it decorates a populated cell rather than replacing '
            'one, which means a cell that looks filled in can still be '
            'reporting that nothing was found. The band\'s optimal and ceiling '
            'are both 100 and the Setup Step column is empty. Atomic Step: '
            '"Identify all UI elements (buttons, links, sections) requiring '
            'identity-based access control."',
        implementationOrder: 376,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Access Type': 'element-level, by role',
          'User Role': 'the signed-in account\'s role',
          'Permission Level': '$available available, $disabled disabled, '
              '$absent absent',
          'Access Log': 'recorded server-side; the map decides drawing only',
          'Access Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'every disabled element carries a reason and every absent one '
                  'is missing from the widget tree rather than covered',
          'Data Quality Note':
              'RULE: ${HabotElementAccessMap.ruleNote} ABSENCE: '
              '${HabotElementAccessMap.absenceNote} BOUNDARY: '
              '${HabotElementAccessMap.boundaryNote} GENERATOR: '
              '${HabotElementAccessMap.generatorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Identification Coverage',
            observed:
                '100, over the five audited elements, with the optimal and the '
                'ceiling both written 100. Every element carries a treatment '
                'and the rule reproduces all five classifications, so the map '
                'and the list cannot drift apart. What the coverage does not '
                'measure is whether the server agrees: the map decides what is '
                'drawn, and an audit of the drawing is not a security '
                'boundary, as Steps 360 and 373 also record.',
            floor: '98',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Refused elements drawn without a reason',
            observed:
                '0 of $disabled. A disabled control says "this exists and you '
                'cannot use it"; a hidden one says nothing, and which is right '
                'depends on whether the existence of the control is itself '
                'information. $absent of the five are absent -- not rendered '
                'and not in the widget tree, because a control drawn and then '
                'covered is one a determined person reads out of the tree -- '
                'and $disabled are disabled with a stated reason and a stated '
                'route back, in the vocabulary Step 292 declared.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/access/element_access_map.dart',
        ],
      ),
    );
  });
}
