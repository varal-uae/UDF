// ANSA-002-A11 — State-Retaining Back Button & Navigation Guard.
// A reusable back navigation control that preserves validated form memory across multi-step workflows and automatically caches field state on blur.
import 'package:flutter/material.dart';

/// A Material 3 back button that invokes a cache callback before navigating away,
/// preventing accidental data loss during backward form navigation.
class StateRetainingBackButton extends StatelessWidget {
  const StateRetainingBackButton({
    super.key,
    this.onBack,
    this.onCacheState,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip = 'Back — your entries are saved automatically',
  });

  /// Called before [onBack] to persist any unsaved field state.
  final VoidCallback? onCacheState;

  /// Called after state caching to pop or navigate backward.
  final VoidCallback? onBack;

  /// Optional transparent background accent, following secondary action hierarchy.
  final Color? backgroundColor;

  /// Optional icon/label color.
  final Color? foregroundColor;

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color effectiveBackground = backgroundColor ?? colorScheme.secondaryContainer.withOpacity(0.15);
    final Color effectiveForeground = foregroundColor ?? colorScheme.onSecondaryContainer;

    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        onCacheState?.call();
        onBack?.call();
      },
      icon: const Icon(Icons.arrow_back_rounded),
      style: IconButton.styleFrom(
        backgroundColor: effectiveBackground,
        foregroundColor: effectiveForeground,
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Mixin that can be attached to form screens to automatically cache field state
/// on every blur event and preserve validated inputs during backward navigation.
mixin StateRetentionFormMixin<T extends StatefulWidget> on State<T> {
  final Map<String, dynamic> _fieldCache = <String, dynamic>{};

  /// Register a TextEditingController so its current value is stored on blur.
  void cacheOnBlur(String key, TextEditingController controller, FocusNode focusNode) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _fieldCache[key] = controller.text;
      }
    });
  }

  /// Restore a cached value into a controller, typically during init or before build.
  void restoreCachedValue(String key, TextEditingController controller) {
    final dynamic value = _fieldCache[key];
    if (value is String) {
      controller.text = value;
    }
  }

  /// Clears all cached form state, used when the form is explicitly submitted or reset.
  void clearCachedFormState() {
    _fieldCache.clear();
  }
}