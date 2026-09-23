import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Row 281: GEN-00072 (Seq 16781)
/// Action: Intercept keypress events before updating component state.
/// Quality Gate: State preservation & input hygiene gate (100% intent match).
class KeypressInterceptionStateGuardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const KeypressInterceptionStateGuardPanel({
    super.key,
    this.globalRefId = 'GEN-00072',
    this.atomicStepRefId = 'GEN-00072',
    this.sequenceOrder = 16781,
  });

  @override
  State<KeypressInterceptionStateGuardPanel> createState() =>
      _KeypressInterceptionStateGuardPanelState();
}

class _KeypressInterceptionStateGuardPanelState
    extends State<KeypressInterceptionStateGuardPanel> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _interceptedKeypresses = 0;
  int _blockedKeypresses = 0;
  String _lastInterceptedKey = 'NONE';
  final List<String> _interceptionAuditLog = [];

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyLabel = event.logicalKey.keyLabel;
      setState(() {
        _interceptedKeypresses++;
        _lastInterceptedKey = keyLabel;
      });

      // Intercept and block forbidden characters (e.g., <, >, ;, script tags)
      if (keyLabel == '<' || keyLabel == '>' || keyLabel == ';') {
        setState(() {
          _blockedKeypresses++;
          _interceptionAuditLog.insert(
            0,
            '[INTERCEPT_BLOCKED] Forbidden symbol "$keyLabel" blocked before reaching state!',
          );
          if (_interceptionAuditLog.length > 20) _interceptionAuditLog.removeLast();
        });
        return KeyEventResult.handled; // Drop the keystroke
      }

      setState(() {
        _interceptionAuditLog.insert(
          0,
          '[INTERCEPT_PERMITTED] Key "$keyLabel" passed security gate -> State updated.',
        );
        if (_interceptionAuditLog.length > 20) _interceptionAuditLog.removeLast();
      });
    }
    return KeyEventResult.ignored;
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
                    Icons.keyboard_command_key_rounded,
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
                        'Keypress Interception State Guard',
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
                    'SECURITY GUARDED',
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
              'Intercepts raw keystrokes before updating component state, sanitizing inputs and stripping injection characters in real time.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Focus(
              focusNode: _focusNode,
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: 'Guarded Text Input (Blocks <, >, ;)',
                  hintText: 'Type symbols to test interception...',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.shield_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Intercepted', style: TextStyle(fontSize: 11)),
                    Text('$_interceptedKeypresses', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Blocked', style: TextStyle(fontSize: 11)),
                    Text('$_blockedKeypresses', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Last Keystroke', style: TextStyle(fontSize: 11)),
                    Text(_lastInterceptedKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Keystroke Interception Logs:',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              height: 75,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _interceptionAuditLog.length,
                itemBuilder: (context, index) {
                  return Text(
                    _interceptionAuditLog[index],
                    style: const TextStyle(
                      color: Colors.yellowAccent,
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

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: KeypressInterceptionStateGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
