// SSTLA-007-A03 — Screen Dimension and Resolution Ingest Adapter Schema.
// Defines the JSON schema specification, Dart models, and validation logic for capturing mobile device viewport boundaries, aspect ratios, and text-scaling preferences to ensure uniform telemetry ingestion.

import 'dart:convert';
import 'dart:ui' as ui;

/// JSON Schema specification string for the Screen Dimension and Resolution Ingest Adapter.
/// Conforms to ISO/IEC/IEEE 29148 completeness requirements with 1:1 mappings and no orphaned values.
const String screenDimensionSchemaJson = '''
{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ScreenDimensionIngestAdapter",
  "description": "Schema for ingesting mobile device screen dimensions, resolution, aspect ratio, and text scaling preferences.",
  "type": "object",
  "properties": {
    "stepExecutionId": { "type": "string" },
    "executionStatus": { "type": "string", "enum": ["SUCCESS", "FAILED", "PENDING"] },
    "executionTimestamp": { "type": "string", "format": "date-time" },
    "stepOutcome": { "type": "string" },
    "userId": { "type": "string" },
    "sessionId": { "type": "string" },
    "completionStatus": { "type": "string", "enum": ["Complete", "Partial", "Not Complete"] },
    "viewport": {
      "type": "object",
      "properties": {
        "widthDp": { "type": "number" },
        "heightDp": { "type": "number" },
        "physicalWidthPx": { "type": "integer" },
        "physicalHeightPx": { "type": "integer" },
        "devicePixelRatio": { "type": "number" },
        "aspectRatioCategory": { "type": "string" },
        "textScaleFactor": { "type": "number" }
      },
      "required": ["widthDp", "heightDp", "physicalWidthPx", "physicalHeightPx", "devicePixelRatio", "aspectRatioCategory", "textScaleFactor"]
    }
  },
  "required": ["stepExecutionId", "executionStatus", "executionTimestamp", "stepOutcome", "userId", "sessionId", "completionStatus", "viewport"]
}
''';

/// Poka-Yoke (Mistake-Proofing) Exception thrown when fixed static pixel dimensions
/// are detected inside view styles, enforcing fluid layout syntax rule compliance.
class StaticPixelDimensionException implements Exception {
  final String message;
  const StaticPixelDimensionException(this.message);

  @override
  String toString() => 'StaticPixelDimensionException: $message';
}

/// Enum representing the qualitative completion status aligned with best practices.
enum CompletionStatus {
  complete,
  partial,
  notComplete;

  String toJsonString() {
    switch (this) {
      case CompletionStatus.complete:
        return 'Complete';
      case CompletionStatus.partial:
        return 'Partial';
      case CompletionStatus.notComplete:
        return 'Not Complete';
    }
  }
}

/// Enum representing execution status.
enum ExecutionStatus {
  success,
  failed,
  pending;

  String toJsonString() => name.toUpperCase();
}

/// Categorizes aspect ratios to group hardware viewport boundaries uniformly.
enum AspectRatioCategory {
  standard,   // ~16:9
  tall,       // ~18:9 to 19.5:9
  ultraTall,  // > 20:9
  square,     // ~1:1
  unknown
}

/// Data model representing the atomic-level fields required for telemetry ingestion.
class ScreenDimensionTelemetry {
  final String stepExecutionId;
  final ExecutionStatus executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String sessionId;
  final CompletionStatus completionStatus;
  final ViewportData viewport;

  const ScreenDimensionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.sessionId,
    required this.completionStatus,
    required this.viewport,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus.toJsonString(),
        'executionTimestamp': executionTimestamp.toUtc().toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'sessionId': sessionId,
        'completionStatus': completionStatus.toJsonString(),
        'viewport': viewport.toJson(),
      };

  factory ScreenDimensionTelemetry.fromJson(Map<String, dynamic> json) {
    return ScreenDimensionTelemetry(
      stepExecutionId: json['stepExecutionId'] as String,
      executionStatus: ExecutionStatus.values.firstWhere(
        (e) => e.toJsonString() == json['executionStatus'],
        orElse: () => ExecutionStatus.pending,
      ),
      executionTimestamp: DateTime.parse(json['executionTimestamp'] as String),
      stepOutcome: json['stepOutcome'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      completionStatus: CompletionStatus.values.firstWhere(
        (e) => e.toJsonString() == json['completionStatus'],
        orElse: () => CompletionStatus.notComplete,
      ),
      viewport: ViewportData.fromJson(json['viewport'] as Map<String, dynamic>),
    );
  }
}

/// Data model representing hardware viewport boundaries and text-scaling preferences.
class ViewportData {
  final double widthDp;
  final double heightDp;
  final int physicalWidthPx;
  final int physicalHeightPx;
  final double devicePixelRatio;
  final AspectRatioCategory aspectRatioCategory;
  final double textScaleFactor;

  const ViewportData({
    required this.widthDp,
    required this.heightDp,
    required this.physicalWidthPx,
    required this.physicalHeightPx,
    required this.devicePixelRatio,
    required this.aspectRatioCategory,
    required this.textScaleFactor,
  });

  Map<String, dynamic> toJson() => {
        'widthDp': widthDp,
        'heightDp': heightDp,
        'physicalWidthPx': physicalWidthPx,
        'physicalHeightPx': physicalHeightPx,
        'devicePixelRatio': devicePixelRatio,
        'aspectRatioCategory': aspectRatioCategory.name,
        'textScaleFactor': textScaleFactor,
      };

  factory ViewportData.fromJson(Map<String, dynamic> json) {
    return ViewportData(
      widthDp: (json['widthDp'] as num).toDouble(),
      heightDp: (json['heightDp'] as num).toDouble(),
      physicalWidthPx: json['physicalWidthPx'] as int,
      physicalHeightPx: json['physicalHeightPx'] as int,
      devicePixelRatio: (json['devicePixelRatio'] as num).toDouble(),
      aspectRatioCategory: AspectRatioCategory.values.firstWhere(
        (e) => e.name == json['aspectRatioCategory'],
        orElse: () => AspectRatioCategory.unknown,
      ),
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
    );
  }
}

/// Adapter responsible for ingesting, validating, and formatting screen dimension data.
/// Enforces Poka-Yoke rules by rejecting fixed static pixel dimensions in view styles.
class ScreenDimensionIngestAdapter {
  const ScreenDimensionIngestAdapter();

  /// Validates that a given style map does not contain fixed static pixel dimensions.
  /// Throws [StaticPixelDimensionException] if hardcoded pixel widths/heights are found.
  void validateFluidLayoutCompliance(Map<String, dynamic> viewStyle) {
    const forbiddenKeys = ['width_px', 'height_px', 'fixedWidth', 'fixedHeight'];
    for (final key in forbiddenKeys) {
      if (viewStyle.containsKey(key)) {
        throw StaticPixelDimensionException(
          'Template parser rejected fixed static pixel dimension key: "$key". Use fluid layout syntax.',
        );
      }
    }
  }

  /// Determines the aspect ratio category based on physical pixel dimensions.
  AspectRatioCategory categorizeAspectRatio(int widthPx, int heightPx) {
    if (widthPx <= 0 || heightPx <= 0) return AspectRatioCategory.unknown;
    final ratio = widthPx / heightPx;
    if (ratio >= 0.9 && ratio <= 1.1) return AspectRatioCategory.square;
    if (ratio >= 0.50 && ratio < 0.58) return AspectRatioCategory.standard;
    if (ratio >= 0.58 && ratio <= 0.65) return AspectRatioCategory.tall;
    if (ratio > 0.65) return AspectRatioCategory.ultraTall;
    return AspectRatioCategory.unknown;
  }

  /// Builds a telemetry payload from Flutter's ui.FlutterView.
  ScreenDimensionTelemetry buildTelemetryFromView({
    required ui.FlutterView view,
    required String stepExecutionId,
    required String userId,
    required String sessionId,
    required double textScaleFactor,
  }) {
    final physicalSize = view.physicalSize;
    final dpr = view.devicePixelRatio;
    final widthDp = physicalSize.width / dpr;
    final heightDp = physicalSize.height / dpr;

    return ScreenDimensionTelemetry(
      stepExecutionId: stepExecutionId,
      executionStatus: ExecutionStatus.success,
      executionTimestamp: DateTime.now(),
      stepOutcome: 'Viewport telemetry captured successfully.',
      userId: userId,
      sessionId: sessionId,
      completionStatus: CompletionStatus.complete,
      viewport: ViewportData(
        widthDp: widthDp,
        heightDp: heightDp,
        physicalWidthPx: physicalSize.width.round(),
        physicalHeightPx: physicalSize.height.round(),
        devicePixelRatio: dpr,
        aspectRatioCategory: categorizeAspectRatio(
          physicalSize.width.round(),
          physicalSize.height.round(),
        ),
        textScaleFactor: textScaleFactor,
      ),
    );
  }

  /// Serializes telemetry to a JSON string ready for BigQuery streaming link ingestion.
  String serializeForBigQuery(ScreenDimensionTelemetry telemetry) {
    return jsonEncode(telemetry.toJson());
  }
}

/// Mock repository providing realistic local mock data for testing without backend dependency.
class MockScreenDimensionRepository {
  static List<ScreenDimensionTelemetry> getMockTelemetryBatch() {
    return [
      ScreenDimensionTelemetry(
        stepExecutionId: 'exec-001-mock',
        executionStatus: ExecutionStatus.success,
        executionTimestamp: DateTime.utc(2026, 9, 28, 10, 0, 0),
        stepOutcome: 'Standard device viewport mapped.',
        userId: 'user_mock_01',
        sessionId: 'session_mock_01',
        completionStatus: CompletionStatus.complete,
        viewport: const ViewportData(
          widthDp: 390.0,
          heightDp: 844.0,
          physicalWidthPx: 1170,
          physicalHeightPx: 2532,
          devicePixelRatio: 3.0,
          aspectRatioCategory: AspectRatioCategory.tall,
          textScaleFactor: 1.0,
        ),
      ),
      ScreenDimensionTelemetry(
        stepExecutionId: 'exec-002-mock',
        executionStatus: ExecutionStatus.success,
        executionTimestamp: DateTime.utc(2026, 9, 28, 10, 5, 0),
        stepOutcome: 'Narrow screen device viewport mapped.',
        userId: 'user_mock_02',
        sessionId: 'session_mock_02',
        completionStatus: CompletionStatus.complete,
        viewport: const ViewportData(
          widthDp: 320.0,
          heightDp: 568.0,
          physicalWidthPx: 640,
          physicalHeightPx: 1136,
          devicePixelRatio: 2.0,
          aspectRatioCategory: AspectRatioCategory.standard,
          textScaleFactor: 1.2,
        ),
      ),
    ];
  }

  static String getMockSchemaJson() => screenDimensionSchemaJson;
}
