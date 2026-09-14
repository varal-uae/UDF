/// AISS GATE -- Step 229 of 235
/// Global Reference ID:       GEN-04164
/// Atomic Steps Reference ID: GEN-04164
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the self-chasing enforcement mechanism:
///               Non-compliant touch targets trigger automatic layout linter
///               flags, blocking UI code from merging into the master branch."
/// Metric: Minimum Touch Target Size -- Floor "44 x 44 CSS px (WCAG Minimum)",
///         Optimal 48x48dp, Ceiling 56x56dp. Pass/Fail.
///         Standard cited: WCAG 2.2 SC 2.5.8 Target Size (Minimum).
///
/// THE MERGE BLOCK ALREADY EXISTS; THE RULE DOES NOT. And the rule that looks
/// like it -- Step 97's A11Y_LITERAL_TOUCH_SIZE -- catches a literal and says
/// nothing about the value, so a correct token resolving to 24dp passes it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';
import 'package:udf_setup/design_system/a11y/touch_target_lint.dart';
import 'package:udf_setup/design_system/interaction/touch_guideline.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double coverage = 0;
  double literalCoverage = 0;

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

  group('GEN-04164 :: the block, and the rule it was missing', () {
    gate(
      'GEN-04164-G1',
      'Atomic Step: "... blocking UI code from merging into the master '
          'branch." Step 180 established that verify_aiss.sh runs the guard at '
          'stage G-C, before the tests, and exits non-zero on the first '
          'violation.',
      'The merge block is not new and is not rebuilt -- it is named, with its '
          'stage and its script -- and what this step adds is the rule that '
          'block never had',
      () =>
          HabotTouchTargetLint.gateStage == 'G-C' &&
          HabotTouchTargetLint.gateScript == 'tool/verify_aiss.sh' &&
          HabotTouchTargetLint.runsBeforeTests &&
          HabotTouchTargetLint.exitsNonZeroOnFirstViolation &&
          HabotTouchTargetLint.blockAlreadyExistedNote
              .contains('Step 180') &&
          HabotTouchTargetLint.ruleId == 'A11Y_TOUCH_TARGET_BELOW_BAND' &&
          HabotTouchTargetLint.owner.contains('GEN-04164'),
    );

    gate(
      'GEN-04164-G2',
      'Step 97\'s A11Y_LITERAL_TOUCH_SIZE matches a literal written at a call '
          'site.',
      'It is a real rule with a real owner and it is not replaced -- this rule '
          'names it as the one it complements, and the two are kept separate '
          'because they answer different questions',
      () =>
          HabotTouchTargetLint.complementsRule == 'A11Y_LITERAL_TOUCH_SIZE' &&
          HabotA11yRules.byId('A11Y_LITERAL_TOUCH_SIZE').owner
              .contains('Step 108') &&
          HabotA11yRules.all.length == 6 &&
          HabotTouchTargetLint.complementNote
              .contains('a repository needs both'),
    );

    gate(
      'GEN-04164-G3',
      '"A control sized with HabotSpacing.lg -- a correct token, correctly '
          'used -- passes it at 24dp."',
      'The gap is demonstrated on a real token: HabotSpacing.lg is 24, a '
          'control sized from it resolves below the 44dp floor, this rule '
          'blocks it, and the literal rule does not flag it because nothing '
          'about it is a literal',
      () {
        final HabotLintedControl c =
            HabotTouchTargetLint.controlNamed('HabotSpacing.lg');
        return HabotSpacing.lg == 24 &&
            c.minorAxisDp == 24 &&
            c.minorAxisDp < HabotTouchTargetGuideline.floorDp &&
            HabotTouchTargetLint.evaluate(c).blocksMerge &&
            HabotTouchTargetLint.evaluate(c).verdict ==
                HabotTouchVerdict.tooSmall &&
            !HabotTouchTargetLint.literalRuleWouldFlag(c) &&
            HabotTouchTargetLint.caughtOnlyByThisRule.length == 2 &&
            HabotTouchTargetLint.caughtOnlyByThisRule.first.symbol
                .contains('HabotSpacing.lg');
      },
    );

    gate(
      'GEN-04164-G4',
      'And the reverse, because a rule that made another redundant would '
          'deserve to replace it.',
      'A compliant control whose size is written as a literal is passed by '
          'this rule and flagged by Step 97\'s -- so neither rule replaces the '
          'other and both stay',
      () {
        final HabotLintedControl c =
            HabotTouchTargetLint.controlNamed('Size(48, 48)');
        return !HabotTouchTargetLint.evaluate(c).blocksMerge &&
            HabotTouchTargetLint.literalRuleWouldFlag(c) &&
            HabotTouchTargetLint.caughtOnlyByTheLiteralRule.length == 1 &&
            HabotTouchTargetLint.caughtOnlyByTheLiteralRule.single.symbol ==
                c.symbol;
      },
    );
  });

  group('GEN-04164 :: what the rule does, and what the row got wrong', () {
    gate(
      'GEN-04164-G5',
      'A rule that only fires downward would let a 72dp icon button through.',
      'The rule blocks in both directions and uses the per-control-class '
          'ceiling from Step 227, so a 64dp navigation destination passes and '
          'a 72dp free-standing button does not',
      () {
        final HabotLintedControl nav =
            HabotTouchTargetLint.controlNamed('destination cell');
        final HabotLintedControl big =
            HabotTouchTargetLint.controlNamed('72dp');
        final HabotLintedControl ok =
            HabotTouchTargetLint.controlNamed('AtomicButton');
        return !HabotTouchTargetLint.evaluate(nav).blocksMerge &&
            HabotTouchTargetLint.genericBandVerdictFor(nav) ==
                HabotTouchVerdict.tooLarge &&
            HabotTouchTargetLint.evaluate(big).blocksMerge &&
            HabotTouchTargetLint.evaluate(big).verdict ==
                HabotTouchVerdict.tooLarge &&
            !HabotTouchTargetLint.evaluate(ok).blocksMerge &&
            nav.controlClass == 'navigation destination' &&
            big.controlClass == 'icon button';
      },
    );

    gate(
      'GEN-04164-G6',
      'A build failure a developer cannot act on is a build failure with a '
          'stack trace attached.',
      'Every blocking finding carries a message naming the resolved value, the '
          'bound it missed and what to read instead, and the inventory is '
          'covered by this rule at 0.5 against the literal rule\'s 0.333',
      () {
        coverage = HabotTouchTargetLint.coverage;
        literalCoverage = HabotTouchTargetLint.literalRuleCoverage;
        return HabotTouchTargetLint.inventory.length == 6 &&
            HabotTouchTargetLint.blocking.length == 3 &&
            HabotTouchTargetLint.blocking.every(
              (HabotTouchLintFinding f) => f.message.isNotEmpty,
            ) &&
            HabotTouchTargetLint.evaluate(
              HabotTouchTargetLint.controlNamed('HabotSpacing.lg'),
            ).message.contains('HabotTouchBand.optimalDp') &&
            (coverage - 0.5).abs() < 1e-9 &&
            (literalCoverage - 1 / 3).abs() < 1e-9;
      },
    );

    gate(
      'GEN-04164-G7',
      'Metric floor: "44 x 44 CSS px (WCAG Minimum)". Standard cited: "WCAG '
          '2.2 SC 2.5.8 Target Size (Minimum)".',
      'SC 2.5.8 is Level AA at 24x24 CSS pixels; 44x44 is SC 2.5.5, Level AAA. '
          'The number on this row is right and the criterion it cites does not '
          'contain it -- recorded, and the ten checks hold for a Pass',
      () =>
          HabotTouchTargetLint.rowCitesTheWrongCriterion &&
          HabotTouchTargetLint.rowCitation.contains('2.5.8') &&
          HabotTouchTargetLint.correctCitationFor44.contains('2.5.5') &&
          HabotTouchTargetGuideline.sc258MinimumCssPx == 24 &&
          HabotTouchTargetLint.checks.length == 10 &&
          HabotTouchTargetLint.checks.values.every((bool b) => b) &&
          HabotTouchTargetLint.isPass &&
          HabotTouchTargetLint.qualitativeOutput == 'Pass' &&
          HabotTouchTargetLint.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04164',
        atomicStepReferenceId: 'GEN-04164',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement the self-chasing enforcement mechanism: '
            'Non-compliant touch targets trigger automatic layout linter '
            'flags, blocking UI code from merging into the master branch."',
        implementationOrder: 229,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTouchTargetLint',
          'Component Properties':
              'Rule ${HabotTouchTargetLint.ruleId}, owned by '
              '${HabotTouchTargetLint.owner}, complementing '
              '${HabotTouchTargetLint.complementsRule}; evaluates a resolved '
              'value against the Step 184 band with the Step 227 '
              'per-control-class ceiling; inventory of '
              '${HabotTouchTargetLint.inventory.length} controls of which '
              '${HabotTouchTargetLint.blocking.length} block the merge',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the merge block the row asks for already exists. Step '
              '180 established that verify_aiss.sh runs the poka-yoke guard at '
              'stage G-C, before the tests, and exits non-zero on the first '
              'violation. What the guard has never had is a rule about whether '
              'a touch target is big enough -- the same shape as Step 180 '
              'itself, where the mechanism the row asked to "activate" had '
              'been active since Step 4 and what was missing was the number. '
              'SECOND FINDING: there IS a rule that looks like it. Step 97\'s '
              'A11Y_LITERAL_TOUCH_SIZE matches a literal minimum size written '
              'at a call site. It cannot see the value a token resolves to, so '
              'a control sized with HabotSpacing.lg -- a correct token, '
              'correctly used -- passes the guard at 24dp and fails WCAG. This '
              'step adds the complementary rule: evaluate the declared VALUE '
              'against the band rather than pattern-matching source text. '
              'Neither replaces the other, and both are demonstrated catching '
              'something the other passes. THIRD: the citation on this row is '
              'wrong. It cites WCAG 2.2 SC 2.5.8 Target Size (Minimum) for a '
              '44x44 floor; 2.5.8 is Level AA at 24x24 and 44x44 is SC 2.5.5, '
              'Level AAA. The number is right and the reference is not, which '
              'is worse than a wrong number: it survives review because the '
              'figure looks familiar.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Minimum Touch Target Size',
            observed:
                'PASS on all ${HabotTouchTargetLint.checks.length} checks. The '
                'rule blocks in both directions against the Step 227 '
                'per-control-class ceiling: a 24dp token-sized control and a '
                '72dp free-standing button block, a 64dp navigation '
                'destination does not.',
            floor: '44 x 44 CSS px (WCAG Minimum) -- see the citation note',
            optimal: '48 x 48 dp (Material Design 3)',
            ceiling: '56 x 56 dp (Oversized / Diminishing Returns)',
          ),
          AissMeasurement(
            metricName: 'Inventory coverage, this rule against the existing '
                'one',
            observed:
                '${coverage.toStringAsFixed(3)} against '
                '${literalCoverage.toStringAsFixed(3)}. Each rule catches one '
                'control the other passes: a token resolving to 24dp is '
                'invisible to a source-reading rule, and a compliant literal '
                'is invisible to a value-reading one. Both stay.',
            floor: 'n/a -- comparison',
            optimal: 'n/a -- comparison',
            ceiling: 'n/a -- comparison',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/touch_target_lint.dart',
        ],
      ),
    );
  });
}
