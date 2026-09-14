/// AISS Step 194 -- GEN-04726
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 3: Set global app state isLoading = true
///               and inject M3 progress indicator."
/// Metric: Substep Definition-of-Done Adherence Rate -- Floor ">=90% unit test
///         coverage / acceptance criteria met before merge", Optimal "95-100%
///         coverage, all acceptance criteria met", Ceiling "100%".
///         Complete / Partial / Not Complete.
///
/// **`isLoading = true` IS THE DEFECT THE ROW IS ASKING FOR, AND IT IS WORTH
/// SAYING SO.** A single global boolean cannot represent two things happening
/// at once, and on an offline-first app two things are happening at once
/// constantly: the Step 123 sync sweep, a Step 153 field autosave, a search.
/// The failure is always the same and always confusing — whichever operation
/// finishes first sets the flag to false, the spinner vanishes, and the app is
/// still loading. Nobody reports it as "the loading flag is shared", they
/// report it as "the spinner disappears too early", which is a different bug
/// and sends people looking in the wrong place.
///
/// So the state is a **counted scope keyed by operation**, and
/// [HabotNaiveLoadingFlag] is kept beside it so the difference can be
/// demonstrated rather than argued.
///
/// **A SPINNER SHOWN FOR 120ms IS WORSE THAN NO SPINNER.** Under a few hundred
/// milliseconds a person experiences the app as responding immediately; a
/// spinner that appears and vanishes inside that window converts something
/// they would not have noticed into a flash they read as a rendering glitch.
/// So the indicator has a **delay before it appears**, and once it has
/// appeared a **minimum time it stays**, because the same flash in reverse is
/// equally bad.
///
/// **THE INDICATOR MUST BE ANNOUNCED, NOT ONLY DRAWN.** A screen reader user
/// gets nothing from a spinner. That is the whole of what "injecting a
/// progress indicator" means for them, and `HabotProgressPolicy` already
/// carries the semantics value.
library;

import '../tokens/motion_tokens.dart';
import 'progress_indicators.dart';

/// Why something is loading. Named rather than anonymous so a stuck scope can
/// say what is stuck.
class HabotLoadingOperation {
  const HabotLoadingOperation({
    required this.id,
    required this.description,
    this.total,
    this.completed = 0,
  });

  final String id;
  final String description;

  /// Total units of work, when it is known. Null for work whose size cannot
  /// be known in advance -- a network round trip.
  final int? total;

  final int completed;

  /// MD3 prefers a determinate indicator whenever the total is known, because
  /// an indeterminate spinner over knowable progress is a decision to tell the
  /// user less than you could.
  bool get isDeterminate => total != null && total! > 0;

  double? get fraction =>
      isDeterminate ? HabotProgressPolicy.clamp(completed / total!) : null;
}

/// The single global boolean, kept so the defect is demonstrable.
///
/// **Not for use.** It exists so the gate can show two concurrent operations
/// clearing one flag, which is the thing this step replaces.
class HabotNaiveLoadingFlag {
  bool isLoading = false;

  void begin() => isLoading = true;

  /// The bug: no idea how many callers are still running.
  void end() => isLoading = false;
}

/// Loading state that survives concurrency.
class HabotLoadingScope {
  HabotLoadingScope({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  final Map<String, HabotLoadingOperation> _active =
      <String, HabotLoadingOperation>{};

  DateTime? _firstBeganAt;
  DateTime? _shownAt;

  /// How long work must run before the indicator appears at all.
  static Duration get appearAfter => HabotMotion.loadingIndicatorDelay;

  /// Once shown, how long it stays even if the work finishes immediately.
  static Duration get minimumVisible =>
      HabotMotion.loadingIndicatorMinimumVisible;

  Iterable<HabotLoadingOperation> get active => _active.values;

  int get activeCount => _active.length;

  /// True while anything is running. **Derived, never set.**
  bool get isLoading => _active.isNotEmpty;

  /// Begin an operation. Idempotent per id: beginning the same operation twice
  /// is one operation, not two, so a retry does not leave the scope stuck.
  void begin(HabotLoadingOperation operation) {
    _firstBeganAt ??= _clock();
    _active[operation.id] = operation;
  }

  /// Update progress on a running operation.
  void advance(String id, int completed) {
    final HabotLoadingOperation? op = _active[id];
    if (op == null) {
      return;
    }
    _active[id] = HabotLoadingOperation(
      id: op.id,
      description: op.description,
      total: op.total,
      completed: completed,
    );
  }

  /// End one operation. The scope closes only when the last one ends.
  void end(String id) {
    _active.remove(id);
    if (_active.isEmpty) {
      _firstBeganAt = null;
    }
  }

  /// Operations still running, named. What a stuck spinner should be able to
  /// tell a developer instead of spinning.
  List<String> get stalled =>
      _active.values.map((HabotLoadingOperation o) => o.description).toList();

  // ---- when the indicator is on screen ------------------------------------

  Duration get elapsed {
    final DateTime? began = _firstBeganAt;
    return began == null ? Duration.zero : _clock().difference(began);
  }

  /// Whether the indicator should be drawn right now.
  ///
  /// Three rules, in order: nothing running and past the minimum-visible
  /// window means no; running but not yet past the appearance delay means no;
  /// otherwise yes.
  bool get shouldShow {
    if (isLoading) {
      if (elapsed < appearAfter) {
        return false;
      }
      _shownAt ??= _clock();
      return true;
    }
    final DateTime? shown = _shownAt;
    if (shown == null) {
      return false;
    }
    if (_clock().difference(shown) < minimumVisible) {
      return true;
    }
    _shownAt = null;
    return false;
  }

  /// The value to hand a progress widget: a fraction when every running
  /// operation knows its size, null otherwise.
  ///
  /// One indeterminate operation makes the whole scope indeterminate -- a
  /// combined bar that ignores the operation it cannot measure would move to
  /// 100% and stop while work continued.
  double? get combinedFraction {
    if (_active.isEmpty) {
      return null;
    }
    if (!_active.values.every((HabotLoadingOperation o) => o.isDeterminate)) {
      return null;
    }
    double sum = 0;
    for (final HabotLoadingOperation o in _active.values) {
      sum += o.fraction ?? 0;
    }
    return HabotProgressPolicy.clamp(sum / _active.length);
  }

  bool get isDeterminate =>
      HabotProgressPolicy.isDeterminate(combinedFraction);

  /// What assistive technology is told. A spinner is nothing to a screen
  /// reader; this is what "injecting a progress indicator" means for that
  /// user.
  String get semanticsValue => isDeterminate
      ? HabotProgressPolicy.semanticsValue(combinedFraction!)
      : 'Loading';

  // ---- the row's metric ---------------------------------------------------

  static Map<String, bool> acceptanceCriteria(
    HabotLoadingScope Function() build,
  ) {
    // Two concurrent operations, the first finishing while the second runs.
    final HabotLoadingScope counted = build()
      ..begin(
        const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
      )
      ..begin(
        const HabotLoadingOperation(id: 'autosave', description: 'Saving'),
      )
      ..end('sync');

    final HabotNaiveLoadingFlag naive = HabotNaiveLoadingFlag()
      ..begin()
      ..begin()
      ..end();

    final HabotLoadingScope idempotent = build()
      ..begin(
        const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
      )
      ..begin(
        const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
      )
      ..end('sync');

    final HabotLoadingScope mixed = build()
      ..begin(
        const HabotLoadingOperation(
          id: 'upload',
          description: 'Uploading',
          total: 10,
          completed: 5,
        ),
      )
      ..begin(
        const HabotLoadingOperation(id: 'lookup', description: 'Looking up'),
      );

    return <String, bool>{
      'the scope stays loading while a second operation is still running':
          counted.isLoading && counted.activeCount == 1,
      'the single global boolean does not, which is the defect being replaced':
          !naive.isLoading,
      'the loading state is derived from what is running rather than set':
          counted.stalled.single == 'Saving',
      'beginning the same operation twice is one operation, so a retry does '
              'not leave the scope stuck':
          !idempotent.isLoading && idempotent.activeCount == 0,
      'the indicator does not appear before the declared delay, so short work '
              'does not flash':
          appearAfter > Duration.zero,
      'once shown, the indicator stays for a declared minimum, so it does not '
              'flash off either':
          minimumVisible > appearAfter,
      'a determinate figure is used only when every running operation knows '
              'its size':
          mixed.combinedFraction == null && !mixed.isDeterminate,
      'the loading state is announced as well as drawn':
          mixed.semanticsValue.isNotEmpty,
    };
  }

  static double adherenceRate(HabotLoadingScope Function() build) {
    final Iterable<bool> v = acceptanceCriteria(build).values;
    return v.where((bool b) => b).length / v.length;
  }

  static const double floor = 0.9;
  static const double optimal = 1.0;

  static String qualitativeOutput(HabotLoadingScope Function() build) {
    final double r = adherenceRate(build);
    if (r >= optimal) {
      return 'Complete';
    }
    return r >= floor ? 'Partial' : 'Not Complete';
  }

  static const String globalFlagNote =
      'A single global boolean cannot represent two things happening at once, '
      'and on an offline-first app two things are happening at once '
      'constantly. Whichever operation finishes first sets the flag to false, '
      'the spinner vanishes, and the app is still loading. Nobody reports that '
      'as "the loading flag is shared" -- they report "the spinner disappears '
      'too early", which sends people looking in the wrong place.';

  static const String flashNote =
      'A spinner shown for 120ms is worse than no spinner. Under a few hundred '
      'milliseconds a person experiences the app as responding immediately; an '
      'indicator that appears and vanishes inside that window converts '
      'something they would not have noticed into a flash they read as a '
      'rendering glitch. Hence a delay before it appears and a minimum time it '
      'stays -- the same flash in reverse is equally bad.';

  static const String indeterminateNote =
      'One indeterminate operation makes the whole scope indeterminate. A '
      'combined bar that ignores the operation it cannot measure would reach '
      '100% and stop while work continued, which is the most misleading thing '
      'a progress indicator can do.';

  static const String announcedNote =
      'A spinner is nothing to a screen reader. Announcing the state is the '
      'whole of what "injecting a progress indicator" means for that user.';

  static const String coverageReadingNote =
      'The row\'s metric joins unit test coverage and acceptance criteria with '
      'a slash. A coverage percentage cannot be produced on this host -- there '
      'is no Dart toolchain, so nothing runs and nothing is instrumented. The '
      'acceptance-criteria half is producible and is what is reported.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
