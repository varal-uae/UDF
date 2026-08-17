/*
 * STEP 2: EDEBS-032 — Anchor Mobile End Document (ED) UI Layout
 * 
 * Setup Step (Action): Open the master interface schema and data contract directory within the repository.
 * Setup Step Description: Definitive CDE restrictions | Nested structure bounds | Null condition rules | Precise type-casting schemas.
 * 
 * ---------------------------------------------------------------------------------------------------
 * DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11):
 * 1. API Endpoint: POST /api/v1/documents/{documentId}/approve-sign
 * 2. HTTP Method: POST | Fetch Endpoint: GET /api/v1/documents/{documentId}
 * 3. Auth Headers: Authorization: Bearer <userSessionId>, Content-Type: application/json
 * 4. Payload Mapping: {"documentId": String, "userSessionId": String, "userRole": String, "signatureHash": String}
 * 5. Notifications / Messages:
 *    - Push Notification: PUSH_NOTIF_DOC_APPROVED ("Document {documentId} signed & approved.")
 *    - Email Notification: EMAIL_SIGN_OFF_CONFIRMATION (Sent to document owner and approver)
 *    - SMS Alert: SMS_RBAC_REJECTION_ALERT (Sent to OPS security if unauthorized sign-off attempted)
 * 6. Approval Escalation Chain:
 *    - Primary Approver: ComplianceOfficer (Role)
 *    - Escalation Handler: If isRbacAuthorized = false, triggers ESCALATE_TO_ADMIN workflow (OPS_SECURITY_LEAD)
 * 7. Error Handling & Failure States:
 *    - Dynamic Network/API Error Banner (HTTP 500 / Network Timeout) with retry backoff loop.
 * 8. Upstream & Downstream Lineage:
 *    - Upstream Source: Step 01 (RCGLA-014) - Dense Data Table -> Route: /documents/review
 *    - Downstream Outcome: Step 03 (SCTSS-001) - Toast Bar & Success Dashboard -> Route: /documents/completed
 * 9. Governance Metadata:
 *    - Status: PASS | Owner: DEA/OPS Compliance Team | Submitted On: 2026-08-14 | Target Date: 2026-08-20
 * 10. Validation Rules:
 *    - Title Length: Min 5 chars, Max 120 chars. Auto-truncated with Tooltip if >80 chars.
 * ---------------------------------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';
import 'status_pill_badge.dart';

/// Structured completion status enum for End Document sign-off workflows.
enum DocumentApprovalStatus {
  pending('Pending Sign-off', StatusBadgeType.pending),
  approved('Approved & Signed', StatusBadgeType.approved),
  rejected('Sign-off Rejected', StatusBadgeType.rejected),
  inReview('In Compliance Review', StatusBadgeType.active);

  final String label;
  final StatusBadgeType badgeType;
  const DocumentApprovalStatus(this.label, this.badgeType);
}

/// Step EDEBS-032: End Document Data Contract & Telemetry Definition.
class EndDocumentDefinition {
  final String documentId;
  final String title;
  final String author;
  final DateTime completionDate;
  final DocumentApprovalStatus approvalStatus;
  final String userRole;
  final bool isRbacAuthorized;
  final DateTime actionTimestamp;
  final String userSessionId;
  final Map<String, dynamic>? cdeMetadata;

  // Governance & Lineage Metadata (Fields 10–11 Spec Compliance)
  final String governanceStatus;
  final String governanceOwner;
  final DateTime submittedOn;
  final DateTime targetDate;
  final String upstreamSourceRoute;
  final String downstreamOutcomeRoute;

  // Notification Event Triggers
  final String pushNotificationEvent;
  final String emailNotificationEvent;
  final String smsRbacAlertEvent;

  // API Contract Specifications
  static const String apiEndpoint = '/api/v1/documents/{documentId}/approve-sign';
  static const String httpMethod = 'POST';
  static const String authHeaderType = 'Bearer <userSessionId>';

  EndDocumentDefinition({
    required this.documentId,
    required this.title,
    required this.author,
    required this.completionDate,
    this.approvalStatus = DocumentApprovalStatus.pending,
    this.userRole = 'ComplianceOfficer',
    this.isRbacAuthorized = true,
    DateTime? actionTimestamp,
    String? userSessionId,
    this.cdeMetadata,
    this.governanceStatus = 'PASS',
    this.governanceOwner = 'DEA/OPS Compliance Team',
    DateTime? submittedOn,
    DateTime? targetDate,
    this.upstreamSourceRoute = 'Step 01 (RCGLA-014) -> /documents/review',
    this.downstreamOutcomeRoute = 'Step 03 (SCTSS-001) -> /documents/completed',
    this.pushNotificationEvent = 'PUSH_NOTIF_DOC_APPROVED',
    this.emailNotificationEvent = 'EMAIL_SIGN_OFF_CONFIRMATION',
    this.smsRbacAlertEvent = 'SMS_RBAC_REJECTION_ALERT',
  })  : actionTimestamp = actionTimestamp ?? DateTime.now(),
        userSessionId = userSessionId ?? 'SESS-2026-ED',
        submittedOn = submittedOn ?? DateTime(2026, 8, 14),
        targetDate = targetDate ?? DateTime(2026, 8, 20);

  // Validation Rule: Title Length (Min 5, Max 120)
  bool get isTitleLengthValid => title.length >= 5 && title.length <= 120;
  String get displayTitle => title.length > 80 ? '${title.substring(0, 77)}...' : title;

  // QA Hydration Sample Constant
  static final EndDocumentDefinition sampleQaInstance = EndDocumentDefinition(
    documentId: 'DOC-2026-EDEBS-032',
    title: 'Q3 Vendor Onboarding & Enterprise Data Compliance Sign-Off Audit Record',
    author: 'Jane Doe (Compliance Lead)',
    completionDate: DateTime(2026, 8, 14),
    approvalStatus: DocumentApprovalStatus.pending,
    userRole: 'ComplianceOfficer',
    isRbacAuthorized: true,
  );
}

/// Step EDEBS-032: End Document Summary & Layout Component with Poka-Yoke, RBAC, Escalation & Error Handling.
class EndDocumentLayout extends StatefulWidget {
  final EndDocumentDefinition document;
  final Future<bool> Function()? onApprove;

  const EndDocumentLayout({
    super.key,
    required this.document,
    this.onApprove,
  });

  @override
  State<EndDocumentLayout> createState() => _EndDocumentLayoutState();
}

class _EndDocumentLayoutState extends State<EndDocumentLayout> {
  bool _isSubmitting = false;
  String? _networkErrorMessage;
  late DocumentApprovalStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.document.approvalStatus;
  }

  void _showPokaYokeConfirmationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Poka-Yoke Sign-off Verification'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Executing digital sign-off for Document ID: ${widget.document.documentId}.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Title: ${widget.document.displayTitle}'),
              Text('Author: ${widget.document.author}'),
              Text('Authorized Role: ${widget.document.userRole}'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API Contract:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('${EndDocumentDefinition.httpMethod} ${EndDocumentDefinition.apiEndpoint}',
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                    Text('Auth: ${EndDocumentDefinition.authHeaderType}',
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Confirming will trigger notifications: PUSH_NOTIF_DOC_APPROVED & EMAIL_SIGN_OFF_CONFIRMATION.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _executeSignOff();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Confirm & Sign-Off'),
          ),
        ],
      ),
    );
  }

  void _showRbacEscalationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('RBAC Authorization Escalation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role "${widget.document.userRole}" is not authorized for executive sign-off.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Escalation Workflow Triggered:\n'
              '• Target Role: OPS_SECURITY_LEAD\n'
              '• Action: Requesting temporal 1-time delegation token.\n'
              '• Security Alert: ${widget.document.smsRbacAlertEvent} sent to Security Admin.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Escalation Request Sent to OPS_SECURITY_LEAD for Re-Authorization.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send Escalation Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSignOff() async {
    setState(() {
      _isSubmitting = true;
      _networkErrorMessage = null;
    });

    try {
      bool success = true;
      if (widget.onApprove != null) {
        success = await widget.onApprove!();
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (success) {
        setState(() {
          _currentStatus = DocumentApprovalStatus.approved;
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Success: Document signed! Triggered ${widget.document.pushNotificationEvent} and ${widget.document.emailNotificationEvent}.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('HTTP 500: Sign-Off Service Unavailable / Network Error');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _networkErrorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doc = widget.document;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Z-Pattern Scanning Header with Title Truncation Tooltip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.description, color: colorScheme.primary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Tooltip(
                          message: doc.title,
                          child: Text(
                            doc.displayTitle,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.hGapSm,
                StatusPillBadge(
                  label: _currentStatus.label,
                  type: _currentStatus.badgeType,
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,

            // Governance & Lineage Metadata Card
            Container(
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Governance: ${doc.governanceStatus} | Owner: ${doc.governanceOwner}',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target: ${doc.targetDate.toLocal().toString().split(' ')[0]}',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Lineage Upstream: ${doc.upstreamSourceRoute}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    'Lineage Downstream: ${doc.downstreamOutcomeRoute}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapMd,

            // Document Details
            Text('Document ID: ${doc.documentId}', style: theme.textTheme.bodySmall),
            Text('Author: ${doc.author}', style: theme.textTheme.bodySmall),
            Text(
              'Submitted On: ${doc.submittedOn.toLocal().toString().split(' ')[0]} | Completed: ${doc.completionDate.toLocal().toString().split(' ')[0]}',
              style: theme.textTheme.bodySmall,
            ),
            Text('User Role: ${doc.userRole}', style: theme.textTheme.bodySmall),

            // Network / API Error State Banner
            if (_networkErrorMessage != null) ...[
              AppSpacingTokens.vGapSm,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'API Error: $_networkErrorMessage',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showPokaYokeConfirmationModal(context),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],

            // RBAC Restricted Warning & Escalation Trigger
            if (!doc.isRbacAuthorized) ...[
              AppSpacingTokens.vGapSm,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(150),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'RBAC Restricted: Executive Sign-off Authority Required (Role: ${doc.userRole})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _showRbacEscalationModal(context),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                      child: const Text('Escalate'),
                    ),
                  ],
                ),
              ),
            ],

            AppSpacingTokens.vGapMd,
            Align(
              alignment: Alignment.centerRight,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: doc.isRbacAuthorized && _currentStatus != DocumentApprovalStatus.approved
                          ? () => _showPokaYokeConfirmationModal(context)
                          : null,
                      icon: Icon(_currentStatus == DocumentApprovalStatus.approved
                          ? Icons.verified
                          : (doc.isRbacAuthorized ? Icons.check_circle : Icons.lock)),
                      label: Text(_currentStatus == DocumentApprovalStatus.approved
                          ? 'Approved & Signed'
                          : (doc.isRbacAuthorized ? 'Approve & Sign' : 'Sign-Off Locked (RBAC)')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


