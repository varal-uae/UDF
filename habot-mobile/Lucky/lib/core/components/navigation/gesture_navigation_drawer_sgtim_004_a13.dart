// SGTIM-004-A13 — GestureNavigationDrawer component with swipe-activated menu panels.
// Implements touch-driven side navigation that follows finger drags, snaps closed on abandoned swipes, ignores gestures during horizontal scrolling, and adapts to desktop layouts.

import 'package:flutter/material.dart';

/// Mock data model for navigation items as required by the atomic data fields.
class NavItemModel {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final Map<String, dynamic> definitionParameters;
  final bool validationStatus;
  final IconData icon;

  const NavItemModel({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.definitionParameters,
    required this.validationStatus,
    required this.icon,
  });
}

/// Local mock data repository supplying realistic navigation entries.
class MockNavRepository {
  static const List<NavItemModel> items = [
    NavItemModel(
      definitionId: 'NAV-001',
      definitionName: 'Dashboard',
      definitionType: 'workspace',
      definitionParameters: {'route': '/dashboard'},
      validationStatus: true,
      icon: Icons.dashboard_outlined,
    ),
    NavItemModel(
      definitionId: 'NAV-002',
      definitionName: 'UDF Manager',
      definitionType: 'workspace',
      definitionParameters: {'route': '/udf'},
      validationStatus: true,
      icon: Icons.data_object,
    ),
    NavItemModel(
      definitionId: 'NAV-003',
      definitionName: 'Analytics',
      definitionType: 'workspace',
      definitionParameters: {'route': '/analytics'},
      validationStatus: true,
      icon: Icons.analytics_outlined,
    ),
    NavItemModel(
      definitionId: 'NAV-004',
      definitionName: 'Settings',
      definitionType: 'system',
      definitionParameters: {'route': '/settings'},
      validationStatus: true,
      icon: Icons.settings_outlined,
    ),
  ];
}

/// A gesture-aware side navigation drawer that supports mobile swipe-to-open,
/// desktop permanent panel, and manual collapse into an icon rail.
class GestureNavigationDrawer extends StatefulWidget {
  final Widget child;
  final ValueChanged<NavItemModel>? onItemSelected;

  const GestureNavigationDrawer({
    super.key,
    required this.child,
    this.onItemSelected,
  });

  @override
  State<GestureNavigationDrawer> createState() => _GestureNavigationDrawerState();
}

class _GestureNavigationDrawerState extends State<GestureNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _drawerAnimation;

  // Configuration constants based on requirement specs
  static const double _drawerWidthMobile = 280.0;
  static const double _drawerWidthDesktop = 256.0;
  static const double _collapsedIconRailWidth = 72.0;
  static const int _animationDurationMs = 250; // Fast 250ms movement profile
  static const double _swipeSensitivityGate = 0.3; // 30% of screen width to trigger
  static const double _velocitySensitivityGate = 500.0; // Pixels per second
  static const Size _switchSize = Size(52.0, 32.0); // 52x32px outer switch sizes

  bool _isHorizontalScrolling = false;
  bool _isDesktopLayout = false;
  bool _isDesktopCollapsed = false;
  String? _activeDefinitionId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _animationDurationMs),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (_isDesktopLayout) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    // Poka-Yoke: Ignore swipe gestures if user is actively scrolling horizontally
    if (_isHorizontalScrolling) return;
  }

  void _handleDragUpdate(DragUpdateDetails details, double screenWidth) {
    if (_isHorizontalScrolling || _isDesktopLayout) return;

    // Follow finger drags precisely
    final delta = details.primaryDelta ?? 0.0;
    final step = delta / screenWidth;
    _controller.value = (_controller.value + step).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details, double screenWidth) {
    if (_isHorizontalScrolling || _isDesktopLayout) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final displacement = _controller.value;

    // AISS: Compare final displacement length and movement speed against defined sensitivity gates
    if (velocity > _velocitySensitivityGate || displacement > _swipeSensitivityGate) {
      // Snap open
      _controller.forward();
    } else if (velocity < -_velocitySensitivityGate || displacement < _swipeSensitivityGate) {
      // Self-Chasing: Drawer panels snap securely closed automatically if a touch swipe gesture is abandoned halfway
      _controller.reverse();
    } else {
      // Default fallback: snap to nearest state
      if (displacement > 0.5) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _toggleDesktopCollapse() {
    setState(() {
      _isDesktopCollapsed = !_isDesktopCollapsed;
    });
  }

  void _onItemTapped(NavItemModel item) {
    setState(() {
      _activeDefinitionId = item.definitionId;
    });
    widget.onItemSelected?.call(item);
    if (!_isDesktopLayout) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isDesktopLayout = constraints.maxWidth >= 840.0;

        if (_isDesktopLayout) {
          return _buildDesktopLayout(constraints);
        }

        return _buildMobileLayout(constraints);
      },
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Detect horizontal scrolling in interactive data charts to ignore gestures
        if (notification.metrics.axis == Axis.horizontal) {
          if (notification is ScrollStartNotification) {
            _isHorizontalScrolling = true;
          } else if (notification is ScrollEndNotification) {
            _isHorizontalScrolling = false;
          }
        }
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: (details) => _handleDragUpdate(details, screenWidth),
        onHorizontalDragEnd: (details) => _handleDragEnd(details, screenWidth),
        child: Stack(
          children: [
            // Main Content
            widget.child,

            // Scrim
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return IgnorePointer(
                  ignoring: _controller.value == 0.0,
                  child: GestureDetector(
                    onTap: () => _controller.reverse(),
                    child: Container(
                      color: Colors.black.withOpacity(0.5 * _drawerAnimation.value),
                    ),
                  ),
                );
              },
            ),

            // Drawer Panel
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_drawerWidthMobile * (1.0 - _drawerAnimation.value), 0.0),
                  child: child,
                );
              },
              child: SizedBox(
                width: _drawerWidthMobile,
                height: constraints.maxHeight,
                child: Material(
                  elevation: 16.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: _buildDrawerContent(isCollapsed: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    final double currentDrawerWidth = _isDesktopCollapsed ? _collapsedIconRailWidth : _drawerWidthDesktop;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Permanent structured left control panel
        AnimatedContainer(
          duration: const Duration(milliseconds: _animationDurationMs),
          curve: Curves.easeInOut,
          width: currentDrawerWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Collapse Toggle Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: _switchSize.width,
                    height: _switchSize.height,
                    child: IconButton(
                      onPressed: _toggleDesktopCollapse,
                      icon: Icon(_isDesktopCollapsed ? Icons.chevron_right : Icons.chevron_left),
                      tooltip: _isDesktopCollapsed ? 'Expand Panel' : 'Collapse Panel',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildDrawerContent(isCollapsed: _isDesktopCollapsed),
              ),
            ],
          ),
        ),
        // Main Content Area
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildDrawerContent({required bool isCollapsed}) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: MockNavRepository.items.length,
      itemBuilder: (context, index) {
        final item = MockNavRepository.items[index];
        final isActive = _activeDefinitionId == item.definitionId;

        // Highlight active states with vibrant accent tokens
        final Color textColor = isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant;
        final Color iconColor = isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant;
        final Color? tileColor = isActive
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null;

        if (isCollapsed) {
          // Tight icon row for collapsed desktop layout
          return Tooltip(
            message: item.definitionName,
            waitDuration: const Duration(milliseconds: 500),
            child: InkWell(
              onTap: () => _onItemTapped(item),
              child: Container(
                height: 56.0,
                alignment: Alignment.center,
                color: tileColor,
                child: Icon(item.icon, color: iconColor),
              ),
            ),
          );
        }

        // Pair clean system icons alongside clear text descriptions inside the menu list rows
        return ListTile(
          leading: Icon(item.icon, color: iconColor),
          title: Text(
            item.definitionName,
            style: TextStyle(
              color: textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isActive,
          tileColor: tileColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          onTap: () => _onItemTapped(item),
        );
      },
    );
  }
}

/// Helper widget to rebuild on animation ticks while keeping GPU acceleration.
/// Run toggle animations entirely on the GPU to keep transitions at a stable 60fps.
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
    return RepaintBoundary(
      child: AnimatedBuilderInternal(
        animation: animation,
        builder: builder,
        child: child,
      ),
    );
  }
}

class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  }) : super();

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}