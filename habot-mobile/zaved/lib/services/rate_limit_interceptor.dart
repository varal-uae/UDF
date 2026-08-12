import 'dart:async';

/// Callback invoked when a 429 Rate Limit error is intercepted globally.
typedef RateLimitHandler = void Function(
  int cooldownSeconds,
  Future<void> Function() retryAction,
);

/// Custom HTTP Response representation for interceptor evaluation.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// Rate-Limit Interceptor service for catching HTTP 429 status codes globally.
class RateLimitInterceptor {
  RateLimitInterceptor({this.onRateLimitTriggered});

  /// Global listener triggered when HTTP 429 Too Many Requests is caught.
  RateLimitHandler? onRateLimitTriggered;

  /// Inspects HTTP response and catches HTTP 429 status codes globally.
  Future<ApiResponse> interceptResponse(
    ApiResponse response, {
    required Future<ApiResponse> Function() requestCall,
  }) async {
    if (response.statusCode == 429) {
      final cooldownSeconds = _parseRetryAfterHeader(response.headers);

      // Trigger global Poka-Yoke modal UI and automated retry pipeline
      if (onRateLimitTriggered != null) {
        onRateLimitTriggered!(cooldownSeconds, () async {
          // Automated retry execution after cooldown expires
          await requestCall();
        });
      }

      throw RateLimitException(
        statusCode: 429,
        cooldownSeconds: cooldownSeconds,
        message: 'HTTP 429 Too Many Requests: API Gateway rate limit exceeded.',
      );
    }

    return response;
  }

  /// Parses the `Retry-After` header from API Gateway (defaults to 5s if absent/invalid).
  int _parseRetryAfterHeader(Map<String, String> headers) {
    // Header keys can be case-insensitive in HTTP
    final retryHeaderValue = headers['retry-after'] ??
        headers['Retry-After'] ??
        headers['RETRY-AFTER'];

    if (retryHeaderValue != null) {
      final parsedSeconds = int.tryParse(retryHeaderValue.trim());
      if (parsedSeconds != null && parsedSeconds > 0) {
        return parsedSeconds;
      }
    }
    return 5; // Default fallback cooldown
  }
}

/// Custom exception thrown when rate limits are exceeded.
class RateLimitException implements Exception {
  RateLimitException({
    required this.statusCode,
    required this.cooldownSeconds,
    required this.message,
  });

  final int statusCode;
  final int cooldownSeconds;
  final String message;

  @override
  String toString() => 'RateLimitException($statusCode): $message (Retry-After: ${cooldownSeconds}s)';
}
