// GEN-01688 — Whitespace Buffer Layout Widget for Engineering Console.
// Implements M3 Elevated Cards with safe whitespace buffers, responsive single/multi-column layout, 48x48dp touch targets, and mock KPI data.

import 'package:flutter/material.dart';

enum _ComplianceLevel { high, medium, low }

class _MockKpiData {
  final String title;
  final String metricName;
  final double value;
  final _ComplianceLevel level;
  final String lastUpdated;

  const _MockKpiData({
    required this.title,
    required this.metricName,
    required this.value,
    required this.level,
    required this.lastUpdated,
  });
}

const List<_MockKpiData> _mockSteps = [
  _MockKpiData(
    title: 'Whitespace Buffer Validation',
    metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
    value: 99.5,
    level: _ComplianceLevel.high,
    lastUpdated: '2026-09-23T10:00:00Z',
  ),
  _MockKpiData(
    title: 'CI/CD Pipeline Gate',
    metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
    value: 96.2,
    level: _ComplianceLevel.medium,
    lastUpdated: '2026-09-23T09:45:00Z',
  ),
  _MockKpiData(
    title: 'Liveness Handshake Monitor',
    metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
    value: 88.0,
    level: _ComplianceLevel.low,
    lastUpdated: '2026-09-23T09:30:00Z',
  ),
];

class WhitespaceBufferCardGen01688 extends StatefulWidget {
  const WhitespaceBufferCardGen01688({super.key});

  @override
  State<WhitespaceBufferCardGen01688> createState() => _WhitespaceBufferCardGen01688State();
}

class _WhitespaceBufferCardGen01688State extends State<WhitespaceBufferCardGen01688> {
  bool _isRefreshing = false;

  Future<void> _simulateRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data synchronized successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Color _getLevelColor(_ComplianceLevel level, ThemeData theme) {
    switch (level) {
      case _ComplianceLevel.high:
        return theme.colorScheme.primary;
      case _ComplianceLevel.medium:
        return theme.colorScheme.tertiary;
      case _ComplianceLevel.low:
        return theme.colorScheme.error;
    }
  }

  String _getLevelLabel(_ComplianceLevel level) {
    switch (level) {
      case _ComplianceLevel.high:
        return 'High';
      case _ComplianceLevel.medium:
        return 'Medium';
      case _ComplianceLevel.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _simulateRefresh,
            icon: const Icon(Icons.sync),
            tooltip: 'Manual Sync',
            iconSize: 24,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _simulateRefresh,
        child: _isRefreshing
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    // Safe whitespace buffer to prevent overlaps
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        if (isDesktop) {
                          return SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                              childAspectRatio: 1.2,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildKpiCard(theme, _mockSteps[index]),
                              childCount: _mockSteps.length,
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              // Safe whitespace buffer between related items
                              padding: EdgeInsets.only(bottom: index < _mockSteps.length - 1 ? 24.0 : 0.0),
                              child: _buildKpiCard(theme, _mockSteps[index]),
                            ),
                            childCount: _mockSteps.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildKpiCard(ThemeData theme, _MockKpiData data) {
    final levelColor = _getLevelColor(data.level, theme);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showConfigBottomSheet(theme, data),
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(
                      _getLevelLabel(data.level),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: levelColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Whitespace buffer
              Text(
                data.metricName,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                '${data.value.toStringAsFixed(1)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 16), // Whitespace buffer
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    data.lastUpdated,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(ThemeData theme, _MockKpiData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
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
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Configuration Details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Step: ${data.title}', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Metric: ${data.metricName}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Current Value: ${data.value}%', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Status: ${_getLevelLabel(data.level)}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
