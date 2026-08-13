/// AISS: RCGLA-018-A01 -- "Universal Master Layout Architecture".
///
/// Substep 1: "Build primary scaffold locking metrics."
/// Substep 2: "Implement configurable child prop targets."
/// Substep 3: "Block flexible padding assignments."
/// Substep 4: "Force tracks to implement central layouts."
///
/// Substep 3 is the interesting one. This widget deliberately exposes **no**
/// padding, margin, width or alignment parameter. A screen cannot pass its own
/// spacing in, because the moment one screen can, every screen will. Spacing
/// comes from the tokens or it does not exist. `RCGLA-018-G3` asserts the
/// constructor has no such parameter, so the block survives future edits.
library;

import 'package:flutter/material.dart';

import '../theme/habot_theme_extension.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'layout_boundary.dart';
import 'page_frame.dart';

/// The one scaffold every screen in the app uses.
///
/// Registers itself so `RCGLA-018-G4` can prove 100% of screens are wrapped.
class HabotMasterScaffold extends StatelessWidget {
  const HabotMasterScaffold({
    required this.screenName,
    required this.body,
    this.header,
    this.footer,
    this.floatingAction,
    this.scrollable = true,
    super.key,
  });

  /// Identifies the screen in the layout audit trail. Required, because an
  /// unnamed screen cannot appear in the RCGLA-018 inventory register.
  final String screenName;

  // --- configurable child prop targets (substep 2) ---
  final Widget body;
  final PreferredSizeWidget? header;
  final Widget? footer;
  final Widget? floatingAction;

  /// Whether the body scrolls. Layout behaviour, not a spacing escape hatch.
  final bool scrollable;

  /// Every screen that has been built this session. The audit gate reads this.
  static final Set<String> registeredScreens = <String>{};

  @visibleForTesting
  static void resetRegistry() => registeredScreens.clear();

  @override
  Widget build(BuildContext context) {
    registeredScreens.add(screenName);
    // Reading the tokens here also proves, at build time, that this screen is
    // inside a Habot theme -- HabotTokens.of throws a readable error if not.
    HabotTokens.of(context);

    final Widget content = Padding(
      // Locked metrics (substep 1). Not overridable by the caller.
      padding: const EdgeInsets.symmetric(
        horizontal: HabotGrid.outerMargin,
        vertical: HabotSpacing.md,
      ),
      child: body,
    );

    return Scaffold(
      appBar: header,
      floatingActionButton: floatingAction,
      bottomNavigationBar: footer,
      body: HabotPageFrame(
        child: SafeArea(
          child: HabotLayoutBoundary(
            debugOrigin: screenName,
            child: scrollable ? SingleChildScrollView(child: content) : content,
          ),
        ),
      ),
    );
  }
}
