// GEN-02098 — Step Health Status Card & Engineering Console Widget.
// Displays M3 Elevated Card with status chips, completion metrics, and mock data for step validation. Responsive single-column mobile layout.

import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class StepHealthModel {
  final String atomicId;
  final String globalRefId;
  final String actionDescription;
  final StepCompletionStatus status;
  final double completionRate;
  final DateTime timestamp;
  final String sessionId;

  const StepHealthModel({
    required this.atomicId,
    required this.globalRefId,
    required this.actionDescription,
    required this.status,
    required this.completionRate,
    required this.timestamp,
    required this.sessionId,
  });
}

class MockStepHealthRepository {
  static List<StepHealthModel> getMockData() {
    return [
      StepHealthModel(
        atomicId: 'GEN-02098',
        globalRefId: 'GEN-02098',
        actionDescription:
            'Force the developer to fix the broken code locally before re-attempting.',
        status: StepCompletionStatus.complete,
        completionRate: 99.0,
        timestamp: DateTime.now(),
        sessionId: 'sess_udf_001',
      ),
      StepHealthModel(
        atomicId: 'GEN-02097',
        globalRefId: 'GEN-02097',
        actionDescription: 'Prior foundational step dependency check.',
        status: StepCompletionStatus.partial,
        completionRate: 85.5,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        sessionId: 'sess_udf_001',
      ),
    ];
  }
}

class StepHealthCardGen02098 extends StatelessWidget {
  final StepHealthModel model;

  const StepHealthCardGen02098({
    super.key,
    required this.model,
  });

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

  String _getStatusText(StepCompletionStatus status) {
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context, model.status);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
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
                    model.atomicId,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(model.status),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.15),
                  side: BorderSide(color: statusColor, width: 1),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              model.actionDescription,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20.0,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Completion Rate: ${model.completionRate.toStringAsFixed(1)}%',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (model.completionRate < 90.0)
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20.0,
                    color: colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Divider(color: colorScheme.outlineVariant, thickness: 0.5),
            const SizedBox(height: 8.0),
            Text(
              'Timestamp: ${model.timestamp.toIso8601String()}',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 48.0, // 48x48dp touch targets
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Drill-down triggered for ${model.atomicId}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 18.0),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EngineeringConsoleScreenGen02098 extends StatefulWidget {
  const EngineeringConsoleScreenGen02098({super.key});

  @override
  State<EngineeringConsoleScreenGen02098> createState() =>
      _EngineeringConsoleScreenGen02098State();
}

class _EngineeringConsoleScreenGen02098State
    extends State<EngineeringConsoleScreenGen02098> {
  late List<StepHealthModel> _steps;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _steps = MockStepHealthRepository.getMockData();
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _steps = MockStepHealthRepository.getMockData();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Manual Sync',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

            if (_isRefreshing && _steps.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: isMobile ? 1.2 : 1.8,
              ),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return StepHealthCardGen02098(model: _steps[index]);
              },
            );
          },
        ),
      ),
    );
  }
}