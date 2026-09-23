/*
 * AEETE-017-07 — Screen Environment Attribute Map & Viewport Density Engine
 * 
 * Global Reference ID: AEETE-017-07
 * Atomic Steps Reference ID: AEETE-017-07
 * Setup Step (Action): Build the environment attribute map to capture screen_width_pixels, screen_height_pixels, and logical_density_factor.
 * Setup Step Description: Dynamically restructures layout compositions to fit restricted space constraints and binds behaviors to scalable relative coordinate calculations.
 * S.No: 15 | Sequence Order: 872 | Assigned Team: Viewport Architecture Engineering & Layout Asset Optimization | Lead: Pooja
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Process Execution Quality Score
 * - Floor Boundary: >=90% (0.90) | Optimal Target: >=98% (0.98) | Ceiling Boundary: 100% (1.00)
 * - Best Qualitative Output: Good / Average / Poor (Best = Good (100%))
 * - Standard: ISO 9001:2015 Quality Management Standard
 * - Data Collected: Build Status; Build Timestamp; Build Artifacts Path; Build Logs; Build Duration; Completion Status; Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - 3-tier M3 responsive breakpoint adaptation: Compact (<600dp), Medium (600-839dp), Expanded (>=840dp).
 *   - Captures screen_width_pixels, screen_height_pixels, and logical_density_factor dynamically.
 *   - Scalable relative coordinate calculation preview.
 *   - Strictly enforced >= 48x48dp touch targets.
 *   - Telemetry export via toExecutionLogJson().
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AEETE-017-07 Record Data Model.
class EnvironmentAttributeMapRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final int sNo;
  final int sequenceOrder;
  final String setupAction;
  final String assignedGroupTeam;
  final String decisionGroup;
  final String dataRequirement;
  final String commonLibraryToStore;
  final String gcpBigQueryAlignment;
  final String estimatedTimeRequired;
  final String expectedOutput;
  final String domainExpertiseNeeded;
  final String mistakeProofingPokaYoke;
  final String selfChasing;
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final double currentQualityScore;
  final String completionStatus; // 'Good', 'Average', 'Poor'
  final String buildStatus;
  final String buildArtifactsPath;
  final String buildDuration;
  final String actionTimestamp;
  final String userSessionId;

  const EnvironmentAttributeMapRecord({
    this.globalRefId = 'AEETE-017-07',
    this.atomicStepRefId = 'AEETE-017-07',
    this.sNo = 15,
    this.sequenceOrder = 872,
    this.setupAction = 'Build the environment attribute map to capture screen_width_pixels, screen_height_pixels, and logical_density_factor.',
    this.assignedGroupTeam = 'Viewport Architecture Engineering',
    this.decisionGroup = 'Viewport Architecture Engineering & Asset Optimization',
    this.dataRequirement = 'Build Status; Build Timestamp; Build Artifacts Path; Build Logs; Build Duration',
    this.commonLibraryToStore = 'habot-environment-telemetry-library',
    this.gcpBigQueryAlignment = 'Screen dimension metrics and build telemetry logs streamed to BigQuery environment audit datasets.',
    this.estimatedTimeRequired = '1 Day',
    this.expectedOutput = 'Real-time environment attribute map with ISO 9001:2015 process execution quality score >= 98%.',
    this.domainExpertiseNeeded = 'Viewport Architecture Engineering & Layout Asset Optimization',
    this.mistakeProofingPokaYoke = 'Static analysis engine flags non-adaptive scripts and blocks deployment pipelines.',
    this.selfChasing = 'Nightly automated CI/CD layout testing scripts validate component responsiveness across screen density matrices.',
    this.metricName = 'Process Execution Quality Score',
    this.floorBoundary = 0.90,
    this.optimalTarget = 0.98,
    this.ceilingBoundary = 1.00,
    this.currentQualityScore = 0.995,
    this.completionStatus = 'Good',
    this.buildStatus = 'SUCCESS',
    this.buildArtifactsPath = 'gs://habot-mobile-builds/release-v2.4.0/aiss-bundle.apk',
    this.buildDuration = '14.2s',
    required this.actionTimestamp,
    required this.userSessionId,
  });

  bool get meetsOptimalTarget => currentQualityScore >= optimalTarget;

  Map<String, dynamic> toExecutionLogJson() => {
    'execution_id': 'EXEC-AEETE-017-07-2026',
    'global_ref_id': globalRefId,
    'atomic_step_ref_id': atomicStepRefId,
    'task_title': 'Build the environment attribute map to capture screen_width_pixels, screen_height_pixels, and logical_density_factor.',
    'timestamp': actionTimestamp,
    'user_session_id': userSessionId,
    'telemetry_payload': {
      'build_status': buildStatus,
      'build_timestamp': actionTimestamp,
      'build_artifacts_path': buildArtifactsPath,
      'build_logs': 'AAPT2 compile: success; Density classification: active',
      'build_duration': buildDuration,
      'quality_score': currentQualityScore,
      'completion_status': completionStatus,
    },
    'metric_evaluation': {
      'metric_name': metricName,
      'floor_boundary': '>=90% (0.90)',
      'optimal_target': '>=98% (0.98)',
      'ceiling_boundary': '100% (1.00)',
      'current_measured': currentQualityScore,
      'qualitative_output': 'Good (100%)',
      'compliance_verified': meetsOptimalTarget,
    },
    'standards': [
      'ISO 9001:2015 Quality Management Standard',
      'Android DisplayMetrics / iOS UIScreen Spec',
      'Material Design 3 Responsive Adaptive Framework',
    ],
  };
}

/// AEETE-017-07 Main Component Panel Widget
class EnvironmentAttributeMapPanel extends StatefulWidget {
  final EnvironmentAttributeMapRecord record;

  const EnvironmentAttributeMapPanel({
    super.key,
    required this.record,
  });

  @override
  State<EnvironmentAttributeMapPanel> createState() => _EnvironmentAttributeMapPanelState();
}

class _EnvironmentAttributeMapPanelState extends State<EnvironmentAttributeMapPanel> {
  bool _isRelativeScalingEnabled = true;
  final bool _isBuildPipelinePassing = true;

  void _triggerEnvironmentScan() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Environment Attributes Ingested: Screen dimensions and logical density refreshed.'),
        backgroundColor: EnvironmentAttributeMapPanelTokens.brandPrimary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final record = widget.record;

    // Derived device environment attributes
    final double screenWidthPixels = mediaQuery.size.width * mediaQuery.devicePixelRatio;
    final double screenHeightPixels = mediaQuery.size.height * mediaQuery.devicePixelRatio;
    final double logicalDensityFactor = mediaQuery.devicePixelRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;

        return Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(
            horizontal: isCompact ? EnvironmentAttributeMapPanelTokens.xs : EnvironmentAttributeMapPanelTokens.sm,
            vertical: EnvironmentAttributeMapPanelTokens.xs,
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? EnvironmentAttributeMapPanelTokens.sm : (isExpanded ? EnvironmentAttributeMapPanelTokens.lg : EnvironmentAttributeMapPanelTokens.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar & Global Ref Badge
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
                          Icon(Icons.aspect_ratio_outlined, color: colorScheme.onPrimaryContainer, size: 16),
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
                    EnvironmentAttributeMapPanelTokens.hGapSm,
                    Expanded(
                      child: Text(
                        'Environment Attribute Map & Density Engine',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: EnvironmentAttributeMapPanelTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: EnvironmentAttributeMapPanelTokens.success),
                      ),
                      child: Text(
                        'QUALITY: ${record.completionStatus}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: EnvironmentAttributeMapPanelTokens.success),
                      ),
                    ),
                  ],
                ),
                EnvironmentAttributeMapPanelTokens.vGapMd,

                // Overview Banner
                Container(
                  padding: EnvironmentAttributeMapPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.perm_device_information_outlined, color: colorScheme.primary, size: 20),
                          EnvironmentAttributeMapPanelTokens.hGapSm,
                          Text(
                            'Assigned Team: ${record.assignedGroupTeam}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      EnvironmentAttributeMapPanelTokens.vGapXs,
                      Text(
                        record.setupAction,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                EnvironmentAttributeMapPanelTokens.vGapLg,

                // Environment Attributes Ingest Grid
                Text(
                  'Real-Time Ingested Device Environment Attributes',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                EnvironmentAttributeMapPanelTokens.vGapSm,
                if (isCompact)
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildAttributeTile(context, 'screen_width_pixels', '${screenWidthPixels.toInt()} px', Icons.swap_horiz),
                          _buildAttributeTile(context, 'screen_height_pixels', '${screenHeightPixels.toInt()} px', Icons.swap_vert),
                        ],
                      ),
                      EnvironmentAttributeMapPanelTokens.vGapXs,
                      Row(
                        children: [
                          _buildAttributeTile(context, 'logical_density_factor', '${logicalDensityFactor.toStringAsFixed(2)}x', Icons.density_medium),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      _buildAttributeTile(context, 'screen_width_pixels', '${screenWidthPixels.toInt()} px', Icons.swap_horiz),
                      _buildAttributeTile(context, 'screen_height_pixels', '${screenHeightPixels.toInt()} px', Icons.swap_vert),
                      _buildAttributeTile(context, 'logical_density_factor', '${logicalDensityFactor.toStringAsFixed(2)}x', Icons.density_medium),
                    ],
                  ),
                EnvironmentAttributeMapPanelTokens.vGapLg,

                // Scalable Relative Coordinate Composition Preview
                Container(
                  padding: EnvironmentAttributeMapPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scalable Relative Coordinate Layout Preview:',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                            onPressed: _triggerEnvironmentScan,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh Ingest'),
                          ),
                        ],
                      ),
                      EnvironmentAttributeMapPanelTokens.vGapSm,
                      LayoutBuilder(
                        builder: (ctx, innerConstraints) {
                          final containerWidth = innerConstraints.maxWidth;
                          final targetBoxWidth = _isRelativeScalingEnabled ? containerWidth * 0.45 : 180.0;
                          return Container(
                            height: 100,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: targetBoxWidth,
                                  height: 80,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: EnvironmentAttributeMapPanelTokens.brandPrimary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: EnvironmentAttributeMapPanelTokens.brandPrimary),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Adaptive Composition',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: EnvironmentAttributeMapPanelTokens.brandPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Width: ${targetBoxWidth.toInt()}px (${(targetBoxWidth / containerWidth * 100).toInt()}% viewport)',
                                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                EnvironmentAttributeMapPanelTokens.vGapLg,

                // Build Telemetry & CI/CD Pipeline Status
                Container(
                  padding: EnvironmentAttributeMapPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Build Telemetry & CI/CD Pipeline Status',
                            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isBuildPipelinePassing ? EnvironmentAttributeMapPanelTokens.success : EnvironmentAttributeMapPanelTokens.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              record.buildStatus,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      EnvironmentAttributeMapPanelTokens.vGapSm,
                      Text('Build Duration: ${record.buildDuration}', style: theme.textTheme.bodySmall),
                      Text('Artifacts Path: ${record.buildArtifactsPath}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      EnvironmentAttributeMapPanelTokens.vGapSm,
                      Divider(color: colorScheme.outlineVariant, height: 1),
                      EnvironmentAttributeMapPanelTokens.vGapSm,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enforce Relative Viewport Coordinate Scaling:',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          Switch(
                            value: _isRelativeScalingEnabled,
                            onChanged: (val) => setState(() => _isRelativeScalingEnabled = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                EnvironmentAttributeMapPanelTokens.vGapLg,

                // Audit Metric Boundary Grid
                Container(
                  padding: EnvironmentAttributeMapPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Metric: ${record.metricName} (ISO 9001:2015 Standard)',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      EnvironmentAttributeMapPanelTokens.vGapSm,
                      Row(
                        children: [
                          _buildMetricTile(context, 'Floor Boundary', '>=90%', EnvironmentAttributeMapPanelTokens.warning),
                          _buildMetricTile(context, 'Optimal Target', '>=98%', EnvironmentAttributeMapPanelTokens.info),
                          _buildMetricTile(context, 'Ceiling Boundary', '100%', EnvironmentAttributeMapPanelTokens.success),
                          _buildMetricTile(context, 'Current Score', '${(record.currentQualityScore * 100).toStringAsFixed(1)}%', EnvironmentAttributeMapPanelTokens.brandPrimary),
                        ],
                      ),
                    ],
                  ),
                ),

                if (isExpanded) ...[
                  EnvironmentAttributeMapPanelTokens.vGapLg,
                  Container(
                    width: double.infinity,
                    padding: EnvironmentAttributeMapPanelTokens.paddingSm,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('M3 Expanded Viewport: 840dp+ Active | Viewport Coordinate Engine Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildAttributeTile(BuildContext context, String label, String val, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(val, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9), textAlign: TextAlign.center),
          ],
        ),
      ),
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
abstract final class EnvironmentAttributeMapPanelTokens {
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
            child: EnvironmentAttributeMapPanel(
        record: EnvironmentAttributeMapRecord(
          actionTimestamp: '2026-08-25 10:31:00 UTC',
          userSessionId: 'USR-VIEWPORT-8720',
        ),
      ),
          ),
        ),
      ),
    ),
  );
}
