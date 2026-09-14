/// AISS Step 160 -- GEN-04649
/// Setup Step (Action) / Atomic Step: "Capture funnel progression events
///   across multi-step support ticket flows."
/// Metric: Analytics Event Schema Validation Rate -- Floor 0.95,
///         Optimal 0.999, Ceiling 1.0. Pass / Fail.
///
/// **"SUPPORT TICKET FLOWS" IS THE ROW'S EXAMPLE; THE MULTI-STEP FLOW THIS APP
/// HAS IS THE STEP 147 WIZARD.** The substitution is recorded rather than
/// silently generalised: what the row asks for is funnel capture across a
/// flow with numbered steps and a drop-off point, and a referral form split
/// into single questions is exactly that shape. A tracker built only for
/// tickets would have to be rewritten when the first other flow arrived.
///
/// **THE HARD PART OF A FUNNEL IS THE ABANDONMENT, NOT THE PROGRESSION.**
/// Completions are easy: something happened, emit an event. Abandonment has no
/// trigger — the user simply stops, and nothing in the app is called. A
/// tracker that only records completions can tell you 300 people reached step
/// 4 and 120 reached step 5, and cannot tell you whether the other 180 gave up
/// or are still typing. So abandonment is inferred, at the two moments the app
/// actually learns about it: the lifecycle observer backgrounding the app
/// (Step 119), and the session ending. [HabotFunnelTracker.sweepAbandoned] is
/// that inference, and it is explicit rather than a side effect.
///
/// **`had_visible_error` IS THE FIELD THAT MAKES AN ABANDONMENT ACTIONABLE.**
/// "They left at step 4" is a fact nobody can act on. "They left at step 4 with
/// a validation error on screen" is a bug report. Step 156 declares the field;
/// this is where it gets set, from the Step 149 navigation outcome rather than
/// from a guess.
///
/// **EVERY EVENT IS VALIDATED BEFORE IT IS EMITTED, WHICH IS THE METRIC.**
/// An event that fails the Step 156 schema is not emitted at all; it is
/// counted as a rejection and named. Emitting it and letting the warehouse
/// reject it later would leave the app's own validation rate at 100% while the
/// pipeline quietly dropped rows.
library;

import 'event_schema.dart';

/// One flow being walked.
class HabotFunnelRun {
  HabotFunnelRun({
    required this.flowId,
    required this.stepCount,
    required this.startedAt,
    required this.traceId,
  });

  final String flowId;
  final int stepCount;
  final DateTime startedAt;

  /// Shared with every crash, timing and outbox record this run produces.
  final String traceId;

  int stepIndex = 0;
  DateTime? stepEnteredAt;
  bool hadVisibleError = false;
  bool completed = false;
  bool abandonmentRecorded = false;
}

/// Captures funnel progression.
class HabotFunnelTracker {
  HabotFunnelTracker({
    required this.view,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// The screen the flow lives on. Required by the Step 156 envelope.
  final String view;

  final DateTime Function() _clock;

  final Map<String, HabotFunnelRun> _runs = <String, HabotFunnelRun>{};
  final List<HabotEvent> _emitted = <HabotEvent>[];
  final List<HabotSchemaFinding> _rejected = <HabotSchemaFinding>[];
  int _attempted = 0;
  int _ordinal = 0;

  List<HabotEvent> get emitted => List<HabotEvent>.unmodifiable(_emitted);
  List<HabotSchemaFinding> get rejected =>
      List<HabotSchemaFinding>.unmodifiable(_rejected);

  int get attempted => _attempted;
  Iterable<HabotFunnelRun> get runs => _runs.values;

  HabotFunnelRun start({
    required String flowId,
    required int stepCount,
    required String traceId,
  }) {
    final HabotFunnelRun run = HabotFunnelRun(
      flowId: flowId,
      stepCount: stepCount,
      startedAt: _clock(),
      traceId: traceId,
    )..stepEnteredAt = _clock();
    _runs[flowId] = run;
    return run;
  }

  /// Record that the user is now looking at an error on this step. Set from
  /// the Step 149 navigation outcome, not guessed.
  void noteVisibleError(String flowId, {required bool visible}) {
    final HabotFunnelRun? run = _runs[flowId];
    if (run != null) {
      run.hadVisibleError = visible;
    }
  }

  /// A step completed. Emits the event the row asks for.
  HabotEvent? completeStep(String flowId) {
    final HabotFunnelRun? run = _runs[flowId];
    if (run == null) {
      return null;
    }
    final DateTime now = _clock();
    final Duration onStep = now.difference(run.stepEnteredAt ?? run.startedAt);
    final HabotEvent event = HabotEvent(
      kind: HabotEventKind.stepCompleted,
      view: view,
      traceId: run.traceId,
      occurredAt: now,
      sessionOrdinal: _ordinal++,
      payload: <String, Object?>{
        'flow_id': run.flowId,
        'step_index': run.stepIndex,
        'step_count': run.stepCount,
        'time_on_step_ms': onStep.inMilliseconds,
      },
    );
    final HabotEvent? kept = _emit(event);
    run
      ..stepIndex += 1
      ..stepEnteredAt = now
      ..hadVisibleError = false;
    if (run.stepIndex >= run.stepCount) {
      run.completed = true;
    }
    return kept;
  }

  /// **The inference.** Anything still open and not completed, at the moment
  /// the app learns the user has gone.
  ///
  /// Called from the Step 119 lifecycle observer on background, and again at
  /// session end. Idempotent per run: a user who backgrounds the app three
  /// times has abandoned once.
  List<HabotEvent> sweepAbandoned() {
    final List<HabotEvent> out = <HabotEvent>[];
    for (final HabotFunnelRun run in _runs.values) {
      if (run.completed || run.abandonmentRecorded) {
        continue;
      }
      run.abandonmentRecorded = true;
      final HabotEvent? kept = _emit(
        HabotEvent(
          kind: HabotEventKind.flowAbandoned,
          view: view,
          traceId: run.traceId,
          occurredAt: _clock(),
          sessionOrdinal: _ordinal++,
          payload: <String, Object?>{
            'flow_id': run.flowId,
            'step_index': run.stepIndex,
            'had_visible_error': run.hadVisibleError,
          },
        ),
      );
      if (kept != null) {
        out.add(kept);
      }
    }
    return out;
  }

  /// Validate, then emit. Never the other way round -- see the header.
  HabotEvent? _emit(HabotEvent event) {
    _attempted++;
    final List<HabotSchemaFinding> findings =
        HabotEventSchema.validate(event);
    if (findings.isNotEmpty) {
      _rejected.addAll(findings);
      return null;
    }
    _emitted.add(event);
    return event;
  }

  // ---- what the funnel is for ---------------------------------------------

  /// How many runs reached each step index, from the emitted events alone --
  /// so the figure is computed the way the warehouse would compute it rather
  /// than from in-memory state the warehouse will not have.
  Map<int, int> get reachedByStep {
    final Map<int, int> out = <int, int>{};
    for (final HabotEvent e in _emitted) {
      if (e.kind != HabotEventKind.stepCompleted) {
        continue;
      }
      final int i = e.payload['step_index']! as int;
      out[i] = (out[i] ?? 0) + 1;
    }
    return out;
  }

  /// Drop-off between two adjacent steps, as a share of those who reached the
  /// first. Null when nobody reached it -- a drop-off of "1.0" computed from
  /// zero arrivals is the most misleading number a funnel can produce.
  double? dropOffAfter(int stepIndex) {
    final int here = reachedByStep[stepIndex] ?? 0;
    if (here == 0) {
      return null;
    }
    final int next = reachedByStep[stepIndex + 1] ?? 0;
    return (here - next) / here;
  }

  /// Abandonments that had an error on screen. The actionable subset.
  int get abandonedWithVisibleError => _emitted
      .where((HabotEvent e) =>
          e.kind == HabotEventKind.flowAbandoned &&
          e.payload['had_visible_error'] == true)
      .length;

  int get abandonedTotal => _emitted
      .where((HabotEvent e) => e.kind == HabotEventKind.flowAbandoned)
      .length;

  // ---- the row's metric ---------------------------------------------------

  /// The share of attempted events that passed the Step 156 schema.
  double get schemaValidationRate =>
      _attempted == 0 ? 1 : _emitted.length / _attempted;

  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1.0;

  static const String flowSubstitution =
      'The row says "support ticket flows". The multi-step flow this app has '
      'is the Step 147 wizard, which is the same shape: numbered steps, a '
      'time per step and a drop-off point. The tracker is built to that shape '
      'rather than to tickets, so the first other flow does not require a '
      'rewrite.';

  static const String abandonmentNote =
      'Completions are easy; abandonment has no trigger. A tracker that only '
      'records completions can say 300 people reached step 4 and 120 reached '
      'step 5, and cannot say whether the other 180 gave up or are still '
      'typing. Abandonment is therefore INFERRED at the two moments the app '
      'learns about it -- backgrounding (Step 119) and session end -- and the '
      'inference is explicit rather than a side effect.';

  static const String validateBeforeEmitNote =
      'An event that fails the Step 156 schema is not emitted. Emitting it and '
      'letting the warehouse reject it would leave the app\'s own validation '
      'rate at 100% while the pipeline quietly dropped rows -- which is the '
      'version of this metric that is always green and never true.';
}
