import 'package:flutter/material.dart';
import '../utils/byt_id.dart';
import '../utils/byt_state.dart';

// MCIIM-013-10 — BytCard: MD3 Card widget keyed by UUID.
// Spec:
//   - Material 3 Card component representing the document
//   - Floating Action Button (FAB) for primary export on compact screens
//   - Canonical Supporting Pane layout for document preview
//   - Clear visual hierarchy for exportable documents
//
// BytCard is the visual representation of any Byt model.
// It uses BytId.key(byt.bytId) as its Flutter key — stable across rebuilds.

// ── Byt card data model ───────────────────────────────────────────────────────

class BytCardData with BytState {
  BytCardData({
    String? id,
    required this.title,
    this.subtitle,
    this.metadata,
    this.status,
    this.onExport,
    this.onTap,
  }) : bytId = id ?? BytId.generate();

  @override
  final String bytId;

  final String title;
  final String? subtitle;

  /// Key-value metadata displayed below title — e.g. {'Date': '25/12/2024'}
  final Map<String, String>? metadata;

  final BytCardStatus? status;
  final VoidCallback? onExport;
  final VoidCallback? onTap;
}

enum BytCardStatus { active, pending, complete, error, draft }

extension BytCardStatusX on BytCardStatus {
  String get label {
    switch (this) {
      case BytCardStatus.active:   return 'Active';
      case BytCardStatus.pending:  return 'Pending';
      case BytCardStatus.complete: return 'Complete';
      case BytCardStatus.error:    return 'Error';
      case BytCardStatus.draft:    return 'Draft';
    }
  }

  Color chipColor(ColorScheme cs) {
    switch (this) {
      case BytCardStatus.active:   return cs.primaryContainer;
      case BytCardStatus.pending:  return cs.tertiaryContainer;
      case BytCardStatus.complete: return cs.secondaryContainer;
      case BytCardStatus.error:    return cs.errorContainer;
      case BytCardStatus.draft:    return cs.surfaceContainerHighest;
    }
  }

  Color chipLabelColor(ColorScheme cs) {
    switch (this) {
      case BytCardStatus.active:   return cs.onPrimaryContainer;
      case BytCardStatus.pending:  return cs.onTertiaryContainer;
      case BytCardStatus.complete: return cs.onSecondaryContainer;
      case BytCardStatus.error:    return cs.onErrorContainer;
      case BytCardStatus.draft:    return cs.onSurfaceVariant;
    }
  }

  IconData get icon {
    switch (this) {
      case BytCardStatus.active:   return Icons.radio_button_checked_rounded;
      case BytCardStatus.pending:  return Icons.schedule_rounded;
      case BytCardStatus.complete: return Icons.check_circle_rounded;
      case BytCardStatus.error:    return Icons.error_outline_rounded;
      case BytCardStatus.draft:    return Icons.edit_note_rounded;
    }
  }
}

// ── BytCard widget ────────────────────────────────────────────────────────────

class BytCard extends StatelessWidget {
  BytCard({
    required this.data,
    this.isSelected = false,
    this.elevation = 2.0,
  }) : super(key: BytId.key(data.bytId));

  final BytCardData data;
  final bool isSelected;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Card(
      elevation:    isSelected ? elevation + 2 : elevation,
      color:        isSelected ? cs.secondaryContainer : cs.surface,
      surfaceTintColor: cs.surfaceTint,
      child: InkWell(
        onTap:        data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row — title + status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? cs.onSecondaryContainer
                            : cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (data.status != null) ...[
                    const SizedBox(width: 8),
                    _StatusChip(status: data.status!),
                  ],
                ],
              ),

              // Subtitle
              if (data.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  data.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Metadata rows
              if (data.metadata != null && data.metadata!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...data.metadata!.entries.map(
                  (e) => _MetadataRow(label: e.key, value: e.value),
                ),
              ],

              // Export action row
              if (data.onExport != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: data.onExport,
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: const Text('Export'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BytCardStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        status.chipColor(cs),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.chipLabelColor(cs)),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w600,
              color:      status.chipLabelColor(cs),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metadata row ──────────────────────────────────────────────────────────────

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BytCard FAB (compact screen export) ──────────────────────────────────────

/// FAB for primary export action on compact screens.
/// Spec: "Floating Action Button (FAB) for primary export on compact screens."
class BytExportFab extends StatelessWidget {
  const BytExportFab({
    super.key,
    required this.onExport,
    this.label = 'Export',
    this.isLoading = false,
  });

  final VoidCallback onExport;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onExport,
      icon: isLoading
          ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload_rounded),
      label: Text(label),
    );
  }
}

// ── BytCard list ──────────────────────────────────────────────────────────────

/// List of BytCards — each keyed by UUID, no duplicate keys possible.
class BytCardList extends StatelessWidget {
  const BytCardList({
    super.key,
    required this.items,
    this.selectedId,
    this.padding,
  });

  final List<BytCardData> items;
  final String? selectedId;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:     padding ?? const EdgeInsets.all(16),
      itemCount:   items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => BytCard(
        data:       items[i],
        isSelected: items[i].bytId == selectedId,
      ),
    );
  }
}
