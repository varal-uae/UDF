// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Master Top Application Bar Showcase & Scaffold Layout
// Component Hierarchy: GlobalAppBarShowcase -> GlobalAppBar -> MD3 Action Buttons
// Layout Rules: Strict 64.0dp vertical height & min 48x48dp phantom hit targets
// Completion Status: Complete (Ref: DPNDL-011-A01)
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/global_app_bar.dart';

/// DPNDL-011-A01: Master Global Top App Bar Interactive Showcase
/// Demonstrates the strict 64dp height, phantom padding touch targets, and compile-time linkages.
class GlobalAppBarShowcase extends StatefulWidget {
  const GlobalAppBarShowcase({super.key});

  @override
  State<GlobalAppBarShowcase> createState() => _GlobalAppBarShowcaseState();
}

class _GlobalAppBarShowcaseState extends State<GlobalAppBarShowcase> {
  String _activeRouteTitle = 'Executive Operational Dashboard';
  int _menuTapCount = 0;
  int _actionTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live GlobalAppBar Embedded Instance
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                GlobalAppBar(
                  activeRouteTitle: _activeRouteTitle,
                  onMenuTapped: () {
                    setState(() => _menuTapCount++);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menu tapped! Total taps: $_menuTapCount'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() => _actionTapCount++);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Search action triggered'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      splashRadius: 24.0,
                      tooltip: 'Search Records',
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active_outlined),
                      onPressed: () {
                        setState(() => _actionTapCount++);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications action triggered'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      constraints: const BoxConstraints(
                        minWidth: 48.0,
                        minHeight: 48.0,
                      ),
                      splashRadius: 24.0,
                      tooltip: 'Alerts',
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: Center(
                    child: Text(
                      'Content viewport below fixed 64dp header with phantom hit boxes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        // Interactive Controls Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Header Specifications & Poka-Yoke Gates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.height),
                  title: const Text('Strict Height: 64.0 dp'),
                  subtitle: const Text('preferredSize locked to Size.fromHeight(64.0) to prevent clipping.'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.touch_app),
                  title: const Text('Phantom Padding: 48x48 dp Hit Box'),
                  subtitle: const Text('All IconButtons enforce minimum 48dp width and height.'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.security),
                  title: const Text('Compile-Time Routing Linkage Safety'),
                  subtitle: const Text('Required non-nullable callbacks guarantee routing connectivity at build time.'),
                ),
                const Divider(height: 24),
                Text(
                  'Switch Active Route Title:',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Executive Operational Dashboard',
                    'Security & Compliance Console',
                    'Real-Time Telemetry Matrix',
                  ]
                      .map(
                        (title) => ChoiceChip(
                          label: Text(title),
                          selected: _activeRouteTitle == title,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _activeRouteTitle = title);
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
