// MCIIM-009-01 — MTO Viewport Crop Padding & Fluid Image Container.
// Enforces 100% max-width fluid containers, clip overflow bounds, and legible task image scaling.

import 'package:flutter/material.dart';

class FluidImageCropContainer extends StatelessWidget {
  const FluidImageCropContainer({
    super.key,
    required this.imageProvider,
    this.aspectRatio = 16 / 9,
    this.padding = const EdgeInsets.all(8.0),
  });

  final ImageProvider imageProvider;
  final double aspectRatio;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth), // max-width: 100%
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // CSS overflow: hidden
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain, // Legible scaling without manual zooming
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image_outlined, size: 36, color: cs.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
