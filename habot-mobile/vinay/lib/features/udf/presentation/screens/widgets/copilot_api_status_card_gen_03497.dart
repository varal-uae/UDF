// GEN-03497 — Copilot API Status Card for Engineering Console.
// Displays policy document indexing and copilot API interface health using M3 Elevated Cards, status chips, 30s polling, and pull-to-refresh. Responsive single-column (<600dp) or multi-column (>=840dp).

import 'dart:async';
import 'package:flutter/material.dart';

enum StepHealth { complete, pending, failed }

class CopilotApiStepData {
  final String atomicId;
  final String stepName;
  final StepHealth health;
  final double schemaMatch;
  final DateTime lastUpdated;

  const CopilotApiStepData({
    required this.atomicId,
    required this.stepName,
    required this.health,
    required this.schemaMatch,
    required this.lastUpdated,
  });
}

class MockCopilotApiRepository {
  static List<CopilotApiStepData> fetchSteps() {
    return [
      CopilotApiStepData(
        atomicId: 'GEN-03497',
        stepName: 'Standardize policy document indexing formats and copilot API interfaces.',
        health: StepHealth.complete,
        schemaMatch: 1.0,
        lastUpdated: DateTime.now(),
      ),
      CopilotApiStepData(
        atomicId: 'GEN-03496',
        stepName: 'Prior foundational step configuration.',
        health: StepHealth.complete,
        schemaMatch: 1.0,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}

class CopilotApiStatusCardGen03497 extends StatefulWidget {
  const CopilotApiStatusCardGen03497({super.key});

  @override
  State<CopilotApiStatusCardGen03497> createState() => _CopilotApiStatusCardGen03497State();
}

class _CopilotApiStatusCardGen03497State extends State<CopilotApiStatusCardGen03497> {
  List<CopilotApiStepData> _steps = [];
  Timer? _pollingTimer;
  bool _isRefreshing = false;

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
    setState(() {
      _steps = MockCopilotApiRepository.fetchSteps();
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Color _healthColor(StepHealth health, ColorScheme cs) {
    switch (health) {
      case StepHealth.complete:
        return cs.primary;
      case StepHealth.pending:
        return cs.tertiary;
      case StepHealth.failed:
        return cs.error;
    }
  }

  String _healthLabel(StepHealth health) {
    switch (health) {
      case StepHealth.complete:
        return 'Complete';
      case StepHealth.pending:
        return 'Pending';
      case StepHealth.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop ? 2 : 1;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final step = _steps[index];
                        return _buildElevatedCard(step, theme, cs);
                      },
                      childCount: _steps.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildElevatedCard(CopilotApiStepData step, ThemeData theme, ColorScheme cs) {
    return GestureDetector(
      onTap: () => _showConfigBottomSheet(step, theme, cs),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.atomicId,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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
                step.stepName,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schema Match: ${step.schemaMatch.toStringAsFixed(1)}',
                    style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    'Updated: ${step.lastUpdated.hour}:${step.lastUpdated.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(CopilotApiStepData step, ThemeData theme, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Details', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Atomic ID'),
                subtitle: Text(step.atomicId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Metric Name'),
                subtitle: const Text('Copilot API Schema Match'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Floor / Optimal / Ceiling'),
                subtitle: const Text('1.0 / 1.0 / 1.0'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Output'),
                subtitle: Text(step.health == StepHealth.complete ? 'Complete' : 'Incomplete'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(label: 'OK', onPressed: () {}),
                      ),
                    );
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
}
