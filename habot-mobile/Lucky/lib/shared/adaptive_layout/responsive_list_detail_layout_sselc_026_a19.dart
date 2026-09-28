// SSELC-026-A19 — Responsive List-Detail View Layout.
// Provides an adaptive split-screen layout that shows list and detail panels side-by-side on tablets, and uses full-screen navigation on phones.

import 'package:flutter/material.dart';

/// Breakpoint thresholds for adaptive layout decisions.
class _LayoutBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 840.0;
}

/// Mock data model representing a list item.
class ListItemModel {
  final String id;
  final String title;
  final String description;

  const ListItemModel({
    required this.id,
    required this.title,
    required this.description,
  });
}

/// Hardcoded mock data repository for local execution without backend dependency.
class MockListRepository {
  static const List<ListItemModel> items = [
    ListItemModel(
      id: 'item_001',
      title: 'Analytics Overview',
      description: 'Comprehensive view of user engagement metrics and tracking statistics across all active sessions.',
    ),
    ListItemModel(
      id: 'item_002',
      title: 'System Health',
      description: 'Real-time monitoring dashboard detailing server uptime, latency distributions, and error rates.',
    ),
    ListItemModel(
      id: 'item_003',
      title: 'User Traces',
      description: 'Deep trace statistics panel showing asynchronous user actions and interaction flows.',
    ),
    ListItemModel(
      id: 'item_004',
      title: 'Configuration',
      description: 'Manage application settings, feature flags, and environment-specific parameters securely.',
    ),
  ];
}

/// A responsive layout widget that adapts between a split-screen (tablet/desktop)
/// and a stacked navigation flow (mobile) for list-to-detail workflows.
class ResponsiveListDetailLayout extends StatefulWidget {
  final List<ListItemModel> items;
  final Widget Function(ListItemModel item) detailBuilder;

  const ResponsiveListDetailLayout({
    super.key,
    required this.items,
    required this.detailBuilder,
  });

  @override
  State<ResponsiveListDetailLayout> createState() => _ResponsiveListDetailLayoutState();
}

class _ResponsiveListDetailLayoutState extends State<ResponsiveListDetailLayout> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Default selection for wide screens to avoid empty detail panel.
    if (widget.items.isNotEmpty) {
      _selectedIndex = 0;
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _LayoutBreakpoints.tablet;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = _isWideScreen(context);
    final selectedItem = (_selectedIndex != null && _selectedIndex! < widget.items.length)
        ? widget.items[_selectedIndex!]
        : null;

    if (isWide) {
      return _buildSplitScreenLayout(context, selectedItem);
    } else {
      return _buildMobileListLayout(context);
    }
  }

  /// Tablet/Desktop: Split-screen with constant list width and flexible detail panel.
  Widget _buildSplitScreenLayout(BuildContext context, ListItemModel? selectedItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // List area maintains constant dimensions
        SizedBox(
          width: 320.0,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: _buildListView(context, isWideScreen: true),
          ),
        ),
        const VerticalDivider(width: 1.0, thickness: 1.0),
        // Detail panel grows or shrinks to match remaining canvas space
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: selectedItem != null
                ? KeyedSubtree(
                    key: ValueKey<String>(selectedItem.id),
                    child: widget.detailBuilder(selectedItem),
                  )
                : const Center(
                    key: ValueKey<String>('empty_state'),
                    child: Text('Select an item from the list to view details.'),
                  ),
          ),
        ),
      ],
    );
  }

  /// Mobile: Full-screen list prioritizing focused columns before navigating to detail.
  Widget _buildMobileListLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Items'),
        elevation: 0.0,
      ),
      body: _buildListView(context, isWideScreen: false),
    );
  }

  Widget _buildListView(BuildContext context, {required bool isWideScreen}) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1.0, indent: 16.0, endIndent: 16.0),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = _selectedIndex == index;

        return ListTile(
          selected: isWideScreen && isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () {
            _onItemSelected(index);
            if (!isWideScreen) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(item.title)),
                    body: widget.detailBuilder(item),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// Standardized detail view module embedded across data entry screens.
class StandardDetailView extends StatelessWidget {
  final ListItemModel item;

  const StandardDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24.0),
          Card(
            elevation: 0.0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trace ID: ${item.id}', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8.0),
                  const Text('Asynchronous tracking database updates are processed seamlessly for this record.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Poka-Yoke (Mistake-Proofing): Validates screen sizes against standard constraints.
/// Throws an assertion error if custom, non-standard screen sizes are applied improperly.
class LayoutSizeValidator {
  static void validateConstraints(BoxConstraints constraints) {
    assert(
      constraints.maxWidth >= _LayoutBreakpoints.mobile || constraints.maxWidth == double.infinity,
      'Poka-Yoke Error: Non-standard screen width detected (${constraints.maxWidth}). '
      'Minimum supported width is ${_LayoutBreakpoints.mobile}dp for proper layout rendering.',
    );
  }
}

/// Telemetry mock data structure for atomic-level tracking as per requirement.
class StepExecutionTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'step_execution_id': stepExecutionId,
    'execution_status': executionStatus,
    'execution_timestamp': executionTimestamp.toIso8601String(),
    'step_outcome': stepOutcome,
    'user_id': userId,
  };
}

/// Example usage / entry point for testing the responsive layout.
class ResponsiveListDetailScreen extends StatelessWidget {
  const ResponsiveListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Self-chasing / Mistake-proofing validation
        LayoutSizeValidator.validateConstraints(constraints);

        return ResponsiveListDetailLayout(
          items: MockListRepository.items,
          detailBuilder: (item) => StandardDetailView(item: item),
        );
      },
    );
  }
}
