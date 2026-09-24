// GEN-02087 — Byt Attention Screen with M3 Status Cards and Deep-Link Support.
// Opens the mobile app directly to a specific Byt requiring attention, displaying completion state via M3 Elevated Cards, background polling every 30s, and pull-to-refresh. Responsive single-column (<600dp) / multi-column (>=840dp).

import 'dart:async';
import 'package:flutter/material.dart';

enum StepStatus { complete, partial, notComplete }

class BytStep {
  final String id;
  final String traceId;
  final String title;
  final StepStatus status;
  final double completionRate;
  final DateTime timestamp;

  const BytStep({
    required this.id,
    required this.traceId,
    required this.title,
    required this.status,
    required this.completionRate,
    required this.timestamp,
  });
}

class MockBytRepository {
  static const List<BytStep> mockSteps = [
    BytStep(
      id: 'BYT-001',
      traceId: 'trace-99a8b7c6',
      title: 'Initialize DCDF Engine Baseline',
      status: StepStatus.complete,
      completionRate: 100.0,
      timestamp: DateTime(2026, 9, 24, 10, 0),
    ),
    BytStep(
      id: 'BYT-002',
      traceId: 'trace-11b2c3d4',
      title: 'Validate ISO/IEC 27001:2022 Compliance',
      status: StepStatus.partial,
      completionRate: 65.5,
      timestamp: DateTime(2026, 9, 24, 10, 15),
    ),
    BytStep(
      id: 'BYT-003',
      traceId: 'trace-55e6f7g8',
      title: 'Stream Execution Events to BigQuery',
      status: StepStatus.notComplete,
      completionRate: 0.0,
      timestamp: DateTime(2026, 9, 24, 10, 30),
    ),
  ];

  Future<List<BytStep>> fetchBytSteps() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms mock latency
    return mockSteps;
  }
}

class BytAttentionScreenGen02087 extends StatefulWidget {
  final String? deepLinkBytId;

  const BytAttentionScreenGen02087({super.key, this.deepLinkBytId});

  @override
  State<BytAttentionScreenGen02087> createState() => _BytAttentionScreenGen02087State();
}

class _BytAttentionScreenGen02087State extends State<BytAttentionScreenGen02087> {
  final MockBytRepository _repository = MockBytRepository();
  List<BytStep> _steps = [];
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

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchBytSteps();
      if (mounted) {
        setState(() {
          _steps = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Color _getStatusColor(StepStatus status, ColorScheme colorScheme) {
    switch (status) {
      case StepStatus.complete:
        return colorScheme.primary;
      case StepStatus.partial:
        return colorScheme.tertiary;
      case StepStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return 'Complete';
      case StepStatus.partial:
        return 'Partial';
      case StepStatus.notComplete:
        return 'Not Complete';
    }
  }

  void _showConfigBottomSheet(BytStep step) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configure ${step.id}', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Trace ID: ${step.traceId}'),
              const SizedBox(height: 16),
              Text('Current Rate: ${step.completionRate.toStringAsFixed(1)}%'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Configuration saved for ${step.id}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BytStep step, ColorScheme colorScheme) {
    final isDeepLinked = widget.deepLinkBytId == step.id;
    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showConfigBottomSheet(step),
        borderRadius: BorderRadius.circular(12),
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
                      step.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isDeepLinked)
                    Icon(Icons.link, color: colorScheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(_getStatusLabel(step.status)),
                    backgroundColor: _getStatusColor(step.status, colorScheme).withOpacity(0.15),
                    labelStyle: TextStyle(color: _getStatusColor(step.status, colorScheme)),
                    side: BorderSide.none,
                  ),
                  const Spacer(),
                  Text(
                    '${step.completionRate.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(step.status, colorScheme),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Timestamp: ${step.timestamp.toIso8601String()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Byt Attention Console'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Engineering Console Info',
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450,
                        mainAxisExtent: 160,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _steps.length,
                      itemBuilder: (context, index) => _buildCard(_steps[index], colorScheme),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) => _buildCard(_steps[index], colorScheme),
                  );
                },
              ),
            ),
    );
  }
}
