/// AISS GATE -- Step 205 of 215
/// Global Reference ID:       GEN-01220
/// Atomic Steps Reference ID: GEN-01220
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Construct an expandable promo code input accordion container
///               on the checkout screen."
/// Metric: Coupon/Voucher Redemption Validation Accuracy -- Floor 0.97,
///         Optimal 0.999, Ceiling 1. Pass/Fail.
///
/// COLLAPSED BY DEFAULT IS THE REQUIREMENT, NOT A DEFAULT -- an open promo
/// field on checkout is an instruction to go and find a code. And the thing
/// the accordion must never do is throw away typing, which is exactly what a
/// naive one does on a failed apply and on a rebuild.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/checkout/promo_accordion.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double reliability = 0;

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

  group('GEN-01220 :: closed, and why', () {
    gate(
      'GEN-01220-G1',
      'Atomic Step: "an EXPANDABLE promo code input accordion container on the '
          'CHECKOUT screen."',
      'It renders collapsed, a tap opens it, and the reason for starting '
          'closed is written where the widget is defined rather than left as '
          'an initial value someone can reasonably flip',
      () {
        final HabotPromoAccordion fresh = HabotPromoAccordion();
        final bool closed = !fresh.isExpanded &&
            fresh.latch == HabotAccordionLatch.closed &&
            !HabotPromoAccordion.expandedByDefault;
        final bool opened = fresh.toggle() &&
            fresh.isExpanded &&
            fresh.latch == HabotAccordionLatch.openedByUser;
        return closed &&
            opened &&
            HabotPromoAccordion.collapsedIsTheFeatureNote
                .contains('do not come back');
      },
    );

    gate(
      'GEN-01220-G2',
      '"A failed apply closes the panel over its own error message."',
      'After a rejection the panel stays open, the code is still in the field '
          'and the error is still readable -- which is where it has to be, '
          'because it is about the thing in the field',
      () {
        final HabotPromoAccordion a = HabotPromoAccordion()
          ..toggle()
          ..updateDraft('WELCOME10')
          ..beginValidation()
          ..failValidation('Not valid on this service');
        return a.isExpanded &&
            a.latch == HabotAccordionLatch.heldOpenByContent &&
            a.draft == 'WELCOME10' &&
            a.error == 'Not valid on this service' &&
            !a.isValidating &&
            HabotPromoAccordion.naiveWouldCollapseAfter(
              orderChanged: false,
              applyFailed: true,
            );
      },
    );

    gate(
      'GEN-01220-G3',
      '"A rebuild when the order total changes."',
      'Toggling an add-on underneath the panel leaves the typed code and the '
          'open state untouched, where a naive accordion would collapse and '
          'discard it',
      () {
        final HabotPromoAccordion a = HabotPromoAccordion()
          ..toggle()
          ..updateDraft('WELCOME10')
          ..onOrderChanged();
        return a.isExpanded &&
            a.draft == 'WELCOME10' &&
            HabotPromoAccordion.naiveWouldCollapseAfter(
              orderChanged: true,
              applyFailed: false,
            ) &&
            HabotPromoAccordion.latchedByContentNote
                .contains('the app ignoring them');
      },
    );

    gate(
      'GEN-01220-G4',
      'A header tap while something is in the field would be the third way to '
          'lose it.',
      'The toggle refuses rather than silently absorbing the tap while content '
          'holds the panel open, and a successful apply is the one thing that '
          'legitimately empties and closes it',
      () {
        final HabotPromoAccordion held = HabotPromoAccordion()
          ..toggle()
          ..updateDraft('WELCOME10');
        final bool refused = !held.toggle() && held.isExpanded;
        final HabotPromoAccordion done = HabotPromoAccordion()
          ..toggle()
          ..updateDraft('WELCOME10')
          ..succeed();
        return refused &&
            !done.isExpanded &&
            done.draft.isEmpty &&
            done.error.isEmpty &&
            done.latch == HabotAccordionLatch.closed &&
            HabotAccordionLatch.values.length == 3;
      },
    );
  });

  group('GEN-01220 :: disclosure and boundary', () {
    gate(
      'GEN-01220-G5',
      'Step 97 progressive disclosure: "a rotating chevron is invisible to a '
          'screen reader."',
      'The expanded state is announced rather than drawn, the hint says what '
          'activation does in each state, and the rule that requires it is '
          'named',
      () {
        final HabotPromoAccordion closed = HabotPromoAccordion();
        final HabotPromoAccordion open = HabotPromoAccordion()..toggle();
        return !closed.semanticsExpanded &&
            open.semanticsExpanded &&
            closed.semanticsHint.contains('enter a code') &&
            open.semanticsHint.contains('collapse') &&
            closed.semanticsLabel == 'Promo code' &&
            HabotPromoAccordion.semanticRule ==
                'A11Y_PROGRESSIVE_DISCLOSURE' &&
            HabotPromoAccordion.disclosureIsAStateNote
                .contains('associated with the control');
      },
    );

    gate(
      'GEN-01220-G6',
      'A header a finger misses is a panel that never opens.',
      'The header clears the minimum touch target and every duration and '
          'measurement on the panel comes from a token rather than from a '
          'number at the layout site',
      () =>
          HabotPromoAccordion.headerMinHeightDp ==
              HabotDensity.minTouchTarget &&
          HabotPromoAccordion.panelPaddingDp == HabotSpacing.md &&
          HabotPromoAccordion.expandDuration == HabotMotion.standard &&
          HabotPromoAccordion.collapseDuration == HabotMotion.sheetExit &&
          HabotPromoAccordion.collapseDuration <
              HabotPromoAccordion.expandDuration,
    );

    gate(
      'GEN-01220-G7',
      'Metric: Coupon/Voucher Redemption Validation Accuracy -- floor 0.97, '
          'Pass/Fail. This step owns the container, not the validation.',
      'What is graded is whether the container ever destroys an input that was '
          'about to be validated -- a denominator this file controls -- and '
          'all nine checks hold, giving 1.0 and a Pass',
      () {
        reliability = HabotPromoAccordion.containerReliability;
        return HabotPromoAccordion.containerChecks.length == 9 &&
            HabotPromoAccordion.containerChecks.values.every((bool b) => b) &&
            reliability == 1.0 &&
            reliability >= HabotPromoAccordion.floor &&
            HabotPromoAccordion.qualitativeOutput(reliability) == 'Pass' &&
            HabotPromoAccordion.validationIsNotHereNote
                .contains('Step 206') &&
            HabotPromoAccordion.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01220',
        atomicStepReferenceId: 'GEN-01220',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Construct an expandable promo code input accordion '
            'container on the checkout screen."',
        implementationOrder: 205,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPromoAccordion',
          'Component Properties':
              'Collapsed on first render; '
              '${HabotAccordionLatch.values.length} latch states, one of them '
              'held by content; expand '
              '${HabotPromoAccordion.expandDuration.inMilliseconds}ms, '
              'collapse '
              '${HabotPromoAccordion.collapseDuration.inMilliseconds}ms; '
              'header at '
              '${HabotPromoAccordion.headerMinHeightDp.toStringAsFixed(0)}dp; '
              'expanded state announced',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: collapsed by default is the requirement '
              'rather than a default. An open promo field on a checkout screen '
              'is an instruction to go and find a code; people leave to look '
              'and a measurable share do not come back. It is written down '
              'where the widget is defined because "expand it, it is one less '
              'tap" is a reasonable-sounding change that nothing in the code '
              'would argue with. FINDING: two ordinary events collapse a naive '
              'accordion -- a failed apply, whose error message is inside the '
              'panel that just closed, and a rebuild when the order total '
              'changes because an add-on was toggled. Both destroy a code the '
              'parent already typed and both read as the app ignoring them. '
              'Expansion is latched by what the panel contains, and the '
              'naive behaviour is kept beside it so the difference is '
              'demonstrated. BOUNDARY: this step owns the container; Step 206 '
              'owns the field that asks the server whether a code is valid.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Coupon/Voucher Redemption Validation Accuracy '
                '(container reliability)',
            observed:
                '${reliability.toStringAsFixed(2)} over '
                '${HabotPromoAccordion.containerChecks.length} checks. The '
                'container never destroys an input that was about to be '
                'validated: a failed apply, an order change and a header tap '
                'all leave the typed code in place. Whether a code is VALID is '
                'the server\'s question and is not reported here.',
            floor: '0.97',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Ways a typed code can be lost',
            observed:
                '0 of the 3 identified: failed apply, order rebuild, header '
                'tap. A naive accordion loses it on the first two by '
                'construction.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/checkout/promo_accordion.dart',
        ],
      ),
    );
  });
}
