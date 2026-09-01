// ============================================================================
// TELEMETRY METADATA BLOCK
// Step Execution ID: ANSA-013-EXEC-99201
// Execution Status: SUCCESS
// Execution Timestamp: 2026-08-19T11:16:34+05:30
// Step Outcome: PASS - Persistent Header Layout System Verified
// User ID: USR-ANSA-013-AUDIT
// Completion Status: Target: Complete - Scope Coverage / Audit Completeness
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';

/// ANSA-013: Persistent Header Layout System
///
/// Implements PreferredSizeWidget to seamlessly function as a Scaffold appBar or custom top header.
class PersistentHeaderLayoutSystem extends StatefulWidget
    implements PreferredSizeWidget {
  final String traceId;
  final bool initialHasActionPermissions;
  final VoidCallback? onBackPressed;
  final List<Widget>? actionShortcuts;

  const PersistentHeaderLayoutSystem({
    super.key,
    this.traceId = "TRC-94820-SEC",
    this.initialHasActionPermissions = true,
    this.onBackPressed,
    this.actionShortcuts,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  State<PersistentHeaderLayoutSystem> createState() =>
      _PersistentHeaderLayoutSystemState();
}

class _PersistentHeaderLayoutSystemState
    extends State<PersistentHeaderLayoutSystem> {
  late bool _hasActionPermissions;

  @override
  void initState() {
    super.initState();
    _hasActionPermissions = widget.initialHasActionPermissions;
  }

  void _togglePermissions() {
    setState(() {
      _hasActionPermissions = !_hasActionPermissions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final isMobile = mediaWidth <= 600;

    // Strict 56dp Mobile Bounds & Responsive Height
    final headerHeight = isMobile ? 56.0 : 64.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PreferredSize(
      preferredSize: Size.fromHeight(headerHeight),
      child: Container(
        height: headerHeight + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                // Highly transparent surface color
                color: colorScheme.surface.withValues(alpha: 0.7),
                // Subtle bottom divider line
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Edge: Essential Details (Back button, trace_id, connectivity status)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
                          tooltip: 'Back',
                          onPressed: widget.onBackPressed ??
                              () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                        ),
                        const SizedBox(width: 4.0),
                        // Connectivity Status Icon
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi,
                            size: 14.0,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Mock trace_id Text
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SYSTEM HEADER",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                "trace_id: ${widget.traceId}",
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Monospace',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Permission Toggle Button (Demo / Security Test Harness)
                  OutlinedButton.icon(
                    onPressed: _togglePermissions,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      side: BorderSide(
                        color: _hasActionPermissions
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                    ),
                    icon: Icon(
                      _hasActionPermissions
                          ? Icons.lock_open
                          : Icons.lock_outline,
                      size: 14.0,
                      color: _hasActionPermissions
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    label: Text(
                      _hasActionPermissions ? "Perms: ON" : "Perms: OFF",
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: _hasActionPermissions
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Right Edge: Contextual Security & Action Shortcuts (Poka-Yoke)
                  // If hasActionPermissions is false, buttons MUST be completely removed from layout
                  _hasActionPermissions
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.actionShortcuts ??
                              [
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20.0),
                                  tooltip: 'Sync Data',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Action executed: Sync'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings, size: 20.0),
                                  tooltip: 'Header Settings',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Action executed: Settings'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Demo Workspace Screen for PersistentHeaderLayoutSystem
class PersistentHeaderDemoScreen extends StatelessWidget {
  const PersistentHeaderDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PersistentHeaderLayoutSystem(
        traceId: "TRC-ANSA-013-SEC-OK",
        initialHasActionPermissions: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth <= 600;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMobile ? Icons.smartphone : Icons.desktop_windows,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isMobile
                            ? "Mobile View (Height: 56dp)"
                            : "Web/Tablet View (Height: 64dp)",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Width: ${constraints.maxWidth.toStringAsFixed(1)}px. "
                        "The header utilizes BackdropFilter with ImageFilter.blur(10, 10), "
                        "transparent background surface.withOpacity(0.7), and bottom border divider.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}
