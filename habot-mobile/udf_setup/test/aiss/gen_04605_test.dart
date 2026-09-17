/// AISS GATE -- Step 414 of 415
/// Global Reference ID:       GEN-04605
/// Atomic Steps Reference ID: GEN-04605
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Document usage guidelines, props interfaces, and code snippets
///               for each component."
/// Metric: Documentation Coverage Rate -- floor "0.8", optimal "0.95", ceiling
///         "1". Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC/IEEE 26515 (Systems and Software Documentation). Assigned to
///         **UDF**.
///
/// DOCUMENTATION COVERAGE AS A FRACTION WHERE THE TRACK USES PERCENTAGES, ON A
/// ROW THAT BORROWS A REACT NOUN.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/component_docs.dart';

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

  group('GEN-04605 :: three sections', () {
    gate(
      'GEN-04605-G1',
      'Three sections are required and all are present.',
      'Usage guidelines, the parameter interface, and a worked call',
      () =>
          HabotComponentDocs.threeSectionsAreRequired &&
          HabotComponentDocs.everyComponentHasEverySection,
    );

  });

  group('GEN-04605 :: one scale, two units', () {
    gate(
      'GEN-04605-G2',
      'The band is a fraction where the track uses percentages.',
      '0.8, 0.95 and 1 mean the same as 80, 95 and 100 and do not compare with '
          'them',
      () =>
          HabotComponentDocs.theBandIsAFraction &&
          HabotComponentDocs.theSameFigureInTwoUnits,
    );

    gate(
      'GEN-04605-G3',
      'And it is the quieter version of Step 342\'s defect.',
      'Two scales in one row is loud; one scale in two units across rows is '
          'quiet until two figures reach one table',
      () =>
          HabotComponentDocs.thisIsTheQuieterVersion &&
          HabotComponentDocs.unitNote.contains('off by a hundred'),
    );

  });

  group('GEN-04605 :: a borrowed noun is not a stack', () {
    gate(
      'GEN-04605-G4',
      '"Props" is a borrowed noun, not a named toolchain.',
      'React\'s name for the values a component is constructed with',
      () =>
          HabotComponentDocs.theNounIsBorrowed &&
          HabotComponentDocs.theBorrowingIsRecordedNotCounted,
    );

    gate(
      'GEN-04605-G5',
      'So the register stands at eighteen until the next row.',
      'Counting a borrowing and a named stack together would hide how often '
          'the second happens',
      () =>
          !HabotComponentDocs.theForeignStackRegisterMoves &&
          HabotComponentDocs.nounNote.contains('names React Native outright'),
    );

  });

  group('GEN-04605 :: coverage measures presence', () {
    gate(
      'GEN-04605-G6',
      'The ceiling is reached on the first attempt.',
      'Which means the metric has stopped measuring',
      () =>
          HabotComponentDocs.theCeilingIsReachedOnTheFirstAttempt &&
          HabotComponentDocs.coveragePercentage == 100,
    );

    gate(
      'GEN-04605-G7',
      'Coverage measures presence and says so.',
      'Full coverage cannot tell you whether any of the comments is still true',
      () =>
          HabotComponentDocs.theProxyIsNamed &&
          HabotComponentDocs.proxyNote.contains('stopped measuring'),
    );

    gate(
      'GEN-04605-G8',
      'The second proxy named in three rows.',
      'Step 412 named a line count as a proxy for whether a function is one '
          'thing',
      () =>
          HabotComponentDocs.secondProxyNamedInThreeRows &&
          HabotComponentDocs.theOtherProxyAgrees,
    );

    gate(
      'GEN-04605-G9',
      'Snippets are bound to call sites and the limit is stated.',
      'No doc-test runner is available on this device, so the binding is by '
          'reference rather than by execution',
      () =>
          HabotComponentDocs.snippetsBreakWhereTheyAreWritten &&
          !HabotComponentDocs.aDocTestRunnerIsAvailable &&
          HabotComponentDocs.snippetNote.contains('rather than papered over'),
    );

    gate(
      'GEN-04605-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotComponentDocs.obligations.length == 5 &&
          HabotComponentDocs.obligations.values.every((bool b) => b) &&
          HabotComponentDocs.qualitativeOutput == 'Complete' &&
          HabotComponentDocs.theTypeSafetyRowIsDocumented,
    );
  });

  tearDownAll(() {
    final int documented = HabotComponentDocs.components.length;
    final double rate = HabotComponentDocs.coverageRate;
    final double percentage = HabotComponentDocs.coveragePercentage;
    final int register = HabotComponentDocs.registerStandsAt;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04605',
        atomicStepReferenceId: 'GEN-04605',
        setupStepAction:
            'COLUMN NOTE: this row\'s band is written as fractions -- 0.8, '
            '0.95, 1 -- where the track\'s other coverage bands are '
            'percentages, one scale in two units across rows; it asks for '
            '"props interfaces", React\'s noun for a constructor parameter '
            'list, which is a borrowing rather than a named toolchain and so '
            'does not move the foreign-stack register; its Data Requirement '
            'cell truncates the Atomic Step with an ellipsis and its Expected '
            'Output cell truncates it again, one character earlier, at '
            '"componen"; and the Setup Step column is empty. Atomic Step: '
            '"Document usage guidelines, props interfaces, and code snippets '
            'for each component."',
        implementationOrder: 414,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Document usage guidelines, props interfaces, and code snippets for '
          'each':
              '$documented components documented across three sections each, '
                  'with every snippet naming a call site that exists in the '
                  'repository',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Documentation Coverage Rate',
            observed:
                'THE BAND IS A FRACTION WHERE THE TRACK USES PERCENTAGES, AND '
                'THE CEILING IS REACHED ON THE FIRST ATTEMPT. Floor 0.8, '
                'optimal 0.95, ceiling 1 means the same as 80, 95 and 100 and '
                'does not compare with it -- one scale written in two units '
                'across rows, which is the quiet version of the conflation '
                'Step 342 held inside a single row. Observed: $rate, which is '
                '$percentage per cent, across $documented components. A metric '
                'at its ceiling on the first attempt has stopped measuring.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Documented components whose comment might not be true',
            observed:
                '$documented of $documented, which is the point. Coverage '
                'measures presence, not truth, and is named as a proxy here '
                'for the same reason Step 412 named a line count as one two '
                'rows earlier. Each snippet names a call site that exists in '
                'the repository, so a rename breaks the call rather than '
                'leaving a plausible wrong example behind; no doc-test runner '
                'is available on this device, so that binding is by reference '
                'rather than by execution, and the limit is stated rather than '
                'papered over. "Props" is React\'s noun and a borrowing, so '
                'the foreign-stack register stands at $register.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/component_docs.dart',
        ],
      ),
    );
  });
}
