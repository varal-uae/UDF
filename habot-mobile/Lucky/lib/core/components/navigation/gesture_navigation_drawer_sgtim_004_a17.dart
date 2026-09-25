// SGTIM-004-A17 — GestureNavigationDrawer: Swipe-activated side menu panel.
// Implements a touch-gesture-aware navigation drawer that follows finger drags, snaps closed on abandonment, ignores swipes during horizontal chart scrolling, and adapts to desktop as a permanent collapsible side panel using Material 3 design tokens.

import 'package:flutter/material.dart';

/// Atomic-level monitoring metric model for telemetry alignment.
class DrawerInteractionMetric {
  final String metricName;
  final String metricValue;
  final String monitoringStatus;
  final String alertThreshold;
  final DateTime monitoringTimestamp;

  const DrawerInteractionMetric({
    required this.metricName,
    required this.metricValue,
    required this.monitoringStatus,
    required this.alertThreshold,
    required this.monitoringTimestamp,
  });
}

/// Mock data generator for GCP/BigQuery alignment tracking.
class DrawerMetricsMockRepository {
  static List<DrawerInteractionMetric> getRecentMetrics() {
    return [
      DrawerInteractionMetric(
        metricName: 'Monitoring & Alert Response Time',
        metricValue: '45s',
        monitoringStatus: 'Optimal',
        alertThreshold: '60s',
        monitoringTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      DrawerInteractionMetric(
        metricName: 'Tool Selection Count',
        metricValue: '128',
        monitoringStatus: 'Normal',
        alertThreshold: 'N/A',
        monitoringTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

/// Data model for menu items pairing clean system icons with text descriptions.
class DrawerMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const DrawerMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// A gesture-driven side menu panel that supports mobile swipe-to-open,
/// desktop permanent rail, and GPU-accelerated 250ms animations.
class GestureNavigationDrawer extends StatefulWidget {
  final List<DrawerMenuItem> items;
  final Widget child;
  final bool isHorizontalScrollInProgress;
  final double desktopExpandedWidth;
  final double desktopCollapsedWidth;

  const GestureNavigationDrawer({
    super.key,
    required this.items,
    required this.child,
    this.isHorizontalScrollInProgress = false,
    this.desktopExpandedWidth = 280.0,
    this.desktopCollapsedWidth = 72.0,
  });

  @override
  State<GestureNavigationDrawer> createState() => _GestureNavigationDrawerState();
}

class _GestureNavigationDrawerState extends State<GestureNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _isDesktopPanelCollapsed = false;
  bool _isOpen = false;

  // Minimum swipe distance in logical pixels to trigger open/close
  static const double _swipeThreshold = 60.0;
  // Edge zone width where swipe initiates the drawer
  static const double _edgeSwipeZone = 32.0;

  @override
  void initState() {
    super.initState();
    // Fast 250ms movement profile running entirely on the GPU
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    // Poka-Yoke: Ignore swipe gestures if user is actively scrolling horizontally through a chart
    if (widget.isHorizontalScrollInProgress) return;

    final delta = details.primaryDelta ?? 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentProgress = _controller.value;

    // Only allow drag if starting from left edge or already partially open
    if (details.globalPosition.dx < _edgeSwipeZone || currentProgress > 0.0) {
      final newProgress = (currentProgress + (delta / screenWidth)).clamp(0.0, 1.0);
      _controller.value = newProgress;
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (widget.isHorizontalScrollInProgress) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final progress = _controller.value;

    // Self-Chasing: Snap securely closed if abandoned halfway, or based on velocity/threshold
    if (velocity > 300 || (progress > 0.5 && velocity >= -300)) {
      _openDrawer();
    } else {
      _closeDrawer();
    }
  }

  void _openDrawer() {
    setState(() => _isOpen = true);
    _controller.forward();
  }

  void _closeDrawer() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _toggleDesktopPanel() {
    setState(() {
      _isDesktopPanelCollapsed = !_isDesktopPanelCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 840;

        if (isWideLayout) {
          return _buildDesktopLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.8;

    return GestureDetector(
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          // Scrim overlay
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              if (_slideAnimation.value == 0.0) return const SizedBox.shrink();
              return GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _slideAnimation.value),
                ),
              );
            },
          ),
          // Drawer Panel
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-drawerWidth * (1.0 - _slideAnimation.value), 0.0),
                child: child,
              );
            },
            child: SizedBox(
              width: drawerWidth,
              child: Material(
                elevation: 16.0,
                color: theme.colorScheme.surface,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'System Navigation',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.items.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            return _buildMenuTile(item, theme, showLabel: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final panelWidth = _isDesktopPanelCollapsed
        ? widget.desktopCollapsedWidth
        : widget.desktopExpandedWidth;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: panelWidth,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            children: [
              // Collapse toggle button maintaining comfortable 52x32px outer switch size
              SizedBox(
                height: 52,
                width: double.infinity,
                child: Center(
                  child: InkWell(
                    onTap: _toggleDesktopPanel,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 52,
                      height: 32,
                      child: Icon(
                        _isDesktopPanelCollapsed
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return _buildMenuTile(
                      item,
                      theme,
                      showLabel: !_isDesktopPanelCollapsed,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildMenuTile(DrawerMenuItem item, ThemeData theme, {required bool showLabel}) {
    // Highlight active states with vibrant accent tokens
    final isActive = false; // Determined by routing state in production
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {
        item.onTap?.call();
        if (!showLabel) return; // Desktop collapsed mode doesn't close
        _closeDrawer();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            if (showLabel) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // Disable text selection overlays to keep interactions clean
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isActive ? activeColor : theme.colorScheme.onSurface,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper widget to rebuild on animation changes without external package dependencies.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
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

/// Example usage and demonstration screen for the GestureNavigationDrawer.
class GestureNavigationDrawerDemoScreen extends StatelessWidget {
  const GestureNavigationDrawerDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockItems = [
      DrawerMenuItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () {}),
      DrawerMenuItem(icon: Icons.analytics_outlined, label: 'Analytics Workspace', onTap: () {}),
      DrawerMenuItem(icon: Icons.people_outline, label: 'Team Management', onTap: () {}),
      DrawerMenuItem(icon: Icons.settings_outlined, label: 'System Settings', onTap: () {}),
      DrawerMenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
    ];

    // Initialize mock metrics collection
    final metrics = DrawerMetricsMockRepository.getRecentMetrics();
    debugPrint('Loaded ${metrics.length} interaction metrics for telemetry.');

    return Scaffold(
      body: GestureNavigationDrawer(
        items: mockItems,
        isHorizontalScrollInProgress: false,
        child: const Center(
          child: Text('Main Content Area - Swipe from left edge to open menu'),
        ),
      ),
    );
  }
}
