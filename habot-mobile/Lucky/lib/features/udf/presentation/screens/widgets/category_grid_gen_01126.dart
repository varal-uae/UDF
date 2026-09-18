// GEN-01126 — Category Navigation Grid Widget.
// Packages category navigation widgets into a reusable M3 grid with responsive layout, mock data, and discoverability metrics.

import 'package:flutter/material.dart';

enum DiscoverabilityStatus { good, average, poor }

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final int timeToFindSeconds;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.timeToFindSeconds,
  });

  DiscoverabilityStatus get status {
    if (timeToFindSeconds < 3) return DiscoverabilityStatus.good;
    if (timeToFindSeconds < 10) return DiscoverabilityStatus.average;
    return DiscoverabilityStatus.poor;
  }
}

class CategoryGridMockRepository {
  static const List<CategoryItem> categories = [
    CategoryItem(id: 'cat_001', name: 'Documents', icon: Icons.description_outlined, timeToFindSeconds: 2),
    CategoryItem(id: 'cat_002', name: 'Approvals', icon: Icons.check_circle_outline, timeToFindSeconds: 5),
    CategoryItem(id: 'cat_003', name: 'Analytics', icon: Icons.analytics_outlined, timeToFindSeconds: 8),
    CategoryItem(id: 'cat_004', name: 'Settings', icon: Icons.settings_outlined, timeToFindSeconds: 12),
    CategoryItem(id: 'cat_005', name: 'Users', icon: Icons.people_outline, timeToFindSeconds: 1),
    CategoryItem(id: 'cat_006', name: 'Billing', icon: Icons.receipt_long_outlined, timeToFindSeconds: 4),
  ];
}

class CategoryGridGen01126 extends StatefulWidget {
  const CategoryGridGen01126({super.key});

  @override
  State<CategoryGridGen01126> createState() => _CategoryGridGen01126State();
}

class _CategoryGridGen01126State extends State<CategoryGridGen01126> {
  late List<CategoryItem> _categories;

  @override
  void initState() {
    super.initState();
    _categories = CategoryGridMockRepository.categories;
  }

  void _refreshData() {
    setState(() {
      _categories = List.from(CategoryGridMockRepository.categories);
    });
  }

  Color _statusColor(DiscoverabilityStatus status, ThemeData theme) {
    switch (status) {
      case DiscoverabilityStatus.good:
        return theme.colorScheme.primary;
      case DiscoverabilityStatus.average:
        return theme.colorScheme.tertiary;
      case DiscoverabilityStatus.poor:
        return theme.colorScheme.error;
    }
  }

  String _statusLabel(DiscoverabilityStatus status) {
    switch (status) {
      case DiscoverabilityStatus.good:
        return 'Good';
      case DiscoverabilityStatus.average:
        return 'Average';
      case DiscoverabilityStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 840;
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: isMobile ? 3.0 : 2.5,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final item = _categories[index];
          return _CategoryCard(
            item: item,
            statusColor: _statusColor(item.status, theme),
            statusLabel: _statusLabel(item.status),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final Color statusColor;
  final String statusLabel;

  const _CategoryCard({
    required this.item,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigating to ${item.name}...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 32.0,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Time-to-Find: ${item.timeToFindSeconds}s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: statusColor,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
