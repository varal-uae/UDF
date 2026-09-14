/// Step 224 (CFCST-014) -- popovers become bottom sheets on mobile.
///
/// The row: "Apply Material Design 3 guidelines to convert modal popovers into
/// sliding bottom sheets on mobile screens."
/// Metric: Mobile Usability Compliance (Touch Target Size & Core Web Vitals).
///
/// The guidance is right and the rule it implies is wrong. **A dialog and a
/// bottom sheet are not interchangeable surfaces**, and converting by device
/// removes a property some of them were chosen for.
///
/// A dialog is modal and blocking: it takes the screen, absorbs every other
/// pointer, and cannot be dismissed by looking away. Step 195 built the
/// compliance alert on exactly that property -- a failure the user must answer
/// before continuing. A bottom sheet, in MD3's default form, is dragged away
/// with a thumb. Convert one into the other because the screen is narrow and
/// the compliance alert becomes a thing you can flick off the bottom of the
/// display.
///
/// So the conversion is by **intent**, not by width. A surface that offers a
/// *choice* becomes a sheet on a compact window, because a sheet is easier to
/// reach and easier to dismiss. A surface that demands a *decision* stays a
/// dialog on every size class, because that is what makes it a decision.
///
/// **The metric on this row measures neither.** "Touch Target Size" is Steps
/// 227-229; "Core Web Vitals" are browser measurements -- LCP and CLS are
/// defined by a page load, and this is a Flutter application. Neither says
/// whether a popover became a sheet. Recorded, and the property this step can
/// actually be graded on is reported instead.
library;

import '../layout/window_size_class.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/surface_tokens.dart';

/// Why a surface is being shown.
enum HabotSurfaceIntent {
  /// Pick one of several options. Dismissing without picking is a valid
  /// outcome.
  choice,

  /// Answer a question before continuing. Dismissing without answering is not
  /// an outcome the flow has.
  decision,

  /// Show something. No answer is wanted at all.
  disclosure,

  /// Confirm something destructive or irreversible.
  destructiveConfirmation,
}

/// The surfaces available.
enum HabotSurfaceForm {
  /// MD3 dialog. Modal, blocking, dismissed only by its own actions.
  dialog,

  /// MD3 modal bottom sheet. Scrimmed, and draggable away.
  modalSheet,

  /// MD3 standard bottom sheet. Not scrimmed; the screen behind stays live.
  standardSheet,

  /// A menu or popover anchored to the control that opened it.
  anchoredPopover,
}

/// The rule.
class HabotSurfaceChoice {
  const HabotSurfaceChoice._();

  /// Total over intent and window class. A surface nobody assigned is a
  /// surface somebody picks at the call site.
  static HabotSurfaceForm formFor(
    HabotSurfaceIntent intent,
    double windowWidthDp,
  ) {
    final bool compact = HabotWindowSizeClass.classOf(windowWidthDp) ==
        HabotMd3WindowClass.compact;
    return switch (intent) {
      HabotSurfaceIntent.choice => compact
          ? HabotSurfaceForm.modalSheet
          : HabotSurfaceForm.anchoredPopover,
      HabotSurfaceIntent.disclosure => compact
          ? HabotSurfaceForm.standardSheet
          : HabotSurfaceForm.anchoredPopover,
      // Unchanged by width, on purpose.
      HabotSurfaceIntent.decision => HabotSurfaceForm.dialog,
      HabotSurfaceIntent.destructiveConfirmation => HabotSurfaceForm.dialog,
    };
  }

  /// Whether a form can be dismissed without answering it.
  static bool isDismissibleByGesture(HabotSurfaceForm form) => switch (form) {
        HabotSurfaceForm.dialog => false,
        HabotSurfaceForm.modalSheet => true,
        HabotSurfaceForm.standardSheet => true,
        HabotSurfaceForm.anchoredPopover => true,
      };

  /// The intents whose surface the row's device-based rule would change, and
  /// which must not change.
  static List<HabotSurfaceIntent> get intentsThatStayDialogs =>
      HabotSurfaceIntent.values
          .where(
            (HabotSurfaceIntent i) =>
                formFor(i, 360) == HabotSurfaceForm.dialog,
          )
          .toList();

  /// What a conversion by width alone would do to a blocking surface: make it
  /// dismissible, which is the property it existed for.
  static bool blindConversionBreaksBlocking(HabotSurfaceIntent intent) =>
      !isDismissibleByGesture(formFor(intent, 1024)) &&
      isDismissibleByGesture(HabotSurfaceForm.modalSheet) &&
      intentsThatStayDialogs.contains(intent);

  static const String notInterchangeableNote =
      'A dialog is modal and blocking; an MD3 bottom sheet is dragged away '
      'with a thumb. Step 195 built the compliance alert on the blocking '
      'property. Convert one into the other because the screen is narrow and '
      'the compliance alert becomes a thing you can flick off the bottom of '
      'the display.';

  // -----------------------------------------------------------------------
  // Sizing, once a sheet is the right answer.
  // -----------------------------------------------------------------------

  /// The sheet's declared default snap, from Step GEN-00235.
  static double get defaultSnapFraction => HabotSheet.defaultSnapFraction;

  /// A dialog's content is usually shorter than 60% of the viewport. Snapping
  /// a converted dialog to the default leaves a sheet that is mostly empty,
  /// which reads as a loading state.
  static double snapFor({
    required double contentHeightDp,
    required double viewportHeightDp,
  }) {
    final double wanted = contentHeightDp / viewportHeightDp;
    if (wanted <= HabotSheet.minSnapFraction) {
      return HabotSheet.minSnapFraction;
    }
    if (wanted >= HabotSheet.maxSnapFraction) {
      return HabotSheet.maxSnapFraction;
    }
    return wanted;
  }

  static bool get contentSizedRatherThanDefaultSnapped =>
      snapFor(contentHeightDp: 180, viewportHeightDp: 740) <
      defaultSnapFraction;

  static Duration get enterDuration => HabotMotion.sheetEnter;
  static Duration get exitDuration => HabotMotion.sheetExit;

  static const String emptySheetNote =
      'A dialog\'s content is usually shorter than 60% of the viewport, so a '
      'converted dialog snapped to the sheet default is a sheet that is mostly '
      'empty -- which people read as something still loading. The snap is '
      'sized to the content and clamped to the declared stops.';

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Mobile Usability Compliance (Touch Target Size & Core Web Vitals)';

  static const String metricDoesNotMeasureTheRowNote =
      'The metric names two things, and neither is about this row. Touch '
      'target size is Steps 227-229. Core Web Vitals are browser '
      'measurements -- LCP and CLS are defined by a page load and this is a '
      'Flutter application, so there is no LCP to report. Whether a popover '
      'became a sheet is not measured by either, and no figure is invented '
      'for them.';

  /// What this step can be graded on: whether every intent has a surface and
  /// whether blocking survived the conversion.
  static Map<String, bool> get checks => <String, bool>{
        'every intent has a surface at every window class':
            HabotSurfaceIntent.values.every(
          (HabotSurfaceIntent i) =>
              formFor(i, 360).name.isNotEmpty &&
              formFor(i, 1024).name.isNotEmpty,
        ),
        'a choice becomes a sheet on a compact window':
            formFor(HabotSurfaceIntent.choice, 360) ==
                HabotSurfaceForm.modalSheet,
        'and an anchored popover where there is room':
            formFor(HabotSurfaceIntent.choice, 1024) ==
                HabotSurfaceForm.anchoredPopover,
        'a decision stays a dialog on every window class':
            formFor(HabotSurfaceIntent.decision, 360) ==
                    HabotSurfaceForm.dialog &&
                formFor(HabotSurfaceIntent.decision, 1024) ==
                    HabotSurfaceForm.dialog,
        'a destructive confirmation stays a dialog too':
            formFor(HabotSurfaceIntent.destructiveConfirmation, 360) ==
                HabotSurfaceForm.dialog,
        'the surfaces that stay dialogs are the ones that cannot be gestured '
                'away':
            intentsThatStayDialogs.every(
          (HabotSurfaceIntent i) =>
              !isDismissibleByGesture(formFor(i, 360)),
        ),
        'converting them blindly would break blocking':
            blindConversionBreaksBlocking(HabotSurfaceIntent.decision),
        'a converted surface is sized to its content':
            contentSizedRatherThanDefaultSnapped,
        'the sheet uses the declared enter and exit durations':
            enterDuration == HabotMotion.sheetEnter &&
                exitDuration == HabotMotion.sheetExit,
      };

  static double get conversionCorrectness =>
      checks.values.where((bool b) => b).length / checks.length;

  static String get qualitativeOutput =>
      conversionCorrectness == 1.0 ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Apply Material Design 3 guidelines to convert modal popovers into '
      'sliding bottom sheets on mobile screens."';
}
