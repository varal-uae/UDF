// SSELC-029-A06 — AdaptiveSplitLayoutShell
// Builds an adaptive master/detail split-panel layout that adjusts interfaces based on screen widths, enforcing a 60/40 widescreen split and full-screen mobile routing with a prominent back button.

import 'package:flutter/material.dart';

/// Mock data model for the list items to satisfy backend/mock data requirements.
class MockTemplateItem {
  final String id;
  final String name;
  final String version;
  final String type;
  final String configuration;

  const MockTemplateItem({
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    required this.configuration,
  });
}

/// Hardcoded mock repository providing local dummy data.
class MockTemplateRepository {
  static const List<MockTemplateItem> items = [
    MockTemplateItem(
      id: 'tpl_001',
      name: 'Standard Invoice',
      version: '1.0.4',
      type: 'Financial',
      configuration: '{"layout": "grid", "density": "compact"}',
    ),
    MockTemplateItem(
      id: 'tpl_002',
      name: 'User Onboarding',
      version: '2.1.0',
      type: 'Workflow',
      configuration: '{"steps": 5, "allowSkip": true}',
    ),
    MockTemplateItem(
      id: 'tpl_003',
      name: 'Inventory Audit',
      version: '1.2.0',
      type: 'Operations',
      configuration: '{"frequency": "monthly", "autoSync": true}',
    ),
    MockTemplateItem(
      id: 'tpl_004',
      name: 'Compliance Report',
      version: '3.0.1',
      type: 'Legal',
      configuration: '{"format": "pdf", "watermark": true}',
    ),
  ];
}

/// Fluid master/detail split-panel layout wrapper shell.
/// Enforces clean, simple border divider lines to separate side-by-side layout panels uniformly.
/// Applies accessible high-contrast palettes across text elements (Material 3).
class AdaptiveSplitLayoutShell extends StatefulWidget {
  final List<MockTemplateItem> items;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const AdaptiveSplitLayoutShell({
    super.key,
    this.items = MockTemplateRepository.items,
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 840.0,
  });

  @override
  State<AdaptiveSplitLayoutShell> createState() => _AdaptiveSplitLayoutShellState();
}

class _AdaptiveSplitLayoutShellState extends State<AdaptiveSplitLayoutShell> {
  MockTemplateItem? _selectedItem;

  void _selectItem(MockTemplateItem item) {
    setState(() {
      _selectedItem = item;
    });

    // Mobile-first implication: push full-screen route on small devices
    if (MediaQuery.of(context).size.width < widget.tabletBreakpoint) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _DetailScreen(
            item: item,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  /// Poka-Yoke: Close active detail screens automatically if a selected item row is deleted.
  void _deleteSelectedItem(String id) {
    setState(() {
      if (_selectedItem?.id == id) {
        _selectedItem = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= widget.tabletBreakpoint;

    if (isWideScreen) {
      return _buildSplitView(context);
    }

    return _buildMobileListView(context);
  }

  Widget _buildMobileListView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        elevation: 0,
      ),
      body: _MasterList(
        items: widget.items,
        selectedItem: _selectedItem,
        onSelect: _selectItem,
        onDelete: _deleteSelectedItem,
      ),
    );
  }

  Widget _buildSplitView(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 60% width for master list
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
              ),
              child: _MasterList(
                items: widget.items,
                selectedItem: _selectedItem,
                onSelect: _selectItem,
                onDelete: _deleteSelectedItem,
              ),
            ),
          ),
          // 40% width for details
          Expanded(
            flex: 4,
            child: _selectedItem != null
                ? _DetailPanel(item: _selectedItem!)
                : const _EmptyDetailPlaceholder(),
          ),
        ],
      ),
    );
  }
}

class _MasterList extends StatelessWidget {
  final List<MockTemplateItem> items;
  final MockTemplateItem? selectedItem;
  final ValueChanged<MockTemplateItem> onSelect;
  final ValueChanged<String> onDelete;

  const _MasterList({
    required this.items,
    required this.selectedItem,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem?.id == item.id;

        return ListTile(
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            '${item.type} • v${item.version}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          onTap: () => onSelect(item),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete template',
            onPressed: () => onDelete(item.id),
          ),
        );
      },
    );
  }
}

class _DetailScreen extends StatelessWidget {
  final MockTemplateItem item;
  final VoidCallback onBack;

  const _DetailScreen({
    required this.item,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Clear, large "Back to Table" arrow button within mobile detail headers
          icon: const Icon(Icons.arrow_back, size: 28.0),
          tooltip: 'Back to Table',
          onPressed: onBack,
        ),
        title: Text(item.name),
        elevation: 0,
      ),
      body: _DetailContent(item: item),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final MockTemplateItem item;

  const _DetailPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        const Divider(height: 1.0),
        Expanded(child: _DetailContent(item: item)),
      ],
    );
  }
}

class _DetailContent extends StatelessWidget {
  final MockTemplateItem item;

  const _DetailContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Template Name', value: item.name, textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 16.0),
          _DetailRow(label: 'Template Version', value: item.version, textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 16.0),
          _DetailRow(label: 'Template Type', value: item.type, textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 16.0),
          _DetailRow(label: 'Template Configuration', value: item.configuration, textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 32.0),
          // Standardized border divider lines
          Divider(color: colorScheme.outlineVariant, thickness: 1.0),
          const SizedBox(height: 16.0),
          Text(
            'Domain 4: Atomic Component Touch Systems & Interface Foundations (ACTS)',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64.0,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Select a template from the list to view details',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
