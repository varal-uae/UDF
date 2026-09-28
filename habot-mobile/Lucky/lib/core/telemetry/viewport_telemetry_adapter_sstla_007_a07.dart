// SSTLA-007-A07 — Viewport Telemetry Adapter & Device Property Extractor.
// Defines the mobile device screen dimension and resolution ingest adapter schema,
// extracting hardware viewport boundaries, aspect ratios, and text-scaling preferences
// to ensure fluid layout compliance and catch display bugs across modern mobile screens.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents the categorized hardware viewport boundaries and telemetry data.
class ViewportTelemetryData {
  final String frontendTechnology;
  final String frameworkVersion;
  final String buildConfiguration;
  final double screenWidthPx;
  final double screenHeightPx;
  final double devicePixelRatio;
  final double aspectRatio;
  final double textScaleFactor;
  final ViewportCategory viewportCategory;
  final String buildOutputPath;
  final DateTime timestamp;

  const ViewportTelemetryData({
    required this.frontendTechnology,
    required this.frameworkVersion,
    required this.buildConfiguration,
    required this.screenWidthPx,
    required this.screenHeightPx,
    required this.devicePixelRatio,
    required this.aspectRatio,
    required this.textScaleFactor,
    required this.viewportCategory,
    required this.buildOutputPath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'frontend_technology': frontendTechnology,
        'framework_version': frameworkVersion,
        'build_configuration': buildConfiguration,
        'screen_width_px': screenWidthPx,
        'screen_height_px': screenHeightPx,
        'device_pixel_ratio': devicePixelRatio,
        'aspect_ratio': aspectRatio,
        'text_scale_factor': textScaleFactor,
        'viewport_category': viewportCategory.name,
        'build_output_path': buildOutputPath,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Categories used to group hardware viewport boundaries.
enum ViewportCategory {
  narrow,
  standard,
  wide,
  tablet,
}

/// Poka-Yoke (Mistake-Proofing) Exception for fixed static pixel dimensions.
class StaticPixelDimensionException implements Exception {
  final String message;
  const StaticPixelDimensionException(this.message);

  @override
  String toString() => 'StaticPixelDimensionException: $message';
}

/// Adapter responsible for extracting device properties using native Flutter API hooks.
class ViewportTelemetryAdapter {
  ViewportTelemetryAdapter._();

  /// Extracts current device properties and maps them to the telemetry schema.
  static ViewportTelemetryData extractDeviceProperties(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final dpr = mediaQuery.devicePixelRatio;
    final textScale = mediaQuery.textScaler.scale(1.0);

    // Calculate logical pixels to physical pixels mapping
    final widthPx = size.width * dpr;
    final heightPx = size.height * dpr;
    final aspectRatio = size.width / size.height;

    return ViewportTelemetryData(
      frontendTechnology: 'Flutter',
      frameworkVersion: '3.24.0', // Aligned with current stable
      buildConfiguration: const bool.fromEnvironment('dart.vm.product') ? 'release' : 'debug',
      screenWidthPx: widthPx,
      screenHeightPx: heightPx,
      devicePixelRatio: dpr,
      aspectRatio: aspectRatio,
      textScaleFactor: textScale,
      viewportCategory: _categorizeViewport(size.width),
      buildOutputPath: 'habot-mobile/build/app/outputs',
      timestamp: DateTime.now().toUtc(),
    );
  }

  /// Groups hardware viewport boundaries into standardized categories.
  static ViewportCategory _categorizeViewport(double logicalWidth) {
    if (logicalWidth < 360) return ViewportCategory.narrow;
    if (logicalWidth < 600) return ViewportCategory.standard;
    if (logicalWidth < 840) return ViewportCategory.wide;
    return ViewportCategory.tablet;
  }

  /// Poka-Yoke: Physically rejects fixed static pixel dimensions inside view styles.
  /// Forces fluid layout syntax rule compliance by validating against hardcoded bounds.
  static void validateFluidLayoutCompliance(double proposedFixedWidth, double proposedFixedHeight) {
    // Reject any strictly fixed static pixel dimensions that exceed safe fluid thresholds
    // In a fluid layout, elements should rely on fractions, flex, or constraints, not raw px.
    const double maxSafeStaticThreshold = 100.0; 
    
    if (proposedFixedWidth > maxSafeStaticThreshold || proposedFixedHeight > maxSafeStaticThreshold) {
      throw const StaticPixelDimensionException(
        'Template parser rejected fixed static pixel dimensions. '
        'Use fluid layout syntax (e.g., Expanded, Flexible, FractionallySizedBox) instead of raw pixel values.',
      );
    }
  }
}

/// Mock repository simulating BigQuery alignment for client platform attribute headers.
class ViewportTelemetryMockRepository {
  final List<ViewportTelemetryData> _mockIngestedData = [];

  ViewportTelemetryMockRepository() {
    // Populate with realistic local mock data
    _mockIngestedData.addAll([
      ViewportTelemetryData(
        frontendTechnology: 'Flutter',
        frameworkVersion: '3.24.0',
        buildConfiguration: 'release',
        screenWidthPx: 1170,
        screenHeightPx: 2532,
        devicePixelRatio: 3.0,
        aspectRatio: 0.462,
        textScaleFactor: 1.0,
        viewportCategory: ViewportCategory.standard,
        buildOutputPath: 'habot-mobile/build/app/outputs/flutter-apk/app-release.apk',
        timestamp: DateTime.utc(2026, 9, 28, 10, 0),
      ),
      ViewportTelemetryData(
        frontendTechnology: 'Flutter',
        frameworkVersion: '3.24.0',
        buildConfiguration: 'debug',
        screenWidthPx: 1080,
        screenHeightPx: 2400,
        devicePixelRatio: 2.75,
        aspectRatio: 0.45,
        textScaleFactor: 1.2,
        viewportCategory: ViewportCategory.narrow,
        buildOutputPath: 'habot-mobile/build/app/outputs/flutter-apk/app-debug.apk',
        timestamp: DateTime.utc(2026, 9, 28, 10, 15),
      ),
    ]);
  }

  /// Ingests new telemetry data into the local mock store.
  void ingest(ViewportTelemetryData data) {
    _mockIngestedData.add(data);
  }

  /// Retrieves all ingested data formatted for analytical views.
  List<Map<String, dynamic>> getAnalyticalViewHeaders() {
    return _mockIngestedData.map((e) => e.toJson()).toList();
  }
}
