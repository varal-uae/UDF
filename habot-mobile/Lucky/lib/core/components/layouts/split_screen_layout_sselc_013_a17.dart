// SSELC-013-A17 — Split-Screen Contextual Mirror UI Template Standardization.
// Enforces a rigid 50/50 split-screen layout on desktop/tablet and vertical stacking on mobile, rejecting custom layout grids programmatically using an 8pt Material Design baseline grid.

import 'package:flutter/material.dart';

/// Atomic-level data fields for layout validation.
class LayoutValidationData {
  final String layoutType;
  final Size layoutGridDimensions;
  final double spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const LayoutValidationData({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// In-memory queue buffer for captured payload events (Mock Data).
class PayloadEventBuffer {
  static final List<Map<String, dynamic>> _queue = [];

  static void enqueue(Map<String, dynamic> event) {
    _queue.add(event);
  }

  static List<Map<String, dynamic>> get events => List.unmodifiable(_queue);

  static void clear() => _queue.clear();
}

/// Rigid template globally mandatory across manual systems.
/// Programmatically ignores local overrides by core framework rules.
class SplitScreenLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final double? forcedSpacingOverride;

  const SplitScreenLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.forcedSpacingOverride,
  });

  /// Structural verification check to confirm custom layout grids are rejected.
  /// Floor: 4dp, Optimal: 8dp, Ceiling: 16dp.
  static bool validateGridAdherence(double spacing) {
    const double floorBoundary = 4.0;
    const double ceilingBoundary = 16.0;
    return spacing >= floorBoundary && spacing <= ceilingBoundary;
  }

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke: Local overrides programmatically ignored by core framework rules.
    if (forcedSpacingOverride != null && !validateGridAdherence(forcedSpacingOverride!)) {
      PayloadEventBuffer.enqueue({
        'event': 'custom_grid_rejected',
        'timestamp': DateTime.now().toIso8601String(),
        'attempted_spacing': forcedSpacingOverride,
        'status': 'Fail',
      });
      throw AssertionError(
        'SSELC-013-A17: Non-standard screen grid ($forcedSpacingOverride) triggers deployment rejection. Must be between 4dp and 16dp.',
      );
    }

    // Optimal Target: 8dp (Material Design responsive grid baseline)
    const double optimalSpacing = 8.0;

    PayloadEventBuffer.enqueue({
      'event': 'layout_rendered',
      'timestamp': DateTime.now().toIso8601String(),
      'spacing': optimalSpacing,
      'status': 'Pass',
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        // Vertical orientation auto-activating on mobile width devices.
        if (isMobile) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPanel(context, leftPanel, isTop: true),
                SizedBox(height: optimalSpacing),
                _buildPanel(context, rightPanel, isTop: false),
              ],
            ),
          );
        }

        // Precise 50/50 balance splitting seamlessly on tablet/desktop geometries.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildPanel(context, leftPanel, isTop: true)),
            SizedBox(width: optimalSpacing),
            Expanded(child: _buildPanel(context, rightPanel, isTop: false)),
          ],
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context, Widget child, {required bool isTop}) {
    // High-density borders separating panels elegantly.
    // Modal block styling maps securely locking fields.
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

/// Mock usage demonstrating dynamic form panels updating based on JSON payloads.
class SplitScreenMockPage extends StatelessWidget {
  const SplitScreenMockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSELC-013-A17 Split Screen')),
      body: SplitScreenLayout(
        leftPanel: const Center(child: Text('Left Panel / Top Card')),
        rightPanel: const Center(child: Text('Right Panel / Bottom Card')),
      ),
    );
  }
}
