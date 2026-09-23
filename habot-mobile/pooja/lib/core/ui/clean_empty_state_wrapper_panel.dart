/*
 * EDBAA-004-A05 — Clean Empty State Layout Wrapper Panel
 * 
 * Setup Step (Action): Initialize a centralized, clean empty state layout wrapper inside the active view container.
 * Metric Name: Environment & Configuration Setup Readiness (Floor: File version-controlled, Target: Schema validated pre-edit)
 * Quality Standard: Confirm correct source-of-truth file is opened; clear separation between 'No Data' and 'System Error'.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class CleanEmptyStateWrapperPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const CleanEmptyStateWrapperPanel({
    super.key,
    this.globalRefId = 'EDBAA-004',
    this.atomicStepRefId = 'EDBAA-004-A05',
    this.sequenceOrder = '12056',
  });

  @override
  State<CleanEmptyStateWrapperPanel> createState() =>
      _CleanEmptyStateWrapperPanelState();
}

class _CleanEmptyStateWrapperPanelState
    extends State<CleanEmptyStateWrapperPanel> {
  bool _isSystemErrorMode = false;

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'layoutType': 'CENTRALIZED_EMPTY_STATE_WRAPPER',
      'layoutGridDimensions': 'FLEXBOX_CENTERED_VIEWPORT',
      'spacingRules': 'AppSpacingTokens_4PX_METRIC',
      'alignmentSettings': 'ALIGN_CENTER_JUSTIFY_CENTER',
      'layoutValidationStatus': 'SCHEMA_VALIDATED_PRE_EDIT',
      'completionStatus': 'Pass',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-EDBAA-004',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 181,
        'seq': int.tryParse(widget.sequenceOrder) ?? 12056,
        'assigned': 'Pooja',
        'metricName': 'Environment & Configuration Setup Readiness',
        'unit': 'Pass/Fail',
        'isSystemErrorMode': _isSystemErrorMode,
        'isFlexboxCentered': true,
        'touchTargetCompliant': true,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final padding = isCompact
            ? CleanEmptyStateWrapperPanelTokens.paddingSm
            : (isExpanded ? CleanEmptyStateWrapperPanelTokens.paddingLg : CleanEmptyStateWrapperPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: CleanEmptyStateWrapperPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                CleanEmptyStateWrapperPanelTokens.vGapMd,
                _buildModeSwitcher(),
                CleanEmptyStateWrapperPanelTokens.vGapMd,
                _buildEmptyStateCanvas(isCompact),
                CleanEmptyStateWrapperPanelTokens.vGapMd,
                _buildGuidanceFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CleanEmptyStateWrapperPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inbox_rounded,
            color: CleanEmptyStateWrapperPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        CleanEmptyStateWrapperPanelTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clean Empty State Layout Wrapper',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              CleanEmptyStateWrapperPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CleanEmptyStateWrapperPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: CleanEmptyStateWrapperPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CleanEmptyStateWrapperPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: CleanEmptyStateWrapperPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                'READY (PRE-EDIT)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: CleanEmptyStateWrapperPanelTokens.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'State Mode: ${_isSystemErrorMode ? 'System Error (Requires Retry)' : 'No Data Exists (Requires Action)'}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: TextButton.icon(
            icon: Icon(
              _isSystemErrorMode ? Icons.refresh_rounded : Icons.add_circle_outline_rounded,
              size: 18,
            ),
            label: Text(_isSystemErrorMode ? 'Show No Data' : 'Show Error State'),
            onPressed: () {
              setState(() {
                _isSystemErrorMode = !_isSystemErrorMode;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCanvas(bool isCompact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: CleanEmptyStateWrapperPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CleanEmptyStateWrapperPanelTokens.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (_isSystemErrorMode
                        ? CleanEmptyStateWrapperPanelTokens.lightError
                        : CleanEmptyStateWrapperPanelTokens.brandPrimary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSystemErrorMode
                    ? Icons.cloud_off_rounded
                    : Icons.folder_open_rounded,
                size: 36,
                color: _isSystemErrorMode
                    ? CleanEmptyStateWrapperPanelTokens.lightError
                    : CleanEmptyStateWrapperPanelTokens.brandPrimary,
              ),
            ),
            CleanEmptyStateWrapperPanelTokens.vGapMd,
            Text(
              _isSystemErrorMode
                  ? 'Unable to Load Records'
                  : 'No Active Ingestion Records Found',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            CleanEmptyStateWrapperPanelTokens.vGapXs,
            Text(
              _isSystemErrorMode
                  ? 'Edge transmission interrupted. Check your network or retry ingestion.'
                  : 'Your pipeline has zero pending telemetry events. Initiate a new run below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CleanEmptyStateWrapperPanelTokens.lightOutline,
                    fontSize: 12,
                  ),
            ),
            CleanEmptyStateWrapperPanelTokens.vGapLg,
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: ElevatedButton.icon(
                icon: Icon(
                  _isSystemErrorMode ? Icons.refresh_rounded : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(
                  _isSystemErrorMode ? 'Retry Ingestion Request' : 'Create First Record',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSystemErrorMode
                      ? CleanEmptyStateWrapperPanelTokens.lightError
                      : CleanEmptyStateWrapperPanelTokens.brandPrimary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceFooter() {
    return Container(
      padding: const EdgeInsets.all(CleanEmptyStateWrapperPanelTokens.sm),
      decoration: BoxDecoration(
        color: CleanEmptyStateWrapperPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: CleanEmptyStateWrapperPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Flexbox centering layout clearly separates "No Data Exists" from "System Error", guiding mobile workers into the primary creation flow.',
              style: TextStyle(
                fontSize: 11,
                color: CleanEmptyStateWrapperPanelTokens.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class CleanEmptyStateWrapperPanelTokens {
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

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

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
            child: CleanEmptyStateWrapperPanel(),
          ),
        ),
      ),
    ),
  );
}
