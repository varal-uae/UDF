// MUFCE-013-A11 — StatelessBinaryToggleSwitch Component with Status Interlock.
// Provides a reusable, accessible toggle switch with double-tap protection, optimistic UI updates, loading placeholders with pulse animations, and automated rollback on sync failure.

import 'dart:async';
import 'package:flutter/material.dart';

/// Domain model representing the lock state data requirements.
class SwitchLockState {
  final String lockType;
  final bool lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;

  const SwitchLockState({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });

  SwitchLockState copyWith({
    String? lockType,
    bool? lockStatus,
    String? lockedBy,
    DateTime? lockTimestamp,
    String? lockReason,
  }) {
    return SwitchLockState(
      lockType: lockType ?? this.lockType,
      lockStatus: lockStatus ?? this.lockStatus,
      lockedBy: lockedBy ?? this.lockedBy,
      lockTimestamp: lockTimestamp ?? this.lockTimestamp,
      lockReason: lockReason ?? this.lockReason,
    );
  }
}

/// Mock repository simulating High Availability relational cluster commits.
class MockPreferenceRepository {
  static Future<bool> commitPreferenceUpdate(SwitchLockState newState) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate occasional transaction conflicts or network drops (10% failure rate)
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('Transaction conflict: Failed synchronization loop.');
    }
    return true;
  }
}

/// Automated error block notifier for operations leads.
class OperationsLeadNotifier {
  static void notifyFailure(String errorMessage) {
    debugPrint('[OPERATIONS LEAD ALERT] Sync Failure: $errorMessage');
  }
}

/// A stateful wrapper that manages the interlock, loading states, and error rollbacks
/// for the core [StatelessBinaryToggleSwitch].
class StatefulSwitchInterlock extends StatefulWidget {
  final SwitchLockState initialState;
  final ValueChanged<SwitchLockState>? onStateChanged;

  const StatefulSwitchInterlock({
    super.key,
    required this.initialState,
    this.onStateChanged,
  });

  @override
  State<StatefulSwitchInterlock> createState() => _StatefulSwitchInterlockState();
}

class _StatefulSwitchInterlockState extends State<StatefulSwitchInterlock>
    with SingleTickerProviderStateMixin {
  late SwitchLockState _currentState;
  bool _isProcessing = false;
  bool _isLocked = false; // Poka-Yoke: Click intercept block
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle(bool newValue) async {
    // Mistake-Proofing (Poka-Yoke): Block double activation commands
    if (_isLocked || _isProcessing) return;

    setState(() {
      _isLocked = true;
      _isProcessing = true;
      _pulseController.repeat(reverse: true);
      // Optimistic UI update
      _currentState = _currentState.copyWith(
        lockStatus: newValue,
        lockTimestamp: DateTime.now(),
      );
    });

    try {
      await MockPreferenceRepository.commitPreferenceUpdate(_currentState);
      
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isLocked = false;
        _pulseController.stop();
        _pulseController.reset();
      });
      widget.onStateChanged?.call(_currentState);
    } catch (e) {
      // Self-Chasing: Automated rollback and notify operations leads
      OperationsLeadNotifier.notifyFailure(e.toString());
      
      if (!mounted) return;
      setState(() {
        // Rollback to previous state
        _currentState = _currentState.copyWith(lockStatus: !newValue);
        _isProcessing = false;
        _isLocked = false;
        _pulseController.stop();
        _pulseController.reset();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status update failed. Rolled back. ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Operational status toggle',
      hint: 'Double tap to change preference status',
      toggled: _currentState.lockStatus,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentState.lockType,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentState.lockReason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              // Mobile-First & Responsive UI: Muted background surfaces for loading placeholders
              // Apply soft pulse animations to loading shapes
              if (_isProcessing)
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Container(
                    width: 52,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              IgnorePointer(
                ignoring: _isProcessing,
                child: Opacity(
                  opacity: _isProcessing ? 0.0 : 1.0,
                  child: StatelessBinaryToggleSwitch(
                    value: _currentState.lockStatus,
                    onChanged: _handleToggle,
                    activeColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                    thumbColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The atomic, reusable stateless binary toggle switch component.
/// Follows strict thickness rules and matches track fills to explicit theme neutral color slots.
class StatelessBinaryToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveTrackColor;
  final Color thumbColor;

  const StatelessBinaryToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveTrackColor,
    required this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    // UX Translation: Slider core slides horizontally to target margins fluidly.
    // Leverages native mobile toggle switch mechanics for single-hand finger sweeping.
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: thumbColor,
      activeTrackColor: activeColor,
      inactiveThumbColor: thumbColor,
      inactiveTrackColor: inactiveTrackColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashRadius: 0, // Prevent intrusive confirmation boxes / splashes
    );
  }
}

/// Example usage demonstrating vertical stacking reflow logic for mobile viewports.
class SwitchSettingsScreen extends StatelessWidget {
  const SwitchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<SwitchLockState> mockPreferences = [
      SwitchLockState(
        lockType: 'Push Notifications',
        lockStatus: true,
        lockedBy: 'System',
        lockTimestamp: DateTime.now(),
        lockReason: 'Receive marketing and operational alerts.',
      ),
      SwitchLockState(
        lockType: 'Dark Mode Override',
        lockStatus: false,
        lockedBy: 'User_Session_99',
        lockTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        lockReason: 'Force light theme across all modules.',
      ),
      SwitchLockState(
        lockType: 'Location Tracking',
        lockStatus: true,
        lockedBy: 'Hardware_Mapping',
        lockTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        lockReason: 'Enable proximity-based feature unlocking.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preference Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Configure auto-activating vertical stacking reflow logic for mobile width viewports
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile ? 16.0 : 32.0;

            return ListView.separated(
              padding: EdgeInsets.all(padding),
              itemCount: mockPreferences.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, index) {
                return StatefulSwitchInterlock(
                  initialState: mockPreferences[index],
                  onStateChanged: (newState) {
                    // Commits preference updates straight to High Availability relational clusters
                    debugPrint('Preference committed: \${newState.lockType} -> \${newState.lockStatus}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
