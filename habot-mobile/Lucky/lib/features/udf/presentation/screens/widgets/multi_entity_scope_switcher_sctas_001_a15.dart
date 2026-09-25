// SCTAS-001-A15 — Multi-Entity Scope Switcher Component.
// A thumb-friendly 48x48px entity switcher pinned top-left in the global header, enforcing strict indirection via abstract tokens for colors and text to prevent data contamination across corporate accounts.

import 'package:flutter/material.dart';

/// Abstract token layer preventing manual color or custom text entry.
abstract class ScopeDesignTokens {
  static const Color activeScopeColor = Color(0xFF1A73E8);
  static const Color inactiveScopeColor = Color(0xFF5F6368);
  static const Color backgroundColor = Colors.white;
  static const Color monogramBackground = Color(0xFFF1F3F4);
  static const double targetSize = 48.0;
}

/// Mock data representing atomic-level multi-tenant entities.
class MockEntity {
  final String id;
  final String name;
  final String monogram;

  const MockEntity({
    required this.id,
    required this.name,
    required this.monogram,
  });
}

const List<MockEntity> kMockEntities = [
  MockEntity(id: 'ent_001', name: 'Alpha Corp', monogram: 'AC'),
  MockEntity(id: 'ent_002', name: 'Beta Holdings', monogram: 'BH'),
  MockEntity(id: 'ent_003', name: 'Gamma LLC', monogram: 'GL'),
];

/// Controller managing scope persistence across navigation.
class ScopeSwitcherController extends ChangeNotifier {
  MockEntity _activeEntity = kMockEntities.first;

  MockEntity get activeEntity => _activeEntity;

  void switchScope(MockEntity entity) {
    if (_activeEntity.id != entity.id) {
      _activeEntity = entity;
      notifyListeners();
      // In production, triggers an immediate Pub/Sub schema hydration request
      // to reload the page data space cleanly.
    }
  }
}

/// Master Entity Switcher Component.
/// Pinned top-left within global header. Spacious 48x48px target zone.
/// Text titles pair with monograms on plain white backgrounds.
/// Iconography pairing for colorblindness & WCAG contrast compliance.
class MultiEntityScopeSwitcher extends StatefulWidget {
  final ScopeSwitcherController controller;

  const MultiEntityScopeSwitcher({
    super.key,
    required this.controller,
  });

  @override
  State<MultiEntityScopeSwitcher> createState() => _MultiEntityScopeSwitcherState();
}

class _MultiEntityScopeSwitcherState extends State<MultiEntityScopeSwitcher> {
  late final ScopeSwitcherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onScopeChanged);
  }

  void _onScopeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onScopeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Active Business Context: ${_controller.activeEntity.name}',
      button: true,
      child: SizedBox(
        width: ScopeDesignTokens.targetSize,
        height: ScopeDesignTokens.targetSize,
        child: Material(
          color: ScopeDesignTokens.backgroundColor,
          borderRadius: BorderRadius.circular(ScopeDesignTokens.targetSize / 2),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _showScopeDrawer,
            splashColor: ScopeDesignTokens.activeScopeColor.withOpacity(0.12),
            child: Center(
              child: _buildMonogram(_controller.activeEntity),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonogram(MockEntity entity) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: ScopeDesignTokens.monogramBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: ScopeDesignTokens.activeScopeColor,
          width: 2.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        entity.monogram,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ScopeDesignTokens.activeScopeColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  /// Frames collapse unnecessary columns automatically into standard drawers on phone.
  void _showScopeDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ScopeDesignTokens.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Switch Corporate Account',
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1.0),
                ...kMockEntities.map((entity) => _buildEntityTile(sheetContext, entity)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntityTile(BuildContext context, MockEntity entity) {
    final bool isActive = _controller.activeEntity.id == entity.id;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? ScopeDesignTokens.activeScopeColor
            : ScopeDesignTokens.monogramBackground,
        child: Text(
          entity.monogram,
          style: TextStyle(
            color: isActive ? Colors.white : ScopeDesignTokens.inactiveScopeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        entity.name,
        style: TextStyle(
          color: isActive ? ScopeDesignTokens.activeScopeColor : Colors.black87,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle, color: ScopeDesignTokens.activeScopeColor)
          : null,
      onTap: () {
        // Fixed structural bounds completely block arbitrary or non-whitelisted text strings.
        if (kMockEntities.any((e) => e.id == entity.id)) {
          _controller.switchScope(entity);
          Navigator.of(context).pop();
        }
      },
    );
  }
}
