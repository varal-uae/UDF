import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'size_class.dart';

// SSELC-025-A01 — Screen size analytics dispatcher.
// Logs device dimension events to analytics dataset on every SizeClass change.
// Replace _sendToAnalytics body with actual analytics client when backend ready.

class ScreenSizeAnalytics {
  ScreenSizeAnalytics._();

  static Future<void> log({
    required double width,
    required double height,
    required SizeClass sizeClass,
    required Orientation orientation,
  }) async {
    final payload = {
      'timestamp':   DateTime.now().toUtc().toIso8601String(),
      'width':       width,
      'height':      height,
      'sizeClass':   sizeClass.name,
      'columns':     sizeClass.columns,
      'orientation': orientation.name,
      'platform':    'mobile',
      'source':      'ScreenSizeService',
    };

    developer.log(
      '[ScreenSize] ${sizeClass.name} · ${width.toStringAsFixed(0)}×${height.toStringAsFixed(0)}dp · ${orientation.name}',
      name: 'SSELC-025',
    );

    await _sendToAnalytics(payload);
  }

  /// TODO: Replace with analytics client (e.g. Firebase Analytics / BigQuery Pub/Sub).
  static Future<void> _sendToAnalytics(Map<String, dynamic> payload) async {
    // e.g.:
    // await FirebaseAnalytics.instance.logEvent(
    //   name: 'screen_size_changed',
    //   parameters: payload,
    // );
  }
}
