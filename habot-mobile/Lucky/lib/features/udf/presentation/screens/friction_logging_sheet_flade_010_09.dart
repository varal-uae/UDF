// FLADE-010-09 — Structured Friction Logging Engine (Cascading Modals).
// Implements Material 3 cascading bottom sheets for dispute and friction logging with thumb-accessible controls,
// dynamic child category population, intense pulsing alert indicators, and physical submit gating on system trace_id.

import 'package:flutter/material.dart';

/// Quality and execution metadata collected during friction logging.
class FrictionLogRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String sessionId;
  final String systemTraceId;
  final String primaryCategory;
  final String subCategory;
  final String severity;
  final String completionStatus;

  const FrictionLogRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.sessionId,
    required this.systemTraceId,
    required this.primaryCategory,
    required this.subCategory,
    required this.severity,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'session_id': sessionId,
        'system_trace_id': systemTraceId,
        'primary_category': primaryCategory,
        'sub_category': subCategory,
        'severity': severity,
        'completion_status': completionStatus,
      };
}

/// Friction Logging Modal Engine adhering to ISO 9001:2015 quality logging standards.
class FrictionLoggingSheet extends StatefulWidget {
  final String userId;
  final String sessionId;
  final String? initialTraceId;
  final ValueChanged<FrictionLogRecord>? onLogSubmitted;

  const FrictionLoggingSheet({
    super.key,
    required this.userId,
    required this.sessionId,
    this.initialTraceId,
    this.onLogSubmitted,
  });

  static Future<FrictionLogRecord?> show({
    required BuildContext context,
    required String userId,
    required String sessionId,
    String? initialTraceId,
  }) {
    return showModalBottomSheet<FrictionLogRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: FrictionLoggingSheet(
          userId: userId,
          sessionId: sessionId,
          initialTraceId: initialTraceId,
          onLogSubmitted: (record) => Navigator.of(ctx).pop(record),
        ),
      ),
    );
  }

  @override
  State<FrictionLoggingSheet> createState() => _FrictionLoggingSheetState();
}

class _FrictionLoggingSheetState extends State<FrictionLoggingSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _alertPulseController;
  late final Animation<double> _pulseAnimation;
  late final TextEditingController _traceIdController;

  static const Map<String, List<String>> _cascadingFrictionTaxonomy = {
    'Workflow Stoppage': [
      'Form Validation Lock',
      'Missing Mandatory Action',
      'Gateway Latency',
      'State Sync Desync',
    ],
    'UX Friction': [
      'Thumb Reach Inaccessible',
      'Unclear Microcopy',
      'Accidental Tap Dismissal',
      'Visual Hierarchy Confusion',
    ],
    'Data Mismatch': [
      'Disputed Balance',
      'Incorrect Status Tag',
      'Currency Precision Error',
      'Document Rejection',
    ],
    'System Error': [
      'API Timeout 504',
      'Authentication Expired',
      'Payload Malformed 422',
      'Crash / ANR Recovery',
    ],
  };

  static const List<String> _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  String? _selectedPrimaryCategory;
  String? _selectedSubCategory;
  String _selectedSeverity = 'Medium';
  bool _isTraceIdValid = false;

  @override
  void initState() {
    super.initState();
    _traceIdController = TextEditingController(text: widget.initialTraceId ?? '');
    _isTraceIdValid = _validateTraceId(_traceIdController.text);

    _alertPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _alertPulseController,
      curve: Curves.easeInOut,
    );

    _traceIdController.addListener(() {
      final isValid = _validateTraceId(_traceIdController.text);
      if (isValid != _isTraceIdValid) {
        setState(() {
          _isTraceIdValid = isValid;
        });
      }
    });
  }

  bool _validateTraceId(String input) {
    final trimmed = input.trim();
    return trimmed.isNotEmpty && trimmed.length >= 8 && !trimmed.contains(' ');
  }

  @override
  void dispose() {
    _alertPulseController.dispose();
    _traceIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_isTraceIdValid || _selectedPrimaryCategory == null || _selectedSubCategory == null) {
      return;
    }

    final record = FrictionLogRecord(
      stepExecutionId: 'EXEC-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: 'COMPLETED',
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: 'Friction Logged: [$_selectedPrimaryCategory -> $_selectedSubCategory]',
      userId: widget.userId,
      sessionId: widget.sessionId,
      systemTraceId: _traceIdController.text.trim(),
      primaryCategory: _selectedPrimaryCategory!,
      subCategory: _selectedSubCategory!,
      severity: _selectedSeverity,
      completionStatus: 'Good (100%)',
    );

    widget.onLogSubmitted?.call(record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCriticalOrHigh = _selectedSeverity == 'High' || _selectedSeverity == 'Critical';
    final showIntenseFlash = !_isTraceIdValid || isCriticalOrHigh;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Friction Log & Dispute',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'FLADE-010-09',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Alert Banner with intense flashing indicator
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final alertColor = !_isTraceIdValid
                    ? Colors.redAccent
                    : (isCriticalOrHigh ? Colors.orangeAccent : Colors.teal);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: showIntenseFlash
                        ? Color.lerp(alertColor.withOpacity(0.12), alertColor.withOpacity(0.38), _pulseAnimation.value)
                        : alertColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: showIntenseFlash
                          ? alertColor.withOpacity(_pulseAnimation.value * 0.9 + 0.1)
                          : alertColor.withOpacity(0.4),
                      width: showIntenseFlash ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        !_isTraceIdValid ? Icons.lock_clock_outlined : Icons.sensors_outlined,
                        color: alertColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          !_isTraceIdValid
                              ? 'SUBMIT LOCKED: Attach a valid system trace_id to proceed.'
                              : 'Trace validated: ${_traceIdController.text.trim()}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Trace ID Entry
            Text(
              'System Trace ID (Required)',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _traceIdController,
              decoration: InputDecoration(
                hintText: 'e.g. TRACE-8849-AF01',
                prefixIcon: const Icon(Icons.fingerprint),
                suffixIcon: _isTraceIdValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error_outline, color: Colors.redAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'Must be >= 8 chars with no spaces',
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Parent Category Selection (Thumb-accessible Choice Chips)
            Text(
              'Primary Friction Area (Thumb Selection)',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cascadingFrictionTaxonomy.keys.map((cat) {
                final isSelected = _selectedPrimaryCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPrimaryCategory = selected ? cat : null;
                      _selectedSubCategory = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Step 2: Child Category (Cascading population)
            if (_selectedPrimaryCategory != null) ...[
              Text(
                'Specific Trigger Reason (Cascading)',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cascadingFrictionTaxonomy[_selectedPrimaryCategory]!.map((sub) {
                  final isSelected = _selectedSubCategory == sub;
                  return ChoiceChip(
                    label: Text(sub),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubCategory = selected ? sub : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Step 3: Severity Segmented Button
            Text(
              'Dispute Severity',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: _severityLevels
                  .map((s) => ButtonSegment<String>(value: s, label: Text(s)))
                  .toList(),
              selected: {_selectedSeverity},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedSeverity = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Submit Button physically gated by valid system trace_id and mandatory selections
            FilledButton.icon(
              key: const Key('submit_friction_log_button'),
              onPressed: (_isTraceIdValid &&
                      _selectedPrimaryCategory != null &&
                      _selectedSubCategory != null)
                  ? _handleSubmit
                  : null,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Log Dispute & Friction Event'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
