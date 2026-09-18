// GEN-01159 — M3 Primary Tab Bar Component.
// Integrates a Material 3 primary tab bar with responsive layout, dynamic color, and mock telemetry data.

import 'package:flutter/material.dart';

/// Mock data representing Information Architecture Task Success Rate metrics.
class _MockTabMetrics {
  final String tabId;
  final String label;
  final double successRate;
  final String qualitativeOutput;

  const _MockTabMetrics({
    required this.tabId,
    required this.label,
    required this.successRate,
    required this.qualitativeOutput,
  });
}

const List<_MockTabMetrics> _kMockMetrics = [
  _MockTabMetrics(tabId: 'tab_1', label: 'Overview', successRate: 0.95, qualitativeOutput: 'Good'),
  _MockTabMetrics(tabId: 'tab_2', label: 'Analytics', successRate: 0.82, qualitativeOutput: 'Average'),
  _MockTabMetrics(tabId: 'tab_3', label: 'Settings', successRate: 0.75, qualitativeOutput: 'Poor'),
  _MockTabMetrics(tabId: 'tab_4', label: 'Telemetry', successRate: 0.98, qualitativeOutput: 'Good'),
];

/// M3 Primary Tab Bar component implementing GEN-01159.
/// Responsive single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Uses M3 Elevated Cards Level 2 (3dp) and Status Chips for health indicators.
class M3PrimaryTabBarGen01159 extends StatefulWidget {
  const M3PrimaryTabBarGen01159({super.key});

  @override
  State<M3PrimaryTabBarGen01159> createState() => _M3PrimaryTabBarGen01159State();
}

class _M3PrimaryTabBarGen01159State extends State<M3PrimaryTabBarGen01159>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kMockMetrics.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Good':
        return colorScheme.primary;
      case 'Average':
        return colorScheme.tertiary;
      case 'Poor':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 840;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // M3 Primary Tab Bar
        Container(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: !isDesktop,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            tabs: _kMockMetrics
                .map((m) => Tab(
                      height: 48, // 48x48dp touch target compliance
                      text: m.label,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Tab Content Area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _kMockMetrics.map((metric) {
              return _buildTabContent(context, metric, isDesktop);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    _MockTabMetrics metric,
    bool isDesktop,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // M3 Elevated Card Level 2 (3dp elevation)
    final cardWidget = Card(
      elevation: 3,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  metric.label,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                // M3 Status Chip
                Chip(
                  label: Text(
                    metric.qualitativeOutput,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: _getStatusColor(context, metric.qualitativeOutput),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Information Architecture Task Success Rate',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(metric.successRate * 100).toStringAsFixed(1)}%',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: metric.successRate,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(context, metric.qualitativeOutput),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Floor Boundary: 0.8 | Optimal Target: 0.95 | Ceiling: 1.0',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );

    // Responsive layout: single-column on mobile, multi-column on desktop
    if (isDesktop) {
      return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
        padding: const EdgeInsets.all(16),
        children: List.generate(3, (_) => cardWidget),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: cardWidget,
    );
  }
}