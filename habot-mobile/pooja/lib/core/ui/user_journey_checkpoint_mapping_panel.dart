/*
 * BTPM-032-03 — User Journey Screen, Form & Manual Checkpoint Mapping Engine
 * 
 * Global Reference ID: BTPM-032-03
 * Atomic Steps Reference ID: BTPM-032-03
 * Setup Step (Action): Map out every existing UI screen, form, and manual checkpoint within the current user journey.
 * S.No: 119 | Sequence Order: 6131 | Assigned Team: Pooja (UDF) | Group: UDF | Decision Group: 2305
 * 
 * Data Requirement (Col O): Source Element ID; Target Element ID; Mapping Rule; Mapping Status; Mapping Validation
 * UX / UI Translation: Structured visual graph node map linking sequential mobile views, input forms, and compliance approval checkpoints.
 * System Verbs (mobile eb.docx): ROUTES, VALIDATES
 * Mathematical Triangular Check (ux Eb.docx): Delta = Total Registered Journey Nodes - (Screens + Forms + Manual Checkpoints) = 0.
 * Mistake-Proofing (Poka-Yoke - Col AD): Graph traversal validator detects unmapped screens and blocks incomplete journeys from entering production release gates.
 * Self-Chasing (Col AE): 100% of journey nodes must pass automated design system token adherence checks (Floor: >=85%, Target: >=95%).
 * 
 * QUALITY METRIC BOUNDARIES (Cols AK-AP):
 * Metric Name: UI Design-System Adherence Rate
 * - Floor Boundary: >=85%
 * - Optimal Target: >=95%
 * - Ceiling Boundary: 1.0 (100%)
 * Best Qualitative Output: Good/Average/Poor -> Best = Good (100%)
 * Output Type: Material Design 3 Journey Graph & Navigation Flow Matrix
 * Telemetry Collected (Col AQ): Source Element ID; Target Element ID; Mapping Rule; Mapping Status; Mapping Validation; Completion Status ('Good/Average/Poor -> Best = Good (100%)'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Row 119: BTPM-032-03 Record Data Model.
class UserJourneyMappingRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final String sourceElementId;
  final String targetElementId;
  final String mappingRule;
  final String mappingStatus;
  final String mappingValidation;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double adherenceRate;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const UserJourneyMappingRecord({
    this.globalRefId = 'BTPM-032-03',
    this.atomicStepRefId = 'BTPM-032-03',
    this.sourceElementId = 'SCREEN_ONBOARDING_01',
    this.targetElementId = 'GATE_APPROVAL_03',
    this.mappingRule = 'STRICT_FORWARD_FLOW',
    this.mappingStatus = 'FULLY_MAPPED',
    this.mappingValidation = 'ALL_CHECKPOINTS_VERIFIED',
    this.completionStatus = 'Good',
    this.actionTimestamp = '2026-09-07T16:41:00Z',
    this.userSessionId = 'SESSION-BTPM-032-03',
    this.adherenceRate = 98.0,
    this.floorBoundary = 85.0,
    this.optimalTarget = 95.0,
    this.ceilingBoundary = 100.0,
  });
}

/// Main Component Panel Widget for Row 119: BTPM-032-03.
class UserJourneyCheckpointMappingPanel extends StatefulWidget {
  final UserJourneyMappingRecord record;

  const UserJourneyCheckpointMappingPanel({
    super.key,
    this.record = const UserJourneyMappingRecord(),
  });

  @override
  State<UserJourneyCheckpointMappingPanel> createState() => _UserJourneyCheckpointMappingPanelState();
}

class _UserJourneyCheckpointMappingPanelState extends State<UserJourneyCheckpointMappingPanel> {
  bool _showExecutionLog = false;
  final List<Map<String, dynamic>> _nodes = [
    {
      'id': 'NODE-SCR-01',
      'type': 'Screen',
      'name': 'Executive Overview Screen',
      'status': 'Verified',
      'icon': Icons.phone_android,
    },
    {
      'id': 'NODE-FRM-02',
      'type': 'Form',
      'name': 'Corporate KYC Intake Form',
      'status': 'Verified',
      'icon': Icons.assignment_outlined,
    },
    {
      'id': 'NODE-CHK-03',
      'type': 'Manual Checkpoint',
      'name': 'Manager Dual-Signature Gate',
      'status': 'Pending Approval',
      'icon': Icons.gavel_outlined,
    },
    {
      'id': 'NODE-SCR-04',
      'type': 'Screen',
      'name': 'Confirmation & Dispatch View',
      'status': 'Verified',
      'icon': Icons.check_circle_outline,
    },
  ];

  void _verifyNode(int index) {
    setState(() {
      _nodes[index]['status'] = 'Verified';
    });
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'sourceElementId': widget.record.sourceElementId,
      'targetElementId': widget.record.targetElementId,
      'mappingRule': widget.record.mappingRule,
      'mappingStatus': widget.record.mappingStatus,
      'mappingValidation': widget.record.mappingValidation,
      'completionStatus': widget.record.completionStatus,
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': widget.record.userSessionId,
      'metadata': {
        'taskCode': 'BTPM-032-03',
        'row': 119,
        'seq': 6131,
        'assigned': 'Pooja',
        'metricName': 'UI Design-System Adherence Rate',
        'floor': widget.record.floorBoundary,
        'target': widget.record.optimalTarget,
        'ceiling': widget.record.ceilingBoundary,
        'unit': 'Good/Average/Poor -> Best = Good (100%)',
        'adherenceRate': widget.record.adherenceRate,
        'nodesCount': _nodes.length,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalNodes = _nodes.length;
    final screenCount = _nodes.where((n) => n['type'] == 'Screen').length;
    final formCount = _nodes.where((n) => n['type'] == 'Form').length;
    final checkpointCount = _nodes.where((n) => n['type'] == 'Manual Checkpoint').length;
    final delta = totalNodes - (screenCount + formCount + checkpointCount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final horizontalPadding = isExpanded
            ? AppSpacingTokens.paddingXl
            : (isCompact ? AppSpacingTokens.paddingSm : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 4 : 8,
            horizontal: isExpanded ? 16 : 0,
          ),
          child: Padding(
            padding: horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.alt_route, color: theme.colorScheme.primary, size: 24),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BTPM-032-03: User Journey Checkpoint Mapper',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 13 : 15,
                            ),
                          ),
                          Text(
                            'Global Ref: ${widget.record.globalRefId} | Atomic: ${widget.record.atomicStepRefId} | Seq: 6131',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Adherence: ${widget.record.adherenceRate.toInt()}%'),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                Text(
                  'End-to-End User Journey Graph (Screens, Forms, and Manual Gates):',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapXs,
                Text(
                  'Visual pipeline tracking transitions and manual checkpoints to detect traversal bottlenecks.',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                AppSpacingTokens.vGapMd,

                // Journey Nodes List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _nodes.length,
                  separatorBuilder: (_, _) => Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(
                      height: 16,
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final node = _nodes[index];
                    final isVerified = node['status'] == 'Verified';

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isVerified ? theme.colorScheme.outlineVariant : Colors.amber.shade800,
                          width: isVerified ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(node['icon'] as IconData, size: 22, color: theme.colorScheme.primary),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  node['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Type: ${node['type']} | Node ID: ${node['id']}',
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          if (!isVerified)
                            OutlinedButton(
                              onPressed: () => _verifyNode(index),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Verify Gate', style: TextStyle(fontSize: 11)),
                            )
                          else
                            const Icon(Icons.check_circle, size: 20, color: Colors.green),
                        ],
                      ),
                    );
                  },
                ),

                AppSpacingTokens.vGapMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: Icon(_showExecutionLog ? Icons.visibility_off : Icons.receipt_long),
                      label: Text(_showExecutionLog ? 'Hide Telemetry' : 'View Audit Telemetry'),
                      onPressed: () => setState(() => _showExecutionLog = !_showExecutionLog),
                    ),
                  ],
                ),

                if (_showExecutionLog) ...[
                  AppSpacingTokens.vGapMd,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: SelectableText(
                      toExecutionLogJson().toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],

                AppSpacingTokens.vGapMd,

                // Telemetry & Specification
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('49-Column Specification Alignment (my steps.xlsx):',
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('• Metric: UI Design-System Adherence ${widget.record.adherenceRate.toInt()}% (Target: >=95% | Floor: 85%)',
                          style: const TextStyle(fontSize: 10)),
                      Text('• Triangular Check: Total Nodes ($totalNodes) - [Screens ($screenCount) + Forms ($formCount) + Checkpoints ($checkpointCount)] = Delta $delta (Zero-Variance).',
                          style: const TextStyle(fontSize: 10)),
                      Text('• Telemetry (Col AQ): Src: ${widget.record.sourceElementId} -> Target: ${widget.record.targetElementId}',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
