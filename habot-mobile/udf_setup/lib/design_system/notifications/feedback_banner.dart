/// Three sheet rows, one component.
///
/// AISS: PNSAD-026-A01 -- "Build Floating Bottom Snackbar Feedback Banner."
/// AISS: HSFVS-012-A01 -- "Implement M3 Snackbar for DCYN Failures."
/// AISS: EDBAA-001-A01 -- "Design the 'Liveness Handshake' Failure Toast."
///
/// THIS IS THE ARCHITECTURAL DECISION OF THE BATCH, so it is stated up front.
/// The sheet asks for a floating bottom snackbar, a snackbar for a specific
/// failure class, and a toast for another specific failure class. Built
/// literally that would be three components with three positions, three
/// durations and three sets of margins -- and `HabotErrorSnackbar` from
/// Step 25 already exists with all three of those settled and gated.
///
/// So: one placement policy (PNSAD-026), and two bound failure sources
/// (HSFVS-012, EDBAA-001) that route through the snackbar that already exists.
/// The gates for Steps 71 and 72 assert the reuse rather than describe it --
/// `HSFVS-012-G1` and `EDBAA-001-G1` fail if a second SnackBar is constructed
/// anywhere under `lib/`.
///
/// ---------------------------------------------------------------------
/// PNSAD-026 (Step 70)
/// Setup Step Description: "Apply CSS positioning rules to anchor the
/// component to the bottom-center of the viewport (e.g. position: fixed;
/// bottom: 16px;)."
/// Metric: UI Element Placement Accuracy (%) -- Floor 98.0, Optimal 99.9,
///         Ceiling 100.0.
///
/// CONTAMINATED ROW, RECORDED: nine columns describe BigQuery row-level
/// security -- Decision Before ("How are super-admin or cross-tenant reporting
/// roles handled within the RLS framework?"), Expected Output ("Enforced RLS
/// Policies"), Completion Measures ("A query run by Tenant A's service account
/// returns 0 rows belonging to Tenant B"). None are gated. The Setup Step, the
/// Setup Step Description and the Metric are coherent, and the metric fits
/// this step exactly: anchor the component, then measure where it landed.
///
/// The description is written in CSS. This is Flutter, so "position: fixed;
/// bottom: 16px" translates to a floating SnackBarBehavior with a bottom
/// margin from the spacing scale -- which is what Step 25 already configured.
/// The translation is stated rather than quietly performed.
///
/// ---------------------------------------------------------------------
/// HSFVS-012 (Step 71)
/// Setup Step Description: "Design the snackbar layout positioned at the
/// bottom of the mobile screen."
/// Metric: NAME IS EMPTY IN THE SHEET. Only the bands are populated --
/// Floor 0.8, Optimal 90-98%, Ceiling 1.0. Bands without a name cannot be
/// reported against, and the omission is recorded rather than a name invented.
/// Data Collected IS coherent: "Layout Type; Layout Grid Dimensions; Spacing
/// Rules; Alignment Settings; Layout Validation Status."
///
/// CONTAMINATED ROW, RECORDED: Expected Output is "Terraform CORS policy
/// rules" and the poka-yoke bans wildcard origins in production.
///
/// ---------------------------------------------------------------------
/// EDBAA-001 (Step 72)
/// Metric: "TLS Protocol Compliance Rate" -- which is not a property of a
/// toast. Recorded as NOT PRODUCED; no number is asserted in its place.
///
/// CONTAMINATED ROW, RECORDED: ten columns describe a sign-up screen and a TLS
/// posture. What is coherent is the Setup Step itself, and the Self-Chasing
/// concept it names, which appears in the Self-Chasing column of nearly every
/// row in the sheet.
library;

import 'package:flutter/material.dart';

import '../feedback/error_snackbar.dart';
import '../resilience/error_rollback_boundary.dart';
import '../resilience/error_templates.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// PNSAD-026: the placement policy, as numbers that can be measured against.
class HabotFeedbackPlacement {
  const HabotFeedbackPlacement._();

  /// "bottom: 16px" from the Setup Step Description, expressed as the token
  /// the design system already uses for that distance. Step 25 configured the
  /// snackbar with this; naming it here is what makes it assertable.
  static const double bottomInset = HabotFeedback.snackbarVerticalMargin;
  static const double horizontalInset =
      HabotFeedback.snackbarHorizontalMargin;

  /// "bottom-CENTER of the viewport." Centring is a property of the rendered
  /// rect, not of a parameter, so the gate measures it.
  static const double centreToleranceDp = 1.0;

  /// Metric bands, from the sheet.
  static const double placementFloor = 98.0;
  static const double placementOptimal = 99.9;
  static const double placementCeiling = 100.0;

  /// How accurately a rendered rect sits where the policy says, as a
  /// percentage. 100 when the horizontal centre and the bottom inset are both
  /// exact; falls off linearly with the error, measured against the viewport
  /// so the number means the same thing on every device.
  static double accuracyFor({
    required Rect rendered,
    required Size viewport,
  }) {
    final double centreError =
        (rendered.center.dx - (viewport.width / 2)).abs();
    final double bottomError =
        ((viewport.height - rendered.bottom) - bottomInset).abs();
    final double centreScore =
        (1 - (centreError / (viewport.width / 2))).clamp(0.0, 1.0);
    final double bottomScore =
        (1 - (bottomError / viewport.height)).clamp(0.0, 1.0);
    return ((centreScore + bottomScore) / 2) * 100;
  }

  static bool meetsFloor(double accuracy) => accuracy >= placementFloor;
  static bool meetsOptimal(double accuracy) => accuracy >= placementOptimal;
}

/// HSFVS-012: the DCYN failure class.
///
/// DCYN is a compliance gate that appears throughout this sheet -- a check
/// that answers yes or no. A "No" is a failure the operator has to see, and it
/// is not an exception: nothing crashed, the answer was simply no. So it gets
/// its own category rather than arriving as an unclassified error.
enum HabotComplianceFailure {
  /// The DCYN check returned No.
  checkFailed,

  /// The DCYN check could not run because its source data was missing.
  sourceMissing,
}

/// EDBAA-001: the liveness handshake failure.
///
/// The Self-Chasing column of nearly every row in this sheet says some form of
/// "an automated liveness handshake monitors this step and triggers rollback
/// on failure". This is what the user sees when that handshake misses.
enum HabotLivenessFailure {
  /// The handshake did not answer inside its window.
  missed,

  /// The handshake answered, and reported unhealthy.
  unhealthy,
}

/// The bound failure sources. Each maps to an existing error category so it
/// reaches the user through the Step 19 templates -- classified, scrubbed and
/// worded -- rather than as a new string written at the call site.
class HabotFeedbackSources {
  const HabotFeedbackSources._();

  /// HSFVS-012. A failed check is a validation outcome; a missing source is a
  /// server-side problem the operator cannot fix by retrying the form.
  static HabotErrorCategory categoryForCompliance(
    HabotComplianceFailure failure,
  ) => failure == HabotComplianceFailure.checkFailed
      ? HabotErrorCategory.validation
      : HabotErrorCategory.serverFailure;

  /// EDBAA-001. A missed handshake is a timeout; an unhealthy one is a server
  /// failure. Both are retryable, which the templates already know.
  static HabotErrorCategory categoryForLiveness(
    HabotLivenessFailure failure,
  ) => failure == HabotLivenessFailure.missed
      ? HabotErrorCategory.timeout
      : HabotErrorCategory.serverFailure;

  /// Builds the handled failure for a DCYN result, through the same classifier
  /// every other failure in the app goes through.
  static HandledFailure compliance(HabotComplianceFailure failure) {
    final HabotErrorCategory category = categoryForCompliance(failure);
    return HandledFailure(
      category: category,
      template: HabotErrorTemplates.of(category),
      scrubbedDiagnostic: failure == HabotComplianceFailure.checkFailed
          ? 'Compliance check returned No'
          : 'Compliance check source data unavailable',
      rolledBack: false,
    );
  }

  static HandledFailure liveness(HabotLivenessFailure failure) {
    final HabotErrorCategory category = categoryForLiveness(failure);
    return HandledFailure(
      category: category,
      template: HabotErrorTemplates.of(category),
      // A missed handshake triggers the rollback the Self-Chasing column
      // describes; an unhealthy report does not, because the call completed.
      scrubbedDiagnostic: failure == HabotLivenessFailure.missed
          ? 'Liveness handshake did not respond'
          : 'Liveness handshake reported unhealthy',
      rolledBack: failure == HabotLivenessFailure.missed,
    );
  }
}

/// The one presentation entry point for all three rows.
///
/// Every method here ends in the same `HabotErrorSnackbar.show`. There is no
/// second SnackBar construction, no second position and no second duration --
/// which is the whole point, and what the gates check.
class HabotFeedbackBanner {
  const HabotFeedbackBanner._();

  /// HSFVS-012 (Step 71).
  static void showComplianceFailure(
    BuildContext context,
    HabotComplianceFailure failure, {
    VoidCallback? onRetry,
  }) {
    HabotErrorSnackbar.show(
      context,
      HabotFeedbackSources.compliance(failure),
      onRetry: onRetry,
    );
  }

  /// EDBAA-001 (Step 72).
  static void showLivenessFailure(
    BuildContext context,
    HabotLivenessFailure failure, {
    VoidCallback? onRetry,
  }) {
    HabotErrorSnackbar.show(
      context,
      HabotFeedbackSources.liveness(failure),
      onRetry: onRetry,
    );
  }

  /// The message that will be shown, without showing it. Lets a gate assert
  /// the wording is a template's rather than an exception's.
  static String messageForCompliance(HabotComplianceFailure failure) =>
      HabotErrorSnackbar.messageFor(HabotFeedbackSources.compliance(failure));

  static String messageForLiveness(HabotLivenessFailure failure) =>
      HabotErrorSnackbar.messageFor(HabotFeedbackSources.liveness(failure));
}

/// A host that reserves the space the floating snackbar needs, so a control
/// anchored to the bottom of a screen is not covered by feedback about itself.
///
/// Step 25 already declared `HabotSnackbarInsets.reservedBottomSpace`; this
/// applies it, so the reservation is structural rather than something each
/// screen remembers.
class HabotFeedbackHost extends StatelessWidget {
  const HabotFeedbackHost({required this.child, super.key});

  final Widget child;

  static const Key hostKey = Key('habot.feedback.host');

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: hostKey,
      padding: const EdgeInsets.only(
        bottom: HabotSnackbarInsets.reservedBottomSpace,
      ),
      child: child,
    );
  }
}
