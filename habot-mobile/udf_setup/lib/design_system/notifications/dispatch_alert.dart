/// AISS: GEN-00692-A01 -- "Configure Mobile Push Notifications & Real-Time
/// Alert Triggers."
/// Setup Step Description: "Integrate Firebase Cloud Messaging (FCM) SDK into
/// backend Cloud Run workers."
///
/// 4 Substeps, verbatim:
///   1. "Integrate Firebase Cloud Messaging (FCM) for instant high-priority
///       push notifications."
///   2. "Implement a 60-second acceptance timer ('Clock') for dispatched job
///       offers."
///   3. "Build one-tap action screens displaying client distance,
///       requirements, and earnings."
///   4. "Create fallback reassignment subroutines if a request expires without
///       response."
///
/// Poka-Yoke: "System PHYSICALLY DISABLES 'Accept' button if another provider
/// accepts the job milliseconds prior, preventing double-booking."
/// Self-Chasing: "Allowing 3 consecutive job alerts to time out temporarily
/// pauses automatic dispatch for 2 hours, requiring manual status reset."
/// Flow Impact: "Lock screen alert sounds -> User taps notification -> Brief
/// job summary appears with 60s timer -> User taps 'Accept' -> Job locked."
/// Completion Measures: "Push notification delivery latency <= 1.5s.
/// Acceptance screen load time <= 300ms. Average job response time <= 30s."
/// Metric: FCM SDK Ingestion Pass -- Floor 100%, Optimal 100%.
///
/// THE ONE FULLY COHERENT ROW IN THIS BATCH. Every column describes the same
/// step, it carries four real substeps, a real poka-yoke and three real
/// completion measures. It is first for that reason: everything else in Steps
/// 67-80 is either a surface this renders through or a store it writes to.
///
/// ON FCM. This file contains no Firebase dependency and makes no network
/// call. What substep 1 actually requires of the client is a TRANSPORT
/// BOUNDARY: one place a delivered message enters the app, so the app has a
/// single answer to "what arrived, and when?" whether the sender was FCM, a
/// local schedule or a test. [HabotDispatchTransport] is that boundary, and
/// Step 68 is the receiver behind it. The SDK wiring itself is a backend and
/// platform-channel concern; the gate records that rather than pretending a
/// widget test proved an SDK integration.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../tokens/motion_tokens.dart';

/// Substep 2: the acceptance clock.
class HabotDispatchClock {
  const HabotDispatchClock._();

  /// "a 60-SECOND acceptance timer ('Clock') for dispatched job offers."
  static const Duration acceptanceWindow =
      HabotMotion.dispatchAcceptanceWindow;

  /// Completion Measure: "Push notification delivery latency <= 1.5s."
  static const Duration deliveryBudget = HabotMotion.dispatchDeliveryBudget;

  /// Completion Measure: "Acceptance screen load time <= 300ms."
  static const Duration acceptanceScreenBudget =
      HabotMotion.dispatchScreenBudget;

  /// Completion Measure: "Average job response time <= 30s." Half the window,
  /// which is the point: a 60s clock whose average response is 55s is a clock
  /// nobody is really reading.
  static const Duration averageResponseBudget =
      HabotMotion.dispatchResponseBudget;

  /// Self-Chasing: "Allowing 3 CONSECUTIVE job alerts to time out temporarily
  /// pauses automatic dispatch for 2 HOURS."
  static const int timeoutsBeforePause = 3;
  static const Duration dispatchPause = HabotMotion.dispatchPause;

  /// The fraction of the window remaining at which the countdown ring turns
  /// urgent. Stated here so the ring and any accompanying haptic agree.
  static const double urgentFraction = 0.25;

  static bool isUrgent(Duration remaining) =>
      remaining.inMilliseconds <=
      acceptanceWindow.inMilliseconds * urgentFraction;
}

/// Why an offer is no longer acceptable. Never a bare bool: "you cannot accept
/// this" and "someone else took it" need different words on screen.
enum HabotOfferOutcome {
  /// Still live and acceptable.
  pending,

  /// This provider accepted, and won.
  accepted,

  /// Substep 4 / the poka-yoke: another provider got there first.
  takenByAnother,

  /// The 60-second clock ran out.
  expired,

  /// The provider declined explicitly.
  declined,
}

/// Substep 3: "one-tap action screens displaying client DISTANCE,
/// REQUIREMENTS, and EARNINGS." Those three are required fields rather than
/// optional decoration -- an offer that cannot say what it pays or how far
/// away it is cannot be decided on in sixty seconds.
@immutable
class HabotDispatchOffer {
  const HabotDispatchOffer({
    required this.id,
    required this.title,
    required this.distanceKm,
    required this.requirements,
    required this.earnings,
    required this.dispatchedAt,
  });

  final String id;
  final String title;

  /// Substep 3, field 1.
  final double distanceKm;

  /// Substep 3, field 2. Empty is allowed; absent is not.
  final List<String> requirements;

  /// Substep 3, field 3, already formatted for display -- currency formatting
  /// is a locale concern and does not belong in a dispatch record.
  final String earnings;

  final DateTime dispatchedAt;

  DateTime get expiresAt =>
      dispatchedAt.add(HabotDispatchClock.acceptanceWindow);

  Duration remainingAt(DateTime now) {
    final Duration left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool hasExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  /// How far through the window, 0 to 1. The countdown ring reads this.
  double progressAt(DateTime now) {
    final int total = HabotDispatchClock.acceptanceWindow.inMilliseconds;
    final int gone = now.difference(dispatchedAt).inMilliseconds;
    return (gone / total).clamp(0.0, 1.0);
  }

  /// The three substep-3 fields as one spoken sentence. A provider deciding in
  /// sixty seconds on a lock screen should not have to read four labels.
  /// Built with a buffer rather than one nested interpolation: a string
  /// holding its own quoted strings inside `${...}` is legal Dart and
  /// unreadable code.
  String get summaryLabel {
    final StringBuffer buffer = StringBuffer(
      '$title, ${distanceKm.toStringAsFixed(1)} kilometres away, $earnings',
    );
    if (requirements.isNotEmpty) {
      final String plural = requirements.length == 1 ? '' : 's';
      buffer.write(', ${requirements.length} requirement$plural');
    }
    return buffer.toString();
  }
}

/// One recorded dispatch, for the completion measures.
@immutable
class HabotDispatchRecord {
  const HabotDispatchRecord({
    required this.offerId,
    required this.outcome,
    required this.deliveryLatency,
    required this.responseTime,
  });

  final String offerId;
  final HabotOfferOutcome outcome;

  /// Time from send to arrival at the transport boundary.
  final Duration deliveryLatency;

  /// Time from arrival to the provider's decision. Equal to the full window
  /// when it expired.
  final Duration responseTime;

  bool get deliveredInBudget =>
      deliveryLatency <= HabotDispatchClock.deliveryBudget;
}

/// Substep 1, the client half: one place a delivered message enters the app.
///
/// Injected, so the gates drive real dispatches without FCM, a network or a
/// device. The production implementation is a thin platform-channel adapter;
/// what this codebase owns and can verify is everything downstream of here.
abstract class HabotDispatchTransport {
  /// Messages as they arrive.
  Stream<HabotDispatchOffer> get offers;

  /// Reports the decision back to the dispatcher. Returns the authoritative
  /// outcome -- which may be [HabotOfferOutcome.takenByAnother] even though
  /// this provider tapped Accept, because the race is resolved server-side.
  Future<HabotOfferOutcome> respond(String offerId, HabotOfferOutcome choice);

  /// Substep 4: "fallback reassignment subroutines if a request expires
  /// without response."
  Future<void> reassign(String offerId);
}

/// The engine.
class HabotDispatchEngine extends ChangeNotifier {
  HabotDispatchEngine({required this.transport, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _subscription = transport.offers.listen(_onOffer);
  }

  final HabotDispatchTransport transport;
  final DateTime Function() _clock;

  StreamSubscription<HabotDispatchOffer>? _subscription;
  Timer? _expiryTimer;

  HabotDispatchOffer? _current;
  HabotOfferOutcome _outcome = HabotOfferOutcome.pending;
  int _consecutiveTimeouts = 0;
  DateTime? _pausedUntil;
  final List<HabotDispatchRecord> _records = <HabotDispatchRecord>[];
  DateTime? _arrivedAt;

  /// The offer currently on screen, if any.
  HabotDispatchOffer? get current => _current;

  HabotOfferOutcome get outcome => _outcome;

  List<HabotDispatchRecord> get records =>
      List<HabotDispatchRecord>.unmodifiable(_records);

  int get consecutiveTimeouts => _consecutiveTimeouts;

  /// Self-Chasing: automatic dispatch is paused until this moment.
  DateTime? get pausedUntil => _pausedUntil;

  bool get isPaused {
    final DateTime? until = _pausedUntil;
    return until != null && _clock().isBefore(until);
  }

  /// THE POKA-YOKE, as a getter. "System physically disables 'Accept' button
  /// if another provider accepts the job milliseconds prior."
  ///
  /// The button reads this rather than being told to disable itself: a UI that
  /// has to remember to check cannot be relied on to, and the race is decided
  /// here in one place.
  bool get canAccept =>
      _current != null &&
      _outcome == HabotOfferOutcome.pending &&
      !_current!.hasExpiredAt(_clock());

  void _onOffer(HabotDispatchOffer offer) {
    if (isPaused) {
      // Paused by the self-chasing rule: the offer is reassigned rather than
      // shown, so a paused provider does not silently sit on live work.
      unawaited(transport.reassign(offer.id));
      return;
    }
    _current = offer;
    _outcome = HabotOfferOutcome.pending;
    _arrivedAt = _clock();
    _expiryTimer?.cancel();
    _expiryTimer = Timer(offer.remainingAt(_clock()), _onExpired);
    notifyListeners();
  }

  /// The provider tapped Accept. Returns the AUTHORITATIVE outcome, which may
  /// not be what they tapped.
  Future<HabotOfferOutcome> accept() async {
    final HabotDispatchOffer? offer = _current;
    if (offer == null || !canAccept) {
      return _outcome;
    }
    final HabotOfferOutcome result = await transport.respond(
      offer.id,
      HabotOfferOutcome.accepted,
    );
    _settle(offer, result);
    if (result == HabotOfferOutcome.accepted) {
      _consecutiveTimeouts = 0;
    }
    return result;
  }

  Future<HabotOfferOutcome> decline() async {
    final HabotDispatchOffer? offer = _current;
    if (offer == null || _outcome != HabotOfferOutcome.pending) {
      return _outcome;
    }
    final HabotOfferOutcome result = await transport.respond(
      offer.id,
      HabotOfferOutcome.declined,
    );
    _settle(offer, result);
    // A decline is a response. It does not count toward the timeout streak,
    // because the rule is about ignoring alerts, not about refusing work.
    _consecutiveTimeouts = 0;
    return result;
  }

  void _onExpired() {
    final HabotDispatchOffer? offer = _current;
    if (offer == null || _outcome != HabotOfferOutcome.pending) {
      return;
    }
    _settle(offer, HabotOfferOutcome.expired);
    _consecutiveTimeouts++;
    if (_consecutiveTimeouts >= HabotDispatchClock.timeoutsBeforePause) {
      _pausedUntil = _clock().add(HabotDispatchClock.dispatchPause);
    }
    // Substep 4: the fallback reassignment.
    unawaited(transport.reassign(offer.id));
    notifyListeners();
  }

  void _settle(HabotDispatchOffer offer, HabotOfferOutcome result) {
    _expiryTimer?.cancel();
    _outcome = result;
    _records.add(
      HabotDispatchRecord(
        offerId: offer.id,
        outcome: result,
        deliveryLatency:
            (_arrivedAt ?? offer.dispatchedAt).difference(offer.dispatchedAt),
        responseTime: result == HabotOfferOutcome.expired
            ? HabotDispatchClock.acceptanceWindow
            : _clock().difference(_arrivedAt ?? offer.dispatchedAt),
      ),
    );
    notifyListeners();
  }

  /// "requiring MANUAL STATUS RESET" -- the pause does not clear itself early,
  /// and clearing it is an explicit act.
  void resetDispatchStatus() {
    _pausedUntil = null;
    _consecutiveTimeouts = 0;
    notifyListeners();
  }

  /// Completion Measure: "Average job response time <= 30s."
  Duration get averageResponseTime {
    if (_records.isEmpty) {
      return Duration.zero;
    }
    final int total = _records.fold<int>(
      0,
      (int sum, HabotDispatchRecord r) => sum + r.responseTime.inMilliseconds,
    );
    return Duration(milliseconds: total ~/ _records.length);
  }

  /// Completion Measure: "Push notification delivery latency <= 1.5s."
  double get deliveryBudgetPassRate => _records.isEmpty
      ? 100
      : (_records.where((HabotDispatchRecord r) => r.deliveredInBudget).length /
                _records.length) *
            100;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
