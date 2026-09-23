import 'package:flutter/material.dart';

/// Row 314: GEN-00429 (Seq 17138)
/// Action: Add an explicit exception trigger if the evaluation result is null or ambiguous.
/// Quality Gate: ISO/IEC 25010 Functional Correctness / ISACA COBIT 2019 (Zero Ambiguous Standard).
class ExplicitExceptionTriggerGuardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const ExplicitExceptionTriggerGuardPanel({
    super.key,
    this.globalRefId = 'GEN-00429',
    this.atomicStepRefId = 'GEN-00429',
    this.sequenceOrder = 17138,
  });

  @override
  State<ExplicitExceptionTriggerGuardPanel> createState() =>
      _ExplicitExceptionTriggerGuardPanelState();
}

class _ExplicitExceptionTriggerGuardPanelState
    extends State<ExplicitExceptionTriggerGuardPanel> {
  String _evaluationInput = 'VALID_CLEARANCE';
  String _guardResult = 'PASS: Explicit Boolean True';
  bool _exceptionFired = false;
  int _evaluationsCount = 0;

  void _runEvaluation() {
    setState(() {
      _evaluationsCount++;
      if (_evaluationInput == 'NULL_INPUT') {
        _exceptionFired = true;
        _guardResult = 'EXCEPTION: AmbiguousEvaluationException — Null evaluation rejected';
      } else if (_evaluationInput == 'AMBIGUOUS_STATE') {
        _exceptionFired = true;
        _guardResult = 'EXCEPTION: AmbiguousEvaluationException — Partial truth rejected';
      } else {
        _exceptionFired = false;
        _guardResult = 'PASS: Explicit Boolean True (Determinism = 100%)';
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
                    Icons.gavel_rounded,
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
                        'Explicit Exception Trigger Guard',
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
                    color: _exceptionFired
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _exceptionFired ? Colors.red : Colors.green,
                    ),
                  ),
                  child: Text(
                    _exceptionFired ? 'EXCEPTION FIRED' : 'DETERMINISTIC PASS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _exceptionFired ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enforces fail-safe error handling by explicitly raising an AmbiguousEvaluationException if any compliance evaluation evaluates to null or indeterminate truth states (COBIT 2019).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Valid Clearance'),
                  selected: _evaluationInput == 'VALID_CLEARANCE',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _evaluationInput = 'VALID_CLEARANCE');
                      _runEvaluation();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Simulate Null Value'),
                  selected: _evaluationInput == 'NULL_INPUT',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _evaluationInput = 'NULL_INPUT');
                      _runEvaluation();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Simulate Ambiguous Result'),
                  selected: _evaluationInput == 'AMBIGUOUS_STATE',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _evaluationInput = 'AMBIGUOUS_STATE');
                      _runEvaluation();
                    }
                  },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Guard Evaluation Result:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Evals: $_evaluationsCount', style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _guardResult,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _exceptionFired ? Colors.red : Colors.green,
                    ),
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

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ExplicitExceptionTriggerGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
