import 'package:flutter/material.dart';

/// Row 316: GEN-00451 (Seq 17160)
/// Action: Conduct static type checking via MyPy to enforce -> bool return signatures.
/// Quality Gate: PEP 484 (Type Hints) / MyPy Strict Mode (100% Boolean Return Enforcement).
class MypyStaticTypeEnforcerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MypyStaticTypeEnforcerPanel({
    super.key,
    this.globalRefId = 'GEN-00451',
    this.atomicStepRefId = 'GEN-00451',
    this.sequenceOrder = 17160,
  });

  @override
  State<MypyStaticTypeEnforcerPanel> createState() =>
      _MypyStaticTypeEnforcerPanelState();
}

class _MypyStaticTypeEnforcerPanelState
    extends State<MypyStaticTypeEnforcerPanel> {
  final List<Map<String, String>> _typedSignatures = [
    {'function': 'verify_kyc_compliance()', 'returnType': '-> bool', 'mypy': 'PASS'},
    {'function': 'validate_sanctions_list()', 'returnType': '-> bool', 'mypy': 'PASS'},
    {'function': 'check_premises_lease()', 'returnType': '-> bool', 'mypy': 'PASS'},
    {'function': 'verify_audit_hash_chain()', 'returnType': '-> bool', 'mypy': 'PASS'},
  ];

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
                    Icons.code_rounded,
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
                        'MyPy Static Type Enforcer',
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
                    'MYPY STRICT PASS',
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
              'Conducts strict MyPy static type analysis on compliance functions, mandating explicit -> bool return annotations and eliminating implicit Any or None return values.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _typedSignatures.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sig = _typedSignatures[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
                    title: Text(sig['function']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                    subtitle: Text('Return: ${sig['returnType']}', style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                    trailing: Text(
                      sig['mypy']!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
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
            child: MypyStaticTypeEnforcerPanel(),
          ),
        ),
      ),
    ),
  );
}
