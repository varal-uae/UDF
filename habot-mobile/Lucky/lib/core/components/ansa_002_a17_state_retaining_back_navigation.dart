// ANSA-002-A17 — State-Retaining Back Navigation Component.
// Intercepts back button and iOS swipe gestures, caching form data before the route is disposed.
// Provides a reusable in-memory cache and back button to prevent data loss in multi-step flows.

import 'package:flutter/material.dart';

/// In-memory cache for preserving form data across backward navigation.
class StepDataCache {
  StepDataCache._();

  static final Map<String, Map<String, dynamic>> _store = {};

  static void save(String stepId, Map<String, dynamic> data) {
    _store[stepId] = Map.of(data);
  }

  static Map<String, dynamic>? read(String stepId) {
    final data = _store[stepId];
    return data == null ? null : Map.of(data);
  }

  static void clear(String stepId) {
    _store.remove(stepId);
  }
}

/// Wraps a step screen and guarantees onCacheBeforePop runs when a pop is invoked.
class StateRetainingPopScope extends StatelessWidget {
  const StateRetainingPopScope({
    super.key,
    required this.child,
    required this.stepId,
    this.onCacheBeforePop,
  });

  final Widget child;
  final String stepId;
  final void Function(String stepId)? onCacheBeforePop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          onCacheBeforePop?.call(stepId);
        }
      },
      child: child,
    );
  }
}

/// A back button styled for secondary actions; uses the retention scope automatically.
class StateRetainingBackButton extends StatelessWidget {
  const StateRetainingBackButton({
    super.key,
    this.onPressed,
    this.tooltip = 'Back',
  });

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: tooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}
