// GEN-01743 — Event Payload Packager Widget.
// Packages tracked event payloads utilizing the Frontend Governance SDK with M3 Elevated Cards, status chips, and background polling every 30 seconds.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class MockTrackedEventPayload {
  final String traceId;
  final String eventName;
  final DateTime timestamp;
  final String sessionId;
  final StepCompletionStatus status;
  final double completionRate;

  const MockTrackedEventPayload({
    required this.traceId,
    required this.eventName,
    required this.timestamp,
    required this.sessionId,
    required this.status,
    required this.completionRate,
  });
}

class MockGovernanceSdkRepository {
  static const List<MockTrackedEventPayload> mockEvents = [
    MockTrackedEventPayload(
      traceId: 'trace-gen-01743-001',
      eventName: 'Package Tracked Event Payloads',
      timestamp: _MockDateTime.fixed1,
      sessionId: 'session-user-9921',
      status: StepCompletionStatus.complete,
      completionRate: 99.5,
    ),
    MockTrackedEventPayload(
      traceId: 'trace-gen-01743-002',
      eventName: 'Frontend Governance Validation',
      timestamp: _MockDateTime.fixed2,
      sessionId: 'session-user-9922',
      status: StepCompletionStatus.partial,
      completionRate: 92.0,
    ),
    MockTrackedEventPayload(
      traceId: 'trace-gen-01743-003',
      eventName: 'BigQuery Stream Alignment',
      timestamp: _MockDateTime.fixed3,
      sessionId: 'session-user-9923',
      status: StepCompletionStatus.notComplete,
      completionRate: 45.0,
    ),
  ];

  Future<List<MockTrackedEventPayload>> fetchPackagedEvents() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms latency simulation
    return mockEvents;
  }
}

class _MockDateTime {
  static final DateTime fixed1 = DateTime(2026, 9, 23, 10, 15);
  static final DateTime fixed2 = DateTime(2026, 9, 23, 10, 16);
  static final DateTime fixed3 = DateTime(2026, 9, 23, 10, 17);
}

class EventPayloadPackagerGen01743 extends StatefulWidget {
  const EventPayloadPackagerGen01743({super.key});

  @override
  State<EventPayloadPackagerGen01743> createState() => _EventPayloadPackagerGen01743State();
}

class _EventPayloadPackagerGen01743State extends State<EventPayloadPackagerGen01743> {
  final MockGovernanceSdkRepository _repository = MockGovernanceSdkRepository();
  List<MockTrackedEventPayload> _events = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchPackagedEvents();
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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            if (_isLoading && _events.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step Health: GEN-01743',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Package the tracked event payloads utilizing the Frontend Governance SDK.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 2.0,
                    ),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _EventHealthCard(event: _events[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EventHealthCard extends StatelessWidget {
  final MockTrackedEventPayload event;

  const _EventHealthCard({required this.event});

  Color _getStatusColor(BuildContext context, StepCompletionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.partial:
        return colorScheme.tertiary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context, event.status);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showConfigurationBottomSheet(context, event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.eventName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _getStatusLabel(event.status),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.fingerprint, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.traceId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completion Rate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${event.completionRate.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: event.completionRate >= 90
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: event.completionRate / 100.0,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6.0,
                borderRadius: BorderRadius.circular(3.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationBottomSheet(BuildContext context, MockTrackedEventPayload event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Trace ID', value: event.traceId),
              _DetailRow(label: 'Session ID', value: event.sessionId),
              _DetailRow(label: 'Timestamp', value: event.timestamp.toIso8601String()),
              _DetailRow(label: 'Standard', value: 'ISO/IEC 27001:2022 General Standards'),
              _DetailRow(label: 'Output Field', value: _getStatusLabel(event.status)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch targets
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration synced successfully.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Sync'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}