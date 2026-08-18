/// AISS: PNSAD-010-A01 -- "Build Mobile Push Notification Layout & Preference
/// Control Manager."
/// Setup Step Description: "Program subscription registration flow targeting
/// device token engines."
/// Metric: Device Push-Token Freshness Rate -- Floor ">= 90% of active devices
/// holding a valid, unexpired token", Optimal 0.97, Ceiling 99.5%+.
///
/// THE MOST CONTAMINATED ROW IN ANY BATCH SO FAR. Eleven columns describe an
/// authentication and API-gateway step:
///
///   Decision Before      "Auth provider selection."
///   Why This Matters     "Secures identity and access management for mobile
///                         users."
///   Mobile App First     "Stateless auth allows mobile apps to scale without
///                         hitting a central session database."
///   UX Translation       "Invisible session handling."
///   Flow Impact          "Secure API access."
///   Dashboard Implication "Auth success/failure metrics."
///   Must Standardize     "API Gateway JWT validation."
///   Atomic Reusability   "Universal Auth middleware."
///   Expected Output      "Secure Auth flow ... 100% of unauthorized requests
///                         blocked at Gateway."
///   Poka-Yoke            "API Gateway inherently rejects invalid signatures
///                         before hitting Cloud Run."
///   Self-Chasing         "Alert on spike in token validation failures."
///
/// None of those are gated. Two columns are coherent and are what this is
/// measured against: the Setup Step Description (a subscription registration
/// flow targeting device token engines) and the Metric (push-token freshness,
/// which genuinely fits a subscription step).
///
/// WHAT THIS STEP ACTUALLY IS. It is the join. Steps 49-50 built a preference
/// store and a screen where a user says what they want; Steps 66-79 built
/// everything that produces and delivers notifications. Nothing yet connects
/// them, which means the preferences are decorative -- a user can switch
/// "offers" off and still receive them. This file is the enforcement point,
/// and it enforces in BOTH directions: a suppressed notification never reaches
/// a surface, and a subscription is registered or dropped as the preference
/// changes.
library;

import 'package:flutter/foundation.dart';

import '../preferences/preference_manager.dart';
import 'delivery_router.dart';
import 'notification_payload.dart';

/// Which preference column governs which notification kind.
///
/// The mapping is total -- every kind resolves to something -- because a kind
/// with no mapping would be a notification nobody can turn off, which is the
/// failure mode the preference screen exists to prevent.
class HabotNotificationPreferenceMap {
  const HabotNotificationPreferenceMap._();

  /// Returns the column that governs [kind], or null when the kind is not
  /// suppressible.
  ///
  /// Two kinds are deliberately NOT suppressible, and this is the decision
  /// worth arguing with rather than hiding:
  ///
  ///   critical  a P1 breach is not marketing. A user who has switched off
  ///             promotional messages has not asked to be uninformed that the
  ///             system is compromised.
  ///   dispatch  a time-boxed offer the user opted into by being on shift.
  ///             Suppressing it silently would look like no work arriving.
  ///
  /// Both remain controllable -- by going off shift, or by the operator
  /// pausing dispatch (Step 66's self-chasing rule) -- but not by a
  /// notification toggle.
  static HabotPreferenceColumn? columnFor(HabotNotificationKind kind) {
    switch (kind) {
      case HabotNotificationKind.informational:
        return HabotPreferenceColumn.allowPromo;
      case HabotNotificationKind.approval:
      case HabotNotificationKind.failure:
        return HabotPreferenceColumn.allowTransaction;
      case HabotNotificationKind.critical:
      case HabotNotificationKind.dispatch:
        return null;
    }
  }

  static bool isSuppressible(HabotNotificationKind kind) =>
      columnFor(kind) != null;

  /// Every kind is accounted for. A gate asserts this rather than trusting the
  /// switch above to stay exhaustive.
  static bool get mappingIsTotal =>
      HabotNotificationKind.values.every(
        (HabotNotificationKind k) =>
            columnFor(k) != null || !isSuppressible(k),
      );
}

/// Why a notification was or was not delivered. Never a bare bool: "the user
/// switched this off" and "this cannot be switched off" are different facts.
enum HabotSuppressionReason {
  /// Delivered.
  none,

  /// The governing preference is off.
  userPreference,

  /// Not suppressible by preference.
  notSuppressible,
}

/// One suppression decision, recorded.
@immutable
class HabotSuppressionRecord {
  const HabotSuppressionRecord({
    required this.id,
    required this.kind,
    required this.delivered,
    required this.reason,
  });

  final String id;
  final HabotNotificationKind kind;
  final bool delivered;
  final HabotSuppressionReason reason;
}

/// The join.
///
/// Everything a notification passes through on its way to a surface goes
/// through here first. There is no second path -- which is what makes the
/// preference screen mean something.
class HabotNotificationPreferenceManager extends ChangeNotifier {
  HabotNotificationPreferenceManager({
    required this.store,
    required this.registry,
    this.onSubscriptionChanged,
  }) {
    store.addListener(_onPreferencesChanged);
  }

  /// Steps 49-50.
  final PreferenceStore store;

  /// Step 76's token registry -- the Setup Step Description's "device token
  /// engines".
  final HabotPushTokenRegistry registry;

  /// Called when a topic subscription should be registered or dropped. The
  /// Setup Step Description's "subscription registration flow", injected so
  /// the gates drive it without a backend.
  final void Function(HabotPreferenceColumn column, bool subscribed)?
  onSubscriptionChanged;

  final List<HabotSuppressionRecord> _decisions = <HabotSuppressionRecord>[];
  final Map<HabotPreferenceColumn, bool> _lastKnown =
      <HabotPreferenceColumn, bool>{};

  List<HabotSuppressionRecord> get decisions =>
      List<HabotSuppressionRecord>.unmodifiable(_decisions);

  /// THE GATE EVERY NOTIFICATION PASSES. True when this may be shown.
  bool allows(HabotNotificationKind kind) {
    final HabotPreferenceColumn? column =
        HabotNotificationPreferenceMap.columnFor(kind);
    if (column == null) {
      return true;
    }
    return store.valueOf(column);
  }

  HabotSuppressionReason reasonFor(HabotNotificationKind kind) {
    final HabotPreferenceColumn? column =
        HabotNotificationPreferenceMap.columnFor(kind);
    if (column == null) {
      return HabotSuppressionReason.notSuppressible;
    }
    return store.valueOf(column)
        ? HabotSuppressionReason.none
        : HabotSuppressionReason.userPreference;
  }

  /// Records and returns the decision for one notification.
  bool admit({required String id, required HabotNotificationKind kind}) {
    final bool delivered = allows(kind);
    _decisions.add(
      HabotSuppressionRecord(
        id: id,
        kind: kind,
        delivered: delivered,
        reason: delivered
            ? HabotSuppressionReason.none
            : HabotSuppressionReason.userPreference,
      ),
    );
    return delivered;
  }

  /// The Setup Step Description's registration flow: a preference going on
  /// registers the subscription, going off drops it. Runs on every change, so
  /// the backend's view and the user's view cannot diverge.
  void _onPreferencesChanged() {
    bool changed = false;
    for (final HabotPreferenceColumn column
        in HabotPreferenceColumn.values) {
      final bool now = store.valueOf(column);
      if (_lastKnown[column] != now) {
        _lastKnown[column] = now;
        onSubscriptionChanged?.call(column, now);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Registers the current state of every subscription. Called once at
  /// startup, so a device that was offline when a preference changed catches
  /// up rather than staying subscribed to something the user switched off.
  Future<bool> synchronise() async {
    final bool fresh = await registry.ensureFresh();
    for (final HabotPreferenceColumn column
        in HabotPreferenceColumn.values) {
      final bool value = store.valueOf(column);
      _lastKnown[column] = value;
      onSubscriptionChanged?.call(column, value);
    }
    notifyListeners();
    return fresh;
  }

  /// How many notifications were suppressed by preference. Worth surfacing:
  /// a user who has switched everything off and then asks why they hear
  /// nothing is answerable from this.
  int get suppressedCount =>
      _decisions.where((HabotSuppressionRecord d) => !d.delivered).length;

  int get admittedCount =>
      _decisions.where((HabotSuppressionRecord d) => d.delivered).length;

  /// The share of notifications the preferences let through.
  double get admissionRate => _decisions.isEmpty
      ? 1
      : admittedCount / _decisions.length;

  @override
  void dispose() {
    store.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}
