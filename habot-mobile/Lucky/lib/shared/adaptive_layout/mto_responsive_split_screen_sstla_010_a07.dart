// SSTLA-010-A07 — MTO Responsive Split-Screen Layout & Material 3 Choice Chips.
// Formulates responsive split-screen grid distributions for Micro Task Outsourcing panels, adapting stacking order dynamically based on screen orientation and applying Material 3 filter chip styling to choice chips.

import 'package:flutter/material.dart';

/// Enum representing the layout type for atomic-level data collection.
enum MtoLayoutType { verticalStack, horizontalSplit }

/// Data class holding layout validation metrics and atomic fields.
class MtoLayoutData {
  final MtoLayoutType layoutType;
  final Size gridDimensions;
  final EdgeInsets spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const MtoLayoutData({
    required this.layoutType,
    required this.gridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Poka-Yoke (Mistake-Proofing) Widget: Pins key source metrics immovably at the top of the viewport.
class PinnedMetricsHeader extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  final String status;

  const PinnedMetricsHeader({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Task ID: $taskId',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            taskTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          // Material 3 styled status indicator
          _Material3ChoiceChip(
            label: status,
            selected: true,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }
}

/// Custom Material 3 Filter Chip styled Choice Chip component.
/// Applies standard Material 3 filter chip styling rules to choice chip components as per requirement Setup Step (Action).1.
class _Material3ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _Material3ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
    );
  }
}

/// Main Responsive Split-Screen Layout for MTO Panels.
/// Replaces wide side-by-side desktop grids with clean, thumb-friendly vertical stacks tailored for mobile interaction.
class MtoResponsiveSplitScreen extends StatelessWidget {
  final List<Widget> panels;
  final MtoLayoutData layoutData;

  const MtoResponsiveSplitScreen({
    super.key,
    required this.panels,
    required this.layoutData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final isTabletOrDesktop = constraints.maxWidth >= 600.0;

        // Draft responsive layout rules that adapt panel stacking order dynamically based on screen orientation.
        if (isTabletOrDesktop && orientation == Orientation.landscape) {
          return _buildHorizontalSplit(context, constraints);
        } else {
          return _buildVerticalStack(context, constraints);
        }
      },
    );
  }

  /// Clean, thumb-friendly vertical stack for small devices / portrait mode.
  Widget _buildVerticalStack(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: layoutData.spacingRules,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: panels.map((panel) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: panel,
          );
        }).toList(),
      ),
    );
  }

  /// Side-by-side grid distribution for larger viewports / landscape mode.
  Widget _buildHorizontalSplit(BuildContext context, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: panels.map((panel) {
        return Expanded(
          child: Padding(
            padding: layoutData.spacingRules,
            child: panel,
          ),
        );
      }).toList(),
    );
  }
}

/// Example Usage / High-Fidelity Template Implementation
class MtoTaskVerificationScreen extends StatefulWidget {
  const MtoTaskVerificationScreen({super.key});

  @override
  State<MtoTaskVerificationScreen> createState() => _MtoTaskVerificationScreenState();
}

class _MtoTaskVerificationScreenState extends State<MtoTaskVerificationScreen> {
  String _selectedFilter = 'Pending';

  // Mock data simulating backend response for local validation
  static const List<Map<String, dynamic>> _mockTasks = [
    {'id': 'MTO-001', 'title': 'Verify Invoice #8832 Details', 'status': 'Pending'},
    {'id': 'MTO-002', 'title': 'Cross-check Shipping Address', 'status': 'In Progress'},
    {'id': 'MTO-003', 'title': 'Validate User Identity Document', 'status': 'Pending'},
  ];

  final MtoLayoutData _layoutData = const MtoLayoutData(
    layoutType: MtoLayoutType.verticalStack,
    gridDimensions: Size(double.infinity, double.infinity),
    spacingRules: EdgeInsets.all(16.0),
    alignmentSettings: Alignment.topCenter,
    layoutValidationStatus: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTO Verification Queue'),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          // Poka-Yoke: Key source metrics pinned immovably at the top
          if (_mockTasks.isNotEmpty)
            PinnedMetricsHeader(
              taskId: _mockTasks.first['id'] as String,
              taskTitle: _mockTasks.first['title'] as String,
              status: _mockTasks.first['status'] as String,
            ),
          
          // Material 3 Filter Chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Wrap(
              spacing: 8.0,
              children: ['All', 'Pending', 'In Progress', 'Completed'].map((filter) {
                return _Material3ChoiceChip(
                  label: filter,
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = filter);
                    }
                  },
                );
              }).toList(),
            ),
          ),

          // Responsive Split-Screen Grid Distribution
          Expanded(
            child: MtoResponsiveSplitScreen(
              layoutData: _layoutData,
              panels: [
                // Panel 1: Task List
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _mockTasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1.0),
                    itemBuilder: (context, index) {
                      final task = _mockTasks[index];
                      return ListTile(
                        title: Text(task['title'] as String),
                        subtitle: Text(task['id'] as String),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {},
                      );
                    },
                  ),
                ),
                // Panel 2: Action/Details Area
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Details',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Verification Notes',
                            hintText: 'Enter notes without pinching or zooming...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 24.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Submit Verification'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}