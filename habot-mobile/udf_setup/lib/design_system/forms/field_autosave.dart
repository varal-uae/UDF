/// AISS Step 153 -- GEN-02588
/// Setup Step (Action) / Atomic Step: "Configure the forms to auto-save
///   granularly per field, preventing complete data loss if the user drops off
///   (Self-Chasing)."
/// Metric: API Response Latency (ms) -- Floor 0.0, Optimal 100-300,
///         Ceiling 500.0. Good / Average / Poor.
///
/// **"PREVENTING COMPLETE DATA LOSS" IS THE REQUIREMENT, AND IT IS ABOUT WHAT
/// SURVIVES, NOT ABOUT WHAT IS SENT.** An autosave that posts each field to a
/// server and keeps nothing locally loses everything the moment the network
/// does -- which is the same moment a user is most likely to give up and close
/// the app. So a field is saved LOCALLY first and queued second, which is the
/// Step 112 contract, and the value is durable before any request exists.
///
/// **GRANULAR MEANS PER FIELD, AND THE STEP 117 DEDUPE IS THE WRONG TOOL FOR
/// IT.** The outbox dedupes by id and keeps the FIRST entry, which is exactly
/// right for an idempotent mutation and exactly wrong for a field whose LATEST
/// value is the true one: a user correcting a typo would have their first
/// attempt delivered and the correction dropped. So each save gets its own
/// entry carrying a per-field revision, and the payload names the entry it
/// supersedes -- last write wins, ordered by a number rather than by arrival.
/// Saving on every keystroke would still put a hundred writes behind one
/// answer, so a field is saved when it SETTLES: on blur, on step advance, or
/// after the Step 33 typing pause.
///
/// **THE METRIC IS THE BUDGET FOR ONE OF THOSE SAVES**, read as at Step 147:
/// splitting a form into single questions turns one write into N, so each has
/// to be cheap enough to disappear inside a step transition. Under 500ms or
/// the wizard fights the user at every step.
///
/// **A FAILED SAVE MUST NOT LOSE THE VALUE.** This is where autosave usually
/// goes wrong: the write fails, the UI clears its dirty flag anyway, and the
/// answer exists nowhere. Here a failure leaves the value in the draft and the
/// field marked unsaved, and [HabotFieldAutosave.unsavedFields] names them --
/// so "saved" is a fact rather than an assumption.
library;

import '../data/outbox.dart';
import '../tokens/motion_tokens.dart';

/// What triggered a save.
enum HabotSaveTrigger {
  /// The field lost focus.
  blur,

  /// The wizard advanced past the step holding it.
  stepAdvance,

  /// Typing paused for the Step 33 debounce.
  typingPause,
}

/// The outcome of one field save.
class HabotSaveOutcome {
  const HabotSaveOutcome({
    required this.fieldName,
    required this.persistedLocally,
    required this.queued,
    required this.elapsed,
    required this.trigger,
    this.error,
  });

  final String fieldName;

  /// The half that prevents data loss.
  final bool persistedLocally;

  /// The half that eventually reaches the server.
  final bool queued;

  final Duration elapsed;
  final HabotSaveTrigger trigger;
  final Object? error;

  bool get isSaved => persistedLocally;
}

/// Per-field autosave.
class HabotFieldAutosave {
  HabotFieldAutosave({
    required this.outbox,
    required Future<void> Function(String field, String value) writeLocal,
    required this.formId,
    DateTime Function()? clock,
  })  : _writeLocal = writeLocal,
        _clock = clock ?? DateTime.now;

  final HabotOutbox outbox;
  final Future<void> Function(String field, String value) _writeLocal;
  final String formId;
  final DateTime Function() _clock;

  static const String outboxKind = 'form_field_autosave';

  /// Saving on every keystroke would put a hundred writes behind one answer.
  /// Reuses the Step 33 search debounce rather than declaring a second idea
  /// of "typing has paused".
  static Duration get typingPause => HabotMotion.searchDebounce;

  final Map<String, String> _draft = <String, String>{};
  final Set<String> _saved = <String>{};
  final Map<String, int> _revisions = <String, int>{};
  final List<HabotSaveOutcome> _outcomes = <HabotSaveOutcome>[];

  Map<String, String> get draft => Map<String, String>.unmodifiable(_draft);

  List<HabotSaveOutcome> get outcomes =>
      List<HabotSaveOutcome>.unmodifiable(_outcomes);

  /// Fields whose value exists only in memory. Empty is the requirement, and
  /// the reason the list exists is that "saved" has to be a fact rather than
  /// an assumption.
  List<String> get unsavedFields =>
      _draft.keys.where((String f) => !_saved.contains(f)).toList();

  /// The current revision of a field. Starts at zero, increments on each
  /// save. This is what the server orders by.
  int revisionOf(String field) => _revisions[field] ?? 0;

  /// The queue id for one save of a field. Carries the revision, because the
  /// Step 117 outbox keeps the FIRST entry for a given id -- correct for an
  /// idempotent mutation, wrong for a field whose latest value is the true
  /// one. See the header.
  String queueIdFor(String field, int revision) =>
      '$formId:$field:r$revision';

  /// Record what the user has typed, without saving it yet.
  void hold(String field, String value) {
    _draft[field] = value;
    _saved.remove(field);
  }

  /// Save one field.
  Future<HabotSaveOutcome> save(
    String field, {
    required HabotSaveTrigger trigger,
  }) async {
    final DateTime start = _clock();
    final String value = _draft[field] ?? '';
    bool local = false;
    bool queued = false;
    Object? failure;
    try {
      await _writeLocal(field, value);
      local = true;
      final int previous = revisionOf(field);
      final int revision = previous + 1;
      await outbox.enqueue(
        id: queueIdFor(field, revision),
        kind: outboxKind,
        payload: <String, Object?>{
          'form_id': formId,
          'field': field,
          'value': value,
          'field_revision': revision,
          'supersedes': previous == 0 ? null : queueIdFor(field, previous),
          'trigger': trigger.name,
          'held_at': start.toUtc().toIso8601String(),
        },
      );
      _revisions[field] = revision;
      queued = true;
      _saved.add(field);
    } on Object catch (e) {
      failure = e;
      // The value stays in the draft and the field stays unsaved. Clearing a
      // dirty flag on a failed write is how an answer ends up existing
      // nowhere.
    }
    final HabotSaveOutcome outcome = HabotSaveOutcome(
      fieldName: field,
      persistedLocally: local,
      queued: queued,
      elapsed: _clock().difference(start),
      trigger: trigger,
      error: failure,
    );
    _outcomes.add(outcome);
    return outcome;
  }

  /// Save everything on a step. Used when the wizard advances.
  Future<List<HabotSaveOutcome>> saveStep(Iterable<String> fields) async {
    final List<HabotSaveOutcome> out = <HabotSaveOutcome>[];
    for (final String f in fields) {
      out.add(await save(f, trigger: HabotSaveTrigger.stepAdvance));
    }
    return out;
  }

  /// What a user gets back after dropping off. The "Self-Chasing" half of the
  /// row: the answers are here, not lost, and the form reopens where it was.
  Map<String, String> restore() => Map<String, String>.from(_draft);

  // ---- the row's metric ---------------------------------------------------

  static Duration get optimalMin => HabotMotion.formStepCommitOptimalMin;
  static Duration get optimalMax => HabotMotion.formStepCommitOptimalMax;
  static Duration get ceiling => HabotMotion.formStepCommitCeiling;

  Duration get slowestSave {
    Duration worst = Duration.zero;
    for (final HabotSaveOutcome o in _outcomes) {
      if (o.elapsed > worst) {
        worst = o.elapsed;
      }
    }
    return worst;
  }

  /// The share of saves inside the row's ceiling.
  double get withinCeilingRate => _outcomes.isEmpty
      ? 1
      : _outcomes
              .where((HabotSaveOutcome o) => o.elapsed <= ceiling)
              .length /
          _outcomes.length;

  /// The row's vocabulary, for the slowest save observed. The slowest rather
  /// than the mean: a mean hides the one step that made someone wait.
  String get band {
    final Duration d = slowestSave;
    if (d <= optimalMax) {
      return 'Good';
    }
    return d <= ceiling ? 'Average' : 'Poor';
  }

  /// Fields that were lost. The number the row's stated purpose is about.
  int get fieldsLost => unsavedFields.length;

  static const String localFirstNote =
      '"Preventing complete data loss" is about what survives, not about what '
      'is sent. An autosave that posts each field and keeps nothing locally '
      'loses everything the moment the network does -- which is the same '
      'moment a user is most likely to give up and close the app. The field is '
      'written locally first and queued second, which is the Step 112 '
      'contract, so the value is durable before any request exists.';

  static const String revisionNote =
      'The Step 117 outbox dedupes by id and keeps the FIRST entry, which is '
      'right for an idempotent mutation and wrong for a field whose latest '
      'value is the true one -- a user correcting a typo would have their '
      'first attempt delivered and the correction dropped. Each save '
      'therefore gets its own entry carrying a per-field revision, and names '
      'the entry it supersedes, so last write wins by a number rather than by '
      'arrival order.';

  static const String failureKeepsValueNote =
      'A failed save leaves the value in the draft and the field marked '
      'unsaved. This is where autosave usually goes wrong: the write fails, '
      'the UI clears its dirty flag anyway, and the answer exists nowhere. '
      'unsavedFields names them, so "saved" is a fact rather than an '
      'assumption.';
}
