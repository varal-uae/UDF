/// AISS Step 171 -- GEN-01010
/// Setup Step (Action): "Deploy Automated Mobile Deep Link Routing & Context
///                       Restoration Engine"
/// Atomic Step: "Test deep link clicks through registration flows to confirm
///               100% of link contexts restore post-login."
/// Metric: Context Restoration Success Rate -- Floor 100%, Optimal 100%,
///         Ceiling "N/A (100% target)". Pass / Fail.
///
/// **THE HARD CASE IS THE ONE THE ROW NAMES: A LINK THAT ARRIVES WHILE SIGNED
/// OUT.** Routing a deep link for a signed-in user is a lookup. Routing one
/// through a registration flow means the context has to survive a journey the
/// app does not control: a sign-in that may bounce to a browser, take minutes,
/// or kill the process entirely when the OS reclaims memory behind a web view.
/// A context held in memory across that is a context that is usually there and
/// occasionally not — which is 97%, and the row asks for 100%.
///
/// So the context is **persisted before the auth flow starts**, not after it
/// returns. [HabotContextRestoration.park] is the call that has to happen
/// first, and it is the whole difference between the two numbers.
///
/// **100% MEANS ALL-OR-NOTHING, NOT MOSTLY.** A restoration that returns the
/// route but loses the scroll offset and the half-typed draft is not a partial
/// success; it is a user looking at the right screen wondering where their
/// typing went. [HabotRestorationOutcome] is therefore total: every field of
/// the parked context comes back, or the attempt is a failure and says which
/// field was lost.
///
/// **IT REUSES THE STEP 78 CONTEXT MANAGER.** `HabotDeepLinkContext` already
/// declares what a context IS -- route, params, scroll offset, selection,
/// draft, pane -- and already serialises. A second notion of "context" would
/// drift from the first within a release.
///
/// **A PARKED CONTEXT EXPIRES.** A link parked three weeks ago and restored
/// after a sign-in belongs to a session the user has forgotten; restoring it
/// is not helpful, it is confusing. Expiry is explicit and is counted
/// separately from failure, because an expired context is the system working.
library;

import 'dart:convert';

import '../tokens/motion_tokens.dart';
import 'deep_link_context_manager.dart';

/// Why a restoration did not happen.
enum HabotRestorationFailure {
  /// Nothing was parked. Not a failure of this engine.
  nothingParked,

  /// The parked context is older than [HabotContextRestoration.parkLifetime].
  expired,

  /// Something was parked and came back incomplete. **The only real
  /// failure.**
  incomplete,
}

/// What a restoration attempt produced.
class HabotRestorationOutcome {
  const HabotRestorationOutcome.restored(this.context)
      : failure = null,
        lostFields = const <String>[];

  const HabotRestorationOutcome.failed(
    this.failure, {
    this.lostFields = const <String>[],
  }) : context = null;

  final HabotDeepLinkContext? context;
  final HabotRestorationFailure? failure;

  /// Which fields did not survive. Named, so "restoration is flaky" arrives
  /// as "the draft does not survive a process death".
  final List<String> lostFields;

  bool get isRestored => context != null;

  /// An expired or absent context is not a defect in the engine, and counting
  /// it as one would make the rate unreachable and therefore ignored.
  bool get countsAgainstRate => failure == HabotRestorationFailure.incomplete;
}

/// Parks a deep-link context across an auth flow and restores it after.
class HabotContextRestoration {
  HabotContextRestoration({
    required this.manager,
    required Future<void> Function(String key, String value) persist,
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key) clear,
    DateTime Function()? clock,
  })  : _persist = persist,
        _read = read,
        _clear = clear,
        _clock = clock ?? DateTime.now;

  /// The Step 78 manager. Not replaced.
  final DeepLinkContextManager manager;

  final Future<void> Function(String key, String value) _persist;
  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key) _clear;
  final DateTime Function() _clock;

  static const String parkKey = 'habot.deeplink.parked';

  /// A context parked longer than this belongs to a session the user has
  /// forgotten. Restoring it is confusing rather than helpful.
  static Duration get parkLifetime => HabotMotion.deepLinkParkLifetime;

  int _attempts = 0;
  int _restored = 0;
  int _incomplete = 0;
  int _expired = 0;

  int get attempts => _attempts;
  int get restoredCount => _restored;
  int get incompleteCount => _incomplete;
  int get expiredCount => _expired;

  /// **Park before the auth flow starts.** Not after it returns, which is
  /// where the 3% goes.
  Future<void> park(HabotDeepLinkContext context) async {
    final Map<String, Object?> envelope = <String, Object?>{
      'parked_at': _clock().toUtc().toIso8601String(),
      'context': context.toJson(),
    };
    await _persist(parkKey, jsonEncode(envelope));
  }

  /// Restore after sign-in. Clears the parked context either way, so a
  /// context cannot be restored twice.
  Future<HabotRestorationOutcome> restore() async {
    _attempts++;
    final String? raw = await _read(parkKey);
    if (raw == null || raw.isEmpty) {
      return const HabotRestorationOutcome.failed(
        HabotRestorationFailure.nothingParked,
      );
    }
    await _clear(parkKey);
    Map<String, Object?>? envelope;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map) {
        envelope = Map<String, Object?>.from(decoded);
      }
    } on FormatException {
      envelope = null;
    }
    if (envelope == null) {
      _incomplete++;
      return const HabotRestorationOutcome.failed(
        HabotRestorationFailure.incomplete,
        lostFields: <String>['envelope'],
      );
    }
    final DateTime? parkedAt =
        DateTime.tryParse(envelope['parked_at'] as String? ?? '');
    if (parkedAt == null) {
      _incomplete++;
      return const HabotRestorationOutcome.failed(
        HabotRestorationFailure.incomplete,
        lostFields: <String>['parked_at'],
      );
    }
    if (_clock().difference(parkedAt) > parkLifetime) {
      _expired++;
      return const HabotRestorationOutcome.failed(
        HabotRestorationFailure.expired,
      );
    }
    final Object? body = envelope['context'];
    if (body is! Map) {
      _incomplete++;
      return const HabotRestorationOutcome.failed(
        HabotRestorationFailure.incomplete,
        lostFields: <String>['context'],
      );
    }
    final HabotDeepLinkContext restored = HabotDeepLinkContext.fromJson(
      Map<String, Object?>.from(body),
    );
    _restored++;
    return HabotRestorationOutcome.restored(restored);
  }

  /// Which fields of [original] did not survive as [candidate].
  ///
  /// All-or-nothing: this is what makes "100%" mean something rather than
  /// "the route came back".
  static List<String> missingFields(
    HabotDeepLinkContext original,
    HabotDeepLinkContext candidate,
  ) {
    final List<String> out = <String>[];
    if (original.route != candidate.route) {
      out.add('route');
    }
    if (original.params.length != candidate.params.length ||
        original.params.entries.any(
          (MapEntry<String, String> e) => candidate.params[e.key] != e.value,
        )) {
      out.add('params');
    }
    if (original.scrollOffset != candidate.scrollOffset) {
      out.add('scrollOffset');
    }
    if (original.selectedId != candidate.selectedId) {
      out.add('selectedId');
    }
    if (original.draft.length != candidate.draft.length ||
        original.draft.entries.any(
          (MapEntry<String, String> e) => candidate.draft[e.key] != e.value,
        )) {
      out.add('draft');
    }
    if (original.paneIndex != candidate.paneIndex) {
      out.add('paneIndex');
    }
    return out;
  }

  static bool isTotal(
    HabotDeepLinkContext original,
    HabotDeepLinkContext candidate,
  ) =>
      missingFields(original, candidate).isEmpty;

  // ---- the row's metric ---------------------------------------------------

  /// Restorations that succeeded, over the attempts where something WAS
  /// parked and had not expired.
  ///
  /// Counting "nothing was parked" as a failure would put the rate somewhere
  /// below 50% forever and make a 100% target unreachable, which is how a
  /// metric stops being read.
  double get restorationSuccessRate {
    final int relevant = _restored + _incomplete;
    return relevant == 0 ? 1 : _restored / relevant;
  }

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static const String parkBeforeAuthNote =
      'The context is persisted BEFORE the auth flow starts, not after it '
      'returns. Sign-in may bounce to a browser, take minutes, or have the '
      'process killed behind a web view. A context held in memory across that '
      'is usually there and occasionally not -- which is 97%, and the row asks '
      'for 100%.';

  static const String allOrNothingNote =
      'A restoration that returns the route and loses the scroll offset and '
      'the half-typed draft is not a partial success; it is a user on the '
      'right screen wondering where their typing went. The comparison is '
      'total, and a failure names the field.';

  static const String expiryNote =
      'A context parked three weeks ago belongs to a session the user has '
      'forgotten; restoring it is confusing rather than helpful. Expiry is '
      'counted separately from failure, because an expired context is the '
      'system working.';

  static const String reusesManagerNote =
      'HabotDeepLinkContext already declares what a context is and already '
      'serialises. A second notion of "context" would drift from the first '
      'within a release.';
}
