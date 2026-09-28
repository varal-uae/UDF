// SSTLA-016-A15 — Mobile Screen Orientation Locking & Numeric Date Input Constraint.
// Enforces portrait-only viewport orientation to prevent layout distortion and restricts date entry keystrokes exclusively to numeric values in valid date ranges.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hard-locks the application viewport orientation to portrait mode
/// to eliminate interaction clutter caused by accidental screen orientation shifts.
class OrientationLockSstla016A15 {
  OrientationLockSstla016A15._();

  /// Enforces portrait orientation globally.
  static Future<void> enforcePortraitOnly() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Resets orientation constraints (useful for specific video playback scenarios if needed later).
  static Future<void> resetOrientation() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}

/// A [TextInputFormatter] that strictly limits input to numeric characters
/// and enforces valid date range boundaries (e.g., DD/MM/YYYY format).
class NumericDateInputFormatterSstla016A15 extends TextInputFormatter {
  final int maxDay;
  final int maxMonth;
  final int maxYear;

  const NumericDateInputFormatterSstla016A15({
    this.maxDay = 31,
    this.maxMonth = 12,
    this.maxYear = 2100,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Restrict exclusively to numeric values
    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Validate basic date bounds as user types
    String formatted = numericOnly;
    
    if (formatted.length >= 2) {
      final dayStr = formatted.substring(0, 2);
      final day = int.tryParse(dayStr) ?? 0;
      if (day > maxDay || day < 0) {
        return oldValue;
      }
    }

    if (formatted.length >= 4) {
      final monthStr = formatted.substring(2, 4);
      final month = int.tryParse(monthStr) ?? 0;
      if (month > maxMonth || month < 1) {
        return oldValue;
      }
      formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
    } else if (formatted.length > 2) {
      formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
    }

    if (formatted.length >= 7) {
      final yearStr = formatted.substring(6).replaceAll('/', '');
      if (yearStr.length >= 4) {
        final year = int.tryParse(yearStr.substring(0, 4)) ?? 0;
        if (year > maxYear || year < 1900) {
          return oldValue;
        }
      }
      final parts = formatted.split('/');
      if (parts.length == 3 && parts[2].length > 4) {
        formatted = '${parts[0]}/${parts[1]}/${parts[2].substring(0, 4)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Mock telemetry data collection model satisfying atomic-level data requirements.
class OrientationTelemetryModelSstla016A15 {
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final Size screenDimensions;
  final Map<String, dynamic> mobileConfiguration;
  final String completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;

  const OrientationTelemetryModelSstla016A15({
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.mobileConfiguration,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
    'mobile_platform': mobilePlatform,
    'os_version': osVersion,
    'device_type': deviceType,
    'screen_dimensions': {'width': screenDimensions.width, 'height': screenDimensions.height},
    'mobile_configuration': mobileConfiguration,
    'completion_status': completionStatus,
    'action_timestamp': actionTimestamp.toIso8601String(),
    'session_id': sessionId,
  };

  /// Realistic local mock data for validation without backend dependency.
  static OrientationTelemetryModelSstla016A15 get mockData => OrientationTelemetryModelSstla016A15(
    mobilePlatform: 'Android',
    osVersion: '14.0',
    deviceType: 'Smartphone',
    screenDimensions: const Size(412.0, 915.0),
    mobileConfiguration: const {'orientation_locked': true, 'theme_mode': 'dark'},
    completionStatus: 'Yes',
    actionTimestamp: DateTime.now(),
    sessionId: 'sess_mock_udf_001',
  );
}

/// Example widget demonstrating the locked viewport and numeric date constraint.
class UdfDataEntryScreenSstla016A15 extends StatefulWidget {
  const UdfDataEntryScreenSstla016A15({super.key});

  @override
  State<UdfDataEntryScreenSstla016A15> createState() => _UdfDataEntryScreenSstla016A15State();
}

class _UdfDataEntryScreenSstla016A15State extends State<UdfDataEntryScreenSstla016A15> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    OrientationLockSstla016A15.enforcePortraitOnly();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Data Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verification Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  const NumericDateInputFormatterSstla016A15(),
                ],
                decoration: const InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(),
                  helperText: 'Numeric values only. Layout is hard-locked to portrait.',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final telemetry = OrientationTelemetryModelSstla016A15.mockData;
                  debugPrint('Telemetry Captured: ${telemetry.toJson()}');
                },
                child: const Text('Submit Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}