// REF-031-A08 — Automated client-side token lifecycle monitor and full-screen session lockout container.
// Binds session lock status to a Material 3 overlay, clears decrypted data from active view references upon expiration, and provides a PIN entry prompt centered above the soft keyboard.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Atomic-level data fields for session lock state.
class SessionLockData {
  final String lockType;
  final bool lockStatus;
  final String lockedBy;
  final DateTime? lockTimestamp;
  final String? lockReason;

  const SessionLockData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    this.lockTimestamp,
    this.lockReason,
  });

  factory SessionLockData.unlocked() => const SessionLockData(
        lockType: 'NONE',
        lockStatus: false,
        lockedBy: 'SYSTEM',
      );

  SessionLockData copyWith({
    String? lockType,
    bool? lockStatus,
    String? lockedBy,
    DateTime? lockTimestamp,
    String? lockReason,
  }) {
    return SessionLockData(
      lockType: lockType ?? this.lockType,
      lockStatus: lockStatus ?? this.lockStatus,
      lockedBy: lockedBy ?? this.lockedBy,
      lockTimestamp: lockTimestamp ?? this.lockTimestamp,
      lockReason: lockReason ?? this.lockReason,
    );
  }
}

/// Mock telemetry logger simulating GCP / BigQuery alignment streaming.
class _MockTelemetryLogger {
  static void logEvent(String eventName, Map<String, dynamic> params) {
    debugPrint('[TELEMETRY] $eventName: $params');
  }
}

/// Centralized security token provider structure wrapping the primary application frame.
class SessionLockoutMonitor extends StatefulWidget {
  final Widget child;
  final Duration tokenLifetime;
  final String validPin;

  const SessionLockoutMonitor({
    super.key,
    required this.child,
    this.tokenLifetime = const Duration(minutes: 5),
    this.validPin = '1234',
  });

  static SessionLockoutMonitorState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SessionLockoutMonitorState>();
    assert(state != null, 'SessionLockoutMonitor not found in widget tree.');
    return state!;
  }

  @override
  State<SessionLockoutMonitor> createState() => SessionLockoutMonitorState();
}

class SessionLockoutMonitorState extends State<SessionLockoutMonitor>
    with WidgetsBindingObserver {
  Timer? _expiryTimer;
  SessionLockData _lockData = SessionLockData.unlocked();
  bool _isLocked = false;

  // Active view references holding decrypted data models (Poka-Yoke clearing target)
  final List<VoidCallback> _decryptedDataClearCallbacks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTokenLifecycleMonitor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _triggerLock(reason: 'APP_BACKGROUND_STATE');
    } else if (state == AppLifecycleState.resumed && !_isLocked) {
      _resetTokenLifecycleMonitor();
    }
  }

  void registerDataClearCallback(VoidCallback callback) {
    _decryptedDataClearCallbacks.add(callback);
  }

  void unregisterDataClearCallback(VoidCallback callback) {
    _decryptedDataClearCallbacks.remove(callback);
  }

  void _startTokenLifecycleMonitor() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(widget.tokenLifetime, () {
      _triggerLock(reason: 'TOKEN_EXPIRED');
    });
  }

  void _resetTokenLifecycleMonitor() {
    _startTokenLifecycleMonitor();
  }

  /// Artificially setting an expired token signature instantly triggers the security lockout overlay layer.
  void forceExpireToken() {
    _triggerLock(reason: 'MANUAL_FORCE_EXPIRE');
  }

  void _triggerLock({required String reason}) {
    if (_isLocked) return;

    setState(() {
      _isLocked = true;
      _lockData = _lockData.copyWith(
        lockType: 'SESSION_TIMEOUT',
        lockStatus: true,
        lockedBy: 'SYSTEM_MONITOR',
        lockTimestamp: DateTime.now(),
        lockReason: reason,
      );
    });

    // Poka-Yoke: Clear all decrypted data models out of active view references upon expiration
    for (final clearCb in _decryptedDataClearCallbacks) {
      clearCb();
    }
    _decryptedDataClearCallbacks.clear();

    _MockTelemetryLogger.logEvent('session_locked', {
      'lock_reason': reason,
      'timestamp': _lockData.lockTimestamp?.toIso8601String(),
    });
  }

  void _unlockSession() {
    setState(() {
      _isLocked = false;
      _lockData = SessionLockData.unlocked();
    });
    _resetTokenLifecycleMonitor();

    _MockTelemetryLogger.logEvent('session_unlocked', {
      'status': 'Pass',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Primary application frame wrapped within centralized security token provider
        widget.child,

        // Full-screen session lockout container bound to lock status visibility
        if (_isLocked)
          Positioned.fill(
            child: _SessionLockoutOverlay(
              lockData: _lockData,
              onUnlockSuccess: _unlockSession,
              validPin: widget.validPin,
            ),
          ),
      ],
    );
  }
}

class _SessionLockoutOverlay extends StatefulWidget {
  final SessionLockData lockData;
  final VoidCallback onUnlockSuccess;
  final String validPin;

  const _SessionLockoutOverlay({
    required this.lockData,
    required this.onUnlockSuccess,
    required this.validPin,
  });

  @override
  State<_SessionLockoutOverlay> createState() => _SessionLockoutOverlayState();
}

class _SessionLockoutOverlayState extends State<_SessionLockoutOverlay> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Prevent back button navigation while locked
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _verifyPin() {
    if (_pinController.text == widget.validPin) {
      widget.onUnlockSuccess();
    } else {
      setState(() {
        _errorMessage = 'Invalid PIN. Try again.';
        _pinController.clear();
      });
      _MockTelemetryLogger.logEvent('auth_failure', {
        'reason': 'INVALID_PIN',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95), // Opaque safety layer
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              // Keyboard avoiding behavior integrated natively via SingleChildScrollView + Center
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Session Locked',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your PIN to resume securely.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Credential entry field centered cleanly above soft keyboard view limits
                    TextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(
                        fontSize: 32,
                        letterSpacing: isMobile ? 16.0 : 24.0, // Dynamic character spacing
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '• • • •', // Clear format placeholder markers
                        hintStyle: TextStyle(
                          color: Colors.white24,
                          letterSpacing: 16.0,
                          fontSize: 32,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 3.0, // High-contrast text focus borders
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        errorText: _errorMessage,
                        errorStyle: const TextStyle(color: Colors.redAccent),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      onSubmitted: (_) => _verifyPin(),
                    ),
                    const SizedBox(height: 32),

                    // Adaptive numeric keypad auto-triggering handled by TextInputType.number
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _verifyPin,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          textStyle: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Unlock'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.lockData.lockReason != null)
                      Text(
                        'Lock Reason: ${widget.lockData.lockReason}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example Usage Wrapper demonstrating how to wrap the primary application frame.
class SecureApplicationShell extends StatelessWidget {
  final Widget appContent;

  const SecureApplicationShell({super.key, required this.appContent});

  @override
  Widget build(BuildContext context) {
    return SessionLockoutMonitor(
      tokenLifetime: const Duration(seconds: 30), // Shortened for testing/completion measures
      validPin: '1234',
      child: appContent,
    );
  }
}