/*
 * STEP 6: SGTIM-019 — Build Adaptive Circular Action Shortcut Buttons (<ContextualFAB>)
 * 
 * Setup Step (Action): Navigate to the core UI layout component bundle directory.
 * Setup Step Description: Pin a standardized 56x56dp circular action button in the lower right thumb-comfort workspace sector.
 *   Program smooth expansion animation unfolding secondary action menus upward.
 * 
 * DEA AUDIT NOTICE:
 * Environment & Configuration Setup Readiness: Pass/Fail gate.
 * Poka-Yoke Gate: Hide the floating action button completely if account permissions restrict a user from running that task.
 * Self-Chasing: Sub-menus collapse back to a single button automatically if a user taps anywhere outside the active option frame.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Firmly placed in lower-screen thumb reach zones (56x56dp standard M3 FAB).
 *   - High-contrast button background tones for clear visibility over any data backdrop.
 *   - Self-chasing sub-menu collapse when tapping outside option frame.
 *   - Minimum touch target size 56x56dp for primary action trigger.
 * 
 * What Was Done to Complete This Step:
 *   - Created `ContextualFab` widget, `FabShortcutAction` model, and `FabSetupReadiness` enum.
 *   - Integrated RBAC permission hiding gate and gesture backdrop auto-collapse.
 *   - Added required telemetry fields (`isAuthorized`, `actionTimestamp`, `userSessionId`, `completionStatus`).
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

enum FabSetupReadiness {
  pass('Pass'),
  fail('Fail');

  final String label;
  const FabSetupReadiness(this.label);
}

class FabShortcutAction {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAuthorized;

  const FabShortcutAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isAuthorized = true,
  });
}

/// Step SGTIM-019: Adaptive Circular Action Shortcut Buttons (ContextualFab).
class ContextualFab extends StatefulWidget {
  final List<FabShortcutAction> actions;
  final IconData mainIcon;
  final bool isAuthorized;
  final String userRole;
  final DateTime? actionTimestamp;
  final String? userSessionId;
  final FabSetupReadiness completionStatus;

  const ContextualFab({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.isAuthorized = true,
    this.userRole = 'OPERATIONS-LEAD',
    this.actionTimestamp,
    this.userSessionId,
    this.completionStatus = FabSetupReadiness.pass,
  });

  @override
  State<ContextualFab> createState() => _ContextualFabState();
}

class _ContextualFabState extends State<ContextualFab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke Gate: Hide FAB completely if account permissions restrict user
    if (!widget.isAuthorized) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authorizedActions = widget.actions.where((a) => a.isAuthorized).toList();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Self-Chasing Backdrop to collapse menu on outside tap
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black12),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen)
              ScaleTransition(
                scale: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: authorizedActions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(action.label, style: theme.textTheme.labelMedium),
                          ),
                          AppSpacingTokens.hGapSm,
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: FloatingActionButton.small(
                              heroTag: 'fab_${action.id}',
                              onPressed: () {
                                _toggleMenu();
                                action.onTap();
                              },
                              child: Icon(action.icon),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(
              width: 56.0,
              height: 56.0,
              child: FloatingActionButton(
                heroTag: 'main_contextual_fab',
                onPressed: _toggleMenu,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: AnimatedRotation(
                  turns: _isOpen ? 0.125 : 0.0, // 45 degree rotate on open
                  duration: const Duration(milliseconds: 250),
                  child: Icon(widget.mainIcon),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

