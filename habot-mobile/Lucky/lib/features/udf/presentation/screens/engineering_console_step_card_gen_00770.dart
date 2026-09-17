// GEN-00770 — Engineering Console Step Health Card for ATT Opt-In Recovery Pipeline.
// Displays M3 Elevated Card with status chip, 48x48dp touch targets, responsive single/multi-column layout, and 30-second polling refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, notComplete, loading }

class EngineeringConsoleStepCardGen00770 extends StatefulWidget {
  const EngineeringConsoleStepCardGen00770({super.key});

  @override
  State<EngineeringConsoleStepCardGen00770> createState() => _EngineeringConsoleStepCardGen00770State();
}

class _EngineeringConsoleStepCardGen00770State extends State<EngineeringConsoleStepCardGen00770> {
  StepCompletionStatus _status = StepCompletionStatus.loading;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchStepHealth();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchStepHealth();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStepHealth() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    // Simulate API call to master_library/integrations health endpoint
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() {
      _status = StepCompletionStatus.complete;
      _isRefreshing = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchStepHealth();
  }

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
      case StepCompletionStatus.loading:
        return colorScheme.outline;
    }
  }

  String _statusLabel() {
    switch (_status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
      case StepCompletionStatus.loading:
        return 'Loading...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isDesktop = constraints.maxWidth >= 840;

        final card = _buildM3ElevatedCard(context, isMobile);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: card),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailPanel(context)),
            ],
          );
        }

        return card;
      },
    );
  }

  Widget _buildM3ElevatedCard(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
                          'ATT Opt-In Recovery Pipeline',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        avatar: _isRefreshing
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Icon(
                                _status == StepCompletionStatus.complete
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                size: 16,
                                color: _statusColor(context),
                              ),
                        label: Text(
                          _statusLabel(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _statusColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: _statusColor(context).withOpacity(0.12),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Metric: Directory Path Integrity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _status == StepCompletionStatus.complete ? 1.0 : 0.0,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _statusColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Target: 100% | Standard: Python Package Layout Rules',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Drill-down details',
                        onPressed: () => _showBottomSheet(context),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step Details', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Text(
              'Global Reference ID: GEN-00770\n'
              'Dependency: GEN-00769\n'
              'Estimated Time: 4 Hours\n'
              'CI/CD Pass Rate: 100%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Details',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Access master_library/integrations/. is a critical implementation step. '
                'All step execution events stream to BigQuery partitioned by event_date.',
                style: theme.textTheme.bodyMedium,
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
                        content: const Text('Configuration acknowledged'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}