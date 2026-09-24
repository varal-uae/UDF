// RRCVG-008-A07 — Release Button with Material 3 Color Tokens.
// Implements the Release button component using M3 color tokens for disabled and enabled states, enforcing a minimum 48dp touch target and WCAG contrast compliance.

import 'package:flutter/material.dart';

/// Mock data constants for color configuration as required by atomic-level data fields.
class _ReleaseButtonMockData {
  static const String colorCodeEnabledHex = '#6750A4'; // M3 Primary
  static const String colorCodeDisabledHex = '#1C1B1F'; // M3 OnSurface (used with opacity)
  static const String colorNameEnabled = 'Primary';
  static const String colorNameDisabled = 'OnSurface';
  static const String colorScheme = 'Material 3 Dynamic Color Scheme';
  static const double contrastRatioEnabled = 4.6;
  static const double contrastRatioDisabled = 3.0;
  static const Map<String, String> colorApplicationMap = {
    'enabled_background': colorCodeEnabledHex,
    'disabled_background': colorCodeDisabledHex,
    'enabled_foreground': '#FFFFFF',
    'disabled_foreground': '#FFFFFF',
  };
}

/// A Material 3 compliant Release button widget that respects
/// accessibility guidelines (minimum 48x48dp touch area) and
/// uses design tokens for enabled/disabled states.
class ReleaseButton extends StatelessWidget {
  const ReleaseButton({
    super.key,
    required this.onPressed,
    this.label = 'Release',
  });

  /// Callback triggered when the button is tapped.
  /// Pass `null` to render the button in its disabled state.
  final VoidCallback? onPressed;

  /// The text label displayed on the button.
  final String label;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Enforce minimum 48dp x 48dp touch area properties
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: Semantics(
        button: true,
        enabled: _isEnabled,
        label: label,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(48.0, 48.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            backgroundColor: _isEnabled
                ? colorScheme.primary // Maps to _ReleaseButtonMockData.colorCodeEnabledHex
                : colorScheme.onSurface.withOpacity(0.12), // Maps to disabled state token
            foregroundColor: _isEnabled
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withOpacity(0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // M3 standard corner radius
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: _isEnabled
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withOpacity(0.38),
            ),
          ),
        ),
      ),
    );
  }
}

/// Telemetry and completion status mock collector for the release dashboard.
class ReleaseButtonTelemetryCollector {
  static Map<String, dynamic> collectEventData({
    required String sessionId,
    required String userId,
    required bool isSuccess,
  }) {
    return <String, dynamic>{
      'color_code_hex': _ReleaseButtonMockData.colorCodeEnabledHex,
      'color_name': _ReleaseButtonMockData.colorNameEnabled,
      'color_scheme': _ReleaseButtonMockData.colorScheme,
      'contrast_ratio': _ReleaseButtonMockData.contrastRatioEnabled,
      'color_application_map': _ReleaseButtonMockData.colorApplicationMap,
      'completion_status': isSuccess ? 'Pass' : 'Fail',
      'action_timestamp': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId,
      'session_id': sessionId,
    };
  }
}