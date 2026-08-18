/// AISS: PNSAD-021-A01 -- "Mobile Push-Driven Notification Routing
/// Infrastructure."
/// Setup Step Description: "Build client-side rendering handlers to display
/// structured local ALERT SHEETS."
/// Metric: Device Push-Token Freshness Rate -- Floor ">= 90% of active devices
/// holding a valid, unexpired token", Optimal 0.97, Ceiling 99.5%+.
///
/// CONTAMINATED ROW, RECORDED: ten columns describe document access control
/// and row-level security -- Why This Matters ("Protects sensitive customer
/// records against unauthorized data viewing attempts"), Expected Output
/// ("Document Isolation Nomenclature Sheet"), Poka-Yoke ("Repository access
/// modules drop file fetch requests if session profiles miss required
/// classification keys"). None are gated. The Setup Step, the Setup Step
/// Description and the Metric are coherent.
///
/// AISS: GEN-03017-A01 -- "Deliver approval requests as mobile push
/// notifications with 1-tap Approve action on lock screens."
/// Metric: Mobile Usability Task Success Rate (%) -- Floor 80.0, Optimal 95.0.
/// METRIC NOTE, RECORDED: a usability-study measure obtained by watching
/// people attempt tasks. No suite produces it, and no number is asserted in
/// its place. What IS measured is what the step names: that an approval
/// decision can be taken in ONE action, that the action is authoritative, and
/// that it cannot be taken twice.
///
/// Two steps, one file: routing a delivered notification and routing the
/// specific case of an approval are the same mechanism, and separating them
/// would mean two things deciding where a tap goes.
///
/// THE ALERT SHEET IS THE STEP 21 SHEET. "structured local alert sheets" is
/// `HabotBottomSheet`, which already owns the 32% scrim, the snap ladder and
/// the drag handle. A fifth surface here would duplicate four gated decisions.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../navigation/deep_link_context_manager.dart';
import '../navigation/route_table.dart';
import 'message_receiver.dart';
import 'notification_center.dart';
import 'notification_payload.dart';

/// What happened to a delivered notification.
enum HabotDeliveryOutcome {
  /// Shown on a transient surface and not kept.
  presented,

  /// Shown and stored in the centre.
  presentedAndStored,

  /// Opened its target route immediately -- a tap from the system tray.
  navigated,

  /// Presented as an alert sheet requiring a decision.
  sheetOpened,

  /// Dropped: the route did not resolve, or a duplicate arrived.
  dropped,
}

/// One routing decision, recorded.
@immutable
class HabotDeliveryRecord {
  const HabotDeliveryRecord({
    required this.id,
    required this.kind,
    required this.outcome,
    required this.route,
    this.reason,
  });

  final String id;
  final HabotNotificationKind kind;
  final HabotDeliveryOutcome outcome;
  final String route;
  final String? reason;

  bool get reachedTheUser => outcome != HabotDeliveryOutcome.dropped;
}

/// An approval request awaiting a decision.
@immutable
class HabotApprovalRequest {
  const HabotApprovalRequest({
    required this.id,
    required this.subject,
    required this.detail,
    required this.route,
  });

  final String id;

  /// What is being approved, in one line -- this is what a lock screen shows.
  final String subject;
  final String detail;
  final String route;

  /// GEN-03017: "1-TAP Approve action on lock screens." One action, so the
  /// label has to carry the whole decision.
  String get approveLabel => 'Approve';
  String get rejectLabel => 'Review';

  String get lockScreenLabel => '$subject. $detail';
}

/// The decision a user took.
enum HabotApprovalDecision { approved, deferred }

/// The authoritative result, which may differ from what was tapped.
enum HabotApprovalOutcome {
  /// The approval was recorded.
  recorded,

  /// Someone else decided first, or the request was withdrawn.
  alreadyResolved,

  /// The decision could not be sent.
  failed,
}

/// Sends an approval decision. Injected, so the gates drive the race without a
/// backend.
typedef HabotApprovalSender =
    Future<HabotApprovalOutcome> Function(
      String requestId,
      HabotApprovalDecision decision,
    );

/// The router.
class HabotDeliveryRouter extends ChangeNotifier {
  HabotDeliveryRouter({
    required this.router,
    required this.centre,
    required this.contextManager,
    HabotApprovalSender? approvalSender,
  }) : _approvalSender = approvalSender;

  /// Step 43. Where a target route becomes a destination.
  final HabotRouter router;

  /// Step 75. Where a persisted notification lands.
  final HabotNotificationCenter centre;

  /// Step 42. What the user had open, restored on a tap.
  final DeepLinkContextManager contextManager;

  final HabotApprovalSender? _approvalSender;

  final List<HabotDeliveryRecord> _records = <HabotDeliveryRecord>[];
  final Set<String> _resolvedApprovals = <String>{};
  HabotApprovalRequest? _pendingApproval;

  List<HabotDeliveryRecord> get records =>
      List<HabotDeliveryRecord>.unmodifiable(_records);

  /// The approval currently asking for a decision, if any.
  HabotApprovalRequest? get pendingApproval => _pendingApproval;

  /// Routes a parsed message. Returns the outcome, and records it either way.
  HabotDeliveryOutcome route(HabotParsedMessage message) {
    final HabotRouteMatch match = router.match(message.route);
    if (match.isFallback) {
      // Step 43 falls back so a tap never lands on a blank screen; that is
      // right at tap time. Here it means the SENDER addressed something that
      // does not exist, which is a defect worth recording rather than
      // absorbing.
      return _record(
        message,
        HabotDeliveryOutcome.dropped,
        reason: 'target route "${message.route}" does not resolve',
      );
    }

    final bool stored = centre.receive(
      id: message.id,
      kind: message.kind,
      title: message.title,
      body: message.body,
      route: message.route,
      at: message.receivedAt,
    );

    if (message.kind == HabotNotificationKind.approval) {
      _pendingApproval = HabotApprovalRequest(
        id: message.id,
        subject: message.title,
        detail: message.body,
        route: message.route,
      );
      notifyListeners();
      return _record(message, HabotDeliveryOutcome.sheetOpened);
    }

    if (message.source == HabotMessageSource.tapped) {
      // A tap from the tray. Restore the context Step 42 remembered rather
      // than dropping the user on a bare screen.
      contextManager.restore(message.route);
      return _record(message, HabotDeliveryOutcome.navigated);
    }

    return _record(
      message,
      stored
          ? HabotDeliveryOutcome.presentedAndStored
          : HabotDeliveryOutcome.presented,
    );
  }

  HabotDeliveryOutcome _record(
    HabotParsedMessage message,
    HabotDeliveryOutcome outcome, {
    String? reason,
  }) {
    _records.add(
      HabotDeliveryRecord(
        id: message.id,
        kind: message.kind,
        outcome: outcome,
        route: message.route,
        reason: reason,
      ),
    );
    return outcome;
  }

  /// GEN-03017: the one tap.
  ///
  /// Returns the AUTHORITATIVE outcome. A second tap on an already-resolved
  /// request cannot record a second decision -- the same race the Step 66
  /// poka-yoke handles for dispatch offers, handled the same way.
  Future<HabotApprovalOutcome> decide(
    String requestId,
    HabotApprovalDecision decision,
  ) async {
    if (_resolvedApprovals.contains(requestId)) {
      return HabotApprovalOutcome.alreadyResolved;
    }
    final HabotApprovalSender? sender = _approvalSender;
    if (sender == null) {
      return HabotApprovalOutcome.failed;
    }
    final HabotApprovalOutcome outcome = await sender(requestId, decision);
    if (outcome == HabotApprovalOutcome.recorded ||
        outcome == HabotApprovalOutcome.alreadyResolved) {
      _resolvedApprovals.add(requestId);
      centre.markRead(requestId);
      if (_pendingApproval?.id == requestId) {
        _pendingApproval = null;
      }
      notifyListeners();
    }
    return outcome;
  }

  /// True while this request can still be decided. The Approve control reads
  /// this rather than being told to disable itself.
  bool canDecide(String requestId) =>
      !_resolvedApprovals.contains(requestId);

  /// How many delivered notifications reached the user. The honest reading of
  /// a delivery metric from inside the client.
  double get reachRate => _records.isEmpty
      ? 1
      : _records.where((HabotDeliveryRecord r) => r.reachedTheUser).length /
            _records.length;

  int get droppedCount => _records
      .where((HabotDeliveryRecord r) => !r.reachedTheUser)
      .length;
}

/// PNSAD-021's Metric: Device Push-Token Freshness Rate.
///
/// The metric fits its step and is measurable client-side: a device holds a
/// token, the token has an issue time, and a token past its refresh horizon is
/// stale. What the CLIENT owns is noticing and refreshing; the fleet-wide
/// percentage is a backend aggregate, and the gate says so.
class HabotPushTokenRegistry extends ChangeNotifier {
  HabotPushTokenRegistry({
    required Future<String?> Function() refresh,
    DateTime Function()? clock,
  }) : _refresh = refresh,
       _clock = clock ?? DateTime.now;

  final Future<String?> Function() _refresh;
  final DateTime Function() _clock;

  /// FCM rotates tokens; treating one older than this as stale keeps the
  /// client ahead of the rotation rather than reacting to a failed send.
  static const Duration refreshHorizon = Duration(days: 30);

  /// Floor: ">= 90% of active devices holding a valid, unexpired token."
  static const double freshnessFloor = 0.90;
  static const double freshnessOptimal = 0.97;

  String? _token;
  DateTime? _issuedAt;
  int _refreshAttempts = 0;
  int _refreshSuccesses = 0;

  String? get token => _token;
  DateTime? get issuedAt => _issuedAt;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  bool get isFresh {
    final DateTime? issued = _issuedAt;
    if (!hasToken || issued == null) {
      return false;
    }
    return _clock().difference(issued) < refreshHorizon;
  }

  /// The client-side reading: 1.0 when this device holds a fresh token, 0.0
  /// when it does not. The fleet percentage the metric names is the average of
  /// this across devices, which only the backend can compute.
  double get deviceFreshness => isFresh ? 1 : 0;

  double get refreshSuccessRate =>
      _refreshAttempts == 0 ? 1 : _refreshSuccesses / _refreshAttempts;

  Future<bool> ensureFresh() async {
    if (isFresh) {
      return true;
    }
    _refreshAttempts++;
    String? next;
    try {
      next = await _refresh();
    } catch (_) {
      next = null;
    }
    if (next == null || next.isEmpty) {
      notifyListeners();
      return false;
    }
    _token = next;
    _issuedAt = _clock();
    _refreshSuccesses++;
    notifyListeners();
    return true;
  }

  void adopt(String token, DateTime issuedAt) {
    _token = token;
    _issuedAt = issuedAt;
    notifyListeners();
  }
}
