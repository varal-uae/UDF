import 'dart:ui';
import 'package:flutter/material.dart';

// MCIIM-009-12 — MTO Viewport Crop Padding.
// Spec: "Define MTO Viewport Crop Padding"
//       "Verify that peripheral text fields are blurred out completely
//        by styling overlays."
//       "Image scales to remain legible without zooming."
//       "Fluid image containers max-width: 100%."
//       "Total focus on atomic task."
//       "CSS overflow: hidden" → Flutter: ClipRect
//
// What it does:
//   - Shows content (image/document) filling the container
//   - Blurs the peripheral edges via BackdropFilter + gradient mask
//   - Everything outside the crop zone is blurred and dimmed
//   - User's eye is drawn to the central crop region only

// ── Crop padding config ───────────────────────────────────────────────────────

class MtoCropConfig {
  const MtoCropConfig({
    this.edgeBlurSigma   = 12.0,
    this.edgeDimOpacity  = 0.45,
    this.paddingFraction = 0.15,
    this.borderRadius    = 8.0,
  });

  /// Blur intensity on peripheral edges. Higher = more blur.
  final double edgeBlurSigma;

  /// Darkness of the dim overlay on edges (0.0–1.0).
  final double edgeDimOpacity;

  /// Fraction of width/height that is blurred on each side.
  /// 0.15 = 15% of each edge is blurred.
  final double paddingFraction;

  /// Border radius of the central clear zone.
  final double borderRadius;

  static const sharp  = MtoCropConfig(edgeBlurSigma: 0,  edgeDimOpacity: 0.6,  paddingFraction: 0.2);
  static const medium = MtoCropConfig(edgeBlurSigma: 12, edgeDimOpacity: 0.45, paddingFraction: 0.15);
  static const soft   = MtoCropConfig(edgeBlurSigma: 20, edgeDimOpacity: 0.3,  paddingFraction: 0.1);
}

// ── Main widget ───────────────────────────────────────────────────────────────

/// Displays content with peripheral blur/dim overlay.
/// Central crop region stays sharp and fully visible.
/// Spec: "CSS overflow: hidden" → wrapped in ClipRect.
/// Spec: "Fluid image containers max-width: 100%" → width: double.infinity.
class MtoViewportCropPadding extends StatelessWidget {
  const MtoViewportCropPadding({
    super.key,
    required this.child,
    this.config = MtoCropConfig.medium,
    this.height,
    this.showCropBorder = true,
  });

  /// The content to display — image, document preview, etc.
  final Widget child;

  final MtoCropConfig config;

  /// Height of the viewport. Defaults to 300dp if not specified.
  final double? height;

  /// Shows a subtle border around the crop zone.
  final bool showCropBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h     = height ?? 300.0;

    return ClipRect(  // overflow: hidden equivalent
      child: SizedBox(
        width:  double.infinity,  // max-width: 100%
        height: h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Content layer — scales to fill ──
            FittedBox(
              fit:   BoxFit.contain,  // scales to remain legible without zooming
              child: child,
            ),

            // ── Peripheral blur overlays — 4 edges ──
            _EdgeBlurOverlay(
              config:    config,
              totalHeight: h,
            ),

            // ── Crop zone border ──
            if (showCropBorder)
              _CropZoneBorder(
                config: config,
                theme:  theme,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Edge blur overlay ─────────────────────────────────────────────────────────

class _EdgeBlurOverlay extends StatelessWidget {
  const _EdgeBlurOverlay({
    required this.config,
    required this.totalHeight,
  });

  final MtoCropConfig config;
  final double totalHeight;

  @override
  Widget build(BuildContext context) {
    // Four directional blur strips — top, bottom, left, right
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top edge
        Positioned(
          top: 0, left: 0, right: 0,
          height: totalHeight * config.paddingFraction,
          child: _BlurStrip(
            sigma:      config.edgeBlurSigma,
            dimOpacity: config.edgeDimOpacity,
            direction:  _BlurDirection.top,
          ),
        ),

        // Bottom edge
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: totalHeight * config.paddingFraction,
          child: _BlurStrip(
            sigma:      config.edgeBlurSigma,
            dimOpacity: config.edgeDimOpacity,
            direction:  _BlurDirection.bottom,
          ),
        ),

        // Left edge
        Positioned(
          top: 0, bottom: 0, left: 0,
          width: 60,  // fixed width peripheral strip
          child: _BlurStrip(
            sigma:      config.edgeBlurSigma,
            dimOpacity: config.edgeDimOpacity,
            direction:  _BlurDirection.left,
          ),
        ),

        // Right edge
        Positioned(
          top: 0, bottom: 0, right: 0,
          width: 60,
          child: _BlurStrip(
            sigma:      config.edgeBlurSigma,
            dimOpacity: config.edgeDimOpacity,
            direction:  _BlurDirection.right,
          ),
        ),
      ],
    );
  }
}

enum _BlurDirection { top, bottom, left, right }

class _BlurStrip extends StatelessWidget {
  const _BlurStrip({
    required this.sigma,
    required this.dimOpacity,
    required this.direction,
  });

  final double sigma;
  final double dimOpacity;
  final _BlurDirection direction;

  AlignmentGeometry get _begin {
    switch (direction) {
      case _BlurDirection.top:    return Alignment.topCenter;
      case _BlurDirection.bottom: return Alignment.bottomCenter;
      case _BlurDirection.left:   return Alignment.centerLeft;
      case _BlurDirection.right:  return Alignment.centerRight;
    }
  }

  AlignmentGeometry get _end {
    switch (direction) {
      case _BlurDirection.top:    return Alignment.bottomCenter;
      case _BlurDirection.bottom: return Alignment.topCenter;
      case _BlurDirection.left:   return Alignment.centerRight;
      case _BlurDirection.right:  return Alignment.centerLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sigma <= 0) {
      // Sharp mode — just dim, no blur
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  _begin,
            end:    _end,
            colors: [
              Colors.black.withOpacity(dimOpacity),
              Colors.transparent,
            ],
          ),
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:  _begin,
              end:    _end,
              colors: [
                Colors.black.withOpacity(dimOpacity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Crop zone border ──────────────────────────────────────────────────────────

class _CropZoneBorder extends StatelessWidget {
  const _CropZoneBorder({required this.config, required this.theme});
  final MtoCropConfig config;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 60,
        vertical:   300 * config.paddingFraction,
      ),
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(config.borderRadius),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Focused field overlay ─────────────────────────────────────────────────────

/// Wraps a form field and blurs everything else on the screen
/// when this field is focused.
/// Spec: "Verify that peripheral text fields are blurred out completely."
/// Usage: wrap individual fields in FocusedFieldOverlay inside a Stack.
class PeripheralBlurOverlay extends StatelessWidget {
  const PeripheralBlurOverlay({
    super.key,
    required this.isActive,
    required this.child,
    this.blurSigma = 8.0,
    this.dimOpacity = 0.5,
  });

  /// When true — overlay dims and blurs. When false — transparent.
  final bool isActive;
  final Widget child;
  final double blurSigma;
  final double dimOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Blur/dim overlay — covers everything when active
        AnimatedOpacity(
          opacity:  isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isActive,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isActive ? blurSigma : 0,
                sigmaY: isActive ? blurSigma : 0,
              ),
              child: Container(
                color: Colors.black.withOpacity(isActive ? dimOpacity : 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
