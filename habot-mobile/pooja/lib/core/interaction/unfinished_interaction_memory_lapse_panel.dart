import 'dart:async';
import 'package:flutter/material.dart';

/// Row 264: FIEVR-044-A12 (Seq 15722)
/// Action: Configure unfinished interaction iterations to lapse from memory if operations freeze.
/// Quality Gate: 95% floor, 99% target, 100% ceiling (Pass/Fail).
class UnfinishedInteractionMemoryLapsePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const UnfinishedInteractionMemoryLapsePanel({
    super.key,
    this.globalRefId = 'FIEVR-044',
    this.atomicStepRefId = 'FIEVR-044-A12',
    this.sequenceOrder = 15722,
  });

  @override
  State<UnfinishedInteractionMemoryLapsePanel> createState() =>
      _UnfinishedInteractionMemoryLapsePanelState();
}

class _UnfinishedInteractionMemoryLapsePanelState
    extends State<UnfinishedInteractionMemoryLapsePanel> {
  int _inactivitySeconds = 0;
  final int _freezeThresholdSeconds = 15;
  bool _isLapsed = false;
  Timer? _heartbeatTimer;
  final List<String> _activeDraftTokens = [
    'SESSION_TOKEN_ALPHA_991',
    'UNFINISHED_REGISTRATION_CHUNK_B',
    'GEOLOCATION_STAMP_PENDING',
  ];
  final List<String> _eventHistory = [];

  @override
  void initState() {
    super.initState();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _inactivitySeconds++;
        if (_inactivitySeconds >= _freezeThresholdSeconds && !_isLapsed) {
          _triggerMemoryLapse();
        }
      });
    });
  }

  void _recordUserActivity() {
    setState(() {
      _inactivitySeconds = 0;
      if (_isLapsed) {
        _isLapsed = false;
        _activeDraftTokens.addAll([
          'SESSION_TOKEN_RESTORED_ALPHA',
          'NEW_ITERATION_CHUNK_V1',
        ]);
        _eventHistory.insert(
            0, '[INTERACTION_RESUMED] User activity registered. Memory session re-established.');
      } else {
        _eventHistory.insert(
            0, '[USER_HEARTBEAT] Tap detected. Inactivity counter reset to 0s.');
      }
      if (_eventHistory.length > 20) _eventHistory.removeLast();
    });
  }

  void _triggerMemoryLapse() {
    _isLapsed = true;
    _activeDraftTokens.clear();
    _eventHistory.insert(0,
        '[MEMORY_LAPSE_TRIGGERED] Operations frozen > ${_freezeThresholdSeconds}s. Volatile heap purged safely.');
    if (_eventHistory.length > 20) _eventHistory.removeLast();
  }

  void _forceSimulateFreeze() {
    setState(() {
      _inactivitySeconds = _freezeThresholdSeconds;
      _triggerMemoryLapse();
    });
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_inactivitySeconds / _freezeThresholdSeconds).clamp(0.0, 1.0);

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
                    color: _isLapsed
                        ? Colors.red.withValues(alpha: 0.15)
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isLapsed ? Icons.timer_off_rounded : Icons.timer_outlined,
                    color: _isLapsed ? Colors.red : theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unfinished Interaction Memory Lapse',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isLapsed
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isLapsed ? Colors.red : Colors.green,
                    ),
                  ),
                  child: Text(
                    _isLapsed ? 'LAPSED / EVICTED' : 'ALIVE (0s–15s)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isLapsed ? Colors.red[800] : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Configures unfinished interaction iterations to safely lapse from memory if operations freeze, preventing UI memory leaks.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inactivity Timer: ${_inactivitySeconds}s / ${_freezeThresholdSeconds}s',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      _isLapsed ? 'Memory Purged' : 'Active Session',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isLapsed ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isLapsed
                          ? Colors.red
                          : (progress > 0.7 ? Colors.orange : Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _recordUserActivity,
                  icon: const Icon(Icons.touch_app_rounded, size: 18),
                  label: const Text('Touch / Keep Alive (Reset)'),
                ),
                OutlinedButton.icon(
                  onPressed: _forceSimulateFreeze,
                  icon: const Icon(Icons.ac_unit_rounded, size: 18),
                  label: const Text('Simulate Freeze Event'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resident Interaction Tokens in RAM: (${_activeDraftTokens.length})',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (_activeDraftTokens.isEmpty)
                    const Text(
                      'No resident tokens. All unfinished interaction memory has lapsed safely.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.redAccent),
                    )
                  else
                    ..._activeDraftTokens.map(
                      (token) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              token,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Memory Eviction Telemetry:',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              height: 90,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _eventHistory.length,
                itemBuilder: (context, index) {
                  return Text(
                    _eventHistory[index],
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
