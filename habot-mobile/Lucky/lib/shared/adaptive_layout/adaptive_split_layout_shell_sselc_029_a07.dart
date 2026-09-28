// SSELC-029-A07 — AdaptiveSplitLayoutShell: Master/detail split-panel layout wrapper.
// Provides a 60/40 horizontal split view on widescreen layouts and full-screen routing with a back button on mobile devices. Enforces 48x48dp touch targets and high-contrast Material 3 palettes.

import 'package:flutter/material.dart';

/// Mock data model for demonstration purposes to satisfy backend/mock data requirements.
class MockDataItem {
  final String id;
  final String title;
  final String description;
  final String metricValue;
  final String monitoringStatus;

  const MockDataItem({
    required this.id,
    required this.title,
    required this.description,
    required this.metricValue,
    required this.monitoringStatus,
  });
}

/// Static mock repository providing dummy data for the adaptive layout shell.
class MockDataRepository {
  static const List<MockDataItem> items = [
    MockDataItem(
      id: '1',
      title: 'Server Latency',
      description: 'Average response time across all API endpoints in the UAE region.',
      metricValue: '45ms',
      monitoringStatus: 'Normal',
    ),
    MockDataItem(
      id: '2',
      title: 'CPU Utilization',
      description: 'Current CPU load percentage on primary compute nodes.',
      metricValue: '68%',
      monitoringStatus: 'Warning',
    ),
    MockDataItem(
      id: '3',
      title: 'Memory Allocation',
      description: 'Total RAM consumed by active application processes.',
      metricValue: '12.4 GB',
      monitoringStatus: 'Normal',
    ),
    MockDataItem(
      id: '4',
      title: 'Network Throughput',
      description: 'Inbound and outbound network traffic volume per second.',
      metricValue: '850 Mbps',
      monitoringStatus: 'Optimal',
    ),
  ];
}

/// A responsive master/detail layout shell that adapts based on screen width.
/// On screens wider than [breakpointWidth], it displays a 60/40 split view.
/// On smaller screens, it forces clean, separate full-screen routing.
class AdaptiveSplitLayoutShell extends StatefulWidget {
  /// The list of items to display in the master panel.
  final List<MockDataItem> items;

  /// Optional callback when an item is selected (useful for Poka-Yoke deletion tracking).
  final ValueChanged<String?>? onItemSelected;

  /// The width threshold at which the layout switches from mobile to widescreen.
  final double breakpointWidth;

  const AdaptiveSplitLayoutShell({
    super.key,
    required this.items,
    this.onItemSelected,
    this.breakpointWidth = 840.0,
  });

  @override
  State<AdaptiveSplitLayoutShell> createState() => _AdaptiveSplitLayoutShellState();
}

class _AdaptiveSplitLayoutShellState extends State<AdaptiveSplitLayoutShell> {
  String? _selectedItemId;

  MockDataItem? get _selectedItem {
    if (_selectedItemId == null) return null;
    try {
      return widget.items.firstWhere((item) => item.id == _selectedItemId);
    } catch (_) {
      // Poka-Yoke: Close active detail screens automatically if a selected item row is deleted.
      _selectedItemId = null;
      return null;
    }
  }

  void _selectItem(String id) {
    setState(() {
      _selectedItemId = id;
    });
    widget.onItemSelected?.call(id);
  }

  void _clearSelection() {
    setState(() {
      _selectedItemId = null;
    });
    widget.onItemSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWidescreen = screenWidth >= widget.breakpointWidth;

    if (isWidescreen) {
      return _buildWidescreenLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWidescreenLayout() {
    return Row(
      children: [
        // Left Panel (Master) - 60% width
        Expanded(
          flex: 6,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: _MasterListView(
              items: widget.items,
              selectedItemId: _selectedItemId,
              onItemTap: _selectItem,
            ),
          ),
        ),
        // Clean, simple border divider line to separate side-by-side layout panels uniformly.
        VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // Right Panel (Detail) - 40% width
        Expanded(
          flex: 4,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: _selectedItem != null
                ? _DetailView(item: _selectedItem!)
                : const _EmptyDetailPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    if (_selectedItem == null) {
      return _MasterListView(
        items: widget.items,
        selectedItemId: _selectedItemId,
        onItemTap: _selectItem,
      );
    }

    // Full-screen detail routing for mobile devices
    return Scaffold(
      appBar: AppBar(
        leading: Tooltip(
          message: 'Return to the main data table',
          child: IconButton(
            // Enforce 48x48dp Touch Target Padding Constraints
            iconSize: 24.0,
            padding: const EdgeInsets.all(12.0),
            onPressed: _clearSelection,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: Text(
          _selectedItem!.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _DetailView(item: _selectedItem!),
    );
  }
}

class _MasterListView extends StatelessWidget {
  final List<MockDataItem> items;
  final String? selectedItemId;
  final ValueChanged<String> onItemTap;

  const _MasterListView({
    required this.items,
    required this.selectedItemId,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1.0,
        thickness: 1.0,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.id == selectedItemId;

        return ListTile(
          // Enforce 48x48dp minimum touch target
          minVerticalPadding: 12.0,
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
          subtitle: Text(
            item.metricValue,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          onTap: () => onItemTap(item.id),
        );
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final MockDataItem item;

  const _DetailView({required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Metric Value', value: item.metricValue, context: context),
                  const Divider(height: 32.0),
                  _DetailRow(label: 'Monitoring Status', value: item.monitoringStatus, context: context),
                  const Divider(height: 32.0),
                  _DetailRow(label: 'Description', value: item.description, context: context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64.0,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Select an item from the list to view details',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}