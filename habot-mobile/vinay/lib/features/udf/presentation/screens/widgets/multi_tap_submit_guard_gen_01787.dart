// GEN-01787 — Multi-Tap Submit Guard & Engineering Console Widget.
// Implements a debounced submit button to prevent multi-tapping during cellular latency, wrapped in an M3 Elevated Card with status chips for the engineering console dashboard.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock telemetry data simulating BigQuery stream events for local validation.
class _MockTelemetryEvent {
  final String traceId;
  final DateTime timestamp;
  final String status;
  final double invalidStateFormLockRate;

  const _MockTelemetryEvent({
    required this.traceId,
    required this.timestamp,
    required this.status,
    required this.invalidStateFormLockRate,
  });
}

const List<_MockTelemetryEvent> _mockEvents = [
  _MockTelemetryEvent(
    traceId: 'trace-001-gen-01787',
    timestamp: null as dynamic,
    status: 'Pass',
    invalidStateFormLockRate: 100.0,
  ),
  _MockTelemetryEvent(
    traceId: 'trace-002-gen-01787',
    timestamp: null as dynamic,
    status: 'Pass',
    invalidStateFormLockRate: 99.5,
  ),
];

/// A widget that provides a multi-tap guarded submit button and displays
/// M3 engineering console KPI cards.
class MultiTapSubmitGuardGen01787 extends StatefulWidget {
  const MultiTapSubmitGuardGen01787({super.key});

  @override
  State<MultiTapSubmitGuardGen01787> createState() => _MultiTapSubmitGuardGen01787State();
}

class _MultiTapSubmitGuardGen01787State extends State<MultiTapSubmitGuardGen01787> {
  bool _isSubmitting = false;
  Timer? _pollingTimer;
  int _tapCount = 0;
  int _blockedTaps = 0;
  String _lastStatus = 'Idle';

  @override
  void initState() {
    super.initState();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshTelemetry();
    });
    _refreshTelemetry();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _refreshTelemetry() {
    setState(() {
      // Simulate fetching latest mock event
      if (_mockEvents.isNotEmpty) {
        _lastStatus = _mockEvents.last.status;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) {
      setState(() => _blockedTaps++);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _tapCount++;
      _lastStatus = 'Processing';
    });

    // Simulate cellular latency (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _lastStatus = 'Pass';
    });

    // M3 Snackbar for confirmations
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Submission validated successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-01787 Engineering Console'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshTelemetry(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // M3 Elevated Card Level 2 (3dp)
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invalid State Form Lock Rate (%)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Floor Threshold: 99%',
                            style: theme.textTheme.bodyMedium,
                          ),
                          // M3 Status Chip for health indicators
                          Chip(
                            avatar: Icon(
                              _lastStatus == 'Pass' ? Icons.check_circle : Icons.pending,
                              size: 18.0,
                              color: _lastStatus == 'Pass' ? Colors.green : Colors.orange,
                            ),
                            label: Text(_lastStatus),
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      LinearProgressIndicator(
                        value: 1.0, // 100% optimal target
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Metrics Summary Card
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manual Testing Metrics', style: theme.textTheme.titleMedium),
                      const Divider(height: 24.0),
                      _buildMetricRow('Total Taps Attempted', _tapCount.toString()),
                      _buildMetricRow('Blocked Multi-Taps', _blockedTaps.toString()),
                      _buildMetricRow('Trace ID', _mockEvents.first.traceId),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),

              // 48x48dp touch targets submit button
              SizedBox(
                height: 48.0,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Execute Manual Test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
