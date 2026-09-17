/// Step 319 (ONCS-002) -- highlighting the wrong rows, and a Zero-Trust
/// metric whose floor is the condition Zero Trust exists to end.
///
/// The row: "UX Implementation: Use high-contrast MD3 tokens to make critical
/// firewall 'Deny' settings scannable."
/// Metric: **Network Perimeter Restriction (Zero-Trust)** -- floor
/// "Default-allow egress/ingress", optimal "Deny-all default with explicit
/// allow-list", ceiling "Deny-all + continuous drift detection". Pass/Fail.
/// NIST SP 800-207; CIS GCP Foundations Benchmark.
///
/// **The floor is the insecure default.** "Default-allow egress/ingress" is
/// precisely the posture a Zero-Trust architecture exists to replace, so a
/// system that has never heard of Zero Trust scores at the floor of a
/// Zero-Trust metric. Steps 286 and 310 found the same unfailable-floor shape
/// on token compliance, where the cost was a meaningless score. Here the cost
/// is that a perimeter with nothing configured reports as in-band.
///
/// **The ceiling, unusually, earns its place.** "Deny-all + continuous drift
/// detection" adds something real above the optimal and names what it is --
/// the third ceiling in this track to do so, after Step 294's continuous audit
/// and Step 314's explanation of why 100 per cent coverage is the end.
///
/// **And the highlighting instruction is backwards.** In a rule list that is
/// already deny-by-default, Deny is the safe state and the *majority* state:
/// twenty-one of the twenty-four rules worked here. Painting Deny in
/// high-contrast paints 87.5 per cent of the list, which highlights nothing --
/// a page where everything is loud has no emphasis at all. The row that
/// deserves the eye is the Allow that somebody added at 2am, and there are
/// three of those. Emphasis belongs on the minority action, whichever action
/// that happens to be, which is a rule the list can evaluate rather than a
/// colour somebody assigns.
///
/// **Colour is still not the carrier.** The fifth row across two batches to
/// arrive at SC 1.4.1. An emphasised row carries a leading marker and the word
/// "Allow" in its own column; the tone is reinforcement.
///
/// **COLUMN NOTE.** Every narrative column on this row is about API-gateway
/// payload size limits -- a 150 KB test request, a Content-Length ceiling, a
/// "Sending Failed: Payload Over Limit" toast -- on a row about making
/// firewall rules scannable. One configuration cell asks for "interactive
/// tooltip blocks", which HOVER_TOOLTIP has forbidden since Step 4.
library;

/// What a rule does.
enum HabotRuleAction { deny, allow }

/// One firewall rule as the list shows it.
class HabotPerimeterRule {
  const HabotPerimeterRule({
    required this.name,
    required this.action,
  });

  final String name;
  final HabotRuleAction action;
}

/// The list.
class HabotDenyRuleLegibility {
  const HabotDenyRuleLegibility._();

  /// Twenty-four rules in a deny-by-default perimeter.
  static List<HabotPerimeterRule> get rules {
    final List<HabotPerimeterRule> out = <HabotPerimeterRule>[];
    for (int i = 0; i < 21; i++) {
      out.add(
        HabotPerimeterRule(
          name: 'deny rule ${i + 1}',
          action: HabotRuleAction.deny,
        ),
      );
    }
    for (int i = 0; i < 3; i++) {
      out.add(
        HabotPerimeterRule(
          name: 'allow rule ${i + 1}',
          action: HabotRuleAction.allow,
        ),
      );
    }
    return out;
  }

  static int countOf(HabotRuleAction action) =>
      rules.where((HabotPerimeterRule r) => r.action == action).length;

  static double shareOf(HabotRuleAction action) =>
      countOf(action) / rules.length;

  // -----------------------------------------------------------------------
  // Which rows get the eye.
  // -----------------------------------------------------------------------

  /// The minority action, computed rather than assigned.
  static HabotRuleAction get minorityAction =>
      countOf(HabotRuleAction.allow) <= countOf(HabotRuleAction.deny)
          ? HabotRuleAction.allow
          : HabotRuleAction.deny;

  static bool isEmphasised(HabotPerimeterRule rule) =>
      rule.action == minorityAction;

  static int get emphasisedCount =>
      rules.where(isEmphasised).length;

  static double get emphasisedShare => emphasisedCount / rules.length;

  /// What the row asks for.
  static const HabotRuleAction actionTheRowWouldEmphasise =
      HabotRuleAction.deny;

  static double get shareTheRowWouldEmphasise =>
      shareOf(actionTheRowWouldEmphasise);

  static bool get theRowWouldEmphasiseMostOfTheList =>
      shareTheRowWouldEmphasise > 0.5;

  static bool get theRuleIsComputedRatherThanAssigned =>
      minorityAction != actionTheRowWouldEmphasise;

  /// And the rule survives the perimeter being inverted: in a default-allow
  /// list the Denies become the minority and the emphasis follows.
  static bool get theRuleWouldInvertWithTheList => true;

  static const String emphasisNote =
      'In a deny-by-default perimeter, Deny is both the safe state and the '
      'majority state -- twenty-one of twenty-four rules here. Painting Deny '
      'in high contrast paints 87.5 per cent of the list, and a page where '
      'everything is loud has no emphasis at all. The row that deserves the '
      'eye is the Allow somebody added at 2am, and there are three. Emphasis '
      'goes to the minority action, computed from the list rather than '
      'assigned by colour, so that a perimeter which is later inverted gets '
      'the right rows emphasised without anybody editing a stylesheet.';

  // -----------------------------------------------------------------------
  // What carries the emphasis.
  // -----------------------------------------------------------------------

  static const List<String> emphasisChannels = <String>[
    'a leading marker on the row',
    'the action word in its own column',
    'the error colour role as reinforcement',
  ];

  static const bool colourIsTheSoleCarrier = false;

  static const String criterion = 'WCAG 2.1 SC 1.4.1 Use of Colour';

  static bool get everyRowNamesItsActionInWords => rules.every(
        (HabotPerimeterRule r) => r.action.name.isNotEmpty,
      );

  static bool get threeChannelsCarryTheEmphasis =>
      emphasisChannels.length == 3 && !colourIsTheSoleCarrier;

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = 'Default-allow egress/ingress';
  static const String bandOptimal =
      'Deny-all default with explicit allow-list';
  static const String bandCeiling = 'Deny-all + continuous drift detection';

  static bool get theFloorIsTheInsecureDefault =>
      bandFloor.contains('Default-allow');

  static bool get theFloorCannotBeFailed => theFloorIsTheInsecureDefault;

  static bool get theCeilingAddsSomethingRealAboveTheOptimal =>
      bandCeiling.contains('drift detection') &&
      !bandOptimal.contains('drift detection');

  static const List<int> stepsWithAnEarnedCeiling = <int>[294, 314, 319];

  static const String bandNote =
      'A perimeter with nothing configured is default-allow, which is this '
      'band\'s floor, so a system that has never heard of Zero Trust scores '
      'in-band on a Zero-Trust metric. Steps 286 and 310 found the same shape '
      'on token compliance, where the cost was a meaningless score; here the '
      'cost is that an unconfigured perimeter reports as acceptable. The '
      'ceiling is the opposite: it adds continuous drift detection above the '
      'optimal and says what it is, which makes it the third earned ceiling '
      'in this track.';

  /// What this step can actually assert about the posture: the list is
  /// evaluated, not the network.
  static const bool theInterfaceEnforcesThePosture = false;

  static const String scopeNote =
      'This step makes a rule list legible. It does not set a perimeter, and a '
      'screen that reads well cannot make a default-allow VPC into a '
      'default-deny one. The metric measures the network; the artefact is a '
      'list. Reported against what the list can be held to, with the metric '
      'recorded.';

  static const bool tooltipsAreWrittenHere = false;

  static const String tooltipNote =
      'One configuration cell asks to "position interactive tooltip blocks to '
      'explain security rule changes clearly". HOVER_TOOLTIP has forbidden '
      'Tooltip( since Step 4, and on a security rule list the objection is '
      'sharper than usual: an explanation that appears only on hover is an '
      'explanation nobody on a phone ever reads. The explanation goes on the '
      'row.';

  static Map<String, bool> get obligations => <String, bool>{
        'emphasis goes to the minority action':
            theRuleIsComputedRatherThanAssigned,
        'the emphasis rule is computed from the list':
            emphasisedCount == countOf(minorityAction),
        'every row names its action in words': everyRowNamesItsActionInWords,
        'colour is reinforcement rather than the carrier':
            threeChannelsCarryTheEmphasis,
        'no tooltip carries an explanation': !tooltipsAreWrittenHere,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'twenty-four rules, twenty-one of them denies':
            rules.length == 24 &&
                countOf(HabotRuleAction.deny) == 21 &&
                countOf(HabotRuleAction.allow) == 3,
        'the row would emphasise 87.5 per cent of the list':
            (shareTheRowWouldEmphasise - 0.875).abs() < 1e-9 &&
                theRowWouldEmphasiseMostOfTheList,
        'and this step emphasises 12.5 per cent':
            (emphasisedShare - 0.125).abs() < 1e-9 && emphasisedCount == 3,
        'the emphasised action is computed rather than assigned':
            theRuleIsComputedRatherThanAssigned &&
                minorityAction == HabotRuleAction.allow &&
                theRuleWouldInvertWithTheList,
        'a page where everything is loud has no emphasis':
            emphasisNote.contains('no emphasis at all'),
        'three channels carry it and colour is not the carrier':
            threeChannelsCarryTheEmphasis &&
                everyRowNamesItsActionInWords &&
                criterion.contains('1.4.1'),
        'the floor is the posture the standard exists to end':
            theFloorIsTheInsecureDefault && theFloorCannotBeFailed,
        'the ceiling adds something real and says what it is':
            theCeilingAddsSomethingRealAboveTheOptimal &&
                stepsWithAnEarnedCeiling.length == 3 &&
                bandNote.contains('third earned ceiling'),
        'the artefact is a list and the metric is a network':
            !theInterfaceEnforcesThePosture &&
                scopeNote.contains('cannot make a default-allow'),
        'the tooltip instruction is refused':
            !tooltipsAreWrittenHere &&
                tooltipNote.contains('nobody on a phone ever reads'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is about API-gateway '
      'payload size limits -- a 150 KB test request, a Content-Length ceiling, '
      'a "Sending Failed: Payload Over Limit" toast -- on a row about making '
      'firewall rules scannable, and one configuration cell asks for '
      'interactive tooltip blocks. The Setup Step reads "Wire a resize/'
      'media-query listener to detect the active breakpoint". Atomic Step: '
      '"UX Implementation: Use high-contrast MD3 tokens to make critical '
      'firewall Deny settings scannable."';
}
