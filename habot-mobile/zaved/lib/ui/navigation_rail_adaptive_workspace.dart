// ============================================================================
// TELEMETRY METADATA BLOCK
// Step Execution ID: ANSA-020-09-EXEC-77291
// Execution Status: SUCCESS
// Execution Timestamp: 2026-08-19T15:19:52+05:30
// Step Outcome: PASS - Navigation Rail Adaptive Mapping (>=600dp) Verified
// User ID: USR-ANSA-020-09-RAIL
// Completion Status: Target: Complete - Requirement & Asset Discovery Coverage
// ============================================================================

import 'package:flutter/material.dart';

/// ANSA-020-09: Navigation Rail Adaptive Workspace
///
/// Isolates and demonstrates the M3 NavigationRail mapping for Medium/Expanded (>=600dp)
/// viewports vs NavigationBar for Compact (<600dp) viewports.
class NavigationRailAdaptiveWorkspace extends StatefulWidget {
  const NavigationRailAdaptiveWorkspace({super.key});

  @override
  State<NavigationRailAdaptiveWorkspace> createState() =>
      _NavigationRailAdaptiveWorkspaceState();
}

class _NavigationRailAdaptiveWorkspaceState
    extends State<NavigationRailAdaptiveWorkspace> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  final List<Map<String, dynamic>> _railItems = const [
    {
      'label': 'Analytics',
      'icon': Icons.insights,
      'description': 'Real-time telemetry and metrics stream.',
    },
    {
      'label': 'Security Keys',
      'icon': Icons.key,
      'description': 'CMEK key rotation and audit logs.',
    },
    {
      'label': 'Workflows',
      'icon': Icons.account_tree,
      'description': 'Automated pipeline progression gates.',
    },
    {
      'label': 'Settings',
      'icon': Icons.tune,
      'description': 'Global environment configuration.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation Rail Adaptive Workspace (ANSA-020-09)"),
        actions: [
          IconButton(
            icon: Icon(_isExtended ? Icons.view_headline : Icons.view_stream),
            tooltip: "Toggle Rail Extended State",
            onPressed: () {
              setState(() {
                _isExtended = !_isExtended;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMediumOrExpanded = constraints.maxWidth >= 600;
            final selectedItem = _railItems[_selectedIndex];

            Widget mainPane = SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Viewport Status Indicator Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMediumOrExpanded
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isMediumOrExpanded
                              ? Icons.desktop_windows
                              : Icons.smartphone,
                          color: isMediumOrExpanded
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMediumOrExpanded
                                    ? "MEDIUM / EXPANDED VIEWPORT (>=600dp)"
                                    : "COMPACT MOBILE VIEWPORT (<600dp)",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isMediumOrExpanded
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                              Text(
                                isMediumOrExpanded
                                    ? "Active Component: NavigationRail (Extended: $_isExtended)"
                                    : "Active Component: Bottom NavigationBar",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isMediumOrExpanded
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selected Tab Content Details
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                child: Icon(
                                  selectedItem['icon'] as IconData,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedItem['label'] as String,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "ANSA-020-09 Isolated Route #${_selectedIndex + 1}",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Text(
                            selectedItem['description'] as String,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Triggered ${selectedItem['label']} action!",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.touch_app),
                            label: Text("Execute ${selectedItem['label']} Action"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isMediumOrExpanded) {
              // NavigationRail mapping to Medium/Expanded (>=600dp) viewport states
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    extended: _isExtended,
                    minExtendedWidth: 180,
                    labelType: _isExtended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FloatingActionButton.small(
                        elevation: 0,
                        onPressed: () {
                          setState(() {
                            _isExtended = !_isExtended;
                          });
                        },
                        child: Icon(
                          _isExtended ? Icons.menu_open : Icons.menu,
                        ),
                      ),
                    ),
                    destinations: _railItems
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item['icon'] as IconData),
                            selectedIcon: Icon(item['icon'] as IconData),
                            label: Text(item['label'] as String),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: mainPane),
                ],
              );
            } else {
              // Compact Mobile Viewport (<600dp): NavigationBar
              return Column(
                children: [
                  Expanded(child: mainPane),
                  NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    destinations: _railItems
                        .map(
                          (item) => NavigationDestination(
                            icon: Icon(item['icon'] as IconData),
                            label: item['label'] as String,
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
