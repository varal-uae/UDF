// SGTIM-006-A11 — DynamicTabCoordinator: Horizontal tab navigation with swipe gestures.
// Provides a responsive, Material 3 compliant tab bar and page view controller that syncs horizontal swipes with tab selection, preserves search filters across tab changes, and adapts layout between mobile and desktop viewports.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level data fields for demonstration.
class _MockTabData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String category;
  final int itemCount;

  const _MockTabData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.category,
    required this.itemCount,
  });
}

final List<_MockTabData> _mockDataset = [
  _MockTabData(
    stepExecutionId: 'EXEC-001',
    executionStatus: 'Completed',
    executionTimestamp: DateTime(2026, 9, 25, 10, 0),
    stepOutcome: 'Success',
    userId: 'USR-101',
    category: 'Metrics',
    itemCount: 42,
  ),
  _MockTabData(
    stepExecutionId: 'EXEC-002',
    executionStatus: 'Pending',
    executionTimestamp: DateTime(2026, 9, 25, 11, 30),
    stepOutcome: 'In Progress',
    userId: 'USR-102',
    category: 'Analytics',
    itemCount: 18,
  ),
  _MockTabData(
    stepExecutionId: 'EXEC-003',
    executionStatus: 'Failed',
    executionTimestamp: DateTime(2026, 9, 24, 15, 45),
    stepOutcome: 'Error',
    userId: 'USR-103',
    category: 'Reports',
    itemCount: 7,
  ),
  _MockTabData(
    stepExecutionId: 'EXEC-004',
    executionStatus: 'Completed',
    executionTimestamp: DateTime(2026, 9, 23, 9, 15),
    stepOutcome: 'Success',
    userId: 'USR-104',
    category: 'Settings',
    itemCount: 3,
  ),
];

/// A reusable dynamic tab navigation container manager.
/// Converts React Native touchmove gesture listeners into Flutter's native [PageView] and [TabController] synchronization.
class DynamicTabCoordinator extends StatefulWidget {
  final String? initialRoutePath;
  final ValueChanged<int>? onTabChanged;

  const DynamicTabCoordinator({
    super.key,
    this.initialRoutePath,
    this.onTabChanged,
  });

  @override
  State<DynamicTabCoordinator> createState() => _DynamicTabCoordinatorState();
}

class _DynamicTabCoordinatorState extends State<DynamicTabCoordinator>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _currentIndex;
  
  // Mistake-Proofing (Poka-Yoke): Keep active table search filters applied when changing tabs.
  final Map<int, String> _searchFilters = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = _mockDataset.map((e) => e.category).toSet().toList();

  @override
  void initState() {
    super.initState();
    _currentIndex = _resolveInitialIndex(widget.initialRoutePath);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  int _resolveInitialIndex(String? routePath) {
    if (routePath == null || routePath.isEmpty) return 0;
    // Self-Chasing: If a tab URL code path contains errors, default back to the first category view.
    final index = _categories.indexWhere(
      (c) => c.toLowerCase() == routePath.toLowerCase(),
    );
    return index == -1 ? 0 : index;
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentIndex = _tabController.index;
      // Restore filter for the newly selected tab
      _searchController.text = _searchFilters[_currentIndex] ?? '';
    });
    widget.onTabChanged?.call(_currentIndex);
  }

  void _onSearchChanged(String value) {
    _searchFilters[_currentIndex] = value;
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return Column(
      children: [
        // Dashboard / Interface Implication: Tab control rows stay pinned cleanly below headers.
        Material(
          color: theme.colorScheme.surface,
          elevation: 2.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mobile-First & Responsive UI: Convert floating mobile buttons into permanent top toolbar options across desktop rows.
              if (isDesktop)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_categories.length, (index) {
                      final bool isActive = _currentIndex == index;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              foregroundColor: isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onPressed: () => _tabController.animateTo(index),
                            child: Text(
                              '${_categories[index]} (${_getItemCount(index)})',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              else
                // Responsive UX/UI Design: Keep tab labels large and readable (14sp standard) across small touch viewports.
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                  ),
                  tabs: _categories.map((category) {
                    final index = _categories.indexOf(category);
                    return Tab(
                      text: '$category (${_getItemCount(index)})',
                    );
                  }).toList(),
                ),
              // Search filter preserved across tabs
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search within ${_categories[_currentIndex]}...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // AISS Translation: Bind touchmove gesture event listeners to track sliding actions across panels.
        // In Flutter, PageView natively handles horizontal swipe gestures, replacing React Native PanResponder/touchmove.
        Expanded(
          child: PageView.builder(
            itemCount: _categories.length,
            controller: PageController(initialPage: _currentIndex),
            onPageChanged: (index) {
              _tabController.animateTo(index);
            },
            itemBuilder: (context, index) {
              return _buildTabPage(context, index, theme);
            },
          ),
        ),
      ],
    );
  }

  int _getItemCount(int index) {
    final category = _categories[index];
    return _mockDataset.where((d) => d.category == category).length;
  }

  Widget _buildTabPage(BuildContext context, int index, ThemeData theme) {
    final category = _categories[index];
    final filter = _searchFilters[index]?.toLowerCase() ?? '';
    
    final items = _mockDataset.where((d) {
      if (d.category != category) return false;
      if (filter.isNotEmpty && !d.stepOutcome.toLowerCase().contains(filter)) {
        return false;
      }
      return true;
    }).toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No records found for $category.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = items[i];
        return ListTile(
          title: Text(
            item.stepExecutionId,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${item.executionStatus}'),
              Text('Outcome: ${item.stepOutcome}'),
              Text('User: ${item.userId}'),
              Text('Time: ${item.executionTimestamp.toIso8601String()}'),
            ],
          ),
          trailing: Chip(
            label: Text(item.executionStatus),
            backgroundColor: item.executionStatus == 'Completed'
                ? Colors.green.shade100
                : item.executionStatus == 'Failed'
                    ? Colors.red.shade100
                    : Colors.orange.shade100,
          ),
          isThreeLine: true,
        );
      },
    );
  }
}
