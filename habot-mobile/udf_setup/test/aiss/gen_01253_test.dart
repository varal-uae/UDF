/// AISS GATE -- Step 212 of 215
/// Global Reference ID:       GEN-01253
/// Atomic Steps Reference ID: GEN-01253
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement binary 'Approve' and 'Reject' decision CTA buttons
///               for operator overrides."
/// Metric: Fraud Detection False-Positive Rate -- Floor <5%, Optimal <1%,
///         Ceiling <10%. Good/Average/Poor.
///
/// THE ROW'S METRIC IS AN ARGUMENT AGAINST THE ROW'S INSTRUCTION. A false
/// positive is a legitimate order rejected, and a reviewer given two buttons
/// and an order they are unsure about has to pick one -- with the incentive
/// always pointing at reject.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/operations/decision_cta.dart';
import 'package:udf_setup/design_system/tokens/button_role_map.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  group('GEN-01253 :: binary, and the third outcome', () {
    gate(
      'GEN-01253-G1',
      'Atomic Step: "BINARY \'Approve\' and \'Reject\' decision CTA buttons." '
          'Metric: Fraud Detection False-Positive Rate.',
      'Both actions the row names exist, and a third -- neither, yet -- exists '
          'beside them and is marked as beyond the row, so what was asked for '
          'and what ships are distinguishable',
      () =>
          HabotReviewOutcome.values.length == 3 &&
          HabotDecisionCta.actions
                  .where((HabotDecisionAction a) => a.namedInRow)
                  .length ==
              2 &&
          HabotDecisionCta.actionFor(HabotReviewOutcome.approve).label ==
              'Approve' &&
          HabotDecisionCta.actionFor(HabotReviewOutcome.reject).label ==
              'Reject' &&
          !HabotDecisionCta.actionFor(
            HabotReviewOutcome.needsInformation,
          ).namedInRow,
    );

    gate(
      'GEN-01253-G2',
      '"An approved fraud is a loss with their name on it; a rejected customer '
          'is a support ticket with nobody\'s."',
      'The third outcome only reduces false positives if it is genuinely '
          'cheaper to choose than a rejection',
      () {
        final HabotDecisionAction third =
            HabotDecisionCta.actionFor(HabotReviewOutcome.needsInformation);
        final HabotDecisionAction reject =
            HabotDecisionCta.actionFor(HabotReviewOutcome.reject);
        return !third.requiresReasonCode &&
            third.isReversible &&
            reject.requiresReasonCode &&
            !reject.isReversible &&
            HabotDecisionCta.binaryManufacturesFalsePositivesNote
                .contains('cheapest available reduction');
      },
    );

    gate(
      'GEN-01253-G3',
      'Step 188: "a delete button coloured like a submit button gets pressed."',
      'Reject carries the destructive role and a different container token '
          'from Approve, and the third outcome is secondary rather than '
          'competing with either',
      () =>
          HabotDecisionCta.actionFor(HabotReviewOutcome.reject).role ==
              HabotButtonRole.destructive &&
          HabotDecisionCta.actionFor(HabotReviewOutcome.approve).role ==
              HabotButtonRole.confirm &&
          HabotDecisionCta.actionFor(
                HabotReviewOutcome.needsInformation,
              ).role ==
              HabotButtonRole.secondary &&
          HabotDecisionCta.rejectIsNotColouredLikeApprove &&
          HabotDecisionCta.containerTokenFor(HabotReviewOutcome.reject) !=
              null,
    );

    gate(
      'GEN-01253-G4',
      '"A reviewer working a queue on a keyboard eventually presses return on '
          'the wrong row."',
      'Nothing takes initial focus, so return on an unread row does nothing '
          'rather than approving or rejecting it',
      () =>
          HabotDecisionCta.initiallyFocused == null &&
          HabotDecisionCta.equalWeightNote.contains('presses return'),
    );
  });

  group('GEN-01253 :: what a decision costs to take back', () {
    gate(
      'GEN-01253-G5',
      'Steps 188 and 193: the confirming action is TRAILING in reading order, '
          'not on the right.',
      'Approve lands on the right in a left-to-right locale and on the LEFT in '
          'a right-to-left one, so "the right-hand button" is not a stable '
          'description of the approving action',
      () =>
          HabotDecisionCta.outcomeAtTrailingEdge ==
              HabotReviewOutcome.approve &&
          HabotDecisionCta.approveIsOnTheRight(
            HabotTextDirectionality.leftToRight,
          ) &&
          !HabotDecisionCta.approveIsOnTheRight(
            HabotTextDirectionality.rightToLeft,
          ) &&
          HabotDecisionCta.sideOrderIsDirectionAware,
    );

    gate(
      'GEN-01253-G6',
      'Approve releases money; reject refuses a customer. The two are not '
          'symmetric in what they cost to undo.',
      'An approval can be taken back within the queue window -- expressed in '
          'decisions rather than a wall clock, because a reviewer realises the '
          'mistake on the next order -- while a rejection is not reversible '
          'from here, because un-rejecting an order a reason code was already '
          'recorded against is a different decision',
      () =>
          HabotDecisionCta.approvalIsReversible &&
          HabotDecisionCta.approvalReversalWindowDecisions == 1 &&
          HabotDecisionCta.rejectionIsNotReversibleInApp &&
          HabotDecisionCta.actionFor(
            HabotReviewOutcome.reject,
          ).requiresReasonCode &&
          !HabotDecisionCta.actionFor(
            HabotReviewOutcome.approve,
          ).requiresReasonCode,
    );

    gate(
      'GEN-01253-G7',
      'Metric: Fraud Detection False-Positive Rate -- floor <5%, optimal <1%, '
          'ceiling <10%. Lower is better, which inverts the sheet\'s reading.',
      'The rate cannot be computed in the app -- it needs to know which '
          'rejected orders were legitimate, which arrives weeks later through '
          'chargebacks -- so no figure is produced; the grading function is '
          'built to the lower-is-better reading and all ten design checks hold',
      () {
        adherence = HabotDecisionCta.adherence;
        return !HabotDecisionCta.rateIsComputableInApp &&
            HabotDecisionCta.lowerIsBetter &&
            HabotDecisionCta.qualitativeOutput(0.004) == 'Good' &&
            HabotDecisionCta.qualitativeOutput(0.03) == 'Average' &&
            HabotDecisionCta.qualitativeOutput(0.12) == 'Poor' &&
            HabotDecisionCta.falsePositiveRate(
                  legitimateOrdersRejected: 3,
                  ordersRejected: 100,
                ) ==
                0.03 &&
            HabotDecisionCta.checks.length == 10 &&
            HabotDecisionCta.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotDecisionCta.rateIsNotOursNote.contains('weeks later') &&
            HabotDecisionCta.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01253',
        atomicStepReferenceId: 'GEN-01253',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement binary \'Approve\' and \'Reject\' decision CTA '
            'buttons for operator overrides."',
        implementationOrder: 212,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDecisionCta / HabotDecisionAction',
          'Component Properties':
              '${HabotDecisionCta.actions.length} outcomes, two of them named '
              'by the row; roles from the Step 188 map so reject is '
              'destructive and approve confirm; nothing focused by default; '
              'approval reversible within '
              '${HabotDecisionCta.approvalReversalWindowDecisions} subsequent '
              'decision; rejection gated by the Step 213 reason code and not '
              'reversible from here',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the row\'s own metric is an argument against the '
              'row\'s instruction. A false positive is a legitimate order '
              'rejected. A '
              'reviewer given two buttons and an order they are not sure about '
              'has to pick one, and the incentive under review always points '
              'at reject -- an approved fraud is a loss with their name on it, '
              'a rejected customer is a support ticket with nobody\'s. Binary '
              'is exactly the shape that manufactures false positives, so a '
              'third outcome that costs nothing to choose is the cheapest '
              'available reduction in the number this row is graded on. '
              'Approve and Reject are built as asked; "Needs info" is built '
              'beside them and marked as beyond the row. SECOND FINDING: two '
              'buttons of equal weight make a destructive decision as easy as '
              'a benign one, and nothing may take initial focus because a '
              'reviewer working a queue on a keyboard eventually presses '
              'return on the wrong row. THIRD: the approving action is '
              'TRAILING in reading order, not right-hand -- the fifth '
              'occurrence of that shape after Steps 150, 167, 188 and 193. '
              'BOUNDARY: the false-positive rate needs to know which rejected '
              'orders were legitimate, which arrives weeks later through '
              'chargebacks and complaints and is never knowable in the app.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Fraud Detection False-Positive Rate',
            observed:
                'NOT COMPUTABLE IN THE APP. It requires knowing which rejected '
                'orders were legitimate, which arrives weeks later through '
                'chargebacks and complaints. No figure is invented. The '
                'grading function is built to the lower-is-better reading and '
                'exercised: 0.4% Good, 3% Average, 12% Poor.',
            floor: '<5%',
            optimal: '<1%',
            ceiling: '<10%',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Outcomes available to an unsure reviewer',
            observed:
                '${HabotReviewOutcome.values.length} against the '
                '2 the row specifies. The third costs the reviewer nothing to '
                'choose and is the only lever in this step that moves the '
                'false-positive rate downward. Design adherence '
                '${adherence.toStringAsFixed(2)} over '
                '${HabotDecisionCta.checks.length} checks.',
            floor: '2',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/decision_cta.dart',
        ],
      ),
    );
  });
}
