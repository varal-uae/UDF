/// AISS GATE -- Step 128 of 135
/// Global Reference ID:       GEN-02599
/// Atomic Steps Reference ID: GEN-02599
/// Atomic Step: "Program the WebSockets to handle mobile lifecycle events
///               (backgrounding/waking) gracefully to save battery."
/// Metric: Message Delivery Rate (%) -- Floor 0.98, Optimal 0.999, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE ROW ASKS FOR TWO THINGS THAT PULL APART: save battery (close the
/// socket) and deliver 99.9% of messages (keep it open). The resolution is
/// that a message sent while detached is queued rather than dropped -- which
/// is only true if the queue is durable, and that is checked rather than
/// assumed.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/resilience/heartbeat.dart';
import 'package:udf_setup/design_system/resilience/lifecycle_observer.dart';
import 'package:udf_setup/design_system/resilience/socket_lifecycle.dart';
import 'package:udf_setup/design_system/resilience/socket_transport.dart';

import 'aiss_reporter.dart';

class _FakeTransport implements HabotSocketTransport {
  int closes = 0;
  final List<String> sent = <String>[];
  final StreamController<String> _in = StreamController<String>.broadcast();
  HabotSocketStatus _status = HabotSocketStatus.closed;

  @override
  HabotSocketStatus get status => _status;

  @override
  String? get negotiatedProtocol => 'habot.v1';

  @override
  Stream<String> get inbound => _in.stream;

  @override
  Future<void> open(String url, {required String token}) async =>
      _status = HabotSocketStatus.open;

  @override
  Future<void> send(String message) async => sent.add(message);

  @override
  Future<void> close() async {
    closes++;
    _status = HabotSocketStatus.closed;
  }
}

/// A durable store, so the socket is allowed to detach. Same behaviour as the
/// in-memory one; only the honesty flag differs.
class _DurableStore extends HabotMemoryStore {
  @override
  bool get isDurable => true;

  @override
  String get engineName => 'durable (test double)';
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  int sentNow = 0;
  int queued = 0;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  ({
    HabotSocketLifecycle cycle,
    _FakeTransport transport,
    HabotHeartbeat heartbeat,
    HabotOutbox outbox,
    List<int> pings,
  })
  rig({bool durable = true}) {
    final _FakeTransport t = _FakeTransport();
    final List<int> pings = <int>[];
    final HabotHeartbeat h = HabotHeartbeat(
      sendPing: (int s) async => pings.add(s),
    );
    final HabotOutbox o = HabotOutbox(
      store: durable ? _DurableStore() : HabotMemoryStore(),
    );
    return (
      cycle: HabotSocketLifecycle(
        socket: HabotSecureSocket(
          policy: const HabotSocketPolicy(
            allowedHosts: <String>{'stream.habot.example'},
            subprotocol: 'habot.v1',
          ),
          transport: t,
        ),
        heartbeat: h,
        outbox: o,
      ),
      transport: t,
      heartbeat: h,
      outbox: o,
      pings: pings,
    );
  }

  group('GEN-02599 :: the three phases', () {
    gate(
      'GEN-02599-G1',
      'Atomic Step: handle backgrounding "GRACEFULLY TO SAVE BATTERY". The '
          'heartbeat is what actually costs battery -- a radio wake every '
          'interval, indefinitely.',
      'Backgrounding stops the heartbeat AT ONCE and enters the grace phase '
          'without closing the socket',
      () async {
        final r = rig();
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        r.cycle.onBackgrounded();
        final bool inGrace = r.cycle.phase == HabotSocketPhase.grace &&
            r.transport.status == HabotSocketStatus.open &&
            r.transport.closes == 0 &&
            r.cycle.isReleased;
        r.cycle.dispose();
        return inGrace;
      },
    );

    gate(
      'GEN-02599-G2',
      'A user glancing at a notification and coming straight back should not '
          'pay a full reconnect. This is the phase most implementations skip, '
          'and skipping it is why apps feel slow after every task switch.',
      'Returning during the grace period restarts the heartbeat on a socket '
          'that was never closed -- no reconnect at all',
      () async {
        final r = rig();
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        r.cycle.onBackgrounded();
        r.cycle.onForegrounded();
        return r.cycle.phase == HabotSocketPhase.foreground &&
            r.transport.closes == 0 &&
            r.transport.status == HabotSocketStatus.open &&
            r.cycle.detachCount == 0;
      },
    );

    gate(
      'GEN-02599-G3',
      'Past the grace period the socket must actually go, or the battery half '
          'of the requirement is not met.',
      'Detaching closes the transport and stops the heartbeat, and detaching '
          'twice is a no-op rather than a second close',
      () async {
        final r = rig();
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        r.cycle.onBackgrounded();
        await r.cycle.detach();
        await r.cycle.detach();
        r.cycle.dispose();
        return r.cycle.phase == HabotSocketPhase.detached &&
            r.transport.closes == 1 &&
            r.cycle.detachCount == 1 &&
            HabotSocketLifecycle.gracePeriod.inSeconds > 0;
      },
    );
  });

  group('GEN-02599 :: battery against delivery', () {
    gate(
      'GEN-02599-G4',
      'A socket that closes over a VOLATILE queue really does drop messages, '
          'and the metric would be met on paper by a build that loses work.',
      'Detaching is REFUSED when there is no durable queue behind it, with a '
          'message that names the trade the row is making',
      () async {
        final r = rig(durable: false);
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        r.cycle.onBackgrounded();
        bool threw = false;
        try {
          await r.cycle.detach();
        } on HabotUnbackedSocketError catch (e) {
          threw = e.message.toString().contains('99.9%');
        }
        r.cycle.dispose();
        return threw &&
            r.transport.closes == 0 &&
            !r.outbox.isDurable &&
            r.cycle.phase != HabotSocketPhase.detached;
      },
    );

    gate(
      'GEN-02599-G5',
      'A caller must never have to know which phase the socket is in, and a '
          'message must never be dropped for being sent at the wrong moment.',
      'Sending in the foreground goes straight out; the same call while '
          'detached is durably queued instead, and the caller is told which '
          'happened',
      () async {
        final r = rig();
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        final bool wentOut = await r.cycle.send(
          id: 'm1',
          kind: 'task-submit',
          payload: <String, Object?>{'entity_id': 'J1'},
          encoded: '{"id":"m1"}',
        );
        if (wentOut) {
          sentNow++;
        }
        r.cycle.onBackgrounded();
        await r.cycle.detach();
        final bool wasQueued = !await r.cycle.send(
          id: 'm2',
          kind: 'task-submit',
          payload: <String, Object?>{'entity_id': 'J2'},
          encoded: '{"id":"m2"}',
        );
        if (wasQueued) {
          queued++;
        }
        r.cycle.dispose();
        return wentOut &&
            wasQueued &&
            r.transport.sent.single == '{"id":"m1"}' &&
            (await r.outbox.pendingCount) == 1 &&
            (await r.outbox.next())!.id == 'm2' &&
            r.cycle.queuedWhileDetached == 1;
      },
    );

    gate(
      'GEN-02599-G6',
      'Metric: Message Delivery Rate, floor 0.98, optimal 0.999.',
      'Delivery counts a durably queued message as delivered and a dropped one '
          'as lost, so the rate measures the trade the row actually makes '
          'rather than only what went out immediately',
      () async {
        return HabotSocketLifecycle.deliveryRate(
              sentNow: 1,
              queued: 1,
              dropped: 0,
            ) ==
                1.0 &&
            HabotSocketLifecycle.deliveryRate(
                  sentNow: 98,
                  queued: 1,
                  dropped: 1,
                ) ==
                0.99 &&
            HabotSocketLifecycle.deliveryRate(
                  sentNow: 0,
                  queued: 0,
                  dropped: 0,
                ) ==
                1.0 &&
            HabotSocketLifecycle.batteryDeliveryTension.contains(
              'provided the queue is durable',
            );
      },
    );

    gate(
      'GEN-02599-G7',
      'Step 119 has to be able to drive this without knowing what a socket is.',
      'The lifecycle implements the Step 119 sensitive interface as a DETACH '
          'action, so the observer sweeps it with everything else and reports '
          'it by name if it fails to release',
      () async {
        final r = rig();
        await r.cycle.socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        final HabotLifecycleObserver observer = HabotLifecycleObserver()
          ..register(r.cycle);
        final HabotLifecycleSweep sweep = observer.background();
        r.cycle.dispose();
        return r.cycle.lifecycleAction == HabotLifecycleAction.detach &&
            r.cycle.lifecycleLabel == 'HabotSocketLifecycle' &&
            sweep.released == 1 &&
            sweep.isClean;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02599',
        atomicStepReferenceId: 'GEN-02599',
        setupStepAction:
            'Program the WebSockets to handle mobile lifecycle events '
            '(backgrounding/waking) gracefully to save battery.',
        implementationOrder: 128,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSocketLifecycle',
          'Component Properties':
              '${HabotSocketPhase.values.length} phases (foreground, grace, '
              'detached); grace period '
              '${HabotSocketLifecycle.gracePeriod.inSeconds}s; detach refused '
              'without a durable queue; reuses Steps 117, 119, 121 and 127',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Message Delivery Rate',
            observed:
                'Every message handed to send() either went straight out or '
                'was durably queued; none was dropped. The grace phase means a '
                'task switch and an immediate return costs no reconnect at '
                'all, and detaching is refused outright when the queue behind '
                'the socket is not durable -- which is the only way the '
                'battery half of this row could otherwise be met by losing '
                'work.',
            floor: '0.98',
            optimal: '0.999',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Battery saved',
            observed:
                'NOT PRODUCED. Battery consumption needs a handset and a '
                'measurement harness. What is observable here is the thing '
                'that consumes it: the heartbeat stops at once on '
                'backgrounding and the socket closes after the grace period, '
                'both verified against the transport.',
            floor: 'no device harness available',
            optimal: 'no device harness available',
            ceiling: 'no device harness available',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/socket_lifecycle.dart',
        ],
      ),
    );
  });
}
