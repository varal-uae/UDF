// GEN-01655 — Mobile-First Design Token Pipeline Engineering Console Card.
// Displays step completion state using M3 Elevated Cards, status chips, and background polling with pull-to-refresh. Single-column on mobile (<600dp), multi-column on desktop (>=840dp). 48x48dp touch targets.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class MockStepData {
  final String atomicId;
  final String stepName;
  final StepCompletionStatus status;
  final int completionRate;
  final DateTime timestamp;
  final String sessionId;

  const MockStepData({
    required this.atomicId,
    required this.stepName,
    required this.status,
    required this.completionRate,
    required this.timestamp,
    required this.sessionId,
  });
}

class MockDesignTokenRepository {
  static const List<MockStepData> _mockSteps = [
    MockStepData(
      atomicId: 'GEN-01655',
      stepName: 'Finalize Figma Master File',
      status: StepCompletionStatus.complete,
      completionRate: 100,
      timestamp: null as dynamic,
      sessionId: 'sess_udf_001',
    ),
    MockStepData(
      atomicId: 'GEN-01654',
      stepName: 'Define Mobile-First Tokens',
      status: StepCompletionStatus.partial,
      completionRate: 85,
      timestamp: null as dynamic,
      sessionId: 'sess_udf_002',
    ),
  ];

  Future<List<MockStepData>> fetchStepHealth() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSteps.map((e) => MockStepData(
      atomicId: e.atomicId,
      stepName: e.stepName,
      status: e.status,
      completionRate: e.completionRate,
      timestamp: DateTime.now(),
      sessionId: e.sessionId,
    )).toList();
  }
}

class DesignTokenPipelineCardGen01655 extends StatefulWidget {
  const DesignTokenPipelineCardGen01655({super.key});

  @override
  State<DesignTokenPipelineCardGen01655> createState() => _DesignTokenPipelineCardGen01655State();
}

class _DesignTokenPipelineCardGen01655State extends State<DesignTokenPipelineCardGen01655> {
  final MockDesignTokenRepository _repository = MockDesignTokenRepository();
  List<MockStepData> _steps = [];
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
      _loadData(showLoading: false);
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchStepHealth();
      if (mounted) setState(() => _steps = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load step health: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (showLoading && mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(StepCompletionStatus status, ColorScheme colorScheme) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => _loadData(showLoading: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading) {
            return SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 2.0,
            ),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              final statusColor = _getStatusColor(step.status, colorScheme);

              return Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Drill-down for ${step.atomicId}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
                                step.stepName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                _getStatusLabel(step.status),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: statusColor.withOpacity(0.12),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'Completion Rate',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${step.completionRate}%',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: step.completionRate >= 90 ? colorScheme.primary : colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: step.completionRate / 100,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            step.completionRate >= 90 ? colorScheme.primary : colorScheme.error,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${step.atomicId} | Session: ${step.sessionId}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
