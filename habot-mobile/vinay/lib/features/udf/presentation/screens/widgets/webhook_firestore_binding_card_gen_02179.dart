// GEN-02179 — Webhook Firestore Binding UI Component.
// Binds UI components to Webhook payloads via Firestore real-time updates using mock data, M3 Elevated Cards, Status Chips, and 30s polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum ProcessStatus { pass, fail, pending }

class WebhookPayload {
  final String traceId;
  final DateTime timestamp;
  final String sessionId;
  final ProcessStatus status;
  final double accuracy;

  const WebhookPayload({
    required this.traceId,
    required this.timestamp,
    required this.sessionId,
    required this.status,
    required this.accuracy,
  });
}

class MockFirestoreRepository {
  static const List<WebhookPayload> _mockData = [
    WebhookPayload(
      traceId: 'trace-001-gen-02179',
      timestamp: DateTime(2026, 9, 24, 10, 0),
      sessionId: 'session-alpha',
      status: ProcessStatus.pass,
      accuracy: 0.98,
    ),
    WebhookPayload(
      traceId: 'trace-002-gen-02179',
      timestamp: DateTime(2026, 9, 24, 10, 5),
      sessionId: 'session-beta',
      status: ProcessStatus.fail,
      accuracy: 0.85,
    ),
    WebhookPayload(
      traceId: 'trace-003-gen-02179',
      timestamp: DateTime(2026, 9, 24, 10, 10),
      sessionId: 'session-gamma',
      status: ProcessStatus.pass,
      accuracy: 0.97,
    ),
  ];

  Stream<List<WebhookPayload>> getRealtimeUpdates() {
    return Stream.periodic(const Duration(seconds: 30), (count) {
      return _mockData;
    }).asBroadcastStream();
  }

  Future<List<WebhookPayload>> fetchOnce() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _mockData;
  }
}

class WebhookFirestoreBindingCardGen02179 extends StatefulWidget {
  const WebhookFirestoreBindingCardGen02179({super.key});

  @override
  State<WebhookFirestoreBindingCardGen02179> createState() => _WebhookFirestoreBindingCardGen02179State();
}

class _WebhookFirestoreBindingCardGen02179State extends State<WebhookFirestoreBindingCardGen02179> {
  final MockFirestoreRepository _repository = MockFirestoreRepository();
  StreamSubscription<List<WebhookPayload>>? _subscription;
  List<WebhookPayload> _payloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final initialData = await _repository.fetchOnce();
    if (!mounted) return;
    setState(() {
      _payloads = initialData;
      _isLoading = false;
    });

    _subscription = _repository.getRealtimeUpdates().listen((data) {
      if (!mounted) return;
      setState(() {
        _payloads = data;
      });
    });
  }

  Future<void> _onRefresh() async {
    final data = await _repository.fetchOnce();
    if (!mounted) return;
    setState(() {
      _payloads = data;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isMobile ? 2.5 : 2.0,
                    ),
                    itemCount: _payloads.length,
                    itemBuilder: (context, index) {
                      final payload = _payloads[index];
                      return _buildElevatedCard(payload, colorScheme, theme.textTheme);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildElevatedCard(WebhookPayload payload, ColorScheme colorScheme, TextTheme textTheme) {
    final statusColor = payload.status == ProcessStatus.pass
        ? colorScheme.primary
        : colorScheme.error;
    final statusLabel = payload.status == ProcessStatus.pass ? 'Pass' : 'Fail';

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showConfigurationSheet(payload),
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
                      payload.traceId,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: Text(statusLabel),
                    backgroundColor: statusColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                    side: BorderSide(color: statusColor.withOpacity(0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Accuracy: ${(payload.accuracy * 100).toStringAsFixed(1)}%',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Session: ${payload.sessionId}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                'Time: ${payload.timestamp.toIso8601String().substring(11, 16)}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationSheet(WebhookPayload payload) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration: ${payload.traceId}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Metric Config Override',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                readOnly: true,
                controller: TextEditingController(text: 'Process Execution Accuracy (Floor: 90%)'),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}