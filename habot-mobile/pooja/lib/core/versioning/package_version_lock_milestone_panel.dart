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
      padding: PackageVersionLockMilestonePanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PackageVersionLockMilestonePanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PackageVersionLockMilestonePanelTokens.sm),
                decoration: BoxDecoration(
                  color: PackageVersionLockMilestonePanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_clock,
                  color: PackageVersionLockMilestonePanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              PackageVersionLockMilestonePanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: PackageVersionLockMilestonePanelTokens.brandPrimary,
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
                  color: PackageVersionLockMilestonePanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ISO 9001:2015',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: PackageVersionLockMilestonePanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          PackageVersionLockMilestonePanelTokens.vGapMd,
          Container(
            width: double.infinity,
            padding: PackageVersionLockMilestonePanelTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isLocked
                    ? PackageVersionLockMilestonePanelTokens.success.withValues(alpha: 0.4)
                    : PackageVersionLockMilestonePanelTokens.warning.withValues(alpha: 0.4),
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
                              ? PackageVersionLockMilestonePanelTokens.success
                              : PackageVersionLockMilestonePanelTokens.warning,
                          size: 20,
                        ),
                        PackageVersionLockMilestonePanelTokens.hGapSm,
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
                            ? PackageVersionLockMilestonePanelTokens.success
                            : PackageVersionLockMilestonePanelTokens.warning,
                      ),
                    ),
                  ],
                ),
                PackageVersionLockMilestonePanelTokens.vGapSm,
                Divider(color: PackageVersionLockMilestonePanelTokens.lightOutline.withValues(alpha: 0.15)),
                PackageVersionLockMilestonePanelTokens.vGapSm,
                _buildMetadataRow('Version Type', _versionType, theme, colorScheme),
                PackageVersionLockMilestonePanelTokens.vGapXs,
                _buildMetadataRow('Release Date', _releaseDate, theme, colorScheme),
                PackageVersionLockMilestonePanelTokens.vGapXs,
                _buildMetadataRow('Lock State', _isLocked ? 'LOCKED (Immutable Milestone)' : 'UNLOCKED', theme, colorScheme),
                PackageVersionLockMilestonePanelTokens.vGapXs,
                _buildMetadataRow('Cryptographic Checksum', _checksum, theme, colorScheme, isCode: true),
                PackageVersionLockMilestonePanelTokens.vGapXs,
                _buildMetadataRow('Completion Status', _completionStatus, theme, colorScheme),
                PackageVersionLockMilestonePanelTokens.vGapXs,
                _buildMetadataRow('Audit Session', _userSessionId, theme, colorScheme),
              ],
            ),
          ),
          PackageVersionLockMilestonePanelTokens.vGapMd,
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
              PackageVersionLockMilestonePanelTokens.hGapSm,
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Version milestone locked: $_versionNumber (Score: 100%)'),
                      backgroundColor: PackageVersionLockMilestonePanelTokens.success,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class PackageVersionLockMilestonePanelTokens {
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
            child: PackageVersionLockMilestonePanel(),
          ),
        ),
      ),
    ),
  );
}
