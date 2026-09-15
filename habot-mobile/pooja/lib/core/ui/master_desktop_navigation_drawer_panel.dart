/*
 * DPNDL-008-A02 — Master Desktop Navigation Drawer Component
 * 
 * Setup Step (Action): Create the Master Desktop Navigation Drawer component.
 * Metric Name: Primary Navigation Item Count (Floor: 4dp, Target: 8dp, Ceiling: 16dp)
 * Quality Standard: Material Design guidance caps primary navigation at 3-5 top-level destinations for scannability.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class MasterDesktopNavigationDrawerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const MasterDesktopNavigationDrawerPanel({
    super.key,
    this.globalRefId = 'DPNDL-008',
    this.atomicStepRefId = 'DPNDL-008-A02',
    this.sequenceOrder = '11157',
  });

  @override
  State<MasterDesktopNavigationDrawerPanel> createState() =>
      _MasterDesktopNavigationDrawerPanelState();
}

class _MasterDesktopNavigationDrawerPanelState
    extends State<MasterDesktopNavigationDrawerPanel> {
  int _selectedPrimaryIndex = 0;
  bool _isCollapsed = false;

  final List<Map<String, dynamic>> _primaryDestinations = [
    {
      'title': 'Executive Dashboard',
      'icon': Icons.dashboard_rounded,
      'shortcut': '⌘1',
    },
    {
      'title': 'FinOps & Budget',
      'icon': Icons.account_balance_wallet_rounded,
      'shortcut': '⌘2',
    },
    {
      'title': 'System Telemetry',
      'icon': Icons.monitor_heart_rounded,
      'shortcut': '⌘3',
    },
    {
      'title': 'Compliance Gates',
      'icon': Icons.verified_user_rounded,
      'shortcut': '⌘4',
    },
  ];

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'creationDate': DateTime.now().toUtc().toIso8601String(),
      'createdBy': 'Pooja',
      'creationMethod': 'M3_DESKTOP_DRAWER_PATTERN',
      'initialConfiguration': 'WIDTH_256DP_PERMANENT_SIDEBAR',
      'objectId': 'DRAWER-MASTER-DESKTOP-008',
      'completionStatus': 'Pass',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DPNDL-008',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 171,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11157,
        'assigned': 'Pooja',
        'metricName': 'Primary Navigation Item Count',
        'floor': '4dp',
        'target': '8dp',
        'ceiling': '16dp',
        'unit': 'Pass/Fail',
        'standard': 'Caps primary navigation at 3-5 top-level destinations for scannability.',
        'primaryDestinationsCount': _primaryDestinations.length,
        'isCountWithinM3Guidance': _primaryDestinations.length <= 5,
        'sidebarWidth': _isCollapsed ? 72.0 : 256.0,
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
                _buildSidebarSimulation(isCompact),
                AppSpacingTokens.vGapMd,
                _buildToggleRow(),
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
            Icons.vertical_split_rounded,
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
                'Master Desktop Navigation Drawer',
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
                '4 DESTINATIONS (M3 PASS)',
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

  Widget _buildSidebarSimulation(bool isCompact) {
    final drawerWidth = _isCollapsed ? 72.0 : 256.0;

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: drawerWidth,
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
            children: [
              // Drawer Brand Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColorPalette.lightOutline.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColorPalette.brandPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (!_isCollapsed) ...[
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'HABOT CORE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Navigation Destinations (Capped at 4 for scannability)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: _primaryDestinations.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedPrimaryIndex == idx;

                    return ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPrimaryIndex = idx;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColorPalette.brandPrimary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? AppColorPalette.brandPrimary
                                    : AppColorPalette.lightOutline,
                              ),
                              if (!_isCollapsed) ...[
                                const SizedBox(width: 12),
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
                                Text(
                                  item['shortcut'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColorPalette.lightOutline,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sidebar State: ${_isCollapsed ? 'Docked Monogram (72dp)' : 'Permanent Full (256dp)'}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: TextButton.icon(
            icon: Icon(
              _isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              size: 20,
            ),
            label: Text(_isCollapsed ? 'Expand' : 'Collapse'),
            onPressed: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
          ),
        ),
      ],
    );
  }
}
