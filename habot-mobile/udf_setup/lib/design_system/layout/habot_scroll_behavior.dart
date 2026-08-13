/// AISS: IS38-SGTIM-018-AS01-A01 -- "Apply M3 Overscroll Stretch on MTOI
/// Lists."
///
/// 4 Substeps: "1) Update to Compose Foundation 1.1.0+. 2) Apply to LazyColumn
/// task lists. 3) Test scrolling bounds. 4) Verify physical elasticity feel on
/// devices."
///
/// Substep 1 is written against Jetpack Compose. This codebase is Flutter, so
/// the equivalent is not a dependency bump: the stretch indicator
/// ([StretchingOverscrollIndicator]) is already in the framework, and what the
/// step actually needs is for it to be applied everywhere rather than left to
/// per-platform defaults. That is what this behaviour does, and the gate
/// asserts the outcome the step names -- a stretch at the scroll boundary --
/// rather than a version number that means nothing here.
///
/// Decision to be Made Before Setup Step: "How does the list feel when the user
/// reaches the end of their task queue?"
///   Recorded answer: elastic. The list stretches and settles. It never halts
///   rigidly, and it never glows -- a glow is an Android 11 artefact that MD3
///   replaced, and a rigid halt reads as a broken scroll rather than an end.
library;

import 'package:flutter/material.dart';

/// The app-wide scroll behaviour.
///
/// Two deliberate differences from [MaterialScrollBehavior]:
///   * Fuchsia gets the stretch too. The framework default drops to a glow
///     there, which would make the same list feel different on one platform.
///   * The stretch does not depend on `ThemeData.useMaterial3`. A theme flag
///     changing the physics of every list in the app is exactly the kind of
///     action at a distance this design system exists to remove.
class HabotScrollBehavior extends MaterialScrollBehavior {
  const HabotScrollBehavior();

  /// Platforms that get the elastic stretch.
  static const Set<TargetPlatform> stretchPlatforms = <TargetPlatform>{
    TargetPlatform.android,
    TargetPlatform.fuchsia,
  };

  /// Platforms whose users expect the system's own bounce instead.
  static const Set<TargetPlatform> bouncePlatforms = <TargetPlatform>{
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };

  /// True when [platform] must render the stretch.
  static bool stretchesOn(TargetPlatform platform) =>
      stretchPlatforms.contains(platform);

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (stretchesOn(getPlatform(context))) {
      return StretchingOverscrollIndicator(
        axisDirection: details.direction,
        clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
        child: child,
      );
    }
    // Everywhere else: no indicator at all. iOS and macOS already bounce from
    // their physics, and a desktop pointer does not overscroll.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (bouncePlatforms.contains(getPlatform(context))) {
      return const BouncingScrollPhysics(
        parent: RangeMaintainingScrollPhysics(),
      );
    }
    // Substep 3: bounds are clamped, so the stretch is a visual effect over a
    // scroll that has genuinely stopped -- content never scrolls past its end.
    return const ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics());
  }
}
