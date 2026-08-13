import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

// GEN-04467 — Habot HTTP Client.
// Singleton Dio instance with AuthInterceptor pre-wired.
// All feature-layer API calls use this client — never a raw Dio instance.
//
// Spec: "Core pattern stored as a reusable module in the shared library."
// Usage:
//   final response = await HabotHttpClient.instance.get('/dashboard/records');

class HabotHttpClient {
  HabotHttpClient._();

  static Dio? _instance;

  /// Call once at app startup — before any network requests.
  static void init({
    required String baseUrl,
    required void Function() onSessionExpired,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    final dio = Dio(BaseOptions(
      baseUrl:        baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept':        'application/json',
      },
    ));

    dio.interceptors.add(
      AuthInterceptor(
        dio:              dio,
        onSessionExpired: onSessionExpired,
      ),
    );

    // Log requests in debug only — never in release (no token leaks)
    assert(() {
      dio.interceptors.add(LogInterceptor(
        requestBody:  true,
        responseBody: true,
        // Mask Authorization header value in logs
        requestHeader: false,
      ));
      return true;
    }());

    _instance = dio;
  }

  static Dio get instance {
    assert(_instance != null,
        'HabotHttpClient.init() must be called before using the client.');
    return _instance!;
  }
}
