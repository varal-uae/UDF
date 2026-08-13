/*
 * STEP 30: FEBFL-005 — Enforce Private Flutter Pub Package Component Imports
 * 
 * Setup Step (Action): Locate all frontend repository root folders in the codebase.
 * Setup Step Description: Enforce clean contextual split-screen view frameworks uniformly; enforce minimum 48x48dp
 *   touch target boundaries; block local custom CSS / styling overrides via automated linter.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Enforce clean contextual split-screen view frameworks uniformly across responsive designs.
 *   - Minimum touch area boundaries on selection elements (48dpx48dp).
 *   - Layout compiler rejects custom styling tweaks, preventing visual layout drift on mobile devices.
 * 
 * What Was Done to Complete This Step:
 *   - Created `PrivatePackageEnforcementPanel` widget and `PrivatePackageEnforcementRecord` model in a single file.
 *   - Integrated `FlutterPubPackageLinter` static analysis rules to enforce private component library package imports.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';
import '../utils/flutter_pub_package_linter.dart';

/// Step FEBFL-005 (Row 2045): Private Pub Package Enforcement Record Model.
class PrivatePackageEnforcementRecord {
  final String repositoryUrl;
  final String repositoryBranch;
  final String accessRights;
  final String commitHistory;
  final String repositoryVersion;
  final String cloneStatus;
  final String completionStatus; // 'Pass/Fail'
  final String actionTimestamp;
  final String userSessionId;
  final double accessConfirmationRate; // Floor: 80%, Optimal: 95%, Ceiling: 100%
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const PrivatePackageEnforcementRecord({
    required this.repositoryUrl,
    required this.repositoryBranch,
    required this.accessRights,
    required this.commitHistory,
    required this.repositoryVersion,
    required this.cloneStatus,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
    this.accessConfirmationRate = 0.95,
    this.floorBoundary = 0.80,
    this.optimalTarget = 0.95,
    this.ceilingBoundary = 1.00,
  });

  bool get meetsFloorBoundary => accessConfirmationRate >= floorBoundary;
  bool get meetsOptimalTarget => accessConfirmationRate >= optimalTarget;
}

/// Step FEBFL-005 (Row 2045): Enforce Private Package Component Imports Panel.
class PrivatePackageEnforcementPanel extends StatefulWidget {
  final PrivatePackageEnforcementRecord record;

  const PrivatePackageEnforcementPanel({
    super.key,
    required this.record,
  });

  @override
  State<PrivatePackageEnforcementPanel> createState() =>
      _PrivatePackageEnforcementPanelState();
}

class _PrivatePackageEnforcementPanelState
    extends State<PrivatePackageEnforcementPanel> {
  late TextEditingController _codeController;
  late FlutterPubLinterResult _linterResult;

  static const String _sampleCompliantScript = '''
import 'package:flutter/material.dart';
import 'package:flutter_app_aiss/flutter_m3_components.dart';

class CompliantView extends StatelessWidget {
  const CompliantView({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatusPillBadge(label: 'ACTIVE');
  }
}''';

  static const String _sampleAdHocScript = '''
import 'package:flutter/material.dart';

class CustomAdHocWidget extends StatelessWidget { // ERROR: Ad-hoc custom widget blocked
  const CustomAdHocWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red);
  }
}''';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: _sampleCompliantScript);
    _linterResult = FlutterPubPackageLinter.validateDartImport(_codeController.text);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String val) {
    setState(() {
      _linterResult = FlutterPubPackageLinter.validateDartImport(val);
    });
  }

  void _loadSample(String sample) {
    _codeController.text = sample;
    _onCodeChanged(sample);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;
    final accessPercentStr =
        '${(record.accessConfirmationRate * 100).toStringAsFixed(0)}%';

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
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: colorScheme.onPrimary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'PRIVATE PUB PACKAGE ENFORCEMENT',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
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
                    'Step 30: FEBFL-005 (Row 2045)',
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

            // Asset/Resource Location & Access Confirmation KPI Card
            Container(
              padding: AppSpacingTokens.paddingMd,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withAlpha(60)),
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
                            Icon(Icons.verified_user_outlined, color: colorScheme.primary, size: 20),
                            AppSpacingTokens.hGapXs,
                            Expanded(
                              child: Text(
                                'Asset/Resource Location & Access Confirmation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
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
                        accessPercentStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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
                                value: record.accessConfirmationRate,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(
                              'Floor: 80% | Optimal: 95% | Ceiling: 100% (Authoritative Private Pub Source)',
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
                    'Standard: Target resource should be reachable from one authoritative, documented location; ad-hoc paths are upgraded to a referenced source of truth.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapLg,

            // Private Flutter Pub Package Linter Simulator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Private Flutter Pub Package Compiler Linter Simulator',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    OutlinedButton(
                      onPressed: () => _loadSample(_sampleCompliantScript),
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Load Compliant Pub Import'),
                    ),
                    OutlinedButton(
                      onPressed: () => _loadSample(_sampleAdHocScript),
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Load Non-Compliant Ad-Hoc'),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Container(
              padding: AppSpacingTokens.paddingMd,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _codeController,
                    onChanged: _onCodeChanged,
                    maxLines: 6,
                    style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      labelText: 'Dart Source Code File',
                      hintText: 'Enter Dart file content...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  AppSpacingTokens.vGapSm,
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingSm,
                    decoration: BoxDecoration(
                      color: _linterResult.isCompliant
                          ? AppColorPalette.successContainer.withAlpha(150)
                          : AppColorPalette.lightErrorContainer.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _linterResult.isCompliant
                            ? AppColorPalette.success
                            : AppColorPalette.lightError,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _linterResult.isCompliant ? Icons.check_circle : Icons.error,
                          color: _linterResult.isCompliant
                              ? AppColorPalette.success
                              : AppColorPalette.lightError,
                          size: 18,
                        ),
                        AppSpacingTokens.hGapSm,
                        Expanded(
                          child: Text(
                            _linterResult.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _linterResult.isCompliant
                                  ? AppColorPalette.onSuccessContainer
                                  : AppColorPalette.lightOnErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapLg,

            // Contextual Split-Screen View Framework (evidence_panel_left & action_form_right)
            Text(
              'Contextual Split-Screen Framework (12-Column Grid • 48dp Touch Targets)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacingTokens.vGapSm,
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                Widget evidencePanelLeft = Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory, color: colorScheme.primary, size: 20),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'evidence_panel_left',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Package Registry: package:flutter_app_aiss/flutter_m3_components.dart',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      AppSpacingTokens.vGapXs,
                      Text(
                        '• Grid Parameters: Grid_Columns_12\n• Minimum Touch Area: Touch_Target_48dp\n• Package Version: v5.0.0-private-pub',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );

                Widget actionFormRight = Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withAlpha(100), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: colorScheme.primary, size: 20),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'action_form_right',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      // Standardized 48dp x 48dp Minimum Touch Area Selection Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.0, // Minimum 48dp touch target
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_done),
                          label: const Text('Confirm Private Pub Package Link (48dp Touch Target)'),
                        ),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: evidencePanelLeft),
                      AppSpacingTokens.hGapMd,
                      Expanded(child: actionFormRight),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      evidencePanelLeft,
                      AppSpacingTokens.vGapMd,
                      actionFormRight,
                    ],
                  );
                }
              },
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
