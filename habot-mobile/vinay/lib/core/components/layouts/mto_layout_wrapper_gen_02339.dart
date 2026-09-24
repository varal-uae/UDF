// GEN-02339 — MTO Layout Wrapper for Universal Component Library.
// Provides a Material 3 responsive layout wrapper with single-column mobile (<600dp) and multi-column desktop (>=840dp) support, elevated cards, status chips, and 48x48dp touch targets.

import 'package:flutter/material.dart';

/// Mock data representing step completion states for the MTO layout.
class _MockStepData {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final double uiComplianceRate;

  const _MockStepData({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.uiComplianceRate,
  });
}

const List<_MockStepData> _kMockSteps = [
  _MockStepData(
    id: 'STEP-001',
    title: 'Foundation Setup',
    description: 'Initialize core UDF architecture components.',
    isCompleted: true,
    uiComplianceRate: 1.0,
  ),
  _MockStepData(
    id: 'STEP-002',
    title: 'Theme Configuration',
    description: 'Apply Material 3 dynamic color tokens.',
    isCompleted: true,
    uiComplianceRate: 0.98,
  ),
  _MockStepData(
    id: 'STEP-003',
    title: 'Telemetry Integration',
    description: 'Stream execution events to BigQuery.',
    isCompleted: false,
    uiComplianceRate: 0.85,
  ),
  _MockStepData(
    id: 'STEP-004',
    title: 'Accessibility Audit',
    description: 'Validate against WCAG 2.2 AA standards.',
    isCompleted: false,
    uiComplianceRate: 0.92,
  ),
];

/// A reusable M3 layout wrapper that adapts between single-column (mobile)
/// and multi-column (tablet/desktop) configurations.
///
/// Features:
/// - M3 Elevated Cards (Level 2, 3dp elevation)
/// - M3 Status Chips for health/completion indicators
/// - 48x48dp minimum touch targets
/// - Pull-to-refresh manual sync
/// - Responsive breakpoints: <600dp single column, >=840dp multi-column
class MtoLayoutWrapper extends StatefulWidget {
  final String title;
  final List<Widget>? children;

  const MtoLayoutWrapper({
    super.key,
    this.title = 'MTO Engineering Console',
    this.children,
  });

  @override
  State<MtoLayoutWrapper> createState() => _MtoLayoutWrapperState();
}

class _MtoLayoutWrapperState extends State<MtoLayoutWrapper> {
  late List<_MockStepData> _steps;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _steps = List.from(_kMockSteps);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate network/API polling delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _steps = List.from(_kMockSteps);
        _isRefreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data synchronized successfully.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'DISMISS',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 840;
    final bool isTablet = screenWidth >= 600 && screenWidth < 840;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        actions: [
          IconButton(
            iconSize: 48,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showConfigBottomSheet(context),
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        edgeOffset: kToolbarHeight,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: _buildSummaryCard(theme),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: isDesktop || isTablet
                  ? _buildMultiColumnGrid(isDesktop)
                  : _buildSingleColumnList(),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final int completedCount = _steps.where((s) => s.isCompleted).length;
    final double avgCompliance = _steps.isEmpty
        ? 0.0
        : _steps.map((s) => s.uiComplianceRate).reduce((a, b) => a + b) /
            _steps.length;
    final bool isCompliant = avgCompliance >= 0.95;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step Health Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isCompliant ? Icons.check_circle : Icons.warning,
                    size: 18,
                    color: isCompliant
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  label: Text(
                    isCompliant ? 'Compliant' : 'Non-Compliant',
                    style: TextStyle(
                      color: isCompliant
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    theme,
                    'Completed',
                    '$completedCount/${_steps.length}',
                    Icons.task_alt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    theme,
                    'UI Compliance Rate',
                    '${(avgCompliance * 100).toStringAsFixed(1)}%',
                    Icons.verified_user,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 24),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }

  SliverGrid _buildMultiColumnGrid(bool isDesktop) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: isDesktop ? 1.5 : 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildStepCard(_steps[index]),
        childCount: _steps.length,
      ),
    );
  }

  SliverList _buildSingleColumnList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildStepCard(_steps[index]),
        ),
        childCount: _steps.length,
      ),
    );
  }

  Widget _buildStepCard(_MockStepData step) {
    final ThemeData theme = Theme.of(context);
    final bool meetsFloor = step.uiComplianceRate >= 0.95;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onStepTapped(step),
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  FilterChip(
                    selected: step.isCompleted,
                    label: Text(step.isCompleted ? 'Pass' : 'Fail'),
                    avatar: Icon(
                      step.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 18,
                    ),
                    onSelected: (_) {},
                    showCheckmark: false,
                    backgroundColor: step.isCompleted
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: step.isCompleted
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: meetsFloor
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Compliance: ${(step.uiComplianceRate * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: meetsFloor
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    step.id,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
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

  void _onStepTapped(_MockStepData step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  step.title,
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(step.id, style: Theme.of(ctx).textTheme.labelMedium),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(
                    step.isCompleted ? Icons.check_circle : Icons.cancel,
                    color: step.isCompleted
                        ? Theme.of(ctx).colorScheme.primary
                        : Theme.of(ctx).colorScheme.error,
                  ),
                  title: const Text('Status'),
                  subtitle: Text(step.isCompleted ? 'Pass' : 'Fail'),
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('UI Compliance Rate'),
                  subtitle: Text(
                    '${(step.uiComplianceRate * 100).toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                  label: const Text('Close Details'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Inputs',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Polling Interval (seconds)',
                  hintText: '30',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Automated Liveness Handshake'),
                subtitle: const Text('Monitors every 30 seconds'),
                value: true,
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration saved.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Configuration'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
