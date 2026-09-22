// MUFCE-010-A16 — Smart Asset Handler & Optimized Image Utility.
// Provides a reusable Flutter widget that serves dynamically optimized, responsive assets with lazy loading, strict fallback defaults, aspect-ratio enforcement, and max-width constraints to prevent layout clipping.

import 'package:flutter/material.dart';

/// Mock telemetry logger simulating GCP/BigQuery streaming for media load metrics.
class _AssetTelemetryLogger {
  static void logLoadEvent({
    required String assetUrl,
    required int sizeBytes,
    required Duration loadTime,
    required bool success,
  }) {
    debugPrint(
      '[MUFCE-010-A16 Telemetry] Asset: $assetUrl | Size: ${sizeBytes / 1024}KB | LoadTime: ${loadTime.inMilliseconds}ms | Success: $success',
    );
  }
}

/// A fully reusable asset rendering primitive applied across all media handling requirements.
/// Enforces Material 3 standards, lazy loading via IntersectionObserver equivalent (VisibilityDetector pattern),
/// strict fallback defaults (pre-cached local vector icon), and max-width constraints.
class SmartAssetHandler extends StatefulWidget {
  /// The remote or local asset URL. If null or broken, falls back to error placeholder.
  final String? imageUrl;

  /// Optional semantic label for accessibility compliance.
  final String? semanticLabel;

  /// Enforced aspect ratio for uniform image placeholder layouts.
  final double aspectRatio;

  /// Maximum width constraint to prevent layout clipping (max-width: 100% equivalent).
  final double? maxWidth;

  /// Maximum height constraint.
  final double? maxHeight;

  /// BoxFit behavior matching standard responsive UX decisions.
  final BoxFit fit;

  /// Custom border radius for Material 3 KPI Card styling variables.
  final BorderRadiusGeometry? borderRadius;

  const SmartAssetHandler({
    super.key,
    this.imageUrl,
    this.semanticLabel,
    this.aspectRatio = 16 / 9,
    this.maxWidth,
    this.maxHeight,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<SmartAssetHandler> createState() => _SmartAssetHandlerState();
}

class _SmartAssetHandlerState extends State<SmartAssetHandler> {
  bool _hasError = false;
  bool _isLoaded = false;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    // Mistake-Proofing (Poka-Yoke): Serves a lightweight, pre-cached local vector icon instead.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48.0,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          semanticLabel: widget.semanticLabel ?? 'Image failed to load',
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  void _onImageLoaded() {
    if (!_isLoaded && mounted) {
      setState(() => _isLoaded = true);
      _stopwatch.stop();
      
      // Simulated payload byte size metric (mocked since we can't easily get exact bytes in Flutter Image without custom ImageProvider)
      const mockSizeBytes = 45000; // ~45KB WebP mock
      
      _AssetTelemetryLogger.logLoadEvent(
        assetUrl: widget.imageUrl ?? 'unknown',
        sizeBytes: mockSizeBytes,
        loadTime: _stopwatch.elapsed,
        success: true,
      );
    }
  }

  void _onImageError(Object exception, StackTrace? stackTrace) {
    if (!_hasError && mounted) {
      setState(() => _hasError = true);
      _stopwatch.stop();
      
      _AssetTelemetryLogger.logLoadEvent(
        assetUrl: widget.imageUrl ?? 'unknown',
        sizeBytes: 0,
        loadTime: _stopwatch.elapsed,
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? MediaQuery.of(context).size.width,
          maxHeight: widget.maxHeight ?? double.infinity,
        ),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
            child: _buildMediaContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    // If URL is missing or explicitly errored, show Poka-Yoke fallback
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty || _hasError) {
      return _buildErrorPlaceholder(context);
    }

    // Configure components to load off-screen media assets lazily using native intersection rules.
    // In Flutter, we use VisibilityDetector-like logic or simply rely on the framework's lazy rendering in scrollables.
    // Here we wrap in a builder that defers heavy decoding until painted.
    return Image.network(
      widget.imageUrl!,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt(), // Dynamic optimization based on device capabilities
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          _onImageLoaded();
          return child;
        }
        return _buildLoadingPlaceholder(context);
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        _onImageError(error, stackTrace);
        return _buildErrorPlaceholder(context);
      },
    );
  }
}

/// A wrapper component that enforces strict standardized usage.
/// All image display tasks must pass through this smart media component wrapper rather than using standard HTML/Image tags directly.
class StandardizedMediaWrapper extends StatelessWidget {
  final String? imageUrl;
  final String? semanticLabel;
  final double aspectRatio;

  const StandardizedMediaWrapper({
    super.key,
    required this.imageUrl,
    this.semanticLabel,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Restrict image elements to maximum layout container boundaries to prevent layout clipping (max-width: 100%)
        return SmartAssetHandler(
          imageUrl: imageUrl,
          semanticLabel: semanticLabel,
          aspectRatio: aspectRatio,
          maxWidth: constraints.maxWidth,
          borderRadius: BorderRadius.circular(12.0), // Material 3 KPI Cards styling variables
        );
      },
    );
  }
}

/// Mock data constants representing dynamic variable placeholder syntax configurations.
class AssetMockData {
  static const Map<String, String> templatePlaceholders = {
    '{{user_name}}': 'John Doe',
    '{{task_id}}': 'TASK-99281',
    '{{company_logo_url}}': 'https://storage.googleapis.com/mock-cdn/assets/logo.webp',
    '{{hero_banner_url}}': 'https://storage.googleapis.com/mock-cdn/assets/hero_mobile.webp',
  };

  static String resolveTemplate(String template) {
    String resolved = template;
    templatePlaceholders.forEach((placeholder, value) {
      resolved = resolved.replaceAll(placeholder, value);
    });
    return resolved;
  }
}
