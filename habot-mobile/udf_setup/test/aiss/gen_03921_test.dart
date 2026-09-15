/// AISS GATE -- Step 258 of 275
/// Global Reference ID:       GEN-03921
/// Atomic Steps Reference ID: GEN-03921
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Open the src/navigation/AppRouter.tsx module."
/// Metric: Router Module Open Latency -- Floor "< 20 ms", Optimal "< 2 ms",
///         Ceiling "50 ms". Complete/Not Complete.
///
/// THE ROW NAMES A TYPESCRIPT FILE IN A DART APPLICATION. IT IS THE FIFTH
/// TIME THIS TRACK HAS BEEN HANDED A ROW WRITTEN FOR A DIFFERENT STACK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/repository/router_entry_point.dart';

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

  group('GEN-03921 :: the file that is not there', () {
    gate(
      'GEN-03921-G1',
      'Atomic Step: "Open the src/navigation/AppRouter.tsx module."',
      'The named file does not exist and no file is created to make the '
          'sentence true; the language the row assumes and the language this '
          'application uses are both recorded',
      () =>
          HabotRouterEntryPoint.fileTheRowNames == 'AppRouter.tsx' &&
          !HabotRouterEntryPoint.theNamedFileExists &&
          HabotRouterEntryPoint.languageTheRowAssumes.contains('TypeScript') &&
          HabotRouterEntryPoint.languageThisApplicationUses == 'Dart' &&
          HabotRouterEntryPoint.noDeclarationIsNamedAppRouter,
    );

    gate(
      'GEN-03921-G2',
      'A step whose action is "open a file" has an answer, not a build.',
      'The answer given is where routing actually lives: four Dart '
          'declarations, each existing, each saying what it declares',
      () =>
          HabotRouterEntryPoint.declarations.length == 4 &&
          HabotRouterEntryPoint.filesInvolved == 4 &&
          HabotRouterEntryPoint.everyDeclarationIsDartAndExists &&
          HabotRouterEntryPoint.whereRoutingLivesNote.isNotEmpty,
    );

    gate(
      'GEN-03921-G3',
      '"Open the module" presumes there is one to open first.',
      'Exactly one of the four is named as the one to read first, so the '
          'question the row asks gets a single answer rather than a list',
      () =>
          HabotRouterEntryPoint.exactlyOneIsNamedFirst &&
          HabotRouterEntryPoint.openFirst.isTheOneToOpenFirst &&
          HabotRouterEntryPoint.openFirst.file.endsWith('.dart'),
    );

    gate(
      'GEN-03921-G4',
      'Four earlier rows assumed a stack this application does not use.',
      'The earlier assumptions are listed and this row is recorded as the '
          'fifth, so the pattern is visible in the repository rather than '
          'rediscovered every batch',
      () =>
          HabotRouterEntryPoint.earlierStackAssumptions.length == 4 &&
          HabotRouterEntryPoint.theFifthIsThisOne &&
          HabotRouterEntryPoint.stackAssumptionNote.contains('fifth'),
    );
  });

  group('GEN-03921 :: the band', () {
    gate(
      'GEN-03921-G5',
      'Metric: Router Module Open Latency -- 20 ms / 2 ms / 50 ms.',
      'The band is kept verbatim and is recorded as tighter than the two '
          'directory rows immediately before it, which measure the same kind '
          'of act in whole seconds',
      () =>
          HabotRouterEntryPoint.rowFloorMs == 20 &&
          HabotRouterEntryPoint.rowOptimalMs == 2 &&
          HabotRouterEntryPoint.rowCeilingMs == 50 &&
          HabotRouterEntryPoint.bandIsTighterThanTheDirectoryRows &&
          HabotRouterEntryPoint.bandNote.isNotEmpty,
    );

    gate(
      'GEN-03921-G6',
      'The cited standard belongs to the assumed stack too.',
      'The standard the row cites is recorded alongside the file name, '
          'because both come from the same assumption and naming only the '
          'file would understate it',
      () => HabotRouterEntryPoint.standardTheRowCites.isNotEmpty,
    );

    gate(
      'GEN-03921-G7',
      'Output: Complete/Not Complete.',
      'All eight declared checks hold, giving Complete -- on an answer that '
          'says the named module is absent and names the four that are not',
      () =>
          HabotRouterEntryPoint.checks.length == 8 &&
          HabotRouterEntryPoint.checks.values.every((bool b) => b) &&
          HabotRouterEntryPoint.qualitativeOutput == 'Complete' &&
          HabotRouterEntryPoint.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String first = HabotRouterEntryPoint.openFirst.file;
    final String count = '${HabotRouterEntryPoint.declarations.length}';
    final String priors =
        '${HabotRouterEntryPoint.earlierStackAssumptions.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03921',
        atomicStepReferenceId: 'GEN-03921',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Open the src/navigation/AppRouter.tsx module."',
        implementationOrder: 258,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRouterEntryPoint / HabotRoutingDeclaration',
          'Component Properties':
              '$count Dart routing declarations, one of them named as the '
              'file to open first ($first); the row\'s own '
              '${HabotRouterEntryPoint.fileTheRowNames} does not exist; '
              '$priors earlier rows recorded as having assumed the same '
              'stack',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotRouterEntryPoint.stackAssumptionNote} '
              'ANSWER: ${HabotRouterEntryPoint.whereRoutingLivesNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Router Module Open Latency',
            observed:
                'NOT TIMED. The module the band times does not exist, and '
                'timing the file that replaces it would be timing an editor. '
                'Substituted: the number of files somebody has to open to '
                'understand routing here, which is $count, with one named as '
                'the place to start.',
            floor: '< 20 ms',
            optimal: '< 2 ms',
            ceiling: '50 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Rows written for another stack',
            observed:
                '$priors before this one; this is the fifth. Recorded so the '
                'pattern is visible in the repository rather than '
                'rediscovered each batch.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/repository/router_entry_point.dart',
        ],
      ),
    );
  });
}
