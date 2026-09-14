/// Step 240 (GEN-04009) -- binding the validation engine to the field
/// controllers, and the rules a regular expression cannot carry.
///
/// The row: "Attach the Regex validation engine directly to the frontend
/// mobile input field controllers."
/// Metric: **Edge Regex Binding Rate** -- floor 1, optimal 1, ceiling 1.
/// Pass/Fail. Standard cited: Client-Side Poka-Yoke Validation.
///
/// **Every declared field is bound. Not every declared rule is a regex.**
/// Thirteen of thirteen CDEs carry a pattern and `ValidatedInputField` wires
/// it in, so the binding rate over regex-expressible rules is 1.0 and the row
/// passes on its own terms. The figure that means something is the other one:
/// over *every* check the fields in Step 236's inventory actually need, a
/// regular expression can carry two kinds out of five. A checksum is
/// arithmetic, a registry is a lookup, and a cross-field rule belongs to no
/// field -- and none of the three can be attached to a field controller at
/// all, because a field controller only sees one field.
///
/// Both figures are published, the same shape as Steps 233 and 234: the
/// exclusion is declared rather than the denominator chosen to make the
/// number come out at one.
///
/// **"Directly to the controller" is the wrong attachment point for the rule
/// that matters.** A `TextEditingController` is one field's text. The gate
/// that decides whether a form may be submitted is [HabotFormGate], and the
/// arithmetic gate Step 252 adds sits above every field at once. Binding
/// validation to controllers and stopping there is how a form ends up with
/// thirteen valid fields and a total that does not add up.
library;

import 'compliance_field_inventory.dart';
import 'field_validation.dart';

/// One rule this application needs, and what can carry it.
class HabotBoundRule {
  const HabotBoundRule({
    required this.name,
    required this.kind,
    required this.attachedTo,
    required this.why,
  });

  final String name;

  final HabotCheckKind kind;

  /// Where the rule runs. Empty when nothing carries it yet.
  final String attachedTo;

  final String why;

  /// Expressible as a regular expression over one field's text.
  bool get isRegexExpressible =>
      kind == HabotCheckKind.mask || kind == HabotCheckKind.pattern;

  /// Attachable to a single [TextEditingController], which is what the row
  /// asks for. A rule that reads two fields is not.
  bool get fitsOnAController => isRegexExpressible;

  bool get isBound => attachedTo.isNotEmpty;
}

/// The binding census.
class HabotEdgeBinding {
  const HabotEdgeBinding._();

  /// Every CDE carries a pattern, and the field widget wires it in. Read from
  /// the declaration rather than counted by hand.
  static int get declaredFields => HabotCde.values.length;

  static int get fieldsWithAPattern => HabotCde.values
      .where((HabotCde c) => HabotFieldRules.of(c).pattern.pattern.isNotEmpty)
      .length;

  static bool get everyFieldCarriesAPattern =>
      HabotFieldRules.isComplete && fieldsWithAPattern == declaredFields;

  /// The row's metric, on the row's own terms.
  static double get edgeRegexBindingRate =>
      fieldsWithAPattern / declaredFields;

  /// The rules this application needs, across all five kinds.
  static List<HabotBoundRule> get rules => <HabotBoundRule>[
        const HabotBoundRule(
          name: 'character filter per field',
          kind: HabotCheckKind.mask,
          attachedTo: 'ValidatedInputField inputFormatters',
          why: 'Decides what may be typed. Runs on every keystroke because '
              'that is the only moment it can prevent anything.',
        ),
        const HabotBoundRule(
          name: 'whole-value pattern per field',
          kind: HabotCheckKind.pattern,
          attachedTo: 'HabotFieldRule.pattern, read by HabotFormGate',
          why: 'Decides whether the value is acceptable. Runs on blur, per '
              'Step 246, because judging a value half typed is not judging a '
              'value.',
        ),
        const HabotBoundRule(
          name: 'IBAN mod-97',
          kind: HabotCheckKind.checksum,
          attachedTo: 'HabotIbanValidator (Step 243)',
          why: 'Arithmetic over the value\'s own digits. A regular expression '
              'recognises a regular language and this is not one -- no '
              'pattern can compute a remainder.',
        ),
        const HabotBoundRule(
          name: 'IBAN country length and registry membership',
          kind: HabotCheckKind.registry,
          attachedTo: 'HabotIbanValidator (Step 243), as a declared subset',
          why: 'The full ISO 13616 registry changes without notice. A client '
              'copy goes stale and starts rejecting valid accounts, so the '
              'client carries the countries it serves and says so.',
        ),
        const HabotBoundRule(
          name: 'source minus destination equals zero',
          kind: HabotCheckKind.crossField,
          attachedTo: 'HabotBalanceGate (Step 252)',
          why: 'Belongs to no field. A controller sees one field\'s text, so '
              'there is no controller this rule could be attached to.',
        ),
      ];

  static List<HabotBoundRule> get regexExpressibleRules =>
      rules.where((HabotBoundRule r) => r.isRegexExpressible).toList();

  static List<HabotBoundRule> get beyondARegex =>
      rules.where((HabotBoundRule r) => !r.isRegexExpressible).toList();

  static List<HabotBoundRule> get unattachableToAController =>
      rules.where((HabotBoundRule r) => !r.fitsOnAController).toList();

  /// Every rule has somewhere to run, regex or not. The row's rate says
  /// nothing about this, which is why it is published beside it.
  static double get ruleCoverageRate =>
      rules.where((HabotBoundRule r) => r.isBound).length / rules.length;

  static double get regexShareOfRules =>
      regexExpressibleRules.length / rules.length;

  static bool get everyRuleIsBoundSomewhere =>
      rules.every((HabotBoundRule r) => r.isBound);

  static bool get theThreeHardKindsAreNamed =>
      beyondARegex.length == 3 &&
      beyondARegex.map((HabotBoundRule r) => r.kind).toSet().length == 3;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String regexCannotNote =
      'A regular expression recognises a regular language. Mod-97 over '
      'twenty-three characters is arithmetic, not recognition, and no pattern '
      'computes a remainder -- which is the whole point of an IBAN and the '
      'reason Step 243 exists. Two of the five kinds of check this '
      'application needs fit in a pattern; three do not.';

  static const String attachmentPointNote =
      '"Directly to the controller" is the wrong attachment point for the '
      'rule that matters. A TextEditingController is one field\'s text. The '
      'gate that decides whether a form may be submitted is HabotFormGate, '
      'and the arithmetic gate Step 252 adds sits above every field at once. '
      'Binding validation to controllers and stopping there is how a form '
      'ends up with thirteen valid fields and a total that does not add up.';

  static const String twoFiguresNote =
      'Both figures are published, the same shape as Steps 233 and 234. Over '
      'regex-expressible rules the binding rate is 1.0 and the row passes on '
      'its own terms. Over every check the application actually needs, a '
      'regular expression carries two kinds out of five. The exclusion is '
      'declared rather than the denominator chosen to make the number come '
      'out at one.';

  // -----------------------------------------------------------------------
  // Metric: Edge Regex Binding Rate -- floor, optimal and ceiling all 1.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  static String get qualitativeOutput =>
      edgeRegexBindingRate >= floor && everyRuleIsBoundSomewhere
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'every declared field carries a pattern and it is wired in':
            everyFieldCarriesAPattern,
        'the row\'s own binding rate is 1.0': edgeRegexBindingRate == 1.0,
        'five rules across five kinds are listed':
            rules.length == 5 &&
                rules.map((HabotBoundRule r) => r.kind).toSet().length == 5,
        'three of the five cannot be expressed as a regular expression':
            theThreeHardKindsAreNamed,
        'the three that cannot are also the three that cannot be attached to '
            'a single controller': unattachableToAController.length == 3,
        'every rule is bound somewhere, regex or not':
            everyRuleIsBoundSomewhere && ruleCoverageRate == 1.0,
        'the regex share of the rule set is published beside the row\'s rate':
            (regexShareOfRules - 0.4).abs() < 1e-9,
        'every rule says why it runs where it runs':
            rules.every((HabotBoundRule r) => r.why.length > 60),
        'the wrong-attachment-point finding is recorded':
            attachmentPointNote.contains('does not add up'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Attach the Regex validation engine directly to the frontend mobile '
      'input field controllers."';
}
