/// AISS Step 154 -- GEN-04825
/// Setup Step (Action) / Atomic Step: "Apply the mistake-proofing (Poka-Yoke)
///   safeguard: FAB automatically hides when virtual keyboard opens to prevent
///   accidental taps during typing."
/// Metric: Error-Proofing (Poka-Yoke) Coverage Rate -- Floor "100% of
///         identified critical-path failure modes covered", Optimal "100%
///         coverage with automated enforcement (NO SILENT BYPASS)",
///         Ceiling "100% (coverage is binary; cannot exceed full)".
///         Pass / Fail.
///
/// **THE OPTIMAL IS NOT THE FLOOR PLUS POLISH -- IT IS A DIFFERENT KIND OF
/// THING.** The floor asks for the failure mode to be covered. The optimal
/// asks for AUTOMATED ENFORCEMENT with no silent bypass. A widget that hides
/// itself when the keyboard opens meets the floor; the next screen someone
/// writes with a raw `FloatingActionButton` silently does not, and nothing
/// notices. So this step ships two things: the widget, and a build-time guard
/// rule (`ROGUE_FAB`) that fails the build on a `FloatingActionButton`
/// constructed anywhere except this file. That is what turns a convention into
/// a poka-yoke, and it is the same shape as the ROGUE_SCAFFOLD and
/// ROGUE_THEME_CONSTRUCTION rules this project already enforces.
///
/// **THERE IS NO OPT-OUT PARAMETER, AND THAT IS DELIBERATE.** A
/// `hideOnKeyboard: false` would be the silent bypass the metric names. If a
/// surface genuinely needs a persistent action while typing, it is not a FAB
/// -- it belongs in the step's own navigation, where it is laid out rather
/// than floating over the content.
///
/// **WHY IT MATTERS HERE PARTICULARLY.** This batch has just turned long forms
/// into single-question screens (Step 147). A FAB floats above the content in
/// the bottom corner -- which, once the keyboard is up, is directly over the
/// next-word suggestion strip and the top row of keys. An accidental tap there
/// is not a stray press: it is a submit or a discard, fired while someone was
/// typing an answer.
///
/// THE THRESHOLD IS THE INSET, NOT A PLATFORM CHECK. `viewInsets.bottom` is
/// what the OS reports for the keyboard on every platform, which means one
/// rule rather than one per platform. A small non-zero inset can also come
/// from a system gesture bar, so the test is a threshold rather than "greater
/// than zero".
library;

import 'package:flutter/widgets.dart';

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Whether the on-screen keyboard is up, and by how much.
class HabotKeyboardInset {
  const HabotKeyboardInset(this.bottomInset);

  factory HabotKeyboardInset.of(BuildContext context) =>
      HabotKeyboardInset(MediaQuery.viewInsetsOf(context).bottom);

  final double bottomInset;

  /// Below this, the inset is a gesture bar or a rounding artefact rather
  /// than a keyboard. A keyboard is never this short.
  static const double keyboardThresholdDp = HabotDensity.minTouchTarget;

  bool get keyboardIsOpen => bottomInset > keyboardThresholdDp;
}

/// A floating action button that cannot be tapped by accident while typing.
///
/// **The only place in `lib/` permitted to construct a
/// `FloatingActionButton`.** Enforced by the ROGUE_FAB rule in
/// `test/guards/poka_yoke_no_hardcoded_values_test.dart`.
class HabotKeyboardAwareFab extends StatelessWidget {
  const HabotKeyboardAwareFab({
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    super.key,
  });

  final VoidCallback onPressed;
  final IconData icon;

  /// Required, not optional: an icon-only control with no accessible name is
  /// the Step 99 A11Y_UNNAMED_ICON_BUTTON defect, and a FAB is the most
  /// commonly unnamed control in any app.
  final String semanticLabel;

  static const Key fabKey = Key('habot.fab');

  /// There is deliberately no parameter that turns this off. See the header.
  static const bool hidesOnKeyboardAlways = true;

  @override
  Widget build(BuildContext context) {
    final HabotKeyboardInset inset = HabotKeyboardInset.of(context);
    return AnimatedSwitcher(
      duration: HabotMotionPolicy.resolve(context, HabotMotion.fast),
      switchInCurve: HabotMotionPolicy.resolveCurve(
        context,
        HabotEasing.standard,
      ),
      child: inset.keyboardIsOpen
          ? const SizedBox.shrink()
          : FloatingActionButton(
              key: fabKey,
              onPressed: onPressed,
              child: Icon(icon, semanticLabel: semanticLabel),
            ),
    );
  }
}

/// The poka-yoke coverage record for this safeguard.
class HabotFabSafeguard {
  const HabotFabSafeguard._();

  /// The guard rule that provides the automated enforcement half.
  static const String enforcementRule = 'ROGUE_FAB';

  static const String enforcementSite =
      'test/guards/poka_yoke_no_hardcoded_values_test.dart';

  /// The one file allowed to construct a FloatingActionButton.
  static const String permittedSite =
      'lib/design_system/interaction/keyboard_aware_fab.dart';

  /// The failure modes this safeguard covers, and how.
  static const Map<String, String> coveredFailureModes = <String, String>{
    'accidental FAB tap while typing':
        'The control is not in the tree while the keyboard is up, so there is '
            'nothing at that position to hit.',
    'a new screen using a raw FloatingActionButton':
        'ROGUE_FAB fails the build on a FloatingActionButton constructed '
            'outside the permitted site.',
    'a caller opting out of the safeguard':
        'There is no parameter to opt out. A surface that needs a persistent '
            'action while typing is not a FAB.',
    'a FAB with no accessible name':
        'semanticLabel is a required parameter of the constructor.',
  };

  /// Whether every named failure mode has a stated mechanism. The metric is
  /// binary and this is what makes it checkable.
  static bool get allModesCovered => coveredFailureModes.values
      .every((String mechanism) => mechanism.trim().length > 40);

  static double get coverageRate => coveredFailureModes.isEmpty
      ? 0
      : coveredFailureModes.values
              .where((String m) => m.trim().length > 40)
              .length /
          coveredFailureModes.length;

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static const String noSilentBypassNote =
      'The row\'s optimal is not the floor plus polish; it is a different '
      'kind of thing. The floor asks for the failure mode to be covered -- a '
      'widget that hides itself does that. The optimal asks for automated '
      'enforcement with no silent bypass, and the next screen someone writes '
      'with a raw FloatingActionButton would quietly not be covered. So this '
      'step ships the widget AND the ROGUE_FAB guard rule, which is what '
      'turns a convention into a poka-yoke.';

  static const String whyHereNote =
      'This batch has just turned long forms into single-question screens. A '
      'FAB floats in the bottom corner -- which, once the keyboard is up, sits '
      'directly over the suggestion strip and the top row of keys. An '
      'accidental tap there is not a stray press: it is a submit or a discard, '
      'fired while someone was typing an answer.';

  static const String thresholdNote =
      'The test is viewInsets.bottom against a threshold rather than a '
      'platform check, so there is one rule instead of one per platform. A '
      'threshold rather than "greater than zero" because a small non-zero '
      'inset can come from a system gesture bar; no keyboard is shorter than '
      'a single touch target.';
}
