/*
 * STEP 47: RRCVG-006 — Design Reconciliation Test: Final Readiness Gate
 * 
 * Setup Step (Action): Design Reconciliation Test: Final Readiness Gate (RRCVG-006)
 * Setup Step Description: Apply the disabled prop to the MUI Button if the difference is non-zero.
 * 
 * ---------------------------------------------------------------------------------------------------
 * DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 & DEA/OPS Doc Conversion):
 * 1. API Endpoint: POST /api/v1/gates/reconciliation-readiness/evaluate
 * 2. HTTP Method: POST | Fetch Endpoint: GET /api/v1/gates/reconciliation-readiness/{gateId}
 * 3. Auth Headers: Authorization: Bearer <userSessionId>, Content-Type: application/json
 * 4. Payload Mapping: {"stepExecutionId": String, "executionStatus": String, "executionTimestamp": String, "stepOutcome": String, "userId": String}
 * 5. Notifications / Messages:
 *    - Push Notification: PUSH_NOTIF_RECONCILIATION_GATE_ACTIVE ("Final readiness gate active; button disabled on non-zero variance.")
 *    - Email Notification: EMAIL_RECONCILIATION_AUDIT (Sent to Project Management and Technical Leadership)
 *    - SMS Alert: SMS_POKA_YOKE_VARIANCE_BLOCKED (Sent to Release Ops when submission attempted on non-zero variance)
 * 6. Approval Escalation Chain:
 *    - Primary Approver: TechnicalLeadership (Role)
 *    - Escalation Handler: If variance remains non-zero >24 hours, escalates to PROJECT_MANAGEMENT_DIRECTOR
 * 7. Error Handling & Failure States:
 *    - Poka-Yoke Guard: Automatically applies disabled state to CTA button if reconciliation variance != 0.0.
 * 8. Upstream & Downstream Lineage:
 *    - Upstream Source: Step 46 (MTVPE-009-05) - Mobile Video Player -> Route: /media/mtoi-video
 *    - Downstream Outcome: Step 48 - Production Deployment Sign-off -> Route: /deployment/sign-off
 * 9. Governance Metadata:
 *    - Status: PASS | Owner: Technical Leadership & Project Management Team | Submitted On: 2026-08-15 | Target Date: 2026-08-20
 * 10. Validation Rules:
 *    - UI/UX Design System Conformity (Material 3): Floor <70%, Optimal 90–100%, Ceiling 100%. Standard: M3 Guidelines / Nielsen Norman Group.
 * ---------------------------------------------------------------------------------------------------
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Clear visual state changes between Disabled and Enabled button states.
 *   - Material Buttons utilizing M3 Design Tokens.
 *   - Informative tooltips explaining exactly why the button is disabled when difference is non-zero.
 *   - Poka-Yoke: Button automatically disables if reconciliation difference != 0.0, blocking invalid submissions.
 *   - Self-Chasing: Testing utilities verify gate behavior; attempting submission with non-zero variance triggers pipeline alert.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step47ReconciliationReadinessPanel` widget and `ReconciliationRecord` data model.
 *   - Implemented `PokaYokeReconciliationGuard` and `DesignSystemConformityValidator` validation engines.
 *   - Built interactive readiness gate panel with variance sliders, dynamic button state, informative tooltips, and M3 data table.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

/// Step RRCVG-006: Reconciliation Audit Record Data Model.
class ReconciliationRecord {
  final String stepExecutionId;
  final String executionStatus;
  final String executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double m3ConformityPercentage;
  final double reconciliationDifference;

  // DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceOwner;

  const ReconciliationRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    this.completionStatus = 'Good',
    required this.actionTimestamp,
    required this.userSessionId,
    this.m3ConformityPercentage = 100.0,
    this.reconciliationDifference = 0.0,
    this.apiEndpoint = '/api/v1/gates/reconciliation-readiness/evaluate',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceOwner = 'Technical Leadership & Project Management Team',
  });
}

enum Step47ConformityStatus {
  good('Good (90–100% Conformity)'),
  average('Average (70–89% Conformity)'),
  poor('Poor (<70% Inconsistent)');

  final String label;
  const Step47ConformityStatus(this.label);
}

/// Poka-Yoke Guard: Evaluates reconciliation difference and applies disabled state if difference != 0.0.
abstract class PokaYokeReconciliationGuard {
  static bool isButtonDisabled(double difference) {
    return difference.abs() > 0.001;
  }

  static String getDisabledTooltipReason(double difference) {
    if (difference.abs() <= 0.001) {
      return 'Reconciliation variance is zero. Gate ready for final sign-off.';
    }
    return 'Action Disabled: Non-zero reconciliation variance (\$${difference.toStringAsFixed(2)}) detected.';
  }
}

/// Design System Conformity Validator (Floor <70%, Optimal 90-100%, Ceiling 100%).
abstract class DesignSystemConformityValidator {
  static const double floor = 70.0;
  static const double optimal = 90.0;

  static Step47ConformityStatus evaluate(double conformityPct) {
    if (conformityPct >= optimal) return Step47ConformityStatus.good;
    if (conformityPct >= floor) return Step47ConformityStatus.average;
    return Step47ConformityStatus.poor;
  }
}

/// Step RRCVG-006: Reconciliation Readiness Gate Panel Component.
class Step47ReconciliationReadinessPanel extends StatefulWidget {
  final ReconciliationRecord record;

  const Step47ReconciliationReadinessPanel({super.key, required this.record});

  @override
  State<Step47ReconciliationReadinessPanel> createState() =>
      _Step47ReconciliationReadinessPanelState();
}

class _Step47ReconciliationReadinessPanelState
    extends State<Step47ReconciliationReadinessPanel> {
  double _reconciliationDifference = 0.0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _reconciliationDifference = widget.record.reconciliationDifference;
  }

  void _handleFinalSignOff() {
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDisabled = PokaYokeReconciliationGuard.isButtonDisabled(
      _reconciliationDifference,
    );
    final tooltipReason = PokaYokeReconciliationGuard.getDisabledTooltipReason(
      _reconciliationDifference,
    );

    final conformityStatus = DesignSystemConformityValidator.evaluate(
      widget.record.m3ConformityPercentage,
    );
    final isPass = conformityStatus == Step47ConformityStatus.good;

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingLg,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Card ---
              Card(
                elevation: 2,
                color: colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gavel_outlined,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'Step 47: Design Reconciliation Test: Final Readiness Gate (RRCVG-006)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'RRCVG-006',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Apply the disabled prop to the Material Button if the reconciliation difference is non-zero.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Interactive Readiness Gate Workspace ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reconciliation Readiness Gate (Poka-Yoke Non-Zero Guard)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        children: [
                          const Text(
                            'Adjust Variance: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Slider(
                              value: _reconciliationDifference,
                              min: 0.0,
                              max: 50.0,
                              divisions: 50,
                              label:
                                  '\$${_reconciliationDifference.toStringAsFixed(2)}',
                              onChanged: (val) => setState(() {
                                _reconciliationDifference = val;
                                _isSubmitted = false;
                              }),
                            ),
                          ),
                          Text(
                            '\$${_reconciliationDifference.toStringAsFixed(2)}',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,

                      // M3 Button State Container with Tooltip
                      Tooltip(
                        message: tooltipReason,
                        child: Container(
                          width: double.infinity,
                          padding: AppSpacingTokens.paddingLg,
                          decoration: BoxDecoration(
                            color: isDisabled
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDisabled
                                  ? colorScheme.outlineVariant
                                  : colorScheme.primary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isDisabled
                                        ? Icons.block
                                        : Icons.check_circle_outline,
                                    color: isDisabled
                                        ? colorScheme.error
                                        : colorScheme.primary,
                                  ),
                                  AppSpacingTokens.hGapSm,
                                  Expanded(
                                    child: Text(
                                      isDisabled
                                          ? 'Gate Status: BLOCKED (Non-zero variance detected)'
                                          : 'Gate Status: READY (Zero variance confirmed)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDisabled
                                            ? colorScheme.error
                                            : colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacingTokens.vGapSm,
                              Text(
                                tooltipReason,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              AppSpacingTokens.vGapMd,

                              // Material Button with `disabled` prop equivalent
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDisabled
                                      ? colorScheme.outlineVariant
                                      : colorScheme.primary,
                                  foregroundColor: isDisabled
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onPrimary,
                                  minimumSize: const Size(
                                    160,
                                    48,
                                  ), // 48dp height
                                ),
                                onPressed: isDisabled
                                    ? null
                                    : _handleFinalSignOff,
                                icon: const Icon(Icons.verified),
                                label: Text(
                                  _isSubmitted
                                      ? 'GATE SIGN-OFF COMPLETE'
                                      : (isDisabled
                                            ? 'SIGN-OFF DISABLED'
                                            : 'EXECUTE FINAL SIGN-OFF'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Metric: UI/UX Design System Conformity Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            color: colorScheme.primary,
                          ),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'UI/UX Design System Conformity (Material 3): ${widget.record.m3ConformityPercentage.toStringAsFixed(0)}% — ${conformityStatus.label}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      LinearProgressIndicator(
                        value: widget.record.m3ConformityPercentage / 100.0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: isPass ? colorScheme.primary : colorScheme.error,
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Floor: <70% | Optimal: 90–100% | Ceiling: 100% (Standard: Google Material Design 3 Guidelines / Nielsen Norman Group)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- System Audit Fields Table ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Collected by System',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Step Execution ID')),
                            DataColumn(label: Text('Execution Status')),
                            DataColumn(label: Text('Execution Timestamp')),
                            DataColumn(label: Text('Step Outcome')),
                            DataColumn(label: Text('User ID')),
                            DataColumn(label: Text('Completion Status')),
                            DataColumn(label: Text('Session ID')),
                            DataColumn(label: Text('Governance Owner')),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(Text(widget.record.stepExecutionId)),
                                DataCell(Text(widget.record.executionStatus)),
                                DataCell(
                                  Text(widget.record.executionTimestamp),
                                ),
                                DataCell(Text(widget.record.stepOutcome)),
                                DataCell(Text(widget.record.userId)),
                                DataCell(Text(conformityStatus.label)),
                                DataCell(Text(widget.record.userSessionId)),
                                DataCell(Text(widget.record.governanceOwner)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
