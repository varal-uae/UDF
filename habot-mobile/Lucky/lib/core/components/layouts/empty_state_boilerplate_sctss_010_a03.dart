// SCTSS-010-A03 — Empty State Boilerplate Component.
// Standardized visual layout and CTA positioning for dashboards returning 0 rows, ensuring thumb-reachable CTAs and WCAG-compliant contrast.

import 'package:flutter/material.dart';

/// Enum defining the allowed visual asset types within empty state containers.
enum EmptyStateAssetType {
  illustration,
  icon,
}

/// Data class representing the atomic-level data fields for an empty state asset.
class EmptyStateAssetData {
  final String assetName;
  final EmptyStateAssetType assetType;
  final String assetLocation;
  final String assetVersion;
  final int assetSizeBytes;
  final Map<String, dynamic> assetMetadata;

  const EmptyStateAssetData({
    required this.assetName,
    required this.assetType,
    required this.assetLocation,
    this.assetVersion = '1.0.0',
    this.assetSizeBytes = 0,
    this.assetMetadata = const {},
  });
}

/// A reusable, standardized empty state component template.
/// Hard-coded into base tables to ensure developers must provide props (Poka-Yoke).
class EmptyStateBoilerplate extends StatelessWidget {
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onCtaPressed;
  final EmptyStateAssetData? assetData;
  final IconData? fallbackIcon;
  final bool pulseCta;

  const EmptyStateBoilerplate({
    super.key,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onCtaPressed,
    this.assetData,
    this.fallbackIcon,
    this.pulseCta = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildVisualAsset(theme, colorScheme),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCtaButton(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualAsset(ThemeData theme, ColorScheme colorScheme) {
    if (assetData != null) {
      if (assetData!.assetType == EmptyStateAssetType.icon) {
        return Icon(
          fallbackIcon ?? Icons.inbox_outlined,
          size: 96,
          color: colorScheme.primary.withValues(alpha: 0.6),
        );
      }
      // For illustrations, we use a placeholder container since actual image loading
      // depends on assetLocation which is mocked here.
      return Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Icon(
      fallbackIcon ?? Icons.hourglass_empty_rounded,
      size: 96,
      color: colorScheme.primary.withValues(alpha: 0.6),
    );
  }

  Widget _buildCtaButton(ThemeData theme, ColorScheme colorScheme) {
    final button = FilledButton(
      onPressed: onCtaPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(200, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(ctaLabel),
    );

    if (pulseCta) {
      return _PulsingCta(child: button);
    }

    return button;
  }
}

/// A wrapper widget that applies a gentle pulsing animation to its child,
/// visually chasing the user to initiate data entry (Self-Chasing requirement).
class _PulsingCta extends StatefulWidget {
  final Widget child;

  const _PulsingCta({required this.child});

  @override
  State<_PulsingCta> createState() => _PulsingCtaState();
}

class _PulsingCtaState extends State<_PulsingCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Mock data repository providing realistic local mock data for empty states.
class EmptyStateMockRepository {
  static const List<EmptyStateAssetData> mockAssets = [
    EmptyStateAssetData(
      assetName: 'no_data_illustration',
      assetType: EmptyStateAssetType.illustration,
      assetLocation: 'assets/images/empty_states/no_data.png',
      assetVersion: '1.0.0',
      assetSizeBytes: 24500,
      assetMetadata: {'semantic_color': 'primary', 'wcag_contrast': 4.5},
    ),
    EmptyStateAssetData(
      assetName: 'error_icon',
      assetType: EmptyStateAssetType.icon,
      assetLocation: 'assets/icons/error.svg',
      assetVersion: '1.0.0',
      assetSizeBytes: 1200,
      assetMetadata: {'semantic_color': 'error', 'wcag_contrast': 7.0},
    ),
  ];

  static EmptyStateAssetData get defaultAsset => mockAssets.first;
}

/// Example usage / Preview wrapper for the Empty State Boilerplate.
class EmptyStatePreviewScreen extends StatelessWidget {
  const EmptyStatePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty State Boilerplates'),
      ),
      body: EmptyStateBoilerplate(
        title: 'No Data Available',
        description: 'It looks like you haven\'t added any records yet. Tap below to create your first entry.',
        ctaLabel: 'Create Record',
        onCtaPressed: () {
          // Action to navigate or open creation flow
        },
        assetData: EmptyStateMockRepository.defaultAsset,
        fallbackIcon: Icons.folder_open_rounded,
        pulseCta: true,
      ),
    );
  }
}
