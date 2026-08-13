/// AISS: UFHT-032-A01 -- "UI Hesitation Tracker Engine Setup."
/// Setup Step Description: "Attach focus event listeners to every individual
/// input field within the target form."
/// Metric: Event Listener Coverage Rate (%) -- Floor 95.0, Optimal 99.0.
///
/// COLUMN CONTAMINATION, RECORDED HONESTLY: this row's Expected Output reads
/// "Historical Audit Report SQL" and its Completion Measure reads
/// "Row_Level_Audit_Coverage == 100%" -- both belong to a warehouse step, not
/// to a mobile UI one. The Setup Step, the Description and the Metric are
/// coherent and are what this implementation is gated against. The two
/// contaminated cells are not gated, and that exclusion is stated in the
/// evidence rather than hidden.
///
/// This is also the step TTMAC-014 (Step 14) named as the source of its
/// double-tap correction rate. That gate was deferred for one reason: no
/// telemetry existed to measure it. This file, with GEN-00632, is that
/// telemetry.
///
/// PRIVACY, BY CONSTRUCTION: no event carries a field value. The tracker
/// records that a field was focused, for how long, and how many corrections
/// followed -- never what was typed. There is no API here that accepts field
/// content, so a future caller cannot start logging it by accident.
library;

import 'package:flutter/widgets.dart';

import '../resilience/log_scrubber.dart';
import '../tokens/motion_tokens.dart';

/// What happened to a field.
enum HabotInteractionKind {
  /// The field took focus.
  focus,

  /// The field lost focus.
  blur,

  /// The user cleared or backspaced through content they had already entered.
  correction,

  /// Two taps on the same target inside [HabotMotion.doubleTapWindow].
  doubleTapCorrection,
}

/// One recorded interaction. Deliberately value-free.
class HabotInteractionEvent {
  const HabotInteractionEvent({
    required this.field,
    required this.kind,
    required this.at,
    this.dwell = Duration.zero,
  });

  /// The field's declared name -- never its contents.
  final String field;

  final HabotInteractionKind kind;
  final DateTime at;

  /// How long focus had been held when this event fired.
  final Duration dwell;

  /// True when the dwell before this event reads as hesitation rather than
  /// ordinary typing.
  bool get isHesitation => dwell >= HabotMotion.hesitationDwell;

  Map<String, Object?> toJson() => <String, Object?>{
    'field': HabotLogScrubber.scrub(field),
    'kind': kind.name,
    'at': at.toIso8601String(),
    'dwell_ms': dwell.inMilliseconds,
    'hesitation': isHesitation,
  };
}

/// The engine.
///
/// A field cannot be tracked without first being registered, and
/// [ValidatedInputField] does both in one call during `initState`. That is what
/// makes [listenerCoverage] structural: coverage is not a number someone
/// remembers to keep at 100, it is 100 unless a field is constructed outside
/// the design system entirely -- which the poka-yoke guard already forbids.
class HabotHesitationTracker extends ChangeNotifier {
  HabotHesitationTracker({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// The app-wide instance. Injectable in tests via [HabotHesitationTracker.new].
  static HabotHesitationTracker instance = HabotHesitationTracker();

  /// Replaces the app-wide instance. Used by the gates to get a deterministic
  /// clock; not called in production.
  static void useInstance(HabotHesitationTracker tracker) {
    instance = tracker;
  }

  final DateTime Function() _clock;

  final Set<String> _registered = <String>{};
  final Set<String> _attached = <String>{};
  final List<HabotInteractionEvent> _events = <HabotInteractionEvent>[];
  final Map<String, DateTime> _focusedAt = <String, DateTime>{};
  final Map<String, DateTime> _lastTapAt = <String, DateTime>{};

  List<HabotInteractionEvent> get events =>
      List<HabotInteractionEvent>.unmodifiable(_events);

  Set<String> get registeredFields => Set<String>.unmodifiable(_registered);
  Set<String> get attachedFields => Set<String>.unmodifiable(_attached);

  /// The metric this step is measured by: percentage of registered fields that
  /// actually carry a focus listener.
  double get listenerCoverage =>
      _registered.isEmpty ? 100 : (_attached.length / _registered.length) * 100;

  /// Declares that a field exists and must be instrumented.
  void registerField(String field) {
    _registered.add(field);
  }

  /// Attaches the focus listener substep 1 asks for. Returns the listener so a
  /// widget can detach it on dispose.
  VoidCallback attach(String field, FocusNode node) {
    registerField(field);
    void listener() {
      if (node.hasFocus) {
        recordFocus(field);
      } else {
        recordBlur(field);
      }
    }

    node.addListener(listener);
    _attached.add(field);
    return listener;
  }

  /// Detaches without pretending the field was never there: it stays
  /// registered, so a widget that drops its listener shows up as a coverage
  /// shortfall rather than disappearing from the denominator.
  void detach(String field, FocusNode node, VoidCallback listener) {
    node.removeListener(listener);
    _attached.remove(field);
  }

  void recordFocus(String field) {
    _focusedAt[field] = _clock();
    _record(field, HabotInteractionKind.focus);
  }

  void recordBlur(String field) {
    _record(field, HabotInteractionKind.blur);
    _focusedAt.remove(field);
  }

  /// A correction: the user removed content they had already entered.
  void recordCorrection(String field) {
    _record(field, HabotInteractionKind.correction);
  }

  /// A tap on [target]. Two inside [HabotMotion.doubleTapWindow] are recorded
  /// as one double-tap correction -- the signal TTMAC-014 is waiting for.
  ///
  /// Returns true when this tap completed a double-tap correction.
  bool recordTap(String target) {
    final DateTime now = _clock();
    final DateTime? previous = _lastTapAt[target];
    _lastTapAt[target] = now;
    _taps++;
    if (previous != null &&
        now.difference(previous) <= HabotMotion.doubleTapWindow) {
      _record(target, HabotInteractionKind.doubleTapCorrection);
      return true;
    }
    return false;
  }

  int _taps = 0;

  /// Every tap seen, including the ones that were not corrections.
  int get tapCount => _taps;

  int countOf(HabotInteractionKind kind) =>
      _events.where((HabotInteractionEvent e) => e.kind == kind).length;

  /// TTMAC-014's completion measure, as a percentage.
  double get doubleTapCorrectionRate => _taps == 0
      ? 0
      : (countOf(HabotInteractionKind.doubleTapCorrection) / _taps) * 100;

  /// How often a field was held without progress long enough to read as
  /// hesitation.
  double get hesitationRate => _events.isEmpty
      ? 0
      : (_events.where((HabotInteractionEvent e) => e.isHesitation).length /
                _events.length) *
            100;

  void reset() {
    _registered.clear();
    _attached.clear();
    _events.clear();
    _focusedAt.clear();
    _lastTapAt.clear();
    _taps = 0;
  }

  void _record(String field, HabotInteractionKind kind) {
    final DateTime now = _clock();
    final DateTime? since = _focusedAt[field];
    _events.add(
      HabotInteractionEvent(
        field: field,
        kind: kind,
        at: now,
        dwell: since == null ? Duration.zero : now.difference(since),
      ),
    );
    notifyListeners();
  }
}
