// GEN-01908 — Engineering Console Step Health Card.
// Displays step completion state using M3 Elevated Cards, status chips, and responsive layout with mock telemetry data.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepHealth { high, medium, low }

class MockStepData {
  final String atomicId;
  final String title;
  final StepHealth health;
  final double fidelityPercentage;
  final DateTime lastUpdated;

  const MockStepData({
    required this.atomicId,
    required this.title,
    required this.health,
    required this.fidelityPercentage,
    required this.lastUpdated,
  });
}

final List<MockStepData> _mockSteps = [
  MockStepData(
    atomicId: 'GEN-01908',
    title: 'Byt Split by OPS Restore Flow',
    health: StepHealth.high,
    fidelityPercentage: 99.5,
    lastUpdated: DateTime.now().subtract(const Duration(seconds: 12)),
  ),
  MockStepData(
    atomicId: 'GEN-01907',
    title: 'Prior Foundational Baseline Config',
    health: StepHealth.medium,
    fidelityPercentage: 96.2,
    lastUpdated: DateTime.now().subtract(const Duration(seconds: 28)),
  ),
];

class EngineeringConsoleCardGen01908 extends StatefulWidget {
  const EngineeringConsoleCardGen01908({super.key});

  @override
  State<EngineeringConsoleCardGen01908> createState() => _EngineeringConsoleCardGen01908State();
}

class _EngineeringConsoleCardGen01908State extends State<EngineeringConsoleCardGen01908> {
  Timer? _pollingTimer;
  List<MockStepData> _steps = _mockSteps;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _steps = _steps.map((s) => MockStepData(
        atomicId: s.atomicId,
        title: s.title,
        health: s.health,
        fidelityPercentage: s.fidelityPercentage,
        lastUpdated: DateTime.now(),
      )).toList();
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _healthColor(StepHealth health, ColorScheme cs) {
    switch (health) {
      case StepHealth.high:
        return cs.primary;
      case StepHealth.medium:
        return cs.tertiary;
      case StepHealth.low:
        return cs.error;
    }
  }

  String _healthLabel(StepHealth health) {
    switch (health) {
      case StepHealth.high:
        return 'High';
      case StepHealth.medium:
        return 'Medium';
      case StepHealth.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? 2 : 1;
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 1.8,
            ),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _buildCard(step, cs, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(MockStepData step, ColorScheme cs, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showBottomSheet(step, cs, theme),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.atomicId,
                      style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  Chip(
                    avatar: Icon(Icons.circle, size: 12, color: _healthColor(step.health, cs)),
                    label: Text(_healthLabel(step.health)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                step.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.speed_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${step.fidelityPercentage.toStringAsFixed(1)}% Fidelity',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (_isRefreshing && step.atomicId == 'GEN-01908')
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(MockStepData step, ColorScheme cs, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuration: ${step.atomicId}', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text('Title: ${step.title}', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Health: ${_healthLabel(step.health)}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Fidelity Target: 99.5% | Floor: 95%', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Last Sync: ${step.lastUpdated.toIso8601String()}', style: theme.textTheme.bodySmall),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${step.atomicId} configuration saved.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Apply Configuration'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}