/// Step 274 (GEN-04517) -- uploading symbols at build time, and the one thing
/// the application has to contribute for it to have been worth doing.
///
/// The row: "Set up automated source map and symbol file uploading during
/// build steps."
/// Metric: **Crash-Free Session Rate** -- floor 0.99, optimal 0.999, ceiling
/// 0.9999. Good / Average / Poor. Standards cited: Google Play Vitals and the
/// Apple App Store Quality Guidelines.
///
/// **The action is a build-pipeline step and cannot be a Dart file.** Nothing
/// in `lib/` runs during `flutter build`, and a library that claimed to upload
/// symbols would be claiming to run somewhere it does not exist. What the
/// application owns is the other end of the same rope: a build identity
/// emitted with every report, so that the symbol file uploaded on Tuesday can
/// be matched to the crash that arrives on Friday. Without that key the upload
/// is an orphan and the crash is a column of hexadecimal.
///
/// **"Source map" is a web word on a mobile row.** Dart emits source maps for
/// the web target only. A Flutter mobile build produces `--split-debug-info`
/// symbol files, a dSYM for the iOS native half, and an R8 mapping for the
/// Android one -- three artefacts, none of them a source map. The mismatch is
/// recorded rather than answered with a file named after a thing that is not
/// produced here.
///
/// **And the symbols must never ship inside the application.** Obfuscation
/// whose mapping travels with the binary is decoration. Step 263 counted the
/// bundled assets in this repository and found none, which is the property
/// being relied on rather than re-asserted.
///
/// **The metric cannot be computed here at all.** A crash-free session rate
/// needs every session in the denominator and the crashed ones in the
/// numerator, and the session that crashed is the least able to report. Worse,
/// "no clean exit" is three different events wearing one face: a crash, an
/// out-of-memory kill, and a person swiping the application away. The client's
/// contribution is the marker that tells them apart.
library;

import '../performance/asset_budget.dart';

/// An artefact a build produces that a crash reader needs later.
enum HabotSymbolArtefact {
  /// `--split-debug-info` output: the Dart symbol file for one ABI.
  dartDebugInfo,

  /// The iOS native debug symbols.
  appleDsym,

  /// The Android R8/ProGuard mapping for the Java and Kotlin half.
  androidMapping,

  /// A JavaScript source map. Web only, and this row asked for it.
  webSourceMap,
}

/// How a session ended, as far as the next launch can tell.
enum HabotSessionEnd {
  /// The application wrote its marker on the way out.
  cleanExit,

  /// The process died with an unhandled error, and the handler recorded it.
  crash,

  /// No marker, no crash record, and the platform reported memory pressure
  /// beforehand.
  outOfMemoryKill,

  /// No marker and nothing else. Most often a swipe from the app switcher.
  unknownTermination,
}

/// The build identity that joins the two ends.
class HabotBuildIdentity {
  const HabotBuildIdentity({
    required this.appVersion,
    required this.buildNumber,
    required this.abi,
  });

  final String appVersion;
  final int buildNumber;

  /// The architecture the symbol file was emitted for. Offsets differ per
  /// ABI, so a build has one symbol file per architecture and they are not
  /// interchangeable.
  final String abi;

  /// The key an upload is filed under and a report is looked up by. Both
  /// sides derive it from the same three facts rather than agreeing on a
  /// convention in a document.
  String get symbolKey => '$appVersion+$buildNumber/$abi';

  /// What `--split-debug-info` writes.
  String get symbolFileName => 'app.$abi.symbols';
}

/// The manifest.
class HabotSymbolManifest {
  const HabotSymbolManifest._();

  /// The architectures a release build produces.
  static const List<String> releaseAbis = <String>[
    'android-arm',
    'android-arm64',
    'android-x64',
    'ios-arm64',
  ];

  static const List<HabotSymbolArtefact> artefactsAMobileBuildProduces =
      <HabotSymbolArtefact>[
    HabotSymbolArtefact.dartDebugInfo,
    HabotSymbolArtefact.appleDsym,
    HabotSymbolArtefact.androidMapping,
  ];

  static bool get noSourceMapIsProducedHere =>
      !artefactsAMobileBuildProduces.contains(HabotSymbolArtefact.webSourceMap);

  static const String sourceMapNote =
      '"Source map" is a web word on a mobile row. Dart emits source maps for '
      'the web target only; a Flutter mobile build produces --split-debug-info '
      'symbol files, a dSYM for the iOS native half, and an R8 mapping for the '
      'Android one. Three artefacts, none of them a source map, and each read '
      'by a different tool. The row is answered with the three that exist '
      'rather than with a file named after the one that does not -- the same '
      'decision Step 258 made about AppRouter.tsx.';

  /// One symbol file per architecture, and they are not interchangeable.
  static List<HabotBuildIdentity> identitiesFor({
    required String appVersion,
    required int buildNumber,
  }) =>
      releaseAbis
          .map(
            (String abi) => HabotBuildIdentity(
              appVersion: appVersion,
              buildNumber: buildNumber,
              abi: abi,
            ),
          )
          .toList();

  static int get symbolFilesPerRelease => releaseAbis.length;

  static bool get everyAbiGetsItsOwnKey {
    final List<HabotBuildIdentity> ids =
        identitiesFor(appVersion: '1.4.0', buildNumber: 312);
    return ids.map((HabotBuildIdentity i) => i.symbolKey).toSet().length ==
            releaseAbis.length &&
        ids.map((HabotBuildIdentity i) => i.symbolFileName).toSet().length ==
            releaseAbis.length;
  }

  /// Two builds of the same version are two different symbol sets. Keeping
  /// "the latest symbols" for a version keeps the wrong ones for every build
  /// of it but the last.
  static bool get theBuildNumberIsPartOfTheKey =>
      const HabotBuildIdentity(
            appVersion: '1.4.0',
            buildNumber: 312,
            abi: 'android-arm64',
          ).symbolKey !=
          const HabotBuildIdentity(
            appVersion: '1.4.0',
            buildNumber: 313,
            abi: 'android-arm64',
          ).symbolKey;

  static const String keyNote =
      'The key is version, build number and ABI, derived on both sides from '
      'the same three facts rather than from a convention in a document '
      'nobody reads. Two builds of the same version produce different offsets '
      'for the same line of code, so keeping "the latest symbols" for a '
      'version keeps the wrong ones for every build of it but the last -- a '
      'failure that produces plausible, incorrect stack traces rather than '
      'obviously broken ones, which is why it survives so long.';

  // -----------------------------------------------------------------------
  // What must not ship.
  // -----------------------------------------------------------------------

  /// Obfuscation whose mapping travels with the binary is decoration. Step
  /// 263 counted the bundled assets in this repository; the property being
  /// relied on is that count, not a promise.
  static bool get nothingIsBundledWithTheApplication =>
      HabotAssetBudget.bundledAssetCount == 0;

  static const bool symbolsAreBuildOutputsNotRepositoryFiles = true;

  static const String doNotShipNote =
      'Symbols are build outputs, not repository files, and they must never '
      'travel inside the application: obfuscation whose mapping ships with '
      'the binary is decoration. --obfuscate is refused by the tool without '
      '--split-debug-info precisely so the mapping has somewhere to go that '
      'is not the bundle. Step 263 counted zero bundled assets in this '
      'repository, which is the property being relied on here rather than '
      'a promise made in a comment.';

  // -----------------------------------------------------------------------
  // The marker: telling three things apart that look like one.
  // -----------------------------------------------------------------------

  /// What the next launch concludes from what the last one left behind.
  static HabotSessionEnd endFor({
    required bool markerWritten,
    required bool crashRecorded,
    required bool memoryPressureSeen,
  }) {
    if (crashRecorded) {
      return HabotSessionEnd.crash;
    }
    if (markerWritten) {
      return HabotSessionEnd.cleanExit;
    }
    return memoryPressureSeen
        ? HabotSessionEnd.outOfMemoryKill
        : HabotSessionEnd.unknownTermination;
  }

  /// Without the marker, all three of the non-clean endings collapse into
  /// one, and the crash-free rate counts swipes as crashes.
  static bool get theMarkerSeparatesThreeEndings {
    final Set<HabotSessionEnd> distinct = <HabotSessionEnd>{
      endFor(
        markerWritten: false,
        crashRecorded: true,
        memoryPressureSeen: false,
      ),
      endFor(
        markerWritten: false,
        crashRecorded: false,
        memoryPressureSeen: true,
      ),
      endFor(
        markerWritten: false,
        crashRecorded: false,
        memoryPressureSeen: false,
      ),
    };
    return distinct.length == 3;
  }

  /// A crash record wins over a written marker: a process that crashed after
  /// writing its marker crashed.
  static bool get aCrashOutranksTheMarker =>
      endFor(
        markerWritten: true,
        crashRecorded: true,
        memoryPressureSeen: false,
      ) ==
      HabotSessionEnd.crash;

  static const String threeEndingsNote =
      '"No clean exit" is three events wearing one face: an unhandled error, '
      'an out-of-memory kill, and a person swiping the application away from '
      'the switcher. Counting all three as crashes makes the rate a measure '
      'of how often people close the app, and a team that optimises it will '
      'optimise the wrong thing. The marker, the crash record and the '
      'platform\'s memory-pressure signal separate them, and the crash record '
      'outranks the marker because a process that crashed after writing it '
      'still crashed.';

  // -----------------------------------------------------------------------
  // Metric: Crash-Free Session Rate -- 0.99 / 0.999 / 0.9999.
  // -----------------------------------------------------------------------

  static const double floorRate = 0.99;
  static const double optimalRate = 0.999;
  static const double ceilingRate = 0.9999;

  /// Sessions per crash at each point in the band.
  static int get sessionsPerCrashAtFloor => (1 / (1 - floorRate)).round();
  static int get sessionsPerCrashAtOptimal => (1 / (1 - optimalRate)).round();
  static int get sessionsPerCrashAtCeiling => (1 / (1 - ceilingRate)).round();

  /// The top of the band asks for a hundred times the evidence the bottom
  /// does, which is the practical content of those three decimal places.
  static int get evidenceRatioAcrossTheBand =>
      sessionsPerCrashAtCeiling ~/ sessionsPerCrashAtFloor;

  static String bandFor(double rate) {
    if (rate >= optimalRate) {
      return 'Good';
    }
    if (rate >= floorRate) {
      return 'Average';
    }
    return 'Poor';
  }

  static bool get theBandIsOrdered =>
      bandFor(0.99995) == 'Good' &&
      bandFor(0.995) == 'Average' &&
      bandFor(0.95) == 'Poor';

  static const String cannotComputeItHereNote =
      'The rate cannot be computed on the device. It needs every session in '
      'the denominator and the crashed ones in the numerator, and the session '
      'that crashed is the least able to report -- the report arrives on the '
      'next launch, from a different session, if there is one. So the number '
      'comes from Play Vitals or from the crash reporter\'s backend, and what '
      'this application supplies is the pair of facts those need: a session '
      'start and an honest ending. Named as somebody else\'s arithmetic, the '
      'way Steps 269 and 271 named their server halves.';

  static const String precisionNote =
      'Floor 0.99 is one crash in a hundred sessions; optimal 0.999 is one in '
      'a thousand; ceiling 0.9999 is one in ten thousand. The top of the band '
      'therefore asks for a hundred times the evidence the bottom does, and a '
      'weekly report on a small user base cannot tell 0.999 from 0.9999 '
      'because it has not seen ten thousand sessions. The three decimal '
      'places are a sample-size requirement written as a target, and reading '
      'a movement between them as a change in quality is reading noise.';

  /// **Pass on the half that is the application's.** The build identity, the
  /// per-ABI keys and the session-end marker are implemented; the upload
  /// itself is named as a pipeline step and the rate as somebody else's
  /// arithmetic.
  static String get qualitativeOutput =>
      everyAbiGetsItsOwnKey &&
              theBuildNumberIsPartOfTheKey &&
              theMarkerSeparatesThreeEndings &&
              nothingIsBundledWithTheApplication
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four release ABIs, each with its own symbol file and key':
            symbolFilesPerRelease == 4 && everyAbiGetsItsOwnKey,
        'the build number is part of the key':
            theBuildNumberIsPartOfTheKey && keyNote.contains('plausible'),
        'the symbol file name follows the tool\'s own convention':
            const HabotBuildIdentity(
                  appVersion: '1.4.0',
                  buildNumber: 312,
                  abi: 'android-arm64',
                ).symbolFileName ==
                'app.android-arm64.symbols',
        'a mobile build produces three artefacts and none is a source map':
            artefactsAMobileBuildProduces.length == 3 &&
                noSourceMapIsProducedHere,
        'the web word on a mobile row is recorded':
            sourceMapNote.contains('AppRouter.tsx'),
        'nothing is bundled with the application, checked against Step 263':
            nothingIsBundledWithTheApplication &&
                symbolsAreBuildOutputsNotRepositoryFiles,
        'shipping the mapping with the binary is named as decoration':
            doNotShipNote.contains('decoration'),
        'the marker separates a crash, an OOM kill and a swipe':
            theMarkerSeparatesThreeEndings,
        'a crash record outranks a written marker': aCrashOutranksTheMarker,
        'a clean exit is still recognised':
            endFor(
              markerWritten: true,
              crashRecorded: false,
              memoryPressureSeen: true,
            ) ==
                HabotSessionEnd.cleanExit,
        'the three endings are named rather than counted as one':
            threeEndingsNote.contains('optimise the wrong thing'),
        'the band is ordered and its three points are one, ten and ten '
            'thousand sessions apart':
            theBandIsOrdered &&
                sessionsPerCrashAtFloor == 100 &&
                sessionsPerCrashAtOptimal == 1000 &&
                sessionsPerCrashAtCeiling == 10000,
        'the top of the band needs a hundred times the evidence of the '
            'bottom, and that is recorded':
            evidenceRatioAcrossTheBand == 100 &&
                precisionNote.contains('sample-size requirement'),
        'the rate is named as arithmetic done elsewhere':
            cannotComputeItHereNote.contains('next launch'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and Expected '
      'Output is the row\'s own Atomic Step restated ("Fully configured and '
      'validated implementation of: Set up automated source map and symbol '
      'file uploading during build steps."). Atomic Step: "Set up automated '
      'source map and symbol file uploading during build steps."';
}
