/*
 * CCPME-012 — Contextual Mobile Consent Gates & Poka-Yoke Control
 * 
 * Setup Step (Action): Contextual Mobile Consent Gates
 * Setup Step Description: Build in the mistake-proofing (poka-yoke) control: "Share Data"
 *   button remains permanently grayed out until user explicitly scrolls to bottom and clicks checkbox.
 * 
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Secure, un-ignorable acknowledgment embedded inside responsive dialog modal forms.
 *   - Ensures legal compliance smoothly on small mobile screens.
 *   - ScrollController tracks bottom scroll threshold before enabling terms checkbox.
 *   - Checkbox state listeners linked to "Share Data" CTA enabled/disabled state.
 *   - Poka-Yoke: "Share Data" CTA remains permanently grayed out until both scroll-to-bottom and checkbox triggers are satisfied.
 *   - Self-Chasing: Testing utilities attempt automated submission; if CTA activates without scroll completion, build fails.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step50MobileConsentGatePanel` widget and `ConsentBuildRecord` data model.
 *   - Implemented `PokaYokeConsentGuard` and `LeanSixSigmaDefectValidator` validation engines.
 *   - Built interactive mobile consent gate panel with scroll-to-bottom tracker, checkbox lock listeners, grayed-out CTA triggers, and M3 data table.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step CCPME-012: Consent Build Record Data Model.
class ConsentBuildRecord {
  final String buildStatus;
  final String buildTimestamp;
  final String buildArtifactsPath;
  final String buildLogs;
  final String buildDuration;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double pokaYokeComplianceRatio;

  // Step Specification & Metrics (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceOwner;

  const ConsentBuildRecord({
    required this.buildStatus,
    required this.buildTimestamp,
    required this.buildArtifactsPath,
    required this.buildLogs,
    required this.buildDuration,
    this.completionStatus = 'Good',
    required this.actionTimestamp,
    required this.userSessionId,
    this.pokaYokeComplianceRatio = 1.0,
    this.apiEndpoint = '/api/v1/consent/mobile-gates/evaluate',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceOwner = 'UI Compliance Architecture Team',
  });
}

enum Step50SixSigmaStatus {
  good('Good (≥0.98 Optimal)'),
  average('Average (0.90–0.97 Floor)'),
  poor('Poor (<0.90 Defect)');

  final String label;
  const Step50SixSigmaStatus(this.label);
}

/// Poka-Yoke Guard: "Share Data" button remains permanently grayed out until user explicitly scrolls to bottom and clicks checkbox.
abstract class PokaYokeConsentGuard {
  static bool isShareDataButtonEnabled({
    required bool hasScrolledToBottom,
    required bool isCheckboxChecked,
  }) {
    return hasScrolledToBottom && isCheckboxChecked;
  }

  static String getDisabledReason({
    required bool hasScrolledToBottom,
    required bool isCheckboxChecked,
  }) {
    if (!hasScrolledToBottom) {
      return 'Poka-Yoke Lock: Scroll to the bottom of the terms agreement to unlock checkbox.';
    }
    if (!isCheckboxChecked) {
      return 'Poka-Yoke Lock: Click agreement checkbox to enable "Share Data".';
    }
    return 'Poka-Yoke Verification Passed: "Share Data" button unlocked.';
  }
}

/// Lean Six Sigma Defect Correction Validator (Floor 0.9, Optimal 0.98, Ceiling 1.0).
abstract class LeanSixSigmaDefectValidator {
  static const double floor = 0.9;
  static const double optimal = 0.98;

  static Step50SixSigmaStatus evaluate(double ratio) {
    if (ratio >= optimal) return Step50SixSigmaStatus.good;
    if (ratio >= floor) return Step50SixSigmaStatus.average;
    return Step50SixSigmaStatus.poor;
  }
}

/// Step CCPME-012: Mobile Consent Gate Panel Component.
class Step50MobileConsentGatePanel extends StatefulWidget {
  final ConsentBuildRecord record;

  const Step50MobileConsentGatePanel({
    super.key,
    required this.record,
  });

  @override
  State<Step50MobileConsentGatePanel> createState() => _Step50MobileConsentGatePanelState();
}

class _Step50MobileConsentGatePanelState extends State<Step50MobileConsentGatePanel> {
  final ScrollController _termsScrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isCheckboxChecked = false;
  bool _isDataShared = false;

  @override
  void initState() {
    super.initState();
    _termsScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_termsScrollController.hasClients) {
      final maxScroll = _termsScrollController.position.maxScrollExtent;
      final currentScroll = _termsScrollController.position.pixels;
      if (currentScroll >= (maxScroll - 16.0)) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _termsScrollController.removeListener(_onScroll);
    _termsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isButtonEnabled = PokaYokeConsentGuard.isShareDataButtonEnabled(
      hasScrolledToBottom: _hasScrolledToBottom,
      isCheckboxChecked: _isCheckboxChecked,
    );
    final disabledReason = PokaYokeConsentGuard.getDisabledReason(
      hasScrolledToBottom: _hasScrolledToBottom,
      isCheckboxChecked: _isCheckboxChecked,
    );

    final sixSigmaStatus = LeanSixSigmaDefectValidator.evaluate(widget.record.pokaYokeComplianceRatio);
    final isPass = sixSigmaStatus != Step50SixSigmaStatus.poor;

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
                          Icon(Icons.rule_outlined, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'Contextual Mobile Consent Gates (Poka-Yoke Share Data Control)',
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
                              'CCPME-012',
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
                        'Build in the mistake-proofing (poka-yoke) control: "Share Data" button remains permanently grayed out until user explicitly scrolls to bottom and clicks checkbox.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Interactive Embedded Consent Gate Dialog Workspace ---
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mobile Legal Consent Dialog Form',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _hasScrolledToBottom
                                  ? colorScheme.primaryContainer
                                  : colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _hasScrolledToBottom
                                  ? 'Scroll: Completed'
                                  : 'Scroll: Locked at Top',
                              style: TextStyle(
                                color: _hasScrolledToBottom
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,

                      // Scrollable Terms & Conditions Box (Height 160)
                      Container(
                        height: 160,
                        padding: AppSpacingTokens.paddingMd,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hasScrolledToBottom
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Scrollbar(
                          controller: _termsScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _termsScrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TERMS OF DATA SHARING & COMPLIANCE AGREEMENT',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                AppSpacingTokens.vGapSm,
                                const Text(
                                  '1. Data Privacy: All customer interaction telemetry is encrypted using AES-256 standards.\n'
                                  '2. Usage Rights: Anonymous interaction logs will be used strictly for interface performance optimization.\n'
                                  '3. Non-Disclosure: No personal operational identities or financial parameters will be exposed to unauthenticated third-party nodes.\n'
                                  '4. Poka-Yoke Controls: Legal sign-off requires complete reading of terms prior to checkbox enablement.\n'
                                  '5. Final Audit Clause: Represents full master compliance registration across all spreadsheet steps.',
                                  style: TextStyle(fontSize: 12, height: 1.4),
                                ),
                                AppSpacingTokens.vGapMd,
                                Container(
                                  padding: AppSpacingTokens.paddingSm,
                                  decoration: BoxDecoration(
                                    color: AppColorPalette.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: AppColorPalette.success, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'End of Agreement Reached — Checkbox Enabled below!',
                                        style: TextStyle(color: AppColorPalette.success, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      AppSpacingTokens.vGapSm,

                      // Agreement Checkbox Locked until Scroll-to-Bottom
                      CheckboxListTile(
                        value: _isCheckboxChecked,
                        enabled: _hasScrolledToBottom,
                        title: const Text(
                          'I have read and accept the Data Sharing Agreement.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _hasScrolledToBottom
                              ? 'Checkbox unlocked.'
                              : 'Locked until you scroll to the bottom of the terms above.',
                          style: TextStyle(
                            fontSize: 11,
                            color: _hasScrolledToBottom ? colorScheme.onSurfaceVariant : colorScheme.error,
                          ),
                        ),
                        onChanged: _hasScrolledToBottom
                            ? (val) => setState(() => _isCheckboxChecked = val ?? false)
                            : null,
                      ),

                      AppSpacingTokens.vGapSm,

                      // Poka-Yoke Status Banner & Permanently Grayed-out "Share Data" CTA Button
                      Container(
                        padding: AppSpacingTokens.paddingMd,
                        decoration: BoxDecoration(
                          color: isButtonEnabled
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disabledReason,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isButtonEnabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            AppSpacingTokens.vGapSm,

                            // "Share Data" Button (Permanently Grayed Out until criteria met)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isButtonEnabled
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                foregroundColor: isButtonEnabled
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                minimumSize: const Size(180, 48), // 48dp minimum height
                              ),
                              onPressed: isButtonEnabled
                                  ? () => setState(() => _isDataShared = true)
                                  : null,
                              icon: const Icon(Icons.share),
                              label: Text(
                                _isDataShared
                                    ? 'DATA SHARED & VERIFIED'
                                    : (isButtonEnabled ? 'SHARE DATA' : 'SHARE DATA (GRAYED OUT)'),
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

              // --- Metric: Poka-Yoke Consent Gate Compliance Ratio Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Text(
                              'Poka-Yoke Consent Gate Compliance Ratio: ${(widget.record.pokaYokeComplianceRatio * 100).toStringAsFixed(0)}% — ${sixSigmaStatus.label}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      LinearProgressIndicator(
                        value: widget.record.pokaYokeComplianceRatio,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: isPass ? colorScheme.primary : colorScheme.error,
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Floor: 0.9 (90%) | Optimal: 0.98 (98%) | Ceiling: 1.0 (100%) (Standard: Lean Six Sigma Poka-Yoke defect-correction benchmark)',
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
                            DataColumn(label: Text('Build Status')),
                            DataColumn(label: Text('Build Timestamp')),
                            DataColumn(label: Text('Artifacts Path')),
                            DataColumn(label: Text('Build Logs')),
                            DataColumn(label: Text('Build Duration')),
                            DataColumn(label: Text('Completion Status')),
                            DataColumn(label: Text('Session ID')),
                            DataColumn(label: Text('Governance Owner')),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(widget.record.buildStatus)),
                              DataCell(Text(widget.record.buildTimestamp)),
                              DataCell(Text(widget.record.buildArtifactsPath)),
                              DataCell(Text(widget.record.buildLogs)),
                              DataCell(Text(widget.record.buildDuration)),
                              DataCell(Text(sixSigmaStatus.label)),
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
