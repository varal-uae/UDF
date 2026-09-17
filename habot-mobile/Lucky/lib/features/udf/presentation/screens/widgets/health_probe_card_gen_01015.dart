// GEN-01015 — Automated System Handshake & Health Probe M3 Status Card.
// Displays database connection handshake verification status inside readiness probes with M3 Elevated Card, status chips, 48x48dp touch targets, and responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum HandshakeStatus { complete, notComplete }

class HandshakeHealthData {
  final String stepName;
  final HandshakeStatus status;
  final double latencyMs;
  final DateTime timestamp;
  final String sessionId;

  const HandshakeHealthData({
    required this.stepName,
    required this.status,
    required this.latencyMs,
    required this.timestamp,
    required this.sessionId,
  });
}

class MockHandshakeRepository {
  static const List<HandshakeHealthData> _mockData = [
    HandshakeHealthData(
      stepName: 'Database Connection Handshake Verification',
      status: HandshakeStatus.complete,
      latencyMs: 1.8,
      timestamp: DateTime(2026, 9, 17, 10, 0, 0),
      sessionId: 'sess_udf_001',
    ),
    HandshakeHealthData(
      stepName: 'Readiness Probe API Gateway Ingress',
      status: HandshakeStatus.complete,
      latencyMs: 4.2,
      timestamp: DateTime(2026, 9, 17, 10, 0, 30),
      sessionId: 'sess_udf_002',
    ),
    HandshakeHealthData(
      stepName: 'BigQuery Event Stream Validation',
      status: HandshakeStatus.notComplete,
      latencyMs: 22.5,
      timestamp: DateTime(2026, 9, 17, 10, 1, 0),
      sessionId: 'sess_udf_003',
    ),
  ];

  Future<List<HandshakeHealthData>> fetchHealthProbes() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockData;
  }
}

class HealthProbeCardGen01015 extends StatefulWidget {
  const HealthProbeCardGen01015({super.key});

  @override
  State<HealthProbeCardGen01015> createState() => _HealthProbeCardGen01015State();
}

class _HealthProbeCardGen01015State extends State<HealthProbeCardGen01015> {
  final MockHandshakeRepository _repository = MockHandshakeRepository();
  List<HandshakeHealthData> _probes = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _repository.fetchHealthProbes();
    if (mounted) {
      setState(() {
        _probes = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _showConfigBottomSheet(BuildContext context, HandshakeHealthData probe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuration: ${probe.stepName}', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Metric: Handshake Check Latency'),
            Text('Floor Boundary: <= 10 ms'),
            Text('Optimal Target: <= 2 ms'),
            Text('Ceiling Boundary: 20 ms'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration saved successfully.')),
                  );
                },
                child: const Text('Apply Configuration'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _isLoading && _probes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (isDesktop) {
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _probes.length,
                    itemBuilder: (context, index) => _buildElevatedCard(context, _probes[index]),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _probes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildElevatedCard(context, _probes[index]),
                );
              },
            ),
    );
  }

  Widget _buildElevatedCard(BuildContext context, HandshakeHealthData probe) {
    final isComplete = probe.status == HandshakeStatus.complete;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showConfigBottomSheet(context, probe),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      probe.stepName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    avatar: Icon(
                      isComplete ? Icons.check_circle_outline : Icons.error_outline,
                      size: 18,
                      color: isComplete ? colorScheme.primary : colorScheme.error,
                    ),
                    label: Text(isComplete ? 'Complete' : 'Not Complete'),
                    backgroundColor: isComplete
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: isComplete ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${probe.latencyMs.toStringAsFixed(1)} ms',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: probe.latencyMs <= 10
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.error,
                        ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      iconSize: 24,
                      onPressed: () => _showConfigBottomSheet(context, probe),
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Configure Probe',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
