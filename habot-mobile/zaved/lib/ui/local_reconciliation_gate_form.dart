// ============================================================================
// TELEMETRY METADATA BLOCK
// Step Execution ID: IS07-FIEVR-012-AS01-EXEC-9021
// Execution Status: SUCCESS
// Execution Timestamp: 2026-08-19T11:24:40+05:30
// Step Outcome: PASS - Local Reconciliation Gate Verified
// User ID: USR-IS07-RECON-GATE
// Completion Status: Target: Complete - Fail-Closed Lock & Math Validator Verified
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

/// IS07-FIEVR-012-AS01: Local Reconciliation Gate Form
///
/// Features on-blur focus listeners, mathematical balance validator (Credits - Debits == 0),
/// Fail-Closed lock on null/empty inputs, 2-minute unresolved variance timeout highlighting,
/// and success checkmark indicators when reconciled.
class LocalReconciliationGateForm extends StatefulWidget {
  const LocalReconciliationGateForm({super.key});

  @override
  State<LocalReconciliationGateForm> createState() =>
      _LocalReconciliationGateFormState();
}

class _LocalReconciliationGateFormState
    extends State<LocalReconciliationGateForm> {
  final TextEditingController _creditsController = TextEditingController(text: "1000.00");
  final TextEditingController _debitsController = TextEditingController(text: "1000.00");

  final FocusNode _creditsFocusNode = FocusNode();
  final FocusNode _debitsFocusNode = FocusNode();

  bool _isCreditsBlurred = false;
  bool _isDebitsBlurred = false;

  Timer? _mismatchTimer;
  bool _isTimeoutHighlightActive = false;
  int _secondsRemaining = 120; // 2 minute timeout threshold
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // On-Blur Verification Triggers
    _creditsFocusNode.addListener(() {
      if (!_creditsFocusNode.hasFocus) {
        setState(() {
          _isCreditsBlurred = true;
        });
        _verifyReconciliation();
      }
    });

    _debitsFocusNode.addListener(() {
      if (!_debitsFocusNode.hasFocus) {
        setState(() {
          _isDebitsBlurred = true;
        });
        _verifyReconciliation();
      }
    });
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    _countdownTimer?.cancel();
    _creditsFocusNode.dispose();
    _debitsFocusNode.dispose();
    _creditsController.dispose();
    _debitsController.dispose();
    super.dispose();
  }

  double? get _parsedCredits => double.tryParse(_creditsController.text.trim());
  double? get _parsedDebits => double.tryParse(_debitsController.text.trim());

  double get _variance {
    final c = _parsedCredits ?? 0.0;
    final d = _parsedDebits ?? 0.0;
    return (c - d).abs();
  }

  bool get _isReconciled {
    if (_parsedCredits == null || _parsedDebits == null) return false;
    if (_creditsController.text.trim().isEmpty || _debitsController.text.trim().isEmpty) {
      return false; // Fail-Closed state
    }
    return (_parsedCredits! - _parsedDebits!).abs() < 0.001;
  }

  void _verifyReconciliation() {
    if (!_isReconciled) {
      _startMismatchTimeout();
    } else {
      _cancelMismatchTimeout();
    }
  }

  void _startMismatchTimeout() {
    if (_mismatchTimer == null || !_mismatchTimer!.isActive) {
      _secondsRemaining = 120;
      _isTimeoutHighlightActive = false;

      _mismatchTimer = Timer(const Duration(minutes: 2), () {
        if (mounted) {
          setState(() {
            _isTimeoutHighlightActive = true;
          });
        }
      });

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsRemaining > 0) {
          if (mounted) {
            setState(() {
              _secondsRemaining--;
            });
          }
        } else {
          t.cancel();
        }
      });
    }
  }

  void _cancelMismatchTimeout() {
    _mismatchTimer?.cancel();
    _countdownTimer?.cancel();
    if (_isTimeoutHighlightActive) {
      setState(() {
        _isTimeoutHighlightActive = false;
        _secondsRemaining = 120;
      });
    }
  }

  void _triggerInstantTimeoutDemo() {
    setState(() {
      _isTimeoutHighlightActive = true;
      _secondsRemaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isReconciled = _isReconciled;
    final varianceValue = _variance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Reconciliation Gate (IS07)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: "Simulate 2-Min Timeout Highlight",
            onPressed: _triggerInstantTimeoutDemo,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= 600;

                Widget formCard = AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    // 2-Minute Timeout Highlight: Flashes background color when unresolved
                    color: _isTimeoutHighlightActive
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: _isTimeoutHighlightActive
                          ? colorScheme.error
                          : colorScheme.outlineVariant,
                      width: _isTimeoutHighlightActive ? 2.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Summary Checkmark Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Ledger Reconciliation Gate",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isTimeoutHighlightActive
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // Success Checkmarks: Displayed when reconciled perfectly
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isReconciled
                                  ? colorScheme.primaryContainer
                                  : colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isReconciled
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 16,
                                  color: isReconciled
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isReconciled
                                      ? "RECONCILED ✓"
                                      : "VARIANCE: \$${varianceValue.toStringAsFixed(2)}",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isReconciled
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Unresolved Timeout Alert Notice
                      if (_isTimeoutHighlightActive) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.onError,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "2-MINUTE TIMEOUT EXCEEDED: Ledger variance unresolved! Correct lines immediately.",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Field 1: Total Credits
                      TextFormField(
                        controller: _creditsController,
                        focusNode: _creditsFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) {
                          _verifyReconciliation();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: "Total Credits (\$)",
                          prefixIcon: const Icon(Icons.add_circle_outline),
                          border: const OutlineInputBorder(),
                          errorText: (_isCreditsBlurred && _parsedCredits == null)
                              ? "Fail-Closed: Valid numeric credit required."
                              : null,
                          helperText: "Loses focus trigger: Verifies balance",
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Field 2: Total Debits
                      TextFormField(
                        controller: _debitsController,
                        focusNode: _debitsFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) {
                          _verifyReconciliation();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: "Total Debits (\$)",
                          prefixIcon: const Icon(Icons.remove_circle_outline),
                          border: const OutlineInputBorder(),
                          errorText: (_isDebitsBlurred && _parsedDebits == null)
                              ? "Fail-Closed: Valid numeric debit required."
                              : null,
                          helperText: "Loses focus trigger: Verifies balance",
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Mathematical Validator & Fail-Closed Lock (Poka-Yoke): onPressed set to null if non-zero variance or null inputs
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: FilledButton.icon(
                          // Locked (null) if calculations produce non-zero balances or empty fields
                          onPressed: isReconciled
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Reconciliation approved & posted to ledger!",
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: Icon(
                            isReconciled ? Icons.lock_open : Icons.lock,
                          ),
                          label: Text(
                            isReconciled
                              ? "Post Reconciled Entry"
                              : "Locked (Variance: \$${varianceValue.toStringAsFixed(2)})",
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (!isMobile) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: formCard,
                  );
                }

                return formCard;
              },
            ),
          ),
        ),
      ),
    );
  }
}
