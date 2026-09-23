/*
 * DLQDP-015-13 — Configure System-Verb Icon Mapping Matrix
 * 
 * Setup Step (Action): Save and commit the finalized System-Verb Icon Mapping Matrix to the version control system.
 * Setup Step Description: Enforce strict iconography usage within the app mapping only to system actions;
 *   strip human-centric indicators completely.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Match layouts to modern compact display constraints.
 *   - Enforce a strict 24x24dp dimension bounding box for structural icons.
 *   - Embed phantom padding bounds to widen finger hit areas to 48dp.
 * 
 * What Was Done to Complete This Step:
 *   - Created `SystemVerbIconPanel` widget, `SystemVerbIconRecord`, and `SystemVerbItem` models in a single file.
 *   - Implemented 24x24dp icon bounding box inspector, 48dp phantom touch target padding, and system action verb grid.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step DLQDP-015-13 (Row 2067): System-Verb Icon Mapping Record Model.
class SystemVerbIconRecord {
  final String versionNumber;
  final String versionType;
  final String releaseDate;
  final String versionStatus;
  final String versionChecksum;
  final String completionStatus; // 'Good/Average/Poor → Best = Good (100%)'
  final String actionTimestamp;
  final String userSessionId;
  final double singleActionGranularityRate; // Floor: 90%, Optimal: 100%, Ceiling: 100%
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final double iconBoundingBoxDp; // 24x24dp
  final double touchTargetPhantomPaddingDp; // 48dp

  const SystemVerbIconRecord({
    required this.versionNumber,
    required this.versionType,
    required this.releaseDate,
    required this.versionStatus,
    required this.versionChecksum,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
    this.singleActionGranularityRate = 1.0,
    this.floorBoundary = 0.90,
    this.optimalTarget = 1.00,
    this.ceilingBoundary = 1.00,
    this.iconBoundingBoxDp = 24.0,
    this.touchTargetPhantomPaddingDp = 48.0,
  });

  bool get meetsFloorBoundary => singleActionGranularityRate >= floorBoundary;
  bool get meetsOptimalTarget => singleActionGranularityRate >= optimalTarget;
}

class SystemVerbItem {
  final String verbName;
  final String actionDescription;
  final IconData iconData;

  const SystemVerbItem({
    required this.verbName,
    required this.actionDescription,
    required this.iconData,
  });
}

/// Step DLQDP-015-13 (Row 2067): System-Verb Icon Mapping Matrix Panel.
class SystemVerbIconPanel extends StatefulWidget {
  final SystemVerbIconRecord record;
  final List<SystemVerbItem> verbs;

  const SystemVerbIconPanel({
    super.key,
    this.record = const SystemVerbIconRecord(
      versionNumber: 'v1.4.2',
      versionType: 'SYSTEM_VERB_MAPPING',
      releaseDate: '2026-09-08',
      versionStatus: 'STABLE_PRODUCTION',
      versionChecksum: 'sha256-4c7b8e19',
      completionStatus: 'Good (100%)',
      actionTimestamp: '2026-09-08T15:00:00Z',
      userSessionId: 'SESSION-DLQDP-015-13',
    ),
    this.verbs = const [
      SystemVerbItem(verbName: 'INGRESS', actionDescription: 'Data stream ingress pipeline', iconData: Icons.input_rounded),
      SystemVerbItem(verbName: 'RECONCILE', actionDescription: 'Reconcile dual entry ledger balance', iconData: Icons.balance_rounded),
      SystemVerbItem(verbName: 'PERSIST', actionDescription: 'Commit transaction record to vault', iconData: Icons.save_rounded),
      SystemVerbItem(verbName: 'DISPATCH', actionDescription: 'Transmit real-time telemetry frame', iconData: Icons.send_rounded),
    ],
  });

  @override
  State<SystemVerbIconPanel> createState() => _SystemVerbIconPanelState();
}

class _SystemVerbIconPanelState extends State<SystemVerbIconPanel> {
  void _onVerbTapped(SystemVerbItem item) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('System Action Triggered: Verb "${item.verbName}" (${item.actionDescription})'),
        backgroundColor: SystemVerbIconPanelTokens.brandPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'versionNumber': widget.record.versionNumber,
      'versionType': widget.record.versionType,
      'releaseDate': widget.record.releaseDate,
      'versionStatus': widget.record.versionStatus,
      'versionChecksum': widget.record.versionChecksum,
      'completionStatus': widget.record.completionStatus,
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': widget.record.userSessionId,
      'metadata': {
        'taskCode': 'DLQDP-015-13',
        'row': 161,
        'seq': 10746,
        'assigned': 'Pooja',
        'metricName': 'Task Atomicity / Single-Action Granularity Rate',
        'floor': '≥90%',
        'target': '100%',
        'ceiling': '100%',
        'unit': 'Good/Average/Poor → Best = Good (100%)',
        'singleActionGranularityRate': widget.record.singleActionGranularityRate,
        'iconBoundingBoxDp': widget.record.iconBoundingBoxDp,
        'touchTargetPhantomPaddingDp': widget.record.touchTargetPhantomPaddingDp,
        'verbsCount': widget.verbs.length,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;
    final atomicityPercentStr =
        '${(record.singleActionGranularityRate * 100).toStringAsFixed(0)}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final cardPadding = isCompact
            ? SystemVerbIconPanelTokens.paddingSm
            : (isExpanded ? SystemVerbIconPanelTokens.paddingLg : SystemVerbIconPanelTokens.paddingMd);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar with Step Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined, color: colorScheme.onSecondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'SYSTEM-VERB ICON MATRIX',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SystemVerbIconPanelTokens.hGapSm,
                Expanded(
                  child: Text(
                    'DLQDP-015-13 (Row 2067)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SystemVerbIconPanelTokens.vGapMd,

            // Task Atomicity / Single-Action Granularity Rate KPI Card
            Container(
              padding: SystemVerbIconPanelTokens.paddingMd,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.secondary.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.grain_outlined, color: colorScheme.secondary, size: 20),
                            SystemVerbIconPanelTokens.hGapXs,
                            Expanded(
                              child: Text(
                                'Task Atomicity / Single-Action Granularity',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SystemVerbIconPanelTokens.hGapSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.meetsOptimalTarget
                              ? SystemVerbIconPanelTokens.success
                              : SystemVerbIconPanelTokens.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          record.completionStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SystemVerbIconPanelTokens.vGapSm,
                  Row(
                    children: [
                      Text(
                        atomicityPercentStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                      SystemVerbIconPanelTokens.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: record.singleActionGranularityRate,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                              ),
                            ),
                            SystemVerbIconPanelTokens.vGapXs,
                            Text(
                              'Floor: ≥90% | Optimal: 1.0 | Ceiling: 1.0 (Lean Six Sigma Standard)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SystemVerbIconPanelTokens.vGapXs,
                  Text(
                    'Standard: Lean Six Sigma Process Decomposition Standard.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SystemVerbIconPanelTokens.vGapLg,

            // SVG Vector Formatting & Version Checksum Status Banner
            Container(
              padding: SystemVerbIconPanelTokens.paddingSm,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.polyline, color: colorScheme.secondary, size: 18),
                  SystemVerbIconPanelTokens.hGapSm,
                  Expanded(
                    child: Text(
                      'SVG Vector Matrix Committed: Version ${record.versionNumber} • Checksum: ${record.versionChecksum}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SystemVerbIconPanelTokens.vGapLg,

            // System-Verb Icon Grid (Strict 24x24dp Icon Bounds inside 48x48dp Phantom Padding Target)
            Text(
              'System-Verb Icon Matrix (24x24dp Icon Bounds • 48x48dp Phantom Touch Targets)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SystemVerbIconPanelTokens.vGapSm,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.verbs.map((item) {
                return Container(
                  width: 140,
                  padding: SystemVerbIconPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      // 48x48dp Phantom Touch Target Container
                      InkWell(
                        onTap: () => _onVerbTapped(item),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: record.touchTargetPhantomPaddingDp, // 48dp phantom touch target
                          height: record.touchTargetPhantomPaddingDp, // 48dp phantom touch target
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withAlpha(120),
                            shape: BoxShape.circle,
                          ),
                          // Strict 24x24dp Icon Dimension Bounding Box
                          child: SizedBox(
                            width: record.iconBoundingBoxDp, // 24dp
                            height: record.iconBoundingBoxDp, // 24dp
                            child: Icon(
                              item.iconData,
                              size: record.iconBoundingBoxDp, // 24dp
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                      SystemVerbIconPanelTokens.vGapXs,
                      Text(
                        item.verbName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.actionDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SystemVerbIconPanelTokens.vGapLg,

            // Data Dictionary 1-to-1 Table for Atomic Data Fields
            Text(
              'Atomic Data Fields (Data Dictionary Mapped)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SystemVerbIconPanelTokens.vGapSm,
            Table(
              border: TableBorder.all(
                color: colorScheme.outlineVariant,
                width: 1,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                _buildTableRow('Version Number', record.versionNumber, theme, colorScheme),
                _buildTableRow('Version Type', record.versionType, theme, colorScheme),
                _buildTableRow('Release Date', record.releaseDate, theme, colorScheme),
                _buildTableRow('Version Status', record.versionStatus, theme, colorScheme),
                _buildTableRow('Version Checksum', record.versionChecksum, theme, colorScheme),
                _buildTableRow('Completion Status', record.completionStatus, theme, colorScheme, isBadge: true),
                _buildTableRow('Action/Event Timestamp', record.actionTimestamp, theme, colorScheme),
                _buildTableRow('User/Session ID', record.userSessionId, theme, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  TableRow _buildTableRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isBadge = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SystemVerbIconPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: SystemVerbIconPanelTokens.onSuccessContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ],
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class SystemVerbIconPanelTokens {
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
            child: SystemVerbIconPanel(),
          ),
        ),
      ),
    ),
  );
}
