/*
 * STEP 43: IS32-CSIVW-019-AS01 — Enforce System-Verb CTA Character Limits
 * 
 * Setup Step (Action): Enforce System-Verb CTA Character Limits.
 * Setup Step Description: Access call-to-action (CTA) button base component
 *   specification files.
 * 
 * ---------------------------------------------------------------------------------------------------
 * DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 & DEA/OPS Doc Conversion):
 * 1. API Endpoint: POST /api/v1/components/cta-verb-limits/enforce
 * 2. HTTP Method: POST | Fetch Endpoint: GET /api/v1/components/cta-verb-limits/{componentId}
 * 3. Auth Headers: Authorization: Bearer <userSessionId>, Content-Type: application/json
 * 4. Payload Mapping: {"accessType": String, "userRole": String, "permissionLevel": String, "accessLog": String, "completionStatus": String}
 * 5. Notifications / Messages:
 *    - Push Notification: PUSH_NOTIF_CTA_LIMIT_ENFORCED ("System-Verb CTA character limits active globally.")
 *    - Email Notification: EMAIL_CTA_SPEC_AUDIT (Sent to OPS Lead and UX Designer)
 *    - SMS Alert: SMS_POKA_YOKE_VERB_WARNING (Sent to Design Ops when button text exceeds word/character threshold)
 * 6. Approval Escalation Chain:
 *    - Primary Approver: OperationsLead (Role)
 *    - Escalation Handler: If Poka-Yoke warning triggered >3 times, escalates to UX_SYSTEMS_ARCHITECT
 * 7. Error Handling & Failure States:
 *    - Poka-Yoke Warning: Buttons exceeding limits pulse warning outlines, chasing designer to pick shorter verbs.
 * 8. Upstream & Downstream Lineage:
 *    - Upstream Source: Step 42 (VPVMP-006-14) - Backward Document Mapping -> Route: /docs/mapping
 *    - Downstream Outcome: Step 44 - Global System-Verb Enforcement -> Route: /components/cta-global
 * 9. Governance Metadata:
 *    - Status: PASS | Owner: OPS / UI Component Constraints Team | Submitted On: 2026-08-15 | Target Date: 2026-08-20
 * 10. Validation Rules:
 *    - Asset Discovery Completeness: Floor 90%, Optimal 100%, Ceiling 100%. Standard: Complete/Partial/Not Complete.
 * ---------------------------------------------------------------------------------------------------
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Ensures buttons never break into two lines on narrow screens, protecting grid alignment.
 *   - Uniform button widths/heights globally using Flexbox button containers.
 *   - CSS white-space: nowrap equivalent in Flutter text layout properties.
 *   - Poka-Yoke: System auto-truncates and flags text exceeding limit with pulsing warning outlines.
 *   - Self-Chasing: Buttons exceeding limits pulse warning outlines, chasing designer to pick shorter verbs.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step43SystemVerbCtaPanel` widget and `CtaVerbConstraintRecord` data model.
 *   - Implemented `PokaYokeCtaWarningGuard` and `DiscoveryCompletenessValidator` engines.
 *   - Built interactive CTA verb testing workspace with pulsing warning border animation.
 *   - Added asset discovery completeness progress bar and M3 data audit table.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step IS32-CSIVW-019-AS01: CTA Verb Constraint Audit Record Data Model.
class CtaVerbConstraintRecord {
  final String accessType;
  final String userRole;
  final String permissionLevel;
  final String accessLog;
  final String accessTimestamp;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double discoveryCompleteness;
  final int maxCharacterLimit;
  final int maxWordLimit;

  // DEA AUDIT & API CONTRACT SPECIFICATION (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceOwner;

  const CtaVerbConstraintRecord({
    required this.accessType,
    required this.userRole,
    required this.permissionLevel,
    required this.accessLog,
    required this.accessTimestamp,
    this.completionStatus = 'Complete',
    required this.actionTimestamp,
    required this.userSessionId,
    this.discoveryCompleteness = 1.0,
    this.maxCharacterLimit = 14,
    this.maxWordLimit = 2,
    this.apiEndpoint = '/api/v1/components/cta-verb-limits/enforce',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceOwner = 'OPS / UI Component Constraints Team',
  });
}

enum CtaCompletionStatus {
  complete('Complete'),
  partial('Partial'),
  notComplete('Not Complete');

  final String label;
  const CtaCompletionStatus(this.label);
}

/// Poka-Yoke Guard: Flags and checks CTA text against max word and character constraints.
abstract class PokaYokeCtaWarningGuard {
  static bool isExceedingLimits(String ctaText, int maxChars, int maxWords) {
    final trimmed = ctaText.trim();
    if (trimmed.isEmpty) return false;
    final words = trimmed.split(RegExp(r'\s+'));
    return trimmed.length > maxChars || words.length > maxWords;
  }

  static String getWarningReason(String ctaText, int maxChars, int maxWords) {
    final trimmed = ctaText.trim();
    final words = trimmed.split(RegExp(r'\s+'));
    final List<String> reasons = [];
    if (trimmed.length > maxChars) {
      reasons.add('Length (${trimmed.length} chars) > Max ($maxChars chars)');
    }
    if (words.length > maxWords) {
      reasons.add('Words (${words.length}) > Max ($maxWords words)');
    }
    return reasons.join(' & ');
  }
}

/// Asset & Component Discovery Completeness Validator (Floor 90%, Optimal 100%).
abstract class DiscoveryCompletenessValidator {
  static const double floor = 0.90;
  static const double optimal = 1.0;

  static CtaCompletionStatus evaluate(double percentage) {
    if (percentage >= optimal) return CtaCompletionStatus.complete;
    if (percentage >= floor) return CtaCompletionStatus.partial;
    return CtaCompletionStatus.notComplete;
  }
}

/// Step IS32-CSIVW-019-AS01: System Verb CTA Panel Component.
class Step43SystemVerbCtaPanel extends StatefulWidget {
  final CtaVerbConstraintRecord record;

  const Step43SystemVerbCtaPanel({
    super.key,
    required this.record,
  });

  @override
  State<Step43SystemVerbCtaPanel> createState() => _Step43SystemVerbCtaPanelState();
}

class _Step43SystemVerbCtaPanelState extends State<Step43SystemVerbCtaPanel>
    with SingleTickerProviderStateMixin {
  late TextEditingController _ctaInputController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  int _maxChars = 14;
  int _maxWords = 2;
  double _discoveryCompleteness = 1.0;

  final List<String> _sampleVerbs = [
    'APPROVE',
    'REJECT',
    'CONFIRM PAYOUT',
    'SUBMIT DOCUMENTATION FOR COMPLIANCE REVIEW',
    'SIGN & LOCK',
  ];

  @override
  void initState() {
    super.initState();
    _ctaInputController = TextEditingController(text: 'SUBMIT DOCUMENTATION FOR COMPLIANCE REVIEW');
    _maxChars = widget.record.maxCharacterLimit;
    _maxWords = widget.record.maxWordLimit;
    _discoveryCompleteness = widget.record.discoveryCompleteness;

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctaInputController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentCtaText = _ctaInputController.text;
    final isExceeding = PokaYokeCtaWarningGuard.isExceedingLimits(
      currentCtaText,
      _maxChars,
      _maxWords,
    );
    final warningReason = PokaYokeCtaWarningGuard.getWarningReason(
      currentCtaText,
      _maxChars,
      _maxWords,
    );

    final discoveryStatus = DiscoveryCompletenessValidator.evaluate(_discoveryCompleteness);

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
                          Icon(Icons.touch_app_outlined, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'Step 43: Enforce System-Verb CTA Character Limits',
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
                              'IS32-CSIVW-019-AS01',
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
                        'Enforces System-Verb CTA character limits across call-to-action base components to protect grid alignment and prevent text wrapping on narrow screens.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Interactive System-Verb CTA Enforcer Workspace ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CTA Character & Word Limit Enforcer (Poka-Yoke & Self-Chasing)',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _maxChars.toDouble(),
                              min: 5,
                              max: 30,
                              divisions: 25,
                              label: 'Max Chars: $_maxChars',
                              onChanged: (v) => setState(() => _maxChars = v.toInt()),
                            ),
                          ),
                          Text('Max Chars: $_maxChars', style: theme.textTheme.labelMedium),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _maxWords.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: 'Max Words: $_maxWords',
                              onChanged: (v) => setState(() => _maxWords = v.toInt()),
                            ),
                          ),
                          Text('Max Words: $_maxWords', style: theme.textTheme.labelMedium),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      TextField(
                        controller: _ctaInputController,
                        decoration: InputDecoration(
                          labelText: 'Test CTA Label',
                          hintText: 'Enter CTA button label...',
                          border: const OutlineInputBorder(),
                          suffixIcon: isExceeding
                              ? const Icon(Icons.warning, color: Colors.orange)
                              : const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Quick Preset System Verbs:',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      AppSpacingTokens.vGapXs,
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _sampleVerbs.map((verb) {
                          final selected = verb == currentCtaText;
                          return ChoiceChip(
                            label: Text(verb),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _ctaInputController.text = verb;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      AppSpacingTokens.vGapMd,

                      // --- Flexbox Button Live Preview Container ---
                      Text(
                        'Global Flexbox Button Preview (CSS white-space: nowrap):',
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,

                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            padding: AppSpacingTokens.paddingMd,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isExceeding
                                    ? AppColorPalette.warning
                                    : colorScheme.outlineVariant,
                                width: isExceeding ? _pulseAnimation.value : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isExceeding
                                            ? AppColorPalette.lightError
                                            : colorScheme.primary,
                                        foregroundColor: isExceeding
                                            ? Colors.white
                                            : colorScheme.onPrimary,
                                        minimumSize: const Size(88, 48), // 48dp min height
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        currentCtaText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    AppSpacingTokens.hGapSm,
                                    Expanded(
                                      child: Text(
                                        isExceeding
                                            ? 'WARNING: $warningReason'
                                            : 'PASS: Label within bounds without wrapping',
                                        style: TextStyle(
                                          color: isExceeding ? AppColorPalette.lightError : AppColorPalette.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Metric: Asset & Component Discovery Completeness Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'Asset & Component Discovery Completeness: ${(_discoveryCompleteness * 100).toStringAsFixed(0)}% — ${discoveryStatus.label}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      LinearProgressIndicator(
                        value: _discoveryCompleteness,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: _discoveryCompleteness >= 0.90
                            ? AppColorPalette.success
                            : colorScheme.error,
                      ),
                      AppSpacingTokens.vGapXs,
                      Text(
                        'Floor: 90% | Optimal: 100% | Ceiling: 100% (Full inventory confirmed before downstream config)',
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
                            DataColumn(label: Text('Access Type')),
                            DataColumn(label: Text('User Role')),
                            DataColumn(label: Text('Permission Level')),
                            DataColumn(label: Text('Access Log')),
                            DataColumn(label: Text('Access Timestamp')),
                            DataColumn(label: Text('Completion Status')),
                            DataColumn(label: Text('Session ID')),
                            DataColumn(label: Text('Governance Owner')),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(widget.record.accessType)),
                              DataCell(Text(widget.record.userRole)),
                              DataCell(Text(widget.record.permissionLevel)),
                              DataCell(Text(widget.record.accessLog)),
                              DataCell(Text(widget.record.accessTimestamp)),
                              DataCell(Text(discoveryStatus.label)),
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
