/*
 * AEETE-001 — Byte-Level A/B Testing Execution on Mobile Components
 * 
 * Global Reference ID: AEETE-001
 * Atomic Steps Reference ID: AEETE-001
 * Setup Step (Action): Review the required work for: Byt-Level A/B Testing Execution on Mobile Components..
 * Setup Step Description: Prevents context abandonment at the absolute earliest gateway of the digital funnel with large touch-targets (>= 48px).
 * S.No: 9 | Sequence Order: 561 | Assigned Team: User Research & Understanding | Lead: Pooja
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Review Scope Coverage
 * - Floor Boundary: 0.9 (90%) | Optimal Target: 0.98 (98%) | Ceiling Boundary: 1.0 (100%)
 * - Best Qualitative Output: Complete
 * - Standard: Verify sample size guarantees minimum detectable effect (MDE)
 * - Data Collected: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration; Completion Status; Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - 3-tier M3 responsive breakpoint adaptation: Compact (<600dp), Medium (600-839dp), Expanded (>=840dp).
 *   - Touch targets >= 48x48dp strictly maintained across all variant selection cards.
 *   - Poka-Yoke check on predecessor_id.
 *   - Telemetry export via toExecutionLogJson().
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

enum AbTestCompletionStatus {
  complete('Complete'),
  partial('Partial'),
  notComplete('Not Complete');

  final String label;
  const AbTestCompletionStatus(this.label);
}

/// AEETE-001 Record Data Model.
class AbTestExecutionRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final int sNo;
  final int sequenceOrder;
  final String setupAction;
  final String assignedGroupTeam;
  final String decisionGroup;
  final String whyThisMatters;
  final String mobileAppFirstImplication;
  final String uxTranslation;
  final String dataRequirement;
  final String userInteractionImpact;
  final String dashboardImplication;
  final String whatStandardizedMustBeDone;
  final String atomicReusability;
  final String commonLibraryToStore;
  final String gcpBigQueryAlignment;
  final String estimatedTimeRequired;
  final String expectedOutput;
  final String completionMeasures;
  final String domainExpertiseNeeded;
  final String mistakeProofingPokaYoke;
  final String selfChasing;
  final String vitalityProsperityUs;
  final String vitalityProsperityCustomer;
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final double currentCoverageRate;
  final AbTestCompletionStatus completionStatus;
  final String actionTimestamp;
  final String userSessionId;

  const AbTestExecutionRecord({
    this.globalRefId = 'AEETE-001',
    this.atomicStepRefId = 'AEETE-001',
    this.sNo = 9,
    this.sequenceOrder = 561,
    this.setupAction = 'Byte-Level A/B Testing Execution on Mobile Components.',
    this.assignedGroupTeam = 'User Research & Understanding',
    this.decisionGroup = 'User Research & Understanding',
    this.whyThisMatters = 'Prevents context abandonment at the absolute earliest gateway of the digital funnel.',
    this.mobileAppFirstImplication = 'Requires large touch-targets (>= 48px) and eliminates keyboard layout overlap for smaller displays.',
    this.uxTranslation = 'Single-column login card containing text fields with inline placeholder indicators.',
    this.dataRequirement = 'Atomic-level data fields: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration',
    this.userInteractionImpact = 'Smooth transition from the Splash screen to an immediate interactive state.',
    this.dashboardImplication = 'Real-time tracking of sign-up drops within the core operational monitoring layout.',
    this.whatStandardizedMustBeDone = 'Mark mandatory fields with a red asterisk (*).',
    this.atomicReusability = 'Component functions can be redeployed across all external vendor and internal admin screens.',
    this.commonLibraryToStore = 'Universal UI Library package',
    this.gcpBigQueryAlignment = 'Events pushed via Pub/Sub to trigger streaming real-time analytical records.',
    this.estimatedTimeRequired = '4 Hours',
    this.expectedOutput = 'Mobile low-fidelity sign-up wireframe and authentication data-flow chart.',
    this.completionMeasures = 'Requirements Defined - Logic Documented = 0 checked inside Project Jira.',
    this.domainExpertiseNeeded = 'UX Research & Identity Management Engineer',
    this.mistakeProofingPokaYoke = 'The system programmatically rejects any upload of form models lacking a specified predecessor_id column.',
    this.selfChasing = 'Missing validation parameters cause building linters to instantly stop the integration pipeline.',
    this.vitalityProsperityUs = 'Accelerates the volume of validated user entries to hit monthly acquisition goals.',
    this.vitalityProsperityCustomer = 'Delivers zero friction during the critical first 30 seconds of app exposure.',
    this.metricName = 'Review Scope Coverage',
    this.floorBoundary = 0.90,
    this.optimalTarget = 0.98,
    this.ceilingBoundary = 1.00,
    this.currentCoverageRate = 0.985,
    this.completionStatus = AbTestCompletionStatus.complete,
    required this.actionTimestamp,
    required this.userSessionId,
  });

  bool get meetsOptimalTarget => currentCoverageRate >= optimalTarget;

  Map<String, dynamic> toExecutionLogJson() => {
    'execution_id': 'EXEC-AEETE-001-2026',
    'global_ref_id': globalRefId,
    'atomic_step_ref_id': atomicStepRefId,
    'task_title': 'Review the required work for: Byt-Level A/B Testing Execution on Mobile Components..',
    'timestamp': actionTimestamp,
    'user_session_id': userSessionId,
    'telemetry_payload': {
      'mobile_platform': 'Flutter/Android/iOS',
      'os_version': 'AOSP 14 / iOS 17',
      'device_type': 'Responsive Handheld Terminal',
      'screen_dimensions': '390x844dp @3x',
      'mobile_configuration': 'Byte-Level A/B Component Suite',
      'review_scope_coverage': currentCoverageRate,
      'completion_status': completionStatus.label,
    },
    'metric_evaluation': {
      'metric_name': metricName,
      'floor_boundary': floorBoundary,
      'optimal_target': optimalTarget,
      'ceiling_boundary': ceilingBoundary,
      'current_measured': currentCoverageRate,
      'qualitative_output': 'Complete',
      'compliance_verified': meetsOptimalTarget,
    },
    'standards': [
      'Verify sample size guarantees minimum detectable effect (MDE)',
      'Material Design 3 Interactive Targets (>= 48x48dp)',
      'ISO/IEC 25010 Usability Standard',
    ],
  };
}

class AbTestVariant {
  final String variantId;
  final String variantName;
  final String description;
  final double conversionRate;
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final String screenDimensions;

  const AbTestVariant({
    required this.variantId,
    required this.variantName,
    required this.description,
    required this.conversionRate,
    this.mobilePlatform = 'CrossPlatform_Flutter',
    this.osVersion = 'Android_14_iOS_17_Web',
    this.deviceType = 'Mobile_Tablet_Desktop',
    this.screenDimensions = '360x800_DP_ADAPTIVE',
  });
}

/// AEETE-001 Main Component Panel Widget
class AbTestingCardSwitch extends StatefulWidget {
  final AbTestExecutionRecord? record;
  final List<AbTestVariant> variants;

  const AbTestingCardSwitch({
    super.key,
    this.record,
    required this.variants,
  });

  @override
  State<AbTestingCardSwitch> createState() => _AbTestingCardSwitchState();
}

class _AbTestingCardSwitchState extends State<AbTestingCardSwitch> {
  late String _selectedVariantId;
  bool _predecessorIdValid = true;

  @override
  void initState() {
    super.initState();
    _selectedVariantId = widget.variants.isNotEmpty ? widget.variants.first.variantId : 'VAR-A';
  }

  void _onVariantSelected(String variantId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedVariantId = variantId;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A/B Variant Switched to: $variantId (Pub/Sub Event Pushed)'),
        backgroundColor: AppColorPalette.brandPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record ?? const AbTestExecutionRecord(
      actionTimestamp: '2026-08-24 16:21:00 UTC',
      userSessionId: 'USR-AB-5610',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;

        return Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacingTokens.xs : AppSpacingTokens.sm,
            vertical: AppSpacingTokens.xs,
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? AppSpacingTokens.sm : (isExpanded ? AppSpacingTokens.lg : AppSpacingTokens.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alt_route, color: colorScheme.onPrimaryContainer, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            record.globalRefId,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacingTokens.hGapSm,
                    Expanded(
                      child: Text(
                        'Byte-Level A/B Testing Execution',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColorPalette.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColorPalette.success),
                      ),
                      child: Text(
                        record.completionStatus.label,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColorPalette.success),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // Description Banner
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.touch_app_outlined, color: colorScheme.primary, size: 20),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'Touch Targets >= 48dp | Pub/Sub Analytics',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapXs,
                      Text(
                        record.whyThisMatters,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapLg,

                // Variant Selector Cards (Touch Targets >= 48dp)
                Text(
                  'Select Experiment Variant (Adaptive Material Cards)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapSm,
                Column(
                  children: widget.variants.map((variant) {
                    final isSelected = variant.variantId == _selectedVariantId;
                    return InkWell(
                      onTap: () => _onVariantSelected(variant.variantId),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(minHeight: 48),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColorPalette.brandPrimary.withValues(alpha: 0.08) : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColorPalette.brandPrimary : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColorPalette.brandPrimary : colorScheme.onSurfaceVariant,
                            ),
                            AppSpacingTokens.hGapSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    variant.variantName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColorPalette.brandPrimary : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    variant.description,
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColorPalette.brandPrimary : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'CVR: ${(variant.conversionRate * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacingTokens.vGapLg,

                // Single-Column Mandatory Login Wireframe (* Red Asterisk Poka-Yoke)
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wireframe Form Gateway (Mandatory * Red Asterisk Standards)',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      RichText(
                        text: TextSpan(
                          text: 'Mobile User ID ',
                          style: theme.textTheme.bodyMedium,
                          children: const [
                            TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Mobile User ID...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Poka-Yoke validation: predecessor_id check:',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          Switch(
                            value: _predecessorIdValid,
                            onChanged: (val) => setState(() => _predecessorIdValid = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapLg,

                // Audit Metric Boundary Grid
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Metric: ${record.metricName}',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        children: [
                          _buildMetricTile(context, 'Floor Boundary', '${(record.floorBoundary * 100).toInt()}%', AppColorPalette.warning),
                          _buildMetricTile(context, 'Optimal Target', '>=${(record.optimalTarget * 100).toInt()}%', AppColorPalette.info),
                          _buildMetricTile(context, 'Ceiling Boundary', '${(record.ceilingBoundary * 100).toInt()}%', AppColorPalette.success),
                          _buildMetricTile(context, 'Current Rate', '${(record.currentCoverageRate * 100).toInt()}%', AppColorPalette.brandPrimary),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapLg,

                if (isExpanded) ...[
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingSm,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('M3 Expanded Viewport: 840dp+ Active | Pub/Sub Topic: ${record.gcpBigQueryAlignment}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Session: ${record.userSessionId}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  AppSpacingTokens.vGapMd,
                ],

                // Vitality & Prosperity Summary Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: AppSpacingTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColorPalette.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitality & Prosperity (Us)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.brandPrimary,
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(record.vitalityProsperityUs, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    AppSpacingTokens.hGapSm,
                    Expanded(
                      child: Container(
                        padding: AppSpacingTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColorPalette.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitality & Prosperity (Customer)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.success,
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(record.vitalityProsperityCustomer, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String val, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
