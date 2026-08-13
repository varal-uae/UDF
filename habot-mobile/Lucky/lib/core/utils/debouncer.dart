import 'dart:async';

// VPVMP-021-02 — Debounce utility.
// Wraps any callback with a delay timer.
// Cancels and restarts the timer on every call — fires only after user stops.
// Hardcoded defaults per spec: 300ms for input, 800ms for auto-save.

class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;

  /// Cancels any pending call and schedules [action] after [delay].
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending call immediately.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the timer. Call in widget dispose().
  void dispose() => cancel();

  bool get isPending => _timer?.isActive ?? false;
}

// Hardcoded intervals per spec
class DebounceDuration {
  /// 300ms — fires after user stops typing. Used on all text input handlers.
  static const input = Duration(milliseconds: 300);

  /// 800ms — background auto-save interval. Used on all form entry fields.
  static const autoSave = Duration(milliseconds: 800);
}

typedef VoidCallback = void Function();
