/// AISS GATE -- Step 77 of 80
/// Global Reference ID:       GEN-03017
/// Atomic Steps Reference ID: GEN-03017
/// Setup Step (Action):       "Deliver approval requests as mobile push
///                             notifications with 1-tap Approve action on lock
///                             screens."
/// Metric: Mobile Usability Task Success Rate (%) -- Floor 80.0, Optimal 95.0,
///         Ceiling 100.0. Standard: "Nielsen Norman Group Mobile UX Heuristics
///         / ISO 9241-11".
///
/// METRIC NOT PRODUCED, RECORDED. Task Success Rate is obtained by giving a
/// task to a sample of people and counting who completes it. No test suite
/// produces that number, and inventing one would be the worst kind of green.
/// What IS measured is what the step names and what a usability study of it
/// would actually be testing: that the decision takes ONE action, that the
/// action is authoritative, and that a second tap cannot record a second
/// decision.
///
/// A GENERATED ROW, RECORDED: Setup Step and Setup Step Description are the
/// same sentence; Why This Matters is that sentence plus "is a critical
/// implementation step"; Expected Output is "Fully configured and validated
/// implementation of:" plus the sentence again; the substeps are the generic
/// four; and Completion Measures is "100% CI/CD pass rate ... committed to
/// runbook", which is project tracking. The Mobile Implication ("sub-100ms API
/// response latencies") and the Material Design columns ("M3 Elevated Cards
/// Level 2 (3dp)", "Background polling refreshes data every 30 seconds") are
/// boilerplate shared with every other GEN-* row in the sheet and describe a
/// dashboard, not a lock screen. None of that is gated.
///
/// WHAT SURVIVES is the sentence itself, and it is a real requirement with a
/// real failure mode: two people approving the same request, or one person
/// approving twice because the first tap gave no answer. Both are races, and
/// both are handled the way Step 66 handles the dispatch race -- the control
/// asks whether it may act instead of being told to disable itself.
///
/// THE LOCK SCREEN IS NOT THE APP. What a client can own is the label the
/// system draws, the single action, and what happens when it is tapped. That
/// the OS renders it is a platform fact, not a claim this suite can make -- so
/// G1 gates the label and the action count, not the rendering.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/deep_link_context_manager.dart';
import 'package:udf_setup/design_system/navigation/route_table.dart';
import 'package:udf_setup/design_system/notifications/delivery_router.dart';
import 'package:udf_setup/design_system/notifications/message_receiver.dart';
import 'package:udf_setup/design_system/notifications/notification_center.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';

import 'aiss_reporter.dart';

const List<HabotRoute> _routes = <HabotRoute>[
  HabotRoute(path: '/approvals/:id', title: 'Approval', requiresId: true),
  HabotRoute(path: '/tasks', title: 'Tasks'),
];

const HabotRoute _fallback = HabotRoute(path: '/', title: 'Home');

HabotParsedMessage _approval(String id) => HabotParsedMessage(
  id: id,
  kind: HabotNotificationKind.approval,
  title: 'Batch 42 needs sign-off',
  body: 'Submitted by Amina, 12 items, R84,200.',
  route: '/approvals/$id',
  source: HabotMessageSource.foreground,
  receivedAt: DateTime(2026, 8, 14, 9),
  data: const <String, String>{},
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int decisionsRecorded = -1;
  int senderCalls = -1;

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

  HabotDeliveryRouter buildRouter(
    HabotApprovalSender sender, {
    HabotNotificationCenter? centre,
  }) => HabotDeliveryRouter(
    router: HabotRouter(routes: _routes, fallback: _fallback),
    centre: centre ?? HabotNotificationCenter(),
    contextManager: DeepLinkContextManager(),
    approvalSender: sender,
  );

  group('GEN-03017 :: one action', () {
    gate(
      'GEN-03017-G1',
      'Setup Step (Action): "1-TAP Approve action ON LOCK SCREENS." A lock '
          'screen shows a line of text and offers an action; it cannot show a '
          'form.',
      'The request carries a single line that says what is being approved and '
          'exactly one affirmative action label, so the decision needs no '
          'second screen to make sense',
      () {
        final HabotDeliveryRouter router = buildRouter(
          (String id, HabotApprovalDecision d) async =>
              HabotApprovalOutcome.recorded,
        );
        addTearDown(router.dispose);
        router.route(_approval('r1'));
        final HabotApprovalRequest? request = router.pendingApproval;
        if (request == null) {
          return false;
        }
        return request.approveLabel == 'Approve' &&
            request.rejectLabel != request.approveLabel &&
            request.lockScreenLabel.contains(request.subject) &&
            request.lockScreenLabel.contains(request.detail) &&
            request.route == '/approvals/r1';
      },
    );

    test('[GEN-03017-G2] the tap is authoritative, and a second tap cannot '
        'record a second decision', () async {
      int calls = 0;
      final HabotNotificationCenter centre = HabotNotificationCenter();
      addTearDown(centre.dispose);
      final HabotDeliveryRouter router = buildRouter(
        (String id, HabotApprovalDecision decision) async {
          calls++;
          return HabotApprovalOutcome.recorded;
        },
        centre: centre,
      );
      addTearDown(router.dispose);

      router.route(_approval('r1'));
      expect(router.canDecide('r1'), isTrue);
      expect(centre.unreadCount, 1, reason: 'stored while it is outstanding');

      final HabotApprovalOutcome first = await router.decide(
        'r1',
        HabotApprovalDecision.approved,
      );
      expect(first, HabotApprovalOutcome.recorded);
      expect(router.canDecide('r1'), isFalse);
      expect(router.pendingApproval, isNull);
      expect(centre.unreadCount, 0, reason: 'answering it reads it');

      // The second tap. It reaches the router and is refused there -- the
      // backend is never asked twice.
      final HabotApprovalOutcome second = await router.decide(
        'r1',
        HabotApprovalDecision.approved,
      );
      expect(second, HabotApprovalOutcome.alreadyResolved);
      senderCalls = calls;
      expect(calls, 1, reason: 'one decision, one send');
      decisionsRecorded = 1;

      gates.add(
        AissGate(
          id: 'GEN-03017-G2',
          requirementSource:
              'Setup Step (Action): "1-tap APPROVE" -- and the race that '
              'follows from delivering the same request to a phone, a watch '
              'and a desktop at once. Handled the way GEN-00692 (Step 66) '
              'handles the dispatch race.',
          description:
              'The first decision is recorded and closes the request; the '
              'second is refused by the client before it reaches the backend, '
              'and the outcome returned says which happened',
          passed: true,
          detail: '2 taps, $senderCalls send, $decisionsRecorded decision',
        ),
      );
    });

    test('[GEN-03017-G3] when someone else got there first, the user is told '
        'that -- not told it worked', () async {
      final HabotDeliveryRouter router = buildRouter(
        (String id, HabotApprovalDecision d) async =>
            HabotApprovalOutcome.alreadyResolved,
      );
      addTearDown(router.dispose);
      router.route(_approval('r2'));

      final HabotApprovalOutcome outcome = await router.decide(
        'r2',
        HabotApprovalDecision.approved,
      );
      expect(
        outcome,
        HabotApprovalOutcome.alreadyResolved,
        reason: 'the backend outcome is passed through, not overwritten',
      );
      expect(
        router.canDecide('r2'),
        isFalse,
        reason: 'and the request closes either way -- it is resolved',
      );

      gates.add(
        const AissGate(
          id: 'GEN-03017-G3',
          requirementSource:
              'Setup Step (Action) read honestly: an approval delivered to '
              'several devices can be answered on any of them.',
          description:
              'A request already resolved elsewhere returns alreadyResolved to '
              'the tapping user rather than a false success, and the request '
              'still closes',
          passed: true,
        ),
      );
    });

    test('[GEN-03017-G4] a failed send does not close the request', () async {
      final HabotDeliveryRouter router = buildRouter(
        (String id, HabotApprovalDecision d) async =>
            HabotApprovalOutcome.failed,
      );
      addTearDown(router.dispose);
      router.route(_approval('r3'));

      final HabotApprovalOutcome outcome = await router.decide(
        'r3',
        HabotApprovalDecision.approved,
      );
      expect(outcome, HabotApprovalOutcome.failed);
      expect(
        router.canDecide('r3'),
        isTrue,
        reason:
            'a decision that never left the device has not been taken; the '
            'user must be able to tap again',
      );
      expect(router.pendingApproval?.id, 'r3');

      gates.add(
        const AissGate(
          id: 'GEN-03017-G4',
          requirementSource:
              'Setup Step (Action): the approval must actually be DELIVERED. '
              'A one-tap action that silently fails is worse than none.',
          description:
              'A failed send leaves the request open and re-tappable, and the '
              'client records no decision it did not manage to send',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03017',
        atomicStepReferenceId: 'GEN-03017-A01',
        setupStepAction:
            'Deliver approval requests as mobile push notifications with '
            '1-tap Approve action on lock screens.',
        implementationOrder: 77,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Deliver approval requests as mobile push notifications with 1-tap '
                  'Approve':
              'One action per request, one send per decision, and the '
              'authoritative outcome returned to the caller: recorded / '
              'alreadyResolved / failed.',
          'Component Name': 'HabotDeliveryRouter.decide / HabotApprovalRequest',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC NOT PRODUCED -- "Mobile Usability Task Success Rate" is '
              'a usability-study measure obtained by watching people attempt '
              'tasks. No number invented in its place. GENERATED ROW -- Setup '
              'Step and Description are the same sentence; Why This Matters, '
              'Expected Output and the four substeps are template prose built '
              'from it; Completion Measures is CI/CD tracking; the Mobile '
              'Implication and Material Design columns are boilerplate shared '
              'across every GEN-* row and describe a dashboard rather than a '
              'lock screen. None gated. PLATFORM SCOPE RECORDED: that the OS '
              'renders the action on a locked device is a platform fact; this '
              'suite gates the label, the single action and the race.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Task Success Rate (%)',
            observed:
                'NOT PRODUCED -- this is a measure of people, obtained by '
                'giving a task to a sample and counting completions. No suite '
                'produces it. What was measured instead: the decision takes '
                'one action, one tap produces exactly one send, and a second '
                'tap is refused before it reaches the backend.',
            floor: '80.0',
            optimal: '95.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/delivery_router.dart',
        ],
      ),
    );
  });
}
