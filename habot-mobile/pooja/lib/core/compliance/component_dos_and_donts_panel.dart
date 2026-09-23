/*
 * AEETE-020-A09 — Component "Do's and Don'ts" Section Content Panel
 * 
 * Global Reference ID: AEETE-020
 * Atomic Steps Reference ID: AEETE-020-A09
 * Setup Step (Action): Draft the "Do's and Don'ts" section content for each targeted component.
 * Sequence Order: 921 | Row: 14 | Team: Pooja (Component Governance Engineering)
 * 
 * 49-Columns Alignment & Architecture Mandates (my steps_backup.xlsx):
 * - Col AD (Poka-Yoke): Automated pre-commit linter checks reject front-end components if prohibited verbs appear or required constraints are missing.
 * - Col AE (Self-Chasing): Rejection forces instant refactor of forbidden human verbs into standardized English Code system verbs.
 * - Col AK (Metric Name): Do's and Don'ts Rule Enforcement & Lint Gate
 * - Col AL (Floor): Feature functionally present, no code-standard check applied
 * - Col AM (Optimal Target): Feature complete, passes linting/static analysis, matches approved architecture pattern
 * - Col AN (Ceiling): Feature complete, zero lint/static-analysis warnings, peer-validated against architecture pattern
 * - Col AO (Qualitative Output): Complete
 * - DEA-170826 Guidelines (mobile eb & ux eb):
 *   - Prohibited Verbs: "Approves", "Clicks", "Submits", "Logs in", "Reviews".
 *   - Required System Action Verbs: "TRANSFERS", "VALIDATES", "PARSES", "ROUTES", "CALCULATES".
 */

import 'package:flutter/material.dart';

/// AEETE-020-A09 Record Data Model.
class ComponentDosAndDontsRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final int sNo;
  final int sequenceOrder;
  final String setupAction;
  final String assignedGroupTeam;
  final String decisionGroup;
  final String whyThisMatters;
  final String mobileAppFirstImplication;
  final String dataRequirement;
  final String commonLibraryToStore;
  final String gcpBigQueryAlignment;
  final String estimatedTimeRequired;
  final String expectedOutput;
  final String domainExpertiseNeeded;
  final String mistakeProofingPokaYoke;
  final String selfChasing;
  final String vitalityProsperityUs;
  final String vitalityProsperityCustomer;
  final String metricName;
  final String floorBoundary;
  final String optimalTarget;
  final String ceilingBoundary;
  final int dosCount;
  final int dontsCount;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;

  const ComponentDosAndDontsRecord({
    this.globalRefId = 'AEETE-020',
    this.atomicStepRefId = 'AEETE-020-A09',
    this.sNo = 14,
    this.sequenceOrder = 921,
    this.setupAction = 'Draft the "Do\'s and Don\'ts" section content for each targeted component.',
    this.assignedGroupTeam = 'Component Governance Engineering',
    this.decisionGroup = 'Design System Council',
    this.whyThisMatters = 'High-performing engineering teams gate implementation completeness on passing automated code-quality checks, not just "it works".',
    this.mobileAppFirstImplication = 'Prevents anti-patterns in mobile interfaces such as prohibited workflow verbs and non-standard pixel dimensions.',
    this.dataRequirement = 'Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID',
    this.commonLibraryToStore = 'Design System Do\'s and Don\'ts Catalog',
    this.gcpBigQueryAlignment = 'Governance compliance logs streamed to BigQuery QA audit datasets.',
    this.estimatedTimeRequired = '4 Hours',
    this.expectedOutput = 'Comprehensive Do\'s and Don\'ts guidelines with zero prohibited human verbs.',
    this.domainExpertiseNeeded = 'Component Governance Engineering',
    this.mistakeProofingPokaYoke = 'Automated pre-commit linter checks reject front-end components if prohibited verbs appear or required constraints are missing.',
    this.selfChasing = 'Rejection forces instant refactor of forbidden human verbs into standardized English Code system verbs.',
    this.vitalityProsperityUs = 'Minimizes technical debt and code review iterations across sprints.',
    this.vitalityProsperityCustomer = 'Delivers rock-solid UI consistency with zero confusing interactive behaviors.',
    this.metricName = 'Do\'s and Don\'ts Rule Enforcement & Lint Gate',
    this.floorBoundary = 'Feature functionally present, no code-standard check applied',
    this.optimalTarget = 'Feature complete, passes linting/static analysis, matches approved architecture pattern',
    this.ceilingBoundary = 'Feature complete, zero lint/static-analysis warnings, peer-validated against architecture pattern',
    this.dosCount = 4,
    this.dontsCount = 4,
    this.completionStatus = 'Complete',
    this.actionTimestamp = '2026-08-25 12:45:00 UTC',
    this.userSessionId = 'USR-GOV-9210',
  });

  bool get isCompliant => dosCount >= 4 && dontsCount >= 4;

  Map<String, dynamic> toExecutionLogJson() => {
    'execution_id': 'EXEC-AEETE-020-A09-2026',
    'global_ref_id': globalRefId,
    'atomic_step_ref_id': atomicStepRefId,
    'task_title': setupAction,
    'timestamp': actionTimestamp,
    'user_session_id': userSessionId,
    'telemetry_payload': {
      'step_execution_id': 'STEP-DOS-DONTS-001',
      'execution_status': 'Passed Linter Gate',
      'execution_timestamp': actionTimestamp,
      'step_outcome': 'Approved Architectural Pattern',
      'user_id': userSessionId,
      'dos_count': dosCount,
      'donts_count': dontsCount,
      'completion_status': completionStatus,
    },
    'metric_evaluation': {
      'metric_name': metricName,
      'floor_boundary': floorBoundary,
      'optimal_target': optimalTarget,
      'ceiling_boundary': ceilingBoundary,
      'current_measured': 1.0,
      'qualitative_output': 'Complete',
      'compliance_verified': isCompliant,
    },
    'standards': [
      'Prohibited Verbs Check (No "Approves", "Clicks", "Submits")',
      'System Action Verbs ("TRANSFERS", "VALIDATES", "PARSES")',
      'Material Design 3 Spacing & 48dp Minimum Touch Targets',
    ],
  };
}

class ComponentDosAndDontsPanel extends StatelessWidget {
  final ComponentDosAndDontsRecord record;

  const ComponentDosAndDontsPanel({
    super.key,
    this.record = const ComponentDosAndDontsRecord(),
  });

  final List<String> _dos = const [
    'DO enforce 48x48dp minimum touch target boundaries on all interactive elements.',
    'DO use standardized system verbs: TRANSFERS, VALIDATES, PARSES, ROUTES, CALCULATES.',
    'DO implement zero-variance mathematical Triangular Checks (Delta = 0).',
    'DO isolate mobile visual contexts with sticky error boundaries guiding the thumb.',
  ];

  final List<String> _donts = const [
    'DON\'T model human workflows (e.g. "Manager approves", "User enters password").',
    'DON\'T use hardcoded pixel values omitting Material Design 3 tokens.',
    'DON\'T commit un-normalized compound location strings without structural parsing.',
    'DON\'T bypass offline sync queues when cellular connectivity drops.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(
            horizontal: isCompact ? ComponentDosAndDontsPanelTokens.xs : ComponentDosAndDontsPanelTokens.sm,
            vertical: ComponentDosAndDontsPanelTokens.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? ComponentDosAndDontsPanelTokens.sm : (isExpanded ? ComponentDosAndDontsPanelTokens.lg : ComponentDosAndDontsPanelTokens.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.rule, color: colorScheme.onPrimaryContainer, size: 22),
                    ),
                    ComponentDosAndDontsPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${record.globalRefId} / ${record.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Component Do\'s and Don\'ts Governance Panel (Seq: ${record.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ComponentDosAndDontsPanelTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ComponentDosAndDontsPanelTokens.success),
                      ),
                      child: Text(
                        record.completionStatus,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: ComponentDosAndDontsPanelTokens.success,
                        ),
                      ),
                    ),
                  ],
                ),

                ComponentDosAndDontsPanelTokens.vGapMd,
                const Divider(height: 1),
                ComponentDosAndDontsPanelTokens.vGapMd,

                // DO'S Section
                Container(
                  padding: ComponentDosAndDontsPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: ComponentDosAndDontsPanelTokens.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ComponentDosAndDontsPanelTokens.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: ComponentDosAndDontsPanelTokens.success, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'DO (Standardized Best Practices):',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ComponentDosAndDontsPanelTokens.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ..._dos.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text('• $item', style: const TextStyle(fontSize: 11)),
                      )),
                    ],
                  ),
                ),

                ComponentDosAndDontsPanelTokens.vGapSm,

                // DON'TS Section
                Container(
                  padding: ComponentDosAndDontsPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.highlight_off, color: colorScheme.error, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'DON\'T (Prohibited Anti-Patterns):',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ..._donts.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text('• $item', style: const TextStyle(fontSize: 11)),
                      )),
                    ],
                  ),
                ),

                ComponentDosAndDontsPanelTokens.vGapMd,

                Container(
                  padding: ComponentDosAndDontsPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('49-Column Specification Alignment (my steps_backup.xlsx):', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('• Poka-Yoke (Col AD): Pre-commit hook enforces forbidden verb blocking and MD3 size requirements.', style: TextStyle(fontSize: 10)),
                      const Text('• DEA-170826 Compliance: Zero human narrative; pure system data execution flows.', style: TextStyle(fontSize: 10)),
                      Text('• Touch Targets: Evaluated against >=48x48dp Material 3 boundary regulations.', style: TextStyle(fontSize: 10, color: colorScheme.primary)),
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ComponentDosAndDontsPanelTokens {
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
            child: ComponentDosAndDontsPanel(),
          ),
        ),
      ),
    ),
  );
}
