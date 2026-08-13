import 'package:flutter/material.dart';
import 'screen_size_provider.dart';
import 'size_class.dart';

// SSELC-033-A01 — Universal Split-Screen Contextual Mirror Layout.
// Master workspace container: ContextualMirrorLayout.
//
// Compact  (<600dp) : Vertical stack.
//   Source pane — top 40% of viewport (read-only, independent scroll).
//   Input pane  — bottom 60% of viewport (form controls, independent scroll).
//   Keyboard-safe: source pane hard-locked — soft keyboard cannot push it off-screen.
//
// Medium/Expanded (≥600dp) : 50/50 horizontal split.
//   Left  — source/evidence display (independent scroll).
//   Right — input/action controls (independent scroll).
//   No bleed between panes — double scroll interactions blocked.
//
// Spec:
//   - Independent scrolling containers inside main viewport limits
//   - Distinct surface elevation shifts between panes
//   - Sharp structural contrast behind primary observation surface
//   - Hard-lock source pane against soft-keyboard expansion events
//   - Continuous aspect checks prevent data clipping (LayoutBuilder)

class ContextualMirrorLayout extends StatelessWidget {
  const ContextualMirrorLayout({
    super.key,
    required this.sourcePane,
    required this.inputPane,
    this.sourceFlex = 4,
    this.inputFlex  = 6,
    this.mobileSourceHeightFraction = 0.40,
    this.dividerColor,
    this.sourceElevation = 2.0,
    this.inputElevation  = 0.0,
  });

  /// Left / top pane — source, evidence, reference content (read-only).
  final Widget sourcePane;

  /// Right / bottom pane — input controls, form fields, action buttons.
  final Widget inputPane;

  /// Flex ratio for wide layout. Default 4:6 (40/60).
  final int sourceFlex;
  final int inputFlex;

  /// Fraction of viewport height for source pane on compact mobile.
  /// Default 0.40 = top 40%.
  final double mobileSourceHeightFraction;

  /// Divider color between panes. Defaults to theme outlineVariant.
  final Color? dividerColor;

  /// Spec: distinct surface elevation shifts to separate panes.
  final double sourceElevation;
  final double inputElevation;

  @override
  Widget build(BuildContext context) {
    final sizeClass = ScreenSizeProvider.of(context);

    return sizeClass.isCompact
        ? _MobileStack(
            sourcePane:                  sourcePane,
            inputPane:                   inputPane,
            mobileSourceHeightFraction:  mobileSourceHeightFraction,
            sourceElevation:             sourceElevation,
            inputElevation:              inputElevation,
          )
        : _WideSplit(
            sourcePane:      sourcePane,
            inputPane:       inputPane,
            sourceFlex:      sourceFlex,
            inputFlex:       inputFlex,
            dividerColor:    dividerColor,
            sourceElevation: sourceElevation,
            inputElevation:  inputElevation,
          );
  }
}

// ─── MOBILE STACK ─────────────────────────────────────────────────────────────

class _MobileStack extends StatelessWidget {
  const _MobileStack({
    required this.sourcePane,
    required this.inputPane,
    required this.mobileSourceHeightFraction,
    required this.sourceElevation,
    required this.inputElevation,
  });

  final Widget sourcePane;
  final Widget inputPane;
  final double mobileSourceHeightFraction;
  final double sourceElevation;
  final double inputElevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // LayoutBuilder for continuous aspect checks — prevents data clipping.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hard-lock source height — keyboard cannot push it off-screen.
        // Uses viewInsets to detect keyboard and subtract from available height.
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final availableHeight = constraints.maxHeight - keyboardHeight;
        final sourceHeight = (availableHeight * mobileSourceHeightFraction)
            .clamp(120.0, availableHeight * 0.5);

        return Column(
          children: [
            // Source pane — hard-locked top 40%, independent scroll.
            // Spec: sharp structural contrast behind primary observation surface.
            SizedBox(
              height: sourceHeight,
              child: Material(
                elevation: sourceElevation,
                color: theme.colorScheme.surfaceContainerLow,
                child: _IndependentScrollPane(
                  child: sourcePane,
                ),
              ),
            ),

            // Divider — sharp contrast separator.
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant,
            ),

            // Input pane — remaining height, independent scroll.
            // Resizes with keyboard — source stays locked above.
            Expanded(
              child: Material(
                elevation: inputElevation,
                color: theme.colorScheme.surface,
                child: _IndependentScrollPane(
                  child: inputPane,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── WIDE SPLIT ───────────────────────────────────────────────────────────────

class _WideSplit extends StatelessWidget {
  const _WideSplit({
    required this.sourcePane,
    required this.inputPane,
    required this.sourceFlex,
    required this.inputFlex,
    required this.sourceElevation,
    required this.inputElevation,
    this.dividerColor,
  });

  final Widget sourcePane;
  final Widget inputPane;
  final int sourceFlex;
  final int inputFlex;
  final double sourceElevation;
  final double inputElevation;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Source pane — left, independent scroll, elevated surface.
        Expanded(
          flex: sourceFlex,
          child: Material(
            elevation: sourceElevation,
            // Spec: sharp structural contrast behind primary observation surface.
            color: theme.colorScheme.surfaceContainerLow,
            child: _IndependentScrollPane(child: sourcePane),
          ),
        ),

        // Vertical divider — clean structural separator.
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: dividerColor ?? theme.colorScheme.outlineVariant,
        ),

        // Input pane — right, independent scroll, base surface.
        Expanded(
          flex: inputFlex,
          child: Material(
            elevation: inputElevation,
            color: theme.colorScheme.surface,
            child: _IndependentScrollPane(child: inputPane),
          ),
        ),
      ],
    );
  }
}

// ─── INDEPENDENT SCROLL PANE ─────────────────────────────────────────────────

/// Wraps content in its own scroll controller.
/// Spec: blocks double scroll interactions — each pane scrolls independently.
class _IndependentScrollPane extends StatefulWidget {
  const _IndependentScrollPane({required this.child});
  final Widget child;

  @override
  State<_IndependentScrollPane> createState() => _IndependentScrollPaneState();
}

class _IndependentScrollPaneState extends State<_IndependentScrollPane> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PrimaryScrollController.none blocks parent scroll bleed.
    return PrimaryScrollController.none(
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const ClampingScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
