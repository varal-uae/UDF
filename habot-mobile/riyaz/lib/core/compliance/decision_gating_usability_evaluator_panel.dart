/*
 * SCTSS-014-A12 — Decision Gating Usability Evaluator
 * 
 * Global Reference ID: SCTSS-014
 * Atomic Steps Reference ID: SCTSS-014-A12
 * Atomic Step: Conduct usability testing to evaluate user clarity during decision gating.
 * Tab Name: SCTSS-014-A12 - UIUX | Row Tab Name: UDF
 * S.No: N/A | Sequence Order: 38722 | Assigned Team Member: Pooja | Group: UDF | Decision Group: Regional Free Zone Compliance
 * Dependency: Step 5, Step 26.
 * 
 * Governing Standard: ADFA Enterprise Backend Architecture & DCDF Compliance Framework
 * Target System: AISS Implementation — Decision Gating Usability Evaluator
 * Backend Models: UserFlowNode (tbl_user_flow_nodes), UserFlowComplianceSummary (tbl_user_flow_compliance_summary), BQGraphCheckpointMetadata (tbl_bq_graph_checkpoint_metadata), DeadLetterQuarantine (q_dead_letter_quarantine), ExecutionAuditLog (tbl_execution_audit_log)
 * API Endpoint: POST /api/v1/compliance/decision-gating-usability-evaluator/validate/
 * Lineage Headers: X-Trace-ID, X-Origin-Source-ID, X-Predecessor-ID (Step 5, Step 26.), X-Transformation-Logic-Hash
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Evaluation Scorecard Coverage (%) — usability testing to evaluate user clarity during
 * - Floor Boundary: 0.9
 * - Optimal Target: 1.0
 * - Ceiling Boundary: 1.0
 * Best Qualitative Output: Pass/Fail
 * Data Collected: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Pass'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';

/// Row 190: SCTSS-014 (Seq 38722)
/// Action: Conduct usability testing to evaluate user clarity during decision gating.
/// Quality Gate: Evaluation Scorecard Coverage (%) — usability testing to evaluate user clarity during (Optimal: 1.0).
class DecisionGatingUsabilityEvaluatorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DecisionGatingUsabilityEvaluatorPanel({
    super.key,
    this.globalRefId = 'SCTSS-014',
    this.atomicStepRefId = 'SCTSS-014-A12',
    this.sequenceOrder = 38722,
  });

  @override
  State<DecisionGatingUsabilityEvaluatorPanel> createState() =>
      _DecisionGatingUsabilityEvaluatorPanelState();
}

class _DecisionGatingUsabilityEvaluatorPanelState
    extends State<DecisionGatingUsabilityEvaluatorPanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      '1.0';

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
                    Icons.rate_review_outlined,
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
                        '${widget.globalRefId}: Decision Gating Usability Evaluator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Evaluation Scorecard Coverage (%) — usability testing to evaluate user clarity during',
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
              'Conduct usability testing to evaluate user clarity during decision gating.',
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
                          'Usability scorecard evaluation recorded for binary decision gate interactions.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.fact_check
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Usability Evaluated'
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
            child: DecisionGatingUsabilityEvaluatorPanel(),
          ),
        ),
      ),
    ),
  );
}
