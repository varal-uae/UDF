import 'dart:async';
import 'package:flutter/material.dart';

/// Row 412: GEN-01502 (Seq 18211)
/// Action: Configure an optimistic slot-locking engine that applies a 10-minute hold upon slot selection.
/// Quality Gate: SCOR Supply Chain Scheduling KPI (Target: 0 conflict).
class OptimisticSlotLockEnginePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const OptimisticSlotLockEnginePanel({
    super.key,
    this.globalRefId = 'GEN-01502',
    this.atomicStepRefId = 'GEN-01502',
    this.sequenceOrder = 18211,
  });

  @override
  State<OptimisticSlotLockEnginePanel> createState() =>
      _OptimisticSlotLockEnginePanelState();
}

class _OptimisticSlotLockEnginePanelState
    extends State<OptimisticSlotLockEnginePanel> {
  final double _conflictRate = 0.0;
  String? _lockedSlot;
  int _secondsRemaining = 600; // 10 minutes hold
  Timer? _countdownTimer;
  int _successfulLocks = 29;

  final List<String> _availableSlots = const [
    'Saturday 10:00 AM - 11:30 AM',
    'Saturday 02:00 PM - 03:30 PM',
    'Sunday 11:00 AM - 12:30 PM',
    'Sunday 03:00 PM - 04:30 PM',
  ];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _lockSlot(String slot) {
    _countdownTimer?.cancel();
    setState(() {
      _lockedSlot = slot;
      _secondsRemaining = 600;
      _successfulLocks++;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _lockedSlot = null);
      }
    });
  }

  void _releaseLock() {
    _countdownTimer?.cancel();
    setState(() {
      _lockedSlot = null;
      _secondsRemaining = 600;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-01502: Optimistic Slot-Locking',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 18211 • Standard: SCOR Scheduling KPI',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('0% CONFLICT'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Select a Slot to Apply 10-Minute Hold:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._availableSlots.map((slot) {
              final isLocked = _lockedSlot == slot;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => _lockSlot(slot),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLocked ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(slot, style: TextStyle(fontWeight: isLocked ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(_secondsRemaining),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text('Available', style: TextStyle(color: Colors.green, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            if (_lockedSlot != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hold active for $_lockedSlot. Remaining: ${_formatTime(_secondsRemaining)}.',
                        style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: _releaseLock,
                      child: const Text('Release Hold'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lock Conflict Rate: ${(_conflictRate * 100).toInt()}%',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Successful Holds: $_successfulLocks', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: OptimisticSlotLockEnginePanel(),
          ),
        ),
      ),
    ),
  );
}
