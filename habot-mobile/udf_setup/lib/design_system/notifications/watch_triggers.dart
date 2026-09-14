/// AISS Step 172 -- GEN-01187
/// Setup Step (Action) / Atomic Step: "Set up automated push notification
///   triggers that alert parents when a favorited service drops in price or
///   opens new scheduling slots."
/// Metric: Mean Time to Detect (MTTD) -- Floor "<15 min", Optimal "<2 min",
///         Ceiling "<30 min". Good / Average / Poor.
///
/// **MTTD IS A SERVER FIGURE, AND THE CLIENT'S HALF IS THE PART THAT DECIDES
/// WHETHER THE ALERT SHOULD EXIST.** Detecting that a price fell is something
/// the backend does against its own catalogue; no phone is watching a price.
/// What the client owns is the watch — which service, on what condition, for
/// whom — and the preference check that decides whether a detected change is
/// allowed to interrupt someone. The MTTD bands are carried so the client can
/// band a figure it is given, and the boundary is recorded rather than left
/// looking like an omission.
///
/// **THE ALERT THAT FIRES ON A ONE-PENNY MOVE IS THE ONE THAT GETS
/// NOTIFICATIONS TURNED OFF.** "Drops in price" has to mean something: a
/// threshold, applied to an exact amount (Step 140), and directional — a price
/// RISE is not a drop, and a system that alerts on both because it compared
/// two numbers and found them different is one nobody trusts twice.
/// [HabotWatchCondition] makes the direction and the threshold explicit.
///
/// **IT GOES THROUGH THE STEP 50 PREFERENCE MANAGER, NOT AROUND IT.** A
/// trigger that sends because it has something to say is spam. Every alert
/// this produces is admitted by the same preference gate every other
/// notification passes, and a watch that fires while its category is muted is
/// recorded as suppressed rather than sent — so "I turned those off and still
/// got one" cannot happen.
///
/// **THE WATCH IS ON A FAVOURITE, WHICH MEANS STEP 132 OWNS ITS LIFETIME.**
/// Un-favouriting a service must stop its alerts. A watch list maintained
/// separately from the favourites is a list that drifts, and the symptom is
/// alerts about things a user deliberately removed.
library;

import '../data/favourites_repository.dart';
import '../i18n/fixed_precision.dart';
import '../tokens/motion_tokens.dart';

/// What kind of change a watch is for.
enum HabotWatchKind {
  /// The price fell by at least the threshold.
  priceDrop,

  /// New scheduling slots became available.
  slotsOpened,
}

/// One watch condition.
class HabotWatchCondition {
  const HabotWatchCondition({
    required this.kind,
    required this.minimumDrop,
    required this.minimumNewSlots,
  });

  /// A price watch that alerts on any change alerts on rounding. The default
  /// is a whole unit of currency, which is the smallest move a person would
  /// call a drop.
  factory HabotWatchCondition.priceDrop({HabotFixed? minimum}) =>
      HabotWatchCondition(
        kind: HabotWatchKind.priceDrop,
        minimumDrop: minimum ?? defaultMinimumDrop,
        minimumNewSlots: 0,
      );

  factory HabotWatchCondition.slotsOpened({int minimum = 1}) =>
      HabotWatchCondition(
        kind: HabotWatchKind.slotsOpened,
        minimumDrop: null,
        minimumNewSlots: minimum,
      );

  final HabotWatchKind kind;

  /// Exact, never a double -- Step 140.
  final HabotFixed? minimumDrop;

  final int minimumNewSlots;

  static HabotFixed get defaultMinimumDrop =>
      HabotPrecision.cacAedValue('1.0000');

  /// Whether a change satisfies this condition.
  ///
  /// **Directional.** A rise is not a drop, however large.
  bool isSatisfiedByPrice({
    required HabotFixed before,
    required HabotFixed after,
  }) {
    if (kind != HabotWatchKind.priceDrop) {
      return false;
    }
    if (after.compareTo(before) >= 0) {
      return false;
    }
    final HabotFixed fall = before - after;
    return fall.compareTo(minimumDrop ?? defaultMinimumDrop) >= 0;
  }

  bool isSatisfiedBySlots({required int newSlots}) =>
      kind == HabotWatchKind.slotsOpened && newSlots >= minimumNewSlots;
}

/// A registered watch.
class HabotWatch {
  const HabotWatch({
    required this.favouriteId,
    required this.condition,
  });

  /// The Step 132 favourite this watch belongs to. Its lifetime, not ours.
  final String favouriteId;

  final HabotWatchCondition condition;

  Map<String, Object?> toRegistration() => <String, Object?>{
        'favourite_id': favouriteId,
        'kind': condition.kind.name,
        'minimum_drop': condition.minimumDrop?.toPlainString(),
        'minimum_new_slots': condition.minimumNewSlots,
      };
}

/// Why an alert was not delivered.
enum HabotAlertSuppression {
  /// The user muted this category. The Step 50 gate said no.
  preferenceMuted,

  /// The change did not meet the watch's threshold.
  belowThreshold,

  /// The favourite no longer exists.
  notFavourited,
}

/// What happened to one detected change.
class HabotAlertDecision {
  const HabotAlertDecision.send(this.watch)
      : suppression = null;

  const HabotAlertDecision.suppress(this.watch, this.suppression);

  final HabotWatch watch;
  final HabotAlertSuppression? suppression;

  bool get willSend => suppression == null;
}

/// Registers watches and decides whether a detected change alerts.
class HabotWatchTriggers {
  HabotWatchTriggers({
    required this.favourites,
    required bool Function(HabotWatchKind kind) isCategoryAllowed,
  }) : _isCategoryAllowed = isCategoryAllowed;

  /// Step 132. The source of truth for what is favourited.
  final HabotFavouritesRepository favourites;

  /// The Step 50 preference gate. Injected rather than reimplemented.
  final bool Function(HabotWatchKind kind) _isCategoryAllowed;

  final Map<String, HabotWatch> _watches = <String, HabotWatch>{};
  final List<HabotAlertDecision> _decisions = <HabotAlertDecision>[];

  Iterable<HabotWatch> get watches => _watches.values;
  List<HabotAlertDecision> get decisions =>
      List<HabotAlertDecision>.unmodifiable(_decisions);

  static String keyOf(String favouriteId, HabotWatchKind kind) =>
      '$favouriteId:${kind.name}';

  void register(HabotWatch watch) =>
      _watches[keyOf(watch.favouriteId, watch.condition.kind)] = watch;

  void unregister(String favouriteId, HabotWatchKind kind) =>
      _watches.remove(keyOf(favouriteId, kind));

  /// Drop every watch whose favourite is gone.
  ///
  /// Called after a Step 132 removal. A watch list maintained separately from
  /// the favourites drifts, and the symptom is alerts about things the user
  /// deliberately removed.
  Future<List<String>> pruneToFavourites() async {
    final Set<String> live = (await favourites.current())
        .map((HabotFavourite f) => f.entityId)
        .toSet();
    final List<String> removed = <String>[];
    for (final String key in _watches.keys.toList()) {
      final HabotWatch w = _watches[key]!;
      if (!live.contains(w.favouriteId)) {
        _watches.remove(key);
        removed.add(key);
      }
    }
    return removed;
  }

  /// Decide on a detected price change.
  HabotAlertDecision? onPriceChange({
    required String favouriteId,
    required HabotFixed before,
    required HabotFixed after,
  }) =>
      _decide(
        favouriteId,
        HabotWatchKind.priceDrop,
        (HabotWatch w) =>
            w.condition.isSatisfiedByPrice(before: before, after: after),
      );

  /// Decide on newly opened slots.
  HabotAlertDecision? onSlotsOpened({
    required String favouriteId,
    required int newSlots,
  }) =>
      _decide(
        favouriteId,
        HabotWatchKind.slotsOpened,
        (HabotWatch w) => w.condition.isSatisfiedBySlots(newSlots: newSlots),
      );

  HabotAlertDecision? _decide(
    String favouriteId,
    HabotWatchKind kind,
    bool Function(HabotWatch) satisfied,
  ) {
    final HabotWatch? watch = _watches[keyOf(favouriteId, kind)];
    if (watch == null) {
      return null;
    }
    late final HabotAlertDecision decision;
    if (!satisfied(watch)) {
      decision = HabotAlertDecision.suppress(
        watch,
        HabotAlertSuppression.belowThreshold,
      );
    } else if (!_isCategoryAllowed(kind)) {
      decision = HabotAlertDecision.suppress(
        watch,
        HabotAlertSuppression.preferenceMuted,
      );
    } else {
      decision = HabotAlertDecision.send(watch);
    }
    _decisions.add(decision);
    return decision;
  }

  int get sent => _decisions.where((HabotAlertDecision d) => d.willSend).length;

  int suppressedFor(HabotAlertSuppression reason) => _decisions
      .where((HabotAlertDecision d) => d.suppression == reason)
      .length;

  /// Alerts sent while the category was muted. Must be zero.
  int get sentWhileMuted => _decisions
      .where((HabotAlertDecision d) =>
          d.willSend && !_isCategoryAllowed(d.watch.condition.kind))
      .length;

  // ---- the row's metric ---------------------------------------------------

  static Duration get optimal => HabotMotion.watchDetectOptimal;
  static Duration get floor => HabotMotion.watchDetectFloor;
  static Duration get ceiling => HabotMotion.watchDetectCeiling;

  /// The row's vocabulary, applied to a detection time the SERVER supplies.
  static String bandFor(Duration mttd) {
    if (mttd <= optimal) {
      return 'Good';
    }
    if (mttd <= floor) {
      return 'Average';
    }
    return mttd <= ceiling ? 'Average' : 'Poor';
  }

  static bool withinCeiling(Duration mttd) => mttd <= ceiling;

  static const String mttdIsServerSide =
      'Detecting that a price fell is something the backend does against its '
      'own catalogue; no phone is watching a price. The client owns the watch '
      '-- which service, on what condition -- and the preference check that '
      'decides whether a detected change may interrupt someone. The bands are '
      'carried so a figure the server supplies can be banded; the boundary is '
      'recorded rather than left looking like an omission.';

  static const String thresholdNote =
      'The alert that fires on a one-penny move is the one that gets '
      'notifications turned off. "Drops in price" needs a threshold, applied '
      'to an exact amount rather than a double, and a DIRECTION -- a rise is '
      'not a drop, and a system that alerts on both because it compared two '
      'numbers and found them different is one nobody trusts twice.';

  static const String preferenceGateNote =
      'Every alert is admitted by the same Step 50 preference gate every other '
      'notification passes. A trigger that sends because it has something to '
      'say is spam, and "I turned those off and still got one" is the '
      'complaint that follows.';

  static const String favouriteLifetimeNote =
      'A watch belongs to a Step 132 favourite and dies with it. A watch list '
      'maintained separately from the favourites drifts, and the symptom is '
      'alerts about things the user deliberately removed.';
}
