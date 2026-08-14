import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/layout/screen_size_provider.dart';
import '../../shared/layout/size_class.dart';
import '../network/token_store.dart';
import 'high_risk_action.dart';
import 'step_up_verifier.dart';

// BDAE-008-A01 — StepUpMFAPrompt.
// Inline secondary security validation for critical actions.
//
// Mobile  (<600dp): bottom sheet, split digit boxes, thumb-reach layout
// Desktop (≥600dp): centered modal, paste-whole-code support
//
// Spec: high-risk actions stay locked until valid TOTP or biometric approval.

abstract class StepUpMFAPrompt {
  /// Shows verification UI. Returns [StepUpApprovalToken] on success, null if cancelled.
  static Future<StepUpApprovalToken?> show(
    BuildContext context, {
    required HighRiskAction action,
    VoidCallback? onSessionExpired,
  }) {
    final sizeClass = ScreenSizeProvider.of(context);
    final useModal = !sizeClass.isCompact;

    return showGeneralDialog<StepUpApprovalToken>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Security verification',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return SafeArea(
          child: useModal
              ? Center(
                  child: _StepUpPromptBody(
                    action: action,
                    usePasteField: true,
                    onSessionExpired: onSessionExpired,
                  ),
                )
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: _StepUpPromptBody(
                    action: action,
                    usePasteField: false,
                    onSessionExpired: onSessionExpired,
                  ),
                ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final offset = useModal
            ? Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            : Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);
        return SlideTransition(
          position: offset.animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}

class _StepUpPromptBody extends StatefulWidget {
  const _StepUpPromptBody({
    required this.action,
    required this.usePasteField,
    this.onSessionExpired,
  });

  final HighRiskAction action;
  final bool usePasteField;
  final VoidCallback? onSessionExpired;

  @override
  State<_StepUpPromptBody> createState() => _StepUpPromptBodyState();
}

class _StepUpPromptBodyState extends State<_StepUpPromptBody> {
  final _verifier = StepUpVerifier.instance;
  final _digitFields = List.generate(6, (_) => TextEditingController());
  final _digitFocus = List.generate(6, (_) => FocusNode());
  final _pasteController = TextEditingController();
  final _pasteFocus = FocusNode();

  String? _error;
  bool _isVerifying = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.usePasteField) {
        _pasteFocus.requestFocus();
      } else {
        _digitFocus[0].requestFocus();
      }
    });
  }

  Future<void> _loadBiometricAvailability() async {
    final available = await BiometricStepUp.isAvailable;
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  void dispose() {
    for (final c in _digitFields) {
      c.dispose();
    }
    for (final f in _digitFocus) {
      f.dispose();
    }
    _pasteController.dispose();
    _pasteFocus.dispose();
    super.dispose();
  }

  String get _code =>
      _digitFields.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isEmpty && index > 0) {
      _digitFocus[index - 1].requestFocus();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _digitFocus[index + 1].requestFocus();
    }
    if (_code.length == 6) {
      _submitTotp();
    }
  }

  void _handlePaste(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < 6; i++) {
      _digitFields[i].text = i < digits.length ? digits[i] : '';
    }

    if (digits.length >= 6) {
      _digitFocus[5].requestFocus();
      _submitTotp();
    } else {
      _digitFocus[digits.length.clamp(0, 5)].requestFocus();
    }
  }

  Future<void> _submitTotp() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final code = widget.usePasteField && _pasteController.text.isNotEmpty
        ? _pasteController.text.replaceAll(RegExp(r'[^0-9]'), '')
        : _code;

    final (result, token) = await _verifier.verifyTotp(
      code: code,
      actionKey: widget.action.actionKey,
    );

    if (!mounted) return;

    switch (result) {
      case StepUpVerifyResult.approved:
        Navigator.of(context).pop(token);
      case StepUpVerifyResult.invalidCode:
        setState(() {
          _error = 'Invalid security code. Try again.';
          _clearDigits();
          _isVerifying = false;
        });
      case StepUpVerifyResult.lockedOut:
        await _handleLockout();
      default:
        setState(() {
          _error = 'Verification failed. Please try again.';
          _isVerifying = false;
        });
    }
  }

  Future<void> _submitBiometric() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final ok = await BiometricStepUp.authenticate(
      reason: 'Verify ${widget.action.title}',
    );

    final (result, token) = await _verifier.verifyBiometric(
      actionKey: widget.action.actionKey,
      localAuthSuccess: ok,
    );

    if (!mounted) return;

    switch (result) {
      case StepUpVerifyResult.approved:
        Navigator.of(context).pop(token);
      case StepUpVerifyResult.biometricFailed:
        setState(() {
          _error = ok
              ? 'Biometric verification failed.'
              : 'Biometric unavailable — use security code.';
          _isVerifying = false;
        });
      case StepUpVerifyResult.lockedOut:
        await _handleLockout();
      default:
        setState(() {
          _error = 'Verification failed.';
          _isVerifying = false;
        });
    }
  }

  Future<void> _handleLockout() async {
    await TokenStore.instance.clear();
    widget.onSessionExpired?.call();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Too many failed attempts. Please sign in again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearDigits() {
    for (final c in _digitFields) {
      c.clear();
    }
    _pasteController.clear();
    if (!widget.usePasteField) {
      _digitFocus[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = widget.usePasteField
        ? width.clamp(320.0, 480.0)
        : width;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      borderRadius: widget.usePasteField
          ? BorderRadius.circular(16)
          : const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  widget.action.warningIcon,
                  color: theme.colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify identity',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.action.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cancel',
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  onPressed: _isVerifying
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              widget.action.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            if (_verifier.isLockedOut)
              _LockoutBanner(theme: theme)
            else if (widget.usePasteField)
              _PasteCodeField(
                controller: _pasteController,
                focusNode: _pasteFocus,
                enabled: !_isVerifying,
                onSubmitted: (_) => _submitTotp(),
              )
            else
              _OtpDigitRow(
                controllers: _digitFields,
                focusNodes: _digitFocus,
                enabled: !_isVerifying,
                onChanged: _onDigitChanged,
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isVerifying || _verifier.isLockedOut
                  ? null
                  : _submitTotp,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isVerifying
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Verify code'),
            ),

            if (_biometricAvailable) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isVerifying || _verifier.isLockedOut
                    ? null
                    : _submitBiometric,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Use Face ID / Touch ID'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],

            if (!widget.usePasteField) ...[
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code from your authenticator app',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Split digit OTP input (mobile) ────────────────────────────────────────────

class _OtpDigitRow extends StatelessWidget {
  const _OtpDigitRow({
    required this.controllers,
    required this.focusNodes,
    required this.enabled,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool enabled;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (v) => onChanged(i, v),
          ),
        );
      }),
    );
  }
}

// ── Paste field (desktop / wide) ──────────────────────────────────────────────

class _PasteCodeField extends StatelessWidget {
  const _PasteCodeField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'Security code',
        hintText: 'Paste or type 6-digit code',
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSubmitted: onSubmitted,
    );
  }
}

class _LockoutBanner extends StatelessWidget {
  const _LockoutBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Device locked due to failed attempts. Sign in again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
