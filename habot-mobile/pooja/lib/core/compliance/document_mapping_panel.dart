/*
 * STEP 42: VPVMP-006-14 — Document Backward Data Mapping from Success Anchors
 * 
 * Setup Step (Action): Document the precise data properties mapping the final step
 *   backward from success anchors.
 * Setup Step Description: Verify the horizontal step documentation entry strictly
 *   follows the non-narrative layout.
 * 
 * ---------------------------------------------------------------------------------------------------
 * DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 & DEA/OPS Doc Conversion):
 * 1. API Endpoint: POST /api/v1/documents/backward-mapping/verify
 * 2. HTTP Method: POST | Fetch Endpoint: GET /api/v1/documents/backward-mapping/{documentId}
 * 3. Auth Headers: Authorization: Bearer <userSessionId>, Content-Type: application/json
 * 4. Payload Mapping: {"documentTitle": String, "documentUrl": String, "userSessionId": String, "qaPassRate": double, "isReleaseFrozen": bool}
 * 5. Notifications / Messages:
 *    - Push Notification: PUSH_NOTIF_DOC_MAPPING_VERIFIED ("Backward mapping sequence verified for {documentTitle}.")
 *    - Email Notification: EMAIL_DOC_MAPPING_AUDIT (Sent to BI Systems Modeler and QA Lead)
 *    - SMS Alert: SMS_SELF_CHASING_RELEASE_FREEZE (Sent to Release Ops if unmapped sequence gaps freeze release)
 * 6. Approval Escalation Chain:
 *    - Primary Approver: BusinessIntelligenceSystemsModeler (Role)
 *    - Escalation Handler: If isReleaseFrozen = true, triggers RELEASE_FREEZE_ESCALATION to OPS_SECURITY_LEAD
 * 7. Error Handling & Failure States:
 *    - Poka-Yoke Exception: Portal specification forms throw TypeLayoutException if fields miss parent parameters.
 * 8. Upstream & Downstream Lineage:
 *    - Upstream Source: Step 41 (PELCE-007-20) - Platform Fee Deduction -> Route: /fees/deduction
 *    - Downstream Outcome: Step 43 - Master Release Certification -> Route: /releases/certification
 * 9. Governance Metadata:
 *    - Status: PASS | Owner: DEA/OPS Compliance Team | Submitted On: 2026-08-15 | Target Date: 2026-08-20
 * 10. Validation Rules:
 *    - QA Test Case Pass Rate: Floor ≥95%, Optimal 100%, Ceiling 100%. Standard: ISO/IEC/IEEE 29119.
 * ---------------------------------------------------------------------------------------------------
 *
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Compress long tracking parameter strings into clean, truncated text list elements for small screens.
 *   - Style connection text labels utilizing minimal typography scaling properties to protect mobile display bounds.
 *   - Support responsive swiping layouts to progress through long sequence mapping actions on mobile.
 *   - Enforce the strict 48dp bounding target dimension standard across tracking triggers explicitly.
 *   - Poka-Yoke: Portal specification forms throw a type layout exception if fields miss explicit parent parameters.
 *   - Self-Chasing: Gaps across completed mapping fields freeze releases, automatically pushing files back into manual revision cycles.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step42DocumentMappingPanel` widget and `Step42DocMappingRecord` data model with DEA/OPS fields.
 *   - Implemented `PokaYokeValidationEngine` and `SelfChasingReleaseGuard` governance engines.
 *   - Built `QaTestPassRateValidator` auditing QA pass rate against ISO/IEC/IEEE 29119 testing standards.
 *   - Implemented horizontal PageView swiper with 48dp touch targets and truncated tracking text lists.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step VPVMP-006-14: Document Mapping Audit Record Data Model.
class Step42DocMappingRecord {
  final String documentTitle;
  final String documentUrl;
  final String lastUpdatedDate;
  final String accessibilityStatus;
  final String documentAccessLog;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double qaPassRate;
  final String hasParentParameters;
  final bool isReleaseFrozen;

  // DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceStatus;
  final String governanceOwner;
  final String pushNotificationEvent;
  final String emailNotificationEvent;
  final String smsRbacAlertEvent;

  const Step42DocMappingRecord({
    required this.documentTitle,
    required this.documentUrl,
    required this.lastUpdatedDate,
    required this.accessibilityStatus,
    required this.documentAccessLog,
    this.completionStatus = 'Pass (100%)',
    required this.actionTimestamp,
    required this.userSessionId,
    this.qaPassRate = 1.0,
    this.hasParentParameters = 'Valid Parent Params Bound',
    this.isReleaseFrozen = false,
    this.apiEndpoint = '/api/v1/documents/backward-mapping/verify',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceStatus = 'PASS',
    this.governanceOwner = 'DEA/OPS Compliance Team',
    this.pushNotificationEvent = 'PUSH_NOTIF_DOC_MAPPING_VERIFIED',
    this.emailNotificationEvent = 'EMAIL_DOC_MAPPING_AUDIT',
    this.smsRbacAlertEvent = 'SMS_SELF_CHASING_RELEASE_FREEZE',
  });
}

class DocumentMappingItem {
  final String stepId;
  final String stepTitle;
  final String parentParameterBinding;
  final String trackingParameter;
  final bool isMapped;

  const DocumentMappingItem({
    required this.stepId,
    required this.stepTitle,
    required this.parentParameterBinding,
    required this.trackingParameter,
    required this.isMapped,
  });
}

/// Poka-Yoke: Portal specification forms throw a type layout exception if fields miss explicit parent parameters.
abstract class PokaYokeValidationEngine {
  static bool validateParentParameters(List<DocumentMappingItem> items) {
    for (final item in items) {
      if (item.parentParameterBinding.trim().isEmpty || item.parentParameterBinding == 'Unbound') {
        return false;
      }
    }
    return true;
  }
}

/// Self-Chasing: Gaps across completed mapping fields freeze releases automatically.
abstract class SelfChasingReleaseGuard {
  static bool evaluateReleaseFreeze(List<DocumentMappingItem> items) {
    return items.any((item) => !item.isMapped);
  }
}

/// Metric Evaluator: QA Test Case Pass Rate (Floor ≥95%, Optimal 1.0).
abstract class QaTestPassRateValidator {
  static const double floor = 0.95;
  static const double optimal = 1.0;

  static String evaluateLabel(double passRate) {
    if (passRate >= optimal) return 'Pass/Fail → Best = Pass (100%)';
    if (passRate >= floor) return 'Pass (≥95% Floor Met)';
    return 'Fail (<95% Floor Violate)';
  }
}

/// Step VPVMP-006-14: Document Mapping Panel Component.
class Step42DocumentMappingPanel extends StatefulWidget {
  final Step42DocMappingRecord record;

  const Step42DocumentMappingPanel({
    super.key,
    required this.record,
  });

  @override
  State<Step42DocumentMappingPanel> createState() => _Step42DocumentMappingPanelState();
}

class _Step42DocumentMappingPanelState extends State<Step42DocumentMappingPanel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _activeStepIndex = 0;

  final List<DocumentMappingItem> _mappingSteps = [
    const DocumentMappingItem(
      stepId: 'STEP-42-A',
      stepTitle: 'Final Success Anchor Definition',
      parentParameterBinding: 'Parent: RootDocSchema_v2.4',
      trackingParameter: 'param_anchor_ref_001_success_state_log_extended_trace',
      isMapped: true,
    ),
    const DocumentMappingItem(
      stepId: 'STEP-42-B',
      stepTitle: 'Backward Lineage Mapping Step 41',
      parentParameterBinding: 'Parent: PlatformFeeFilter_PELCE-007-20',
      trackingParameter: 'param_flat_rate_fee_deduction_audit_log_trace',
      isMapped: true,
    ),
    const DocumentMappingItem(
      stepId: 'STEP-42-C',
      stepTitle: 'Backward Lineage Mapping Step 40',
      parentParameterBinding: 'Parent: MemoryLimitGuard_HSCPE-017',
      trackingParameter: 'param_oom_kill_protection_matrix_telemetry_trace',
      isMapped: true,
    ),
    const DocumentMappingItem(
      stepId: 'STEP-42-D',
      stepTitle: 'Backward Lineage Mapping Step 39',
      parentParameterBinding: 'Parent: StatefulSetPersist_HSCPE-015',
      trackingParameter: 'param_statefulset_manifest_checkout_persist_trace',
      isMapped: true,
    ),
  ];

  void _toggleMappingStatus(int index) {
    setState(() {
      final oldItem = _mappingSteps[index];
      _mappingSteps[index] = DocumentMappingItem(
        stepId: oldItem.stepId,
        stepTitle: oldItem.stepTitle,
        parentParameterBinding: oldItem.parentParameterBinding,
        trackingParameter: oldItem.trackingParameter,
        isMapped: !oldItem.isMapped,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasValidParents = PokaYokeValidationEngine.validateParentParameters(_mappingSteps);
    final isReleaseFrozen = SelfChasingReleaseGuard.evaluateReleaseFreeze(_mappingSteps);
    final mappedCount = _mappingSteps.where((s) => s.isMapped).length;
    final currentPassRate = _mappingSteps.isEmpty ? 1.0 : (mappedCount / _mappingSteps.length);
    final completionLabel = QaTestPassRateValidator.evaluateLabel(currentPassRate);

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
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
                          Icon(Icons.account_tree_outlined, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'Step 42: Document Backward Data Mapping from Success Anchors',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VPVMP-006-14',
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
                        'Document the precise data properties mapping the final step backward from success anchors, verifying entries follow non-narrative horizontal layouts.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Self-Chasing & Poka-Yoke Governance Status Card ---
              Card(
                elevation: 1,
                color: isReleaseFrozen
                    ? colorScheme.errorContainer
                    : colorScheme.primaryContainer,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isReleaseFrozen ? Icons.lock_clock : Icons.verified_user_outlined,
                            color: isReleaseFrozen
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                          ),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              isReleaseFrozen
                                  ? 'Self-Chasing Guard: RELEASE FROZEN (Gaps Detected)'
                                  : 'Self-Chasing Guard: Release Ready (100% Sequence Mapped)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isReleaseFrozen
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapXs,
                      Text(
                        isReleaseFrozen
                            ? 'Unmapped sequence fields freeze releases, automatically pushing files back into manual revision cycles.'
                            : 'All horizontal step documentation entries strictly follow non-narrative backward mapping.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isReleaseFrozen
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (!hasValidParents) ...[
                        AppSpacingTokens.vGapSm,
                        Container(
                          padding: AppSpacingTokens.paddingSm,
                          decoration: BoxDecoration(
                            color: AppColorPalette.lightError,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bug_report, color: Colors.white, size: 18),
                              AppSpacingTokens.hGapSm,
                              Text(
                                'Poka-Yoke Alert: Type Layout Exception (Unbound Parent Parameter)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Responsive Swipeable Mapping Sequence (PageView) ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Backward Lineage Swiping Sequence',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_activeStepIndex + 1} of ${_mappingSteps.length}',
                            style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      SizedBox(
                        height: 190,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) => setState(() => _activeStepIndex = idx),
                          itemCount: _mappingSteps.length,
                          itemBuilder: (context, index) {
                            final item = _mappingSteps[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              color: colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: item.isMapped
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: AppSpacingTokens.paddingMd,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.stepId,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        // 48dp Bounding Touch Target Switch Trigger
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 48,
                                            minHeight: 48,
                                          ),
                                          child: Switch(
                                            value: item.isMapped,
                                            onChanged: (_) => _toggleMappingStatus(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.stepTitle,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    AppSpacingTokens.vGapXs,
                                    Text(
                                      item.parentParameterBinding,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    AppSpacingTokens.vGapXs,
                                    Text(
                                      item.trackingParameter,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'monospace',
                                        color: colorScheme.secondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Metric: QA Test Case Pass Rate Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.rule_folder_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'QA Test Case Pass Rate: ${(currentPassRate * 100).toStringAsFixed(0)}% — $completionLabel',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      LinearProgressIndicator(
                        value: currentPassRate,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: currentPassRate >= 0.95
                            ? AppColorPalette.success
                            : colorScheme.error,
                      ),
                      AppSpacingTokens.vGapXs,
                      Text(
                        'Standard: ISO/IEC/IEEE 29119 Software Testing Standard (Floor: ≥95%, Optimal: 100%)',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                        'Data Collected by System (DEA/OPS Conversion)',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Document Title')),
                            DataColumn(label: Text('Document URL')),
                            DataColumn(label: Text('Last Updated')),
                            DataColumn(label: Text('Accessibility Status')),
                            DataColumn(label: Text('Document Access Log')),
                            DataColumn(label: Text('Completion Status')),
                            DataColumn(label: Text('Session ID')),
                            DataColumn(label: Text('Governance Owner')),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(widget.record.documentTitle)),
                              DataCell(Text(widget.record.documentUrl)),
                              DataCell(Text(widget.record.lastUpdatedDate)),
                              DataCell(Text(widget.record.accessibilityStatus)),
                              DataCell(Text(widget.record.documentAccessLog)),
                              DataCell(Text(completionLabel)),
                              DataCell(Text(widget.record.userSessionId)),
                              DataCell(Text(widget.record.governanceOwner)),
                            ]),
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
