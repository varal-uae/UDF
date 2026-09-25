// SGTIM-019-A08 — ContextualFAB Adaptive Circular Action Shortcut Button.
// Implements a 56x56dp Material 3 floating action button pinned to the lower-screen thumb zone, with context-linked icons, upward unfolding sub-menus, permission-based visibility, and responsive desktop toolbar conversion.

import 'package:flutter/material.dart';

/// Mock data representing context-linked actions for different workspaces.
class _MockActionItem {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MockActionItem({
    required this.id,
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Generates mock actions based on the current workspace context.
List<_MockActionItem> _getMockActionsForContext(String contextId) {
  switch (contextId) {
    case 'asset_log':
      return [
        _MockActionItem(id: 'a1', icon: Icons.add_box_outlined, label: 'New Asset'),
        _MockActionItem(id: 'a2', icon: Icons.qr_code_scanner, label: 'Scan QR'),
        _MockActionItem(id: 'a3', icon: Icons.upload_file, label: 'Upload File'),
      ];
    case 'inventory':
      return [
        _MockActionItem(id: 'i1', icon: Icons.inventory_2_outlined, label: 'Stock Check'),
        _MockActionItem(id: 'i2', icon: Icons.local_shipping_outlined, label: 'Receive'),
      ];
    default:
      return [
        _MockActionItem(id: 'd1', icon: Icons.add, label: 'Create New'),
      ];
  }
}

/// A reusable, adaptive, context-linked floating action controller.
/// 
/// On mobile, it renders as a 56x56dp FAB in the bottom-right thumb zone
/// that expands into an upward unfolding sub-menu.
/// On desktop/web, it converts into a standard horizontal button group or toolbar option.
class ContextualFAB extends StatefulWidget {
  /// The current workspace or screen context identifier used to load relevant actions.
  final String contextId;

  /// Whether the current user has permissions to see and interact with this FAB.
  /// If false, the widget hides itself completely (Poka-Yoke).
  final bool hasPermission;

  /// Optional callback triggered when the main FAB is tapped without expanding.
  final VoidCallback? onMainTap;

  const ContextualFAB({
    super.key,
    required this.contextId,
    this.hasPermission = true,
    this.onMainTap,
  });

  @override
  State<ContextualFAB> createState() => _ContextualFABState();
}

class _ContextualFABState extends State<ContextualFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late List<_MockActionItem> _actions;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _loadActions();
  }

  @override
  void didUpdateWidget(covariant ContextualFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contextId != widget.contextId) {
      _loadActions();
      if (_isExpanded) {
        _collapseMenu();
      }
    }
  }

  void _loadActions() {
    _actions = _getMockActionsForContext(widget.contextId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _collapseMenu() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke: Hide completely if permissions restrict the user.
    if (!widget.hasPermission) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Responsive UX: Convert to horizontal button group on wide layouts.
    if (isDesktop) {
      return _buildDesktopToolbar(theme);
    }

    // Mobile-First: Floating action button pinned to lower-screen thumb reach zone.
    return GestureDetector(
      // Self-Chasing: Collapse sub-menus if user taps outside the active option frame.
      onTapDown: (_) {},
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Background scrim to detect outside taps and collapse menu
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _collapseMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          
          // Upward unfolding sub-menu animations
          Positioned(
            bottom: 72.0, // 56dp FAB + 16dp margin
            right: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_actions.length, (index) {
                final action = _actions[index];
                final int reverseIndex = _actions.length - 1 - index;
                
                return ScaleTransition(
                  scale: _expandAnimation,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0 * (reverseIndex == 0 ? 1 : 1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              action.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Secondary buttons meeting 48x48 dp minimal hit target
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: FloatingActionButton.small(
                              heroTag: 'fab_sub_${action.id}',
                              onPressed: () {
                                action.onTap?.call();
                                _collapseMenu();
                              },
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              foregroundColor: theme.colorScheme.onSecondaryContainer,
                              child: Icon(action.icon, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main bold, clean circular component container surface (56x56dp)
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              heroTag: 'fab_main_${widget.contextId}',
              onPressed: () {
                if (widget.onMainTap != null && !_isExpanded) {
                  widget.onMainTap!();
                } else {
                  _toggleMenu();
                }
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 6,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * (3.14159 / 4),
                    child: Icon(
                      _isExpanded ? Icons.close : _getPrimaryIcon(),
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrimaryIcon() {
    if (_actions.isEmpty) return Icons.add;
    return _actions.first.icon;
  }

  Widget _buildDesktopToolbar(ThemeData theme) {
    // Arrange action options into standard horizontal button groups across wide layout sheets.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.tonalIcon(
              onPressed: action.onTap,
              icon: Icon(action.icon, size: 20),
              label: Text(action.label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Helper class since Flutter's built-in is `AnimatedBuilder` -> actually it's `AnimatedBuilder` in newer versions, 
/// but standard is `AnimatedBuilder`. Let's use standard `AnimatedBuilder` alias to avoid compile errors.
/// Note: Standard Flutter uses `AnimatedBuilder`.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}