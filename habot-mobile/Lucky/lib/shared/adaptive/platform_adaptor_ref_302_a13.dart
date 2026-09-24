// REF-302-A13 — Cross-Platform Mobile Device Adaptation Layer.
// Provides OS detection, platform-specific layout adjustments (status bar heights, grid spacing), and native input type resolution for Material 3 compliance.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enum representing the detected operating system.
enum PlatformOS { android, ios, unknown }

/// Utility class for cross-platform device adaptation.
class PlatformAdaptor {
  PlatformAdaptor._();

  /// Detects the current operating system.
  static PlatformOS get currentOS {
    if (kIsWeb) return PlatformOS.unknown;
    if (Platform.isAndroid) return PlatformOS.android;
    if (Platform.isIOS) return PlatformOS.ios;
    return PlatformOS.unknown;
  }

  /// Returns true if the current platform is Android.
  static bool get isAndroid => currentOS == PlatformOS.android;

  /// Returns true if the current platform is iOS.
  static bool get isIOS => currentOS == PlatformOS.ios;

  /// Adapts dashboard grid spacing to account for varied system status bar heights.
  static double gridSpacing(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    // Base spacing adjusted by status bar influence
    final baseSpacing = 16.0;
    if (isIOS) {
      return baseSpacing + (statusBarHeight > 40 ? 8.0 : 0.0);
    }
    return baseSpacing;
  }

  /// Resolves the appropriate [TextInputType] based on platform best practices
  /// for touch-friendly numerical entry.
  static TextInputType numericInputType() {
    if (isIOS) {
      return const TextInputType.numberWithOptions(decimal: false, signed: false);
    }
    return TextInputType.number;
  }

  /// Adapts typography to match system font behaviors across platforms.
  static TextTheme adaptTextTheme(TextTheme baseTheme) {
    if (isIOS) {
      return baseTheme.apply(
        fontFamily: '.SF Pro Display',
      );
    }
    return baseTheme.apply(
      fontFamily: 'Roboto',
    );
  }

  /// Returns platform-specific visual feedback duration for invalid key presses.
  static Duration get invalidFeedbackDuration {
    return isIOS ? const Duration(milliseconds: 400) : const Duration(milliseconds: 300);
  }
}

/// A wrapper widget that applies platform-specific adaptations dynamically.
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adaptedTheme = theme.copyWith(
      textTheme: PlatformAdaptor.adaptTextTheme(theme.textTheme),
    );

    return Theme(
      data: adaptedTheme,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(PlatformAdaptor.gridSpacing(context)),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Material 3 TextField with predefined keyboardType and platform-native behavior.
class AdaptiveNumericField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onInvalidKey;

  const AdaptiveNumericField({
    super.key,
    this.controller,
    required this.label,
    this.onChanged,
    this.onInvalidKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: PlatformAdaptor.numericInputType(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      onChanged: (value) {
        // Basic validation: trigger visual feedback if non-numeric characters slip through
        if (value.isNotEmpty && double.tryParse(value) == null && !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
          onInvalidKey?.call();
        }
        onChanged?.call(value);
      },
    );
  }
}

/// Mock telemetry data collector for unit testing adaptation utilities.
class MockAdaptationTelemetry {
  static final List<Map<String, dynamic>> testLogs = [];

  static void logTest({
    required String testType,
    required bool testResult,
    required double testCoverage,
  }) {
    testLogs.add({
      'testType': testType,
      'testResult': testResult ? 'Pass' : 'Fail',
      'testCoverage': testCoverage,
      'testTimestamp': DateTime.now().toIso8601String(),
      'testLogPath': '/mock/logs/adaptation_${DateTime.now().millisecondsSinceEpoch}.log',
      'completionStatus': testResult ? 'Pass' : 'Fail',
      'sessionId': 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  static void clearLogs() => testLogs.clear();
}