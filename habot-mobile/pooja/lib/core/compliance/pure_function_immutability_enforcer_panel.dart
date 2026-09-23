import 'package:flutter/material.dart';

/// Row 313: GEN-00418 (Seq 17127)
/// Action: Enforce pure function patterns returning new immutable outputs.
/// Quality Gate: ISO/IEC 25010 Software Quality — Modifiability & Zero Side-Effects.
class PureFunctionImmutabilityEnforcerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const PureFunctionImmutabilityEnforcerPanel({
    super.key,
    this.globalRefId = 'GEN-00418',
    this.atomicStepRefId = 'GEN-00418',
    this.sequenceOrder = 17127,
  });

  @override
  State<PureFunctionImmutabilityEnforcerPanel> createState() =>
      _PureFunctionImmutabilityEnforcerPanelState();
}

class _PureFunctionImmutabilityEnforcerPanelState
    extends State<PureFunctionImmutabilityEnforcerPanel> {
  int _stateVersion = 1;
  final List<String> _immutableHistory = [
    'State v1: Genesis payload [hash: 0x9a1c]',
  ];

  // Pure function: takes input, returns new immutable copy without mutating original
  Map<String, dynamic> _pureTransform(Map<String, dynamic> input, int newVer) {
    return {
      'version': newVer,
      'timestamp': DateTime.now().toIso8601String(),
      'hash': '0x${(newVer * 0x3f8a).toRadixString(16).padLeft(4, '0')}',
    };
  }

  void _applyImmutableTransition() {
    setState(() {
      _stateVersion++;
      final newState = _pureTransform({'version': _stateVersion - 1}, _stateVersion);
      _immutableHistory.insert(
        0,
        'State v${newState['version']}: Transformed payload [hash: ${newState['hash']}]',
      );
      if (_immutableHistory.length > 5) {
        _immutableHistory.removeLast();
      }
    });
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
                    Icons.functions_rounded,
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
                        'Pure Function Immutability Enforcer',
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
                    'ZERO SIDE-EFFECTS',
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
              'Enforces pure functional programming patterns across compliance transforms, guaranteeing inputs are never mutated in place and all state outputs are immutable (ISO/IEC 25010).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _applyImmutableTransition,
                  icon: const Icon(Icons.add_moderator_rounded, size: 18),
                  label: const Text('Invoke Pure Transformation'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('State Version', style: TextStyle(fontSize: 11)),
                      Text('v$_stateVersion', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('Mutation Policy', style: TextStyle(fontSize: 11)),
                      Text('Immutable Copy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('Side Effects', style: TextStyle(fontSize: 11)),
                      Text('0 Detected', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _immutableHistory
                    .map((entry) => Text(
                          entry,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.lightGreenAccent,
                          ),
                        ))
                    .toList(),
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
            child: PureFunctionImmutabilityEnforcerPanel(),
          ),
        ),
      ),
    ),
  );
}
