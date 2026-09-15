/*
 * EDBAA-015-09 — Repository Artifact Access Control Panel
 * 
 * Setup Step (Action): Apply repository access control rules setting the uploaded artifact permissions to read-only for all developer accounts.
 * Metric Name: Process Adherence / Task Completion Rate (Floor: ≥90%, Target: 1, Ceiling: 1)
 * Quality Standard: ISO 9001:2015 Quality Management — Process Conformance Standard (Best = Complete 100%)
 * Telemetry: Repository URL; Repository Branch; Access Rights; Commit History; Repository Version; Clone Status; Completion Status ('Complete/Partial/Not Complete → Best = Complete (100%)'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class RepositoryArtifactAccessControlPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const RepositoryArtifactAccessControlPanel({
    super.key,
    this.globalRefId = 'EDBAA-015',
    this.atomicStepRefId = 'EDBAA-015-09',
    this.sequenceOrder = '12157',
  });

  @override
  State<RepositoryArtifactAccessControlPanel> createState() =>
      _RepositoryArtifactAccessControlPanelState();
}

class _RepositoryArtifactAccessControlPanelState
    extends State<RepositoryArtifactAccessControlPanel> {
  bool _readOnlyEnforced = true;

  final String _repoUrl = 'git@github.com:habot/habot-mobile-dist.git';
  final String _branch = 'release/v1.0.0-LOCKED';
  final String _accessRights = 'Developers: Read-Only (r--r--r--); Automated Pipeline: Sign-Only';
  final String _commitHistory = '1,284 verified signed commits';
  final String _repoVersion = 'v1.0.0-LOCKED';
  final String _cloneStatus = 'Active (Enforced Read-Only)';
  final String _completionStatus = 'Complete (100%)';
  final String _userSessionId = 'POOJA-EDBAA-015-09';

  final List<Map<String, String>> _aclMatrix = [
    {'role': 'Developer Accounts (*@habot.io)', 'perm': 'Read-Only (GET, PULL)', 'scope': 'All release artifacts', 'status': 'ENFORCED'},
    {'role': 'QA Verification Bots', 'perm': 'Read-Only (GET, CLONE)', 'scope': 'Testing builds', 'status': 'ENFORCED'},
    {'role': 'Distribution CDN Ingress', 'perm': 'Read-Only (FETCH)', 'scope': 'Public endpoints', 'status': 'ENFORCED'},
    {'role': 'Release Gate Administrator', 'perm': 'Admin (Supervised PGP)', 'scope': 'Master keys only', 'status': 'RESTRICTED'},
  ];

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-EDBAA-015-09-2026',
      'repositoryUrl': _repoUrl,
      'repositoryBranch': _branch,
      'accessRights': _accessRights,
      'commitHistory': _commitHistory,
      'repositoryVersion': _repoVersion,
      'cloneStatus': _cloneStatus,
      'readOnlyEnforced': _readOnlyEnforced,
      'standard': 'ISO 9001:2015 Process Conformance Standard',
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
                  Icons.security,
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
                      'Artifact Repository Access Control (ACL)',
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
                  'ISO 9001: 100%',
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
                    Text(
                      'Repository: $_repoUrl',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _readOnlyEnforced
                            ? AppColorPalette.successContainer
                            : AppColorPalette.warningContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _readOnlyEnforced ? 'READ-ONLY LOCKED' : 'UNENFORCED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _readOnlyEnforced
                              ? AppColorPalette.onSuccessContainer
                              : AppColorPalette.onWarningContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapXs,
                Text(
                  'Branch: $_branch | Version: $_repoVersion | Clones: $_cloneStatus',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                AppSpacingTokens.vGapSm,
                Divider(color: AppColorPalette.lightOutline.withValues(alpha: 0.15)),
                AppSpacingTokens.vGapSm,
                Text(
                  'Account Permissions Enforcement Matrix:',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapXs,
                ..._aclMatrix.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapXs,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['role']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${item['perm']} — ${item['scope']}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColorPalette.successContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status']!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColorPalette.onSuccessContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enforce Read-Only ACL for Developers'),
                  subtitle: const Text('Blocks unauthorized force pushes and mutations on release tags'),
                  value: _readOnlyEnforced,
                  onChanged: (val) {
                    setState(() {
                      _readOnlyEnforced = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
