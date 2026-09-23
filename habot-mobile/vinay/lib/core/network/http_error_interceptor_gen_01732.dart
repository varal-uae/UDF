// GEN-01732 — HTTP Error Interceptor for 422 and 500 Errors.
// Configures Dio interceptors to dynamically catch HTTP 422 and 500 errors, stream execution events to mock telemetry, and enforce M3 UI-ready error states.

import 'package:dio/dio.dart';

/// Represents the completion status of the interception step.
enum InterceptionStatus { complete, partial, notComplete }

/// Telemetry event model for BigQuery alignment (mocked locally).
class InterceptionTelemetryEvent {
  final String traceId;
  final DateTime eventDate;
  final int statusCode;
  final String uri;
  final InterceptionStatus status;

  InterceptionTelemetryEvent({
    required this.traceId,
    required this.eventDate,
    required this.statusCode,
    required this.uri,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'trace_id': traceId,
        'event_date': eventDate.toIso8601String(),
        'status_code': statusCode,
        'uri': uri,
        'status': status.name,
      };
}

/// Custom exception for HTTP 422 Unprocessable Entity.
class HttpUnprocessableEntityException implements Exception {
  final String message;
  final Response? response;

  HttpUnprocessableEntityException(this.message, [this.response]);

  @override
  String toString() => 'HttpUnprocessableEntityException: $message';
}

/// Custom exception for HTTP 500 Internal Server Error.
class HttpInternalServerErrorException implements Exception {
  final String message;
  final Response? response;

  HttpInternalServerErrorException(this.message, [this.response]);

  @override
  String toString() => 'HttpInternalServerErrorException: $message';
}

/// Mock telemetry sink simulating BigQuery streaming partitioned by event_date, clustered by trace_id.
class MockBigQueryTelemetrySink {
  static final List<InterceptionTelemetryEvent> _events = [];

  static void record(InterceptionTelemetryEvent event) {
    _events.add(event);
    // In production, this would stream to GCP BigQuery.
    // print('[GEN-01732] Telemetry recorded: ${event.toJson()}');
  }

  static List<InterceptionTelemetryEvent> get events => List.unmodifiable(_events);

  /// Metric: HTTP Error Interception Coverage (%)
  /// Floor Boundary: 98, Optimal Target: 100, Ceiling: 100
  static double calculateCoverage(int totalRequests, int interceptedErrors) {
    if (totalRequests == 0) return 100.0;
    return (interceptedErrors / totalRequests) * 100.0;
  }
}

/// Interceptor that dynamically catches HTTP 422 and 500 errors.
/// Compliant with HTTP/1.1 Standards (RFC 7231) & OWASP Error Handling.
class HttpErrorInterceptor extends Interceptor {
  final String Function() traceIdGenerator;

  HttpErrorInterceptor({
    this.traceIdGenerator = _defaultTraceIdGenerator,
  });

  static String _defaultTraceIdGenerator() {
    return 'trace_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final statusCode = response?.statusCode ?? -1;
    final uri = err.requestOptions.uri.toString();
    final traceId = traceIdGenerator();

    InterceptionStatus status = InterceptionStatus.complete;

    if (statusCode == 422) {
      // RFC 7231 / OWASP: Do not leak internal state. Provide safe message.
      final safeMessage = _extractSafeMessage(response, 'Validation failed. Please check your input.');
      
      MockBigQueryTelemetrySink.record(
        InterceptionTelemetryEvent(
          traceId: traceId,
          eventDate: DateTime.now(),
          statusCode: 422,
          uri: uri,
          status: status,
        ),
      );

      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: HttpUnprocessableEntityException(safeMessage, response),
        ),
      );
    }

    if (statusCode == 500) {
      // RFC 7231 / OWASP: Generic error message for 500 to prevent information disclosure.
      final safeMessage = 'An internal server error occurred. Please try again later.';
      
      MockBigQueryTelemetrySink.record(
        InterceptionTelemetryEvent(
          traceId: traceId,
          eventDate: DateTime.now(),
          statusCode: 500,
          uri: uri,
          status: status,
        ),
      );

      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: HttpInternalServerErrorException(safeMessage, response),
        ),
      );
    }

    // For other errors, record as partial coverage if applicable
    status = InterceptionStatus.partial;
    MockBigQueryTelemetrySink.record(
      InterceptionTelemetryEvent(
        traceId: traceId,
        eventDate: DateTime.now(),
        statusCode: statusCode,
        uri: uri,
        status: status,
      ),
    );

    return handler.next(err);
  }

  String _extractSafeMessage(Response? response, String fallback) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      // Only extract known safe fields per OWASP guidelines
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }
}

/// Factory to configure a Dio instance with the required interceptors.
class NetworkClientFactory {
  /// Returns a fully configured Dio instance with HTTP 422/500 interception.
  static Dio createConfiguredDio({
    String baseUrl = 'https://api.habot.local/v1',
    Duration connectTimeout = const Duration(milliseconds: 100),
    Duration receiveTimeout = const Duration(milliseconds: 100),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Attach the dynamic error interceptor
    dio.interceptors.add(HttpErrorInterceptor());

    // Optional: Log interceptor for debugging (remove in production if strict OWASP compliance requires it)
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }
}

// --- MOCK DATA FOR LOCAL VALIDATION ---

/// Mock repository to simulate API calls triggering 422 and 500 errors.
class MockApiRepository {
  final Dio _dio;

  MockApiRepository(this._dio);

  Future<Response> triggerMock422Error() async {
    // Simulating a 422 response via mock adapter or direct throw
    throw DioException(
      requestOptions: RequestOptions(path: '/mock/validate'),
      response: Response(
        requestOptions: RequestOptions(path: '/mock/validate'),
        statusCode: 422,
        data: {'message': 'Invalid payload structure.'},
      ),
      type: DioExceptionType.badResponse,
    );
  }

  Future<Response> triggerMock500Error() async {
    throw DioException(
      requestOptions: RequestOptions(path: '/mock/process'),
      response: Response(
        requestOptions: RequestOptions(path: '/mock/process'),
        statusCode: 500,
        data: {'error': 'Internal DB timeout'},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
