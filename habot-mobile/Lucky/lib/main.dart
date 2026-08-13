import 'dart:async';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/error/global_error_handler.dart';
import 'core/error/error_telemetry.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorHandler.init();

  runZonedGuarded(
    () => runApp(const HabotApp()),
    (error, stack) => ErrorTelemetry.dispatch(
      error: error,
      stackTrace: stack,
      module: 'zone',
    ),
  );
}
