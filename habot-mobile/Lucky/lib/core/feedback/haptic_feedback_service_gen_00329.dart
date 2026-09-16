// GEN-00329 — Material Design 3 Haptic Interaction Service.
// Centralized, M3-aligned haptic feedback utility mapping semantic interaction
// intents (selection, confirmation, success, warning, error) to Flutter haptics,
// with throttling to prevent haptic spam and a global enable/disable toggle.

import 'dart:async';

import 'package:flutter/services.dart';

/// Semantic haptic intents aligned with Material Design 3 interaction guidance.
///
/// M3 recommends haptics be subtle, purposeful, and reserved for meaningful
/// moments: confirmations, destructive actions, errors, and selection changes.
enum HapticIntent {
  /// Light tick for selection changes (chips, tabs, pickers, toggles).
  selection,

  /// Gentle impact for standard tap confirmations on primary actions.
  confirm,

  /// Medium impact for successful completion of a task or step.
  success,

  /// Medium impact for cautionary / warning states.
  warning,

  /// Heavy impact for errors or destructive/irreversible actions.
  error,

  /// Notification-style feedback for async completion events.
  notification,
}

/// Production haptic feedback service implementing Material Design 3
/// haptic interaction guidelines.
///
/// Usage:
/// ```dart
/// await HapticFeedbackServiceGen00329.instance.trigger(HapticIntent.confirm);
/// ```
class HapticFeedbackServiceGen00329 {
  HapticFeedbackServiceGen00329._();

  /// Shared singleton instance.
  static final HapticFeedbackServiceGen00329 instance =
      HapticFeedbackServiceGen00329._();

  /// Minimum interval between haptic triggers to avoid haptic spam during
  /// rapid interactions (e.g. fast scrolling through selectable items).
  static const Duration _throttleInterval = Duration(milliseconds: 50);

  DateTime? _lastTriggerAt;
  bool _enabled = true;

  /// Globally enables or disables haptic feedback (e.g. from user settings).
  bool get isEnabled => _enabled;

  /// Updates the global haptic preference. When disabled, [trigger] is a no-op.
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Triggers haptic feedback for the given [intent].
  ///
  /// Returns `true` if feedback was actually dispatched, `false` when the
  /// call was skipped due to throttling or the service being disabled.
  Future<bool> trigger(HapticIntent intent) async {
    if (!_enabled) return false;

    final now = DateTime.now();
    final last = _lastTriggerAt;
    if (last != null && now.difference(last) < _throttleInterval) {
      return false;
    }
    _lastTriggerAt = now;

    switch (intent) {
      case HapticIntent.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticIntent.confirm:
        await HapticFeedback.lightImpact();
        break;
      case HapticIntent.success:
        await HapticFeedback.mediumImpact();
        break;
      case HapticIntent.warning:
        await HapticFeedback.mediumImpact();
        break;
      case HapticIntent.error:
        await HapticFeedback.heavyImpact();
        break;
      case HapticIntent.notification:
        await HapticFeedback.vibrate();
        break;
    }
    return true;
  }

  /// Convenience helper for button press confirmations.
  Future<bool> onButtonPressed() => trigger(HapticIntent.confirm);

  /// Convenience helper for selection changes (chips, tabs, switches).
  Future<bool> onSelectionChanged() => trigger(HapticIntent.selection);

  /// Convenience helper for successful task completion.
  Future<bool> onSuccess() => trigger(HapticIntent.success);

  /// Convenience helper for validation or runtime errors.
  Future<bool> onError() => trigger(HapticIntent.error);

  /// Resets internal throttle state. Intended primarily for tests.
  void resetForTesting() {
    _lastTriggerAt = null;
    _enabled = true;
  }
}

/// Mixin providing ergonomic haptic helpers on widgets that already manage
/// user interactions, keeping call sites terse and consistent.
mixin HapticInteractionMixin {
  /// The haptic service used by this mixin. Override to inject a fake in tests.
  HapticFeedbackServiceGen00329 get haptics =>
      HapticFeedbackServiceGen00329.instance;

  /// Wraps an action callback with a confirmation haptic before execution.
  Future<void> withConfirmHaptic(FutureOr<void> Function() action) async {
    await haptics.trigger(HapticIntent.confirm);
    await action();
  }

  /// Wraps an action callback with a selection haptic before execution.
  Future<void> withSelectionHaptic(FutureOr<void> Function() action) async {
    await haptics.trigger(HapticIntent.selection);
    await action();
  }
}
