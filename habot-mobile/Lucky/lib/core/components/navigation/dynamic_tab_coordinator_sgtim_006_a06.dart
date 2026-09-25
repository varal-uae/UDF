// SGTIM-006-A06 — DynamicTabCoordinator: Horizontal tab navigation with swipe gestures.
// Provides a responsive tab bar and page view controller with Material 3 styling, URL path sync fallback, and persistent search filter state.

import 'package:flutter/material.dart';

/// Mock data representing tab categories for demonstration purposes.
class _MockTabCategory {
  final String id;
  final String label;
  final int itemCount;
  final List<Map<String, dynamic>> records;

  const _MockTabCategory({
    required this.id,
    required this.label,
    required this.itemCount,
    required this.records,
  });
}

const List<_MockTabCategory> _kMockCategories = [
  _MockTabCategory(
    id: 'metrics_overview',
    label: 'Overview',
    itemCount: 124,
    records: [
      {'id': '1', 'name': 'Total Users', 'value': '12,450'},
      {'id': '2', 'name': 'Active Sessions', 'value': '3,210'},
    ],
  ),
  _MockTabCategory(
    id: 'metrics_performance',
    label: 'Performance',
    itemCount: 89,
    records: [
      {'id': '3', 'name': 'Avg Load Time', 'value': '1.2s'},
      {'id': '4', 'name': 'Error Rate', 'value': '0.05%'},
    ],
  ),
  _MockTabCategory(
    id: 'metrics_engagement',
    label: 'Engagement',
    itemCount: 210,
    records: [
      {'id': '5', 'name': 'Daily Active', 'value': '8,900'},
      {'id': '6', 'name': 'Retention', 'value': '78%'},
    ],
  ),
  _MockTabCategory(
    id: 'metrics_revenue',
    label: 'Revenue',
    itemCount: 45,
    records: [
      {'id': '7', 'name': 'MRR', 'value': '\$45,000'},
      {'id': '8', 'name': 'ARPU', 'value': '\$12.50'},
    ],
  ),
];

/// A reusable dynamic tab coordinator widget that manages horizontal tabs
/// linked to swipeable page views. Implements mistake-proofing by retaining
/// search filters across tab changes and falling back to the first tab on errors.
class DynamicTabCoordinator extends StatefulWidget {
  final String? initialRoutePath;
  final ValueChanged<String>? onRoutePathChanged;

  const DynamicTabCoordinator({
    super.key,
    this.initialRoutePath,
    this.onRoutePathChanged,
  });

  @override
  State<DynamicTabCoordinator> createState() => _DynamicTabCoordinatorState();
}

class _DynamicTabCoordinatorState extends State<DynamicTabCoordinator>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  String _activeSearchFilter = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Self-chasing: Default to first tab if route path is invalid or missing
    int initialIndex = 0;
    if (widget.initialRoutePath != null) {
      final index = _kMockCategories.indexWhere(
        (c) => c.id == widget.initialRoutePath,
      );
      if (index != -1) {
        initialIndex = index;
      }
    }

    _tabController = TabController(
      length: _kMockCategories.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final selectedCategory = _kMockCategories[_tabController.index];
      widget.onRoutePathChanged?.call(selectedCategory.id);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      children: [
        // Pinned header area containing search and tabs
        Material(
          elevation: 2,
          color: theme.colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mistake-Proofing: Persistent search filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search across tabs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _activeSearchFilter = value.toLowerCase();
                    });
                  },
                ),
              ),
              // Responsive Tab Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return TabBar(
                    controller: _tabController,
                    isScrollable: !isDesktop,
                    tabAlignment: isDesktop ? TabAlignment.fill : TabAlignment.start,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3.0,
                    labelColor: theme.colorScheme.onPrimaryContainer,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    // Bold, high-contrast button background tones for active tab
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.0, // 14sp standard
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: _kMockCategories.map((category) {
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(category.label),
                            if (isDesktop) ...[
                              const SizedBox(width: 6),
                              // Embed clear item count indicators on wide desktop screens
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category.itemCount.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        // Swipeable Page View linked to TabController
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: _kMockCategories.map((category) {
              // Apply search filter to mock records
              final filteredRecords = category.records.where((record) {
                if (_activeSearchFilter.isEmpty) return true;
                return record['name'].toString().toLowerCase().contains(_activeSearchFilter) ||
                    record['value'].toString().toLowerCase().contains(_activeSearchFilter);
              }).toList();

              return _TabContentPanel(
                category: category,
                records: filteredRecords,
                isDesktop: isDesktop,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TabContentPanel extends StatelessWidget {
  final _MockTabCategory category;
  final List<Map<String, dynamic>> records;
  final bool isDesktop;

  const _TabContentPanel({
    required this.category,
    required this.records,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No matching records found.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              record['name'] as String,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Category: ${category.label}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Text(
              record['value'] as String,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
