// SSTLA-007-A04 — Viewport Telemetry Schema Adapter.
// Defines mobile device screen dimension and resolution ingest adapter schema with strict validation rules, boundary constraints, and fluid layout enforcement to prevent fixed pixel usage.

import 'dart:ui';

/// Enumerates the allowed definition types for viewport attributes.
enum ViewportDefinitionType {
  dimension,
  resolution,
  aspectRatio,
  textScale,
}

/// Represents a single atomic-level data field definition for viewport telemetry.
class ViewportFieldDefinition {
  final String definitionId;
  final String definitionName;
  final Map<String, dynamic> definitionParameters;
  final ViewportDefinitionType definitionType;
  final bool validationStatus;

  const ViewportFieldDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionParameters,
    required this.definitionType,
    required this.validationStatus,
  });

  Map<String, dynamic> toJson() => {
        'definition_id': definitionId,
        'definition_name': definitionName,
        'definition_parameters': definitionParameters,
        'definition_type': definitionType.name,
        'validation_status': validationStatus,
      };
}

/// Poka-Yoke (Mistake-Proofing) parser that physically rejects fixed static
/// pixel dimensions inside view styles, forcing fluid layout syntax compliance.
class FluidLayoutEnforcer {
  const FluidLayoutEnforcer._();

  /// Validates that no fixed pixel constraints are used in layout parameters.
  /// Returns true if the layout is fluid-compliant, false otherwise.
  static bool validateFluidCompliance(Map<String, dynamic> layoutParams) {
    const forbiddenKeys = [
      'fixed_width_px',
      'fixed_height_px',
      'static_pixel_width',
      'static_pixel_height',
      'absolute_px',
    ];

    for (final key in layoutParams.keys) {
      final lowerKey = key.toLowerCase();
      if (forbiddenKeys.any((forbidden) => lowerKey.contains(forbidden))) {
        return false;
      }
      // Reject raw integer/double values explicitly flagged as pixels
      if (lowerKey.contains('px') && layoutParams[key] is num) {
        return false;
      }
    }
    return true;
  }
}

/// Core adapter schema for ingesting and validating mobile device viewport
/// hardware boundaries, ensuring uniform storage of aspect ratios and
/// text-scaling preferences for BigQuery analytical views.
class ViewportSchemaAdapter {
  final List<ViewportFieldDefinition> _definitions;
  final double thresholdPrecision;

  ViewportSchemaAdapter({
    required List<ViewportFieldDefinition> definitions,
    this.thresholdPrecision = 0.95,
  }) : _definitions = definitions;

  /// Returns all registered field definitions.
  List<ViewportFieldDefinition> get definitions =>
      List.unmodifiable(_definitions);

  /// Evaluates the threshold/boundary definition precision percentage.
  /// Target optimal is 1.0 (100%), floor boundary is 0.95 (95%).
  double evaluatePrecision() {
    if (_definitions.isEmpty) return 0.0;
    final validCount =
        _definitions.where((d) => d.validationStatus).length;
    return validCount / _definitions.length;
  }

  /// Returns qualitative Pass/Fail based on NIST SP 800-53 style parameterisation.
  String get qualitativeStatus {
    final precision = evaluatePrecision();
    return precision >= thresholdPrecision ? 'Pass' : 'Fail';
  }

  /// Validates incoming device data against the schema definitions.
  /// Throws [ArgumentError] if fluid layout compliance fails (Poka-Yoke).
  void ingestDeviceData({
    required Size screenSize,
    required double devicePixelRatio,
    required double textScaleFactor,
    required Map<String, dynamic> layoutParams,
  }) {
    if (!FluidLayoutEnforcer.validateFluidCompliance(layoutParams)) {
      throw ArgumentError(
        'Poka-Yoke Violation: Fixed static pixel dimensions detected in view styles. '
        'Fluid layout syntax rule compliance is mandatory.',
      );
    }

    if (screenSize.width <= 0 || screenSize.height <= 0) {
      throw ArgumentError('Screen dimensions must be positive values.');
    }
    if (devicePixelRatio <= 0) {
      throw ArgumentError('Device pixel ratio must be greater than zero.');
    }
    if (textScaleFactor < 0.5 || textScaleFactor > 3.0) {
      throw ArgumentError(
          'Text scale factor out of acceptable boundary constraints (0.5 - 3.0).');
    }
  }

  /// Generates structured payload for GCP / BigQuery alignment.
  Map<String, dynamic> generateTelemetryPayload({
    required Size screenSize,
    required double devicePixelRatio,
    required double textScaleFactor,
    required String sessionId,
    required String userId,
  }) {
    return {
      'schema_version': 'SSTLA-007-A04',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': sessionId,
      'user_id': userId,
      'completion_status': qualitativeStatus,
      'precision_score': evaluatePrecision(),
      'hardware_attributes': {
        'screen_width_logical': screenSize.width,
        'screen_height_logical': screenSize.height,
        'aspect_ratio': screenSize.width / screenSize.height,
        'device_pixel_ratio': devicePixelRatio,
        'text_scale_factor': textScaleFactor,
      },
      'field_definitions': _definitions.map((d) => d.toJson()).toList(),
    };
  }
}

// ============================================================================
// MOCK DATA — Local hardcoded reference data for development without backend
// ============================================================================

/// Mock repository providing standardized viewport field definitions.
class MockViewportSchemaRepository {
  const MockViewportSchemaRepository._();

  static List<ViewportFieldDefinition> getMockDefinitions() {
    return const [
      ViewportFieldDefinition(
        definitionId: 'VD-001',
        definitionName: 'Logical Screen Width',
        definitionParameters: {
          'min_value': 320.0,
          'max_value': 2560.0,
          'unit': 'dp',
          'fluid_constraint': 'percentage_or_flex',
        },
        definitionType: ViewportDefinitionType.dimension,
        validationStatus: true,
      ),
      ViewportFieldDefinition(
        definitionId: 'VD-002',
        definitionName: 'Logical Screen Height',
        definitionParameters: {
          'min_value': 480.0,
          'max_value': 1440.0,
          'unit': 'dp',
          'fluid_constraint': 'percentage_or_flex',
        },
        definitionType: ViewportDefinitionType.dimension,
        validationStatus: true,
      ),
      ViewportFieldDefinition(
        definitionId: 'VR-001',
        definitionName: 'Device Pixel Ratio',
        definitionParameters: {
          'min_value': 1.0,
          'max_value': 4.0,
          'step': 0.5,
        },
        definitionType: ViewportDefinitionType.resolution,
        validationStatus: true,
      ),
      ViewportFieldDefinition(
        definitionId: 'VA-001',
        definitionName: 'Aspect Ratio Category',
        definitionParameters: {
          'allowed_categories': ['16:9', '18:9', '19.5:9', '21:9'],
          'fallback_category': 'unknown',
        },
        definitionType: ViewportDefinitionType.aspectRatio,
        validationStatus: true,
      ),
      ViewportFieldDefinition(
        definitionId: 'VT-001',
        definitionName: 'Text Scale Factor',
        definitionParameters: {
          'min_value': 0.8,
          'max_value': 2.0,
          'default_value': 1.0,
          'accessibility_compliant': true,
        },
        definitionType: ViewportDefinitionType.textScale,
        validationStatus: true,
      ),
    ];
  }

  static ViewportSchemaAdapter createMockAdapter() {
    return ViewportSchemaAdapter(
      definitions: getMockDefinitions(),
      thresholdPrecision: 0.95,
    );
  }
}
