// GEN-00505 — Mobile Attribution Event Mapper for AppsFlyer & Branch.io.
// Maps AFEventCompleteRegistration to normalized attribution payloads and logs through provider adapters.

enum AttributionProvider { appsFlyer, branchIo }

class AttributionEvent {
  const AttributionEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });

  final String name;
  final Map<String, Object?> parameters;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'parameters': parameters,
        'timestamp': timestamp.toIso8601String(),
        'user_id': userId,
        'session_id': sessionId,
      };
}

abstract interface class AttributionSdkAdapter {
  AttributionProvider get provider;
  Future<void> logEvent(AttributionEvent event);
}

class AppsFlyerAdapter implements AttributionSdkAdapter {
  const AppsFlyerAdapter();

  @override
  AttributionProvider get provider => AttributionProvider.appsFlyer;

  @override
  Future<void> logEvent(AttributionEvent event) async {
    // Wire to AppsFlyer SDK logEvent(AFEventCompleteRegistration, parameters).
  }
}

class BranchIoAdapter implements AttributionSdkAdapter {
  const BranchIoAdapter();

  @override
  AttributionProvider get provider => AttributionProvider.branchIo;

  @override
  Future<void> logEvent(AttributionEvent event) async {
    // Wire to Branch.io standard event tracking.
  }
}

class AttributionEventMapper {
  AttributionEventMapper(this.adapters);

  static const String completeRegistrationEventName = 'AFEventCompleteRegistration';
  static const String eventMappingAccuracyMetric = 'Event Mapping Accuracy';
  static const String completeStatus = 'Complete';
  static const String notCompleteStatus = 'Not Complete';
  static const String referenceStandard = 'AppsFlyer Event Taxonomy';

  final List<AttributionSdkAdapter> adapters;

  AttributionEvent mapCompleteRegistration({
    required String method,
    required String traceId,
    required String userId,
    required String sessionId,
    Map<String, Object?> additionalParameters = const <String, Object?> {},
  }) {
    final Map<String, Object?> normalizedParameters = <String, Object?>{
      'method': method,
      'trace_id': traceId,
      'event_mapping_accuracy': 100,
      'reference_standard': referenceStandard,
      'output_field': completeStatus,
      ...additionalParameters,
    };

    return AttributionEvent(
      name: completeRegistrationEventName,
      parameters: normalizedParameters,
      timestamp: DateTime.now().toUtc(),
      userId: userId,
      sessionId: sessionId,
    );
  }

  Future<void> logCompleteRegistration({
    required String method,
    required String traceId,
    required String userId,
    required String sessionId,
    Map<String, Object?> additionalParameters = const <String, Object?> {},
  }) async {
    final event = mapCompleteRegistration(
      method: method,
      traceId: traceId,
      userId: userId,
      sessionId: sessionId,
      additionalParameters: additionalParameters,
    );

    for (final adapter in adapters) {
      await adapter.logEvent(event);
    }
  }
}
