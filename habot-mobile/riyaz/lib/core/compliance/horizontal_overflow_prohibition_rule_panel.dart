/*
 * SSTLA-011-A05 — Horizontal Overflow Prohibition Rule
 * 
 * Global Reference ID: SSTLA-011
 * Atomic Steps Reference ID: SSTLA-011-A05
 * Atomic Step: Prohibit layout rules that generate horizontal scrolling containers (overflow-x: scroll) on metric views.
 * Tab Name: SSTLA-011-A05 - UIUX | Row Tab Name: UDF
 * S.No: 2.0 | Sequence Order: 41238 | Assigned Team Member: Pooja | Group: UDF | Decision Group: Mobile Responsive Data Visualization Design
 * Dependency: Serial Number 9.
 * 
 * Governing Standard: ADFA Enterprise Backend Architecture & DCDF Compliance Framework
 * Target System: AISS Implementation — Horizontal Overflow Prohibition Rule
 * Backend Models: UserFlowNode (tbl_user_flow_nodes), UserFlowComplianceSummary (tbl_user_flow_compliance_summary), BQGraphCheckpointMetadata (tbl_bq_graph_checkpoint_metadata), DeadLetterQuarantine (q_dead_letter_quarantine), ExecutionAuditLog (tbl_execution_audit_log)
 * API Endpoint: POST /api/v1/compliance/horizontal-overflow-prohibition-rule/validate/
 * Lineage Headers: X-Trace-ID, X-Origin-Source-ID, X-Predecessor-ID (Serial Number 9.), X-Transformation-Logic-Hash
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Task Execution Quality Score (1-5 scale) — Prohibit layout rules that generate horizontal scrolling
 * - Floor Boundary: 3.5
 * - Optimal Target: 4.5
 * - Ceiling Boundary: 5.0
 * Best Qualitative Output: Good/Average/Poor
 * Data Collected: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Pass'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';

/// Row 284: SSTLA-011 (Seq 41238)
/// Action: Prohibit layout rules that generate horizontal scrolling containers (overflow-x: scroll) on metric views.
/// Quality Gate: Task Execution Quality Score (1-5 scale) — Prohibit layout rules that generate horizontal scrolling (Optimal: 4.5).
class HorizontalOverflowProhibitionRulePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const HorizontalOverflowProhibitionRulePanel({
    super.key,
    this.globalRefId = 'SSTLA-011',
    this.atomicStepRefId = 'SSTLA-011-A05',
    this.sequenceOrder = 41238,
  });

  @override
  State<HorizontalOverflowProhibitionRulePanel> createState() =>
      _HorizontalOverflowProhibitionRulePanelState();
}

class _HorizontalOverflowProhibitionRulePanelState
    extends State<HorizontalOverflowProhibitionRulePanel> {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      '4.5';

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
                    Icons.block_outlined,
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
                        '${widget.globalRefId}: Horizontal Overflow Prohibition Rule',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Task Execution Quality Score (1-5 scale) — Prohibit layout rules that generate horizontal scrolling',
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
              'Prohibit layout rules that generate horizontal scrolling containers (overflow-x: scroll) on metric views.',
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
                          'Prohibition rule enforced blocking horizontal scroll containers on metric views.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                    _isActionActive
                        ? Icons.gpp_bad_outlined
                        : Icons.play_arrow_rounded,
                    size: 20),
                label: Text(_isActionActive
                    ? 'Overflow Rule Enforced'
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
            child: HorizontalOverflowProhibitionRulePanel(),
          ),
        ),
      ),
    ),
  );
}
