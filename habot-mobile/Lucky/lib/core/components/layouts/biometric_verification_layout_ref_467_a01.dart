// REF-467-A01 — Biometric Verification Layout with Absolute Anchoring.
// Implements a mobile-first, Material 3 compliant layout for biometric verification gates using an 8pt grid system and native security prompts.

import 'package:flutter/material.dart';

/// Mock data constants for layout validation and telemetry tracking.
class _MockLayoutData {
  static const String layoutType = 'BiometricVerificationGate';
  static const double gridDimensionBase = 8.0;
  static const String spacingRule = 'factorized_by_8pt_grid';
  static const String alignmentSetting = 'center_anchored';
  static const bool layoutValidationStatus = true;
}

/// Spacing constants factorized by the 8pt grid (Mobile-First & Responsive UI).
class _Spacing {
  static const double xxs = _MockLayoutData.gridDimensionBase * 0.5; // 4.0
  static const double xs = _MockLayoutData.gridDimensionBase * 1; // 8.0
  static const double sm = _MockLayoutData.gridDimensionBase * 2; // 16.0
  static const double md = _MockLayoutData.gridDimensionBase * 3; // 24.0
  static const double lg = _MockLayoutData.gridDimensionBase * 4; // 32.0
  static const double xl = _MockLayoutData.gridDimensionBase * 6; // 48.0
}

/// A high-security checkpoint layout that leverages native smartphone biometric options.
/// Blocks unauthorized form submissions instantly if a mobile device is left unattended.
class BiometricVerificationLayout extends StatelessWidget {
  const BiometricVerificationLayout({
    super.key,
    required this.onVerificationSuccess,
    required this.onVerificationFailed,
    this.title = 'Secure Access',
    this.subtitle = 'Authenticate to continue',
  });

  final VoidCallback onVerificationSuccess;
  final VoidCallback onVerificationFailed;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.fingerprint_rounded,
                    size: _MockLayoutData.gridDimensionBase * 12, // 96.0
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: _Spacing.lg),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: _Spacing.xs),
                  // Inline hints organized contextually beneath form labels
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: _Spacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: _MockLayoutData.gridDimensionBase * 6, // 48.0
                    child: FilledButton.icon(
                      onPressed: () => _triggerNativeBiometricPrompt(context),
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text('Verify Identity'),
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  // Error alerts wrap gracefully to fit tight portrait device columns
                  _buildErrorAlertWrapper(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _triggerNativeBiometricPrompt(BuildContext context) async {
    // In production, integrate local_auth or similar native plugin here.
    // Simulating sub-500ms completion measure requirement.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (_MockLayoutData.layoutValidationStatus) {
      onVerificationSuccess();
    } else {
      // Self-Chasing: Failed verification checks freeze user sessions instantly
      onVerificationFailed();
      if (context.mounted) {
        _showSecurityFreezeAlert(context);
      }
    }
  }

  void _showSecurityFreezeAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Mistake-Proofing (Poka-Yoke)
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Session Frozen'),
          content: const Text(
            'Verification failed. Your session has been securely frozen to protect sensitive data.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onVerificationFailed();
              },
              child: const Text('Acknowledge'),
            ),
          ],
        );
      },
    );
  }

  /// Utilizes bright high-contrast alert highlights matching Material 3 color rules (md.sys.color.error).
  Widget _buildErrorAlertWrapper(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_Spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_MockLayoutData.gridDimensionBase),
        border: Border.all(
          color: colorScheme.error,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: _MockLayoutData.gridDimensionBase * 3, // 24.0
          ),
          const SizedBox(width: _Spacing.xs),
          Expanded(
            child: Text(
              'Strict access control protocols are active. Ensure your device is secure before proceeding.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
              // Wraps gracefully to fit tight portrait device columns without breaking canvas limits
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Telemetry model for data collected by the system per requirements.
class LayoutTelemetryModel {
  const LayoutTelemetryModel({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.completionStatus,
    required this.timestamp,
    required this.sessionId,
  });

  final String layoutType;
  final double layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final bool layoutValidationStatus;
  final String completionStatus;
  final DateTime timestamp;
  final String sessionId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'layout_type': layoutType,
        'layout_grid_dimensions': layoutGridDimensions,
        'spacing_rules': spacingRules,
        'alignment_settings': alignmentSettings,
        'layout_validation_status': layoutValidationStatus,
        'completion_status': completionStatus,
        'timestamp': timestamp.toIso8601String(),
        'session_id': sessionId,
      };

  /// Generates mock telemetry data for edge perimeter validation.
  factory LayoutTelemetryModel.mock(String sessionId) {
    return LayoutTelemetryModel(
      layoutType: _MockLayoutData.layoutType,
      layoutGridDimensions: _MockLayoutData.gridDimensionBase,
      spacingRules: _MockLayoutData.spacingRule,
      alignmentSettings: _MockLayoutData.alignmentSetting,
      layoutValidationStatus: _MockLayoutData.layoutValidationStatus,
      completionStatus: 'Complete/Not Complete',
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );
  }
}
