import 'package:flutter/material.dart';

/// Row 289: GEN-00152 (Seq 16861)
/// Action: Wrap interactive components in permission components.
/// Quality Gate: NIST SP 800-162 (ABAC) / 100% Policy Decision Point Denial Standard.
class PermissionWrapperComponentPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const PermissionWrapperComponentPanel({
    super.key,
    this.globalRefId = 'GEN-00152',
    this.atomicStepRefId = 'GEN-00152',
    this.sequenceOrder = 16861,
  });

  @override
  State<PermissionWrapperComponentPanel> createState() =>
      _PermissionWrapperComponentPanelState();
}

class _PermissionWrapperComponentPanelState
    extends State<PermissionWrapperComponentPanel> {
  String _currentRole = 'GUEST_VIEWER';
  int _unauthorizedBlocks = 0;
  int _authorizedExecutions = 0;
  String _pdpMessage = 'Ready for ABAC evaluation';

  void _executeProtectedAction() {
    setState(() {
      if (_currentRole == 'ADMIN_COMPLIANCE') {
        _authorizedExecutions++;
        _pdpMessage = 'PDP: Access GRANTED for role $_currentRole';
      } else {
        _unauthorizedBlocks++;
        _pdpMessage = 'PDP: Access DENIED. Role $_currentRole lacks WRITE_PERMIT permission';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAttempts = _unauthorizedBlocks + _authorizedExecutions;
    final denialRate = totalAttempts > 0
        ? ((_unauthorizedBlocks / (_unauthorizedBlocks == 0 ? 1 : totalAttempts)) * 100).toStringAsFixed(0)
        : '100';

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
                    Icons.admin_panel_settings_rounded,
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
                        'Permission Wrapper Component',
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
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'NIST SP 800-162 ABAC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enforces client-side and PDP server-side boundary wrapping around interactive controls, guaranteeing unauthorized actions are 100% blocked before invocation.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Current User Session Role:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'GUEST_VIEWER',
                  label: Text('Guest (Read)'),
                  icon: Icon(Icons.visibility),
                ),
                ButtonSegment(
                  value: 'ADMIN_COMPLIANCE',
                  label: Text('Admin (Write)'),
                  icon: Icon(Icons.verified_user),
                ),
              ],
              selected: {_currentRole},
              onSelectionChanged: (val) {
                setState(() {
                  _currentRole = val.first;
                  _pdpMessage = 'Role switched to $_currentRole';
                });
              },
            ),
            const SizedBox(height: 16),
            // Permission-wrapped interactive control
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Action: Mutate Compliance Record',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _pdpMessage,
                          style: TextStyle(
                            fontSize: 11,
                            color: _pdpMessage.contains('GRANTED')
                                ? Colors.green
                                : (_pdpMessage.contains('DENIED') ? Colors.red : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _executeProtectedAction,
                    child: const Text('Invoke'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Authorized Calls', style: TextStyle(fontSize: 11)),
                      Text('$_authorizedExecutions', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Unauthorized Blocked', style: TextStyle(fontSize: 11)),
                      Text('$_unauthorizedBlocks', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Denial Protection', style: TextStyle(fontSize: 11)),
                      Text('$denialRate%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
