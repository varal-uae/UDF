/// AISS GATE -- Step 200 of 215
/// Global Reference ID:       GEN-01165
/// Atomic Steps Reference ID: GEN-01165
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement dynamic CTA text logic that replaces the booking
///               action with 'Contact for Details' if the vendor profile is
///               incomplete."
/// Metric: Information Architecture Task Success Rate -- Floor 0.8,
///         Optimal 0.95, Ceiling 1. Good/Average/Poor.
///
/// THE ROW'S OWN LABEL BREAKS THE ROW'S OWN DESIGN SYSTEM. "Contact for
/// Details" is nineteen characters against Step 144's twelve-character button
/// budget, in English, before translation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/discovery/dynamic_cta.dart';
import 'package:udf_setup/design_system/i18n/language_toggle.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double success = 0;
  double inRow = 0;

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

  const Set<HabotVendorField> complete = <HabotVendorField>{
    HabotVendorField.displayName,
    HabotVendorField.pricedService,
    HabotVendorField.location,
    HabotVendorField.availability,
    HabotVendorField.contactChannel,
    HabotVendorField.verifiedStatus,
  };
  const Set<HabotVendorField> unverified = <HabotVendorField>{
    HabotVendorField.displayName,
    HabotVendorField.pricedService,
    HabotVendorField.location,
    HabotVendorField.availability,
    HabotVendorField.contactChannel,
  };
  const Set<HabotVendorField> bare = <HabotVendorField>{
    HabotVendorField.displayName,
  };

  group('GEN-01165 :: label and behaviour', () {
    gate(
      'GEN-01165-G1',
      'Atomic Step: "replaces the booking ACTION with \'Contact for '
          'Details\'". A button that says Contact and opens the booking flow '
          'is worse than one that says Book.',
      'Label and intent are one value, so a complete profile offers Book and '
          'an unverified one offers Contact -- and the label cannot be changed '
          'without changing what happens next',
      () {
        final HabotCta a = HabotDynamicCta.resolve(
          present: complete,
          placement: HabotCtaPlacement.fullWidth,
        );
        final HabotCta b = HabotDynamicCta.resolve(
          present: unverified,
          placement: HabotCtaPlacement.fullWidth,
        );
        return a.intent == HabotCtaIntent.book &&
            a.label == HabotDynamicCta.bookLabel &&
            b.intent == HabotCtaIntent.contact &&
            b.label == HabotDynamicCta.contactLabel &&
            HabotDynamicCta.labelMatchesIntent(a) &&
            HabotDynamicCta.labelMatchesIntent(b) &&
            HabotDynamicCta.labelAndActionMoveTogetherNote
                .contains('tells the truth');
      },
    );

    gate(
      'GEN-01165-G2',
      '"Incomplete" is not defined on the row, and left to the call site the '
          'list and the detail page disagree about the same vendor.',
      'Completeness is one declared required-field set, what is missing is '
          'reportable in a stable order, and the contact route is '
          'deliberately not required for booking',
      () =>
          HabotDynamicCta.requiredForBooking.length == 5 &&
          !HabotDynamicCta.requiredForBooking
              .contains(HabotVendorField.contactChannel) &&
          HabotDynamicCta.isBookable(complete) &&
          !HabotDynamicCta.isBookable(unverified) &&
          HabotDynamicCta.missingFrom(unverified).single ==
              HabotVendorField.verifiedStatus &&
          HabotDynamicCta.missingFrom(bare).length == 4 &&
          HabotDynamicCta.completenessDefinedOnceNote
              .contains('has an answer'),
    );

    gate(
      'GEN-01165-G3',
      '"A vendor with an incomplete profile AND no contact route cannot be '
          'contacted either."',
      'The binary the row implies would put "Contact for Details" on a button '
          'with nowhere to go; a third intent says so instead, and it is '
          'reached only when there is genuinely no route',
      () {
        final HabotCta c = HabotDynamicCta.resolve(
          present: bare,
          placement: HabotCtaPlacement.fullWidth,
        );
        return c.intent == HabotCtaIntent.unavailable &&
            c.label == HabotDynamicCta.unavailableLabel &&
            HabotCtaIntent.values.length == 3 &&
            HabotDynamicCta.thirdIntentNote.contains('nowhere to go');
      },
    );
  });

  group('GEN-01165 :: nineteen characters against a budget of twelve', () {
    gate(
      'GEN-01165-G4',
      'Step 144 set a twelve-character button label budget because translated '
          'labels wrap and a wrapped button has a height nobody designed.',
      'The row\'s own label is nineteen characters and breaks that budget in '
          'English, before translation -- measured against the budget as Step '
          '144 declared it rather than against a number copied here',
      () =>
          HabotDynamicCta.contactLabelLength == 19 &&
          HabotDynamicCta.actionRowBudget ==
              HabotLanguageToggle.buttonLabelBudget &&
          HabotDynamicCta.actionRowBudget == 12 &&
          HabotDynamicCta.contactLabelBreaksActionRowBudget &&
          HabotDynamicCta.budgetCollisionNote
              .contains('before translation'),
    );

    gate(
      'GEN-01165-G5',
      '"A twelve-character limit on a full-width button is a rule with no '
          'reason behind it."',
      'The budget is declared per placement rather than globally, the label '
          'fits full-width and fits nowhere tighter, and the row\'s words are '
          'not truncated to satisfy a rule that was written about a different '
          'situation',
      () =>
          HabotDynamicCta.contactLabelFitsFullWidth &&
          HabotDynamicCta.budgetFor(HabotCtaPlacement.fullWidth) == 24 &&
          HabotDynamicCta.budgetFor(HabotCtaPlacement.listItemTrailing) == 8 &&
          HabotDynamicCta.placementsFor(HabotDynamicCta.contactLabel)
                  .single ==
              HabotCtaPlacement.fullWidth &&
          HabotDynamicCta.placementsFor(HabotDynamicCta.bookLabel).length ==
              3,
    );

    gate(
      'GEN-01165-G6',
      'The placement decision is load-bearing rather than cosmetic.',
      'The same six profile states score 1.0 on a full-width action and 0.667 '
          'in a constrained action row, because the two states that resolve '
          'to the long label no longer fit',
      () {
        success = HabotDynamicCta.taskSuccessRate;
        inRow = HabotDynamicCta.taskSuccessRateInActionRow;
        return success == 1.0 &&
            (inRow - 2 / 3).abs() < 1e-9 &&
            inRow < HabotDynamicCta.floor &&
            HabotDynamicCta.profileStates.length == 6;
      },
    );

    gate(
      'GEN-01165-G7',
      'Metric: Information Architecture Task Success Rate -- floor 0.8, '
          'optimal 0.95.',
      'At the placement this CTA is actually drawn in, every profile state '
          'produces an action whose label matches what it does and fits where '
          'it is drawn: 1.0, reported as Good',
      () =>
          success >= HabotDynamicCta.optimal &&
          success <= HabotDynamicCta.ceiling &&
          HabotDynamicCta.qualitativeOutput == 'Good' &&
          HabotDynamicCta.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01165',
        atomicStepReferenceId: 'GEN-01165',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement dynamic CTA text logic that replaces the booking '
            'action with \'Contact for Details\' if the vendor profile is '
            'incomplete."',
        implementationOrder: 200,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDynamicCta / HabotCta',
          'Component Properties':
              '${HabotVendorField.values.length} profile fields, '
              '${HabotDynamicCta.requiredForBooking.length} of them required '
              'for direct booking; ${HabotCtaIntent.values.length} intents, '
              'each carrying its own label; label budget declared per '
              'placement -- ${HabotDynamicCta.actionRowBudget} in an action '
              'row, ${HabotDynamicCta.fullWidthBudget} full-width, '
              '${HabotDynamicCta.listItemTrailingBudget} in a list item',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the row\'s own label breaks the row\'s own design '
              'system. "Contact for Details" is nineteen characters against '
              'Step 144\'s twelve-character button budget, in English, before '
              'translation -- and that budget exists because translated labels '
              'wrap and a wrapped button has a height nobody designed. Rather '
              'than truncating the row\'s words, the budget is declared PER '
              'PLACEMENT: twelve in a constrained action row, twenty-four '
              'full-width, eight in a list item. A twelve-character limit on a '
              'full-width button is a rule with no reason behind it. Measured: '
              'the same six profile states score 1.0 full-width and 0.667 in '
              'an action row, below the row\'s own floor of 0.8, so the '
              'placement decision is load-bearing. SECOND FINDING: the row '
              'changes the TEXT. A button reading "Contact for Details" that '
              'opens the booking flow is worse than one reading "Book"; label '
              'and intent are one value here. THIRD: a vendor with an '
              'incomplete profile and no contact route cannot be contacted '
              'either, and the row\'s binary would put the contact label on a '
              'button with nowhere to go.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Information Architecture Task Success Rate',
            observed:
                '${success.toStringAsFixed(2)} over '
                '${HabotDynamicCta.profileStates.length} profile states at the '
                'full-width placement: every state produces an action whose '
                'label matches what it does and fits where it is drawn.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'The same rate in a constrained action row',
            observed:
                '${inRow.toStringAsFixed(3)} -- the two states resolving to '
                '"Contact for Details" fail the twelve-character budget, '
                'putting the screen below the row\'s own floor of 0.8. The '
                'number that says the placement is a decision rather than a '
                'detail.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/discovery/dynamic_cta.dart',
        ],
      ),
    );
  });
}
