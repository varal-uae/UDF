// GEN-00959 — Standardized Material Design 3 Bottom Sheet for Mobile Complex Action Flows.
// Provides a reusable AppBottomSheet widget that retrofits mobile dashboard filter drawers, date selectors, and export prompts to use a single MD3-compliant bottom sheet pattern with 48x48dp touch targets, dynamic color, and responsive layout.

import 'package:flutter/material.dart';

/// Enum representing the type of bottom sheet action flow.
enum BottomSheetFlowType {
  filterDrawer,
  dateSelector,
  exportPrompt,
}

/// Mock data provider for demonstration purposes.
class _MockBottomSheetData {
  static const List<String> filterOptions = [
    'All Projects',
    'Active Only',
    'Completed',
    'Archived',
    'Pending Review',
  ];

  static const List<String> exportFormats = [
    'PDF Report',
    'CSV Export',
    'Excel (XLSX)',
    'JSON Data Dump',
  ];
}

/// A standardized Material Design 3 Bottom Sheet component.
/// Retrofits all mobile dashboard filter drawers, date selectors,
/// and export prompts to use this unified implementation.
class AppBottomSheet extends StatelessWidget {
  final BottomSheetFlowType flowType;
  final String title;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  const AppBottomSheet({
    super.key,
    required this.flowType,
    required this.title,
    this.onApply,
    this.onCancel,
  });

  /// Shows the standardized bottom sheet using M3 configuration.
  static Future<T?> show<T>({
    required BuildContext context,
    required BottomSheetFlowType flowType,
    required String title,
    VoidCallback? onApply,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        return AppBottomSheet(
          flowType: flowType,
          title: title,
          onApply: onApply,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final bool isDesktop = screenWidth >= 840;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // M3 Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                width: 32.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            // Header with M3 Elevated Card styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // 48x48dp touch target for close button
                  SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1.0),

            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: isDesktop
                    ? _buildMultiColumnContent(context)
                    : _buildSingleColumnContent(context),
              ),
            ),

            const Divider(height: 1.0),

            // Action Buttons with 48x48dp minimum touch targets
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 48.0,
                    child: TextButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    height: 48.0,
                    child: FilledButton(
                      onPressed: onApply ?? () => Navigator.of(context).pop(),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumnContent(BuildContext context) {
    switch (flowType) {
      case BottomSheetFlowType.filterDrawer:
        return _buildFilterContent(context);
      case BottomSheetFlowType.dateSelector:
        return _buildDateSelectorContent(context);
      case BottomSheetFlowType.exportPrompt:
        return _buildExportContent(context);
    }
  }

  Widget _buildMultiColumnContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSingleColumnContent(context)),
        const SizedBox(width: 24.0),
        Expanded(
          child: Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Configuration preview will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _MockBottomSheetData.filterOptions.map((option) {
        return SizedBox(
          height: 48.0, // 48x48dp touch target
          child: RadioListTile<String>(
            title: Text(option, style: theme.textTheme.bodyLarge),
            value: option,
            groupValue: _MockBottomSheetData.filterOptions.first,
            onChanged: (String? value) {},
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelectorContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date Range', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 48.0,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today),
            label: const Text('Start Date - End Date'),
          ),
        ),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: ['Today', 'Last 7 Days', 'Last 30 Days', 'Custom'].map((label) {
            return FilterChip(
              label: Text(label),
              selected: label == 'Last 7 Days',
              onSelected: (bool selected) {},
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExportContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _MockBottomSheetData.exportFormats.map((format) {
        return SizedBox(
          height: 48.0, // 48x48dp touch target
          child: CheckboxListTile(
            title: Text(format, style: theme.textTheme.bodyLarge),
            value: format == _MockBottomSheetData.exportFormats.first,
            onChanged: (bool? value) {},
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }
}

/// Example usage demonstrating how to retrofit existing flows.
class BottomSheetRetrofitExample extends StatelessWidget {
  const BottomSheetRetrofitExample({super.key});

  void _showFilterDrawer(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      flowType: BottomSheetFlowType.filterDrawer,
      title: 'Dashboard Filters',
      onApply: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filters applied successfully')),
        );
      },
    );
  }

  void _showDateSelector(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      flowType: BottomSheetFlowType.dateSelector,
      title: 'Select Date Range',
      onApply: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date range updated')),
        );
      },
    );
  }

  void _showExportPrompt(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      flowType: BottomSheetFlowType.exportPrompt,
      title: 'Export Options',
      onApply: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export initiated')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MD3 Bottom Sheet Retrofit')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48.0,
              child: FilledButton.tonal(
                onPressed: () => _showFilterDrawer(context),
                child: const Text('Open Filter Drawer'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 48.0,
              child: FilledButton.tonal(
                onPressed: () => _showDateSelector(context),
                child: const Text('Open Date Selector'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 48.0,
              child: FilledButton.tonal(
                onPressed: () => _showExportPrompt(context),
                child: const Text('Open Export Prompt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}