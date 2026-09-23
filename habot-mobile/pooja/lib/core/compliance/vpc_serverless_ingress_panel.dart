/*
 * ACRAE-025 — VPC Serverless Ingress Connector Subnet Sizing Strategy
 * 
 * Global Reference ID: ACRAE-025
 * Atomic Steps Reference ID: ACRAE-025
 * Setup Step (Action): 1. Access the interviewer mobile application.
 * Setup Step Description: Limiting access boundaries minimizes systemic blast radiuses if an individual application container is compromised.
 * S.No: 14 | Sequence Order: 421 | Assigned Team: Core Security Perimeter | Lead: Pooja
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Mobile Touch Response Time (ms)
 * - Floor Boundary: 0 ms | Optimal Target: 100 ms | Ceiling Boundary: 300 ms
 * - Best Qualitative Output: Good / Average / Poor (Best = Good)
 * - Standard: W3C Mobile Web Best Practices & ISO/IEC 25010
 * - Data Collected: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration; Completion Status; Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - 3-tier M3 responsive breakpoint adaptation: Compact (<600dp), Medium (600-839dp), Expanded (>=840dp).
 *   - Strict touch target >= 48x48dp on all triggers.
 *   - Adheres to 4px metric grid spacing tokens.
 *   - Telemetry log export via toExecutionLogJson().
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ACRAE-025 Specification Record Data Model.
class VpcServerlessIngressRecord {
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
  final String mobileFirstUxDecision;
  final String domainExpertiseNeeded;
  final String mistakeProofingPokaYoke;
  final String selfChasing;
  final String vitalityProsperityUs;
  final String vitalityProsperityCustomer;
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String bestQualitativeOutput;
  final String dataCollectedBySystem;
  final String primaryTeamAssigned;
  final String backendDataRequired;
  final double touchResponseTimeMs;
  final String completionStatus; // 'Good', 'Average', 'Poor'
  final String actionTimestamp;
  final String userSessionId;

  const VpcServerlessIngressRecord({
    this.globalRefId = 'ACRAE-025',
    this.atomicStepRefId = 'ACRAE-025',
    this.sNo = 14,
    this.sequenceOrder = 421,
    this.setupAction = 'VPC Serverless Ingress Connector Subnet Sizing Strategy.',
    this.assignedGroupTeam = 'Core Security Perimeter',
    this.decisionGroup = 'Core Security Perimeter',
    this.whyThisMatters = 'Limiting access boundaries minimizes systemic blast radiuses if an individual application container is compromised.',
    this.mobileAppFirstImplication = 'Ensures that a breach in a user-facing mobile endpoint service cannot gain administrative database access.',
    this.uxTranslation = 'Users browse secondary menu options knowing that core transaction data tiers are completely segregated.',
    this.dataRequirement = 'Atomic-level data fields: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration',
    this.userInteractionImpact = 'Isolates user actions so background tasks function under dedicated service scopes.',
    this.dashboardImplication = 'Security management metrics track role usage trends without cluttering infrastructure views.',
    this.whatStandardizedMustBeDone = 'Every Cloud Run instance must be provisioned with its own minimal IAM identity via Terraform.',
    this.atomicReusability = 'Reusable IAM modules with fine-grained access rules applied across repositories.',
    this.commonLibraryToStore = 'habot-iac-security-roles',
    this.gcpBigQueryAlignment = 'Enforced natively via Google Cloud IAM policies with metadata audits synced to BigQuery.',
    this.estimatedTimeRequired = '8 Hours',
    this.expectedOutput = 'Declarative IaC files allocating specific service identities per container.',
    this.completionMeasures = 'Running identity sweepers confirming that data-ingestion runtimes fail when attempting direct table deletions.',
    this.mobileFirstUxDecision = 'Handling security permission blocks cleanly using graceful fallback notification layouts.',
    this.domainExpertiseNeeded = 'Cloud IAM Policy Governance & Least Privilege Access Modeling',
    this.mistakeProofingPokaYoke = 'Infrastructure pipelines reject builds if any container defaults to the primitive Compute Engine service profile.',
    this.selfChasing = 'A nightly scanning daemon checks IAM changes; if an account receives unauthorized wildcard access, the policy is rolled back.',
    this.vitalityProsperityUs = 'Automates compliance audits by ensuring strict security isolation at the infrastructure tier.',
    this.vitalityProsperityCustomer = 'Provides confidence that system access controls are hardcoded to isolate personal data.',
    this.metricName = 'Mobile Touch Response Time (ms)',
    this.floorBoundary = 0.0,
    this.optimalTarget = 100.0,
    this.ceilingBoundary = 300.0,
    this.bestQualitativeOutput = 'Good',
    this.dataCollectedBySystem = 'Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration; Completion Status (Good/Average/Poor); Action/Event Timestamp; User/Session ID',
    this.primaryTeamAssigned = 'Use programmatic generation where possible; validate data integrity; implement automated checks',
    this.backendDataRequired = 'ACRAE-024-16',
    this.touchResponseTimeMs = 85.0,
    this.completionStatus = 'Good',
    required this.actionTimestamp,
    required this.userSessionId,
  });

  bool get meetsOptimalTarget => touchResponseTimeMs <= optimalTarget;

  Map<String, dynamic> toExecutionLogJson() => {
    'execution_id': 'EXEC-ACRAE-025-2026',
    'global_ref_id': globalRefId,
    'atomic_step_ref_id': atomicStepRefId,
    'task_title': 'Access the interviewer mobile application.',
    'timestamp': actionTimestamp,
    'user_session_id': userSessionId,
    'telemetry_payload': {
      'mobile_platform': 'Flutter/Android/iOS',
      'os_version': 'AOSP 14 / iOS 17',
      'device_type': 'Handheld Mobile Terminal',
      'screen_dimensions': '390x844dp @3x',
      'mobile_configuration': 'VPC-Serverless-Connector-Subnet-Sized',
      'touch_response_time_ms': touchResponseTimeMs,
      'completion_status': completionStatus,
    },
    'metric_evaluation': {
      'metric_name': metricName,
      'floor_boundary': floorBoundary,
      'optimal_target': optimalTarget,
      'ceiling_boundary': ceilingBoundary,
      'current_measured': touchResponseTimeMs,
      'qualitative_output': bestQualitativeOutput,
      'compliance_verified': meetsOptimalTarget,
    },
    'standards': [
      'W3C Mobile Web Best Practices',
      'ISO/IEC 25010 Performance Efficiency',
      'Habot Enterprise Security IAM Specification',
    ],
  };
}

enum IngressSecurityState {
  isolated('Security Perimeter Enforced (Least Privilege IAM Active)', VpcServerlessIngressPanelTokens.success, Icons.security),
  simulatedBreach('Container Breach Isolated (Database Direct Access Blocked)', VpcServerlessIngressPanelTokens.warning, Icons.shield_outlined),
  rollbackDaemon('Nightly Daemon Rollback Triggered (Wildcard IAM Revoked)', VpcServerlessIngressPanelTokens.info, Icons.autorenew);

  final String label;
  final Color color;
  final IconData icon;
  const IngressSecurityState(this.label, this.color, this.icon);
}

/// ACRAE-025 Main Component Panel Widget
class VpcServerlessIngressPanel extends StatefulWidget {
  final VpcServerlessIngressRecord record;

  const VpcServerlessIngressPanel({
    super.key,
    required this.record,
  });

  @override
  State<VpcServerlessIngressPanel> createState() => _VpcServerlessIngressPanelState();
}

class _VpcServerlessIngressPanelState extends State<VpcServerlessIngressPanel> {
  IngressSecurityState _currentState = IngressSecurityState.isolated;
  final bool _isPipelineChecked = true;
  final bool _isIaCLocked = true;
  double _simulatedLatencyMs = 85.0;

  void _triggerBreachSimulation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentState = IngressSecurityState.simulatedBreach;
      _simulatedLatencyMs = 92.0;
    });
  }

  void _triggerDaemonRollback() {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentState = IngressSecurityState.rollbackDaemon;
      _simulatedLatencyMs = 74.0;
    });
  }

  void _resetPerimeterState() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentState = IngressSecurityState.isolated;
      _simulatedLatencyMs = 85.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final record = widget.record;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;

        return Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: VpcServerlessIngressPanelTokens.sm, vertical: VpcServerlessIngressPanelTokens.xs),
          child: Padding(
            padding: VpcServerlessIngressPanelTokens.paddingMd,
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
                          Icon(Icons.lock_person_outlined, color: colorScheme.onPrimaryContainer, size: 16),
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
                    VpcServerlessIngressPanelTokens.hGapSm,
                    Expanded(
                      child: Text(
                        'VPC Serverless Ingress Connector Subnet Sizing',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.meetsOptimalTarget ? VpcServerlessIngressPanelTokens.success.withValues(alpha: 0.15) : VpcServerlessIngressPanelTokens.lightError.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        record.completionStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: record.meetsOptimalTarget ? VpcServerlessIngressPanelTokens.success : VpcServerlessIngressPanelTokens.lightError,
                        ),
                      ),
                    ),
                  ],
                ),

                VpcServerlessIngressPanelTokens.vGapSm,
                Text(
                  record.setupAction,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),

                VpcServerlessIngressPanelTokens.vGapMd,

                // Security Perimeter Status Card
                Container(
                  width: double.infinity,
                  padding: VpcServerlessIngressPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: _currentState.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _currentState.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_currentState.icon, color: _currentState.color, size: 28),
                      VpcServerlessIngressPanelTokens.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Isolation Status',
                              style: theme.textTheme.labelSmall?.copyWith(color: _currentState.color, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _currentState.label,
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                VpcServerlessIngressPanelTokens.vGapMd,

                // Metrics Row (Responsive)
                if (isCompact)
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildMetricTile(context, 'Measured Latency', '${_simulatedLatencyMs.toStringAsFixed(0)} ms', VpcServerlessIngressPanelTokens.brandPrimary),
                          _buildMetricTile(context, 'Optimal Target', '<= ${record.optimalTarget.toInt()} ms', VpcServerlessIngressPanelTokens.success),
                        ],
                      ),
                      VpcServerlessIngressPanelTokens.vGapXs,
                      Row(
                        children: [
                          _buildMetricTile(context, 'Poka-Yoke IaC', _isIaCLocked ? 'LOCKED' : 'DRIFT', VpcServerlessIngressPanelTokens.info),
                          _buildMetricTile(context, 'Nightly Daemon', _isPipelineChecked ? 'ACTIVE' : 'IDLE', VpcServerlessIngressPanelTokens.success),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      _buildMetricTile(context, 'Measured Latency', '${_simulatedLatencyMs.toStringAsFixed(0)} ms', VpcServerlessIngressPanelTokens.brandPrimary),
                      _buildMetricTile(context, 'Optimal Target', '<= ${record.optimalTarget.toInt()} ms', VpcServerlessIngressPanelTokens.success),
                      _buildMetricTile(context, 'Poka-Yoke IaC', _isIaCLocked ? 'LOCKED' : 'DRIFT', VpcServerlessIngressPanelTokens.info),
                      _buildMetricTile(context, 'Nightly Daemon', _isPipelineChecked ? 'ACTIVE' : 'IDLE', VpcServerlessIngressPanelTokens.success),
                    ],
                  ),

                VpcServerlessIngressPanelTokens.vGapMd,

                // Interactive Buttons (>= 48x48dp touch targets)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: VpcServerlessIngressPanelTokens.warning.withValues(alpha: 0.15),
                        foregroundColor: VpcServerlessIngressPanelTokens.warning,
                      ),
                      icon: const Icon(Icons.security_update_warning_outlined, size: 18),
                      label: const Text('Simulate Breach Attempt'),
                      onPressed: _triggerBreachSimulation,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: VpcServerlessIngressPanelTokens.info.withValues(alpha: 0.15),
                        foregroundColor: VpcServerlessIngressPanelTokens.info,
                      ),
                      icon: const Icon(Icons.restore_page_outlined, size: 18),
                      label: const Text('Trigger Daemon Rollback'),
                      onPressed: _triggerDaemonRollback,
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset Perimeter'),
                      onPressed: _resetPerimeterState,
                    ),
                  ],
                ),

                if (isExpanded) ...[
                  VpcServerlessIngressPanelTokens.vGapMd,
                  Container(
                    padding: VpcServerlessIngressPanelTokens.paddingSm,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Standard: ${record.dataRequirement}', style: const TextStyle(fontSize: 10)),
                        Text('Session: ${record.userSessionId}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class VpcServerlessIngressPanelTokens {
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
            child: VpcServerlessIngressPanel(
        record: VpcServerlessIngressRecord(
          actionTimestamp: '2026-08-24 15:08:00 UTC',
          userSessionId: 'USR-SEC-4219',
        ),
      ),
          ),
        ),
      ),
    ),
  );
}
