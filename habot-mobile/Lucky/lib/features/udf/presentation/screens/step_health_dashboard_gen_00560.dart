// GEN-00560 — UDF Engineering Console Step Health Dashboard.
// Displays BigQuery lineage/orphan-sweeper step health using M3 elevated cards, status chips, responsive single/multi-column layout, polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

class StepHealthDashboardGen00560 extends StatefulWidget {
  const StepHealthDashboardGen00560({super.key});

  @override
  State<StepHealthDashboardGen00560> createState() => _StepHealthDashboardGen00560State();
}

class _StepHealthDashboardGen00560State extends State<StepHealthDashboardGen00560> {
  Timer? _pollTimer;
  bool _isRefreshing = false;
  List<StepHealthItem> _items = const [
    StepHealthItem(
      title: 'Provision BigQuery Warehouse',
      status: StepHealthStatus.success,
      detail: 'Lineage engine active',
    ),
    StepHealthItem(
      title: 'Orphan Sweeper SQL',
      status: StepHealthStatus.warning,
      detail: 'parent_id null check pending',
    ),
    StepHealthItem(
      title: 'CI/CD Validation Gate',
      status: StepHealthStatus.error,
      detail: 'Gate failed: runbook doc missing',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      _items = List.of(_items);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(ColorScheme cs, StepHealthStatus status) {
    switch (status) {
      case StepHealthStatus.success:
        return Colors.green;
      case StepHealthStatus.warning:
        return Colors.orange;
      case StepHealthStatus.error:
        return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        actions: [
          IconButton(
            onPressed: _openConfig,
            icon: const Icon(Icons.settings),
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 3 : 2;

            if (isMobile) {
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _StepHealthCard(
                    item: item,
                    statusColor: _statusColor(cs, item.status),
                    onTap: () => _showDetails(item),
                  );
                },
              );
            }

            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _StepHealthCard(
                  item: item,
                  statusColor: _statusColor(cs, item.status),
                  onTap: () => _showDetails(item),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openConfig,
        icon: const Icon(Icons.tune),
        label: const Text('Configure'),
      ),
    );
  }

  Future<void> _openConfig() async {
    final controller = TextEditingController(text: 'orphan_sweeper.sql');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BigQuery Lineage Config',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'SQL artifact',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration saved')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDetails(StepHealthItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.detail),
            const SizedBox(height: 16),
            const Text('Read-only KPI card. Deep-link drill-down available.'),
          ],
        ),
      ),
    );
  }
}

class _StepHealthCard extends StatelessWidget {
  const _StepHealthCard({
    required this.item,
    required this.statusColor,
    required this.onTap,
  });

  final StepHealthItem item;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(item.status.label),
                    backgroundColor: statusColor.withAlpha(38),
                    labelStyle: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(color: statusColor.withAlpha(102)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.detail,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text('48x48dp target', style: theme.textTheme.labelSmall),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum StepHealthStatus { success, warning, error }

extension StepHealthStatusX on StepHealthStatus {
  String get label {
    switch (this) {
      case StepHealthStatus.success:
        return 'Healthy';
      case StepHealthStatus.warning:
        return 'Warning';
      case StepHealthStatus.error:
        return 'Error';
      default:
        return 'Unknown';
    }
  }
}

class StepHealthItem {
  const StepHealthItem({
    required this.title,
    required this.status,
    required this.detail,
  });

  final String title;
  final StepHealthStatus status;
  final String detail;
}