/*
 * STEP 29: TNRML-007 — Build Responsive Tablet Sidebar Navigation Rail
 * 
 * Setup Step (Action): Open shared front-end UI component repository and locate Master Sidebar Rail Shell.
 * Setup Step Description: Set sidebar conversion breakpoint trigger to 600dp viewport width; lock rail horizontal
 *   width to exactly 80dp; shift bottom navigation to sidebar on wide devices.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Keep critical navigation paths visible while minimizing layout weight on mobile.
 *   - Lock rail horizontal space rules to exactly 80dp at >= 600dp breakpoint.
 *   - Render active navigation items using pill-shape Material Design 3 selection accents.
 * 
 * What Was Done to Complete This Step:
 *   - Created `ResponsiveNavRailPanel` widget and `ResponsiveNavRailRecord` model in a single file.
 *   - Implemented 600dp breakpoint switcher, 80dp locked navigation rail sidebar shell, and viewport width simulation preview.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step TNRML-007 (Row 2034): Responsive Tablet Navigation Rail Record Model.
class ResponsiveNavRailRecord {
  final String repositoryUrl;
  final String repositoryBranch;
  final String accessRights;
  final String commitHistory;
  final String repositoryVersion;
  final String cloneStatus;
  final String completionStatus; // 'Good / Average / Poor'
  final String actionTimestamp;
  final String userSessionId;
  final int navigationClickDepth; // Floor: 1 click, Optimal: 2 clicks, Ceiling: 3 clicks
  final int floorClicks;
  final int optimalClicks;
  final int ceilingClicks;
  final double railWidthDp; // Locked 80dp
  final double breakpointWidthDp; // 600dp trigger

  const ResponsiveNavRailRecord({
    required this.repositoryUrl,
    required this.repositoryBranch,
    required this.accessRights,
    required this.commitHistory,
    required this.repositoryVersion,
    required this.cloneStatus,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
    this.navigationClickDepth = 1,
    this.floorClicks = 1,
    this.optimalClicks = 2,
    this.ceilingClicks = 3,
    this.railWidthDp = 80.0,
    this.breakpointWidthDp = 600.0,
  });

  bool get meetsUsabilityCeiling => navigationClickDepth <= ceilingClicks;
  bool get isOptimalPath => navigationClickDepth <= optimalClicks;
}

/// Step TNRML-007 (Row 2034): Responsive Tablet Sidebar Navigation Rail Shell Panel.
class ResponsiveNavRailPanel extends StatefulWidget {
  final ResponsiveNavRailRecord record;

  const ResponsiveNavRailPanel({
    super.key,
    required this.record,
  });

  @override
  State<ResponsiveNavRailPanel> createState() => _ResponsiveNavRailPanelState();
}

class _ResponsiveNavRailPanelState extends State<ResponsiveNavRailPanel> {
  double _simulatedViewportWidth = 768.0; // Tablet width (above 600dp)
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;
    final isRailMode = _simulatedViewportWidth >= record.breakpointWidthDp;

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
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_sidebar_outlined, color: colorScheme.onSecondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'RESPONSIVE NAV RAIL SHELL',
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
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: Text(
                    'Step 29: TNRML-007 (Row 2034)',
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

            // Navigation Depth & Findability KPI Card
            Container(
              padding: AppSpacingTokens.paddingMd,
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
                            Icon(Icons.ads_click, color: colorScheme.secondary, size: 20),
                            AppSpacingTokens.hGapXs,
                            Expanded(
                              child: Text(
                                'Navigation Depth & Findability (Hick\'s Law / NN/g)',
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
                          color: record.meetsUsabilityCeiling
                              ? AppColorPalette.success
                              : AppColorPalette.lightError,
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
                        '${record.navigationClickDepth} Click',
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
                                value: (4 - record.navigationClickDepth) / 3.0,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(
                              'Floor: 1 click | Typical: 2 clicks | Ceiling: 3 clicks (NN/g 3-Click Rule)',
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
                    'Standard: Core destinations remain reachable within the classic 3-click usability ceiling referenced by Nielsen Norman Group heuristics.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapLg,

            // Viewport Width Breakpoint & 80dp Navigation Rail Shell Simulator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '600dp Breakpoint Viewport Simulator',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isRailMode ? Icons.tablet_mac : Icons.smartphone,
                    size: 16,
                    color: isRailMode ? colorScheme.secondary : colorScheme.primary,
                  ),
                  label: Text(
                    isRailMode
                        ? 'Tablet/Desktop (80dp Navigation Rail)'
                        : 'Mobile Compact (<600dp Bottom Nav)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isRailMode ? colorScheme.secondary : colorScheme.primary,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Slider(
              value: _simulatedViewportWidth,
              min: 360.0,
              max: 1024.0,
              divisions: 66,
              label: '${_simulatedViewportWidth.toStringAsFixed(0)}dp Viewport',
              activeColor: colorScheme.secondary,
              onChanged: (val) {
                setState(() {
                  _simulatedViewportWidth = val;
                });
              },
            ),
            AppSpacingTokens.vGapSm,

            // Live Simulator Container
            Container(
              height: 380,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
              ),
              child: Row(
                children: [
                  // 80dp Locked Navigation Rail (Visible when width >= 600dp)
                  if (isRailMode)
                    SizedBox(
                      width: 80.0, // Locked 80dp Rail width as required by spec
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onDestinationSelected,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        indicatorColor: colorScheme.secondaryContainer, // Pill shape accent
                        labelType: NavigationRailLabelType.selected,
                        minWidth: 80.0,
                        minExtendedWidth: 80.0,
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: FloatingActionButton.small(
                            heroTag: 'rail_top_action_fab',
                            onPressed: () {},
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                            child: const Icon(Icons.add),
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Overview'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.analytics_outlined),
                            selectedIcon: Icon(Icons.analytics),
                            label: Text('Analytics'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: Text('Settings'),
                          ),
                        ],
                      ),
                    ),

                  // Main Content View
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: colorScheme.surface,
                            padding: AppSpacingTokens.paddingMd,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedIndex == 0
                                      ? Icons.dashboard
                                      : _selectedIndex == 1
                                          ? Icons.analytics
                                          : Icons.settings,
                                  size: 48,
                                  color: colorScheme.secondary,
                                ),
                                AppSpacingTokens.vGapSm,
                                Text(
                                  _selectedIndex == 0
                                      ? 'Overview Analytics Dashboard'
                                      : _selectedIndex == 1
                                          ? 'Real-Time Telemetry & Lineage'
                                          : 'System Preferences & Tokens',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                AppSpacingTokens.vGapXs,
                                Text(
                                  isRailMode
                                      ? 'Reclaimed vertical screen space via 80dp Navigation Rail sidebar.'
                                      : 'Compact view (<600dp) rendering bottom navigation.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Navigation Bar for <600dp Mobile Viewport
                        if (!isRailMode)
                          NavigationBar(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: _onDestinationSelected,
                            destinations: const [
                              NavigationDestination(
                                icon: Icon(Icons.dashboard_outlined),
                                selectedIcon: Icon(Icons.dashboard),
                                label: 'Overview',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.analytics_outlined),
                                selectedIcon: Icon(Icons.analytics),
                                label: 'Analytics',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.settings_outlined),
                                selectedIcon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
