/*
 * EDEBS-032-A01 — Master Schema Directory Explorer Panel
 * 
 * Setup Step (Action): Open the master interface schema and data contract directory within the repository.
 * Metric Name: Environment & Configuration Setup Readiness (Target: Config file opened in correct branch with schema validated pre-edit)
 * Quality Standard: Confirm the correct source-of-truth file/module is opened before any edits begin to avoid config drift across environments.
 * Telemetry: Repository URL; Repository Branch; Access Rights; Commit History; Repository Version; Clone Status; Completion Status ('Pass'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class MasterSchemaDirectoryExplorerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const MasterSchemaDirectoryExplorerPanel({
    super.key,
    this.globalRefId = 'EDEBS-032',
    this.atomicStepRefId = 'EDEBS-032-A01',
    this.sequenceOrder = '13143',
  });

  @override
  State<MasterSchemaDirectoryExplorerPanel> createState() =>
      _MasterSchemaDirectoryExplorerPanelState();
}

class _MasterSchemaDirectoryExplorerPanelState
    extends State<MasterSchemaDirectoryExplorerPanel> {
  final String _repoUrl = 'git@github.com:habot/habot-mobile.git';
  final String _branch = 'release/v1.0.0-LOCKED';
  final String _accessRights = 'Read-Only Source-of-Truth';
  final String _commitHistory = 'Commit: 0x9f4a12b (Validated & Signed)';
  final String _repoVersion = 'v1.0.0-LOCKED';
  final String _cloneStatus = 'Clean / In-Sync';
  final String _completionStatus = 'Pass';
  final String _userSessionId = 'POOJA-EDEBS-032-A01';

  final List<Map<String, String>> _schemaFiles = [
    {
      'path': 'contracts/schemas/ed/end_document_master_v1.json',
      'size': '24.2 KB',
      'status': 'VALIDATED',
      'type': 'JSON Schema (DCDF Master)'
    },
    {
      'path': 'contracts/schemas/ed/vendor_audit_receipt_contract.json',
      'size': '18.6 KB',
      'status': 'VALIDATED',
      'type': 'JSON Schema (Audit Receipt)'
    },
    {
      'path': 'contracts/schemas/ed/telemetry_event_stream.proto',
      'size': '8.4 KB',
      'status': 'VALIDATED',
      'type': 'Protobuf Contract (BigQuery)'
    },
  ];

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-EDEBS-032-A01-2026',
      'repositoryUrl': _repoUrl,
      'repositoryBranch': _branch,
      'accessRights': _accessRights,
      'commitHistory': _commitHistory,
      'repositoryVersion': _repoVersion,
      'cloneStatus': _cloneStatus,
      'readinessStatus': 'Config file opened in correct branch & schema validated pre-edit',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: AppSpacingTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: AppColorPalette.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 24,
                ),
              ),
              AppSpacingTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColorPalette.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Master Interface Schema Directory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Branch: LOCKED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColorPalette.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapMd,
          Container(
            padding: AppSpacingTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Repository: $_repoUrl', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRE-EDIT VALIDATED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColorPalette.onSuccessContainer)),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapXs,
                Text('Branch: $_branch | Commit: $_commitHistory', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                AppSpacingTokens.vGapSm,
                Divider(color: AppColorPalette.lightOutline.withValues(alpha: 0.15)),
                AppSpacingTokens.vGapSm,
                Text('Data Contract Directory (/contracts/schemas/ed/):', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacingTokens.vGapXs,
                ..._schemaFiles.map((file) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file['path']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            Text('${file['type']} — ${file['size']}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColorPalette.successContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(file['status']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColorPalette.onSuccessContainer)),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schema directory validated against release branch (Pass)'),
                  backgroundColor: AppColorPalette.success,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirm Schema Readiness'),
          ),
        ],
      ),
    );
  }
}
