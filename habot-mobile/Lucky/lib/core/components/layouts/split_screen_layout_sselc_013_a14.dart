// SSELC-013-A14 — Split-Screen Contextual Mirror UI Template Standardization.
// Enforces a rigid 50/50 split-screen layout on desktop/tablet and adaptive vertical card stacking on mobile, with local overrides programmatically ignored.

import 'package:flutter/material.dart';

/// Mock data payload representing atomic-level layout configuration fields.
/// In production, this would be parsed from a JSON payload delivered by the backend.
class LayoutConfigPayload {
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final AlignmentDirectional alignmentSettings;
  final bool layoutValidationStatus;

  const LayoutConfigPayload({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Hardcoded mock repository simulating backend delivery of layout configurations.
class MockLayoutRepository {
  static const LayoutConfigPayload defaultConfig = LayoutConfigPayload(
    layoutType: 'split_screen_mirror',
    layoutGridDimensions: Size(800, 600),
    spacingRules: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    alignmentSettings: AlignmentDirectional.topStart,
    layoutValidationStatus: true,
  );

  static LayoutConfigPayload fetchConfig() => defaultConfig;
}

/// Core split-screen layout widget enforcing rigid template globally.
/// Local overrides passed via constructor are programmatically ignored to ensure compliance.
class SplitScreenContextualMirror extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final double mobileBreakpoint;
  final LayoutConfigPayload? _ignoredLocalOverride;

  /// [localOverride] is accepted but strictly ignored by core framework rules (Poka-Yoke).
  const SplitScreenContextualMirror({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.mobileBreakpoint = 600.0,
    LayoutConfigPayload? localOverride,
  }) : _ignoredLocalOverride = localOverride;

  @override
  Widget build(BuildContext context) {
    // Enforce standardized config; ignore any local overrides programmatically
    final LayoutConfigPayload enforcedConfig = MockLayoutRepository.fetchConfig();

    if (!enforcedConfig.layoutValidationStatus) {
      return const Center(
        child: Text(
          'Layout Validation Failed. Non-standard screens trigger deployment rejections.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        if (isMobile) {
          // Vertical orientation auto-activating on mobile width devices
          // Adaptive panel stacking shifting smoothly
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: enforcedConfig.spacingRules,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardWrapper(context, leftPanel, enforcedConfig),
                SizedBox(height: enforcedConfig.spacingRules.vertical),
                _buildCardWrapper(context, rightPanel, enforcedConfig),
              ],
            ),
          );
        } else {
          // Precise 50/50 balance splitting seamlessly
          // High-density borders separating panels elegantly
          return Padding(
            padding: enforcedConfig.spacingRules,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPanelContainer(context, leftPanel, enforcedConfig),
                ),
                SizedBox(width: enforcedConfig.spacingRules.horizontal),
                Expanded(
                  child: _buildPanelContainer(context, rightPanel, enforcedConfig),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildCardWrapper(
    BuildContext context,
    Widget child,
    LayoutConfigPayload config,
  ) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: child,
      ),
    );
  }

  Widget _buildPanelContainer(
    BuildContext context,
    Widget child,
    LayoutConfigPayload config,
  ) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.5, // High-density borders separating panels elegantly
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Touch-optimized selector wrapper mapped horizontally for mobile-first UX.
class TouchOptimizedSelectorWrapper extends StatelessWidget {
  final List<Widget> selectors;
  final EdgeInsetsGeometry padding;

  const TouchOptimizedSelectorWrapper({
    super.key,
    required this.selectors,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: selectors
            .map((selector) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    height: 48.0, // Minimum touch target size (Material 3)
                    child: selector,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Modal block styling maps securely locking fields to prevent unauthorized edits.
class SecureModalBlock extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onConfirm;

  const SecureModalBlock({
    super.key,
    required this.title,
    required this.content,
    this.onConfirm,
  });

  static Future<void> show(BuildContext context, {required String title, required Widget content, VoidCallback? onConfirm}) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Securely locking fields
      builder: (context) => SecureModalBlock(
        title: title,
        content: content,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(title, style: theme.textTheme.titleLarge),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (onConfirm != null) onConfirm!();
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}