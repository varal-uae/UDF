// IRBCA-040 — Collapsible Audit Log Viewer.
// Groups audit trail details into collapsible summary sets, matching compact data typography and search filter controls.

import 'package:flutter/material.dart';

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.action,
    required this.operator,
    required this.timestamp,
    required this.details,
    this.isSuccessful = true,
  });

  final String id;
  final String action;
  final String operator;
  final String timestamp;
  final String details;
  final bool isSuccessful;
}

class CollapsibleAuditLogViewer extends StatefulWidget {
  const CollapsibleAuditLogViewer({
    super.key,
    required this.logs,
    required this.onSearchFilterTap,
  });

  final List<AuditLogItem> logs;
  final VoidCallback onSearchFilterTap;

  @override
  State<CollapsibleAuditLogViewer> createState() => _CollapsibleAuditLogViewerState();
}

class _CollapsibleAuditLogViewerState extends State<CollapsibleAuditLogViewer> {
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final filteredLogs = widget.logs.where((log) {
      return log.action.toLowerCase().contains(_filterQuery.toLowerCase()) ||
             log.operator.toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prominent search filter button bar
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (q) => setState(() => _filterQuery = q),
                decoration: InputDecoration(
                  hintText: 'Filter audit logs...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: widget.onSearchFilterTap,
              icon: const Icon(Icons.filter_list, size: 20),
              tooltip: 'Search Filters',
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...filteredLogs.map((log) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ExpansionTile(
              leading: Icon(
                log.isSuccessful ? Icons.check_circle : Icons.error,
                color: log.isSuccessful ? cs.primary : cs.error,
                size: 20,
              ),
              title: Text(
                log.action,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                'Op: ${log.operator} | ${log.timestamp}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11, // Compact typography fitting detail rows on mobile
                  color: cs.onSurfaceVariant,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log ID: ${log.id}', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      Text(log.details, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
