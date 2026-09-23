// RCGLA-020-A09 — Reusable Contextual Mirror Grid Module.
// Provides a locked, reusable split-container layout template that dynamically shifts from side-by-side to stacked presentation on small viewports following Material 3 standards.

import 'package:flutter/material.dart';

/// Atomic-level data model for the contextual mirror grid configuration.
class MirrorGridConfig {
  final String templateName;
  final String templateVersion;
  final String templateType;
  final String templateConfiguration;
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const MirrorGridConfig({
    required this.templateName,
    required this.templateVersion,
    required this.templateType,
    required this.templateConfiguration,
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Mock data repository providing realistic local configuration for the layout module.
class MockMirrorGridRepository {
  static const MirrorGridConfig defaultConfig = MirrorGridConfig(
    templateName: 'UDF_Contextual_Mirror_Grid',
    templateVersion: '1.0.0',
    templateType: 'SplitContainer',
    templateConfiguration: 'Standardized Exception Resolution View',
    layoutType: 'ResponsiveFlex',
    layoutGridDimensions: Size(1024, 768),
    spacingRules: EdgeInsets.all(16.0),
    alignmentSettings: Alignment.topCenter,
    layoutValidationStatus: true,
  );

  static const List<Map<String, dynamic>> mockTelemetryData = [
    {'metric': 'Layout Structural Consistency', 'value': 1.0, 'target': 1.0},
    {'metric': 'Render Speed (ms)', 'value': 12.5, 'target': 16.0},
  ];
}

/// A reusable widget that enforces the Contextual Mirror Grid pattern.
/// Evidence views take up exactly half of the available screen area.
/// Automatically adapts flex-direction based on device orientation and viewport width.
class ContextualMirrorGrid extends StatelessWidget {
  final Widget primaryView;
  final Widget evidenceView;
  final MirrorGridConfig config;
  final double mobileBreakpoint;

  const ContextualMirrorGrid({
    super.key,
    required this.primaryView,
    required this.evidenceView,
    this.config = MockMirrorGridRepository.defaultConfig,
    this.mobileBreakpoint = 600.0,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isMobileViewport = mediaQuery.size.width < mobileBreakpoint;
    final Axis direction = isMobileViewport ? Axis.vertical : Axis.horizontal;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Poka-Yoke: Enforce strict layout validation status before rendering
        if (!config.layoutValidationStatus) {
          return _buildValidationError(theme);
        }

        return Container(
          color: theme.colorScheme.surface,
          padding: config.spacingRules,
          alignment: config.alignmentSettings,
          child: Flex(
            direction: direction,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary interaction sector
              Expanded(
                flex: 1,
                child: _buildSectorContainer(
                  theme: theme,
                  child: primaryView,
                  isRightOrBottom: false,
                  isVertical: isMobileViewport,
                ),
              ),
              // Thin division accent between interaction sectors
              _buildDivisionAccent(theme, isMobileViewport),
              // Evidence view taking exactly half of the available space
              Expanded(
                flex: 1,
                child: _buildSectorContainer(
                  theme: theme,
                  child: evidenceView,
                  isRightOrBottom: true,
                  isVertical: isMobileViewport,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectorContainer({
    required ThemeData theme,
    required Widget child,
    required bool isRightOrBottom,
    required bool isVertical,
  }) {
    // Match elevation shading patterns with systematic level structures
    final double elevation = isRightOrBottom ? 1.0 : 2.0;
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12.0),
      topRight: const Radius.circular(12.0),
      bottomLeft: Radius.circular(isVertical && !isRightOrBottom ? 0.0 : 12.0),
      bottomRight: Radius.circular(isVertical && isRightOrBottom ? 0.0 : 12.0),
    );

    return Card(
      elevation: elevation,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildDivisionAccent(ThemeData theme, bool isVertical) {
    // Execute clear structural separation using thin division accents
    return Container(
      width: isVertical ? double.infinity : 1.0,
      height: isVertical ? 1.0 : double.infinity,
      color: theme.colorScheme.outlineVariant,
      margin: isVertical
          ? const EdgeInsets.symmetric(vertical: 8.0)
          : const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Widget _buildValidationError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.0,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Layout Validation Failed',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Divergent design structures fail compliance checks. Components must use library patterns.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Example usage demonstrating how to implement the ContextualMirrorGrid
/// for data exception resolution screens.
class DataExceptionScreenExample extends StatelessWidget {
  const DataExceptionScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Exception Resolution'),
        centerTitle: true,
      ),
      body: ContextualMirrorGrid(
        primaryView: const _MockPrimaryInteractionView(),
        evidenceView: const _MockEvidenceView(),
      ),
    );
  }
}

class _MockPrimaryInteractionView extends StatelessWidget {
  const _MockPrimaryInteractionView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exception Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16.0),
          const Text('Transaction ID: TXN-9928374-UAE'),
          const SizedBox(height: 8.0),
          const Text('Status: Pending Manual Verification'),
          const Spacer(),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Resolve Exception'),
          ),
        ],
      ),
    );
  }
}

class _MockEvidenceView extends StatelessWidget {
  const _MockEvidenceView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supporting Evidence',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: const Text('Attached Document / Image Preview Area'),
            ),
          ),
        ],
      ),
    );
  }
}