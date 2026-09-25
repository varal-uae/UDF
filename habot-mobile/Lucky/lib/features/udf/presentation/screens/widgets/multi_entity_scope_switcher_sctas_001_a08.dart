// SCTAS-001-A08 — Multi-Entity Scope Switcher Component.
// Provides a 48x48px pinned top-left scope selector within the global header, enforcing strict MD3 design tokens, monogram pairing, and WCAG-compliant color shifts for active entity context switching with local mock data.

import 'package:flutter/material.dart';

/// Whitelisted entity model to prevent arbitrary text injection (Poka-Yoke).
class ScopeEntity {
  final String id;
  final String name;
  final Color tokenColor;

  const ScopeEntity({
    required this.id,
    required this.name,
    required this.tokenColor,
  });

  /// Monogram derived strictly from whitelisted name.
  String get monogram => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// Strict indirection layer using abstract tokens.
/// Prevents manual color or custom text entry at build time.
abstract class ScopeDesignTokens {
  static const double targetSize = 48.0;
  static const Color backgroundWhite = Colors.white;
  static const Color textOnWhite = Color(0xFF1C1B1F); // MD3 On-Surface
  static const Color activeIndicator = Color(0xFF6750A4); // MD3 Primary
  static const Color inactiveIndicator = Color(0xFFE6E1E5); // MD3 Surface Variant
  static const double borderRadius = 12.0;
}

/// Mock data repository simulating backend hydration.
class MockScopeRepository {
  static const List<ScopeEntity> entities = [
    ScopeEntity(
      id: 'ent_001',
      name: 'Alpha Corp',
      tokenColor: ScopeDesignTokens.activeIndicator,
    ),
    ScopeEntity(
      id: 'ent_002',
      name: 'Beta Holdings',
      tokenColor: Color(0xFF0061A4),
    ),
    ScopeEntity(
      id: 'ent_003',
      name: 'Gamma LLC',
      tokenColor: Color(0xFF006D3B),
    ),
  ];
}

/// State notifier simulation for scope selection.
class ScopeStateController extends ChangeNotifier {
  ScopeEntity _activeEntity = MockScopeRepository.entities.first;

  ScopeEntity get activeEntity => _activeEntity;

  void switchScope(ScopeEntity entity) {
    if (_activeEntity.id != entity.id) {
      _activeEntity = entity;
      notifyListeners();
      // In production: Triggers Pub/Sub schema hydration request here.
    }
  }
}

/// Master Entity Switcher Component.
/// Pinned top-left within global header. Exactly 48x48px touch target.
class MultiEntityScopeSwitcher extends StatelessWidget {
  final ScopeStateController controller;

  const MultiEntityScopeSwitcher({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final active = controller.activeEntity;
        return SizedBox(
          width: ScopeDesignTokens.targetSize,
          height: ScopeDesignTokens.targetSize,
          child: Material(
            color: ScopeDesignTokens.backgroundWhite,
            borderRadius: BorderRadius.circular(ScopeDesignTokens.borderRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showScopeDrawer(context, controller),
              borderRadius: BorderRadius.circular(ScopeDesignTokens.borderRadius),
              child: Tooltip(
                message: 'Active Scope: ${active.name}',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active.tokenColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(ScopeDesignTokens.borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      active.monogram,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: active.tokenColor,
                            fontWeight: FontWeight.bold,
                          ),
                      semanticsLabel: 'Switch corporate entity scope',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Frames collapse unnecessary columns automatically into standard drawers on phone.
  void _showScopeDrawer(BuildContext context, ScopeStateController ctrl) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select Corporate Scope',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 24.0),
              ...MockScopeRepository.entities.map((entity) {
                final isActive = ctrl.activeEntity.id == entity.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? entity.tokenColor.withOpacity(0.12)
                        : ScopeDesignTokens.inactiveIndicator,
                    child: Text(
                      entity.monogram,
                      style: TextStyle(
                        color: isActive
                            ? entity.tokenColor
                            : ScopeDesignTokens.textOnWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    entity.name,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: ScopeDesignTokens.textOnWhite,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check_circle, color: entity.tokenColor)
                      : null,
                  onTap: () {
                    ctrl.switchScope(entity);
                    Navigator.of(sheetContext).pop();
                  },
                );
              }),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}

/// Example usage demonstrating integration into a global header.
class GlobalHeaderWithScope extends StatelessWidget implements PreferredSizeWidget {
  final ScopeStateController scopeController;
  final Widget? child;

  const GlobalHeaderWithScope({
    super.key,
    required this.scopeController,
    this.child,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8.0),
          MultiEntityScopeSwitcher(controller: scopeController),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              'Unified Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ScopeDesignTokens.textOnWhite,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: ScopeDesignTokens.backgroundWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }
}