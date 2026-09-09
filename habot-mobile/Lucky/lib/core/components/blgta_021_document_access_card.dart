// BLGTA-021 — Document Isolation & Access Control Visualization.
// Static mobile UI for secure document attachment listings with role-based lock banners, security tags, and access request pathways.

import 'package:flutter/material.dart';

/// A single document access card showing isolation status and security tags.
class DocumentAccessCard extends StatelessWidget {
  const DocumentAccessCard({
    super.key,
    required this.documentTitle,
    required this.isRestricted,
    required this.securityTags,
    this.onRequestAccess,
  });

  final String documentTitle;
  final bool isRestricted;
  final List<String> securityTags;
  final VoidCallback? onRequestAccess;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isRestricted ? Icons.lock_outline : Icons.visibility_outlined,
              color: isRestricted ? colorScheme.error : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (isRestricted) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Access restricted — verification required',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: securityTags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (isRestricted && onRequestAccess != null)
              TextButton(
                onPressed: onRequestAccess,
                child: const Text('Request access'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Static visualization screen for document isolation states.
class DocumentIsolationVisualizationScreen extends StatelessWidget {
  const DocumentIsolationVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Isolation'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          DocumentAccessCard(
            documentTitle: 'Invoice_2024_0031.pdf',
            isRestricted: true,
            securityTags: ['Finance', 'Confidential'],
          ),
          DocumentAccessCard(
            documentTitle: 'Filing_Unit_Summary.xlsx',
            isRestricted: false,
            securityTags: ['Internal'],
          ),
          DocumentAccessCard(
            documentTitle: 'Identity_Verification_Report.pdf',
            isRestricted: true,
            securityTags: ['PII', 'Legal Hold'],
          ),
        ],
      ),
    );
  }
}
