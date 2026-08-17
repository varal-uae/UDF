// DSDD-007-11 — End Document Field Deconstructor hierarchy widget.
// Organizes structural fields deconstruction logically inside fluid vertical list views.
// Incorporates tracking schemas (Step Execution ID, Execution Status, Timestamp).

import 'package:flutter/material.dart';

/// Represents atomic data metadata properties
class EdFieldMetadata {
  const EdFieldMetadata({
    required this.fieldName,
    required this.fieldType,
    required this.value,
    this.children = const [],
  });

  final String fieldName;
  final String fieldType;
  final String value;
  final List<EdFieldMetadata> children;
}

/// A hierarchical vertical list layout for compact screens
class EdFieldHierarchyViewer extends StatelessWidget {
  const EdFieldHierarchyViewer({
    super.key,
    required this.stepExecutionId,
    required this.status,
    required this.timestamp,
    required this.userId,
    required this.fields,
  });

  final String stepExecutionId;
  final String status;
  final String timestamp;
  final String userId;
  final List<EdFieldMetadata> fields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tracking Payload Header (Least Privilege Mapping / BigQuery properties)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EndDocument Atomic Field Deconstruction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Execution ID: $stepExecutionId',
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
                Text(
                  'Timestamp: $timestamp | Operator: $userId',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Badge(
                      label: Text(status),
                      backgroundColor: status == 'Pass' ? cs.primary : cs.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Hierarchical Fields List
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: fields.length,
              itemBuilder: (context, index) {
                return _buildHierarchyTile(context, fields[index], 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyTile(BuildContext context, EdFieldMetadata field, int depth) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (field.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 + (depth * 16), right: 16, top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.fieldName,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Type: ${field.fieldType}',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            Text(
              field.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: 16.0 + (depth * 16), right: 16),
      title: Text(
        field.fieldName,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('Complex Object (${field.fieldType})', style: theme.textTheme.bodySmall),
      children: field.children.map((child) => _buildHierarchyTile(context, child, depth + 1)).toList(),
    );
  }
}
