// EDEBS-032-A04 — Anchor Mobile End Document (ED) UI Layout.
// Data-driven mobile layout with 4-column fluid grid, Z-pattern scanning,
// sticky bottom navigation, Material Data Tables, and schema validation status.

import 'package:flutter/material.dart';

enum EdLayoutValidationStatus { pass, fail }

class EdLayoutField {
  const EdLayoutField({
    required this.label,
    required this.value,
    this.validationStatus,
  });

  final String label;
  final String value;
  final EdLayoutValidationStatus? validationStatus;
}

class Edebs032A04EdLayout extends StatelessWidget {
  const Edebs032A04EdLayout({
    super.key,
    required this.fields,
    this.validationStatus = EdLayoutValidationStatus.pass,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Continue',
  });

  final List<EdLayoutField> fields;
  final EdLayoutValidationStatus validationStatus;
  final VoidCallback? onPrimaryAction;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('End Document Layout'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 16.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ValidationBanner(status: validationStatus),
                  const SizedBox(height: 16),
                  Text('Layout Grid Bounds', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _ZPatternGrid(fields: fields),
                  const SizedBox(height: 24),
                  Text('Material Data Table', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _EdDataTable(fields: fields),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Layout'),
          NavigationDestination(icon: Icon(Icons.table_chart), label: 'Data'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Validate'),
        ],
      ),
      floatingActionButton: onPrimaryAction == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onPrimaryAction,
              icon: const Icon(Icons.arrow_forward),
              label: Text(primaryActionLabel),
            ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.status});

  final EdLayoutValidationStatus status;

  @override
  Widget build(BuildContext context) {
    final isPass = status == EdLayoutValidationStatus.pass;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPass ? colorScheme.primaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPass ? Icons.check_circle : Icons.error,
            color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPass
                  ? 'Schema alignment: Pass — 100% mapped 1:1 to ED schema'
                  : 'Schema alignment: Fail — critical data element omission detected',
              style: TextStyle(
                color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZPatternGrid extends StatelessWidget {
  const _ZPatternGrid({required this.fields});

  final List<EdLayoutField> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        final rows = <List<EdLayoutField>>[];
        for (var i = 0; i < fields.length; i += columns) {
          final end = (i + columns < fields.length) ? i + columns : fields.length;
          rows.add(fields.sublist(i, end));
        }
        return Column(
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              _buildGridRow(rows[r], r.isEven, itemWidth, spacing),
              if (r < rows.length - 1) const SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGridRow(List<EdLayoutField> row, bool leftToRight, double itemWidth, double spacing) {
    final displayRow = leftToRight ? row : row.reversed.toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < 4; c++) ...[
          if (c < displayRow.length)
            SizedBox(width: itemWidth, child: _FieldTile(field: displayRow[c]))
          else
            SizedBox(width: itemWidth),
          if (c < 3) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.field});

  final EdLayoutField field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = field.validationStatus;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: theme.textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              field.value,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (status != null) ...[
              const SizedBox(height: 6),
              _StatusChip(status: status),
            ],
          ],
        ),
      ),
    );
  }
}

class _EdDataTable extends StatelessWidget {
  const _EdDataTable({required this.fields});

  final List<EdLayoutField> fields;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Field')),
          DataColumn(label: Text('Value')),
          DataColumn(label: Text('Validation')),
        ],
        rows: fields.map((f) {
          return DataRow(cells: [
            DataCell(Text(f.label)),
            DataCell(Text(f.value)),
            DataCell(
              _StatusChip(
                status: f.validationStatus ?? EdLayoutValidationStatus.pass,
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final EdLayoutValidationStatus status;

  @override
  Widget build(BuildContext context) {
    final isPass = status == EdLayoutValidationStatus.pass;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPass ? colorScheme.secondaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPass ? 'Pass' : 'Fail',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPass ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
