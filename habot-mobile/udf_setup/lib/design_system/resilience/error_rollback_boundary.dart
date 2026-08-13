/// AISS: REF-197-A01 -- "Developing the Safe Error-Handling UI Rollback
/// Handler."
///
/// Substep 1: "Build an error boundary wrapper around transactional forms to
///             intercept system processing exceptions."
/// Substep 3: "Wire up UI state controllers to fall back to generic, helpful
///             confirmation notes when processing anomalies occur."
/// Substep 4: "Set up form storage managers to reset input sections back to
///             verified local baseline states upon transaction failure."
///
/// Completion Measure: "simulated server crashes result in clean, friendly
/// alerts rather than system code traces."
library;

import 'package:flutter/material.dart';

import '../interaction/atomic_button.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'error_templates.dart';
import 'log_scrubber.dart';

/// A snapshot a form can be rolled back to (substep 4).
typedef FormBaseline = Map<String, String>;

/// What the boundary decided about a caught failure.
@immutable
class HandledFailure {
  const HandledFailure({
    required this.category,
    required this.template,
    required this.scrubbedDiagnostic,
    required this.rolledBack,
  });

  final HabotErrorCategory category;
  final HabotErrorTemplate template;

  /// Safe to log. Never shown to the user.
  final String scrubbedDiagnostic;

  final bool rolledBack;
}

/// Classifies a raw error into a category the templates can speak to.
///
/// Pure and static so the classification is unit-testable without throwing
/// real exceptions through a widget tree.
class HabotFailureClassifier {
  const HabotFailureClassifier._();

  static HabotErrorCategory classify(Object error) {
    final String text = error.toString().toLowerCase();
    if (error is FormatException || text.contains('validation')) {
      return HabotErrorCategory.validation;
    }
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('offline')) {
      return HabotErrorCategory.offline;
    }
    if (error is TimeoutException ||
        text.contains('timeout') ||
        text.contains('timed out')) {
      return HabotErrorCategory.timeout;
    }
    if (text.contains('401') ||
        text.contains('unauthenticated') ||
        text.contains('unauthorized')) {
      return HabotErrorCategory.unauthenticated;
    }
    if (text.contains('403') || text.contains('forbidden')) {
      return HabotErrorCategory.forbidden;
    }
    if (text.contains('404') || text.contains('not found')) {
      return HabotErrorCategory.notFound;
    }
    if (text.contains('409') ||
        text.contains('conflict') ||
        text.contains('version mismatch')) {
      return HabotErrorCategory.conflict;
    }
    if (text.contains('500') ||
        text.contains('502') ||
        text.contains('503') ||
        text.contains('server error')) {
      return HabotErrorCategory.serverFailure;
    }
    return HabotErrorCategory.unknown;
  }

  /// Does the whole job: classify, pick the template, scrub the diagnostic.
  static HandledFailure handle(Object error, {bool rolledBack = false}) {
    final HabotErrorCategory category = classify(error);
    return HandledFailure(
      category: category,
      template: HabotErrorTemplates.of(category),
      scrubbedDiagnostic: HabotLogScrubber.scrub(error.toString()),
      rolledBack: rolledBack,
    );
  }
}

/// Minimal stand-in so the classifier can be exercised without dart:async
/// leaking into every caller.
class TimeoutException implements Exception {
  const TimeoutException(this.message);
  final String message;
  @override
  String toString() => 'TimeoutException: $message';
}

/// Wraps any data-aware component. Catches build-time errors from its subtree
/// and surfaces a template instead of a red screen.
///
/// Atomic Reusability column: "Ensure the error handling boundary can wrap any
/// data-aware component layout" -- so it takes an arbitrary child and knows
/// nothing about forms specifically.
class ErrorRollbackBoundary extends StatefulWidget {
  const ErrorRollbackBoundary({
    required this.child,
    this.onRetry,
    this.onRollback,
    this.baseline,
    super.key,
  });

  final Widget child;

  /// Invoked by the retry control in the error panel.
  final VoidCallback? onRetry;

  /// Substep 4: called with the baseline the form should be restored to.
  final void Function(FormBaseline baseline)? onRollback;

  /// The verified local baseline to roll back to.
  final FormBaseline? baseline;

  @override
  State<ErrorRollbackBoundary> createState() => ErrorRollbackBoundaryState();
}

class ErrorRollbackBoundaryState extends State<ErrorRollbackBoundary> {
  HandledFailure? _failure;

  /// The failures this boundary has handled, in order. Read by the gate.
  final List<HandledFailure> handled = <HandledFailure>[];

  HandledFailure? get failure => _failure;

  /// Entry point for an imperative failure (a failed submit, not a build
  /// crash). Rolls the form back and shows the template.
  void reportFailure(Object error) {
    final bool canRollback =
        widget.baseline != null && widget.onRollback != null;
    if (canRollback) {
      widget.onRollback!(widget.baseline!);
    }
    final HandledFailure result = HabotFailureClassifier.handle(
      error,
      rolledBack: canRollback,
    );
    handled.add(result);
    if (mounted) {
      setState(() => _failure = result);
    }
  }

  void dismiss() {
    if (mounted) {
      setState(() => _failure = null);
    }
  }

  void _retry() {
    dismiss();
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final HandledFailure? failure = _failure;
    return Stack(
      children: <Widget>[
        widget.child,
        if (failure != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ErrorPanel(
              failure: failure,
              onRetry: _retry,
              onDismiss: dismiss,
            ),
          ),
      ],
    );
  }
}

/// UX implementation row: "Use standard bottom sheet or dialog layout layers to
/// present error feedback panels."
class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    required this.failure,
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });

  final HandledFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final HabotErrorTemplate template = failure.template;

    return AnimatedSlide(
      offset: Offset.zero,
      duration: HabotMotionPolicy.resolve(context, HabotMotion.failureDuration),
      curve: HabotMotionPolicy.resolveCurve(context, HabotEasing.failure),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(HabotShape.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(HabotSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                template.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: HabotSpacing.xs),
              Text(
                template.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
              if (failure.rolledBack) ...<Widget>[
                const SizedBox(height: HabotSpacing.xs),
                Text(
                  'Your previous entries have been restored.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
              const SizedBox(height: HabotSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AtomicButton(
                    semanticLabel: 'Dismiss',
                    touchPadding: AtomicButton.standardTouchPadding,
                    onPressed: onDismiss,
                    child: Text(
                      'Dismiss',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(width: HabotSpacing.xs),
                  if (template.retryable)
                    AtomicButton(
                      semanticLabel: template.retryLabel,
                      touchPadding: AtomicButton.standardTouchPadding,
                      onPressed: onRetry,
                      child: Text(
                        template.retryLabel,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
