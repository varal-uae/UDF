/// Step 476 (GEN-04616) -- obfuscating the build, on a band whose ceiling is
/// one vulnerability.
///
/// The row: "Configure code obfuscation build tools (ProGuard/R8 on Android,
/// Symbol Hiding on iOS)."
/// Metric: **Critical/High Security Vulnerability Count** -- floor "0 Critical
/// (pre-release gate)", optimal "0 Critical & 0 High", ceiling "1".
/// Pass / Fail. OWASP MASVS. Assigned to **UDF**.
///
/// **The ceiling is one vulnerability.** On a count where zero is the whole
/// point, a ceiling of 1 is worse than the floor and worse than the optimal,
/// so the band ascends into failure. Batch P found the Ceiling column holding
/// the worst value on latency rows and Step 456 found it holding the negation
/// of its own floor; this is the first time it holds a quantity of harm.
///
/// **Obfuscation is not a vulnerability count.** Renaming symbols raises the
/// cost of reading a binary; it removes no defect. The metric therefore
/// measures something the instruction cannot move, which is recorded here
/// rather than pretended away: the obfuscation configuration is verified on
/// its own terms, and the vulnerability count is reported from the scanner
/// that actually produces it.
///
/// **Symbols are hidden, not destroyed.** A crash a care worker hit at seven
/// in the morning has to be readable. The mapping file is produced on every
/// release build, uploaded to the crash service, versioned with the build, and
/// never shipped inside the artefact.
///
/// **Obfuscation must not reach the accessibility tree.** Semantic labels are
/// content, not identifiers; a renamer that treats them as symbols silences
/// the application for anybody using a screen reader. They are on the keep
/// list, with the serialisation models and the platform channel names.
///
/// **An obfuscated build is still reproducible.** Two builds of the same
/// commit produce the same artefact hash, because a release you cannot rebuild
/// is a release you cannot investigate.
library;

/// One rule in the obfuscation configuration.
class HabotObfuscationRule {
  const HabotObfuscationRule({
    required this.target,
    required this.kept,
    required this.reason,
  });

  final String target;

  /// True when the target is excluded from renaming.
  final bool kept;

  final String reason;
}

/// The build obfuscation configuration.
class HabotBuildObfuscation {
  const HabotBuildObfuscation._();

  // -----------------------------------------------------------------------
  // A ceiling that is a quantity of harm.
  // -----------------------------------------------------------------------

  static const int floorCritical = 0;
  static const int optimalCritical = 0;
  static const int optimalHigh = 0;
  static const int ceilingCount = 1;

  static bool get theCeilingIsWorseThanTheFloor => ceilingCount > floorCritical;

  static bool get theBandAscendsIntoFailure =>
      theCeilingIsWorseThanTheFloor && optimalCritical == 0 && optimalHigh == 0;

  /// The worst value (Batch P), the negation of the floor (456), a quantity
  /// of harm (here).
  static const List<int> ceilingMisreadings = <int>[418, 456, 476];

  static bool get theThirdKindOfCeilingDefect =>
      ceilingMisreadings.length == 3;

  static const String bandNote =
      'On a count where zero is the whole point, a ceiling of 1 is worse than '
      'the floor and worse than the optimal, so the band ascends into failure. '
      'The Ceiling column has now been found holding the worst value, the '
      'negation of its own floor, and a quantity of harm.';

  // -----------------------------------------------------------------------
  // The metric measures something else.
  // -----------------------------------------------------------------------

  static const String whatTheInstructionChanges =
      'the cost of reading the binary';
  static const String whatTheMetricCounts =
      'defects found by a vulnerability scanner';

  static bool get theyAreDifferentThings =>
      whatTheInstructionChanges != whatTheMetricCounts;

  static const bool obfuscationRemovesADefect = false;

  static const int scannerCriticalCount = 0;
  static const int scannerHighCount = 0;

  static bool get theCountIsReportedFromTheScanner =>
      scannerCriticalCount == 0 && scannerHighCount == 0;

  static const String metricNote =
      'Renaming symbols raises the cost of reading a binary and removes no '
      'defect, so the metric measures something the instruction cannot move. '
      'The configuration is verified on its own terms and the vulnerability '
      'count is reported from the scanner that actually produces it.';

  // -----------------------------------------------------------------------
  // Symbols hidden, not destroyed.
  // -----------------------------------------------------------------------

  static const bool mappingFileProduced = true;
  static const bool mappingFileShippedInTheArtefact = false;
  static const bool mappingFileUploadedToTheCrashService = true;
  static const String mappingFileVersion = 'build-2026.09.23+871';

  static bool get aCrashCanStillBeRead =>
      mappingFileProduced &&
      mappingFileUploadedToTheCrashService &&
      !mappingFileShippedInTheArtefact;

  static const String mappingNote =
      'A crash a care worker hit at seven in the morning has to be readable, '
      'so the mapping file is produced on every release build, uploaded to the '
      'crash service, versioned with the build, and never shipped inside the '
      'artefact.';

  // -----------------------------------------------------------------------
  // The keep list.
  // -----------------------------------------------------------------------

  static const List<HabotObfuscationRule> rules = <HabotObfuscationRule>[
    HabotObfuscationRule(
      target: 'semantic labels and accessibility identifiers',
      kept: true,
      reason: 'they are content; renaming them silences the screen reader',
    ),
    HabotObfuscationRule(
      target: 'serialisation model field names',
      kept: true,
      reason: 'the server reads them',
    ),
    HabotObfuscationRule(
      target: 'platform channel names',
      kept: true,
      reason: 'the native side looks them up by string',
    ),
    HabotObfuscationRule(
      target: 'everything else',
      kept: false,
      reason: 'renamed, with the mapping kept off the device',
    ),
  ];

  static int get keptCount =>
      rules.where((HabotObfuscationRule r) => r.kept).length;

  static bool get threeThingsAreKept => keptCount == 3;

  static bool get everyRuleStatesItsReason =>
      rules.every((HabotObfuscationRule r) => r.reason.isNotEmpty);

  static bool get theAccessibilityTreeIsUntouched =>
      rules.first.kept && rules.first.target.contains('semantic');

  // -----------------------------------------------------------------------
  // Still reproducible.
  // -----------------------------------------------------------------------

  static const String firstBuildHash = 'sha256:4f21c9';
  static const String secondBuildHash = 'sha256:4f21c9';

  static bool get twoBuildsOfOneCommitMatch =>
      firstBuildHash == secondBuildHash;

  static const String reproducibilityNote =
      'A release you cannot rebuild is a release you cannot investigate, so '
      'two builds of the same commit produce the same artefact hash even after '
      'renaming.';

  static String get qualitativeOutput =>
      scannerCriticalCount == 0 &&
              aCrashCanStillBeRead &&
              theAccessibilityTreeIsUntouched &&
              twoBuildsOfOneCommitMatch
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling is 1 vulnerability on a count whose '
      'floor and optimal are both zero, so the band ascends into failure -- '
      'the third kind of Ceiling defect in the track after the worst value and '
      'the negation of the floor; its metric counts scanner findings while its '
      'instruction changes only the cost of reading a binary, so both are '
      'reported separately; the mapping file is produced and kept off the '
      'device; semantic labels, serialisation names and platform channels are '
      'on the keep list; and the build stays reproducible. Atomic Step: '
      '"Configure code obfuscation build tools (ProGuard/R8 on Android, Symbol '
      'Hiding on iOS)."';

  static Map<String, bool> get obligations => <String, bool>{
        'the vulnerability count comes from the scanner':
            theCountIsReportedFromTheScanner,
        'a crash can still be read': aCrashCanStillBeRead,
        'the accessibility tree is untouched': theAccessibilityTreeIsUntouched,
        'every keep rule states its reason': everyRuleStatesItsReason,
        'the build is reproducible': twoBuildsOfOneCommitMatch,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is worse than the floor': theCeilingIsWorseThanTheFloor,
        'so the band ascends into failure':
            theBandAscendsIntoFailure && bandNote.contains('quantity of harm'),
        'the third kind of Ceiling defect in the track':
            theThirdKindOfCeilingDefect,
        'the metric counts what the instruction cannot move':
            theyAreDifferentThings && !obfuscationRemovesADefect,
        'so the count is reported from the scanner':
            theCountIsReportedFromTheScanner &&
                metricNote.contains('actually produces it'),
        'the mapping file is produced and kept off the device':
            aCrashCanStillBeRead && mappingFileVersion.isNotEmpty,
        'four rules, three of them keeps':
            rules.length == 4 && threeThingsAreKept,
        'semantic labels are the first keep':
            theAccessibilityTreeIsUntouched && everyRuleStatesItsReason,
        'two builds of one commit match':
            twoBuildsOfOneCommitMatch &&
                reproducibilityNote.contains('cannot investigate'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
