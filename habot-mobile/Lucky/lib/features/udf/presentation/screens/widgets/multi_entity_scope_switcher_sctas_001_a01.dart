// SCTAS-001-A01 — Multi-Entity Scope Switcher Component.
// A thumb-friendly 48x48px master entity switcher pinned top-left within the global header, enforcing strict token-based styling and WCAG-compliant Material 3 design tokens with dark mode support.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level entity scope items.
/// In production, this would be hydrated via a Pub/Sub schema request mapped to local state.
final List<Map<String, dynamic>> _mockScopeEntities = [
  {'id': 'ent_001', 'name': 'Habot UAE', 'type': 'region', 'monogram': 'HU'},
  {'id': 'ent_002', 'name': 'Habot KSA', 'type': 'region', 'monogram': 'HK'},
  {'id': 'ent_003', 'name': 'Project Alpha', 'type': 'project', 'monogram': 'PA'},
  {'id': 'ent_004', 'name': 'Admin Role', 'type': 'role', 'monogram': 'AR'},
];

class MultiEntityScopeSwitcherSctas001A01 extends StatefulWidget {
  const MultiEntityScopeSwitcherSctas001A01({super.key});

  @override
  State<MultiEntityScopeSwitcherSctas001A01> createState() => _MultiEntityScopeSwitcherSctas001A01State();
}

class _MultiEntityScopeSwitcherSctas001A01State extends State<MultiEntityScopeSwitcherSctas001A01> {
  String? _selectedEntityId;

  void _handleEntitySelection(String entityId) {
    setState(() {
      _selectedEntityId = entityId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Multi-Entity Scope Switcher',
      hint: 'Tap to change active business context',
      child: SizedBox(
        // Spacious 48x48px target zone protects against finger selection slips on mobile.
        width: 48.0,
        height: 48.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () => _showScopeDrawer(context, colorScheme),
            child: Ink(
              decoration: BoxDecoration(
                // Enforce strict indirection layer using abstract tokens; no manual colors.
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.account_tree_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 24.0,
                  semanticLabel: 'Entity Scope',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showScopeDrawer(BuildContext context, ColorScheme colorScheme) {
    // Frames collapse unnecessary columns automatically into standard drawers on phone.
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'Select Business Context',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _mockScopeEntities.length,
                  itemBuilder: (context, index) {
                    final entity = _mockScopeEntities[index];
                    final isSelected = entity['id'] == _selectedEntityId;

                    return ListTile(
                      leading: CircleAvatar(
                        // Text titles pair with monograms on plain white backgrounds to enhance direct glare visibility.
                        backgroundColor: isSelected 
                            ? colorScheme.primaryContainer 
                            : colorScheme.surfaceContainerHighest,
                        child: Text(
                          entity['monogram'] as String,
                          style: TextStyle(
                            color: isSelected 
                                ? colorScheme.onPrimaryContainer 
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        entity['name'] as String,
                        style: TextStyle(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        (entity['type'] as String).toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.0,
                          letterSpacing: 1.2,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        _handleEntitySelection(entity['id'] as String);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Wrapper widget demonstrating pinned top-left placement within a global header.
class GlobalHeaderScopeWrapperSctas001A01 extends StatelessWidget implements PreferredSizeWidget {
  final Widget? body;

  const GlobalHeaderScopeWrapperSctas001A01({super.key, this.body});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Row(
          children: [
            const SizedBox(width: 8.0),
            // Pinned top-left within global header to maintain single-pane reading pattern rules.
            const MultiEntityScopeSwitcherSctas001A01(),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'UDF Dashboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: body ?? const Center(child: Text('Dashboard Content Area')),
    );
  }
}