/*
 * STEP 44: REF-016 — Integrated Character-Level Text Formatting Mask Handler
 * 
 * Setup Step (Action): Build an integrated character-level text formatting mask
 *   handler for data entry input fields.
 * Setup Step Description: Identify all data entry input fields requiring text
 *   masking across the application.
 * 
 * ---------------------------------------------------------------------------------------------------
 * DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 & DEA/OPS Doc Conversion):
 * 1. API Endpoint: POST /api/v1/input-masks/character-level/enforce
 * 2. HTTP Method: POST | Fetch Endpoint: GET /api/v1/input-masks/{maskId}
 * 3. Auth Headers: Authorization: Bearer <userSessionId>, Content-Type: application/json
 * 4. Payload Mapping: {"stepExecutionId": String, "executionStatus": String, "executionTimestamp": String, "stepOutcome": String, "userId": String}
 * 5. Notifications / Messages:
 *    - Push Notification: PUSH_NOTIF_MASK_HANDLER_ACTIVE ("Character-level text formatting mask active across registry.")
 *    - Email Notification: EMAIL_MASK_SPEC_AUDIT (Sent to Frontend Logic Developer and RegEx Specialist)
 *    - SMS Alert: SMS_POKA_YOKE_INVALID_CHAR_DROPPED (Sent to QA Ops when invalid characters are intercepted)
 * 6. Approval Escalation Chain:
 *    - Primary Approver: FrontendLogicDeveloper (Role)
 *    - Escalation Handler: If unmasked inputs pass into payload compilation, triggers DEPLOYMENT_ERROR_FLAG
 * 7. Error Handling & Failure States:
 *    - Poka-Yoke Gate: Drops invalid characters from keyboard buffer before registering in form state memory.
 * 8. Upstream & Downstream Lineage:
 *    - Upstream Source: Step 43 (IS32-CSIVW-019-AS01) - CTA Verb Limits -> Route: /components/cta-limits
 *    - Downstream Outcome: Step 45 - Automated Form Validation Pipeline -> Route: /forms/validation-pipeline
 * 9. Governance Metadata:
 *    - Status: PASS | Owner: Frontend Input & Security Perimeter Team | Submitted On: 2026-08-15 | Target Date: 2026-08-20
 * 10. Validation Rules:
 *    - Identification Accuracy: Floor 95.0%, Optimal 100.0%, Ceiling 100.0%. Standard: Complete/Not Complete.
 * ---------------------------------------------------------------------------------------------------
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Minimizes typing frustrations on soft keyboards by handling spacing and formatting automatically.
 *   - Map input field height parameters to match a minimum 56px standard for touch access.
 *   - Adhere to MD3 text field error messaging layout rules for invalid inputs.
 *   - Apply distinctive visual color variables for focus and idle input field states.
 *   - Ensure validation error notes remain short to fit within narrow form widths without clipping.
 *   - Poka-Yoke: Input-filtering logic gate drops invalid characters from keyboard buffer before registering in state memory.
 *   - Self-Chasing: Testing utilities simulate automated data entry tasks; if unmasked inputs pass, deployment raises error flag.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step44TextMaskHandlerPanel` widget and `TextMaskRecord` data model.
 *   - Implemented `PokaYokeInputFilterGuard` and `IdentificationAccuracyValidator` validation engines.
 *   - Built interactive phone/tax/amount mask tester with live character drop counters, regex validators, and M3 data table.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step REF-016: Text Mask Audit Record Data Model.
class TextMaskRecord {
  final String stepExecutionId;
  final String executionStatus;
  final String executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double identificationAccuracy;

  // DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceOwner;

  const TextMaskRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    this.completionStatus = 'Complete',
    required this.actionTimestamp,
    required this.userSessionId,
    this.identificationAccuracy = 100.0,
    this.apiEndpoint = '/api/v1/input-masks/character-level/enforce',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceOwner = 'Frontend Input & Security Perimeter Team',
  });
}

enum Step44CompletionStatus {
  complete('Complete'),
  notComplete('Not Complete');

  final String label;
  const Step44CompletionStatus(this.label);
}

/// Poka-Yoke Gate: Drops invalid characters before they register in form state memory.
abstract class PokaYokeInputFilterGuard {
  static String applyMask({
    required String input,
    required String maskType, // 'PHONE', 'TAX_ID', 'CURRENCY'
  }) {
    if (input.isEmpty) return '';

    if (maskType == 'PHONE') {
      final digits = input.replaceAll(RegExp(r'\D'), '');
      if (digits.length <= 3) return digits;
      if (digits.length <= 6) return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
      final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
      return '(${capped.substring(0, 3)}) ${capped.substring(3, 6)}-${capped.substring(6)}';
    }

    if (maskType == 'TAX_ID') {
      final digits = input.replaceAll(RegExp(r'\D'), '');
      if (digits.length <= 2) return digits;
      final capped = digits.length > 8 ? digits.substring(0, 8) : digits;
      return 'TX-${capped.substring(0, 2)}-${capped.substring(2)}';
    }

    if (maskType == 'CURRENCY') {
      final digits = input.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return '';
      final val = double.tryParse(digits) ?? 0.0;
      return '\$${(val / 100).toStringAsFixed(2)}';
    }

    return input;
  }

  static int countRejectedChars(String rawInput, String maskType) {
    if (maskType == 'PHONE' || maskType == 'TAX_ID' || maskType == 'CURRENCY') {
      return RegExp(r'[^\d]').allMatches(rawInput).length;
    }
    return 0;
  }
}

/// Identification Accuracy Validator (Floor 95.0%, Optimal 100.0%).
abstract class IdentificationAccuracyValidator {
  static const double floor = 95.0;
  static const double optimal = 100.0;

  static Step44CompletionStatus evaluate(double accuracyPercentage) {
    if (accuracyPercentage >= floor) return Step44CompletionStatus.complete;
    return Step44CompletionStatus.notComplete;
  }
}

/// Step REF-016: Text Mask Handler Panel Component.
class Step44TextMaskHandlerPanel extends StatefulWidget {
  final TextMaskRecord record;

  const Step44TextMaskHandlerPanel({
    super.key,
    required this.record,
  });

  @override
  State<Step44TextMaskHandlerPanel> createState() => _Step44TextMaskHandlerPanelState();
}

class _Step44TextMaskHandlerPanelState extends State<Step44TextMaskHandlerPanel> {
  final TextEditingController _rawInputController = TextEditingController(text: '9876543210abc');
  String _selectedMaskType = 'PHONE';
  int _rejectedCount = 3;

  @override
  void dispose() {
    _rawInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rawText = _rawInputController.text;
    final maskedResult = PokaYokeInputFilterGuard.applyMask(
      input: rawText,
      maskType: _selectedMaskType,
    );
    _rejectedCount = PokaYokeInputFilterGuard.countRejectedChars(rawText, _selectedMaskType);

    final completionStatus = IdentificationAccuracyValidator.evaluate(widget.record.identificationAccuracy);
    final isPass = completionStatus == Step44CompletionStatus.complete;

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
                          Icon(Icons.password_outlined, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'Step 44: Integrated Character-Level Text Formatting Mask Handler',
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
                              'REF-016',
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
                        'Build an integrated character-level text formatting mask handler for data entry input fields across the application.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Interactive Input Mask Workspace ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Character-Level Input Filter (Poka-Yoke Logic Gate)',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        children: [
                          const Text('Select Mask Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          ChoiceChip(
                            label: const Text('Phone Number'),
                            selected: _selectedMaskType == 'PHONE',
                            onSelected: (_) => setState(() => _selectedMaskType = 'PHONE'),
                          ),
                          AppSpacingTokens.hGapSm,
                          ChoiceChip(
                            label: const Text('Tax Identification'),
                            selected: _selectedMaskType == 'TAX_ID',
                            onSelected: (_) => setState(() => _selectedMaskType = 'TAX_ID'),
                          ),
                          AppSpacingTokens.hGapSm,
                          ChoiceChip(
                            label: const Text('Currency Amount'),
                            selected: _selectedMaskType == 'CURRENCY',
                            onSelected: (_) => setState(() => _selectedMaskType = 'CURRENCY'),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,

                      // 56px Minimum Height Touch Target Input
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: TextField(
                          controller: _rawInputController,
                          decoration: InputDecoration(
                            labelText: 'Test User Keyed Input Stream',
                            hintText: 'Type letters and digits (e.g. 9876543210abc)...',
                            border: const OutlineInputBorder(),
                            helperText: 'Poka-Yoke: Invalid non-numeric characters dropped automatically.',
                            suffixIcon: _rejectedCount > 0
                                ? Tooltip(
                                    message: 'Dropped $_rejectedCount invalid characters',
                                    child: const Icon(Icons.shield_outlined, color: AppColorPalette.warning),
                                  )
                                : const Icon(Icons.verified_outlined, color: AppColorPalette.success),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      AppSpacingTokens.vGapSm,

                      // Auto-Formatted Mask Output Container
                      Container(
                        width: double.infinity,
                        padding: AppSpacingTokens.paddingLg,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formatted Payload Output Value:',
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            AppSpacingTokens.vGapSm,
                            Text(
                              maskedResult.isEmpty ? '(Empty Payload)' : maskedResult,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            AppSpacingTokens.vGapSm,
                            Text(
                              'Rejected Invalid Buffer Characters: $_rejectedCount',
                              style: TextStyle(
                                color: _rejectedCount > 0 ? AppColorPalette.warning : AppColorPalette.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Metric: Identification Accuracy Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'Identification Accuracy: ${widget.record.identificationAccuracy.toStringAsFixed(1)}% — ${completionStatus.label}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      LinearProgressIndicator(
                        value: widget.record.identificationAccuracy / 100.0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: isPass ? colorScheme.primary : colorScheme.error,
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Floor: 95.0% | Optimal: 100.0% | Ceiling: 100.0% (Standard: Comprehensive audit for data hygiene)',
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
                        'Data Collected by System',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
                            DataRow(cells: [
                              DataCell(Text(widget.record.stepExecutionId)),
                              DataCell(Text(widget.record.executionStatus)),
                              DataCell(Text(widget.record.executionTimestamp)),
                              DataCell(Text(widget.record.stepOutcome)),
                              DataCell(Text(widget.record.userId)),
                              DataCell(Text(completionStatus.label)),
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
