/// Step 196 (GEN-01110) -- device-local first-run-experience state.
///
/// The row asks for "device local storage flags (FRE_Completed)". The metric on
/// the same row is **First-Run Experience Completion Rate**.
///
/// A single boolean cannot produce that rate. `FRE_Completed = true` is written
/// when someone finishes the carousel and also when someone skips it, because
/// both end the carousel and both need it to stay gone. Once the two are the
/// same value, the completion rate is 1.0 for every install that got past the
/// first screen, which is the number the metric was asked for and the one
/// number it can never be. What is recorded here is the OUTCOME and the
/// furthest slide
/// reached, from which both the rate and the drop-off point are derivable.
///
/// The second thing a device-local flag cannot do is survive the device. It is
/// per-install, not per-account -- reinstall, a second phone, or a cleared app
/// and the carousel comes back for someone who has seen it three times. That is
/// not fixed here; Step 197 is where the account-side suppression lives, and
/// this file records the boundary rather than pretending the flag is enough.
library;

import 'dart:typed_data';

import '../data/local_store.dart';

/// How a first-run carousel ended.
enum HabotFreOutcome {
  /// Every slide was seen and the final action was taken.
  completed,

  /// The user dismissed the carousel deliberately.
  skipped,

  /// The carousel was left part-way -- the app was backgrounded, killed, or
  /// navigated away from -- and never ended.
  abandoned,
}

/// The state of one install's first-run experience.
class HabotFreState {
  const HabotFreState({
    required this.outcome,
    required this.furthestSlide,
    required this.slideCount,
    required this.carouselVersion,
    required this.recordedAt,
  });

  /// How it ended. `null` while the carousel is still open.
  final HabotFreOutcome? outcome;

  /// Zero-based index of the furthest slide the user reached.
  final int furthestSlide;

  /// How many slides the carousel had when this state was written. Stored
  /// because a later release can change it, and a drop-off index means nothing
  /// without the denominator it was measured against.
  final int slideCount;

  /// Which carousel this state describes. See [HabotFreFlag.versionNote].
  final int carouselVersion;

  final DateTime recordedAt;

  /// True once the carousel should no longer be shown for this install.
  ///
  /// This is the boolean the row asked for. It is DERIVED rather than stored,
  /// so it cannot drift away from the outcome it is supposed to summarise.
  bool get isSettled =>
      outcome == HabotFreOutcome.completed ||
      outcome == HabotFreOutcome.skipped;

  /// The fraction of the carousel that was seen.
  double get progress =>
      slideCount == 0 ? 0 : (furthestSlide + 1) / slideCount;

  Map<String, Object?> toRecord() => <String, Object?>{
        'outcome': outcome?.name,
        'furthestSlide': furthestSlide,
        'slideCount': slideCount,
        'carouselVersion': carouselVersion,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
      };

  static HabotFreState? fromRecord(Map<String, Object?>? record) {
    if (record == null) {
      return null;
    }
    final Object? slide = record['furthestSlide'];
    final Object? count = record['slideCount'];
    final Object? version = record['carouselVersion'];
    final Object? at = record['recordedAt'];
    if (slide is! int || count is! int || version is! int || at is! String) {
      return null;
    }
    final DateTime? parsed = DateTime.tryParse(at);
    if (parsed == null) {
      return null;
    }
    final Object? outcome = record['outcome'];
    return HabotFreState(
      outcome: outcome is String ? _outcomeNamed(outcome) : null,
      furthestSlide: slide,
      slideCount: count,
      carouselVersion: version,
      recordedAt: parsed,
    );
  }

  static HabotFreOutcome? _outcomeNamed(String name) {
    for (final HabotFreOutcome o in HabotFreOutcome.values) {
      if (o.name == name) {
        return o;
      }
    }
    return null;
  }
}

/// Reads and writes the first-run state for one install.
class HabotFreFlag {
  HabotFreFlag({required this.store, this.carouselVersion = 1});

  final HabotLocalStore store;

  /// The version of the carousel this build ships.
  final int carouselVersion;

  static const HabotCollection collection = HabotCollection('onboarding');
  static const String key = 'fre_state';

  /// The name the row asks for, kept so the field can be found from the sheet.
  static const String rowFieldName = 'FRE_Completed';

  Future<HabotFreState?> read() async {
    final Uint8List? bytes = await store.read(collection, key);
    if (bytes == null) {
      return null;
    }
    return HabotFreState.fromRecord(HabotRecordCodec.decode(bytes));
  }

  Future<void> write(HabotFreState state) =>
      store.write(collection, key, HabotRecordCodec.encode(state.toRecord()));

  /// Records progress without ending the carousel.
  ///
  /// Written on every slide advance rather than only at the end, because the
  /// abandonment case never reaches an end and is exactly the case the
  /// completion rate is measuring.
  Future<HabotFreState> recordProgress({
    required int slideIndex,
    required int slideCount,
    required DateTime now,
  }) async {
    final HabotFreState? prior = await read();
    final int furthest = prior == null
        ? slideIndex
        : (slideIndex > prior.furthestSlide ? slideIndex : prior.furthestSlide);
    final HabotFreState next = HabotFreState(
      outcome: null,
      furthestSlide: furthest,
      slideCount: slideCount,
      carouselVersion: carouselVersion,
      recordedAt: now,
    );
    await write(next);
    return next;
  }

  /// Ends the carousel with an explicit outcome.
  Future<HabotFreState> settle({
    required HabotFreOutcome outcome,
    required int slideIndex,
    required int slideCount,
    required DateTime now,
  }) async {
    final HabotFreState next = HabotFreState(
      outcome: outcome,
      furthestSlide: slideIndex,
      slideCount: slideCount,
      carouselVersion: carouselVersion,
      recordedAt: now,
    );
    await write(next);
    return next;
  }

  /// The decision this flag exists to make, for this build's carousel version.
  ///
  /// A state written against an older carousel does not settle a newer one --
  /// otherwise a redesigned first-run experience would ship to nobody who had
  /// already installed the app.
  bool shouldShowCarousel(HabotFreState? state) =>
      state == null ||
      state.carouselVersion != carouselVersion ||
      !state.isSettled;

  /// The completion rate the metric names, over a set of install states.
  ///
  /// Abandonment counts against it. That is the whole point: an install that
  /// opened slide one and never came back is the failure this rate is for.
  static double completionRate(Iterable<HabotFreState> states) {
    final List<HabotFreState> all = states.toList();
    if (all.isEmpty) {
      return 0;
    }
    final int completed = all
        .where((HabotFreState s) => s.outcome == HabotFreOutcome.completed)
        .length;
    return completed / all.length;
  }

  /// Where people stop, as a slide index -> count map over unfinished states.
  static Map<int, int> dropOffHistogram(Iterable<HabotFreState> states) {
    final Map<int, int> out = <int, int>{};
    for (final HabotFreState s in states) {
      if (s.outcome == HabotFreOutcome.completed) {
        continue;
      }
      out[s.furthestSlide] = (out[s.furthestSlide] ?? 0) + 1;
    }
    return out;
  }

  /// The rate a single stored boolean would report for the same population.
  ///
  /// Kept beside the real figure so the defect is demonstrated rather than
  /// argued: every settled install looks complete, so the rate is the share
  /// that got past the first screen at all, which is not what was asked for.
  static double naiveBooleanRate(Iterable<HabotFreState> states) {
    final List<HabotFreState> all = states.toList();
    if (all.isEmpty) {
      return 0;
    }
    return all.where((HabotFreState s) => s.isSettled).length / all.length;
  }

  static const double floor = 0.7;
  static const double optimal = 0.9;
  static const double ceiling = 1;

  static String qualitativeOutput(double rate) {
    if (rate >= optimal) {
      return 'Good';
    }
    if (rate >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  static const String booleanCannotProduceARateNote =
      'A single FRE_Completed boolean is written both when the carousel is '
      'finished and when it is skipped, because both need it to stay gone. '
      'Once those two write the same value the completion rate is 1.0 for '
      'every install that got past the first screen -- the one number the '
      'metric can never be. The outcome is recorded instead and the boolean '
      'is derived from it.';

  static const String perInstallNote =
      'BOUNDARY: this is device-local state, so it is per install and not per '
      'account. Reinstalling, switching phone or clearing app data shows the '
      'carousel again to someone who has seen it. The flag is the fast path '
      'for an unauthenticated first run; Step 197 (GEN-01419) carries the '
      'account-side suppression that the flag cannot provide.';

  static const String versionNote =
      'The carousel version is stored with the state. Without it a settled '
      'flag suppresses every future first-run experience as well as this one, '
      'so a redesigned carousel would ship only to new installs -- and the '
      'people who most need re-onboarding after a redesign are the existing '
      'users.';

  static const String durabilityNote =
      'HabotMemoryStore.isDurable is false by declaration, so a test that '
      'writes this flag and reads it back is testing the codec, not '
      'persistence. The durable implementation is a platform concern; what '
      'this file owns is the shape of what gets stored.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement device local storage flags (FRE_Completed) to track carousel '
      'completion."';
}
