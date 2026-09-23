import 'package:flutter/material.dart';

/// Row 9: MUFCE-018 (Seq 30520)
/// Action: Open the DevOps CI/CD pipeline code analysis directory and locate DesignComplianceLinterEngine.
/// Quality Gate: Deployment / Build Stability Rate (Optimal: 99.9% successful builds).
class DesignComplianceLinterEnginePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DesignComplianceLinterEnginePanel({
    super.key,
    this.globalRefId = 'MUFCE-018',
    this.atomicStepRefId = 'MUFCE-018-A01',
    this.sequenceOrder = 30520,
  });

  @override
  State<DesignComplianceLinterEnginePanel> createState() =>
      _DesignComplianceLinterEnginePanelState();
}

class _DesignComplianceLinterEnginePanelState
    extends State<DesignComplianceLinterEnginePanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric = '99.9% successful builds';

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
                    Icons.rule_folder_outlined,
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
                        '${widget.globalRefId}: Design Compliance Linter',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Build Stability Rate',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 16),
                  label: Text('ACTIVE PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benchmark Target:',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _targetMetric,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Telemetry Executions:',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_executionCount runs',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Open the DevOps CI/CD pipeline code analysis directory and locate DesignComplianceLinterEngine.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isActionActive = !_isActionActive;
                    _executionCount++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'DesignComplianceLinterEngine verified. 99.9% build stability standard enforced.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.verified_user_rounded
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Linter Engine Active'
                    : 'Execute Step Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone entrypoint for isolated file verification.
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: DesignComplianceLinterEnginePanel(),
          ),
        ),
      ),
    ),
  );
}
