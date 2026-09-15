/// AISS GATE -- Step 263 of 275
/// Global Reference ID:       GEN-00988
/// Atomic Steps Reference ID: GEN-00988
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Compress and convert image assets to modern formats for the
///               mobile bundle."
/// Metric: Asset Compression Ratio -- Floor ">= 60%", Optimal ">= 80%",
///         Ceiling ">= 90%". Pass / Fail.
///
/// THIS STEP REPORTS FAIL. THERE ARE NO BUNDLED IMAGE ASSETS TO COMPRESS,
/// AND REPORTING PASS OVER AN EMPTY POPULATION IS HOW A METRIC STOPS BEING
/// ABLE TO FAIL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/asset_budget.dart';

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

  group('GEN-00988 :: the population', () {
    gate(
      'GEN-00988-G1',
      'Atomic Step: "image assets ... for the mobile bundle".',
      'Every image file in the repository is inventoried by location, count '
          'and byte size; the one Flutter-asset location is the assets '
          'directory the row is about, and it holds no files at all',
      () =>
          HabotAssetBudget.locations.length == 5 &&
          HabotAssetBudget.totalFiles == 35 &&
          HabotAssetBudget.totalBytes == 229791 &&
          HabotAssetBudget.bundledAssetCount == 0 &&
          HabotAssetBudget.flutterAssets.length == 1 &&
          HabotAssetBudget.flutterAssets.single.files == 0,
    );

    gate(
      'GEN-00988-G2',
      'Reporting Pass on an empty population is how a metric stops failing.',
      'The step reports Fail, and the reason is stated: there is nothing in '
          'the population the ratio would be computed over',
      () =>
          HabotAssetBudget.thePopulationIsEmpty &&
          HabotAssetBudget.qualitativeOutput == 'Fail' &&
          HabotAssetBudget.emptyPopulationNote.isNotEmpty,
    );

    gate(
      'GEN-00988-G3',
      'The images that do exist belong to the platforms.',
      'All thirty-five files sit in the four platform locations -- launcher '
          'icons and favicons, which ship because the platform requires them '
          'and are not assets this application loads -- and one platform '
          'holds most of the bytes',
      () =>
          HabotAssetBudget.platformImages.length ==
              HabotAssetBudget.locations.length - 1 &&
          HabotAssetBudget.platformImages.length == 4 &&
          HabotAssetBudget.macOsShareOfBytes > 0.7 &&
          HabotAssetBudget.macOsShareOfBytes < 0.72 &&
          HabotAssetBudget.platformImagesNote.isNotEmpty,
    );

    gate(
      'GEN-00988-G4',
      'The row\'s density convention is not Flutter\'s.',
      'Twelve files carry an iOS @2x/@3x suffix and no directory uses the '
          'Flutter density convention, so a rule written for one would not '
          'find the files of the other',
      () =>
          HabotAssetBudget.filesWithIosDensitySuffix == 12 &&
          HabotAssetBudget.flutterDensityDirectories == 0 &&
          HabotAssetBudget.flutterDensityConvention.isNotEmpty &&
          HabotAssetBudget.theRowsConventionIsNotFluttersConvention &&
          HabotAssetBudget.densityNote.isNotEmpty,
    );
  });

  group('GEN-00988 :: the band nobody can read', () {
    gate(
      'GEN-00988-G5',
      'Metric: "Asset Compression Ratio >= 60% / 80% / 90%".',
      'The ratio has no declared direction: on one reading the ceiling is the '
          'best outcome and on the other the floor is, and both readings are '
          'computed on the same worked pair rather than argued about',
      () =>
          HabotAssetBudget.theTwoReadingsDisagree &&
          HabotAssetBudget.savingOf(before: 100000, after: 10000) == 90 &&
          HabotAssetBudget.outputShareOf(before: 100000, after: 10000) == 10 &&
          HabotAssetBudget.directionNote.contains('opposite outcomes'),
    );

    gate(
      'GEN-00988-G6',
      'A compression target with no quality floor rewards making it worse.',
      'Any photograph can be made ninety per cent smaller by degrading it, so '
          'the missing half of a usable target -- a perceptual quality floor '
          '-- is recorded rather than assumed',
      () => HabotAssetBudget.qualityFloorNote.contains('quality floor'),
    );

    gate(
      'GEN-00988-G7',
      '"Modern formats" is two different answers on two platforms.',
      'WebP is decodable everywhere this application runs and AVIF is not, so '
          'the conversion that would be safe is named and the one that would '
          'break a platform is refused',
      () =>
          HabotAssetBudget.webPIsSafeAndAvifIsNot &&
          HabotAssetBudget.decodableEverywhere.contains('webp') &&
          !HabotAssetBudget.decodableEverywhere.contains('avif') &&
          HabotAssetBudget.avifNote.isNotEmpty,
    );

    gate(
      'GEN-00988-G8',
      'The finding has to survive the next person adding an asset.',
      'All nine declared checks hold, and the count of convertible files is '
          'published so that the day somebody adds a real asset this row '
          'becomes measurable rather than staying Fail forever',
      () =>
          HabotAssetBudget.checks.length == 9 &&
          HabotAssetBudget.checks.values.every((bool b) => b) &&
          HabotAssetBudget.convertibleFiles >= 0 &&
          HabotAssetBudget.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String files = '${HabotAssetBudget.totalFiles}';
    final String bytes = '${HabotAssetBudget.totalBytes}';
    final String macos =
        (HabotAssetBudget.macOsShareOfBytes * 100).toStringAsFixed(1);
    final String largest = HabotAssetBudget.largestLocation.path;
    final String convertible = '${HabotAssetBudget.convertibleFiles}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00988',
        atomicStepReferenceId: 'GEN-00988',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'band is written with LaTeX escapes. Atomic Step: "Compress and '
            'convert image assets to modern formats for the mobile bundle."',
        implementationOrder: 263,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAssetBudget / HabotImageLocation',
          'Component Properties':
              '${HabotAssetBudget.locations.length} image locations holding '
              '$files files and $bytes bytes, of which '
              '${HabotAssetBudget.bundledAssetCount} are Flutter assets; '
              'largest location $largest at $macos% of all bytes; '
              '${HabotAssetBudget.filesWithIosDensitySuffix} files use the '
              'iOS density suffix and '
              '${HabotAssetBudget.flutterDensityDirectories} use Flutter\'s',
          'Completion Status': 'Derived from gate outcomes -- step reports '
              'Fail on an empty population',
          'Data Quality Note':
              'FINDING: ${HabotAssetBudget.emptyPopulationNote} '
              'DIRECTION: ${HabotAssetBudget.directionNote} '
              'QUALITY: ${HabotAssetBudget.qualityFloorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Asset Compression Ratio',
            observed:
                'NOT COMPUTABLE. ${HabotAssetBudget.bundledAssetCount} '
                'bundled assets, so the ratio has an empty population. The '
                'band also has no declared direction: on the same worked '
                'pair, one reading gives 90% and the other 10%, and they '
                'disagree about which end is good. Reported Fail rather than '
                'Pass, because a metric that cannot fail is not one.',
            floor: '>= 60%',
            optimal: '>= 80%',
            ceiling: '>= 90%',
          ),
          AissMeasurement(
            metricName: 'Files convertible to a modern format today',
            observed:
                '$convertible of $files. WebP decodes on every target this '
                'application builds for; AVIF does not, so a blanket '
                'conversion would break one.',
            floor: 'stated',
            optimal: 'stated',
            ceiling: 'stated',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/asset_budget.dart',
        ],
      ),
    );
  });
}
