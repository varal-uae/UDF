// SGTIM-002-A04 — HorizontalScrollContainer for mobile quick-action controls.
// Implements a touch-responsive, momentum-scrolling horizontal layout with haptic feedback and Material 3 design tokens.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable horizontal scroll container optimized for mobile quick-action controls.
/// Enforces momentum scrolling, generous corner radii, and consistent spacing.
class HorizontalScrollContainer extends StatelessWidget {
  const HorizontalScrollContainer({
    super.key,
    required this.children,
    this.itemSpacing = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.itemCornerRadius = 16.0,
    this.physics = const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
  });

  final List<Widget> children;
  final double itemSpacing;
  final EdgeInsetsGeometry padding;
  final double itemCornerRadius;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            _HapticActionWrapper(
              cornerRadius: itemCornerRadius,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
              elevation: 1.0,
              child: children[i],
            ),
            if (i < children.length - 1) SizedBox(width: itemSpacing),
          ],
        ],
      ),
    );
  }
}

class _HapticActionWrapper extends StatefulWidget {
  const _HapticActionWrapper({
    required this.child,
    required this.cornerRadius,
    required this.backgroundColor,
    required this.foregroundColor,
    this.elevation = 1.0,
  });

  final Widget child;
  final double cornerRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  @override
  State<_HapticActionWrapper> createState() => _HapticActionWrapperState();
}

class _HapticActionWrapperState extends State<_HapticActionWrapper> {
  bool _isPressed = false;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _triggerHaptic();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.1),
                blurRadius: _isPressed ? 2.0 : 6.0,
                offset: Offset(0, _isPressed ? 1.0 : 2.0),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: widget.foregroundColor),
            child: IconTheme.merge(
              data: IconThemeData(color: widget.foregroundColor),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock quick-action items to demonstrate the container's capabilities.
class MockQuickActions {
  static List<Widget> getItems(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return [
      _buildActionItem(Icons.dashboard_outlined, 'Dashboard', theme),
      _buildActionItem(Icons.analytics_outlined, 'Analytics', theme),
      _buildActionItem(Icons.notifications_none, 'Alerts', theme),
      _buildActionItem(Icons.settings_outlined, 'Settings', theme),
      _buildActionItem(Icons.person_outline, 'Profile', theme),
      _buildActionItem(Icons.help_outline, 'Support', theme),
    ];
  }

  static Widget _buildActionItem(IconData icon, String label, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24.0, color: theme.colorScheme.primary),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Example usage demonstrating integration into a dashboard screen.
class HorizontalScrollExampleScreen extends StatelessWidget {
  const HorizontalScrollExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Actions'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Common Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          HorizontalScrollContainer(
            children: MockQuickActions.getItems(context),
          ),
          const Expanded(
            child: Center(
              child: Text('Main Dashboard Content Area'),
            ),
          ),
        ],
      ),
    );
  }
}
