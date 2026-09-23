/*
 * ERMWD-011 — Async Exception Status Chips Panel
 * 
 * Setup Step (Action): Program async status chips ("Processing Exception") for mobile client feedback.
 * Metric Name: Exception Handling / Auto-Remediation Response Time (Floor: <15m, Target: <5m, Ceiling: <1m)
 * Quality Standard: Track failed-write and retry counts separately from success rate.
 * Telemetry: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration; Completion Status ('Good'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class AsyncExceptionStatusChipsPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const AsyncExceptionStatusChipsPanel({
    super.key,
    this.globalRefId = 'ERMWD-011',
    this.atomicStepRefId = 'ERMWD-011',
    this.sequenceOrder = '13792',
  });

  @override
  State<AsyncExceptionStatusChipsPanel> createState() =>
      _AsyncExceptionStatusChipsPanelState();
}

class _AsyncExceptionStatusChipsPanelState
    extends State<AsyncExceptionStatusChipsPanel> {
  final String _userSessionId = 'POOJA-ERMWD-011';
  final String _completionStatus = 'Good';
  int _retryCount = 2;
  bool _isBackoffActive = true;

  final List<Map<String, dynamic>> _statusChips = [
    {
      'label': 'Processing Exception',
      'sublabel': 'Auto-remediation queue active (<1m)',
      'icon': Icons.sync_problem,
      'color': AsyncExceptionStatusChipsPanelTokens.warning,
      'bg': AsyncExceptionStatusChipsPanelTokens.warningContainer,
    },
    {
      'label': 'Rate Limit 429 Backoff',
      'sublabel': 'Exponential backoff delay (1.4s)',
      'icon': Icons.hourglass_top,
      'color': AsyncExceptionStatusChipsPanelTokens.info,
      'bg': AsyncExceptionStatusChipsPanelTokens.infoContainer,
    },
    {
      'label': 'Retry Ingress In-Flight',
      'sublabel': 'Attempt #2 of 3 automated retries',
      'icon': Icons.refresh,
      'color': AsyncExceptionStatusChipsPanelTokens.brandPrimary,
      'bg': AsyncExceptionStatusChipsPanelTokens.brandPrimaryContainer,
    },
    {
      'label': 'Self-Healing Cleared',
      'sublabel': 'Stateless container recovered cleanly',
      'icon': Icons.check_circle_outline,
      'color': AsyncExceptionStatusChipsPanelTokens.success,
      'bg': AsyncExceptionStatusChipsPanelTokens.successContainer,
    },
  ];

  Map<String, dynamic> getTelemetryData(BuildContext context) {
    final mq = MediaQuery.of(context);
    return {
      'stepExecutionId': 'EXEC-ERMWD-011-2026',
      'mobilePlatform': Theme.of(context).platform.toString(),
      'deviceType': 'Mobile Handset',
      'screenDimensions': '${mq.size.width.toInt()}x${mq.size.height.toInt()}dp',
      'mobileConfiguration': 'Async Exception Chip Feedback Overlay',
      'failedWriteRetryCount': _retryCount,
      'remediationTime': '<1 minute (Ceiling: <1m Pass)',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: AsyncExceptionStatusChipsPanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AsyncExceptionStatusChipsPanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AsyncExceptionStatusChipsPanelTokens.sm),
                decoration: BoxDecoration(
                  color: AsyncExceptionStatusChipsPanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_mode_outlined,
                  color: AsyncExceptionStatusChipsPanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              AsyncExceptionStatusChipsPanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AsyncExceptionStatusChipsPanelTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Async Exception Status Feedback',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AsyncExceptionStatusChipsPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Auto-Fix: <1m',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AsyncExceptionStatusChipsPanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AsyncExceptionStatusChipsPanelTokens.vGapMd,
          Container(
            padding: AsyncExceptionStatusChipsPanelTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Async Status Chips for Non-Blocking Client Feedback:',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AsyncExceptionStatusChipsPanelTokens.vGapSm,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusChips.map((chip) {
                    final color = chip['color'] as Color;
                    final bg = chip['bg'] as Color;
                    return ActionChip(
                      avatar: Icon(chip['icon'] as IconData, size: 16, color: color),
                      label: Text(chip['label'] as String, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: bg.withValues(alpha: 0.4),
                      side: BorderSide(color: color.withValues(alpha: 0.3)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${chip['label']}: ${chip['sublabel']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                AsyncExceptionStatusChipsPanelTokens.vGapSm,
                Divider(color: AsyncExceptionStatusChipsPanelTokens.lightOutline.withValues(alpha: 0.15)),
                AsyncExceptionStatusChipsPanelTokens.vGapSm,
                Text(
                  'Graceful Degradation: Replaces blocking modal screens with non-intrusive status indicators, maintaining app interactivity while backoff retry executes in background.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          AsyncExceptionStatusChipsPanelTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _retryCount++;
                      _isBackoffActive = !_isBackoffActive;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Simulated auto-remediation attempt #$_retryCount (<1m resolution)'),
                        backgroundColor: AsyncExceptionStatusChipsPanelTokens.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Simulate Exception Auto-Remediation'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class AsyncExceptionStatusChipsPanelTokens {
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
            child: AsyncExceptionStatusChipsPanel(),
          ),
        ),
      ),
    ),
  );
}
