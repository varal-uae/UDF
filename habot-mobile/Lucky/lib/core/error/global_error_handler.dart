import 'dart:async';
import 'package:flutter/foundation.dart';
import 'error_telemetry.dart';

/// FEBFL-018-A01 — Global error handler.
/// Call [GlobalErrorHandler.init] inside [runZonedGuarded] in main()
/// to catch all uncaught Flutter framework and async errors.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void init() {
    // Catch Flutter framework / widget build errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorTelemetry.dispatch(
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
        module: 'flutter-framework',
      );
    };

    // Catch errors outside Flutter framework (e.g. platform channels)
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorTelemetry.dispatch(
        error: error,
        stackTrace: stack,
        module: 'platform-dispatcher',
      );
      return true;
    };
  }
}
