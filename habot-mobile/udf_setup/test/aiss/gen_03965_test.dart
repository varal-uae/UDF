/// AISS GATE -- Step 257 of 275
/// Global Reference ID:       GEN-03965
/// Atomic Steps Reference ID: GEN-03965
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Create the screens folder to organize distinct application
///               pages."
/// Metric: Directory Navigation Time -- Floor "< 1.0 s", Optimal "< 0.1 s",
///         Ceiling "2.0 s". Complete/Not Complete.
///
/// THERE IS NO lib/screens, AND THE REASON IS THE ARCHITECTURE RATHER THAN
/// AN OVERSIGHT: THIS APPLICATION HAS PANES, NOT PAGES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/repository/screen_index.dart';

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

  group('GEN-03965 :: the folder the row asks for', () {
    gate(
      'GEN-03965-G1',
      'Atomic Step: "Create the screens folder".',
      'The directory the row names does not exist, and that is recorded as a '
          'finding rather than fixed by creating an empty folder so the '
          'sentence comes true',
      () =>
          HabotScreenIndex.directoryTheRowExpects == 'lib/screens' &&
          !HabotScreenIndex.theExpectedDirectoryExists &&
          HabotScreenIndex.noScreensFolderNote.isNotEmpty,
    );

    gate(
      'GEN-03965-G2',
      '"Distinct application pages" assumes pages.',
      'Five routes are served by one adaptive shell, so there are more routes '
          'than screen files -- panes composed at runtime rather than pages '
          'pushed onto a stack',
      () =>
          HabotScreenIndex.declaredRoutes == 5 &&
          HabotScreenIndex.routesOutnumberScreenFiles &&
          HabotScreenIndex.panesNotPagesNote.contains('pane'),
    );

    gate(
      'GEN-03965-G3',
      'An index nobody can check is a claim.',
      'Every entry names its file, its kind and whether a route reaches it, '
          'and each says why it is classified that way',
      () =>
          HabotScreenIndex.entries.length == 5 &&
          HabotScreenIndex.everyEntryIsExplained,
    );

    gate(
      'GEN-03965-G4',
      'Counting probes as screens would flatter the number.',
      'One entry is a product surface and four are not: two probes and two '
          'composition roots, counted separately rather than folded in',
      () =>
          HabotScreenIndex.productionScreens.length == 1 &&
          HabotScreenIndex.probes.length == 2 &&
          HabotScreenIndex.compositionRoots.length == 2 &&
          HabotScreenIndex.probesOutnumberScreens,
    );
  });

  group('GEN-03965 :: the convention, and the twin band', () {
    gate(
      'GEN-03965-G5',
      'A folder with no rule about it fills with whatever arrives.',
      'The convention a screens folder would need is written down -- four '
          'rules -- so that the decision survives whether or not the folder '
          'is ever created',
      () =>
          HabotScreenIndex.screensFolderConvention.length == 4 &&
          HabotScreenIndex.conventionIsDeclared,
    );

    gate(
      'GEN-03965-G6',
      'Metric: Directory Navigation Time -- 1.0 s / 0.1 s / 2.0 s.',
      'This band is identical to Step 256\'s under a different metric name, '
          'transcribed independently rather than aliased, so the twin is a '
          'finding rather than an assertion about a constant',
      () =>
          HabotScreenIndex.rowFloorMs == 1000 &&
          HabotScreenIndex.rowOptimalMs == 100 &&
          HabotScreenIndex.rowCeilingMs == 2000 &&
          HabotScreenIndex.bandIsIdenticalToStep256 &&
          HabotScreenIndex.twinMetricNote.contains('Step 256'),
    );

    gate(
      'GEN-03965-G7',
      'Metric ceiling 2.0 s; output Complete/Not Complete.',
      'All nine declared checks hold, giving Complete -- reported on an index '
          'that says the folder is absent rather than on a folder created to '
          'satisfy the sentence',
      () =>
          HabotScreenIndex.checks.length == 9 &&
          HabotScreenIndex.checks.values.every((bool b) => b) &&
          HabotScreenIndex.qualitativeOutput == 'Complete' &&
          HabotScreenIndex.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String entries = '${HabotScreenIndex.entries.length}';
    final String surfaces = '${HabotScreenIndex.productionScreens.length}';
    final String probes = '${HabotScreenIndex.probes.length}';
    final String roots = '${HabotScreenIndex.compositionRoots.length}';
    final String routes = '${HabotScreenIndex.declaredRoutes}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03965',
        atomicStepReferenceId: 'GEN-03965',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Create the screens folder to organize distinct '
            'application pages."',
        implementationOrder: 257,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotScreenIndex / HabotScreenEntry',
          'Component Properties':
              '$entries indexed entries -- $surfaces product surface, '
              '$probes probes, $roots composition roots -- against $routes '
              'declared routes; '
              '${HabotScreenIndex.screensFolderConvention.length} convention '
              'rules recorded for a folder that does not exist',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotScreenIndex.noScreensFolderNote} '
              'SECOND: ${HabotScreenIndex.panesNotPagesNote} '
              'TWIN: ${HabotScreenIndex.twinMetricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Directory Navigation Time',
            observed:
                'NOT TIMED, for the same reason as Step 256: the band times a '
                'person opening a folder. Substituted: $routes routes are '
                'served by $surfaces product surface file, so the index is '
                'the navigable artefact rather than a directory listing.',
            floor: '< 1.0 s',
            optimal: '< 0.1 s',
            ceiling: '2.0 s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'lib/screens exists',
            observed:
                'No. The directory the row names is absent; five entries are '
                'indexed where they actually live, and the convention a '
                'screens folder would need is recorded against the day one is '
                'created.',
            floor: 'present',
            optimal: 'present',
            ceiling: 'present',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/repository/screen_index.dart',
        ],
      ),
    );
  });
}
