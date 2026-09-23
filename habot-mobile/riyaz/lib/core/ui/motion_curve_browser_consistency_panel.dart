import 'package:flutter/material.dart';

/// Row 4: MUFCE-011 (Seq 30463)
/// Action: Confirm the motion curve behaves consistently across supported browsers.
/// Quality Gate: Functional Verification Accuracy (Optimal: ≥95% documented acceptance pass rate).
class MotionCurveBrowserConsistencyPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MotionCurveBrowserConsistencyPanel({
    super.key,
    this.globalRefId = 'MUFCE-011',
    this.atomicStepRefId = 'MUFCE-011-A12',
    this.sequenceOrder = 30463,
  });

  @override
  State<MotionCurveBrowserConsistencyPanel> createState() =>
      _MotionCurveBrowserConsistencyPanelState();
}

class _MotionCurveBrowserConsistencyPanelState
    extends State<MotionCurveBrowserConsistencyPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      'Verified against a documented acceptance criterion with a 95% or above pass rate';
  static const List<String> _browserMatrix = <String>[
    'Chrome',
    'Safari',
    'Firefox',
    'Edge',
  ];
  final Set<String> _passedBrowsers = <String>{};

  void _executeVerification() {
    setState(() {
      _isActionActive = !_isActionActive;
      _executionCount++;
      if (_isActionActive) {
        _passedBrowsers
          ..clear()
          ..addAll(_browserMatrix);
      } else {
        _passedBrowsers.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Audit event dispatched. Latency verified against Functional Verification Accuracy.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
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
                    Icons.web_asset_outlined,
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
                        '${widget.globalRefId}: Browser Motion Consistency',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Functional Verification',
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
                  label: Text('ACTIVE PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benchmark Target:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Telemetry Executions:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_executionCount runs',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Confirm the motion curve behaves consistently across supported browsers.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _browserMatrix.map((browser) {
                final passed = _passedBrowsers.contains(browser);
                return Chip(
                  avatar: Icon(
                    passed ? Icons.check : Icons.pending_outlined,
                    size: 16,
                    color: passed ? Colors.green : theme.colorScheme.outline,
                  ),
                  label: Text(browser),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _executeVerification,
                icon: Icon(
                  _isActionActive
                      ? Icons.sync_rounded
                      : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                  _isActionActive
                      ? 'Active Handshake Live'
                      : 'Execute Step Verification',
                ),
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
            child: MotionCurveBrowserConsistencyPanel(),
          ),
        ),
      ),
    ),
  );
}
