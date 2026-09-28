// GEN-03596 — Design Token Adoption Dashboard Widget.
// Displays M3 Elevated Cards with status chips for design token adoption ratio, supporting single-column mobile and multi-column desktop layouts with 30-second background polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepStatus { pass, fail, pending }

class DesignTokenStepModel {
  final String atomicId;
  final String name;
  final StepStatus status;
  final double adoptionRatio;
  final DateTime lastChecked;

  const DesignTokenStepModel({
    required this.atomicId,
    required this.name,
    required this.status,
    required this.adoptionRatio,
    required this.lastChecked,
  });
}

class MockDesignTokenRepository {
  static List<DesignTokenStepModel> fetchSteps() {
    return [
      DesignTokenStepModel(
        atomicId: 'GEN-03596',
        name: 'Standardize UI Components via Design Tokens',
        status: StepStatus.pass,
        adoptionRatio: 1.0,
        lastChecked: DateTime.now(),
      ),
      DesignTokenStepModel(
        atomicId: 'GEN-03595',
        name: 'Foundational Design Token Setup',
        status: StepStatus.pass,
        adoptionRatio: 1.0,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      DesignTokenStepModel(
        atomicId: 'GEN-03597',
        name: 'Component Library Validation',
        status: StepStatus.pending,
        adoptionRatio: 0.85,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }
}

class DesignTokenDashboardGen03596 extends StatefulWidget {
  const DesignTokenDashboardGen03596({super.key});

  @override
  State<DesignTokenDashboardGen03596> createState() => _DesignTokenDashboardGen03596State();
}

class _DesignTokenDashboardGen03596State extends State<DesignTokenDashboardGen03596> {
  List<DesignTokenStepModel> _steps = [];
  Timer? _pollingTimer;
  bool _isRefreshing = false;

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

  void _loadData() {
    setState(() {
      _steps = MockDesignTokenRepository.fetchSteps();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _loadData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width >= 840) return 3;
    return 2;
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

  String _getStatusText(StepStatus status) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: crossAxisCount == 1 ? 3.0 : 2.0,
              ),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _buildElevatedCard(step, colorScheme, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildElevatedCard(
    DesignTokenStepModel step,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final statusColor = _getStatusColor(step.status, colorScheme);

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () => _showBottomSheet(step, theme),
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
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      _getStatusText(step.status),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Expanded(
                child: Text(
                  step.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(
                    'Adoption Ratio:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${(step.adoptionRatio * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: step.adoptionRatio >= 1.0 ? colorScheme.primary : colorScheme.error,
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

  void _showBottomSheet(DesignTokenStepModel step, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
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
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Configuration: ${step.atomicId}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Text(
                step.name,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Metric Config Override',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  hintText: 'Enter threshold override...',
                ),
                minLines: 1,
                maxLines: 3,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        action: SnackBarAction(
                          label: 'Dismiss',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
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