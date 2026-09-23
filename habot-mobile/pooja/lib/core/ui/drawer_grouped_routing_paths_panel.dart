/*
 * DPNDL-007-A05 — Drawer Grouped Routing Paths Panel
 * 
 * Setup Step (Action): Group routing paths into logical sections/categories within the drawer.
 * Metric Name: Architecture Pattern Adherence & Code Quality (Floor: Present, Target: 98%, Ceiling: 100%)
 * Quality Standard: Feature complete, zero lint/static-analysis warnings, peer-validated against approved pattern.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

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
            ? DrawerGroupedRoutingPathsPanelTokens.paddingSm
            : (isExpanded ? DrawerGroupedRoutingPathsPanelTokens.paddingLg : DrawerGroupedRoutingPathsPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: DrawerGroupedRoutingPathsPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                DrawerGroupedRoutingPathsPanelTokens.vGapMd,
                _buildGroupedDrawerPreview(isCompact),
                DrawerGroupedRoutingPathsPanelTokens.vGapMd,
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
            color: DrawerGroupedRoutingPathsPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            color: DrawerGroupedRoutingPathsPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        DrawerGroupedRoutingPathsPanelTokens.hGapMd,
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
              DrawerGroupedRoutingPathsPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DrawerGroupedRoutingPathsPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DrawerGroupedRoutingPathsPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DrawerGroupedRoutingPathsPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: DrawerGroupedRoutingPathsPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                '4 SECTIONS GROUPED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: DrawerGroupedRoutingPathsPanelTokens.success,
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
      padding: const EdgeInsets.all(DrawerGroupedRoutingPathsPanelTokens.md),
      decoration: BoxDecoration(
        color: DrawerGroupedRoutingPathsPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DrawerGroupedRoutingPathsPanelTokens.lightOutline.withValues(alpha: 0.2),
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
              color: DrawerGroupedRoutingPathsPanelTokens.lightOutline.withValues(alpha: 0.2),
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
                        color: DrawerGroupedRoutingPathsPanelTokens.lightOutline,
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
                                ? DrawerGroupedRoutingPathsPanelTokens.brandPrimary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected
                                ? Border.all(
                                    color: DrawerGroupedRoutingPathsPanelTokens.brandPrimary.withValues(alpha: 0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? DrawerGroupedRoutingPathsPanelTokens.brandPrimary
                                    : DrawerGroupedRoutingPathsPanelTokens.lightOutline,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? DrawerGroupedRoutingPathsPanelTokens.brandPrimary : Colors.black87,
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
                                        ? DrawerGroupedRoutingPathsPanelTokens.brandPrimary.withValues(alpha: 0.2)
                                        : DrawerGroupedRoutingPathsPanelTokens.lightOutline.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['badge'] as String,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? DrawerGroupedRoutingPathsPanelTokens.brandPrimary
                                          : DrawerGroupedRoutingPathsPanelTokens.lightOutline,
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
      padding: const EdgeInsets.all(DrawerGroupedRoutingPathsPanelTokens.sm),
      decoration: BoxDecoration(
        color: DrawerGroupedRoutingPathsPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: DrawerGroupedRoutingPathsPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Enforces 256dp structural width cap and groups multi-tier enterprise tooling paths into clean, scannable domains.',
              style: TextStyle(
                fontSize: 11,
                color: DrawerGroupedRoutingPathsPanelTokens.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class DrawerGroupedRoutingPathsPanelTokens {
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
            child: DrawerGroupedRoutingPathsPanel(),
          ),
        ),
      ),
    ),
  );
}
