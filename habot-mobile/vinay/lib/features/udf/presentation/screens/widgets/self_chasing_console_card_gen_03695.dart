// GEN-03695 — Self-Chasing Mechanism Engineering Console Card.
// Displays account freeze status, biometric failure alerts, and execution speed metrics using M3 Elevated Cards with 30-second background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepHealthStatus { pass, fail, pending }

class MockFreezeEvent {
  final String traceId;
  final String sessionId;
  final DateTime timestamp;
  final StepHealthStatus status;
  final int executionTimeMs;
  final String triggerReason;

  const MockFreezeEvent({
    required this.traceId,
    required this.sessionId,
    required this.timestamp,
    required this.status,
    required this.executionTimeMs,
    required this.triggerReason,
  });
}

class MockSelfChasingRepository {
  static const List<MockFreezeEvent> mockEvents = [
    MockFreezeEvent(
      traceId: 'trace-88291-a',
      sessionId: 'sess-001-gen-03695',
      timestamp: DateTime(2026, 9, 28, 10, 15, 30),
      status: StepHealthStatus.pass,
      executionTimeMs: 45,
      triggerReason: 'Failed biometric attempt (3 consecutive)',
    ),
    MockFreezeEvent(
      traceId: 'trace-88292-b',
      sessionId: 'sess-002-gen-03695',
      timestamp: DateTime(2026, 9, 28, 11, 02, 15),
      status: StepHealthStatus.fail,
      executionTimeMs: 1250,
      triggerReason: 'Duress PIN triggered by user',
    ),
    MockFreezeEvent(
      traceId: 'trace-88293-c',
      sessionId: 'sess-003-gen-03695',
      timestamp: DateTime(2026, 9, 28, 12, 45, 00),
      status: StepHealthStatus.pass,
      executionTimeMs: 82,
      triggerReason: 'Automated liveness handshake anomaly',
    ),
  ];

  Future<List<MockFreezeEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockEvents;
  }
}

class SelfChasingConsoleCardGen03695 extends StatefulWidget {
  const SelfChasingConsoleCardGen03695({super.key});

  @override
  State<SelfChasingConsoleCardGen03695> createState() => _SelfChasingConsoleCardGen03695State();
}

class _SelfChasingConsoleCardGen03695State extends State<SelfChasingConsoleCardGen03695> {
  final MockSelfChasingRepository _repository = MockSelfChasingRepository();
  List<MockFreezeEvent> _events = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchEvents();
      if (mounted) {
        setState(() {
          _events = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(StepHealthStatus status, ThemeData theme) {
    switch (status) {
      case StepHealthStatus.pass:
        return theme.colorScheme.primary;
      case StepHealthStatus.fail:
        return theme.colorScheme.error;
      case StepHealthStatus.pending:
        return theme.colorScheme.tertiary;
    }
  }

  String _getStatusLabel(StepHealthStatus status) {
    switch (status) {
      case StepHealthStatus.pass:
        return 'Pass';
      case StepHealthStatus.fail:
        return 'Fail';
      case StepHealthStatus.pending:
        return 'Pending';
    }
  }

  void _showDetailsBottomSheet(MockFreezeEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Details', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _DetailRow(label: 'Trace ID', value: event.traceId),
              _DetailRow(label: 'Session ID', value: event.sessionId),
              _DetailRow(label: 'Timestamp', value: event.timestamp.toIso8601String()),
              _DetailRow(label: 'Execution Time', value: '${event.executionTimeMs} ms'),
              _DetailRow(label: 'Trigger', value: event.triggerReason),
              _DetailRow(label: 'Status', value: _getStatusLabel(event.status)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuration acknowledged')),
                      );
                    }
                  },
                  child: const Text('Acknowledge'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Self-Chasing Mechanism Console',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'GEN-03695 | Account Freeze Execution Speed | Target: < 100ms',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Text('No events recorded.', style: theme.textTheme.bodyLarge),
                ),
              )
            else
              ...(_events.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildEventCard(event, theme),
              ))),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(MockFreezeEvent event, ThemeData theme) {
    final statusColor = _getStatusColor(event.status, theme);
    final isWithinTarget = event.executionTimeMs < 100;
    final isWithinFloor = event.executionTimeMs < 1000;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailsBottomSheet(event),
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.triggerReason,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getStatusLabel(event.status),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    isWithinTarget ? Icons.bolt : (isWithinFloor ? Icons.timer : Icons.warning_amber_rounded),
                    size: 20,
                    color: isWithinTarget ? theme.colorScheme.primary : (isWithinFloor ? theme.colorScheme.tertiary : theme.colorScheme.error),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${event.executionTimeMs} ms',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isWithinTarget ? theme.colorScheme.primary : (isWithinFloor ? null : theme.colorScheme.error),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Trace: ${event.traceId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
