/// AISS GATE -- Step 214 of 215
/// Global Reference ID:       GEN-01308
/// Atomic Steps Reference ID: GEN-01308
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Embed M3 Filled Buttons for final dispute submission."
/// Metric: Dispute Resolution Cycle Time -- Floor <5 business days,
///         Optimal <48 hours, Ceiling <10 business days. Good/Average/Poor.
///
/// THE METRIC MEASURES SOMETHING THAT HAPPENS AFTER THE APP STOPS. What the
/// client changes is the one thing that reliably lengthens a cycle: an intake
/// that arrives incomplete, so the agent's first action is to write back and
/// ask -- a round trip measured in days on either side of a weekend.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/dispute_submission.dart';
import 'package:udf_setup/design_system/tokens/button_role_map.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  HabotDisputeDraft complete() => const HabotDisputeDraft(
        kind: HabotDisputeKind.amountIncorrect,
        bookingReference: 'BK-4471',
        providedFields: <String>{
          'bookingReference',
          'chargeDate',
          'expectedAmount',
          'contactPreference',
        },
      );

  /// A second draft describing the same dispute, built separately.
  HabotDisputeDraft sameAgain() => const HabotDisputeDraft(
        kind: HabotDisputeKind.amountIncorrect,
        bookingReference: 'BK-4471',
        providedFields: <String>{
          'bookingReference',
          'chargeDate',
          'expectedAmount',
          'contactPreference',
        },
        evidenceCount: 2,
      );

  HabotDisputeDraft partial() => const HabotDisputeDraft(
        kind: HabotDisputeKind.unauthorised,
        bookingReference: 'BK-4471',
        providedFields: <String>{'chargeDate'},
      );

  group('GEN-01308 :: the intake is the lever', () {
    gate(
      'GEN-01308-G1',
      'Metric: DISPUTE RESOLUTION CYCLE TIME, on a row that asks for a button.',
      'Required fields differ by dispute kind rather than being one form for '
          'everything, and every one records why an agent needs it -- so a '
          'field cannot be dropped for being tedious without someone reading '
          'what dropping it costs',
      () =>
          HabotDisputeSubmission.fields.length == 5 &&
          HabotDisputeSubmission.fields.every(
            (HabotDisputeField f) => f.whyItShortensTheCycle.isNotEmpty,
          ) &&
          HabotDisputeSubmission.requiredFieldsFor(
                HabotDisputeKind.amountIncorrect,
              ).length ==
              4 &&
          HabotDisputeSubmission.requiredFieldsFor(
                HabotDisputeKind.unauthorised,
              ).length ==
              3 &&
          HabotDisputeKind.values.length == 4 &&
          HabotDisputeSubmission.cycleTimeIsNotOursNote
              .contains('write back and ask'),
    );

    gate(
      'GEN-01308-G2',
      '"An incomplete intake is what makes the cycle long."',
      'A complete draft submits at 1.0 and an incomplete one is refused with '
          'the missing fields named, so the parent fixes it now rather than in '
          'two days through an agent',
      () {
        completeness =
            HabotDisputeSubmission.intakeCompleteness(complete());
        final double partialRate =
            HabotDisputeSubmission.intakeCompleteness(partial());
        return completeness == 1.0 &&
            HabotDisputeSubmission.isSubmittable(complete()) &&
            !HabotDisputeSubmission.isSubmittable(partial()) &&
            (partialRate - 1 / 3).abs() < 1e-9 &&
            HabotDisputeSubmission.missingFrom(partial()).length == 2 &&
            HabotDisputeSubmission.missingFrom(partial())
                .contains('description') &&
            HabotDisputeSubmission.missingFrom(partial())
                .contains('contactPreference');
      },
    );

    gate(
      'GEN-01308-G3',
      'Atomic Step: "M3 FILLED Buttons for FINAL dispute submission."',
      'The filled button is the right emphasis and it takes the confirm role '
          'from Step 188 rather than a bare filled style -- and a summary '
          'stands in front of it, because a parent cannot withdraw a case from '
          'here once it is open',
      () =>
          HabotDisputeSubmission.role == HabotButtonRole.confirm &&
          HabotDisputeSubmission.containerToken ==
              HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm) &&
          HabotDisputeSubmission.containerToken != null &&
          HabotDisputeSubmission.requiresReviewStep &&
          HabotDisputeSubmission.reviewStepNote
              .contains('emphasis is not a safeguard'),
    );

    gate(
      'GEN-01308-G4',
      '"A dispute submitted twice is two cases on one transaction."',
      'The idempotency key comes from the booking and the dispute kind rather '
          'than from the moment of pressing, so two separately built drafts of '
          'the same dispute produce the same key while a different kind on the '
          'same booking produces a different one',
      () =>
          HabotDisputeSubmission.keyIsStableAcross(
            complete(),
            sameAgain(),
          ) &&
          HabotDisputeSubmission.idempotencyKeyFor(complete()) ==
              'dispute:BK-4471:amountIncorrect' &&
          HabotDisputeSubmission.keySeparatesDifferentDisputes(
            complete(),
            partial(),
          ) &&
          HabotDisputeSubmission.idempotencyKeyFor(partial()) !=
              HabotDisputeSubmission.idempotencyKeyFor(complete()) &&
          HabotDisputeSubmission.dispatcherIsTheDeclaredOne &&
          HabotDisputeSubmission.submitOnceNote
              .contains('experiences it as being ignored'),
    );
  });

  group('GEN-01308 :: what the parent is told, and in what units', () {
    gate(
      'GEN-01308-G5',
      '"A parent who believes a dispute is filed stops chasing it."',
      'Queued and filed are different words, and the queued message says in '
          'plain terms that the dispute has not reached anyone yet',
      () =>
          HabotDisputeSubmission.queuedAndFiledAreDifferentWords &&
          HabotDisputeSubmission.confirmationFor(reachedServer: false)
              .contains('has not reached us yet') &&
          HabotDisputeSubmission.confirmationFor(reachedServer: true)
              .startsWith('Sent.') &&
          HabotDisputeSubmission.confirmationFor(reachedServer: false) !=
              HabotDisputeSubmission.confirmationFor(reachedServer: true),
    );

    gate(
      'GEN-01308-G6',
      'Metric bounds: "<5 business days" and "<10 business days". A Duration '
          'cannot hold a business day.',
      'Only the 48-hour optimal is expressed as a duration, held as a motion '
          'token; the other two are kept as a count of business days with the '
          'calendar left to whoever owns the calendar, and the reason is '
          'recorded rather than quietly converted to 120 hours',
      () =>
          HabotDisputeSubmission.optimalCycle ==
              HabotMotion.disputeCycleOptimal &&
          HabotDisputeSubmission.optimalCycle.inHours == 48 &&
          HabotDisputeSubmission.floorBusinessDays == 5 &&
          HabotDisputeSubmission.ceilingBusinessDays == 10 &&
          HabotDisputeSubmission.businessDayNote
              .contains('a different promise') &&
          HabotDisputeSubmission.businessDayNote
              .contains('not the same two days'),
    );

    gate(
      'GEN-01308-G7',
      'The ceiling is the WORST tolerated value here, as at Steps 199 and 212.',
      'One business day grades Good, four Average and eleven Poor, and all '
          'nine structural checks hold on the worked drafts -- while the cycle '
          'time itself is left to the operation rather than being invented '
          'from an intake form',
      () =>
          HabotDisputeSubmission.ceilingIsTheWorstBound &&
          HabotDisputeSubmission.qualitativeOutputForBusinessDays(1) ==
              'Good' &&
          HabotDisputeSubmission.qualitativeOutputForBusinessDays(4) ==
              'Average' &&
          HabotDisputeSubmission.qualitativeOutputForBusinessDays(11) ==
              'Poor' &&
          HabotDisputeSubmission.checksFor(complete(), partial()).length ==
              9 &&
          HabotDisputeSubmission.checksFor(complete(), partial())
              .values
              .every((bool b) => b) &&
          HabotDisputeSubmission.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01308',
        atomicStepReferenceId: 'GEN-01308',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Embed M3 Filled Buttons for final dispute submission."',
        implementationOrder: 214,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDisputeSubmission / HabotDisputeDraft',
          'Component Properties':
              '${HabotDisputeSubmission.fields.length} intake fields across '
              '${HabotDisputeKind.values.length} dispute kinds, each field '
              'carrying why an agent needs it; submit action on the Step 188 '
              'confirm role behind a summary; idempotency key derived from the '
              'booking and the kind; queued and filed distinguished in the '
              'confirmation text',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: dispute resolution cycle time is agents, '
              'queues and a decision this app is not party to, and no build of '
              'this client changes it directly. What the client does change is '
              'the one thing that reliably lengthens a cycle -- an intake that '
              'arrives incomplete, so the agent\'s first action is to write '
              'back and ask, which is a round trip measured in days on either '
              'side of a weekend. Intake completeness is built and reported '
              'instead, with the substitution stated rather than a cycle-time '
              'figure invented. FINDING: the floor and ceiling are in BUSINESS '
              'DAYS and a Duration cannot hold one. Five business days is '
              'between seven and nine calendar days depending on when it '
              'starts, and the weekend is not the same two days for every '
              'counterparty in this market; a Duration of 120 hours is a '
              'different promise from the one the row makes. Only the 48-hour '
              'optimal is a duration. SECOND FINDING: "final submission" has '
              'to happen once -- a dispute submitted twice is two cases on one '
              'transaction, which an agent resolves by closing one and the '
              'parent experiences as being ignored. The key comes from the '
              'booking and the kind, not the tap. THIRD: a dispute filed '
              'offline is QUEUED, not filed, and the confirmation says so, '
              'because a parent who believes it is filed stops chasing it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dispute Resolution Cycle Time',
            observed:
                'NOT PRODUCIBLE IN THE APP -- measured after the client stops '
                'being involved. The grading function is built to the '
                'lower-is-better reading and exercised: 1 business day Good, 4 '
                'Average, 11 Poor. The floor and ceiling are business-day '
                'counts rather than durations.',
            floor: '<5 business days',
            optimal: '<48 hours',
            ceiling: '<10 business days',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Intake completeness (what the client controls)',
            observed:
                '${completeness.toStringAsFixed(2)} for a complete draft, '
                '0.3333 for one missing two of three required fields -- '
                'refused at submission with the missing fields named, so the '
                'parent fixes it now rather than in two days through an agent.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/dispute_submission.dart',
        ],
      ),
    );
  });
}
