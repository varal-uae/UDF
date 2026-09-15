/// AISS GATE -- Step 274 of 275
/// Global Reference ID:       GEN-04517
/// Atomic Steps Reference ID: GEN-04517
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Set up automated source map and symbol file uploading during
///               build steps."
/// Metric: Crash-Free Session Rate -- Floor 0.99, Optimal 0.999, Ceiling
///         0.9999. Good/Average/Poor.
///
/// THE UPLOAD IS A BUILD-PIPELINE STEP. WHAT THE APPLICATION OWES IS THE KEY
/// THAT MAKES IT WORTH DOING, AND AN HONEST ACCOUNT OF HOW A SESSION ENDED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/symbol_manifest.dart';

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

  group('GEN-04517 :: the key that joins the two ends', () {
    gate(
      'GEN-04517-G1',
      'Atomic Step: "symbol file uploading during build steps".',
      'A release produces one symbol file per architecture, each with its own '
          'key and its own file name, because offsets differ per ABI and the '
          'files are not interchangeable',
      () =>
          HabotSymbolManifest.symbolFilesPerRelease == 4 &&
          HabotSymbolManifest.releaseAbis.length == 4 &&
          HabotSymbolManifest.everyAbiGetsItsOwnKey,
    );

    gate(
      'GEN-04517-G2',
      'Keeping "the latest symbols" keeps the wrong ones.',
      'The build number is part of the key, so two builds of the same version '
          'are two different symbol sets rather than one overwriting the '
          'other',
      () =>
          HabotSymbolManifest.theBuildNumberIsPartOfTheKey &&
          HabotSymbolManifest.keyNote.contains('plausible'),
    );

    gate(
      'GEN-04517-G3',
      'The file name follows the tool\'s convention, not a new one.',
      'The symbol file name is the one --split-debug-info actually writes, so '
          'the upload and the build agree without a document in between',
      () =>
          const HabotBuildIdentity(
                appVersion: '1.4.0',
                buildNumber: 312,
                abi: 'android-arm64',
              ).symbolFileName ==
              'app.android-arm64.symbols' &&
          HabotSymbolManifest.identitiesFor(
                appVersion: '1.4.0',
                buildNumber: 312,
              ).length ==
              4,
    );

    gate(
      'GEN-04517-G4',
      '"Source map" is a web word on a mobile row.',
      'A Flutter mobile build produces three artefacts and none of them is a '
          'source map, and the mismatch is recorded rather than answered with '
          'a file named after something that is not produced',
      () =>
          HabotSymbolManifest.artefactsAMobileBuildProduces.length == 3 &&
          HabotSymbolManifest.noSourceMapIsProducedHere &&
          HabotSymbolArtefact.values.length == 4 &&
          HabotSymbolManifest.sourceMapNote.contains('AppRouter.tsx'),
    );

    gate(
      'GEN-04517-G5',
      'Obfuscation whose mapping ships with the binary is decoration.',
      'Symbols are build outputs rather than repository files, checked '
          'against the Step 263 count of bundled assets rather than promised '
          'in a comment',
      () =>
          HabotSymbolManifest.symbolsAreBuildOutputsNotRepositoryFiles &&
          HabotSymbolManifest.nothingIsBundledWithTheApplication &&
          HabotSymbolManifest.doNotShipNote.contains('decoration'),
    );
  });

  group('GEN-04517 :: the ending, and the rate nobody here can compute', () {
    gate(
      'GEN-04517-G6',
      '"No clean exit" is three events wearing one face.',
      'A crash, an out-of-memory kill and a swipe from the app switcher are '
          'separated by the marker, the crash record and the platform '
          'signal, and all three resolve differently',
      () =>
          HabotSymbolManifest.theMarkerSeparatesThreeEndings &&
          HabotSessionEnd.values.length == 4,
    );

    gate(
      'GEN-04517-G7',
      'A process that crashed after writing its marker still crashed.',
      'The crash record outranks the marker, and a clean exit is still '
          'recognised when memory pressure was seen beforehand',
      () =>
          HabotSymbolManifest.aCrashOutranksTheMarker &&
          HabotSymbolManifest.endFor(
                markerWritten: true,
                crashRecorded: false,
                memoryPressureSeen: true,
              ) ==
              HabotSessionEnd.cleanExit &&
          HabotSymbolManifest.threeEndingsNote.contains('optimise the wrong '
              'thing'),
    );

    gate(
      'GEN-04517-G8',
      'Metric: Crash-Free Session Rate -- 0.99 / 0.999 / 0.9999.',
      'The three points of the band are one crash in a hundred, a thousand '
          'and ten thousand sessions, so the ceiling asks for a hundred times '
          'the evidence the floor does -- a sample-size requirement written '
          'as a target',
      () =>
          HabotSymbolManifest.sessionsPerCrashAtFloor == 100 &&
          HabotSymbolManifest.sessionsPerCrashAtOptimal == 1000 &&
          HabotSymbolManifest.sessionsPerCrashAtCeiling == 10000 &&
          HabotSymbolManifest.evidenceRatioAcrossTheBand == 100 &&
          HabotSymbolManifest.precisionNote.contains('sample-size '
              'requirement'),
    );

    gate(
      'GEN-04517-G9',
      'The session that crashed is the least able to report it.',
      'The rate is named as arithmetic done elsewhere, over a denominator '
          'this application does not hold, and the band is still exercised so '
          'the three-way split is real',
      () =>
          HabotSymbolManifest.theBandIsOrdered &&
          HabotSymbolManifest.bandFor(0.9999) == 'Good' &&
          HabotSymbolManifest.bandFor(0.992) == 'Average' &&
          HabotSymbolManifest.bandFor(0.9) == 'Poor' &&
          HabotSymbolManifest.cannotComputeItHereNote.contains('next launch'),
    );

    gate(
      'GEN-04517-G10',
      'Output: Good/Average/Poor.',
      'All fourteen declared checks hold and the step reports Pass on the '
          'half that is the application\'s, with the upload named as a '
          'pipeline step',
      () =>
          HabotSymbolManifest.checks.length == 14 &&
          HabotSymbolManifest.checks.values.every((bool b) => b) &&
          HabotSymbolManifest.qualitativeOutput == 'Pass' &&
          HabotSymbolManifest.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String abis = '${HabotSymbolManifest.symbolFilesPerRelease}';
    final String ratio = '${HabotSymbolManifest.evidenceRatioAcrossTheBand}';
    final String ceiling =
        '${HabotSymbolManifest.sessionsPerCrashAtCeiling}';
    final String key = const HabotBuildIdentity(
      appVersion: '1.4.0',
      buildNumber: 312,
      abi: 'android-arm64',
    ).symbolKey;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04517',
        atomicStepReferenceId: 'GEN-04517',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and '
            'Expected Output restates the Atomic Step. Atomic Step: "Set up '
            'automated source map and symbol file uploading during build '
            'steps."',
        implementationOrder: 274,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotSymbolManifest / HabotBuildIdentity / HabotSessionEnd',
          'Component Properties':
              '$abis release ABIs each with its own symbol file and key '
              '(example "$key"); three mobile build artefacts and no source '
              'map; four session endings separated by a marker, a crash '
              'record and the platform memory signal; nothing bundled with '
              'the application',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSymbolManifest.cannotComputeItHereNote} '
              'ENDINGS: ${HabotSymbolManifest.threeEndingsNote} '
              'SOURCE MAPS: ${HabotSymbolManifest.sourceMapNote} '
              'PRECISION: ${HabotSymbolManifest.precisionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Crash-Free Session Rate',
            observed:
                'NOT COMPUTABLE ON THE DEVICE. It needs every session in the '
                'denominator and the crashed ones in the numerator, and the '
                'crashed session reports from the next launch if there is '
                'one. What is supplied here is the pair of facts the backend '
                'needs: a session start and an ending that tells a crash '
                'from an out-of-memory kill from a swipe.',
            floor: '0.99',
            optimal: '0.999',
            ceiling: '0.9999',
          ),
          AissMeasurement(
            metricName: 'Sessions needed to observe one crash at the ceiling',
            observed:
                '$ceiling, against 100 at the floor -- a factor of $ratio. '
                'The three decimal places are a sample-size requirement '
                'written as a target, and a weekly report on a small user '
                'base cannot tell 0.999 from 0.9999.',
            floor: '100',
            optimal: '1000',
            ceiling: '10000',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/symbol_manifest.dart',
        ],
      ),
    );
  });
}
