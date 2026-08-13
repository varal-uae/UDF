/*
 * STEP 31: EDBAA-015-09 — Package and Lock the Master Component Library
 * 
 * Setup Step (Action): Apply repository access control rules setting uploaded artifact permissions to read-only for developer accounts.
 * Setup Step Description: Compile pre-approved visual view modules into a read-only distribution file to freeze codebase integrity;
 *   ISO 9001:2015 process conformance standard.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Ensure view widgets comply fully with modern WCAG mobile readability indexes.
 *   - Lock sizing scales across layout elements to maintain scannability on all screens.
 *   - Touch interactions trigger immediate, responsive visual click feedback indicators.
 * 
 * What Was Done to Complete This Step:
 *   - Created `MasterLibraryLockPanel` widget, `MasterLibraryLockRecord`, and `PreApprovedViewModuleItem` models.
 *   - Implemented read-only distribution lock verification UI, ISO process adherence meter, and pre-approved module catalog.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step EDBAA-015-09 (Row 2056): Master Component Library Lock Record Model.
class MasterLibraryLockRecord {
  final String repositoryUrl;
  final String repositoryBranch;
  final String accessRights;
  final String commitHistory;
  final String repositoryVersion;
  final String cloneStatus;
  final String completionStatus; // 'Complete/Partial/Not Complete → Best = Complete (100%)'
  final String actionTimestamp;
  final String userSessionId;
  final double processAdherenceRate; // Floor: 90%, Optimal: 100%, Ceiling: 100%
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final bool isLibraryLockedReadOnly;

  const MasterLibraryLockRecord({
    required this.repositoryUrl,
    required this.repositoryBranch,
    required this.accessRights,
    required this.commitHistory,
    required this.repositoryVersion,
    required this.cloneStatus,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
    this.processAdherenceRate = 1.0,
    this.floorBoundary = 0.90,
    this.optimalTarget = 1.00,
    this.ceilingBoundary = 1.00,
    this.isLibraryLockedReadOnly = true,
  });

  bool get meetsFloorBoundary => processAdherenceRate >= floorBoundary;
  bool get meetsOptimalTarget => processAdherenceRate >= optimalTarget;
}

class PreApprovedViewModuleItem {
  final String moduleId;
  final String moduleName;
  final String targetStepCode;
  final bool isLocked;

  const PreApprovedViewModuleItem({
    required this.moduleId,
    required this.moduleName,
    required this.targetStepCode,
    this.isLocked = true,
  });
}

/// Step EDBAA-015-09 (Row 2056): Package and Lock Master Component Library Panel.
class MasterLibraryLockPanel extends StatefulWidget {
  final MasterLibraryLockRecord record;
  final List<PreApprovedViewModuleItem> modules;

  const MasterLibraryLockPanel({
    super.key,
    required this.record,
    required this.modules,
  });

  @override
  State<MasterLibraryLockPanel> createState() => _MasterLibraryLockPanelState();
}

class _MasterLibraryLockPanelState extends State<MasterLibraryLockPanel> {
  void _onModuleTapped(PreApprovedViewModuleItem item) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Module "${item.moduleName}" is LOCKED (Read-Only Version: ${widget.record.repositoryVersion})'),
        backgroundColor: AppColorPalette.brandPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;
    final adherencePercentStr =
        '${(record.processAdherenceRate * 100).toStringAsFixed(0)}%';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar with Step Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColorPalette.brandPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'MASTER COMPONENT LIBRARY LOCK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: Text(
                    'Step 31: EDBAA-015-09 (Row 2056)',
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
            AppSpacingTokens.vGapMd,

            // Process Adherence / Task Completion Rate KPI Card
            Container(
              padding: AppSpacingTokens.paddingMd,
              decoration: BoxDecoration(
                color: AppColorPalette.brandPrimaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorPalette.brandPrimary.withAlpha(60)),
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
                            const Icon(Icons.verified, color: AppColorPalette.brandPrimary, size: 20),
                            AppSpacingTokens.hGapXs,
                            Expanded(
                              child: Text(
                                'Process Adherence / Task Completion Rate',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorPalette.onBrandPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacingTokens.hGapSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.meetsOptimalTarget
                              ? AppColorPalette.success
                              : AppColorPalette.warning,
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
                  AppSpacingTokens.vGapSm,
                  Row(
                    children: [
                      Text(
                        adherencePercentStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColorPalette.brandPrimary,
                        ),
                      ),
                      AppSpacingTokens.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: record.processAdherenceRate,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColorPalette.brandPrimary),
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(
                              'Floor: ≥90% | Optimal: 1.0 | Ceiling: 1.0 (ISO 9001:2015 Conformance)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Standard: ISO 9001:2015 Quality Management — Process Conformance Standard.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapLg,

            // Read-Only Repository Access Control & Codebase Freeze Status Banner
            Container(
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: AppColorPalette.successContainer.withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColorPalette.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColorPalette.success, size: 18),
                  AppSpacingTokens.hGapSm,
                  Expanded(
                    child: Text(
                      'Codebase Integrity Frozen: Version ${record.repositoryVersion} • Permissions: ${record.accessRights}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColorPalette.onSuccessContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapLg,

            // Crisp Boundary Tabular Display for Pre-Approved View Modules
            Text(
              'Pre-Approved Visual View Modules (Crisp Tabular Boundaries • Tap to Inspect)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacingTokens.vGapSm,
            Table(
              border: TableBorder.all(
                color: colorScheme.outlineVariant,
                width: 1.5, // Crisp boundary dividing tabular layout display cleanly
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  children: [
                    _buildHeaderCell('Module ID', theme, colorScheme),
                    _buildHeaderCell('Module Name', theme, colorScheme),
                    _buildHeaderCell('Target Step Code', theme, colorScheme),
                    _buildHeaderCell('Status', theme, colorScheme),
                  ],
                ),
                ...widget.modules.map((m) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                    ),
                    children: [
                      _buildBodyCell(m.moduleId, theme, colorScheme),
                      _buildBodyCell(m.moduleName, theme, colorScheme, isClickable: true, onItemTap: () => _onModuleTapped(m)),
                      _buildBodyCell(m.targetStepCode, theme, colorScheme),
                      _buildBadgeCell('READ-ONLY', theme, colorScheme),
                    ],
                  );
                }),
              ],
            ),
            AppSpacingTokens.vGapLg,

            // Data Dictionary 1-to-1 Table for Atomic Data Fields
            Text(
              'Atomic Data Fields (Data Dictionary Mapped)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacingTokens.vGapSm,
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
                _buildTableRow('Repository URL', record.repositoryUrl, theme, colorScheme),
                _buildTableRow('Repository Branch', record.repositoryBranch, theme, colorScheme),
                _buildTableRow('Access Rights', record.accessRights, theme, colorScheme),
                _buildTableRow('Commit History', record.commitHistory, theme, colorScheme),
                _buildTableRow('Repository Version', record.repositoryVersion, theme, colorScheme),
                _buildTableRow('Clone Status', record.cloneStatus, theme, colorScheme),
                _buildTableRow('Completion Status', record.completionStatus, theme, colorScheme, isBadge: true),
                _buildTableRow('Action/Event Timestamp', record.actionTimestamp, theme, colorScheme),
                _buildTableRow('User/Session ID', record.userSessionId, theme, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBodyCell(
    String text,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isClickable = false,
    VoidCallback? onItemTap,
  }) {
    final cellText = Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isClickable ? AppColorPalette.brandPrimary : colorScheme.onSurfaceVariant,
        fontWeight: isClickable ? FontWeight.bold : FontWeight.normal,
      ),
    );

    if (isClickable && onItemTap != null) {
      return InkWell(
        onTap: onItemTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: cellText,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: cellText,
    );
  }

  Widget _buildBadgeCell(String text, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColorPalette.successContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColorPalette.onSuccessContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColorPalette.onSuccessContainer,
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
