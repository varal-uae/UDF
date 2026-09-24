// REF-467-A10 — Biometric Verification Gate Layout Component.
// Provides absolute anchoring with safe-area inset adjustments, Material 3 error styling, and native biometric verification gating for high-security mobile layouts.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level layout configuration fields.
class LayoutConfigMock {
  static const String layoutType = 'BiometricVerificationGate';
  static const Size layoutGridDimensions = Size(375.0, 812.0);
  static const EdgeInsets spacingRules = EdgeInsets.all(16.0);
  static const Alignment alignmentSettings = Alignment.center;
  static const bool layoutValidationStatus = true;
}

/// A gate widget that wraps secure content behind a native biometric prompt simulation.
/// Respects device notches via SafeArea and uses strict 8pt grid spacing.
class BiometricVerificationGate extends StatefulWidget {
  final Widget securedContent;
  final VoidCallback? onVerificationSuccess;
  final VoidCallback? onVerificationFailed;

  const BiometricVerificationGate({
    super.key,
    required this.securedContent,
    this.onVerificationSuccess,
    this.onVerificationFailed,
  });

  @override
  State<BiometricVerificationGate> createState() => _BiometricVerificationGateState();
}

class _BiometricVerificationGateState extends State<BiometricVerificationGate> {
  bool _isVerified = false;
  bool _hasAttempted = false;
  bool _showError = false;

  // 8pt grid factorized constants
  static const double _gutter8 = 8.0;
  static const double _gutter16 = 16.0;
  static const double _gutter24 = 24.0;
  static const double _gutter32 = 32.0;

  Future<void> _triggerNativeBiometricScan() async {
    setState(() {
      _hasAttempted = true;
      _showError = false;
    });

    // Simulate native biometric scan latency (< 500ms target)
    await Future.delayed(const Duration(milliseconds: 450));

    // Mocking success/failure (90% success rate for demonstration)
    final bool mockSuccess = DateTime.now().millisecond % 10 != 0;

    if (!mounted) return;

    if (mockSuccess) {
      setState(() {
        _isVerified = true;
      });
      widget.onVerificationSuccess?.call();
    } else {
      setState(() {
        _isVerified = false;
        _showError = true;
      });
      widget.onVerificationFailed?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    // Automatically trigger scan on mount for zero typing friction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerNativeBiometricScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        // Absolute anchoring: adjust safe-area insets to respect device notches
        minimum: const EdgeInsets.symmetric(horizontal: _gutter16),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isVerified
                ? _buildSecuredLayout(theme)
                : _buildAuthenticationLayout(theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationLayout(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('auth_layout'),
      mainAxisAlignment: LayoutConfigMock.alignmentSettings.y == 0.0
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.fingerprint_rounded,
          size: _gutter8 * 12, // 96.0
          color: colorScheme.primary,
        ),
        const SizedBox(height: _gutter24),
        Text(
          'High-Security Checkpoint',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _gutter8),
        // Inline hints contextually beneath form labels
        Text(
          'A quick native biometric scan opens high-security fields cleanly.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _gutter32),
        if (_hasAttempted && !_isVerified)
          ElevatedButton.icon(
            onPressed: _triggerNativeBiometricScan,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Biometric Scan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: _gutter16),
            ),
          ),
        if (!_hasAttempted)
          const CircularProgressIndicator.adaptive(),
        const SizedBox(height: _gutter24),
        // Error alerts wrap gracefully in tight portrait columns using md.sys.color.error
        if (_showError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_gutter16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(_gutter8),
              border: Border.all(color: colorScheme.error, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                  size: _gutter24,
                ),
                const SizedBox(width: _gutter8),
                Expanded(
                  child: Text(
                    'Verification failed. Unauthorized form submissions are blocked instantly to protect sensitive field values.',
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSecuredLayout(ThemeData theme) {
    return Column(
      key: const ValueKey('secured_layout'),
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: _gutter16),
        // Focused authentication screen header built using native mobile options
        Row(
          children: [
            Icon(Icons.verified_user_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: _gutter8),
            Expanded(
              child: Text(
                'Secure Session Active',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: _gutter32),
        // The anchored layout respects device notches via parent SafeArea
        Expanded(
          child: widget.securedContent,
        ),
      ],
    );
  }
}

/// Metric validation helper for Inset Accuracy (Floor: 100, Optimal: 100, Ceiling: 100).
class InsetAccuracyValidator {
  static const String metricName = 'Inset Accuracy';
  static const int floorBoundary = 100;
  static const int optimalTarget = 100;
  static const int ceilingBoundary = 100;

  /// Returns Pass/Fail based on whether the applied safe area matches expected bounds.
  static String validate({
    required EdgeInsets actualInsets,
    required EdgeInsets expectedInsets,
  }) {
    final bool isExactMatch = actualInsets == expectedInsets;
    return isExactMatch ? 'Pass' : 'Fail';
  }
}
