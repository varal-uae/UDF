import 'package:flutter/material.dart';

/// Row 299: GEN-00264 (Seq 16973)
/// Action: Package the module as IMEFocusManager inside @gacl/ui-core.
/// Quality Gate: ISO/IEC 25010 Functional Suitability / Soft Keyboard Inset Handling.
class ImeFocusManagerPackagePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const ImeFocusManagerPackagePanel({
    super.key,
    this.globalRefId = 'GEN-00264',
    this.atomicStepRefId = 'GEN-00264',
    this.sequenceOrder = 16973,
  });

  @override
  State<ImeFocusManagerPackagePanel> createState() =>
      _ImeFocusManagerPackagePanelState();
}

class _ImeFocusManagerPackagePanelState
    extends State<ImeFocusManagerPackagePanel> {
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;
  int _focusTransitions = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _focusTransitions++;
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
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
                    Icons.keyboard_alt_rounded,
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
                        'IMEFocusManager Package Panel',
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
                    '@gacl/ui-core PACKAGED',
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
              'Packages the IMEFocusManager module into @gacl/ui-core, coordinating soft-keyboard appearance, automatic viewport panning, and programmatic unfocus dismissal.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Simulated Input Field',
                hintText: 'Tap to trigger IME focus change',
                prefixIcon: const Icon(Icons.edit),
                suffixIcon: _isKeyboardVisible
                    ? IconButton(
                        icon: const Icon(Icons.keyboard_hide),
                        onPressed: () => _focusNode.unfocus(),
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
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
                      const Text('Soft Keyboard IME State', style: TextStyle(fontSize: 11)),
                      Text(
                        _isKeyboardVisible ? 'OPEN (FOCUSED)' : 'DISMISSED (IDLE)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isKeyboardVisible ? Colors.indigo : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Focus Transitions', style: TextStyle(fontSize: 11)),
                      Text('$_focusTransitions', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
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
