// RIMV-018-A18 — LoadingFormContainer: DOM Element Disabling Framework linked to Loading Flags.
// A shared form container layout that locks components automatically when processing updates, dims inputs uniformly, dismisses keyboards, and blocks pointer interactions during network transfers following Material 3 standards.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Documentation:
/// Purpose: Prevents users from altering input values while the data model is being transferred to servers.
/// Usage: Wrap any form content inside [LoadingFormContainer] and toggle [isLoading] via your state management.
/// Example:
/// ```dart
/// LoadingFormContainer(
///   isLoading: _isSubmitting,
///   child: Form(
///     child: Column(
///       children: [
///         TextFormField(decoration: InputDecoration(labelText: 'Name')),
///         ElevatedButton(onPressed: _submit, child: Text('Submit')),
///       ],
///     ),
///   ),
/// )
/// ```
class LoadingFormContainer extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color? disabledOverlayColor;
  final double disabledOpacity;

  const LoadingFormContainer({
    super.key,
    required this.isLoading,
    required this.child,
    this.disabledOverlayColor,
    this.disabledOpacity = 0.6,
  });

  @override
  State<LoadingFormContainer> createState() => _LoadingFormContainerState();
}

class _LoadingFormContainerState extends State<LoadingFormContainer> {
  @override
  void didUpdateWidget(covariant LoadingFormContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dismissing active mobile software keyboards automatically when forms enter loading modes.
    if (widget.isLoading && !oldWidget.isLoading) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color overlayColor = widget.disabledOverlayColor ??
        theme.colorScheme.surface.withOpacity(0.4);

    return AbsorbPointer(
      // Blocks pointer interaction events completely across the screen to preserve the current data transaction.
      absorbing: widget.isLoading,
      child: AnimatedOpacity(
        // Dropping component layout contrast ratios uniformly to show inactive statuses.
        opacity: widget.isLoading ? widget.disabledOpacity : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            widget.child,
            if (widget.isLoading)
              Positioned.fill(
                child: Container(
                  color: overlayColor,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator.adaptive(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper for individual interactive elements to ensure they map the main
/// loading flag directly to the native disabled properties of all form components.
class LoadingAwareFormField extends StatelessWidget {
  final bool isLoading;
  final Widget Function(bool isDisabled) builder;

  const LoadingAwareFormField({
    super.key,
    required this.isLoading,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Removing touch feedback animations from locked elements to clarify they are un-clickable.
    return IgnorePointer(
      ignoring: isLoading,
      child: builder(isLoading),
    );
  }
}

/// Mixin or extension to be used by parent containers to intercept and block
/// submit commands internally if state systems report an active processing cycle.
mixin FormSubmissionGuard<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<void> guardSubmission(Future<void> Function() onSubmit) async {
    if (_isProcessing) {
      // Poka-Yoke: The parent container intercepts and blocks submit commands internally.
      debugPrint('Submission blocked: Active processing cycle detected.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await onSubmit();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}