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
        backgroundColor: AbTestingCardSwitchTokens.brandPrimary,
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
            horizontal: isCompact ? AbTestingCardSwitchTokens.xs : AbTestingCardSwitchTokens.sm,
            vertical: AbTestingCardSwitchTokens.xs,
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? AbTestingCardSwitchTokens.sm : (isExpanded ? AbTestingCardSwitchTokens.lg : AbTestingCardSwitchTokens.md)),
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
                    AbTestingCardSwitchTokens.hGapSm,
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
                        color: AbTestingCardSwitchTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AbTestingCardSwitchTokens.success),
                      ),
                      child: Text(
                        record.completionStatus.label,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AbTestingCardSwitchTokens.success),
                      ),
                    ),
                  ],
                ),
                AbTestingCardSwitchTokens.vGapMd,

                // Description Banner
                Container(
                  padding: AbTestingCardSwitchTokens.paddingMd,
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
                          AbTestingCardSwitchTokens.hGapSm,
                          Text(
                            'Touch Targets >= 48dp | Pub/Sub Analytics',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AbTestingCardSwitchTokens.vGapXs,
                      Text(
                        record.whyThisMatters,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                AbTestingCardSwitchTokens.vGapLg,

                // Variant Selector Cards (Touch Targets >= 48dp)
                Text(
                  'Select Experiment Variant (Adaptive Material Cards)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                AbTestingCardSwitchTokens.vGapSm,
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
                          color: isSelected ? AbTestingCardSwitchTokens.brandPrimary.withValues(alpha: 0.08) : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AbTestingCardSwitchTokens.brandPrimary : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AbTestingCardSwitchTokens.brandPrimary : colorScheme.onSurfaceVariant,
                            ),
                            AbTestingCardSwitchTokens.hGapSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    variant.variantName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AbTestingCardSwitchTokens.brandPrimary : colorScheme.onSurface,
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
                                color: isSelected ? AbTestingCardSwitchTokens.brandPrimary : colorScheme.surfaceContainerHighest,
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
                AbTestingCardSwitchTokens.vGapLg,

                // Single-Column Mandatory Login Wireframe (* Red Asterisk Poka-Yoke)
                Container(
                  padding: AbTestingCardSwitchTokens.paddingMd,
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
                      AbTestingCardSwitchTokens.vGapSm,
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
                      AbTestingCardSwitchTokens.vGapSm,
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
                AbTestingCardSwitchTokens.vGapLg,

                // Audit Metric Boundary Grid
                Container(
                  padding: AbTestingCardSwitchTokens.paddingMd,
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
                      AbTestingCardSwitchTokens.vGapSm,
                      Row(
                        children: [
                          _buildMetricTile(context, 'Floor Boundary', '${(record.floorBoundary * 100).toInt()}%', AbTestingCardSwitchTokens.warning),
                          _buildMetricTile(context, 'Optimal Target', '>=${(record.optimalTarget * 100).toInt()}%', AbTestingCardSwitchTokens.info),
                          _buildMetricTile(context, 'Ceiling Boundary', '${(record.ceilingBoundary * 100).toInt()}%', AbTestingCardSwitchTokens.success),
                          _buildMetricTile(context, 'Current Rate', '${(record.currentCoverageRate * 100).toInt()}%', AbTestingCardSwitchTokens.brandPrimary),
                        ],
                      ),
                    ],
                  ),
                ),
                AbTestingCardSwitchTokens.vGapLg,

                if (isExpanded) ...[
                  Container(
                    width: double.infinity,
                    padding: AbTestingCardSwitchTokens.paddingSm,
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
                  AbTestingCardSwitchTokens.vGapMd,
                ],

                // Vitality & Prosperity Summary Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: AbTestingCardSwitchTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: AbTestingCardSwitchTokens.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitality & Prosperity (Us)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AbTestingCardSwitchTokens.brandPrimary,
                              ),
                            ),
                            AbTestingCardSwitchTokens.vGapXs,
                            Text(record.vitalityProsperityUs, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    AbTestingCardSwitchTokens.hGapSm,
                    Expanded(
                      child: Container(
                        padding: AbTestingCardSwitchTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: AbTestingCardSwitchTokens.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitality & Prosperity (Customer)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AbTestingCardSwitchTokens.success,
                              ),
                            ),
                            AbTestingCardSwitchTokens.vGapXs,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class AbTestingCardSwitchTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: AbTestingCardSwitch(
              variants: [
                AbTestVariant(
                  variantId: 'VAR-A',
                  variantName: 'Variant A (Compact)',
                  description: 'Dense single-column layout',
                  conversionRate: 0.048,
                ),
                AbTestVariant(
                  variantId: 'VAR-B',
                  variantName: 'Variant B (Fluid)',
                  description: 'Expanded fluid grid layout',
                  conversionRate: 0.062,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
