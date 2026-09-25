// SSELC-013-A12 — Split-Screen Contextual Mirror UI Layout.
// Provides a rigid 50/50 split-screen layout that adaptively stacks vertically on mobile devices, enforcing standardized panel structures with high-density borders and cubic-bezier animations.

import 'package:flutter/material.dart';

/// Mock configuration data for the split-screen layout as required by the atomic data fields.
class SplitScreenMockConfig {
  static const String configurationParameter = 'split_screen_ratio';
  static const String currentSetting = '0.5';
  static const String previousSetting = '0.5';
  static const String changeLog = 'Initial standardization enforcement';
  static final String configurationTimestamp = DateTime.now().toIso8601String();
}

/// A reusable split-screen layout widget enforcing rigid orientation and adaptive stacking.
/// 
/// On desktop/tablet (width >= 600), it displays a precise 50/50 horizontal split.
/// On mobile (width < 600), it automatically activates vertical orientation stacking.
/// Local overrides are programmatically ignored to enforce core framework rules.
class SplitScreenLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final double mobileBreakpoint;

  const SplitScreenLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.mobileBreakpoint = 600.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        // Custom cubic-bezier deceleration curve injected into entry style definitions
        const Curve decelerationCurve = Cubic(0.0, 0.0, 0.2, 1.0);
        const Duration animationDuration = Duration(milliseconds: 400);

        if (isMobile) {
          // Vertical orientation auto-activating on mobile width devices
          return AnimatedSwitcher(
            duration: animationDuration,
            switchInCurve: decelerationCurve,
            switchOutCurve: decelerationCurve,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              key: const ValueKey('mobile_vertical_stack'),
              child: Column(
                children: [
                  _buildAdaptivePanel(context, leftPanel, isVertical: true),
                  _buildHighDensityDivider(isVertical: true),
                  _buildAdaptivePanel(context, rightPanel, isVertical: true),
                ],
              ),
            ),
          );
        }

        // Precise 50/50 balance splitting seamlessly on tablet/desktop geometries
        return AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: decelerationCurve,
          switchOutCurve: decelerationCurve,
          child: Row(
            key: const ValueKey('desktop_horizontal_split'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: _buildAdaptivePanel(context, leftPanel, isVertical: false),
              ),
              _buildHighDensityDivider(isVertical: false),
              Expanded(
                flex: 1,
                child: _buildAdaptivePanel(context, rightPanel, isVertical: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdaptivePanel(BuildContext context, Widget child, {required bool isVertical}) {
    // Modal block styling maps securely locking fields / visual state shifts
    return Container(
      constraints: isVertical ? const BoxConstraints(minHeight: 300) : null,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  Widget _buildHighDensityDivider({required bool isVertical}) {
    // High-density borders separating panels elegantly
    if (isVertical) {
      return const Divider(
        height: 2.0,
        thickness: 2.0,
        color: Colors.black87,
      );
    }
    return const VerticalDivider(
      width: 2.0,
      thickness: 2.0,
      color: Colors.black87,
    );
  }
}

/// Standardized wrapper for touch-optimized selectors horizontally mapped.
class TouchOptimizedSelectorWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TouchOptimizedSelectorWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: child,
        ),
      ),
    );
  }
}
