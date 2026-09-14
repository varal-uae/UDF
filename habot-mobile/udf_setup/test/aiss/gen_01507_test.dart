/// AISS GATE -- Step 202 of 215
/// Global Reference ID:       GEN-01507
/// Atomic Steps Reference ID: GEN-01507
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add a single-tap card interaction allowing parents to assign
///               one or more children to the booking payload."
/// Metric: Special-Requirement Field Capture Accuracy -- Floor 0.95,
///         Optimal 0.999, Ceiling 1. Pass/Fail.
///
/// SINGLE TAP IS SYMMETRIC: the gesture that adds a child is the gesture that
/// removes one. A mis-tap while scrolling four siblings drops a child and
/// changes one outline. The count is always on screen because it is the only
/// part of that change which is legible at a glance.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/booking/child_assignment.dart';
import 'package:udf_setup/design_system/booking/child_profile_card.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  HabotChildProfile child(String id, Set<HabotChildRequirement> done) =>
      HabotChildProfile(
        id: id,
        displayName: 'Child $id',
        completedRequirements: done,
      );

  final HabotChildProfile amal =
      child('amal', HabotChildRequirement.values.toSet());
  final HabotChildProfile bilal =
      child('bilal', HabotChildRequirement.values.toSet());
  final HabotChildProfile cara =
      child('cara', HabotChildRequirement.values.toSet());
  final HabotChildProfile dana = child(
    'dana',
    HabotChildRequirement.values.toSet()
      ..remove(HabotChildRequirement.medication),
  );

  List<HabotChildProfile> family() =>
      <HabotChildProfile>[amal, bilal, cara, dana];

  HabotChildAssignment sheet({
    int capacity = 2,
    Set<String> eligible = const <String>{},
    Set<String> conflicts = const <String>{},
  }) =>
      HabotChildAssignment(
        serviceId: 'svc-1',
        capacity: capacity,
        eligibleIds: eligible,
        conflictingIds: conflicts,
      );

  group('GEN-01507 :: one tap, both directions', () {
    gate(
      'GEN-01507-G1',
      'Atomic Step: "a SINGLE-TAP card interaction allowing parents to assign '
          'ONE OR MORE children."',
      'One tap adds and the same tap removes, the count is available at every '
          'point, and the singular and plural forms of the count are both '
          'written rather than one being left to read as "1 children"',
      () {
        final HabotChildAssignment a = sheet();
        final HabotAssignmentResult first = a.toggle(amal);
        final bool one =
            a.countLabel == '1 child selected' && first.accepted;
        a.toggle(bilal);
        final bool two = a.countLabel == '2 children selected';
        final HabotAssignmentResult removed = a.toggle(amal);
        return one &&
            two &&
            removed.accepted &&
            a.selectedCount == 1 &&
            !a.isSelected(amal.id) &&
            a.isSelected(bilal.id) &&
            a.countLabel == '1 child selected' &&
            HabotChildAssignment.symmetricGestureNote
                .contains('legible at a glance');
      },
    );

    gate(
      'GEN-01507-G2',
      '"Two structures updated separately will disagree, and the one that gets '
          'sent is the one nobody is looking at."',
      'The payload is derived from the selection set at the moment it is '
          'asked for, so a removal is reflected in it without a second update '
          'having to remember to happen',
      () {
        final HabotChildAssignment a = sheet(capacity: 3)
          ..toggle(amal)
          ..toggle(bilal)
          ..toggle(cara);
        final HabotBookingPayload before = a.payload();
        a.toggle(bilal);
        final HabotBookingPayload after = a.payload();
        return before.childIds.length == 3 &&
            after.childIds.length == 2 &&
            !after.childIds.contains(bilal.id) &&
            after.childIds.first == amal.id &&
            after.serviceId == 'svc-1' &&
            after.isValid &&
            HabotChildAssignment.payloadIsDerivedNote
                .contains('nobody is looking at');
      },
    );

    gate(
      'GEN-01507-G3',
      '"Checked at submit instead, the parent is told the booking is invalid '
          'and left to work out which child to drop."',
      'Capacity, age band and a clashing booking each refuse at the tap that '
          'would break them, with a reason naming the child and, for capacity, '
          'the number the session takes',
      () {
        final HabotChildAssignment full = sheet()
          ..toggle(amal)
          ..toggle(bilal);
        final HabotAssignmentResult overflow = full.toggle(cara);
        final HabotAssignmentResult ineligible = sheet(
          eligible: <String>{'amal'},
        ).toggle(bilal);
        final HabotAssignmentResult clash = sheet(
          conflicts: <String>{'cara'},
        ).toggle(cara);
        return !overflow.accepted &&
            overflow.refusal == HabotAssignmentRefusal.capacityReached &&
            overflow.reason.contains('takes 2 children') &&
            !ineligible.accepted &&
            ineligible.refusal == HabotAssignmentRefusal.ageBand &&
            !clash.accepted &&
            clash.refusal ==
                HabotAssignmentRefusal.alreadyBookedElsewhere &&
            HabotAssignmentRefusal.values.length == 3 &&
            full.selectedCount == 2;
      },
    );
  });

  group('GEN-01507 :: what may be sent', () {
    gate(
      'GEN-01507-G4',
      'Atomic Step: "ONE OR MORE children."',
      'An empty selection cannot be submitted and says so in words a parent '
          'can act on, rather than arriving as a refusal after a card has been '
          'entered',
      () {
        final HabotChildAssignment a = sheet();
        return !a.canSubmit(family()) &&
            a.selectedCount == 0 &&
            !a.payload().isValid &&
            a.submitBlockReason(family())
                .contains('at least one child') &&
            HabotChildAssignment.zeroIsRefusableNote.contains('at payment');
      },
    );

    gate(
      'GEN-01507-G5',
      'Step 201 lets an incomplete profile be selected. This step is where '
          '"cannot be sent" actually happens.',
      'A selected child with a missing required field blocks submission and is '
          'named, while the same selection without that child submits',
      () {
        final HabotChildAssignment withDana = sheet()
          ..toggle(amal)
          ..toggle(dana);
        final bool blocked = !withDana.canSubmit(family()) &&
            withDana.blockingProfiles(family()).single.id == dana.id &&
            withDana
                .submitBlockReason(family())
                .contains('Child dana is missing');
        withDana.toggle(dana);
        return blocked && withDana.canSubmit(family());
      },
    );

    gate(
      'GEN-01507-G6',
      'A child\'s name is rendered on a card; a payload is sent to a server.',
      'The payload carries profile ids and the service id and nothing else, so '
          'no child\'s name leaves the device through this path',
      () {
        final HabotChildAssignment a = sheet()..toggle(amal);
        final Map<String, Object?> json = a.payload().toJson();
        return json.keys.length == 2 &&
            json.containsKey('serviceId') &&
            json.containsKey('childIds') &&
            (json['childIds']! as List<String>).single == amal.id &&
            !json.toString().contains(amal.displayName) &&
            HabotChildAssignment.idsNotNamesNote.contains('profile ids');
      },
    );

    gate(
      'GEN-01507-G7',
      'Metric: Special-Requirement Field Capture Accuracy -- floor 0.95.',
      'Accuracy is computed over the children actually being sent rather than '
          'over every registered profile: selecting the two complete siblings '
          'gives 1.0, and adding the incomplete one drops it to 0.944, below '
          'the floor -- so the number moves with what is being booked',
      () {
        final HabotChildAssignment clean = sheet()
          ..toggle(amal)
          ..toggle(bilal);
        accuracy = clean.captureAccuracyForSelection(family());
        final HabotChildAssignment dirty = sheet(capacity: 3)
          ..toggle(amal)
          ..toggle(bilal)
          ..toggle(dana);
        final double withMissing =
            dirty.captureAccuracyForSelection(family());
        return accuracy == 1.0 &&
            (withMissing - 17 / 18).abs() < 1e-9 &&
            withMissing < HabotChildAssignment.floor &&
            HabotChildAssignment.qualitativeOutput(accuracy) == 'Pass' &&
            HabotChildAssignment.qualitativeOutput(withMissing) == 'Fail' &&
            HabotChildAssignment.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01507',
        atomicStepReferenceId: 'GEN-01507',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Add a single-tap card interaction allowing parents to '
            'assign one or more children to the booking payload."',
        implementationOrder: 202,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotChildAssignment / HabotBookingPayload',
          'Component Properties':
              'Insertion-ordered selection set with the payload derived from '
              'it; ${HabotAssignmentRefusal.values.length} refusal reasons '
              'evaluated at the tap; selected count always available in '
              'singular and plural; submit gated on a non-empty selection and '
              'on every selected profile being complete',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: single tap is symmetric -- the gesture that adds a '
              'child is the gesture that removes one. A mis-tap while '
              'scrolling past four siblings drops a child from the booking and '
              'changes one outline, which is not legible at a glance. The '
              'selected count is therefore always on screen. SECOND: the '
              'payload is derived from the selection set rather than '
              'maintained beside it; two structures updated separately '
              'disagree and the one that gets sent is the one nobody is '
              'looking at. THIRD: capacity, age band and clashing bookings are '
              'refused at the tap that would break them, with a reason. '
              'Checked at submit instead, the parent is told the booking is '
              'invalid and left to work out which child to drop. The metric is '
              'computed over the children being SENT rather than over every '
              'registered profile, which is the population the metric is '
              'actually about.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Special-Requirement Field Capture Accuracy '
                '(over the selection)',
            observed:
                '${accuracy.toStringAsFixed(2)} for a selection of two '
                'complete profiles; 0.9444 when a profile missing one required '
                'field is added, which is below the 0.95 floor and reports '
                'Fail. The figure moves with what is being booked rather than '
                'with what is registered.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Refusals evaluated before the payload is built',
            observed:
                '${HabotAssignmentRefusal.values.length} -- capacity, age '
                'band and an overlapping booking, each refused at the tap with '
                'a reason naming the child. Zero of them are deferred to '
                'submit.',
            floor: '3',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/booking/child_assignment.dart',
        ],
      ),
    );
  });
}
