// GEN-03651 — AI MJE Policy Screening Engine and Mobile Approval Workflow.
// Displays step completion state using M3 Elevated Cards, Status Chips, and a 30-second background polling mechanism with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepStatus { complete, notComplete, pending }

class MockScreeningStep {
  final String id;
  final String title;
  final StepStatus status;
  final String description;

  const MockScreeningStep({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
  });
}

class MockScreeningRepository {
  static const List<MockScreeningStep> steps = [
    MockScreeningStep(
      id: 'STEP-001',
      title: 'Policy Validation',
      status: StepStatus.complete,
      description: 'AI-driven policy rules evaluated successfully.',
    ),
    MockScreeningStep(
      id: 'STEP-002',
      title: 'MJE Engine Screening',
      status: StepStatus.complete,
      description: 'Manual Journal Entry screening passed all gates.',
    ),
    MockScreeningStep(
      id: 'STEP-003',
      title: 'Mobile Approval Routing',
      status: StepStatus.pending,
      description: 'Awaiting approval from designated authority.',
    ),
    MockScreeningStep(
      id: 'STEP-004',
      title: 'BigQuery Event Streaming',
      status: StepStatus.notComplete,
      description: 'Telemetry sync to partitioned dataset pending.',
    ),
  ];

  Future<List<MockScreeningStep>> fetchSteps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return steps;
  }
}

class AiMjePolicyScreeningEngineGen03651 extends StatefulWidget {
  const AiMjePolicyScreeningEngineGen03651({super.key});

  @override
  State<AiMjePolicyScreeningEngineGen03651> createState() => _AiMjePolicyScreeningEngineGen03651State();
}

class _AiMjePolicyScreeningEngineGen03651State extends State<AiMjePolicyScreeningEngineGen03651> {
  final MockScreeningRepository _repository = MockScreeningRepository();
  List<MockScreeningStep> _steps = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling every 30 seconds as per requirement
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
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
      final data = await _repository.fetchSteps();
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

  Color _getStatusColor(StepStatus status, ThemeData theme) {
    switch (status) {
      case StepStatus.complete:
        return theme.colorScheme.primary;
      case StepStatus.notComplete:
        return theme.colorScheme.error;
      case StepStatus.pending:
        return theme.colorScheme.tertiary;
    }
  }

  String _getStatusText(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return 'Complete';
      case StepStatus.notComplete:
        return 'Not Complete';
      case StepStatus.pending:
        return 'Pending';
    }
  }

  IconData _getStatusIcon(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return Icons.check_circle_outline_rounded;
      case StepStatus.notComplete:
        return Icons.error_outline_rounded;
      case StepStatus.pending:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI MJE Policy Screening'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading && _steps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _steps.length,
                      itemBuilder: (context, index) => _buildStepCard(_steps[index], theme),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildStepCard(_steps[index], theme),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStepCard(MockScreeningStep step, ThemeData theme) {
    final statusColor = _getStatusColor(step.status, theme);

    // M3 Elevated Cards Level 2 (3dp)
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showConfigurationBottomSheet(step, theme),
        // 48x48dp touch targets minimum enforced by InkWell/Card defaults + padding
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
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // M3 Status Chips for health indicators
                  Chip(
                    avatar: Icon(
                      _getStatusIcon(step.status),
                      size: 18,
                      color: statusColor,
                    ),
                    label: Text(
                      _getStatusText(step.status),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                step.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  step.id,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // M3 Bottom Sheet for configuration inputs
  void _showConfigurationBottomSheet(MockScreeningStep step, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configure: ${step.title}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Approval Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // M3 Snackbar for confirmations
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${step.title} configuration saved.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
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
