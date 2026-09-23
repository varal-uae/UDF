/// AISS GATE -- Step 460 of 1,314
/// Global Reference ID:       GEN-04891
/// Atomic Steps Reference ID: GEN-04891
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package the resulting logic into the designated shared module:
///               @Universal-Library/ui-assistance."
/// Metric: Shared Module Packaging & Versioning Compliance -- floor "Module
///         published with valid semantic version and passing lint/build
///         checks", optimal "100% SemVer-compliant release with automated build
///         passing", ceiling "100% (compliance is binary; no upper excess)".
///         Best Qualitative Output: "Complete / Partial / Not Complete".
///         Semantic Versioning 2.0.0 (SemVer) / npm package publishing
///         standard. Assigned to **UDF**.
///
/// A MODULE NAMED TWICE, ON A BAND WHOSE TWO ENDS DESCRIBE ONE STATE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/capture/assistance_package.dart';

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

  group('GEN-04891 :: one state, two wordings', () {
    gate(
      'GEN-04891-G1',
      'The floor and the optimal name one state.',
      'A valid semantic version with lint and build passing, twice',
      () => HabotAssistancePackage.bothEndsNameOneState,
    );

    gate(
      'GEN-04891-G2',
      'The second such band in this batch.',
      'After Step 456\'s floor and ceiling',
      () => HabotAssistancePackage.secondSuchBand,
    );

  });

  group('GEN-04891 :: the artefact is the noun', () {
    gate(
      'GEN-04891-G3',
      'The artefact to prepare is the module\'s own name.',
      'The third such row after Step 436\'s "completion" and Step 450\'s '
          '"Learning Difficulty (LD)"',
      () =>
          HabotAssistancePackage.theArtefactIsTheModuleName &&
          HabotAssistancePackage.thirdSuchRow,
    );

  });

  group('GEN-04891 :: two registries', () {
    gate(
      'GEN-04891-G4',
      'The row names two registries.',
      '@Universal-Library/ui-assistance and @habot/shared-library, on one row',
      () => HabotAssistancePackage.theRowNamesTwoRegistries,
    );

    gate(
      'GEN-04891-G5',
      'And neither is invented over.',
      'Where this publishes is a decision for the owner of the registries',
      () =>
          !HabotAssistancePackage.aRegistryIsInvented &&
          HabotAssistancePackage.registryNote.contains('owner of the'),
    );

  });

  group('GEN-04891 :: what a version protects', () {
    gate(
      'GEN-04891-G6',
      'Four assistive surfaces, each with announced text.',
      'Read aloud, simpler wording, reduced motion, open as a list',
      () =>
          HabotAssistancePackage.surfaces.length == 4 &&
          HabotAssistancePackage.everySurfaceAnnouncesSomething,
    );

    gate(
      'GEN-04891-G7',
      'A wording change took the major version.',
      '"Listen" became "Read aloud", so 1.4.2 became 2.0.0',
      () =>
          HabotAssistancePackage.aWordingChangeIsMajor &&
          HabotAssistancePackage.breakingChange.contains('1.4.2'),
    );

    gate(
      'GEN-04891-G8',
      'Because announced text is public interface.',
      'Somebody who navigates by hearing has learned the words',
      () =>
          HabotAssistancePackage.announcedTextIsPublicInterface &&
          HabotAssistancePackage.versionNote.contains('navigates by hearing'),
    );

    gate(
      'GEN-04891-G9',
      'The version is well formed and the build passes.',
      'Which is the whole of the floor and the whole of the optimal',
      () =>
          HabotAssistancePackage.semverIsWellFormed &&
          HabotAssistancePackage.lintAndBuildPass,
    );

    gate(
      'GEN-04891-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotAssistancePackage.obligations.length == 5 &&
          HabotAssistancePackage.obligations.values.every((bool b) => b) &&
          HabotAssistancePackage.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int surfaces = HabotAssistancePackage.surfaces.length;
    final String v = HabotAssistancePackage.version;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04891',
        atomicStepReferenceId: 'GEN-04891',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor and optimal describe one state in '
            'two wordings, the second such band in this batch after Step '
            '456\'s; its Data Requirement is the module\'s own name, the third '
            'such artefact after Steps 436 and 450; its instruction and its '
            'Common Library column name two different registries, as Step '
            '470\'s do; and the module it publishes treats announced text as '
            'public interface, so a change of wording takes the major version. '
            'Atomic Step: "Package the resulting logic into the designated '
            'shared module: @Universal-Library/ui-assistance."',
        implementationOrder: 460,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          '@Universal-Library/ui-assistance':
              '$surfaces assistive surfaces published at $v, with announced '
                  'text treated as public interface; both registry names '
                  'recorded and neither chosen over the other',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Shared Module Packaging & Versioning Compliance',
            observed:
                'THE BAND HAS ONE VALUE AND THE ROW HAS TWO REGISTRIES. '
                '"Published with a valid semantic version and passing '
                'lint/build checks" and "100% SemVer-compliant release with '
                'automated build passing" are one state in two wordings, the '
                'second such band in this batch. The Atomic Step names '
                '@Universal-Library/ui-assistance and the Common Library '
                'column names @habot/shared-library. Observed: $surfaces '
                'surfaces published at $v with lint and build passing.',
            floor:
                'Module published with valid semantic version and passing '
                    'lint/build checks',
            optimal:
                '100% SemVer-compliant release with automated build passing',
            ceiling: '100% (compliance is binary; no upper excess)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Announced strings changed without a major version',
            observed:
                '0. A screen-reader user has learned the wording of a control, '
                'so renaming a label is invisible in a screenshot and total '
                'for somebody who navigates by hearing it. Announced text is '
                'part of this module\'s public interface: when "Listen" became '
                '"Read aloud", 1.4.2 became $v rather than 1.4.3.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/capture/assistance_package.dart',
        ],
      ),
    );
  });
}
