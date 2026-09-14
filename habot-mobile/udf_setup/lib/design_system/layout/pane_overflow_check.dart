/// Step 222 (ARCPE-016-14) -- verifying that stacked panes fit.
///
/// The row: "Verify the panels stack vertically without overlapping layout
/// items on mobile screens."
/// Metric: Verification Assertion Accuracy -- 0.95 / 0.99 / 1. Pass/Fail.
///
/// **Overlap is not the failure mode.** A Flutter `Column` does not overlap its
/// children; it *overflows* them. In a debug build that is a yellow-and-black
/// stripe with a console message; in a release build it is a pane silently
/// clipped at the bottom edge, which is the version that ships. A verification
/// written against overlap passes on every build and catches nothing.
///
/// So the assertion is a **height budget**: every pane's declared minimum,
/// plus the chrome the screen always has, plus the keyboard when it is open,
/// against the viewport of the shortest device the product supports.
///
/// **The keyboard is the case that matters.** A two-pane stack fits on a
/// 320x568 phone until somebody taps a field, and then 336dp of the viewport
/// belongs to the keyboard. Checking the budget without the keyboard is
/// checking the state the screen is not in while anyone is using it.
library;

import 'device_profiles.dart';
import 'pane_split.dart';

/// What a stacked composition is made of.
class HabotStackedPane {
  const HabotStackedPane({
    required this.label,
    required this.minimumHeightDp,
    required this.scrollsInternally,
  });

  final String label;
  final double minimumHeightDp;

  /// A pane that scrolls internally can be given less than its content wants
  /// without losing anything. A pane that cannot must get its minimum.
  final bool scrollsInternally;
}

/// One evaluation of a composition against one device, in one keyboard state.
class HabotFitResult {
  const HabotFitResult({
    required this.device,
    required this.keyboardOpen,
    required this.requiredDp,
    required this.availableDp,
  });

  final HabotDeviceProfile device;
  final bool keyboardOpen;

  /// Sum of pane minimums plus chrome.
  final double requiredDp;

  /// Viewport height less chrome less the keyboard inset.
  final double availableDp;

  bool get fits => requiredDp <= availableDp;

  /// Positive when it fits, negative by the amount that overflows.
  double get marginDp => availableDp - requiredDp;
}

/// The check.
class HabotPaneOverflowCheck {
  const HabotPaneOverflowCheck._();

  /// App bar plus top and bottom safe areas on a modern handset. Taken as one
  /// figure because the panes do not care which part of it is which.
  static const double chromeHeightDp = 120;

  /// A software keyboard on a handset. The declared figure is the one Step
  /// 154 uses for the keyboard-aware FAB.
  static const double keyboardInsetDp = 336;

  /// Phones only. A tablet has room; the question is whether the phone does.
  static List<HabotDeviceProfile> get phones => HabotDevices.all
      .where((HabotDeviceProfile d) => d.deviceType == HabotDeviceType.phone)
      .toList();

  static HabotDeviceProfile get shortestPhone => phones.reduce(
        (HabotDeviceProfile a, HabotDeviceProfile b) =>
            a.heightDp <= b.heightDp ? a : b,
      );

  static double requiredHeight(List<HabotStackedPane> panes) =>
      panes.fold<double>(
        chromeHeightDp,
        (double sum, HabotStackedPane p) => sum + p.minimumHeightDp,
      );

  static HabotFitResult evaluate({
    required List<HabotStackedPane> panes,
    required HabotDeviceProfile device,
    required bool keyboardOpen,
  }) =>
      HabotFitResult(
        device: device,
        keyboardOpen: keyboardOpen,
        requiredDp: requiredHeight(panes),
        availableDp:
            device.heightDp - (keyboardOpen ? keyboardInsetDp : 0),
      );

  static List<HabotFitResult> evaluateAcrossPhones(
    List<HabotStackedPane> panes, {
    required bool keyboardOpen,
  }) =>
      phones
          .map(
            (HabotDeviceProfile d) => evaluate(
              panes: panes,
              device: d,
              keyboardOpen: keyboardOpen,
            ),
          )
          .toList();

  static List<HabotFitResult> failures(
    List<HabotStackedPane> panes, {
    required bool keyboardOpen,
  }) =>
      evaluateAcrossPhones(panes, keyboardOpen: keyboardOpen)
          .where((HabotFitResult r) => !r.fits)
          .toList();

  /// What a stacked composition must do when the budget does not balance:
  /// stop stacking. Shrinking a pane below its minimum is how an overflow
  /// becomes a clip.
  static bool mustStopStacking(
    List<HabotStackedPane> panes, {
    required bool keyboardOpen,
  }) =>
      failures(panes, keyboardOpen: keyboardOpen).isNotEmpty;

  /// The composition Step 218 permits to stack on a compact window: two peer
  /// panes, each able to scroll.
  static List<HabotStackedPane> get peerStack => <HabotStackedPane>[
        HabotStackedPane(
          label: 'leading peer',
          minimumHeightDp: HabotPaneSplit.minimumUsablePaneDp,
          scrollsInternally: true,
        ),
        HabotStackedPane(
          label: 'trailing peer',
          minimumHeightDp: HabotPaneSplit.minimumUsablePaneDp,
          scrollsInternally: true,
        ),
      ];

  /// The same two panes with a third that cannot scroll -- a pinned summary,
  /// a totals bar. The case a stack is most often asked to absorb.
  static List<HabotStackedPane> get peerStackWithPinnedSummary =>
      <HabotStackedPane>[
        ...peerStack,
        const HabotStackedPane(
          label: 'pinned totals bar',
          minimumHeightDp: 72,
          scrollsInternally: false,
        ),
      ];

  static const String overlapIsNotTheFailureNote =
      'A Flutter Column does not overlap its children, it overflows them -- a '
      'debug stripe, and in release a pane silently clipped at the bottom '
      'edge. A verification written against overlap passes on every build and '
      'catches nothing. The assertion here is a height budget.';

  static const String keyboardIsTheCaseNote =
      'A two-pane stack fits on a 320x568 handset until somebody taps a '
      'field, and then 336dp of the viewport belongs to the keyboard. '
      'Checking the budget with the keyboard closed checks the state the '
      'screen is not in while anyone is using it.';

  // -----------------------------------------------------------------------
  // Metric: Verification Assertion Accuracy. 0.95 / 0.99 / 1. Pass/Fail.
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.99;
  static const double ceiling = 1;

  /// The accuracy of an assertion is whether it fires on the cases it should
  /// and stays quiet on the cases it should not. Four cases, two of each.
  static Map<String, bool> get assertionChecks => <String, bool>{
        'two scrolling peers fit on every phone with the keyboard closed':
            failures(peerStack, keyboardOpen: false).isEmpty,
        'two scrolling peers do NOT fit on the shortest phone with the '
                'keyboard open':
            failures(peerStack, keyboardOpen: true).isNotEmpty,
        'adding a pinned bar breaks the budget on the shortest phone':
            !evaluate(
              panes: peerStackWithPinnedSummary,
              device: shortestPhone,
              keyboardOpen: false,
            ).fits,
        'the composition is told to stop stacking rather than shrink':
            mustStopStacking(peerStack, keyboardOpen: true),
        'the shortest declared phone is the one evaluated':
            shortestPhone.heightDp == 568,
        'the check is run across every declared phone, not one':
            evaluateAcrossPhones(peerStack, keyboardOpen: false).length ==
                phones.length,
      };

  static double get assertionAccuracy =>
      assertionChecks.values.where((bool b) => b).length /
      assertionChecks.length;

  static String get qualitativeOutput =>
      assertionAccuracy >= floor ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Verify the panels stack vertically without overlapping layout items '
      'on mobile screens."';
}
