// GEN-00637 — Mobile UX Friction Log Drop Guard.
// Guards hesitation/friction telemetry by dropping records when required contextual metadata headers are absent.
// Supports OWASP Log Validation Rules alignment and dependency-free use from mobile telemetry pipelines.

class FrictionLogDropGuard {
  final Set<String> requiredHeaders;

  const FrictionLogDropGuard({
    this.requiredHeaders = const {
      'trace_id',
      'session_id',
      'event_date',
    },
  });

  bool shouldDrop(Map<String, String?> headers) {
    return requiredHeaders.any((header) {
      final value = headers[header];
      return value == null || value.trim().isEmpty;
    });
  }

  FrictionLogEvent? guard(FrictionLogEvent event) {
    return shouldDrop(event.contextualMetadataHeaders) ? null : event;
  }
}

class FrictionLogEvent {
  final String name;
  final Map<String, Object?> data;
  final Map<String, String?> contextualMetadataHeaders;

  const FrictionLogEvent({
    required this.name,
    required this.data,
    required this.contextualMetadataHeaders,
  });
}

enum FrictionLogDisposition {
  accepted,
  droppedMissingContext,
}

FrictionLogDisposition evaluateFrictionLog(
  FrictionLogDropGuard guard,
  FrictionLogEvent event,
) {
  return guard.guard(event) == null
      ? FrictionLogDisposition.droppedMissingContext
      : FrictionLogDisposition.accepted;
}
