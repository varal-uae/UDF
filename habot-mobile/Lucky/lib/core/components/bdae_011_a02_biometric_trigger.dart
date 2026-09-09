// BDAE-011-A02 — Biometric Authentication Trigger with WebAuthn availability check.
// Reusable Material 3 widget that surfaces a fingerprint/face unlock action, handles device capability detection, and maps touch feedback to ripple.
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// A standardized biometric authentication trigger aligned with MD3 guidelines.
/// Checks WebAuthn/local biometric availability before enabling the action.
class BDAE011A02BiometricTrigger extends StatefulWidget {
  const BDAE011A02BiometricTrigger({
    super.key,
    required this.onAuthenticated,
    this.onUnavailable,
    this.onError,
  });

  final VoidCallback onAuthenticated;
  final ValueChanged<String>? onUnavailable;
  final ValueChanged<String>? onError;

  @override
  State<BDAE011A02BiometricTrigger> createState() =>
      _BDAE011A02BiometricTriggerState();
}

class _BDAE011A02BiometricTriggerState
    extends State<BDAE011A02BiometricTrigger> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAvailable = false;
  bool _isAuthenticating = false;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];

  IconData get _biometricIcon {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    }
    return Icons.fingerprint;
  }

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    bool available = false;
    List<BiometricType> biometrics = [];
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      available = canCheck || isSupported;
      if (available) {
        biometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (_) {
      available = false;
      biometrics = [];
    }
    if (!mounted) return;
    setState(() {
      _isAvailable = available;
      _availableBiometrics = biometrics;
    });
    if (!available) {
      widget.onUnavailable
          ?.call('Biometric authentication is not supported on this device.');
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !_isAvailable) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (authenticated) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Authentication cancelled. Please try again.';
        });
        widget.onError?.call(_errorMessage!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Biometric read failed. Please ensure your enrolled fingerprint or face is clean and try again.';
      });
      widget.onError?.call(_errorMessage!);
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Biometric authentication',
      enabled: _isAvailable && !_isAuthenticating,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: colorScheme.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _isAvailable && !_isAuthenticating ? _authenticate : null,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isAuthenticating
                    ? SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        _biometricIcon,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAuthenticating
                ? 'Authenticating…'
                : 'Unlock with biometrics',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
