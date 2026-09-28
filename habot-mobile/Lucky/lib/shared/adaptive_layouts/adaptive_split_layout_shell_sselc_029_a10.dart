// SSELC-029-A10 — Adaptive Split Layout Shell for Master/Detail Routing.
// Provides a responsive 60/40 split view on widescreen and full-screen routing on mobile, with automatic detail closure on item deletion and distinct row highlighting.

import 'package:flutter/material.dart';

/// Mock data representing the canonical schema fields required by SSELC-029-A10.
class _MockMasterRecord {
  final String id;
  final String title;
  final String description;
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final String layoutValidationStatus;

  const _MockMasterRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

const List<_MockMasterRecord> _kMockRecords = [
  _MockMasterRecord(
    id: 'REC-001',
    title: 'Primary Record Alpha',
    description: 'Detailed information for record Alpha. Ensures data reviews are comfortable on both phones and monitors.',
    layoutType: 'Fluid Grid',
    layoutGridDimensions: '12-column, 8px gutter',
    spacingRules: '8dp baseline grid',
    alignmentSettings: 'Left-aligned text, center-aligned media',
    layoutValidationStatus: 'Pass',
  ),
  _MockMasterRecord(
    id: 'REC-002',
    title: 'Primary Record Beta',
    description: 'Detailed information for record Beta. Coordinates data fetching efficiently to save network bandwidth.',
    layoutType: 'Fixed Panel',
    layoutGridDimensions: '6-column, 16px gutter',
    spacingRules: '4dp baseline grid',
    alignmentSettings: 'Justified text',
    layoutValidationStatus: 'Pass',
  ),
  _MockMasterRecord(
    id: 'REC-003',
    title: 'Primary Record Gamma',
    description: 'Detailed information for record Gamma. Reduces code maintenance overhead by utilizing a single adaptive layout file.',
    layoutType: 'Responsive Stack',
    layoutGridDimensions: '4-column, 12px gutter',
    spacingRules: '16dp baseline grid',
    alignmentSettings: 'Right-aligned text',
    layoutValidationStatus: 'Fail',
  ),
];

/// Fluid master/detail split-panel layout wrapper shell.
/// Automatically adjusts interfaces based on screen widths (SSELC-029).
class AdaptiveSplitLayoutShell extends StatefulWidget {
  /// The breakpoint width below which the layout switches to mobile full-screen routing.
  final double mobileBreakpoint;

  const AdaptiveSplitLayoutShell({
    super.key,
    this.mobileBreakpoint = 840.0,
  });

  @override
  State<AdaptiveSplitLayoutShell> createState() => _AdaptiveSplitLayoutShellState();
}

class _AdaptiveSplitLayoutShellState extends State<AdaptiveSplitLayoutShell> {
  final List<_MockMasterRecord> _records = List.from(_kMockRecords);
  _MockMasterRecord? _selectedRecord;

  void _selectRecord(_MockMasterRecord record) {
    setState(() {
      _selectedRecord = record;
    });
  }

  /// Poka-Yoke: Close active detail screens automatically if a selected item row is deleted.
  void _deleteRecord(String id) {
    setState(() {
      _records.removeWhere((r) => r.id == id);
      if (_selectedRecord?.id == id) {
        _selectedRecord = null;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedRecord = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWidescreen = constraints.maxWidth >= widget.mobileBreakpoint;

        if (isWidescreen) {
          return _buildWidescreenLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  /// Open details inside an elegant 60/40 horizontal split view across widescreen layouts.
  Widget _buildWidescreenLayout(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        // Left-side structural layout frame (60%)
        Flexible(
          flex: 6,
          child: _MasterListView(
            records: _records,
            selectedRecordId: _selectedRecord?.id,
            onSelect: _selectRecord,
            onDelete: _deleteRecord,
            isWidescreen: true,
          ),
        ),
        // Enforce clean, simple border divider lines to separate side-by-side layout panels uniformly.
        VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: colorScheme.outlineVariant,
        ),
        // Right-side detail panel (40%)
        Flexible(
          flex: 4,
          child: _selectedRecord != null
              ? _DetailView(
                  record: _selectedRecord!,
                  onBack: _clearSelection,
                  showBackButton: false,
                )
              : _EmptyDetailPlaceholder(theme: theme),
        ),
      ],
    );
  }

  /// Force clean, separate full-screen routing for lists and details on small mobile devices.
  Widget _buildMobileLayout(BuildContext context) {
    if (_selectedRecord == null) {
      return _MasterListView(
        records: _records,
        selectedRecordId: null,
        onSelect: _selectRecord,
        onDelete: _deleteRecord,
        isWidescreen: false,
      );
    }

    return _DetailView(
      record: _selectedRecord!,
      onBack: _clearSelection,
      showBackButton: true,
    );
  }
}

class _MasterListView extends StatelessWidget {
  final List<_MockMasterRecord> records;
  final String? selectedRecordId;
  final ValueChanged<_MockMasterRecord> onSelect;
  final ValueChanged<String> onDelete;
  final bool isWidescreen;

  const _MasterListView({
    required this.records,
    required this.selectedRecordId,
    required this.onSelect,
    required this.onDelete,
    required this.isWidescreen,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: isWidescreen ? Colors.transparent : colorScheme.surface,
      appBar: isWidescreen
          ? null
          : AppBar(
              title: const Text('Master Records'),
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
      body: records.isEmpty
          ? Center(
              child: Text(
                'No records available.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: records.length,
              separatorBuilder: (_, __) => Divider(
                height: 1.0,
                thickness: 1.0,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (BuildContext context, int index) {
                final _MockMasterRecord record = records[index];
                final bool isSelected = record.id == selectedRecordId;

                return _MasterListTile(
                  record: record,
                  isSelected: isSelected,
                  onTap: () => onSelect(record),
                  onDelete: () => onDelete(record.id),
                  colorScheme: colorScheme,
                  theme: theme,
                );
              },
            ),
    );
  }
}

class _MasterListTile extends StatelessWidget {
  final _MockMasterRecord record;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _MasterListTile({
    required this.record,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Keep selected rows distinctly highlighted in left lists to maintain reading context.
    final Color tileColor = isSelected
        ? colorScheme.secondaryContainer
        : Colors.transparent;
    final Color textColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return Material(
      color: tileColor,
      child: InkWell(
        onTap: onTap,
        // Enforce 48x48dp Touch Target Padding Constraints
        customBorder: const RoundedRectangleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        record.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        record.layoutType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onSecondaryContainer.withOpacity(0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete action for Poka-Yoke testing
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: onDelete,
                  tooltip: 'Delete Record',
                  // 48x48dp touch target enforced by IconButton defaults
                  constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final _MockMasterRecord record;
  final VoidCallback onBack;
  final bool showBackButton;

  const _DetailView({
    required this.record,
    required this.onBack,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        leading: showBackButton
            // Include a clear, large "Back to Table" arrow button within mobile detail headers.
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24.0),
                onPressed: onBack,
                tooltip: 'Back to Table',
                constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          record.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          // Provide prominent tooltip boxes detailing structural form requirements.
          Tooltip(
            message: 'Structural Form Requirement: Layout Validation Status must be verified before submission.',
            preferBelow: false,
            child: IconButton(
              icon: Icon(Icons.info_outline, color: colorScheme.primary),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DetailField(
              label: 'Description',
              value: record.description,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const Divider(height: 32.0, thickness: 1.0),
            _DetailField(
              label: 'Layout Type',
              value: record.layoutType,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16.0),
            _DetailField(
              label: 'Layout Grid Dimensions',
              value: record.layoutGridDimensions,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16.0),
            _DetailField(
              label: 'Spacing Rules',
              value: record.spacingRules,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16.0),
            _DetailField(
              label: 'Alignment Settings',
              value: record.alignmentSettings,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16.0),
            _DetailField(
              label: 'Layout Validation Status',
              value: record.layoutValidationStatus,
              theme: theme,
              colorScheme: colorScheme,
              isStatus: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isStatus;

  const _DetailField({
    required this.label,
    required this.value,
    required this.theme,
    required this.colorScheme,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    // Apply accessible high-contrast palettes across text elements.
    final Color valueColor = isStatus
        ? (value == 'Pass' ? Colors.green.shade700 : colorScheme.error)
        : colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor,
            fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _EmptyDetailPlaceholder extends StatelessWidget {
  final ThemeData theme;

  const _EmptyDetailPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.view_sidebar_outlined,
            size: 64.0,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Select a record to view details',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
