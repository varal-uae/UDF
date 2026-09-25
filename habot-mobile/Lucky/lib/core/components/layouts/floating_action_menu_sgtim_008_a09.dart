// SGTIM-008-A09 — Floating Action Button (FAB) Expandable Action Menu.
// A Material 3 compliant FAB that expands into a vertical sub-menu overlay on tap, anchored 16px from screen edges with spring animations and keyboard avoidance.

import 'package:flutter/material.dart';

/// Data model representing a single action item within the FAB menu.
class FabActionItem {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FabActionItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Mock data for demonstration and local testing without backend dependency.
final List<FabActionItem> mockFabActions = [
  FabActionItem(
    id: 'action_create_entry',
    icon: Icons.add_circle_outline,
    label: 'Create Entry',
    onTap: () {},
  ),
  FabActionItem(
    id: 'action_upload_doc',
    icon: Icons.upload_file_outlined,
    label: 'Upload Document',
    onTap: () {},
  ),
  FabActionItem(
    id: 'action_scan_qr',
    icon: Icons.qr_code_scanner,
    label: 'Scan QR Code',
    onTap: () {},
  ),
];

/// A high-performance expandable Floating Action Button component.
/// 
/// Adheres to Material Design 3 guidelines, anchoring itself 16px away from
/// screen edges. Expands vertically using hardware-accelerated spring animations.
/// Automatically hides or shifts when the software keyboard is visible.
class FloatingActionMenu extends StatefulWidget {
  final List<FabActionItem> actions;
  final IconData expandedIcon;
  final IconData collapsedIcon;
  final Color? fabBackgroundColor;
  final Color? fabForegroundColor;
  final double edgeMargin;

  const FloatingActionMenu({
    super.key,
    required this.actions,
    this.expandedIcon = Icons.close,
    this.collapsedIcon = Icons.add,
    this.fabBackgroundColor,
    this.fabForegroundColor,
    this.edgeMargin = 16.0,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Linear spring animation equations matching Material motion systems
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  void _handleActionTap(FabActionItem item) {
    _closeMenu();
    item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    
    // Self-chasing verification: shift/hide cleanly when software keyboards slide up
    final double bottomInset = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = bottomInset > 0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: widget.edgeMargin + (isKeyboardOpen ? bottomInset : 0)),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(right: widget.edgeMargin),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Background overlay for mistake-proofing (Poka-Yoke)
              // Tapping it closes the expanded menu safely
              if (_isExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeMenu,
                    behavior: HitTestBehavior.translucent,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              
              // Vertical Sub-menu Overlay Layer
              IgnorePointer(
                ignoring: !_isExpanded,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(widget.actions.length, (index) {
                    final item = widget.actions[index];
                    final delay = index * 0.05;
                    
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _controller,
                          curve: Interval(delay, 1.0, curve: Curves.easeOut),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _SubMenuItem(
                            item: item,
                            onTap: () => _handleActionTap(item),
                            theme: theme,
                          ),
                        ),
                      ),
                    );
                  }).reversed.toList(),
                ),
              ),

              // Primary Floating Action Button
              RotationTransition(
                turns: _rotationAnimation,
                child: FloatingActionButton(
                  onPressed: _toggleMenu,
                  backgroundColor: widget.fabBackgroundColor ?? colorScheme.primaryContainer,
                  foregroundColor: widget.fabForegroundColor ?? colorScheme.onPrimaryContainer,
                  elevation: 6.0,
                  child: Icon(_isExpanded ? widget.expandedIcon : widget.collapsedIcon),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal widget representing a single row in the expanded vertical menu.
/// Pairs sub-menu icons with clear text plates to explain option destinations instantly.
class _SubMenuItem extends StatelessWidget {
  final FabActionItem item;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SubMenuItem({
    required this.item,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: item.backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: item.foregroundColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  item.icon,
                  size: 20.0,
                  color: item.foregroundColor ?? colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example usage wrapper demonstrating how to integrate the FloatingActionMenu
/// into a Scaffold, utilizing the mock data provided locally.
class FloatingActionMenuExample extends StatelessWidget {
  const FloatingActionMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Dashboard'),
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(
          title: Text('Dashboard Item $index'),
          subtitle: const Text('Scroll down to test FAB visibility and thumb reach zones.'),
        ),
      ),
      // Renders overlay style above content blocks, preserving baseline scrolling layouts
      floatingActionButton: FloatingActionMenu(
        actions: mockFabActions,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}