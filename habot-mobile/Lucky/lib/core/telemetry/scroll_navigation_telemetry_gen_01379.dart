// GEN-01379 — Scroll Depth and Navigation Telemetry Streamer.
// Streams scroll-depth and user navigation events to BigQuery user behavior tables with mock local storage, 30s polling, and M3 status cards.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

enum TelemetryHealth { good, average, poor }

class TelemetryEvent {
  final String eventId;
  final String traceId;
  final String eventType;
  final String sessionId;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  TelemetryEvent({
    required this.eventId,
    required this.traceId,
    required this.eventType,
    required this.sessionId,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'trace_id': traceId,
        'event_type': eventType,
        'session_id': sessionId,
        'timestamp': timestamp.toIso8601String(),
        'payload': payload,
      };
}

class MockBigQueryTelemetryRepository {
  final List<TelemetryEvent> _events = [];
  double _conversionRate = 0.82;

  Future<void> streamEvent(TelemetryEvent event) async {
    await Future.delayed(const Duration(milliseconds: 45));
    _events.add(event);
  }

  Future<List<TelemetryEvent>> fetchRecentEvents() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return List.unmodifiable(_events.reversed.take(20).toList());
  }

  Future<double> fetchConversionRate() async {
    return _conversionRate;
  }

  TelemetryHealth evaluateHealth(double rate) {
    if (rate >= 0.8) return TelemetryHealth.good;
    if (rate >= 0.6) return TelemetryHealth.average;
    return TelemetryHealth.poor;
  }
}

class ScrollNavigationTelemetryService {
  final MockBigQueryTelemetryRepository _repository;
  Timer? _pollingTimer;
  final String _sessionId;

  ScrollNavigationTelemetryService({
    required MockBigQueryTelemetryRepository repository,
    String? sessionId,
  })  : _repository = repository,
        _sessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _streamHeartbeat();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> trackScrollDepth(double scrollPercentage, String routeName) async {
    final event = TelemetryEvent(
      eventId: 'scr_${DateTime.now().millisecondsSinceEpoch}',
      traceId: 'trace_${_sessionId}_scr',
      eventType: 'scroll_depth',
      sessionId: _sessionId,
      timestamp: DateTime.now(),
      payload: {'percentage': scrollPercentage, 'route': routeName},
    );
    await _repository.streamEvent(event);
  }

  Future<void> trackNavigation(String fromRoute, String toRoute) async {
    final event = TelemetryEvent(
      eventId: 'nav_${DateTime.now().millisecondsSinceEpoch}',
      traceId: 'trace_${_sessionId}_nav',
      eventType: 'navigation',
      sessionId: _sessionId,
      timestamp: DateTime.now(),
      payload: {'from': fromRoute, 'to': toRoute},
    );
    await _repository.streamEvent(event);
  }

  Future<void> _streamHeartbeat() async {
    final event = TelemetryEvent(
      eventId: 'hb_${DateTime.now().millisecondsSinceEpoch}',
      traceId: 'trace_${_sessionId}_hb',
      eventType: 'liveness_handshake',
      sessionId: _sessionId,
      timestamp: DateTime.now(),
      payload: {'status': 'active'},
    );
    await _repository.streamEvent(event);
  }
}

class TelemetryDashboardScreen extends StatefulWidget {
  const TelemetryDashboardScreen({super.key});

  @override
  State<TelemetryDashboardScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<TelemetryDashboardScreen> {
  late final MockBigQueryTelemetryRepository _repository;
  late final ScrollNavigationTelemetryService _service;
  List<TelemetryEvent> _events = [];
  double _conversionRate = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = MockBigQueryTelemetryRepository();
    _service = ScrollNavigationTelemetryService(repository: _repository);
    _service.startPolling();
    _loadData();
  }

  @override
  void dispose() {
    _service.stopPolling();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final events = await _repository.fetchRecentEvents();
    final rate = await _repository.fetchConversionRate();
    if (mounted) {
      setState(() {
        _events = events;
        _conversionRate = rate;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = _repository.evaluateHealth(_conversionRate);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Manual Sync',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            if (isDesktop) {
              return _buildMultiColumnLayout(context, health, colorScheme);
            }
            return _buildSingleColumnLayout(context, health, colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context, TelemetryHealth health, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildKpiCard(context, health, colorScheme),
        const SizedBox(height: 16),
        _buildEventsList(context, colorScheme),
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context, TelemetryHealth health, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildKpiCard(context, health, colorScheme),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildEventsList(context, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, TelemetryHealth health, ColorScheme colorScheme) {
    final chipColor = health == TelemetryHealth.good
        ? Colors.green
        : health == TelemetryHealth.average
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mobile Conversion Funnel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Chip(
                  label: Text(
                    health.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: chipColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${(_conversionRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Baymard Institute Mobile UX Benchmark',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Card(
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No telemetry events streamed yet.\nInteract with the app to generate data.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Telemetry Events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final event = _events[index];
              return InkWell(
                onTap: () => _showEventDetails(context, event),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          event.eventType == 'scroll_depth'
                              ? Icons.swap_vert
                              : event.eventType == 'navigation'
                                  ? Icons.navigation
                                  : Icons.favorite_pulse_sharp,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventType.replaceAll('_', ' ').toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              jsonEncode(event.payload),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        TimeOfDay.fromDateTime(event.timestamp).format(context),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, TelemetryEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Event Details', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _detailRow('Event ID', event.eventId),
              _detailRow('Trace ID', event.traceId),
              _detailRow('Type', event.eventType),
              _detailRow('Session', event.sessionId),
              _detailRow('Timestamp', event.timestamp.toIso8601String()),
              _detailRow('Payload', jsonEncode(event.payload)),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
