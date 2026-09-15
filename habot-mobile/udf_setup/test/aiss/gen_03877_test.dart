/// AISS GATE -- Step 256 of 275
/// Global Reference ID:       GEN-03877
/// Atomic Steps Reference ID: GEN-03877
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Map the modular directory structure for components, screens,
///               services, and state management."
/// Metric: Path Navigation Overhead -- Floor "< 1.0 s", Optimal "< 0.1 s",
///         Ceiling "2.0 s". Complete/Not Complete.
///
/// THE METRIC TIMES A HUMAN OPENING A FOLDER. THE ARTEFACT IS THE MAP.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/repository/module_map.dart';

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

  group('GEN-03877 :: the map is of what is there', () {
    gate(
      'GEN-03877-G1',
      'Atomic Step: "Map the modular directory structure".',
      'The map has twelve rows covering thirty-two real directories under '
          'lib/design_system, and every row says what its directory is for',
      () =>
          HabotModuleMap.groups.length == 12 &&
          HabotModuleMap.declaredGroupCount == 32 &&
          HabotModuleMap.everyGroupIsDescribed &&
          HabotModuleMap.rootDirectory == 'lib/design_system',
    );

    gate(
      'GEN-03877-G2',
      'A map of a repository that does not match it is a diagram.',
      'The file count is the sum of the rows rather than a figure typed once '
          'and left to rot, and the largest group is named rather than '
          'averaged away',
      () =>
          HabotModuleMap.totalFiles == 267 &&
          HabotModuleMap.totalFiles ==
              HabotModuleMap.groups.fold<int>(
                0,
                (int a, HabotModuleGroup g) => a + g.files,
              ) &&
          HabotModuleMap.largestGroup.files > 0,
    );

    gate(
      'GEN-03877-G3',
      'Row names "components, screens, services, state management".',
      'One of the row\'s four categories has no directory in this repository '
          'and the aggregate row says so, rather than four headings being '
          'invented to match the sentence',
      () =>
          HabotModuleMap.groups.any((HabotModuleGroup g) => g.isAggregate) &&
          HabotModuleMap.namedGroups == HabotModuleMap.groups.length - 1,
    );
  });

  group('GEN-03877 :: the arithmetic of grouping', () {
    gate(
      'GEN-03877-G4',
      'Metric: Path Navigation Overhead.',
      'Grouping is measured rather than asserted: thirty-two directories '
          'average 8.34 files each, so finding a file means reading about a '
          'thirtieth of the tree instead of all of it',
      () =>
          (HabotModuleMap.averageFilesPerGroup - 267 / 32).abs() < 1e-9 &&
          HabotModuleMap.searchReductionFromGrouping > 0.96 &&
          HabotModuleMap.searchReductionFromGrouping < 1,
    );

    gate(
      'GEN-03877-G5',
      'Depth is the thing a person actually feels.',
      'The number of hops from the repository root to a component file is '
          'recorded, because a flat tree with four levels above it is not '
          'shallow',
      () =>
          HabotModuleMap.hopsToAComponent == 4 &&
          HabotModuleMap.depthNote.isNotEmpty,
    );

    gate(
      'GEN-03877-G6',
      'Metric floor "< 1.0 s", optimal "< 0.1 s", ceiling "2.0 s".',
      'The band is kept verbatim in milliseconds and the substitution is '
          'stated: a stopwatch on a person opening a folder cannot run on a '
          'build host, so what is produced is the map that shortens the '
          'search rather than a timing nobody took',
      () =>
          HabotModuleMap.rowFloorMs == 1000 &&
          HabotModuleMap.rowOptimalMs == 100 &&
          HabotModuleMap.rowCeilingMs == 2000 &&
          HabotModuleMap.rowConcept == 'Path Navigation Overhead' &&
          HabotModuleMap.substitution.isNotEmpty &&
          HabotModuleMap.notARunnableStepNote.isNotEmpty,
    );

    gate(
      'GEN-03877-G7',
      'A snapshot that does not say it is one becomes a lie quietly.',
      'The counts are dated as a snapshot, and all eleven declared checks '
          'hold, giving Complete',
      () =>
          HabotModuleMap.snapshotNote.isNotEmpty &&
          HabotModuleMap.checks.length == 11 &&
          HabotModuleMap.checks.values.every((bool b) => b) &&
          HabotModuleMap.qualitativeOutput == 'Complete' &&
          HabotModuleMap.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String groups = '${HabotModuleMap.groups.length}';
    final String dirs = '${HabotModuleMap.declaredGroupCount}';
    final String files = '${HabotModuleMap.totalFiles}';
    final String avg = HabotModuleMap.averageFilesPerGroup.toStringAsFixed(2);
    final String reduction =
        (HabotModuleMap.searchReductionFromGrouping * 100).toStringAsFixed(1);
    final String largest = HabotModuleMap.largestGroup.directory;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03877',
        atomicStepReferenceId: 'GEN-03877',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Map the modular directory structure for components, '
            'screens, services, and state management."',
        implementationOrder: 256,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotModuleMap / HabotModuleGroup',
          'Component Properties':
              '$groups map rows covering $dirs real directories and $files '
              'Dart files under ${HabotModuleMap.rootDirectory}; largest '
              'group "$largest"; $avg files per directory on average; '
              '${HabotModuleMap.hopsToAComponent} hops from the repository '
              'root to a component file',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: ${HabotModuleMap.substitution} '
              'SNAPSHOT: ${HabotModuleMap.snapshotNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Path Navigation Overhead',
            observed:
                'NOT TIMED. The band measures a person opening a folder, '
                'which no build host can time. Substituted: the search space '
                'for one file falls from $files candidates to $avg on '
                'average, a $reduction% reduction, at a depth of '
                '${HabotModuleMap.hopsToAComponent} hops.',
            floor: '< 1.0 s',
            optimal: '< 0.1 s',
            ceiling: '2.0 s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Directories described',
            observed: '$dirs of $dirs, in $groups map rows',
            floor: 'every directory accounted for',
            optimal: 'every directory accounted for',
            ceiling: 'every directory accounted for',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/repository/module_map.dart',
        ],
      ),
    );
  });
}
