/// AISS: GEN-01363-A01 -- "Bind the client UI error boundaries to trigger M3
/// error Snackbars upon caught exceptions."
///
/// This is the step that could not be built in the previous batch: every
/// snackbar row then available in the sheet had output columns belonging to
/// another domain. This one is clean, and it lands on top of REF-197's error
/// boundary, templates and log scrubber rather than duplicating them.
///
/// The rule this file enforces: an exception may reach the user only after it
/// has been classified into a template and scrubbed. There is no API here that
/// takes a raw error message and shows it.
library;

import 'package:flutter/material.dart';

import '../resilience/error_rollback_boundary.dart';
import '../resilience/error_templates.dart';
import '../resilience/log_scrubber.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// Builds and shows the error snackbar.
class HabotErrorSnackbar {
  const HabotErrorSnackbar._();

  /// The message a user sees for [failure]. Always the template's own words --
  /// never the exception's.
  static String messageFor(HandledFailure failure) =>
      '${failure.template.title}. ${failure.template.body}';

  /// How long the snackbar holds the screen. Longer when there is an action,
  /// because the user has to decide something rather than just read.
  static Duration durationFor(HandledFailure failure) =>
      failure.template.retryable
      ? HabotMotion.snackbarDisplayWithAction
      : HabotMotion.snackbarDisplay;

  /// Builds the M3 error snackbar for [failure].
  ///
  /// Colour comes from the audited error-container pair, which TTMCS-005
  /// already measured at 6.36:1 (light) and 10.91:1 (dark) -- so the snackbar
  /// inherits its contrast guarantee instead of asserting a new one.
  static SnackBar buildFor(
    BuildContext context,
    HandledFailure failure, {
    VoidCallback? onRetry,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SnackBar(
      content: Text(
        messageFor(failure),
        maxLines: HabotFeedback.snackbarMaxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: scheme.onErrorContainer),
      ),
      backgroundColor: scheme.errorContainer,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: HabotFeedback.snackbarHorizontalMargin,
        vertical: HabotFeedback.snackbarVerticalMargin,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(HabotFeedback.snackbarCornerRadius),
        ),
      ),
      duration: durationFor(failure),
      action: failure.template.retryable && onRetry != null
          ? SnackBarAction(
              label: failure.template.retryLabel,
              textColor: scheme.onErrorContainer,
              onPressed: onRetry,
            )
          : null,
    );
  }

  /// Classifies, scrubs and shows. The only entry point that accepts a raw
  /// error, and it never puts that error on screen.
  static void showError(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
  }) {
    show(context, HabotFailureClassifier.handle(error), onRetry: onRetry);
  }

  static void show(
    BuildContext context,
    HandledFailure failure, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(buildFor(context, failure, onRetry: onRetry));
  }

  /// True when [text] carries nothing a user should not see. The gate runs the
  /// rendered snackbar message through this, so the guarantee is checked
  /// against what is actually on screen rather than against intent.
  static bool isPresentable(String text) =>
      HabotLogScrubber.isClean(text) &&
      !HabotErrorTemplates.forbiddenJargon.any(
        (String jargon) => text.toLowerCase().contains(jargon),
      );
}

/// A boundary that surfaces failures as snackbars rather than as a panel.
///
/// Both presentations exist because they answer different questions. A panel
/// stays until dismissed and can explain a rollback; a snackbar is right when
/// the failure is transient and the screen behind it is still usable. The
/// boundary owns which one it uses so the choice is made once per surface, not
/// once per error.
class SnackbarErrorBoundary extends StatefulWidget {
  const SnackbarErrorBoundary({
    required this.child,
    this.onRetry,
    super.key,
  });

  final Widget child;
  final VoidCallback? onRetry;

  @override
  State<SnackbarErrorBoundary> createState() => SnackbarErrorBoundaryState();
}

class SnackbarErrorBoundaryState extends State<SnackbarErrorBoundary> {
  /// Every failure this boundary has surfaced, in order. Read by the gate.
  final List<HandledFailure> surfaced = <HandledFailure>[];

  /// Entry point for a caught exception.
  void reportFailure(Object error) {
    final HandledFailure failure = HabotFailureClassifier.handle(error);
    surfaced.add(failure);
    if (mounted) {
      HabotErrorSnackbar.show(context, failure, onRetry: widget.onRetry);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Padding token re-export so callers never reach for a raw number when
/// spacing content above a floating snackbar.
class HabotSnackbarInsets {
  const HabotSnackbarInsets._();

  static const double reservedBottomSpace =
      HabotSpacing.xxxl + HabotFeedback.snackbarVerticalMargin;

  static const double cornerRadius = HabotShape.xs;
}
