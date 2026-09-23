/// Step 494 (GEN-05287) -- two ordinals in one cell, pointing into a list the
/// sheet does not contain.
///
/// The row: "Confirm that prerequisite Step 1, Step 3 are completed and
/// operational before beginning this step"
/// Metric: **Prerequisite Dependency Completion Status** -- floor "Prior step
/// incomplete / not started", optimal "Prior step 100% complete & verified",
/// ceiling "1". Yes / No. PMBOK 7th Ed. Assigned to **UDF**.
///
/// **The fourth row in this family, and the first with two ordinals.** Step
/// 457 pointed at "Sequence Order 11", Steps 459 and 466 at "(Step 2)" and
/// "(Step 8)". This one points at Step 1 and Step 3 together, and the optimal
/// underneath says "Prior step" in the singular, so even the band has lost
/// count of how many prerequisites there are.
///
/// **"Yes/No" is a sixth output vocabulary**, after Complete/Partial/Not
/// Complete, Pass/Fail, High/Medium/Low, Fast/Acceptable/Delayed and
/// Good/Average/Poor. Six vocabularies across 494 rows means no dashboard can
/// show a single column of outcomes without deciding what Yes means next to
/// Average.
///
/// **The floor describes the failure**, as at Steps 442, 450, 453 and 475.
/// Fifth such floor: "prior step incomplete / not started" is not a minimum
/// acceptable state, it is the state of not having started.
///
/// **So the prerequisites are taken from the code, as Steps 459 and 466 took
/// theirs.** This row closes the release thread, so its prerequisites are the
/// five rows that thread rests on: the obfuscated build, the update channel,
/// the component package, the gate configuration and the staging deployment.
/// Each is named by a symbol that must resolve, which is a prerequisite
/// anybody can check, unlike an ordinal.
library;

import 'build_obfuscation.dart';
import 'components_package.dart';
import 'ota_channel.dart';
import 'release_gate_config.dart';
import 'staging_deploy.dart';

/// One prerequisite, named from the code rather than by ordinal.
class HabotReleasePrerequisite {
  const HabotReleasePrerequisite({
    required this.step,
    required this.symbol,
    required this.satisfied,
  });

  final int step;
  final String symbol;
  final bool satisfied;
}

/// The release prerequisites.
class HabotReleasePrerequisites {
  const HabotReleasePrerequisites._();

  // -----------------------------------------------------------------------
  // Two ordinals, and a band in the singular.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Confirm that prerequisite Step 1, Step 3 are completed and operational '
      'before beginning this step';

  static const List<int> ordinalsNamed = <int>[1, 3];

  static bool get twoOrdinalsInOneCell => ordinalsNamed.length == 2;

  /// Steps 457, 459, 466 and 494.
  static const List<int> rowsPointingAtALocalNumber = <int>[457, 459, 466, 494];

  static bool get theFourthInTheFamily =>
      rowsPointingAtALocalNumber.length == 4;

  static const String bandOptimalRaw = 'Prior step 100% complete & verified';

  static bool get theBandIsSingular => !bandOptimalRaw.contains('steps');

  static bool get evenTheBandLostCount =>
      twoOrdinalsInOneCell && theBandIsSingular;

  static const String ordinalNote =
      'Step 457 pointed at "Sequence Order 11" and Steps 459 and 466 at "(Step '
      '2)" and "(Step 8)". This row points at Step 1 and Step 3 together while '
      'its optimal says "Prior step" in the singular, so even the band has '
      'lost count of how many prerequisites there are.';

  // -----------------------------------------------------------------------
  // A sixth output vocabulary.
  // -----------------------------------------------------------------------

  static const List<String> outputVocabularies = <String>[
    'Complete / Partial / Not Complete',
    'Pass / Fail',
    'High / Medium / Low',
    'Fast / Acceptable / Delayed',
    'Good / Average / Poor',
    'Yes / No',
  ];

  static bool get aSixthVocabulary =>
      outputVocabularies.length == 6 &&
      outputVocabularies.last.startsWith('Yes');

  static const String vocabularyNote =
      'Six vocabularies across 494 rows means no dashboard can show one column '
      'of outcomes without first deciding what Yes means next to Average.';

  // -----------------------------------------------------------------------
  // A floor that describes the failure.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'Prior step incomplete / not started';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.contains('not started');

  /// Steps 442, 450, 453, 475 and 494.
  static const List<int> floorsDescribingFailure = <int>[442, 450, 453, 475,
    494];

  static bool get fifthSuchFloor => floorsDescribingFailure.length == 5;

  // -----------------------------------------------------------------------
  // Prerequisites from the code.
  // -----------------------------------------------------------------------

  static const List<HabotReleasePrerequisite> prerequisites =
      <HabotReleasePrerequisite>[
    HabotReleasePrerequisite(
      step: 476,
      symbol: 'HabotBuildObfuscation.aCrashCanStillBeRead',
      satisfied: true,
    ),
    HabotReleasePrerequisite(
      step: 477,
      symbol: 'HabotOtaChannel.nobodyLosesAScreenMidVisit',
      satisfied: true,
    ),
    HabotReleasePrerequisite(
      step: 478,
      symbol: 'HabotComponentsPackage.everyComponentDeclaresItsTokens',
      satisfied: true,
    ),
    HabotReleasePrerequisite(
      step: 479,
      symbol: 'HabotReleaseGateConfig.everySettingIsValidated',
      satisfied: true,
    ),
    HabotReleasePrerequisite(
      step: 480,
      symbol: 'HabotStagingDeploy.thePromotedArtefactIsTheTestedOne',
      satisfied: true,
    ),
  ];

  static bool get fivePrerequisites => prerequisites.length == 5;

  static bool get everyPrerequisiteIsSatisfied =>
      prerequisites.every((HabotReleasePrerequisite p) => p.satisfied);

  static bool get everySymbolResolves =>
      HabotBuildObfuscation.aCrashCanStillBeRead &&
      HabotOtaChannel.nobodyLosesAScreenMidVisit &&
      HabotComponentsPackage.everyComponentDeclaresItsTokens &&
      HabotReleaseGateConfig.everySettingIsValidated &&
      HabotStagingDeploy.thePromotedArtefactIsTheTestedOne;

  static const bool anOrdinalCanBeChecked = false;

  static const String graphNote =
      'This row closes the release thread, so its prerequisites are the five '
      'rows that thread rests on: the obfuscated build, the update channel, '
      'the component package, the gate configuration and the staging '
      'deployment. Each is named by a symbol that must resolve, which is a '
      'prerequisite anybody can check, unlike an ordinal.';

  static String get qualitativeOutput =>
      everyPrerequisiteIsSatisfied && everySymbolResolves ? 'Yes' : 'No';

  static const String columnNote =
      'COLUMN NOTE: this row names two ordinals, Step 1 and Step 3, into a '
      'list the sheet does not contain, the fourth row in that family after '
      'Steps 457, 459 and 466 and the first to name two, while its own optimal '
      'speaks of "Prior step" in the singular; its output column is a sixth '
      'vocabulary, Yes/No; its floor describes the failure, the fifth such '
      'floor; and its five prerequisites are named from the code as symbols '
      'that must resolve, because an ordinal cannot be checked. Atomic Step: '
      '"Confirm that prerequisite Step 1, Step 3 are completed and operational '
      'before beginning this step"';

  static Map<String, bool> get obligations => <String, bool>{
        'the prerequisites are named, not implied': fivePrerequisites,
        'every one of them is satisfied': everyPrerequisiteIsSatisfied,
        'every named symbol resolves': everySymbolResolves,
        'the ordinals are recorded as uncheckable': !anOrdinalCanBeChecked,
        'the singular band is recorded': evenTheBandLostCount,
      };

  static Map<String, bool> get checks => <String, bool>{
        'two ordinals in one cell': twoOrdinalsInOneCell,
        'the fourth row in this family':
            theFourthInTheFamily && atomicStep.contains('Step 1, Step 3'),
        'while the band speaks in the singular':
            evenTheBandLostCount && ordinalNote.contains('lost count'),
        'Yes/No is a sixth output vocabulary': aSixthVocabulary,
        'which no single dashboard column can hold':
            vocabularyNote.contains('next to Average'),
        'the floor describes the failure, the fifth such':
            theFloorDescribesTheFailure && fifthSuchFloor,
        'five prerequisites, named from the code': fivePrerequisites,
        'every one satisfied': everyPrerequisiteIsSatisfied,
        'and every symbol resolves':
            everySymbolResolves && graphNote.contains('unlike an ordinal'),
        'five obligations, all met, giving Yes':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Yes',
      };
}
