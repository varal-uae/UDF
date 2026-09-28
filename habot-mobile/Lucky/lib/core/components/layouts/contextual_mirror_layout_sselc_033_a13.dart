// SSELC-033-A13 — Contextual Mirror Layout with Keyboard Avoidance.
// Implements a universal split-screen layout that collapses to a vertical stack on mobile, locking the observation panel to the top 40% and preventing software keyboards from pushing content off-screen.

import 'package:flutter/material.dart';

/// Mock data model representing the atomic-level lock fields required by the system.
class LockContextData {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;

  const LockContextData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });
}

/// Hardcoded mock repository supplying realistic local data for UI rendering.
class MockLockRepository {
  static const List<LockContextData> mockLocks = [
    LockContextData(
      lockType: 'SESSION_EDIT',
      lockStatus: 'ACTIVE',
      lockedBy: 'user_admin_01',
      lockTimestamp: _kMockTimestamp,
      lockReason: 'Prevent concurrent modification during evaluation.',
    ),
    LockContextData(
      lockType: 'RECORD_VIEW',
      lockStatus: 'PENDING',
      lockedBy: 'system_daemon',
      lockTimestamp: _kMockTimestamp,
      lockReason: 'Background synchronization in progress.',
    ),
  ];

  static const DateTime _kMockTimestamp = DateTime(2026, 9, 28, 10, 30);
}

/// A responsive layout widget that enforces strict container sizing constraints.
/// 
/// On desktop/tablet (width >= 600), it renders a 50/50 horizontal split.
/// On mobile (width < 600), it collapses into a vertical stack where the
/// observation surface is hard-locked to the top 40% of the viewport.
/// 
/// Wraps content in a [Scaffold] with resizeToAvoidBottomInset set to false
/// and uses a custom keyboard avoidance strategy to prevent observation boxes
/// from being pushed off-screen.
class ContextualMirrorLayout extends StatelessWidget {
  final Widget observationPanel;
  final Widget actionPanel;
  final bool immersiveMode;

  const ContextualMirrorLayout({
    super.key,
    required this.observationPanel,
    required this.actionPanel,
    this.immersiveMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final bool isMobile = screenSize.width < 600;

    return Scaffold(
      // Hard-lock: Prevent default scaffold resizing which shoves content off-screen.
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double availableHeight = constraints.maxHeight - viewInsets.bottom;
            final double safeHeight = availableHeight > 0 ? availableHeight : constraints.maxHeight;

            if (isMobile) {
              // Mobile-First: Vertical stacked configuration.
              // Observation panel locked securely to the top 40% viewport area.
              return Column(
                children: [
                  Container(
                    height: safeHeight * 0.4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: observationPanel,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: theme.colorScheme.surface,
                      child: SingleChildScrollView(
                        // Block double scroll interactions by constraining physics
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: viewInsets.bottom + 16,
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: actionPanel,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Desktop/Tablet: 50/50 split panel view.
              return Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                      ),
                      child: observationPanel,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: viewInsets.bottom + 24,
                          left: 24,
                          right: 24,
                          top: 24,
                        ),
                        child: actionPanel,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

/// Example implementation demonstrating the ContextualMirrorLayout
/// utilizing mock lock data and native keyboard invocation.
class ContextualMirrorExampleScreen extends StatelessWidget {
  const ContextualMirrorExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<LockContextData> locks = MockLockRepository.mockLocks;

    return ContextualMirrorLayout(
      observationPanel: _ObservationSurface(locks: locks, theme: theme),
      actionPanel: _ActionInputSurface(theme: theme),
    );
  }
}

class _ObservationSurface extends StatelessWidget {
  final List<LockContextData> locks;
  final ThemeData theme;

  const _ObservationSurface({required this.locks, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence & Lock Context',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lock = locks[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${lock.lockType} - ${lock.lockStatus}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'By: ${lock.lockedBy}\nReason: ${lock.lockReason}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionInputSurface extends StatelessWidget {
  final ThemeData theme;

  const _ActionInputSurface({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Execution',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Numeric Entry Field',
            hintText: 'Summons numeric keypad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Summons email keypad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.text,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Evaluation Notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit Evaluation'),
          ),
        ),
      ],
    );
  }
}
