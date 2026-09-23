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
      padding: MasterSchemaDirectoryExplorerPanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MasterSchemaDirectoryExplorerPanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MasterSchemaDirectoryExplorerPanelTokens.sm),
                decoration: BoxDecoration(
                  color: MasterSchemaDirectoryExplorerPanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open_outlined,
                  color: MasterSchemaDirectoryExplorerPanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              MasterSchemaDirectoryExplorerPanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: MasterSchemaDirectoryExplorerPanelTokens.brandPrimary,
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
                  color: MasterSchemaDirectoryExplorerPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Branch: LOCKED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MasterSchemaDirectoryExplorerPanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          MasterSchemaDirectoryExplorerPanelTokens.vGapMd,
          Container(
            padding: MasterSchemaDirectoryExplorerPanelTokens.paddingMd,
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
                        color: MasterSchemaDirectoryExplorerPanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRE-EDIT VALIDATED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MasterSchemaDirectoryExplorerPanelTokens.onSuccessContainer)),
                    ),
                  ],
                ),
                MasterSchemaDirectoryExplorerPanelTokens.vGapXs,
                Text('Branch: $_branch | Commit: $_commitHistory', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                MasterSchemaDirectoryExplorerPanelTokens.vGapSm,
                Divider(color: MasterSchemaDirectoryExplorerPanelTokens.lightOutline.withValues(alpha: 0.15)),
                MasterSchemaDirectoryExplorerPanelTokens.vGapSm,
                Text('Data Contract Directory (/contracts/schemas/ed/):', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                MasterSchemaDirectoryExplorerPanelTokens.vGapXs,
                ..._schemaFiles.map((file) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: MasterSchemaDirectoryExplorerPanelTokens.brandPrimary),
                      MasterSchemaDirectoryExplorerPanelTokens.hGapSm,
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
                          color: MasterSchemaDirectoryExplorerPanelTokens.successContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(file['status']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MasterSchemaDirectoryExplorerPanelTokens.onSuccessContainer)),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          MasterSchemaDirectoryExplorerPanelTokens.vGapMd,
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schema directory validated against release branch (Pass)'),
                  backgroundColor: MasterSchemaDirectoryExplorerPanelTokens.success,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class MasterSchemaDirectoryExplorerPanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: MasterSchemaDirectoryExplorerPanel(),
          ),
        ),
      ),
    ),
  );
}
