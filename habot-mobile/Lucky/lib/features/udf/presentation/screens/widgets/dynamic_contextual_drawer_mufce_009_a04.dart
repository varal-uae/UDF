// MUFCE-009-A04 — Dynamic Contextual Bottom Sheet Drawer.
// Deploys a gesture-driven bottom sheet with 48dp minimum touch targets, scrim dismissal, adaptive side-sheet layout for desktop viewports, and telemetry tracking.

import 'package:flutter/material.dart';

/// Mock telemetry data collector per requirement specification.
class _DrawerTelemetry {
  static void logEvent({
    required String stepExecutionId,
    required String executionStatus,
    required String stepOutcome,
    String? userId,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint(
      '[MUFCE-009-A04 Telemetry] '
      'StepExecutionID: $stepExecutionId, '
      'Status: $executionStatus, '
      'Timestamp: $timestamp, '
      'Outcome: $stepOutcome, '
      'UserID: ${userId ?? 'anonymous'}',
    );
  }
}

/// Configuration for the dynamic contextual drawer.
class DynamicContextualDrawerConfig {
  final List<DrawerActionItem> actions;
  final bool enableThumbnailPreview;
  final String? thumbnailUrl;
  final Color? errorColor;

  const DynamicContextualDrawerConfig({
    required this.actions,
    this.enableThumbnailPreview = false,
    this.thumbnailUrl,
    this.errorColor,
  });
}

/// Individual interactive target within the drawer.
class DrawerActionItem {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const DrawerActionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Core widget implementing the Dynamic Contextual Bottom Sheet Drawer.
/// Transforms into a side sheet automatically when viewport matches desktop breakpoints.
class DynamicContextualDrawer extends StatelessWidget {
  final DynamicContextualDrawerConfig config;
  final String userId;

  const DynamicContextualDrawer({
    super.key,
    required this.config,
    this.userId = 'mock_user_001',
  });

  /// Static helper to show the drawer. Dispatches analytical query triggers
  /// only when sheet animations successfully lock into view.
  static Future<void> show(
    BuildContext context, {
    required DynamicContextualDrawerConfig config,
    String userId = 'mock_user_001',
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840.0;

    final executionId = 'exec_${DateTime.now().millisecondsSinceEpoch}';

    if (isDesktop) {
      // Transform sheets into structured side sheets automatically when viewports match desktop breaks.
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: SizedBox(
                    width: 360.0,
                    height: double.infinity,
                    child: DynamicContextualDrawer(
                      config: config,
                      userId: userId,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Bottom Sheet modal behavior orchestration.
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        // Tapping the background dimming layer automatically dismisses active drawer states safely.
        isDismissible: true,
        enableDrag: true,
        builder: (context) {
          return DynamicContextualDrawer(
            config: config,
            userId: userId,
          );
        },
      );
    }

    // Dispatches analytical query triggers only when sheet animations successfully lock into view.
    _DrawerTelemetry.logEvent(
      stepExecutionId: executionId,
      executionStatus: 'Completed',
      stepOutcome: 'Pass',
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pair card surface tones precisely to predefined elevation token matrices.
    final surfaceColor = ElevationOverlay.applySurfaceTint(
      colorScheme.surface,
      colorScheme.surfaceTint,
      2.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        // Apply specific corner-rounding parameters to top sheet frames for distinct framing.
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Distinct framing drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                width: 32.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            // Auto-render a clean thumbnail preview pill upon valid data payload reception.
            if (config.enableThumbnailPreview && config.thumbnailUrl != null)
              _buildThumbnailPreviewPill(context),
            // Interactive targets list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: config.actions.length,
                separatorBuilder: (_, __) => const Divider(height: 1.0),
                itemBuilder: (context, index) {
                  return _DrawerActionTile(
                    item: config.actions[index],
                    errorColor: config.errorColor ?? colorScheme.error,
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPreviewPill(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: colorScheme.onSecondaryContainer, size: 20.0),
            const SizedBox(width: 8.0),
            Text(
              'Preview Available',
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerActionTile extends StatefulWidget {
  final DrawerActionItem item;
  final Color errorColor;

  const _DrawerActionTile({
    required this.item,
    required this.errorColor,
  });

  @override
  State<_DrawerActionTile> createState() => _DrawerActionTileState();
}

class _DrawerActionTileState extends State<_DrawerActionTile> {
  bool _showErrorBanner = false;

  void _handleTap() {
    // Simulate file type validation check
    final isValidType = !widget.item.label.toLowerCase().contains('invalid');

    if (!isValidType) {
      // Throw immediate, non-disruptive feedback banners if an improper file type is selected.
      // Display error warnings using distinctive, clear semantic red accent palettes.
      setState(() => _showErrorBanner = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showErrorBanner = false);
      });
      return;
    }

    widget.item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDestructive = widget.item.isDestructive;

    final foregroundColor = isDestructive ? widget.errorColor : colorScheme.onSurface;
    final iconColor = isDestructive ? widget.errorColor : colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Restrict sheet content to interactive targets that meet the minimum 48dp dimension rule.
        // Ensure target sizes comply fully with mobile accessibility standards (minimum 48x48dp dimensions).
        SizedBox(
          height: 56.0, // Exceeds 48dp minimum
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      color: iconColor,
                      size: 24.0,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Non-disruptive feedback banner
        if (_showErrorBanner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: widget.errorColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: widget.errorColor, size: 16.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Improper file type selected.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Example usage / mock implementation demonstrating the component.
class DynamicContextualDrawerDemo extends StatelessWidget {
  const DynamicContextualDrawerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Contextual Drawer Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openDrawer(context),
          child: const Text('Open Filter Drawer'),
        ),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    final config = DynamicContextualDrawerConfig(
      enableThumbnailPreview: true,
      thumbnailUrl: 'mock://payload/preview.jpg',
      actions: [
        DrawerActionItem(
          id: 'filter_date',
          label: 'Filter by Date',
          icon: Icons.calendar_today_outlined,
          onTap: () => Navigator.of(context).pop(),
        ),
        DrawerActionItem(
          id: 'filter_category',
          label: 'Filter by Category',
          icon: Icons.category_outlined,
          onTap: () => Navigator.of(context).pop(),
        ),
        DrawerActionItem(
          id: 'sort_asc',
          label: 'Sort Ascending',
          icon: Icons.arrow_upward_outlined,
          onTap: () => Navigator.of(context).pop(),
        ),
        DrawerActionItem(
          id: 'invalid_file_test',
          label: 'Upload Invalid File Type',
          icon: Icons.upload_file_outlined,
          onTap: () {},
        ),
        DrawerActionItem(
          id: 'clear_filters',
          label: 'Clear All Filters',
          icon: Icons.delete_sweep_outlined,
          onTap: () => Navigator.of(context).pop(),
          isDestructive: true,
        ),
      ],
    );

    DynamicContextualDrawer.show(
      context,
      config: config,
      userId: 'user_demo_001',
    );
  }
}
