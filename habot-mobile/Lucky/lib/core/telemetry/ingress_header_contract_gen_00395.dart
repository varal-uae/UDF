// GEN-00395 — Source Document (SD) Ingress Header Contract (Mobile Clickstream & Ad Networks).
// Enforces mandatory payload headers (origin_source_id, trace_id) per the W3C Trace Context
// Specification. Emits a Pass/Fail verdict and the 'Header Presence Rate' metric (floor: 1.0).

import 'dart:math';

/// Supported ingress origins for Source Document payloads.
enum OriginSource {
  mobileClickstream('mobile_clickstream'),
  adNetwork('ad_network');

  const OriginSource(this.wireValue);

  /// Canonical wire value sent in the `origin_source_id` header.
  final String wireValue;
}

/// Result of validating a payload against the ingress header contract.
class IngressContractVerdict {
  const IngressContractVerdict({
    required this.passed,
    required this.headerPresenceRate,
    required this.missingHeaders,
  });

  /// Pass / Fail — true only when every mandatory header is present and valid.
  final bool passed;

  /// 'Header Presence Rate' metric in the range 0.0–1.0 (floor threshold: 1.0).
  final double headerPresenceRate;

  /// Mandatory headers that were absent or malformed.
  final List<String> missingHeaders;

  /// Best qualitative output captured for this validation run.
  String get qualitativeOutput => passed ? 'Pass' : 'Fail';
}

/// W3C Trace Context compliant trace identifier pair.
class TraceContext {
  const TraceContext({required this.traceId, required this.spanId});

  /// 32 lowercase hex chars (128-bit) — W3C `trace-id`.
  final String traceId;

  /// 16 lowercase hex chars (64-bit) — W3C `parent-id` / span id.
  final String spanId;

  /// Serializes to the W3C `traceparent` header format:
  /// `00-<trace-id>-<span-id>-01` (version 00, sampled flag set).
  String toTraceparent() => '00-$traceId-$spanId-01';

  static final RegExp _traceIdPattern = RegExp(r'^[0-9a-f]{32}$');
  static final RegExp _spanIdPattern = RegExp(r'^[0-9a-f]{16}$');

  /// A trace-id is valid only when it is 32 lowercase hex chars and non-zero.
  static bool isValidTraceId(String value) =>
      _traceIdPattern.hasMatch(value) && value != '0' * 32;

  /// A span-id is valid only when it is 16 lowercase hex chars and non-zero.
  static bool isValidSpanId(String value) =>
      _spanIdPattern.hasMatch(value) && value != '0' * 16;
}

/// Generates and validates the mandatory ingress headers for SD payloads
/// originating from mobile clickstream and ad network sources.
class IngressHeaderContract {
  IngressHeaderContract({Random? random})
      : _random = random ?? Random.secure();

  static const String originSourceIdHeader = 'origin_source_id';
  static const String traceIdHeader = 'trace_id';
  static const String traceparentHeader = 'traceparent';
  static const String timestampHeader = 'event_timestamp_utc';

  /// Mandatory headers — completeness must be 100% (floor threshold: 1.0).
  static const List<String> mandatoryHeaders = <String>[
    originSourceIdHeader,
    traceIdHeader,
  ];

  final Random _random;

  /// Creates a fresh W3C-compliant [TraceContext].
  TraceContext createTraceContext() => TraceContext(
        traceId: _hex(16),
        spanId: _hex(8),
      );

  /// Builds the mandatory header set for an outbound SD payload.
  Map<String, String> buildHeaders({
    required OriginSource origin,
    TraceContext? traceContext,
    DateTime? eventTimestampUtc,
  }) {
    final context = traceContext ?? createTraceContext();
    final timestamp = eventTimestampUtc ?? DateTime.now().toUtc();
    return <String, String>{
      originSourceIdHeader: origin.wireValue,
      traceIdHeader: context.traceId,
      traceparentHeader: context.toTraceparent(),
      // UTC ISO-8601 only — no local timezone offset strings.
      timestampHeader: timestamp.toIso8601String(),
    };
  }

  /// Validates [headers] against the contract and returns a Pass/Fail verdict.
  IngressContractVerdict validate(Map<String, String> headers) {
    final missing = <String>[];

    final origin = headers[originSourceIdHeader];
    if (origin == null || origin.trim().isEmpty) {
      missing.add(originSourceIdHeader);
    }

    final traceId = headers[traceIdHeader];
    if (traceId == null || !TraceContext.isValidTraceId(traceId)) {
      missing.add(traceIdHeader);
    }

    final presentCount = mandatoryHeaders.length - missing.length;
    final rate = presentCount / mandatoryHeaders.length;

    return IngressContractVerdict(
      passed: missing.isEmpty,
      headerPresenceRate: rate,
      missingHeaders: List<String>.unmodifiable(missing),
    );
  }

  /// Returns true when [value] is a UTC timestamp with no local offset.
  bool isUtcTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed != null && (value.endsWith('Z') || parsed.isUtc);
  }

  String _hex(int byteCount) {
    final buffer = StringBuffer();
    for (var i = 0; i < byteCount; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
