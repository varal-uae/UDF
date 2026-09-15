/*
 * DPNDL-007-A05 — Drawer Grouped Routing Paths Panel
 * 
 * Setup Step (Action): Group routing paths into logical sections/categories within the drawer.
 * Metric Name: Architecture Pattern Adherence & Code Quality (Floor: Present, Target: 98%, Ceiling: 100%)
 * Quality Standard: Feature complete, zero lint/static-analysis warnings, peer-validated against approved pattern.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class DrawerGroupedRoutingPathsPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const DrawerGroupedRoutingPathsPanel({
    super.key,
    this.globalRefId = 'DPNDL-007',
    this.atomicStepRefId = 'DPNDL-007-A05',
    this.sequenceOrder = '11142',
  });

  @override
  State<DrawerGroupedRoutingPathsPanel> createState() =>
      _DrawerGroupedRoutingPathsPanelState();
}

class _DrawerGroupedRoutingPathsPanelState
    extends State<DrawerGroupedRoutingPathsPanel> {
  String _selectedPathId = 'op-1';

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'OPERATIONS',
      'items': [
        {'id': 'op-1', 'title': 'Telemetry Hub', 'icon': Icons.stream_rounded, 'badge': 'Live'},
        {'id': 'op-2', 'title': 'Pipeline Monitor', 'icon': Icons.insights_rounded, 'badge': null},
        {'id': 'op-3', 'title': 'Sync Status Matrix', 'icon': Icons.sync_alt_rounded, 'badge': '24/7'},
      ],
    },
    {
      'title': 'GOVERNANCE & COMPLIANCE',
      'items': [
        {'id': 'gov-1', 'title': 'VAT Audit Engine', 'icon': Icons.account_balance_rounded, 'badge': 'UAE FTA'},
        {'id': 'gov-2', 'title': '3-Strike Policy Gate', 'icon': Icons.gavel_rounded, 'badge': null},
        {'id': 'gov-3', 'title': 'Token Lifetime Scanner', 'icon': Icons.timer_rounded, 'badge': '5m'},
      ],
    },
    {
      'title': 'DESIGN SYSTEM CORE',
      'items': [
        {'id': 'ds-1', 'title': 'Breakpoint Token Registry', 'icon': Icons.view_quilt_rounded, 'badge': 'M3'},
        {'id': 'ds-2', 'title': 'Fluid Media Guidelines', 'icon': Icons.video_library_rounded, 'badge': null},
        {'id': 'ds-3', 'title': 'Brand Identity Module', 'icon': Icons.branding_watermark_rounded, 'badge': null},
      ],
    },
    {
      'title': 'ADMINISTRATION',
      'items': [
        {'id': 'adm-1', 'title': 'Master Access Roles', 'icon': Icons.admin_panel_settings_rounded, 'badge': 'Root'},
        {'id': 'adm-2', 'title': 'Serverless Ingress', 'icon': Icons.cloud_done_rounded, 'badge': null},
      ],
    },
  ];

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-DPNDL-007-2026',
      'executionStatus': 'ROUTING_PATHS_GROUPED',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'LOGICAL_GROUPING_COMPLETE',
      'userId': 'USER-AUTO-B17',
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DPNDL-007',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 170,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11142,
        'assigned': 'Pooja',
        'metricName': 'Architecture Pattern Adherence & Code Quality',
        'floor': 'Feature present',
        'target': 'Passes static analysis & architecture pattern',
        'ceiling': 'Zero lint warnings, peer-validated',
        'unit': 'Complete',
        'totalSections': _sections.length,
        'totalGroupedRoutes': 11,
        'activePathId': _selectedPathId,
        'drawerWidthCap': 256.0,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final padding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                AppSpacingTokens.vGapMd,
                _buildGroupedDrawerPreview(isCompact),
                AppSpacingTokens.vGapMd,
                _buildArchitecturePatternFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.account_tree_rounded,
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
                'Drawer Grouped Routing Paths Architecture',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              AppSpacingTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColorPalette.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColorPalette.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColorPalette.success, size: 14),
              SizedBox(width: 4),
              Text(
                '4 SECTIONS GROUPED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColorPalette.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedDrawerPreview(bool isCompact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Container(
          width: 256.0, // Strict 256dp horizontal structural cap
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _sections.map((sec) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      sec['title'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColorPalette.lightOutline,
                      ),
                    ),
                  ),
                  // Group Items
                  ...((sec['items'] as List<Map<String, dynamic>>).map((item) {
                    final isSelected = _selectedPathId == item['id'];
                    return ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPathId = item['id'] as String;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColorPalette.brandPrimary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected
                                ? Border.all(
                                    color: AppColorPalette.brandPrimary.withValues(alpha: 0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? AppColorPalette.brandPrimary
                                    : AppColorPalette.lightOutline,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColorPalette.brandPrimary : Colors.black87,
                                  ),
                                ),
                              ),
                              if (item['badge'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColorPalette.brandPrimary.withValues(alpha: 0.2)
                                        : AppColorPalette.lightOutline.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['badge'] as String,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColorPalette.brandPrimary
                                          : AppColorPalette.lightOutline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
                  const Divider(height: 12, thickness: 0.5),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildArchitecturePatternFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColorPalette.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Enforces 256dp structural width cap and groups multi-tier enterprise tooling paths into clean, scannable domains.',
              style: TextStyle(
                fontSize: 11,
                color: AppColorPalette.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
