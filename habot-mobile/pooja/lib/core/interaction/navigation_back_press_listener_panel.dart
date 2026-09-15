import 'package:flutter/material.dart';

/// Row 266: FLADE-006-02 (Seq 15832)
/// Action: Attach event listeners to all form navigation back-buttons and hardware back-press actions.
/// Quality Gate: ISO 9001:2015 Quality Management Standard (≥90% floor, ≥98% target, 100% ceiling).
class NavigationBackPressListenerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const NavigationBackPressListenerPanel({
    super.key,
    this.globalRefId = 'FLADE-006-02',
    this.atomicStepRefId = 'FLADE-006-02',
    this.sequenceOrder = 15832,
  });

  @override
  State<NavigationBackPressListenerPanel> createState() =>
      _NavigationBackPressListenerPanelState();
}

class _NavigationBackPressListenerPanelState
    extends State<NavigationBackPressListenerPanel> {
  bool _hasUnsavedFormChanges = true;
  int _interceptedBackPresses = 0;
  String _lastInterceptStatus = 'LISTENING';
  final List<String> _navigationAuditLog = [];

  void _handleBackPressAttempt(String triggerType) {
    setState(() {
      _interceptedBackPresses++;
      _lastInterceptStatus = 'INTERCEPTED via $triggerType';
      _navigationAuditLog.insert(
        0,
        '[$triggerType] Back-navigation action intercepted. Unsaved data protection evaluated.',
      );
      if (_navigationAuditLog.length > 20) _navigationAuditLog.removeLast();
    });

    if (_hasUnsavedFormChanges) {
      _showUnsavedChangesDialog(triggerType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clean navigation permitted: No unsaved modifications ($triggerType).'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showUnsavedChangesDialog(String triggerType) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('Unsaved Changes'),
            ],
          ),
          content: Text(
            'You have unsaved form progress. An event listener intercepted $triggerType. Discard edits or stay on current step?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Stay / Keep Editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Discard & Exit'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (shouldDiscard == true) {
      setState(() {
        _hasUnsavedFormChanges = false;
        _navigationAuditLog.insert(
          0,
          '[DISCARD_CONFIRMED] User opted to discard dirty changes. Exit route unlocked.',
        );
      });
    } else {
      setState(() {
        _navigationAuditLog.insert(
          0,
          '[NAVIGATION_CANCELED] Exit aborted by user; focus maintained on current step.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_hasUnsavedFormChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPressAttempt('HARDWARE_BACK_PRESS');
        }
      },
      child: Card(
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
                      Icons.arrow_back_rounded,
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
                          'Navigation Back-Press Listener',
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
                      color: _hasUnsavedFormChanges
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasUnsavedFormChanges ? Colors.amber : Colors.green,
                      ),
                    ),
                    child: Text(
                      _hasUnsavedFormChanges ? 'DIRTY FORM (LOCKED)' : 'CLEAN (PERMITTED)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _hasUnsavedFormChanges ? Colors.amber[900] : Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Attaches event listeners to all form navigation back-buttons and hardware back-press actions to prevent accidental data forfeiture.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Form Has Unsaved Modifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Simulates active user edits triggering the poka-yoke confirmation gate.'),
                      value: _hasUnsavedFormChanges,
                      onChanged: (val) {
                        setState(() {
                          _hasUnsavedFormChanges = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _handleBackPressAttempt('SOFTWARE_UI_BACK_BTN'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Trigger UI Back Button'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _handleBackPressAttempt('HARDWARE_BACK_GESTURE'),
                    icon: const Icon(Icons.phone_android_rounded, size: 18),
                    label: const Text('Simulate Android Back Gesture'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Intercepted Back Actions: $_interceptedBackPresses',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    _lastInterceptStatus,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Back-Press Event Telemetry Stream:',
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
                  itemCount: _navigationAuditLog.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _navigationAuditLog[index],
                      style: const TextStyle(
                        color: Colors.lightGreenAccent,
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
      ),
    );
  }
}
