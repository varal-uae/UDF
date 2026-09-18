// GEN-01457 — Vendor Fallback Image Placeholder Widget.
// Provides a reusable Material 3 compliant image widget that displays a fallback placeholder if the vendor image fails to load. Supports responsive sizing and 48x48dp minimum touch targets.

import 'package:flutter/material.dart';

/// A reusable widget that attempts to load a vendor image from [imageUrl]
/// and gracefully falls back to an M3-styled placeholder on error or null URL.
class VendorFallbackImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final VoidCallback? onTap;

  const VendorFallbackImage({
    super.key,
    this.imageUrl,
    this.size = 48.0,
    this.borderRadius = 12.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageWidget = _buildPlaceholder(colorScheme);
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingState(colorScheme, loadingProgress);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(colorScheme);
          },
        ),
      );
    }

    // Ensure minimum 48x48dp touch target per M3 guidelines
    return Semantics(
      label: 'Vendor Image',
      hint: imageUrl == null || imageUrl!.trim().isEmpty ? 'Default placeholder image' : 'Loaded vendor image',
      child: SizedBox(
        width: size < 48.0 ? 48.0 : size,
        height: size < 48.0 ? 48.0 : size,
        child: Center(
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: imageWidget,
                )
              : imageWidget,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Icon(
        Icons.storefront_outlined,
        size: size * 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme, ImageChunkEvent loadingProgress) {
    final expectedBytes = loadingProgress.expectedTotalBytes;
    final progress = expectedBytes != null && expectedBytes > 0
        ? loadingProgress.cumulativeBytesLoaded / expectedBytes
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.6,
          height: size * 0.6,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.0,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Mock data provider for local development and testing without backend dependency.
class VendorImageMockData {
  static const List<Map<String, dynamic>> mockVendors = [
    {'id': 'v1', 'name': 'Alpha Electronics', 'imageUrl': 'https://picsum.photos/id/1/200/200'},
    {'id': 'v2', 'name': 'Beta Groceries', 'imageUrl': 'https://picsum.photos/id/2/200/200'},
    {'id': 'v3', 'name': 'Gamma Services', 'imageUrl': null}, // Will trigger fallback
    {'id': 'v4', 'name': 'Delta Tech', 'imageUrl': 'invalid_url_to_trigger_error'}, // Will trigger fallback
    {'id': 'v5', 'name': 'Epsilon Retail', 'imageUrl': ''}, // Will trigger fallback
  ];
}
