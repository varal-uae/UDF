// GEN-04280 — Data Lineage Validation Screen.
// Displays M3 Elevated Cards with status chips for mobile UI screens, data lineage paths, and backend functions validation. Single-column on mobile (<600dp), multi-column on desktop (>=840dp). Background polling every 30 seconds with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum ValidationStatus { pass, fail }

class ValidationItem {
  final String id;
  final String name;
  final String category;
  final ValidationStatus status;
  final double orphanRecordRate;
  final DateTime lastChecked;

  const ValidationItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.orphanRecordRate,
    required this.lastChecked,
  });
}

class MockValidationRepository {
  static List<ValidationItem> getMockData() {
    final now = DateTime.now();
    return [
      ValidationItem(
        id: 'UI-001',
        name: 'Authentication Screen',
        category: 'Mobile UI Screen',
        status: ValidationStatus.pass,
        orphanRecordRate: 0.0,
        lastChecked: now.subtract(const Duration(seconds: 15)),
      ),
      ValidationItem(
        id: 'UI-002',
        name: 'Dashboard Screen',
        category: 'Mobile UI Screen',
        status: ValidationStatus.pass,
        orphanRecordRate: 0.5,
        lastChecked: now.subtract(const Duration(seconds: 10)),
      ),
      ValidationItem(
        id: 'DL-001',
        name: 'User Event Stream',
        category: 'Data Lineage Path',
        status: ValidationStatus.fail,
        orphanRecordRate: 3.2,
        lastChecked: now.subtract(const Duration(seconds: 5)),
      ),
      ValidationItem(
        id: 'DL-002',
        name: 'Telemetry Pipeline',
        category: 'Data Lineage Path',
        status: ValidationStatus.pass,
        orphanRecordRate: 0.1,
        lastChecked: now.subtract(const Duration(seconds: 20)),
      ),
      ValidationItem(
        id: 'BE-001',
        name: 'validateSession()',
        category: 'Backend Function',
        status: ValidationStatus.pass,
        orphanRecordRate: 0.0,
        lastChecked: now.subtract(const Duration(seconds: 8)),
      ),
      ValidationItem(
        id: 'BE-002',
        name: 'syncLineageRecords()',
        category: 'Backend Function',
        status: ValidationStatus.fail,
        orphanRecordRate: 2.8,
        lastChecked: now.subtract(const Duration(seconds: 12)),
      ),
    ];
  }
}

class DataLineageValidationScreenGen04280 extends StatefulWidget {
  const DataLineageValidationScreenGen04280({super.key});

  @override
  State<DataLineageValidationScreenGen04280> createState() => _DataLineageValidationScreenGen04280State();
}

class _DataLineageValidationScreenGen04280State extends State<DataLineageValidationScreenGen04280> {
  List<ValidationItem> _items = [];
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
      _items = MockValidationRepository.getMockData();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _loadData();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Validation data synced successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  int get _passCount => _items.where((e) => e.status == ValidationStatus.pass).length;
  int get _failCount => _items.where((e) => e.status == ValidationStatus.fail).length;
  double get _overallOrphanRate {
    if (_items.isEmpty) return 0.0;
    final total = _items.fold<double>(0.0, (sum, item) => sum + item.orphanRecordRate);
    return total / _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EC Validation Console'),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Manual Sync',
              onPressed: _onRefresh,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: _buildSummaryCards(theme),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Validation Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _buildItemsGrid(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;
        final cards = [
          _buildKpiCard(
            theme,
            title: 'Total Checks',
            value: '${_items.length}',
            icon: Icons.checklist_rounded,
            color: theme.colorScheme.primary,
          ),
          _buildKpiCard(
            theme,
            title: 'Passed',
            value: '$_passCount',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _buildKpiCard(
            theme,
            title: 'Failed',
            value: '$_failCount',
            icon: Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          _buildKpiCard(
            theme,
            title: 'Avg Orphan Rate',
            value: '${_overallOrphanRate.toStringAsFixed(2)}%',
            icon: Icons.analytics_outlined,
            color: _overallOrphanRate <= 2.0 ? Colors.green : theme.colorScheme.error,
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: card))).toList(),
          );
        }
        return Column(
          children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: card)).toList(),
        );
      },
    );
  }

  Widget _buildKpiCard(ThemeData theme, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid() {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.crossAxisExtent >= 840;
        final crossAxisCount = isDesktop ? 2 : 1;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: isDesktop ? 3.0 : 2.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildValidationCard(_items[index]),
            childCount: _items.length,
          ),
        );
      },
    );
  }

  Widget _buildValidationCard(ValidationItem item) {
    final theme = Theme.of(context);
    final isPass = item.status == ValidationStatus.pass;
    final statusColor = isPass ? Colors.green : theme.colorScheme.error;
    final statusLabel = isPass ? 'PASS' : 'FAIL';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailBottomSheet(item),
        borderRadius: BorderRadius.circular(12),
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
                      item.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Orphan Rate: ${item.orphanRecordRate.toStringAsFixed(2)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.orphanRecordRate > 2.0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ID: ${item.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontFamily: 'monospace',
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

  void _showDetailBottomSheet(ValidationItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Validation Detail', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildDetailRow('Name', item.name),
              _buildDetailRow('Category', item.category),
              _buildDetailRow('ID', item.id),
              _buildDetailRow('Status', item.status == ValidationStatus.pass ? 'Pass' : 'Fail'),
              _buildDetailRow('Orphan Record Rate', '${item.orphanRecordRate.toStringAsFixed(2)}%'),
              _buildDetailRow('Threshold', '≤ 2% (Tolerable)'),
              _buildDetailRow('Last Checked', item.lastChecked.toIso8601String()),
              _buildDetailRow('Standard', 'DAMA-DMBOK Data Lineage'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
