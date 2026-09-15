/*
 * EDBAA-015-04 — Package Version Lock Milestone Panel
 * 
 * Setup Step (Action): Update the package version number to a designated locked master release milestone (e.g., v1.0.0-LOCKED).
 * Metric Name: Process Execution Quality Score (Floor: ≥90%, Target: ≥98%, Ceiling: 1)
 * Quality Standard: ISO 9001:2015 Quality Management Standard
 * Telemetry: Version Number; Version Type; Release Date; Version Status; Version Checksum; Completion Status ('Good/Average/Poor → Best = Good (100%)'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class PackageVersionLockMilestonePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const PackageVersionLockMilestonePanel({
    super.key,
    this.globalRefId = 'EDBAA-015',
    this.atomicStepRefId = 'EDBAA-015-04',
    this.sequenceOrder = '12152',
  });

  @override
  State<PackageVersionLockMilestonePanel> createState() =>
      _PackageVersionLockMilestonePanelState();
}

class _PackageVersionLockMilestonePanelState
    extends State<PackageVersionLockMilestonePanel> {
  bool _isLocked = true;
  String _versionNumber = 'v1.0.0-LOCKED';
  final String _versionType = 'Designated Locked Master Release Milestone';
  final String _releaseDate = '2026-09-09';
  final String _checksum = 'sha256:d572ec417a80b85e0f91b7e4369a48f2cb380';
  final String _completionStatus = 'Good (100%)';
  final String _userSessionId = 'POOJA-EDBAA-015-04';

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-EDBAA-015-04-2026',
      'versionNumber': _versionNumber,
      'versionType': _versionType,
      'releaseDate': _releaseDate,
      'versionStatus': _isLocked ? 'LOCKED_IMMUTABLE' : 'UNLOCKED',
      'versionChecksum': _checksum,
      'qualityStandard': 'ISO 9001:2015 Quality Management Standard',
      'processQualityScore': 1.0,
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
                  Icons.lock_clock,
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
                      'Master Release Version Lock Milestone',
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
                  'ISO 9001:2015',
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
            width: double.infinity,
            padding: AppSpacingTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isLocked
                    ? AppColorPalette.success.withValues(alpha: 0.4)
                    : AppColorPalette.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLocked ? Icons.verified : Icons.lock_open,
                          color: _isLocked
                              ? AppColorPalette.success
                              : AppColorPalette.warning,
                          size: 20,
                        ),
                        AppSpacingTokens.hGapSm,
                        Text(
                          'Version Identifier:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _versionNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _isLocked
                            ? AppColorPalette.success
                            : AppColorPalette.warning,
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapSm,
                Divider(color: AppColorPalette.lightOutline.withValues(alpha: 0.15)),
                AppSpacingTokens.vGapSm,
                _buildMetadataRow('Version Type', _versionType, theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildMetadataRow('Release Date', _releaseDate, theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildMetadataRow('Lock State', _isLocked ? 'LOCKED (Immutable Milestone)' : 'UNLOCKED', theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildMetadataRow('Cryptographic Checksum', _checksum, theme, colorScheme, isCode: true),
                AppSpacingTokens.vGapXs,
                _buildMetadataRow('Completion Status', _completionStatus, theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildMetadataRow('Audit Session', _userSessionId, theme, colorScheme),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLocked = !_isLocked;
                      _versionNumber = _isLocked ? 'v1.0.0-LOCKED' : 'v1.0.0-DRAFT';
                    });
                  },
                  icon: Icon(_isLocked ? Icons.lock : Icons.lock_open),
                  label: Text(_isLocked ? 'Verify Version Lock' : 'Lock Version Milestone'),
                ),
              ),
              AppSpacingTokens.hGapSm,
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Version milestone locked: $_versionNumber (Score: 100%)'),
                      backgroundColor: AppColorPalette.success,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Export Telemetry'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isCode = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isCode
                ? theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
