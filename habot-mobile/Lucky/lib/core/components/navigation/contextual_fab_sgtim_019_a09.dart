// SGTIM-019-A09 — ContextualFAB: Adaptive circular action shortcut buttons pinned to screens.
// Implements a 56x56dp Material floating action button with expand/collapse animations, permission-based visibility, and responsive desktop adaptation.

import 'package:flutter/material.dart';

/// Mock data representing context-linked actions for the FAB.
class _MockContextualAction {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool requiresPermission;

  const _MockContextualAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.requiresPermission = true,
  });
}

/// A reusable, adaptive floating action button that expands into sub-menus.
/// Meets 56x56dp standard size and 48x48dp minimum hit target parameters.
class ContextualFAB extends StatefulWidget {
  final List<_MockContextualAction> actions;
  final bool hasPermission;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ContextualFAB({
    super.key,
    required this.actions,
    this.hasPermission = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<ContextualFAB> createState() => _ContextualFABState();
}

class _ContextualFABState extends State<ContextualFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Self-Chasing: Collapse automatically when tapping outside.
  void _collapseIfExpanded() {
    if (_isExpanded) {
      _toggleExpand();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mistake-Proofing (Poka-Yoke): Hide completely if no permissions.
    if (!widget.hasPermission) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Responsive UX/UI Design: Desktop uses permanent top toolbar options.
    if (isDesktop) {
      return _buildDesktopToolbar(context, theme);
    }

    final filteredActions = widget.actions
        .where((a) => !a.requiresPermission || widget.hasPermission)
        .toList();

    return GestureDetector(
      onTapDown: (_) => _collapseIfExpanded(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Upward unfolding sub-menu animations
          Positioned(
            bottom: 72.0,
            right: 4.0,
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              axis: Axis.vertical,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: filteredActions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildSubMenuItem(action, theme),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Main 56x56dp Floating Action Button
          SizedBox(
            width: 56.0,
            height: 56.0,
            child: FloatingActionButton(
              onPressed: _toggleExpand,
              backgroundColor:
                  widget.backgroundColor ?? theme.colorScheme.primaryContainer,
              foregroundColor:
                  widget.foregroundColor ?? theme.colorScheme.onPrimaryContainer,
              heroTag: 'contextual_fab_main',
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _expandAnimation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(_MockContextualAction action, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            action.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        // Minimum 48x48 dp hit target
        SizedBox(
          width: 48.0,
          height: 48.0,
          child: FloatingActionButton.small(
            heroTag: 'fab_sub_${action.id}',
            onPressed: () {
              action.onTap();
              _collapseIfExpanded();
            },
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            child: Icon(action.icon),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar(BuildContext context, ThemeData theme) {
    final filteredActions = widget.actions
        .where((a) => !a.requiresPermission || widget.hasPermission)
        .toList();

    // Arrange action options into standard horizontal button groups across wide layout sheets.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surfaceVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: filteredActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton.icon(
              onPressed: action.onTap,
              icon: Icon(action.icon),
              label: Text(action.label),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Example usage wrapper demonstrating mock data integration.
class ContextualFABExample extends StatelessWidget {
  const ContextualFABExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Atomic-level mock data fields
    const mockActions = [
      _MockContextualAction(
        id: 'log_asset',
        icon: Icons.add_box_outlined,
        label: 'Start Asset Log',
        onTap: _mockLogAsset,
      ),
      _MockContextualAction(
        id: 'scan_qr',
        icon: Icons.qr_code_scanner,
        label: 'Scan QR Code',
        onTap: _mockScanQr,
      ),
      _MockContextualAction(
        id: 'upload_file',
        icon: Icons.cloud_upload_outlined,
        label: 'Upload File',
        onTap: _mockUploadFile,
        requiresPermission: true,
      ),
    ];

    return Scaffold(
      body: const Center(
        child: Text('Main Content Area'),
      ),
      // Table layouts use explicit bottom padding rules to ensure content is never covered by the button.
      bottomNavigationBar: const SizedBox(height: 80),
      floatingActionButton: ContextualFAB(
        actions: mockActions,
        hasPermission: true,
      ),
    );
  }

  static void _mockLogAsset() {
    debugPrint('[SGTIM-019-A09] Mock: Starting asset log...');
  }

  static void _mockScanQr() {
    debugPrint('[SGTIM-019-A09] Mock: Opening QR scanner...');
  }

  static void _mockUploadFile() {
    debugPrint('[SGTIM-019-A09] Mock: Initiating file upload...');
  }
}
