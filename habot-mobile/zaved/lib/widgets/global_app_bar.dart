import 'package:flutter/material.dart';

/// Master Header App Bar Component enforcing strict layout limits and compile-time Poka-Yoke.
class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({
    super.key,
    required this.activeRouteTitle,
    required this.onMenuTapped,
    this.actions,
  });

  /// Compile-Time Safety: Required non-nullable active route title
  final String activeRouteTitle;

  /// Compile-Time Safety: Required non-nullable menu tap callback
  final VoidCallback onMenuTapped;

  /// Optional custom action buttons
  final List<Widget>? actions;

  // 2. Strict Bounds: preferredSize strictly enforced to exactly 64.0 height
  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    // 3. ToolbarHeight set to exactly 64.0
    return AppBar(
      toolbarHeight: 64.0,
      // 6. Bind activeRouteTitle to Text widget in center of AppBar
      centerTitle: true,
      title: Text(activeRouteTitle),
      // 4. Phantom Padding: IconButton for leading with 48x48 min touch target
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuTapped,
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        splashRadius: 24.0,
        tooltip: 'Navigation Menu',
      ),
      // 4. Phantom Padding: IconButton for actions with 48x48 min touch target
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
              constraints: const BoxConstraints(
                minWidth: 48.0,
                minHeight: 48.0,
              ),
              splashRadius: 24.0,
              tooltip: 'Notifications',
            ),
          ],
    );
  }
}
