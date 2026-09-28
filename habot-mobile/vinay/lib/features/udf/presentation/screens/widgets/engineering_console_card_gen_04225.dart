// GEN-04225 — Engineering Console M3 Status Card for NPM Package Governance Gate.
// Displays step completion state using Material 3 ElevatedCard, StatusChip, and mock deliverable verification data with 30s polling simulation.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepStatus { pass, fail, pending }

class Gen04225MockStepData {
  final String atomicId;
  final String globalRefId;
  final String description;
  final StepStatus status;
  final DateTime lastUpdated;
  final String metricName;
  final String standardReference;

  const Gen04225MockStepData({
    required this.atomicId,
    required this.globalRefId,
    required this.description,
    required this.status,
    required this.lastUpdated,
    required this.metricName,
    required this.standardReference,
  });
}

class Gen04225MockRepository {
  static const List<Gen04225MockStepData> steps = [
    Gen04225MockStepData(
      atomicId: 'GEN-04225',
      globalRefId: 'GEN-04225',
      description: 'Published Private NPM M3 Component Package & Linters',
      status: StepStatus.pass,
      lastUpdated: DateTime(2026, 9, 28, 10, 15),
      metricName: 'Deliverable/Output Verification',
      standardReference: 'PMBOK 7th Edition – Deliverable Acceptance Criteria',
    ),
  ];

  static Future<List<Gen04225MockStepData>> fetchSteps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return steps;
  }
}

class EngineeringConsoleCardGen04225 extends StatefulWidget {
  const EngineeringConsoleCardGen04225({super.key});

  @override
  State<EngineeringConsoleCardGen04225> createState() => _EngineeringConsoleCardGen04225State();
}

class _EngineeringConsoleCardGen04225State extends State<EngineeringConsoleCardGen04225> {
  List<Gen04225MockStepData> _steps = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds as per requirement
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
    final data = await Gen04225MockRepository.fetchSteps();
    if (mounted) {
      setState(() {
        _steps = data;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(StepStatus status, ColorScheme colorScheme) {
    switch (status) {
      case StepStatus.pass:
        return colorScheme.primary;
      case StepStatus.fail:
        return colorScheme.error;
      case StepStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusLabel(StepStatus status) {
    switch (status) {
      case StepStatus.pass:
        return 'Pass';
      case StepStatus.fail:
        return 'Fail';
      case StepStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (≥840dp)
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading && _steps.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: isDesktop ? 3.0 : 2.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _buildElevatedCard(step, colorScheme, textTheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildElevatedCard(
    Gen04225MockStepData step,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _showConfigurationBottomSheet(step),
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
                      step.atomicId,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // M3 Status Chips for health indicators
                  Chip(
                    avatar: Icon(
                      step.status == StepStatus.pass ? Icons.check_circle : Icons.error_outline,
                      size: 18.0,
                      color: _getStatusColor(step.status, colorScheme),
                    ),
                    label: Text(
                      _getStatusLabel(step.status),
                      style: textTheme.labelLarge?.copyWith(
                        color: _getStatusColor(step.status, colorScheme),
                      ),
                    ),
                    backgroundColor: _getStatusColor(step.status, colorScheme).withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                step.description,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 16.0, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      step.metricName,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
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

  // M3 Bottom Sheet for configuration inputs
  void _showConfigurationBottomSheet(Gen04225MockStepData step) {
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text('Step Details', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Global Reference ID'),
                subtitle: Text(step.globalRefId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Standard Reference'),
                subtitle: Text(step.standardReference),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Last Updated'),
                subtitle: Text(step.lastUpdated.toIso8601String()),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                // 48x48dp touch targets
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // M3 Snackbar for confirmations
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    );
                  },
                  child: const Text('Acknowledge'),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }
}
