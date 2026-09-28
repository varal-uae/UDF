// GEN-03673 — Edge-level TRN (Tax Registration Number) input masking and validation gates.
// Implements FTA-compliant 15-digit TRN input formatter, validation logic, M3 UI components with status chips, and mock telemetry streaming.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// FTA TRN Validation Format: 15 numeric digits.
class TrnInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered.length > 15) {
      return oldValue;
    }
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

enum TrnValidationStatus { empty, invalid, valid }

class TrnValidationGate {
  static const int requiredLength = 15;

  static TrnValidationStatus validate(String trn) {
    if (trn.isEmpty) return TrnValidationStatus.empty;
    final isNumeric = RegExp(r'^[0-9]{15}$').hasMatch(trn);
    return isNumeric ? TrnValidationStatus.valid : TrnValidationStatus.invalid;
  }

  static String getErrorMessage(TrnValidationStatus status) {
    switch (status) {
      case TrnValidationStatus.empty:
        return 'TRN is required.';
      case TrnValidationStatus.invalid:
        return 'Invalid TRN. Must be exactly 15 numeric digits per FTA spec.';
      case TrnValidationStatus.valid:
        return '';
    }
  }
}

class MockTrnTelemetryService {
  static void streamEvent({
    required String trn,
    required TrnValidationStatus status,
    required String sessionId,
  }) {
    // Simulates streaming to BigQuery partitioned by event_date, clustered by trace_id.
    final payload = {
      'event_date': DateTime.now().toIso8601String().split('T').first,
      'trace_id': sessionId,
      'metric_name': 'TRN Edge Intercept Efficiency',
      'floor_boundary': 1.0,
      'optimal_target': 1.0,
      'ceiling_boundary': 1.0,
      'qualitative_output': status == TrnValidationStatus.valid ? 'Pass' : 'Fail',
      'user_session_id': sessionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    debugPrint('[GEN-03673 Telemetry]: $payload');
  }
}

class TrnInputMaskScreen extends StatefulWidget {
  const TrnInputMaskScreen({super.key});

  @override
  State<TrnInputMaskScreen> createState() => _TrnInputMaskScreenState();
}

class _TrnInputMaskScreenState extends State<TrnInputMaskScreen> {
  final TextEditingController _controller = TextEditingController();
  final String _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
  TrnValidationStatus _status = TrnValidationStatus.empty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _status = TrnValidationGate.validate(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_status) {
      case TrnValidationStatus.valid:
        return colorScheme.primary;
      case TrnValidationStatus.invalid:
        return colorScheme.error;
      case TrnValidationStatus.empty:
        return colorScheme.outline;
    }
  }

  String _getStatusLabel() {
    switch (_status) {
      case TrnValidationStatus.valid:
        return 'Valid';
      case TrnValidationStatus.invalid:
        return 'Invalid';
      case TrnValidationStatus.empty:
        return 'Pending';
    }
  }

  void _submit() {
    MockTrnTelemetryService.streamEvent(
      trn: _controller.text,
      status: _status,
      sessionId: _sessionId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _status == TrnValidationStatus.valid
              ? 'TRN validated successfully. Event streamed.'
              : TrnValidationGate.getErrorMessage(_status),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _status == TrnValidationStatus.valid
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRN Validation Gate'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 64.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // M3 Elevated Card Level 2 (3dp)
                    Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Edge-Level TRN Input',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // M3 Status Chip
                                Chip(
                                  label: Text(
                                    _getStatusLabel(),
                                    style: TextStyle(
                                      color: _getStatusColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: _getStatusColor(context).withOpacity(0.12),
                                  side: BorderSide.none,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                TrnInputFormatter(),
                                LengthLimitingTextInputFormatter(15),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Tax Registration Number (TRN)',
                                hintText: 'Enter 15-digit TRN',
                                border: const OutlineInputBorder(),
                                errorText: _status == TrnValidationStatus.invalid
                                    ? TrnValidationGate.getErrorMessage(_status)
                                    : null,
                                suffixIcon: _status == TrnValidationStatus.valid
                                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            SizedBox(
                              height: 48.0, // 48x48dp touch target
                              child: FilledButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.send_rounded),
                                label: const Text('Validate & Stream Event'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Read-only M3 KPI Card
                    Card(
                      elevation: 1.0,
                      color: colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metric Config: TRN Edge Intercept Efficiency',
                              style: textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text('Floor Threshold: 1.0', style: textTheme.bodyMedium),
                            Text('Reference Standard: FTA TRN Validation Format', style: textTheme.bodyMedium),
                            Text('Output Field: Pass/Fail', style: textTheme.bodyMedium),
                            Text('Session ID: $_sessionId', style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}