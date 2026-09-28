// SSELC-029-A13 — AdaptiveSplitLayoutShell: Master/detail adaptive routing and fluid split-panel container.
// Provides a 60/40 horizontal split view on widescreen layouts, collapsing to full-screen vertical routing on mobile with distinct row highlighting and a prominent back button. Enforces 48x48dp touch targets and high-contrast Material 3 palettes.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level layout fields for demonstration.
class _MockLayoutItem {
  final String id;
  final String title;
  final String description;

  const _MockLayoutItem({
    required this.id,
    required this.title,
    required this.description,
  });
}

const List<_MockLayoutItem> _kMockItems = [
  _MockLayoutItem(id: '1', title: 'Record Alpha', description: 'Detailed information for Record Alpha. Layout Type: Grid. Dimensions: 60/40.'),
  _MockLayoutItem(id: '2', title: 'Record Beta', description: 'Detailed information for Record Beta. Spacing Rules: 16dp. Alignment: Start.'),
  _MockLayoutItem(id: '3', title: 'Record Gamma', description: 'Detailed information for Record Gamma. Validation Status: Good.'),
  _MockLayoutItem(id: '4', title: 'Record Delta', description: 'Detailed information for Record Delta. Completion Status: Average.'),
];

/// Fluid master/detail split-panel layout wrapper shell.
/// Adapts interfaces based on screen widths (SSELC-029).
class AdaptiveSplitLayoutShell extends StatefulWidget {
  const AdaptiveSplitLayoutShell({super.key});

  @override
  State<AdaptiveSplitLayoutShell> createState() => _AdaptiveSplitLayoutShellState();
}

class _AdaptiveSplitLayoutShellState extends State<AdaptiveSplitLayoutShell> {
  _MockLayoutItem? _selectedItem;

  static const double _kMobileBreakpoint = 600.0;
  static const double _kTouchTargetSize = 48.0;

  void _selectItem(_MockLayoutItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWideScreen = constraints.maxWidth >= _kMobileBreakpoint;

        if (isWideScreen) {
          return _buildWideScreenLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  /// Elegant 60/40 horizontal split view across widescreen layouts.
  Widget _buildWideScreenLayout() {
    return Row(
      children: <Widget>[
        // Left Panel: 60% width
        Flexible(
          flex: 6,
          child: _buildMasterList(isWideScreen: true),
        ),
        // Clean, simple border divider line to separate side-by-side panels uniformly
        const VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Colors.black26,
        ),
        // Right Panel: 40% width
        Flexible(
          flex: 4,
          child: _buildDetailPanel(isWideScreen: true),
        ),
      ],
    );
  }

  /// Full-screen routing for lists and details on small mobile devices.
  Widget _buildMobileLayout() {
    if (_selectedItem == null) {
      return _buildMasterList(isWideScreen: false);
    } else {
      return _buildDetailPanel(isWideScreen: false);
    }
  }

  Widget _buildMasterList({required bool isWideScreen}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _kMockItems.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 1.0,
          thickness: 1.0,
          color: Colors.black12,
        ),
        itemBuilder: (BuildContext context, int index) {
          final _MockLayoutItem item = _kMockItems[index];
          final bool isSelected = _selectedItem?.id == item.id;

          return InkWell(
            onTap: () => _selectItem(item),
            child: Container(
              // Enforce 48x48dp Touch Target Padding Constraints
              constraints: const BoxConstraints(minHeight: _kTouchTargetSize),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailPanel({required bool isWideScreen}) {
    if (_selectedItem == null) {
      return Center(
        child: Text(
          'Select an item to view details',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWideScreen
          ? null
          : AppBar(
              leading: Tooltip(
                message: 'Return to the list of records',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _clearSelection,
                  // Ensure 48x48 touch target
                  constraints: const BoxConstraints(
                    minWidth: _kTouchTargetSize,
                    minHeight: _kTouchTargetSize,
                  ),
                ),
              ),
              title: const Text('Details'),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!isWideScreen)
              const SizedBox(height: 8.0)
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _selectedItem!.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            Text(
              _selectedItem!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const Spacer(),
            // Fallback layout modification rules indicator
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Layout Validation Status: Good\nGrid Dimensions: ${isWideScreen ? "60/40 Split" : "Single Column"}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}