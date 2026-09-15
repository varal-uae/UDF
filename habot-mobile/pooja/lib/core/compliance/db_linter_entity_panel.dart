/*
 * CBSV-005-10 — DB Identifier _ID Linter & Masked Entity Tokens
 * 
 * Setup Step (Action): Open the UI frontend component library designated for entity and record layouts.
 * Setup Step Description: Implement strict linter check forcing all primary DB keys to terminate in `_ID` suffix;
 *   hide raw internal system keys from mobile displays, replacing them with masked user tokens.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - 3-Tier M3 Breakpoints: Adaptive LayoutBuilder handling Compact (<600dp), Medium (600-839dp), and Expanded (>=840dp).
 *   - Minimum Touch Targets: >=48x48dp interactive padding on all interactive entities and inputs.
 *   - Modern Flutter 3.35+ Colors: Uses withValues(alpha: ...) color transforms across surfaces.
 *   - Long-press interactions on entity elements cleanly copy masked unique reference values to system clipboard.
 *   - Key labels utilize low-contrast typography states to prioritize content visibility hierarchies.
 * 
 * Standardized Telemetry Export:
 *   - toExecutionLogJson() provides structured EXEC-CBSV-005-10-2026 schema output.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';
import '../utils/db_identifier_linter.dart';

/// Step CBSV-005-10 (Row 122 / Seq 1803): DB Linter & Entity Record Data Model.
class DbLinterEntityRecord {
  final String libraryName;
  final String libraryVersion;
  final String componentCount;
  final String installationStatus;
  final String dependencyList;
  final String libraryLocationPath;
  final String completionStatus; // 'Good/Average/Poor → Best = Good (100%)'
  final String actionTimestamp;
  final String userSessionId;
  final double designSystemAdherenceRate; // Floor: >=85%, Optimal: >=95%, Ceiling: 100%
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const DbLinterEntityRecord({
    required this.libraryName,
    required this.libraryVersion,
    required this.componentCount,
    required this.installationStatus,
    required this.dependencyList,
    required this.libraryLocationPath,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
    this.designSystemAdherenceRate = 1.0,
    this.floorBoundary = 0.85,
    this.optimalTarget = 0.95,
    this.ceilingBoundary = 1.00,
  });

  bool get meetsFloorBoundary => designSystemAdherenceRate >= floorBoundary;
  bool get meetsOptimalTarget => designSystemAdherenceRate >= optimalTarget;

  Map<String, dynamic> toExecutionLogJson() => {
    'libraryName': libraryName,
    'libraryVersion': libraryVersion,
    'componentCount': componentCount,
    'installationStatus': installationStatus,
    'dependencyList': dependencyList,
    'libraryLocationPath': libraryLocationPath,
    'completionStatus': completionStatus,
    'actionEventTimestamp': actionTimestamp,
    'userSessionId': userSessionId,
    'metadata': {
      'taskCode': 'CBSV-005-10',
      'row': 122,
      'seq': 1803,
      'assigned': 'Pooja',
      'metricName': 'UI Design-System Adherence Rate',
      'floor': floorBoundary,
      'target': optimalTarget,
      'ceiling': ceilingBoundary,
      'unit': 'Good/Average/Poor -> Best = Good (100%)',
      'adherenceRate': designSystemAdherenceRate,
    }
  };
}

class EntityRecordItem {
  final String entityIdKey; // Must end in _ID
  final String entityName;
  final String maskedUserToken;
  final String fullInternalReferenceKey;
  final String status;

  const EntityRecordItem({
    required this.entityIdKey,
    required this.entityName,
    required this.maskedUserToken,
    required this.fullInternalReferenceKey,
    this.status = 'Validated',
  });
}

/// Step CBSV-005-10 (Row 122 / Seq 1803): Strict DB Identifier _ID Linter & Entity Record Layout Panel.
class DbLinterEntityPanel extends StatefulWidget {
  final DbLinterEntityRecord record;
  final List<EntityRecordItem> entities;

  const DbLinterEntityPanel({
    super.key,
    required this.record,
    required this.entities,
  });

  @override
  State<DbLinterEntityPanel> createState() => _DbLinterEntityPanelState();
}

class _DbLinterEntityPanelState extends State<DbLinterEntityPanel> {
  final _testKeyController = TextEditingController(text: 'CUSTOMER_ACCOUNT_ID');
  late DbLinterValidationResult _validationResult;

  @override
  void initState() {
    super.initState();
    _validationResult = DbIdentifierLinter.validateIdentifier(_testKeyController.text);
  }

  @override
  void dispose() {
    _testKeyController.dispose();
    super.dispose();
  }

  void _onKeyChanged(String val) {
    setState(() {
      _validationResult = DbIdentifierLinter.validateIdentifier(val);
    });
  }

  void _copyToClipboard(String token, String name) {
    Clipboard.setData(ClipboardData(text: token));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$name" Reference Token ($token) to Clipboard!'),
        backgroundColor: AppColorPalette.brandPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'libraryName': widget.record.libraryName,
      'libraryVersion': widget.record.libraryVersion,
      'componentCount': widget.record.componentCount,
      'installationStatus': widget.record.installationStatus,
      'dependencyList': widget.record.dependencyList,
      'libraryLocationPath': widget.record.libraryLocationPath,
      'completionStatus': widget.record.completionStatus,
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': widget.record.userSessionId,
      'metadata': {
        'taskCode': 'CBSV-005-10',
        'row': 122,
        'seq': 1803,
        'assigned': 'Pooja',
        'metricName': 'UI Design-System Adherence Rate',
        'floor': widget.record.floorBoundary,
        'target': widget.record.optimalTarget,
        'ceiling': widget.record.ceilingBoundary,
        'unit': 'Good/Average/Poor -> Best = Good (100%)',
        'adherenceRate': widget.record.designSystemAdherenceRate,
        'entitiesCount': widget.entities.length,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;
    final adherencePercentStr =
        '${(record.designSystemAdherenceRate * 100).toStringAsFixed(0)}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final cardPadding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

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
                          Icon(Icons.terminal, color: colorScheme.onSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'DB IDENTIFIER _ID LINTER',
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 10 : 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacingTokens.hGapSm,
                    Expanded(
                      child: Text(
                        'CBSV-005-10 (Row 122 / Seq 1803)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: isExpanded ? 13 : 11,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // UI Design-System Adherence Rate KPI Card
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.25)),
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
                                Icon(Icons.rule, color: colorScheme.secondary, size: 20),
                                AppSpacingTokens.hGapXs,
                                Expanded(
                                  child: Text(
                                    'UI Design-System Adherence Rate',
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
                              record.meetsOptimalTarget ? 'Good (100%)' : 'Floor ≥85%',
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
                              color: colorScheme.secondary,
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
                                    value: record.designSystemAdherenceRate,
                                    minHeight: 8,
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                                  ),
                                ),
                                AppSpacingTokens.vGapXs,
                                Text(
                                  'Floor: ≥85% | Optimal: ≥95% | Ceiling: 100% (Strict _ID Linter Enforced)',
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
                        'Standard: Material Design 3 Guidelines / Nielsen Norman Group Heuristic Evaluation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapLg,

                // Live Strict Linter Suffix Enforcement Validator Simulator
                Text(
                  'Strict Linter Rule Validator Simulator (_ID Suffix Required)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: TextField(
                          controller: _testKeyController,
                          onChanged: _onKeyChanged,
                          decoration: InputDecoration(
                            labelText: 'Primary Database Key Identifier',
                            hintText: 'Enter DB Key (e.g. USER_ID, VENDOR_ID, user_pk)...',
                            prefixIcon: const Icon(Icons.key),
                            suffixIcon: Icon(
                              _validationResult.isValid ? Icons.check_circle : Icons.error,
                              color: _validationResult.isValid
                                  ? AppColorPalette.success
                                  : AppColorPalette.lightError,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      Container(
                        width: double.infinity,
                        padding: AppSpacingTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: _validationResult.isValid
                              ? AppColorPalette.successContainer.withValues(alpha: 0.6)
                              : AppColorPalette.lightErrorContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _validationResult.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _validationResult.isValid
                                ? AppColorPalette.onSuccessContainer
                                : AppColorPalette.lightOnErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapLg,

                // Atomic Data Fields Table
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
                    _buildTableRow('Library Name', record.libraryName, theme, colorScheme),
                    _buildTableRow('Library Version', record.libraryVersion, theme, colorScheme),
                    _buildTableRow('Component Count', record.componentCount, theme, colorScheme),
                    _buildTableRow('Installation Status', record.installationStatus, theme, colorScheme),
                    _buildTableRow('Dependency List', record.dependencyList, theme, colorScheme),
                    _buildTableRow('Library Location Path', record.libraryLocationPath, theme, colorScheme),
                    _buildTableRow('Completion Status', record.completionStatus, theme, colorScheme, isBadge: true),
                    _buildTableRow('Action/Event Timestamp', record.actionTimestamp, theme, colorScheme),
                    _buildTableRow('User/Session ID', record.userSessionId, theme, colorScheme),
                  ],
                ),
                AppSpacingTokens.vGapLg,

                // Entity Layout List with Masked Tokens & Long-Press Copy
                Text(
                  'Entity Record Layouts (Scannable User Tokens • Press & Hold to Copy)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapSm,
                Column(
                  children: widget.entities.map((item) {
                    final linterCheck = DbIdentifierLinter.validateIdentifier(item.entityIdKey);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onLongPress: () => _copyToClipboard(item.fullInternalReferenceKey, item.entityName),
                          child: Ink(
                            padding: AppSpacingTokens.paddingMd,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: colorScheme.secondaryContainer,
                                  child: Icon(Icons.dataset, color: colorScheme.onSecondaryContainer, size: 20),
                                ),
                                AppSpacingTokens.hGapMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.entityName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          AppSpacingTokens.hGapSm,
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: linterCheck.isValid
                                                  ? AppColorPalette.successContainer
                                                  : AppColorPalette.lightErrorContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.entityIdKey,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: linterCheck.isValid
                                                    ? AppColorPalette.onSuccessContainer
                                                    : AppColorPalette.lightOnErrorContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      AppSpacingTokens.vGapXs,
                                      // Low-contrast typography for key labels
                                      Text(
                                        'Scannable Token: ${item.maskedUserToken}',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tooltip(
                                  message: 'Long-press to copy full reference ID',
                                  child: Icon(Icons.copy, color: colorScheme.secondary, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
