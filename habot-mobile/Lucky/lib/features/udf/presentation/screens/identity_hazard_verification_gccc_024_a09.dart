// GCCC-024-A09 — Automated Identity Hazard Verification & Status Badging.
// Evaluates identity hazards against verification rules, displaying status via Material 3 badges,
// state-driven color schemes, wide mobile touch markers, and structured typographic parameters.

import 'package:flutter/material.dart';

/// Represents the verification outcome category for identity hazard rules.
enum IdentityHazardOutcome {
  safe,
  lowRisk,
  highHazard,
  pendingApproval,
}

/// Data model capturing atomic execution metrics and identity hazard state.
class IdentityHazardRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final IdentityHazardOutcome stepOutcome;
  final String userId;
  final String completionStatus; // 'Poor', 'Acceptable', or 'Good'
  final double latencyMs;
  final String hazardDetails;

  const IdentityHazardRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.latencyMs,
    required this.hazardDetails,
  });
}

/// Screen displaying automated identity hazard verification checks and status.
class IdentityHazardVerificationScreenGccc024A09 extends StatefulWidget {
  final String userId;
  final VoidCallback? onSignOffRequested;

  const IdentityHazardVerificationScreenGccc024A09({
    super.key,
    this.userId = 'USR-GCCC-9902',
    this.onSignOffRequested,
  });

  @override
  State<IdentityHazardVerificationScreenGccc024A09> createState() =>
      _IdentityHazardVerificationScreenGccc024A09State();
}

class _IdentityHazardVerificationScreenGccc024A09State
    extends State<IdentityHazardVerificationScreenGccc024A09> {
  late List<IdentityHazardRecord> _records;
  bool _isEvaluating = false;

  @override
  void initState()
  {
    super.initState();
    _records = [
      IdentityHazardRecord(
        stepExecutionId: 'EXEC-GCCC-024-001',
        executionStatus: 'Completed',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 4)),
        stepOutcome: IdentityHazardOutcome.safe,
        userId: widget.userId,
        completionStatus: 'Good',
        latencyMs: 142.5,
        hazardDetails: 'Sanctions & PEP registry cross-match passed without flags.',
      ),
      IdentityHazardRecord(
        stepExecutionId: 'EXEC-GCCC-024-002',
        executionStatus: 'Warning',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        stepOutcome: IdentityHazardOutcome.lowRisk,
        userId: widget.userId,
        completionStatus: 'Acceptable',
        latencyMs: 310.2,
        hazardDetails: 'Geographic discrepancy detected between residency and submission node.',
      ),
      IdentityHazardRecord(
        stepExecutionId: 'EXEC-GCCC-024-003',
        executionStatus: 'Pending',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        stepOutcome: IdentityHazardOutcome.pendingApproval,
        userId: widget.userId,
        completionStatus: 'Acceptable',
        latencyMs: 218.0,
        hazardDetails: 'Secondary corporate governance review assigned to Lead Counsel.',
      ),
    ];
  }

  Color _getOutcomeColor(BuildContext context, IdentityHazardOutcome outcome) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (outcome) {
      case IdentityHazardOutcome.safe:
        return Colors.green.shade700;
      case IdentityHazardOutcome.lowRisk:
        return Colors.amber.shade800;
      case IdentityHazardOutcome.highHazard:
        return colorScheme.error;
      case IdentityHazardOutcome.pendingApproval:
        return colorScheme.primary;
    }
  }

  String _getOutcomeLabel(IdentityHazardOutcome outcome) {
    switch (outcome) {
      case IdentityHazardOutcome.safe:
        return 'SAFE / VERIFIED';
      case IdentityHazardOutcome.lowRisk:
        return 'POTENTIAL HAZARD';
      case IdentityHazardOutcome.highHazard:
        return 'CRITICAL HAZARD';
      case IdentityHazardOutcome.pendingApproval:
        return 'PENDING REVIEW';
    }
  }

  IconData _getOutcomeIcon(IdentityHazardOutcome outcome) {
    switch (outcome) {
      case IdentityHazardOutcome.safe:
        return Icons.verified_user_rounded;
      case IdentityHazardOutcome.lowRisk:
        return Icons.warning_amber_rounded;
      case IdentityHazardOutcome.highHazard:
        return Icons.gpp_bad_rounded;
      case IdentityHazardOutcome.pendingApproval:
        return Icons.pending_actions_rounded;
    }
  }

  Future<void> _runAutomatedEvaluation() async {
    setState(() => _isEvaluating = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final newRecord = IdentityHazardRecord(
      stepExecutionId: 'EXEC-GCCC-024-00${_records.length + 1}',
      executionStatus: 'Completed',
      executionTimestamp: DateTime.now(),
      stepOutcome: IdentityHazardOutcome.safe,
      userId: widget.userId,
      completionStatus: 'Good',
      latencyMs: 124.8,
      hazardDetails: 'Automated identity hazard telemetry confirmed zero high-risk signals.',
    );
    if (mounted) {
      setState(() {
        _records.insert(0, newRecord);
        _isEvaluating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Identity hazard rule executed successfully.'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Hazard Rules'),
        actions: [
          IconButton(
            tooltip: 'Run Evaluation',
            icon: _isEvaluating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isEvaluating ? null : _runAutomatedEvaluation,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorScheme.surfaceVariant.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET USER ID',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.1,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.userId,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Badge(
                    backgroundColor: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                    label: Text('${_records.length} Rules Logged'),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _records[index];
                  final stateColor = _getOutcomeColor(context, item.stepOutcome);

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: stateColor.withOpacity(0.35), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _showExecutionDetailsModal(context, item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(_getOutcomeIcon(item.stepOutcome), color: stateColor, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  item.stepExecutionId,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Badge(
                                  backgroundColor: stateColor.withOpacity(0.15),
                                  textColor: stateColor,
                                  label: Text(
                                    _getOutcomeLabel(item.stepOutcome),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.hazardDetails,
                              style: textTheme.bodyMedium?.copyWith(height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _buildParamChip(
                                  label: 'Latency: ${item.latencyMs.toStringAsFixed(1)} ms',
                                  icon: Icons.timer_outlined,
                                  textTheme: textTheme,
                                ),
                                _buildParamChip(
                                  label: 'Status: ${item.completionStatus}',
                                  icon: Icons.speed_rounded,
                                  textTheme: textTheme,
                                ),
                                _buildParamChip(
                                  label: '${item.executionTimestamp.hour.toString().padLeft(2, '0')}:${item.executionTimestamp.minute.toString().padLeft(2, '0')}',
                                  icon: Icons.access_time_rounded,
                                  textTheme: textTheme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Wide touch marker button to facilitate mobile traversal
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 54, // Optimized wide-layout touch target (>= 48dp)
                child: FilledButton.icon(
                  onPressed: _isEvaluating ? null : _runAutomatedEvaluation,
                  icon: const Icon(Icons.security_update_good_rounded),
                  label: const Text(
                    'EXECUTE HAZARD VERIFICATION RULE',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamChip({
    required String label,
    required IconData icon,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showExecutionDetailsModal(BuildContext context, IdentityHazardRecord item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Telemetry Details',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Execution ID', item.stepExecutionId),
              _buildDetailRow('Execution Status', item.executionStatus),
              _buildDetailRow('User / Subject ID', item.userId),
              _buildDetailRow('Execution Timestamp', item.executionTimestamp.toIso8601String()),
              _buildDetailRow('Completion Latency', '${item.latencyMs} ms'),
              _buildDetailRow('PMBOK Quality Index', item.completionStatus),
              _buildDetailRow('Rule Output Text', item.hazardDetails),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('DISMISS'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
