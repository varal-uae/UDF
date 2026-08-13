import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'token_store.dart';

// GEN-04467 — Token Refresh Interceptor.
// Handles 401 Unauthorized responses by:
//   1. Pausing all in-flight requests
//   2. Silently refreshing the access token via refresh token
//   3. Retrying all queued requests with the new token
//   4. Redirecting to login if refresh fails
//
// Spec: Authentication Success Rate floor = 0.95 (NIST SP 800-63B)
// Poka-Yoke: only ONE refresh call fires even if multiple 401s arrive simultaneously.

typedef OnSessionExpired  = void Function();
typedef OnTokenRefreshed  = void Function(String newAccessToken);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.onSessionExpired,
    this.onTokenRefreshed,
    // ⏳ Replace with real endpoint when backend provides it
    this.refreshEndpoint = 'https://api.habot.com/auth/refresh',
  });

  final Dio dio;
  final OnSessionExpired onSessionExpired;
  final OnTokenRefreshed? onTokenRefreshed;
  final String refreshEndpoint;

  bool _isRefreshing = false;

  // Queue of completers for requests waiting on a token refresh
  final List<Completer<String>> _waitQueue = [];

  // ── Request — attach Bearer token ────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isRefreshPath(options.path)) return handler.next(options);

    // Proactive refresh if token is expired/near-expiry
    if (await TokenStore.instance.isAccessTokenExpired) {
      final newToken = await _getRefreshedToken();
      if (newToken == null) {
        onSessionExpired();
        return handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          message: 'Session expired',
        ));
      }
      options.headers['Authorization'] = 'Bearer $newToken';
      return handler.next(options);
    }

    final token = await TokenStore.instance.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  // ── Response error — handle 401 ──────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    // Prevent refresh loop
    if (_isRefreshPath(err.requestOptions.path)) {
      await TokenStore.instance.clear();
      onSessionExpired();
      return handler.next(err);
    }

    try {
      final newToken = await _getRefreshedToken();
      if (newToken == null) {
        await TokenStore.instance.clear();
        onSessionExpired();
        return handler.next(err);
      }

      // Retry original request with new token
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }

  // ── Refresh coordination — only one call fires at a time ─────────────────

  Future<String?> _getRefreshedToken() async {
    if (_isRefreshing) {
      // Queue this request — wait for the active refresh to complete
      final completer = Completer<String>();
      _waitQueue.add(completer);
      try {
        return await completer.future;
      } catch (_) {
        return null;
      }
    }

    _isRefreshing = true;
    try {
      final newToken = await _callRefreshEndpoint();
      if (newToken != null) {
        // Unblock all waiting requests with the new token
        for (final c in _waitQueue) c.complete(newToken);
        onTokenRefreshed?.call(newToken);
      } else {
        for (final c in _waitQueue) c.completeError('Refresh failed');
      }
      return newToken;
    } finally {
      _waitQueue.clear();
      _isRefreshing = false;
    }
  }

  // ── Actual refresh HTTP call ──────────────────────────────────────────────

  Future<String?> _callRefreshEndpoint() async {
    try {
      final refreshToken = await TokenStore.instance.refreshToken;
      if (refreshToken == null) return null;

      // ⏳ Stub — adjust field names when backend confirms response schema
      final response = await Dio().post<Map<String, dynamic>>(
        refreshEndpoint,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final newAccess  = data['access_token']  as String?;
        final newRefresh = data['refresh_token'] as String?;
        final expiresIn  = data['expires_in']    as int? ?? 3600;

        if (newAccess == null || newRefresh == null) return null;

        await TokenStore.instance.saveTokens(
          accessToken:  newAccess,
          refreshToken: newRefresh,
          expiry: DateTime.now().add(Duration(seconds: expiresIn)),
        );

        return newAccess;
      }

      return null;
    } catch (e) {
      debugPrint('[AuthInterceptor] Token refresh error: $e');
      return null;
    }
  }

  bool _isRefreshPath(String path) => path.contains('/auth/refresh');
}
