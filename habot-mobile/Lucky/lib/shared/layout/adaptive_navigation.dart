import 'package:flutter/material.dart';
import 'screen_size_provider.dart';
import 'size_class.dart';

// ANSA-020-10 — M3 Adaptive Navigation for Dashboards.
// Spec:
//   - Bottom NavigationBar on Compact (<600dp)
//   - NavigationRail on Medium/Expanded (≥600dp)
//   - M3 motion to animate transitions between navigation states
//   - 48dp minimum touch targets in nav bar
//   - Maximizes vertical space for data on larger screens
//
// Uses ScreenSizeProvider (Step 5) — no raw MediaQuery needed.

// ── Navigation destination model ─────────────────────────────────────────────

class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  /// Optional badge count — null = no badge, 0 = dot badge
  final int? badge;
}

// ── Adaptive nav scaffold ─────────────────────────────────────────────────────

class AdaptiveNavScaffold extends StatefulWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.destinations,
    required this.body,
    this.initialIndex = 0,
    this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
  });

  final List<NavDestination> destinations;

  /// Body builder — receives current selected index.
  final Widget Function(int selectedIndex) body;

  final int initialIndex;
  final ValueChanged<int>? onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  State<AdaptiveNavScaffold> createState() => _AdaptiveNavScaffoldState();
}

class _AdaptiveNavScaffoldState extends State<AdaptiveNavScaffold>
    with SingleTickerProviderStateMixin {

  late int _selectedIndex;
  late final AnimationController _transitionCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // M3 motion — fade transition between navigation states
    _transitionCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _transitionCtrl,
      curve:  Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _transitionCtrl.dispose();
    super.dispose();
  }

  void _onSelect(int index) {
    if (index == _selectedIndex) return;
    // M3 motion — re-trigger fade on navigation state change
    _transitionCtrl.forward(from: 0.0);
    setState(() => _selectedIndex = index);
    widget.onDestinationSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = ScreenSizeProvider.of(context);

    return sizeClass.isCompact
        ? _CompactLayout(
            destinations:  widget.destinations,
            selectedIndex: _selectedIndex,
            onSelect:      _onSelect,
            body:          FadeTransition(
              opacity: _fadeAnim,
              child:   widget.body(_selectedIndex),
            ),
            appBar:             widget.appBar,
            floatingActionButton: widget.floatingActionButton,
          )
        : _WideLayout(
            destinations:  widget.destinations,
            selectedIndex: _selectedIndex,
            onSelect:      _onSelect,
            extended:      sizeClass.isExpanded,
            body:          FadeTransition(
              opacity: _fadeAnim,
              child:   widget.body(_selectedIndex),
            ),
            appBar: widget.appBar,
          );
  }
}

// ── Compact — Bottom Navigation Bar ──────────────────────────────────────────

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex:        selectedIndex,
        onDestinationSelected: onSelect,
        // M3 motion — animationDuration controls tab switch animation
        animationDuration:    const Duration(milliseconds: 300),
        destinations: destinations.map((d) {
          final icon = _buildIcon(d, isSelected: false);
          final selectedIcon = _buildIcon(d, isSelected: true);
          return NavigationDestination(
            icon:         icon,
            selectedIcon: selectedIcon,
            label:        d.label,
            // 48dp touch target enforced by NavigationDestination natively
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIcon(NavDestination d, {required bool isSelected}) {
    final iconWidget = Icon(isSelected ? (d.selectedIcon ?? d.icon) : d.icon);
    if (d.badge == null) return iconWidget;
    if (d.badge == 0) {
      return Badge(child: iconWidget);
    }
    return Badge(
      label: Text('${d.badge}'),
      child: iconWidget,
    );
  }
}

// ── Wide — Navigation Rail ────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    required this.extended,
    this.appBar,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;

  /// True on expanded (≥1200dp) — shows full label alongside icon.
  final bool extended;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          // Navigation Rail — maximizes vertical space for data
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve:    Curves.easeOut,
            width:    extended ? 200 : 80,
            child: NavigationRail(
              selectedIndex:    selectedIndex,
              onDestinationSelected: onSelect,
              extended:         extended,
              minWidth:         56,   // 48dp + 8dp padding
              minExtendedWidth: 200,
              labelType:        extended
                  ? NavigationRailLabelType.none  // label shown inline
                  : NavigationRailLabelType.selected,
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon:         _buildIcon(d, isSelected: false),
                  selectedIcon: _buildIcon(d, isSelected: true),
                  label:        Text(d.label),
                  // 48dp touch target enforced by NavigationRailDestination
                  padding:      const EdgeInsets.symmetric(vertical: 4),
                );
              }).toList(),
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // Main content — fills remaining space
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildIcon(NavDestination d, {required bool isSelected}) {
    final iconWidget = Icon(isSelected ? (d.selectedIcon ?? d.icon) : d.icon);
    if (d.badge == null) return iconWidget;
    if (d.badge == 0) return Badge(child: iconWidget);
    return Badge(label: Text('${d.badge}'), child: iconWidget);
  }
}
