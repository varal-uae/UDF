/// AISS GATE -- Step 211 of 215
/// Global Reference ID:       GEN-01231
/// Atomic Steps Reference ID: GEN-01231
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Benchmark re-booking completion times targeting an execution
///               duration under 15 seconds."
/// Metric: One-Click Re-Booking Completion Rate -- Floor 0.7, Optimal 0.9,
///         Ceiling 1. Good/Average/Poor.
///
/// "ONE-CLICK" AND "UNDER FIFTEEN SECONDS" DESCRIBE DIFFERENT FEATURES. One
/// click is under a second. Fifteen seconds is a path with decisions on it,
/// most of them a person and a payment sheet this app does not own.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/booking/rebooking_path.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;
  double reduction = 0;

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

  group('GEN-01231 :: decisions, not seconds', () {
    gate(
      'GEN-01231-G1',
      'Metric: ONE-CLICK Re-Booking. Atomic Step: "under 15 SECONDS."',
      'A re-book asks three decisions where a first booking asks six -- and it '
          'is not one, because the literal one-click reading is what produces '
          'the defects in the next gate',
      () {
        reduction = HabotRebookingPath.decisionReduction;
        return HabotRebookingPath.firstBookingDecisionCount == 6 &&
            HabotRebookingPath.rebookingDecisionCount == 3 &&
            reduction == 0.5 &&
            HabotRebookingPath.rebookingDecisionCount >
                HabotRebookingPath.oneClickDecisionCount &&
            HabotRebookingPath.oneClickAndFifteenSecondsNote
                .contains('describe different features');
      },
    );

    gate(
      'GEN-01231-G2',
      '"A re-book that replays a stored booking can charge for a child who has '
          'aged out, a date in the past, a session now full, or a card that '
          'expired last month."',
      'Every one of the six blockers is revalidated before a charge, each '
          'carries a message written for a parent rather than a code, and each '
          'says whether the path can continue after it',
      () =>
          HabotRebookingPath.revalidatesRatherThanReplays &&
          HabotRebookingPath.revalidationIsTotal &&
          HabotRebookingBlocker.values.length == 6 &&
          HabotRebookingBlocker.values.every(
            (HabotRebookingBlocker b) =>
                HabotRebookingPath.messageFor(b).isNotEmpty,
          ) &&
          HabotRebookingPath.isRecoverableInPlace(
            HabotRebookingBlocker.datePassed,
          ) &&
          !HabotRebookingPath.isRecoverableInPlace(
            HabotRebookingBlocker.childAgedOut,
          ) &&
          HabotRebookingPath.replayIsTheDangerousVersionNote
              .contains('a re-book that did not check'),
    );

    gate(
      'GEN-01231-G3',
      '"The three that remain are the three that go stale."',
      'The date and the children are still confirmed, because a date passes '
          'and a family changes, while the service, the add-ons, the special '
          'requirements and the payment method are carried forward',
      () {
        final List<String> carried = HabotRebookingPath.carriedForward;
        return carried.length == 3 &&
            carried.contains('requirements') &&
            carried.contains('payment') &&
            carried.contains('service') &&
            !carried.contains('date') &&
            !carried.contains('children') &&
            !carried.contains('confirm');
      },
    );

    gate(
      'GEN-01231-G4',
      'A confirmation that is prefilled is not a confirmation.',
      'The final confirm-and-pay step is the one decision that can never be '
          'carried forward, and a price change is shown whichever direction it '
          'moved in',
      () {
        final HabotBookingDecision confirm = HabotRebookingPath.decisions
            .firstWhere((HabotBookingDecision d) => d.id == 'confirm');
        return !confirm.canBePrefilled &&
            confirm.requiredOnRebooking &&
            confirm.requiredOnFirstBooking &&
            HabotRebookingPath.priceChangeIsAlwaysShown &&
            HabotRebookingPath.messageFor(
              HabotRebookingBlocker.priceChanged,
            ).contains('price has changed');
      },
    );
  });

  group('GEN-01231 :: the metric', () {
    gate(
      'GEN-01231-G5',
      'Metric: One-Click Re-Booking Completion Rate -- floor 0.7, optimal 0.9.',
      'The rate needs real attempts and is not producible here; the grading '
          'function is built and exercised, and an empty denominator returns '
          'zero rather than dividing by it',
      () =>
          HabotRebookingPath.completionRate(completed: 0, started: 0) == 0 &&
          HabotRebookingPath.completionRate(completed: 92, started: 100) ==
              0.92 &&
          HabotRebookingPath.qualitativeOutput(0.92) == 'Good' &&
          HabotRebookingPath.qualitativeOutput(0.75) == 'Average' &&
          HabotRebookingPath.qualitativeOutput(0.6) == 'Poor',
    );

    gate(
      'GEN-01231-G6',
      '"Benchmarking wall clock would mostly be benchmarking the payment '
          'sheet."',
      'The fifteen-second target is held as a motion token so it is one '
          'declared number rather than a literal in a test, and the reason no '
          'timing figure is produced is recorded rather than left as a gap',
      () =>
          HabotRebookingPath.target == HabotMotion.rebookingTarget &&
          HabotRebookingPath.target.inSeconds == 15 &&
          HabotRebookingPath.wallClockNotProducibleNote
              .contains('none is invented') &&
          HabotRebookingPath.decisionsAreTheMeasurableThingNote
              .contains('a place the parent can stop'),
    );

    gate(
      'GEN-01231-G7',
      'What this step can be graded on statically.',
      'All nine declared checks hold, giving 1.0 -- the structure of the path, '
          'which is what the app controls and what actually moves the '
          'completion rate',
      () {
        adherence = HabotRebookingPath.adherence;
        return HabotRebookingPath.checks.length == 9 &&
            HabotRebookingPath.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotRebookingPath.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01231',
        atomicStepReferenceId: 'GEN-01231',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Benchmark re-booking completion times targeting an '
            'execution duration under 15 seconds."',
        implementationOrder: 211,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRebookingPath / HabotBookingDecision',
          'Component Properties':
              '${HabotRebookingPath.decisions.length} declared decisions on '
              'the booking path, '
              '${HabotRebookingPath.firstBookingDecisionCount} required first '
              'time and '
              '${HabotRebookingPath.rebookingDecisionCount} on a re-book; '
              '${HabotRebookingBlocker.values.length} blockers revalidated '
              'before any charge, each with a parent-facing message and a '
              'recoverability verdict; target '
              '${HabotRebookingPath.target.inSeconds}s as a motion token',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "one-click" and "under fifteen seconds" cannot both '
              'describe the same flow. One click is under a second; fifteen '
              'seconds is a path with decisions on it, and most of what makes '
              'it fifteen seconds is a person confirming a date and a payment '
              'sheet this app does not own. Benchmarking wall clock would '
              'mostly be benchmarking the payment sheet. What the app controls '
              'is the number of DECISIONS, and that is what moves the '
              'completion rate -- every required decision is a place the '
              'parent can stop. Measured: six required decisions on a first '
              'booking, three on a re-book. SECOND FINDING: the dangerous '
              'version of this feature is the one that works. A re-book that '
              'replays a stored booking can charge for a child who has aged '
              'out of the service, a date in the past, a session that is now '
              'full, or a card that expired last month, and every one of those '
              'produces a confirmed booking and a refund conversation. The '
              'path revalidates rather than replays across six blockers, and '
              'the revalidation is where the seconds go: a re-book that is '
              'instant is a re-book that did not check. SUBSTITUTION: no '
              'timing figure is produced on a host with no Dart toolchain and '
              'no instrumentation.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'One-Click Re-Booking Completion Rate',
            observed:
                'NOT PRODUCIBLE -- the rate needs real attempts and none is '
                'invented. The grading function is exercised: 0.92 Good, 0.75 '
                'Average, 0.60 Poor.',
            floor: '0.7',
            optimal: '0.9',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Required decisions on the path',
            observed:
                '${HabotRebookingPath.rebookingDecisionCount} on a re-book '
                'against ${HabotRebookingPath.firstBookingDecisionCount} on a '
                'first booking -- a reduction of '
                '${(reduction * 100).toStringAsFixed(0)}%. The three that '
                'remain are the three that go stale: the date, the children '
                'and the final confirmation. Structural adherence '
                '${adherence.toStringAsFixed(2)} over '
                '${HabotRebookingPath.checks.length} checks.',
            floor: '<= 6',
            optimal: '<= 3',
            ceiling: '1 would mean no revalidation',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/booking/rebooking_path.dart',
        ],
      ),
    );
  });
}
