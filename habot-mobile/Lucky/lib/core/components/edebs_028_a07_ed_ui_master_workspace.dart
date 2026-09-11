// EDEBS-028-A07 — ED-to-UI Master Workspace.
// Initializes a responsive Material 3 workspace that maps verified ED schema fields to UI containers.
// Enforces mobile-first rules: compact viewports use a single column, 100% width, and a 4-column fluid grid.

import 'package:flutter/material.dart';

@immutable
class EdUiWorkspaceCardData {
  const EdUiWorkspaceCardData({
    required this.id,
    required this.title,
    required this.schemaField,
    this.isVerified = true,
    this.child,
  });

  final String id;
  final String title;
  final String schemaField;
  final bool isVerified;
  final Widget? child;
}

class EdUiMasterWorkspace extends StatelessWidget {
  const EdUiMasterWorkspace({
    super.key,
    this.cards = const <EdUiWorkspaceCardData>[],
  });

  final List<EdUiWorkspaceCardData> cards;

  static const double compactBreakpoint = 600;
  static const double mediumBreakpoint = 840;
  static const int compactGridColumns = 4;
  static const double gutter = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isCompact = width < compactBreakpoint;
        final bool isMedium = width >= compactBreakpoint && width < mediumBreakpoint;
        final int contentColumns = isCompact ? 1 : (isMedium ? 2 : 4);
        final double gridColumnWidth =
            (width - (compactGridColumns - 1) * gutter) / compactGridColumns;
        final double cardWidth = isCompact
            ? width
            : (width - (contentColumns - 1) * gutter) / contentColumns;

        return Semantics(
          container: true,
          label: 'ED-to-UI Master Workspace',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _WorkspaceHeader(gridColumnWidth: gridColumnWidth),
              const SizedBox(height: gutter),
              const _SuccessColorProbe(),
              const SizedBox(height: gutter),
              _ResponsiveCardGrid(
                cards: cards,
                columns: contentColumns,
                cardWidth: cardWidth,
                gutter: gutter,
                isCompact: isCompact,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.gridColumnWidth});

  final double gridColumnWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'ED-to-UI Master Workspace',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Fluid width scaling based on 4-column compact device grid',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: const Icon(Icons.grid_on, size: 18),
            label: Text('grid column ${gridColumnWidth.toStringAsFixed(1)}px'),
          ),
        ),
      ],
    );
  }
}

class _SuccessColorProbe extends StatelessWidget {
  const _SuccessColorProbe();

  static const Color _successLight = Color(0xFF2E7D32);
  static const Color _successDark = Color(0xFF81C784);

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color successColor =
        brightness == Brightness.dark ? _successDark : _successLight;
    return Semantics(
      label: 'Success color rendering probe',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: successColor.withAlpha(31),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: successColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check_circle, color: successColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Success color test',
              style: TextStyle(color: successColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({
    required this.cards,
    required this.columns,
    required this.cardWidth,
    required this.gutter,
    required this.isCompact,
  });

  final List<EdUiWorkspaceCardData> cards;
  final int columns;
  final double cardWidth;
  final double gutter;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const _EmptyEdSchemaState();
    }
    return Wrap(
      spacing: isCompact ? 0 : gutter,
      runSpacing: gutter,
      children: cards.map((EdUiWorkspaceCardData card) {
        return SizedBox(
          width: cardWidth,
          child: _EdUiCard(data: card),
        );
      }).toList(),
    );
  }
}

class _EdUiCard extends StatelessWidget {
  const _EdUiCard({required this.data});

  final EdUiWorkspaceCardData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!data.isVerified) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(Icons.link_off, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unmapped ED schema field: ${data.schemaField}',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.verified, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ED schema: ${data.schemaField}',
              style: theme.textTheme.bodySmall,
            ),
            if (data.child != null) ...<Widget>[
              const SizedBox(height: 12),
              data.child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyEdSchemaState extends StatelessWidget {
  const _EmptyEdSchemaState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.dashboard_customize_outlined, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No verified ED schema cards available',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Map MD3 structural cards directly to the ED data dictionary.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
