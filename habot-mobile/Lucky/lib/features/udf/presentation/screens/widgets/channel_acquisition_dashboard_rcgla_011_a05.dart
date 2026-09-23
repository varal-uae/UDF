// RCGLA-011-A05 — Regional Channel Acquisition Data Isolation Dashboard.
// Implements a Material 3 tabbed dashboard for viewing isolated cost-per-acquisition variables across neighborhood clusters with adaptive grid lists, empty state handling, and local mock data matrix routing.

import 'package:flutter/material.dart';

enum MatrixType { online, offline }

enum MatrixStatus { active, paused, completed }

class AcquisitionMatrix {
  final String id;
  final String region;
  final String channel;
  final MatrixType type;
  final MatrixStatus status;
  final double costPerAcquisition;
  final double lifespanCostRatio;
  final int impressions;
  final DateTime timestamp;

  const AcquisitionMatrix({
    required this.id,
    required this.region,
    required this.channel,
    required this.type,
    required this.status,
    required this.costPerAcquisition,
    required this.lifespanCostRatio,
    required this.impressions,
    required this.timestamp,
  });
}

class MockChannelRepository {
  static const List<AcquisitionMatrix> matrices = [
    AcquisitionMatrix(
      id: 'MAT-001',
      region: 'Downtown Dubai',
      channel: 'Print Flyers',
      type: MatrixType.offline,
      status: MatrixStatus.active,
      costPerAcquisition: 45.50,
      lifespanCostRatio: 4.2,
      impressions: 12000,
      timestamp: null as dynamic,
    ),
    AcquisitionMatrix(
      id: 'MAT-002',
      region: 'Abu Dhabi Marina',
      channel: 'Social Ads',
      type: MatrixType.online,
      status: MatrixStatus.active,
      costPerAcquisition: 12.30,
      lifespanCostRatio: 1.8,
      impressions: 85000,
      timestamp: null as dynamic,
    ),
    AcquisitionMatrix(
      id: 'MAT-003',
      region: 'Sharjah Industrial',
      channel: 'Billboards',
      type: MatrixType.offline,
      status: MatrixStatus.paused,
      costPerAcquisition: 120.00,
      lifespanCostRatio: 5.5,
      impressions: 3000,
      timestamp: null as dynamic,
    ),
    AcquisitionMatrix(
      id: 'MAT-004',
      region: 'Al Ain Center',
      channel: 'Search PPC',
      type: MatrixType.online,
      status: MatrixStatus.completed,
      costPerAcquisition: 8.75,
      lifespanCostRatio: 1.2,
      impressions: 42000,
      timestamp: null as dynamic,
    ),
  ];

  static List<AcquisitionMatrix> getByType(MatrixType type) {
    return matrices.where((m) => m.type == type).toList();
  }

  static List<String> get regions => matrices.map((m) => m.region).toSet().toList();
}

class ChannelAcquisitionDashboardRcgla011A05 extends StatefulWidget {
  const ChannelAcquisitionDashboardRcgla011A05({super.key});

  @override
  State<ChannelAcquisitionDashboardRcgla011A05> createState() => _ChannelAcquisitionDashboardRcgla011A05State();
}

class _ChannelAcquisitionDashboardRcgla011A05State extends State<ChannelAcquisitionDashboardRcgla011A05>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedRegion = MockChannelRepository.regions.isNotEmpty ? MockChannelRepository.regions.first : null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(MatrixStatus status, ColorScheme colorScheme) {
    switch (status) {
      case MatrixStatus.active:
        return colorScheme.primary;
      case MatrixStatus.paused:
        return colorScheme.tertiary;
      case MatrixStatus.completed:
        return colorScheme.outline;
    }
  }

  bool _isSafetyRuleBroken(double ratio) => ratio > 3.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final regions = MockChannelRepository.regions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Center'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Offline Acquisition'),
            Tab(text: 'Online Acquisition'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (regions.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: regions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final region = regions[index];
                  final isSelected = region == _selectedRegion;
                  return FilterChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedRegion = region),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    selectedColor: colorScheme.secondaryContainer,
                  );
                },
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMatrixGrid(MatrixType.offline, theme, colorScheme),
                _buildMatrixGrid(MatrixType.online, theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixGrid(MatrixType type, ThemeData theme, ColorScheme colorScheme) {
    var items = MockChannelRepository.getByType(type);
    if (_selectedRegion != null) {
      items = items.where((m) => m.region == _selectedRegion).toList();
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.campaign_outlined, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'No Active Campaign Records Found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final matrix = items[index];
            final isBroken = _isSafetyRuleBroken(matrix.lifespanCostRatio);

            return Card(
              elevation: 1, // md.sys.elevation.level1
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isBroken ? colorScheme.error : _getStatusColor(matrix.status, colorScheme),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (isBroken) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Alert: ${matrix.channel} in ${matrix.region} breached the 3:1 safety rule (Current: ${matrix.lifespanCostRatio.toStringAsFixed(1)}:1)',
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
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
                              matrix.channel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(matrix.status, colorScheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              matrix.status.name.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getStatusColor(matrix.status, colorScheme),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        matrix.region,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CPA',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '\$${matrix.costPerAcquisition.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'LTV:CAC Ratio',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${matrix.lifespanCostRatio.toStringAsFixed(1)}:1',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isBroken ? colorScheme.error : colorScheme.onSurface,
                                  fontWeight: isBroken ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
