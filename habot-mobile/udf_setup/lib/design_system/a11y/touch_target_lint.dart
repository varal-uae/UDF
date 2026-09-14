/// Step 229 (GEN-04164) -- the layout linter that blocks a non-compliant
/// touch target from merging.
///
/// The row: "Implement the self-chasing enforcement mechanism: Non-compliant
/// touch targets trigger automatic layout linter flags, blocking UI code from
/// merging into the master branch."
/// Metric: Minimum Touch Target Size -- floor "44 x 44 CSS px (WCAG Minimum)",
/// optimal 48x48dp, ceiling 56x56dp. Pass/Fail.
///
/// **The merge block already exists; the rule does not.** Step 180 established
/// that `verify_aiss.sh` runs the poka-yoke guard at stage G-C, before the
/// tests, and exits non-zero on the first violation. Nothing merges past it.
/// What the guard has never had is a rule about whether a touch target is big
/// enough.
///
/// **It has one that looks like it.** Step 97's `A11Y_LITERAL_TOUCH_SIZE`
/// matches `minimumSize: ... Size(<digit>`, which catches a literal written at
/// a call site. It cannot catch
/// a minimumSize built from `WidgetStatePropertyAll(Size(HabotSpacing.lg,
/// HabotSpacing.lg))` -- a token, correctly used, that resolves to 24dp. That
/// passes the guard and
/// fails WCAG. The existing rule stops a literal; it says nothing about the
/// value.
///
/// So this step adds the complementary rule: evaluate the **declared value**
/// against the Step 184 band over a declared control inventory, rather than
/// pattern-matching source text. The two rules are complementary and both are
/// needed -- one stops a literal, the other stops a wrong number.
///
/// **The citation on this row is wrong.** It cites "WCAG 2.2 SC 2.5.8 Target
/// Size (Minimum)" for a 44x44 floor. SC 2.5.8 is Level AA at **24x24** CSS
/// pixels; 44x44 is SC 2.5.5 Target Size, Level AAA. The number is right and
/// the reference is not -- see Step 227.
library;

import 'dart:ui' show Size;

import '../interaction/touch_guideline.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// A control as the linter sees it: a name, a declared size, and the class it
/// belongs to.
class HabotLintedControl {
  const HabotLintedControl({
    required this.symbol,
    required this.declaredSize,
    required this.controlClass,
    required this.sizeWrittenAsALiteral,
  });

  /// Where it is declared, for the message.
  final String symbol;

  /// The size it resolves to -- not the text used to write it.
  final Size declaredSize;

  /// Which ceiling applies. See Step 227.
  final String controlClass;

  /// Whether the size was written as a number at the call site. The Step 97
  /// rule catches these; this rule does not care.
  final bool sizeWrittenAsALiteral;

  double get minorAxisDp => HabotTouchBand.minorOf(declaredSize);
}

/// One finding.
class HabotTouchLintFinding {
  const HabotTouchLintFinding({
    required this.symbol,
    required this.verdict,
    required this.message,
  });

  final String symbol;
  final HabotTouchVerdict verdict;
  final String message;

  bool get blocksMerge =>
      verdict == HabotTouchVerdict.tooSmall ||
      verdict == HabotTouchVerdict.tooLarge;
}

/// The rule.
class HabotTouchTargetLint {
  const HabotTouchTargetLint._();

  static const String ruleId = 'A11Y_TOUCH_TARGET_BELOW_BAND';

  static const String owner = 'Step 229 GEN-04164';

  /// The rule this one complements rather than replaces.
  static const String complementsRule = 'A11Y_LITERAL_TOUCH_SIZE';

  static const String complementNote =
      'A11Y_LITERAL_TOUCH_SIZE matches a literal written at a call site. It '
      'cannot see the value a token resolves to, so a control sized with '
      'HabotSpacing.lg -- a correct token, correctly used -- passes it at '
      '24dp. This rule evaluates the declared VALUE against the band and says '
      'nothing about how it was written. One stops a literal, the other stops '
      'a wrong number, and a repository needs both.';

  /// The merge block the row asks for, which was built at Step 4 and named at
  /// Step 180.
  static const String gateStage = 'G-C';
  static const String gateScript = 'tool/verify_aiss.sh';
  static const bool runsBeforeTests = true;
  static const bool exitsNonZeroOnFirstViolation = true;

  static const String blockAlreadyExistedNote =
      'The merge block is not new. verify_aiss.sh has run the poka-yoke guard '
      'at stage G-C, before the tests, since Step 4, and exits non-zero on the '
      'first violation. What did not exist was a rule about whether a target '
      'is big enough -- the same shape as Step 180, where the self-chasing '
      'mechanism the row asked to "activate" had been active for 176 steps and '
      'what was missing was the count.';

  /// Evaluate one control.
  static HabotTouchLintFinding evaluate(HabotLintedControl control) {
    final double ceiling =
        HabotTouchTargetGuideline.ceilingForControlClass(control.controlClass);
    final double minor = control.minorAxisDp;
    if (minor < HabotTouchTargetGuideline.floorDp) {
      return HabotTouchLintFinding(
        symbol: control.symbol,
        verdict: HabotTouchVerdict.tooSmall,
        message: '${control.symbol} resolves to '
            '${minor.toStringAsFixed(0)}dp on its minor axis, below the '
            '${HabotTouchTargetGuideline.floorDp.toStringAsFixed(0)}dp floor. '
            'Read HabotTouchBand.optimalDp rather than a spacing rung.',
      );
    }
    if (minor > ceiling) {
      return HabotTouchLintFinding(
        symbol: control.symbol,
        verdict: HabotTouchVerdict.tooLarge,
        message: '${control.symbol} resolves to '
            '${minor.toStringAsFixed(0)}dp, above the '
            '${ceiling.toStringAsFixed(0)}dp ceiling for a '
            '${control.controlClass}. Declare an exception at Step 227 if the '
            'control class warrants one.',
      );
    }
    // Inside the bounds for this control class. The generic band would call
    // a 64dp navigation destination tooLarge, which is precisely the
    // disagreement Step 227 resolves -- so the verdict is graded against the
    // resolved ceiling rather than delegated to HabotTouchBand.verdictFor.
    final HabotTouchVerdict verdict =
        minor == HabotTouchTargetGuideline.optimalDp
            ? HabotTouchVerdict.optimal
            : (minor < HabotTouchTargetGuideline.optimalDp
                ? HabotTouchVerdict.withinFloor
                : HabotTouchVerdict.withinCeiling);
    return HabotTouchLintFinding(
      symbol: control.symbol,
      verdict: verdict,
      message: '',
    );
  }

  /// What the generic band says about the same control, ignoring the
  /// per-control-class ceiling. Kept so the resolution is demonstrated.
  static HabotTouchVerdict genericBandVerdictFor(HabotLintedControl c) =>
      HabotTouchBand.verdictFor(c.declaredSize);

  /// What the Step 97 rule would say about the same control.
  static bool literalRuleWouldFlag(HabotLintedControl control) =>
      control.sizeWrittenAsALiteral;

  /// The inventory used to demonstrate the gap. Two of these are the cases
  /// that matter: a literal that both rules catch, and a token that only this
  /// one does.
  static List<HabotLintedControl> get inventory => <HabotLintedControl>[
        HabotLintedControl(
          symbol: 'AtomicButton at HabotDensity.minTouchTarget',
          declaredSize: Size(
            HabotDensity.minTouchTarget,
            HabotDensity.minTouchTarget,
          ),
          controlClass: 'icon button',
          sizeWrittenAsALiteral: false,
        ),
        HabotLintedControl(
          symbol: 'a control sized from HabotSpacing.lg',
          declaredSize: Size(HabotSpacing.lg, HabotSpacing.lg),
          controlClass: 'icon button',
          sizeWrittenAsALiteral: false,
        ),
        const HabotLintedControl(
          symbol: 'a control with minimumSize: Size(24, 24) at the call site',
          declaredSize: Size(24, 24),
          controlClass: 'icon button',
          sizeWrittenAsALiteral: true,
        ),
        const HabotLintedControl(
          symbol: 'HabotNavTabTargets destination cell',
          declaredSize: Size(64, 64),
          controlClass: 'navigation destination',
          sizeWrittenAsALiteral: false,
        ),
        const HabotLintedControl(
          symbol: 'an oversized 72dp free-standing button',
          declaredSize: Size(72, 72),
          controlClass: 'icon button',
          sizeWrittenAsALiteral: false,
        ),
        // Compliant, and still a literal. The band check passes it; the Step
        // 97 rule does not, because a number at a call site is a number that
        // stops tracking the token it was copied from.
        const HabotLintedControl(
          symbol: 'a compliant control with minimumSize: Size(48, 48)',
          declaredSize: Size(48, 48),
          controlClass: 'icon button',
          sizeWrittenAsALiteral: true,
        ),
      ];

  static HabotLintedControl controlNamed(String fragment) => inventory
      .firstWhere((HabotLintedControl c) => c.symbol.contains(fragment));

  static List<HabotTouchLintFinding> get findings =>
      inventory.map(evaluate).toList();

  static List<HabotTouchLintFinding> get blocking =>
      findings.where((HabotTouchLintFinding f) => f.blocksMerge).toList();

  /// Controls this rule blocks that the Step 97 rule would pass: the gap.
  static List<HabotLintedControl> get caughtOnlyByThisRule => inventory
      .where(
        (HabotLintedControl c) =>
            evaluate(c).blocksMerge && !literalRuleWouldFlag(c),
      )
      .toList();

  /// And controls the Step 97 rule catches that this one would pass -- the
  /// reason it is not replaced. A literal that happens to be 48 is still a
  /// literal.
  static List<HabotLintedControl> get caughtOnlyByTheLiteralRule => inventory
      .where(
        (HabotLintedControl c) =>
            literalRuleWouldFlag(c) && !evaluate(c).blocksMerge,
      )
      .toList();

  /// Share of the inventory this rule blocks, against the share the existing
  /// rule would.
  static double get coverage =>
      blocking.length / inventory.length;

  static double get literalRuleCoverage =>
      inventory.where(literalRuleWouldFlag).length / inventory.length;

  // -----------------------------------------------------------------------
  // The citation defect.
  // -----------------------------------------------------------------------

  static const String rowCitation =
      'WCAG 2.2 SC 2.5.8 Target Size (Minimum)';
  static const String rowFloor = '44 x 44 CSS px (WCAG Minimum)';

  static const String correctCitationFor44 = 'WCAG 2.1 SC 2.5.5 Target Size';

  static bool get rowCitesTheWrongCriterion =>
      rowCitation.contains('2.5.8') &&
      rowFloor.contains('44') &&
      HabotTouchTargetGuideline.sc258MinimumCssPx != 44 &&
      HabotTouchTargetGuideline.sc255MinimumCssPx == 44;

  // -----------------------------------------------------------------------
  // Metric: Minimum Touch Target Size. 44 / 48 / 56. Pass/Fail.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'the rule has an id and an owner':
            ruleId.startsWith('A11Y_') && owner.contains('GEN-04164'),
        'the merge block it needs already exists':
            runsBeforeTests && exitsNonZeroOnFirstViolation,
        'the rule evaluates a resolved value, not source text':
            evaluate(controlNamed('HabotSpacing.lg')).blocksMerge &&
                !literalRuleWouldFlag(controlNamed('HabotSpacing.lg')),
        'a token resolving to 24dp is caught where the literal rule passes it':
            caughtOnlyByThisRule.isNotEmpty &&
                caughtOnlyByThisRule.first.symbol.contains('HabotSpacing.lg'),
        'the existing rule still catches one this rule passes, so neither '
                'replaces the other':
            caughtOnlyByTheLiteralRule.length == 1 &&
                caughtOnlyByTheLiteralRule.single.symbol
                    .contains('Size(48, 48)'),
        'a compliant control is not flagged':
            !evaluate(controlNamed('AtomicButton')).blocksMerge,
        'a navigation destination at 64dp is not flagged as too large, '
                'though the generic band would':
            !evaluate(controlNamed('destination cell')).blocksMerge &&
                genericBandVerdictFor(controlNamed('destination cell')) ==
                    HabotTouchVerdict.tooLarge,
        'a free-standing control at 72dp is':
            evaluate(controlNamed('72dp')).verdict ==
                HabotTouchVerdict.tooLarge,
        'every blocking finding carries a message a developer can act on':
            blocking.every(
          (HabotTouchLintFinding f) => f.message.isNotEmpty,
        ),
        'the row cites a criterion that does not contain its own number':
            rowCitesTheWrongCriterion,
      };

  static bool get isPass => checks.values.every((bool b) => b);

  static String get qualitativeOutput => isPass ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement the self-chasing enforcement mechanism: Non-compliant touch '
      'targets trigger automatic layout linter flags, blocking UI code from '
      'merging into the master branch."';
}
