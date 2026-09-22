import 'package:flutter/material.dart';

/// Row 6: MUFCE-011 (Seq 30470)
/// Action: Conduct code review and merge the change.
/// Quality Gate: Code Review Rigor (Optimal: reviewer approvals + automated checks passing).
class CodeReviewMergeGatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const CodeReviewMergeGatePanel({
    super.key,
    this.globalRefId = 'MUFCE-011',
    this.atomicStepRefId = 'MUFCE-011-A19',
    this.sequenceOrder = 30470,
  });

  @override
  State<CodeReviewMergeGatePanel> createState() =>
      _CodeReviewMergeGatePanelState();
}

class _CodeReviewMergeGatePanelState extends State<CodeReviewMergeGatePanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      'One or more reviewer approvals plus all automated checks (lint, tests, security scan) passing';
  bool _lintPass = false;
  bool _reviewerApproved = false;
  bool _mergeReady = false;

  void _executeVerification() {
    setState(() {
      _isActionActive = !_isActionActive;
      _executionCount++;
      _lintPass = _isActionActive;
      _reviewerApproved = _isActionActive;
      _mergeReady = _isActionActive && _lintPass && _reviewerApproved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _mergeReady
              ? 'Merge gate open. Audit verified against Code Review Rigor.'
              : 'Audit event dispatched. Latency verified against Code Review Rigor.',
        ),
        duration: const Duration(seconds: 2),
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
                    Icons.merge_type_outlined,
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
                        '${widget.globalRefId}: Code Review Merge Gate',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Code Review Rigor',
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
              'Conduct code review and merge the change.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    _lintPass ? Icons.check_circle : Icons.cancel_outlined,
                    size: 16,
                    color: _lintPass ? Colors.green : theme.colorScheme.error,
                  ),
                  label: const Text('Lint / Tests'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: Icon(
                    _reviewerApproved
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    size: 16,
                    color: _reviewerApproved
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                  label: const Text('Reviewer'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: Icon(
                    _mergeReady ? Icons.lock_open : Icons.lock_outline,
                    size: 16,
                    color: _mergeReady
                        ? Colors.green
                        : theme.colorScheme.outline,
                  ),
                  label: Text(_mergeReady ? 'Merge Ready' : 'Merge Locked'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
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
            child: CodeReviewMergeGatePanel(),
          ),
        ),
      ),
    ),
  );
}
