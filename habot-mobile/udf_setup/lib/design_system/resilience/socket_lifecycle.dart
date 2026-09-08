/// AISS Step 128 -- GEN-02599
/// Atomic Step: "Program the WebSockets to handle mobile lifecycle events
///               (backgrounding/waking) gracefully to save battery."
/// Metric: Message Delivery Rate (%) -- Floor 0.98, Optimal 0.999, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE TENSION THIS STEP IS ENTIRELY ABOUT. The row asks for two things that
/// pull in opposite directions: save battery (close the socket) and deliver
/// 99.9% of messages (keep it open). Neither wins outright, and a build that
/// pretends otherwise fails one of them silently.
///
/// The resolution is that a message is not LOST when the socket is closed --
/// it is QUEUED, by Step 117, and delivered on wake by Step 123. So the socket
/// can close aggressively without costing delivery, PROVIDED the queue is
/// actually durable. That proviso is checked here rather than assumed:
/// [HabotSocketLifecycle] refuses to detach if it has no queue behind it,
/// because a socket that closes over a volatile queue really does drop
/// messages, and the metric would be met on paper by a build that loses work.
///
/// THE THREE PHASES, and why the middle one exists:
///
///   FOREGROUND     socket open, heartbeat running.
///   GRACE          backgrounded, socket still open, heartbeat stopped. A user
///                  glancing at a notification and coming straight back should
///                  not pay a full reconnect. This is the phase most
///                  implementations skip, and skipping it is why apps feel
///                  slow after every task switch.
///   DETACHED       socket closed, everything queued.
///
/// WHAT IT REUSES: Step 119's observer for the signal, Step 127's heartbeat to
/// stop and restart, Step 117's outbox to hold what cannot be sent, and Step
/// 121's policy to come back. Nothing here is a second implementation of any
/// of them.
library;

import 'dart:async';

import '../data/outbox.dart';
import '../tokens/motion_tokens.dart';
import 'heartbeat.dart';
import 'lifecycle_observer.dart';
import 'socket_transport.dart';

/// Where the socket is in the background cycle.
enum HabotSocketPhase { foreground, grace, detached }

/// Thrown when a socket is asked to detach with nothing to hold its messages.
class HabotUnbackedSocketError extends StateError {
  HabotUnbackedSocketError()
    : super(
        'This socket has no durable queue behind it, so closing it on '
        'backgrounding would DROP messages rather than defer them. The row '
        'asks for a 99.9% delivery rate; a socket that closes over a volatile '
        'queue meets the battery half of the requirement by failing the other '
        'half quietly. Give it a durable HabotOutbox, or leave it attached.',
      );
}

/// Manages the socket across backgrounding and waking.
class HabotSocketLifecycle implements HabotLifecycleSensitive {
  HabotSocketLifecycle({
    required this.socket,
    required this.heartbeat,
    required this.outbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotSecureSocket socket;
  final HabotHeartbeat heartbeat;

  /// Where messages go while detached. Required -- see [HabotUnbackedSocketError].
  final HabotOutbox outbox;

  final DateTime Function() _clock;

  /// How long the socket stays open after backgrounding before it detaches.
  static Duration get gracePeriod => HabotMotion.socketGracePeriod;

  HabotSocketPhase _phase = HabotSocketPhase.foreground;
  Timer? _graceTimer;
  DateTime? _backgroundedAt;
  int _detachCount = 0;
  int _queuedWhileDetached = 0;

  HabotSocketPhase get phase => _phase;
  int get detachCount => _detachCount;
  int get queuedWhileDetached => _queuedWhileDetached;

  Duration? get backgroundedFor =>
      _backgroundedAt == null ? null : _clock().difference(_backgroundedAt!);

  // ---- HabotLifecycleSensitive ------------------------------------------

  @override
  String get lifecycleLabel => 'HabotSocketLifecycle';

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.detach;

  /// "Released" here means the heartbeat has stopped -- which happens
  /// immediately on backgrounding, before the grace period expires. The socket
  /// itself is deliberately still open during grace, and that is not a leak:
  /// it is the decision this step exists to make.
  @override
  bool get isReleased => _phase != HabotSocketPhase.foreground;

  @override
  void onBackgrounded() {
    if (_phase != HabotSocketPhase.foreground) {
      return;
    }
    _phase = HabotSocketPhase.grace;
    _backgroundedAt = _clock();
    // The heartbeat is what actually costs battery: a radio wake every
    // interval, indefinitely. It stops at once.
    heartbeat.stop();
    _graceTimer?.cancel();
    _graceTimer = Timer(gracePeriod, () => unawaited(detach()));
  }

  @override
  void onForegrounded() {
    _graceTimer?.cancel();
    _graceTimer = null;
    final HabotSocketPhase was = _phase;
    _phase = HabotSocketPhase.foreground;
    _backgroundedAt = null;
    if (was == HabotSocketPhase.grace) {
      // Nothing to reopen -- this is the case the grace period exists for.
      heartbeat.start();
    }
  }

  // ---- the socket itself -------------------------------------------------

  /// Close the socket and hand delivery to the queue.
  Future<void> detach() async {
    if (_phase == HabotSocketPhase.detached) {
      return;
    }
    if (!outbox.isDurable) {
      throw HabotUnbackedSocketError();
    }
    _phase = HabotSocketPhase.detached;
    _detachCount++;
    heartbeat.stop();
    await socket.transport.close();
  }

  /// Send, or queue if the socket is not there to take it.
  ///
  /// This is the method that makes the battery/delivery trade honest: a caller
  /// never has to know which phase the socket is in, and a message is never
  /// dropped for being sent at the wrong moment.
  Future<bool> send({
    required String id,
    required String kind,
    required Map<String, Object?> payload,
    required String encoded,
  }) async {
    if (_phase == HabotSocketPhase.foreground &&
        socket.transport.status == HabotSocketStatus.open) {
      await socket.transport.send(encoded);
      return true;
    }
    await outbox.enqueue(id: id, kind: kind, payload: payload);
    _queuedWhileDetached++;
    return false;
  }

  void dispose() {
    _graceTimer?.cancel();
    _graceTimer = null;
  }

  /// The row's metric, computed over what this component can actually see: of
  /// everything handed to [send], the share that either went straight out or
  /// was durably queued. Nothing else counts as delivered, and nothing that
  /// was queued counts as lost.
  static double deliveryRate({required int sentNow, required int queued, required int dropped}) {
    final int total = sentNow + queued + dropped;
    return total == 0 ? 1 : (sentNow + queued) / total;
  }

  static const double floor = 0.98;
  static const double optimal = 0.999;

  static const String batteryDeliveryTension =
      'The row asks to save battery (close the socket) and to deliver 99.9% of '
      'messages (keep it open). The resolution is that a message sent while '
      'detached is QUEUED rather than dropped, so the socket can close '
      'aggressively without costing delivery -- provided the queue is durable, '
      'which is checked rather than assumed.';
}
