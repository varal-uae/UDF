// SGTIM-006-A09 — DynamicTabCoordinator: Horizontal tab navigation with swipe gestures.
// Provides a reusable tab bar and page view controller that syncs horizontal swipes with tab selection, preserves search filters across tab changes, and falls back to the first tab on invalid routes.

import 'package:flutter/material.dart';

/// Mock data representing tab categories and item counts.
class _MockTabCategory {
  final String id;
  final String label;
  final int itemCount;

  const _MockTabCategory({
    required this.id,
    required this.label,
    required this.itemCount,
  });
}

const List<_MockTabCategory> _mockCategories = [
  _MockTabCategory(id: 'metrics', label: 'Metrics', itemCount: 124),
  _MockTabCategory(id: 'reports', label: 'Reports', itemCount: 38),
  _MockTabCategory(id: 'analytics', label: 'Analytics', itemCount: 87),
  _MockTabCategory(id: 'settings', label: 'Settings', itemCount: 12),
];

/// A reusable dynamic tab coordinator that binds horizontal swipe gestures
/// to a tab bar, ensuring smooth transitions and filter preservation.
class DynamicTabCoordinator extends StatefulWidget {
  /// Optional external search filter state to preserve across tab switches.
  final ValueNotifier<String>? searchFilterNotifier;

  /// Callback when a tab is selected or swiped to.
  final ValueChanged<int>? onTabChanged;

  /// Builder for the content of each tab page.
  final Widget Function(BuildContext context, int index, String categoryId)? pageBuilder;

  const DynamicTabCoordinator({
    super.key,
    this.searchFilterNotifier,
    this.onTabChanged,
    this.pageBuilder,
  });

  @override
  State<DynamicTabCoordinator> createState() => _DynamicTabCoordinatorState();
}

class _DynamicTabCoordinatorState extends State<DynamicTabCoordinator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentSearchFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _mockCategories.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);

    if (widget.searchFilterNotifier != null) {
      _currentSearchFilter = widget.searchFilterNotifier!.value;
      widget.searchFilterNotifier!.addListener(_syncSearchFilter);
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
      // Simulate URL path update / routing fallback logic
      _updateRoutePath(_tabController.index);
    }
  }

  void _syncSearchFilter() {
    setState(() {
      _currentSearchFilter = widget.searchFilterNotifier?.value ?? '';
    });
  }

  void _updateRoutePath(int index) {
    // Self-chasing Poka-Yoke: if index is out of bounds, default to 0.
    if (index < 0 || index >= _mockCategories.length) {
      _tabController.animateTo(0);
      return;
    }
    // In a real app, this would push a named route or update GoRouter state.
    // e.g., context.go('/dashboard/${_mockCategories[index].id}?search=$_currentSearchFilter');
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    if (widget.searchFilterNotifier != null) {
      widget.searchFilterNotifier!.removeListener(_syncSearchFilter);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return Column(
      children: [
        // Pinned tab control row below headers
        Material(
          color: theme.colorScheme.surface,
          elevation: 2.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return TabBar(
                controller: _tabController,
                isScrollable: !isDesktop,
                tabAlignment: isDesktop ? TabAlignment.fill : TabAlignment.start,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3.0,
                labelColor: theme.colorScheme.onPrimaryContainer,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14.0, // 14sp standard
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                tabs: _mockCategories.map((category) {
                  return _buildTab(category, isDesktop, theme);
                }).toList(),
              );
            },
          ),
        ),
        // Horizontal page gesture controller (swipeable area)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: List.generate(_mockCategories.length, (index) {
              if (widget.pageBuilder != null) {
                return widget.pageBuilder!(
                  context,
                  index,
                  _mockCategories[index].id,
                );
              }
              return _DefaultTabPage(
                category: _mockCategories[index],
                searchFilter: _currentSearchFilter,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(_MockTabCategory category, bool isDesktop, ThemeData theme) {
    return Tab(
      height: 48.0,
      child: Row(
        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              category.label,
              overflow: TextOverflow.visible,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${category.itemCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Default fallback page when no custom pageBuilder is provided.
class _DefaultTabPage extends StatelessWidget {
  final _MockTabCategory category;
  final String searchFilter;

  const _DefaultTabPage({
    required this.category,
    required this.searchFilter,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category: ${category.label}',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Total Items: ${category.itemCount}',
            style: theme.textTheme.bodyMedium,
          ),
          if (searchFilter.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Chip(
              avatar: const Icon(Icons.filter_alt, size: 16),
              label: Text('Active Filter: $searchFilter'),
              backgroundColor: theme.colorScheme.secondaryContainer,
            ),
          ],
          const SizedBox(height: 24.0),
          Expanded(
            child: ListView.builder(
              itemCount: category.itemCount > 10 ? 10 : category.itemCount,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text('${category.label} Item ${index + 1}'),
                    subtitle: Text('ID: ${category.id}_$index'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
