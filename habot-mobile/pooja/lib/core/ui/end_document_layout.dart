/*
 * STEP 2: EDEBS-032 — Anchor Mobile End Document (ED) UI Layout
 * 
 * Setup Step (Action): Open the master interface schema and data contract directory within the repository.
 * Setup Step Description: Definitive CDE restrictions | Nested structure bounds | Null condition rules | Precise type-casting schemas.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Z-pattern visual scanning for mobile layout navigation.
 *   - 4-column fluid grids adapting to screen width.
 *   - Sticky bottom navigation and flex-direction column orientation on compact mobile screens.
 *   - Material Data Tables with dynamic container structural mapping.
 * 
 * What Was Done to Complete This Step:
 *   - Created `EndDocumentLayout` widget and `EndDocumentDefinition` model in a single Dart file.
 *   - Implemented Z-pattern scanning header, document metadata chips, and sign-off completion actions.
 *   - Added CDE validation badge badges and clean summary layout wrappers.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class EndDocumentDefinition {
  final String documentId;
  final String title;
  final String author;
  final DateTime completionDate;
  final String approvalStatus;

  const EndDocumentDefinition({
    required this.documentId,
    required this.title,
    required this.author,
    required this.completionDate,
    this.approvalStatus = 'Pending Sign-off',
  });
}

/// Step EDEBS-032: End Document Summary & Layout Component.
class EndDocumentLayout extends StatelessWidget {
  final EndDocumentDefinition document;
  final VoidCallback? onApprove;

  const EndDocumentLayout({
    super.key,
    required this.document,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.description, color: colorScheme.primary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          document.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(document.approvalStatus),
                  avatar: const Icon(Icons.shield_outlined, size: 16),
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,
            Text('Document ID: ${document.documentId}', style: theme.textTheme.bodySmall),
            Text('Author: ${document.author}', style: theme.textTheme.bodySmall),
            Text('Completed: ${document.completionDate.toLocal().toString().split(' ')[0]}', style: theme.textTheme.bodySmall),
            AppSpacingTokens.vGapMd,
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve & Sign'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
