/// AISS Step 181 -- GEN-04275
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Produce and confirm the expected output: Fully Tokenized
///               Mobile Application Codebase & NPM Token Integration."
/// Metric: Deliverable/Output Verification -- Floor "N/A - Binary Governance
///         Gate", Optimal "100% - Expected Output Produced & Confirmed",
///         Ceiling "N/A - Binary Governance Gate". Pass / Fail.
///
/// **THIS STEP REPORTS FAIL, AND THAT IS THE CORRECT ANSWER TODAY.** The row
/// is a binary governance gate: there is no partial credit by construction,
/// and the floor and ceiling both say so. "Fully tokenized" either holds or it
/// does not, and three of the eight criteria below do not hold.
///
/// **A MILESTONE GATE IS ONLY WORTH ANYTHING IF IT CAN SAY NO.** A sign-off
/// step that passes because the work that led to it was substantial is not a
/// gate, it is a formality — and the damage is downstream, because everything
/// after it is built on a confirmation nobody could have withheld. The point
/// of this file is that the criteria are decidable and are evaluated against
/// what the repository can actually show.
///
/// **WHAT BLOCKS IT, PLAINLY.**
///   1. The palette is `PROVISIONAL` pending brand sign-off, unchanged since
///      Step 1. A fully tokenized codebase whose token *values* are
///      placeholders is a tokenized structure holding provisional content, and
///      confirming it would be confirming the shape rather than the thing.
///   2. The body type face is Roboto; the specification asks for Inter, and
///      Step 182 declines to swap the name without the asset.
///   3. "NPM Token Integration" has no meaning in this ecosystem and no
///      network on this host. Step 176 records the substitution; a gate that
///      asks for it cannot be told it happened.
///
/// **FIVE OF THE EIGHT DO HOLD**, and they are the structural half: one
/// declaration site per family, canonical MD3 names, declared-equals-delivered
/// parity, a packaged rule catalogue, and a blocking build intercept within
/// its exemption budget. That is what makes the three that do not hold worth
/// naming individually rather than reporting as one red light.
library;

import 'body_font_binding.dart';
import 'build_intercept.dart';
import 'governance_rules.dart';
import 'm3_naming.dart';
import 'token_package.dart';
import 'token_parity.dart';
import 'token_validation.dart';

/// One criterion in the milestone.
class HabotMilestoneCriterion {
  const HabotMilestoneCriterion({
    required this.id,
    required this.statement,
    required this.owner,
    required this.isMet,
    this.blocker,
  });

  final String id;
  final String statement;

  /// The step that is accountable for it.
  final String owner;

  final bool isMet;

  /// Why not. Required when [isMet] is false: a criterion that fails without
  /// saying why is a red light nobody can act on.
  final String? blocker;

  bool get isWellFormed => isMet || (blocker != null && blocker!.length > 30);
}

/// The "Fully Tokenized Mobile Application Codebase" gate.
class HabotTokenisationMilestone {
  const HabotTokenisationMilestone._();

  static List<HabotMilestoneCriterion> get criteria =>
      <HabotMilestoneCriterion>[
        HabotMilestoneCriterion(
          id: 'FT-1',
          statement: 'Every token family has exactly one declaration site, and '
              'every value in it is a compile-time constant.',
          owner: 'Step 176 GEN-03182',
          isMet: HabotTokenPackage.initialisesFree &&
              HabotTokenPackage.declarationSites.length ==
                  HabotTokenPackage.families.length,
        ),
        HabotMilestoneCriterion(
          id: 'FT-2',
          statement: 'Every declared token maps to a canonical MD3 name, and '
              'every departure from the MD3 role set is declared as a brand '
              'extension with a reason.',
          owner: 'Step 177 GEN-00033',
          isMet: HabotM3Naming.nonConformant().isEmpty &&
              HabotM3Naming.completeness >= HabotM3Naming.optimal,
        ),
        HabotMilestoneCriterion(
          id: 'FT-3',
          statement: 'The token a widget is handed is the token that was '
              'declared, in every scheme the app ships.',
          owner: 'Step 178 GEN-04528',
          isMet: HabotTokenParity.auditAll().isEmpty,
        ),
        HabotMilestoneCriterion(
          id: 'FT-4',
          statement: 'The rule set that enforces tokenisation is packaged as '
              'data: countable, reviewable, and adoptable without copying '
              'regexes.',
          owner: 'Step 179 GEN-03514',
          isMet: HabotGovernance.isPackaged,
        ),
        HabotMilestoneCriterion(
          id: 'FT-5',
          statement: 'Untokenised UI code fails the build, before the tests, '
              'with every exemption explained and the exemption count within '
              'its declared budget.',
          owner: 'Step 180 GEN-03602',
          isMet: HabotBuildIntercept.isEnforced,
        ),
        HabotMilestoneCriterion(
          id: 'FT-6',
          statement: 'The token specification the configuration is validated '
              'against has been approved.',
          owner: 'Step 174 GEN-00291',
          isMet: HabotTokenValidation.specificationIsApproved,
          blocker: 'tokens.json has been PROVISIONAL pending brand sign-off '
              'since Step 1. Every colour passes its accessibility gates and '
              'the hex values are placeholders. A fully tokenized codebase '
              'whose token VALUES are provisional is a tokenized structure '
              'holding provisional content; confirming it would confirm the '
              'shape rather than the thing.',
        ),
        HabotMilestoneCriterion(
          id: 'FT-7',
          statement: 'Body typography is bound to the family the specification '
              'names.',
          owner: 'Step 182 GEN-00599',
          isMet: HabotBodyFont.isAligned,
          blocker: 'The specification asks for Inter; the body tokens are '
              'bound to Roboto. Step 182 declines to change the family name '
              'without vendoring the font, because the result would be a '
              'per-device platform fallback that silently invalidates every '
              'text-fit measurement taken against Roboto metrics.',
        ),
        HabotMilestoneCriterion(
          id: 'FT-8',
          statement: 'NPM Token Integration is in place.',
          owner: 'Step 176 GEN-03182',
          isMet: false,
          blocker: 'NPM is JavaScript\'s registry and this is a Flutter '
              'application; there is also no network on this build host. Step '
              '176 records the substitution and builds the package manifest '
              'in the ecosystem that exists. A gate asking for NPM '
              'integration cannot be told it happened, and marking it met '
              'would be the one dishonest line in this file.',
        ),
      ];

  static List<HabotMilestoneCriterion> get met =>
      criteria.where((HabotMilestoneCriterion c) => c.isMet).toList();

  static List<HabotMilestoneCriterion> get unmet =>
      criteria.where((HabotMilestoneCriterion c) => !c.isMet).toList();

  /// Every unmet criterion must say why.
  static bool get everyFailureExplained =>
      criteria.every((HabotMilestoneCriterion c) => c.isWellFormed);

  // ---- the row's metric ---------------------------------------------------

  /// **Binary.** The row's floor and ceiling both read "N/A - Binary
  /// Governance Gate", so there is no partial credit and none is invented.
  static bool get isConfirmed => unmet.isEmpty;

  static String get qualitativeOutput => isConfirmed ? 'Pass' : 'Fail';

  /// Reported alongside the verdict, NOT as the verdict. A gate that reports
  /// "5 of 8" as though it were five-eighths passed is the formality this file
  /// exists to avoid.
  static String get progressForContext =>
      '${met.length} of ${criteria.length} criteria met';

  static List<String> get blockers => unmet
      .map((HabotMilestoneCriterion c) =>
          '${c.id} (${c.owner}): ${c.blocker ?? "no reason recorded"}')
      .toList();

  static const String binaryGateNote =
      'A milestone gate is only worth anything if it can say no. A sign-off '
      'that passes because the work leading to it was substantial is a '
      'formality, and the damage is downstream: everything after it rests on '
      'a confirmation nobody could have withheld.';

  static const String structuralVsContentNote =
      'Five of the eight criteria hold, and they are the structural half -- '
      'one declaration site per family, canonical MD3 names, '
      'declared-equals-delivered parity, a packaged rule catalogue, and a '
      'blocking intercept within budget. The three that do not hold are about '
      'CONTENT rather than structure: an unapproved palette, a type face that '
      'does not match the specification, and an integration in an ecosystem '
      'this app is not built in.';

  static const String noPartialCreditNote =
      'The count of criteria met is reported for context and is not the '
      'verdict. The row is Pass/Fail with "N/A - Binary Governance Gate" at '
      'both boundaries; reading five-of-eight as a score would be inventing a '
      'scale the row deliberately does not have.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
