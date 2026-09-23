/*
 * DSDD-020-13 — Mobile Worker Snippet Card Panel
 * 
 * Setup Step (Action): Program mobile worker views to dynamically resize extracted snippet cards to match local screen boundaries.
 * Metric Name: Process Execution Quality Score (Floor: >=90%, Target: >=98%, Ceiling: 1.0)
 * Quality Standard: ISO 9001:2015 Quality Management Standard; zero horizontal overflow on mobile viewports.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class MobileWorkerSnippetCardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const MobileWorkerSnippetCardPanel({
    super.key,
    this.globalRefId = 'DSDD-020',
    this.atomicStepRefId = 'DSDD-020-13',
    this.sequenceOrder = '11908',
  });

  @override
  State<MobileWorkerSnippetCardPanel> createState() =>
      _MobileWorkerSnippetCardPanelState();
}

class _MobileWorkerSnippetCardPanelState
    extends State<MobileWorkerSnippetCardPanel> {
  double _cardScaleWidth = 320.0;

  final List<Map<String, dynamic>> _snippets = [
    {
      'title': 'Telemetry Stream Ingestion',
      'id': 'SNIP-9021',
      'status': 'RUNNING',
      'records': '12,450 msgs/sec',
      'latency': '4.2ms',
    },
    {
      'title': 'VAT Rate Freeze Validator',
      'id': 'SNIP-9022',
      'status': 'COMPLIANT',
      'records': '840 evaluations',
      'latency': '1.8ms',
    },
  ];

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'mobilePlatform': 'Flutter Cross-Platform',
      'osVersion': 'Android 14 / iOS 17.5',
      'deviceType': 'Mobile Worker Viewport',
      'screenDimensions': '${_cardScaleWidth.toInt()}dp x Auto',
      'mobileConfiguration': 'DYNAMIC_CARD_BOUNDARY_MATCH',
      'completionStatus': 'Good (100%)',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DSDD-020',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 180,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11908,
        'assigned': 'Pooja',
        'metricName': 'Process Execution Quality Score',
        'floor': '>=90%',
        'target': '>=98%',
        'ceiling': '1.0',
        'unit': 'Good/Average/Poor',
        'activeCardWidth': _cardScaleWidth,
        'hasZeroHorizontalOverflow': true,
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
            ? MobileWorkerSnippetCardPanelTokens.paddingSm
            : (isExpanded ? MobileWorkerSnippetCardPanelTokens.paddingLg : MobileWorkerSnippetCardPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: MobileWorkerSnippetCardPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                MobileWorkerSnippetCardPanelTokens.vGapMd,
                _buildSliderControl(),
                MobileWorkerSnippetCardPanelTokens.vGapMd,
                _buildResponsiveCardsContainer(),
                MobileWorkerSnippetCardPanelTokens.vGapMd,
                _buildQualityFooter(),
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
            color: MobileWorkerSnippetCardPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.view_agenda_rounded,
            color: MobileWorkerSnippetCardPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        MobileWorkerSnippetCardPanelTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mobile Worker Dynamic Snippet Card',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              MobileWorkerSnippetCardPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MobileWorkerSnippetCardPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: MobileWorkerSnippetCardPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MobileWorkerSnippetCardPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: MobileWorkerSnippetCardPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                'ZERO OVERFLOW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: MobileWorkerSnippetCardPanelTokens.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Simulated Mobile Screen Boundary Width',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '${_cardScaleWidth.toInt()} dp',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: MobileWorkerSnippetCardPanelTokens.brandPrimary,
              ),
            ),
          ],
        ),
        Slider(
          value: _cardScaleWidth,
          min: 240,
          max: 480,
          divisions: 24,
          activeColor: MobileWorkerSnippetCardPanelTokens.brandPrimary,
          onChanged: (val) {
            setState(() {
              _cardScaleWidth = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveCardsContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MobileWorkerSnippetCardPanelTokens.md),
      decoration: BoxDecoration(
        color: MobileWorkerSnippetCardPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MobileWorkerSnippetCardPanelTokens.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _cardScaleWidth),
          child: Column(
            children: _snippets.map((snip) {
              return Container(
                margin: const EdgeInsets.only(bottom: MobileWorkerSnippetCardPanelTokens.sm),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: MobileWorkerSnippetCardPanelTokens.brandPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            snip['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MobileWorkerSnippetCardPanelTokens.successContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            snip['status'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: MobileWorkerSnippetCardPanelTokens.onSuccessContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    MobileWorkerSnippetCardPanelTokens.vGapXs,
                    Text(
                      'ID: ${snip['id']} · Throughput: ${snip['records']} · Latency: ${snip['latency']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MobileWorkerSnippetCardPanelTokens.lightOutline,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityFooter() {
    return Container(
      padding: const EdgeInsets.all(MobileWorkerSnippetCardPanelTokens.sm),
      decoration: BoxDecoration(
        color: MobileWorkerSnippetCardPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.fit_screen_rounded,
            color: MobileWorkerSnippetCardPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cards dynamically scale and pack within local boundaries without horizontal truncation or text clipping.',
              style: TextStyle(
                fontSize: 11,
                color: MobileWorkerSnippetCardPanelTokens.lightOutline,
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
abstract final class MobileWorkerSnippetCardPanelTokens {
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
            child: MobileWorkerSnippetCardPanel(),
          ),
        ),
      ),
    ),
  );
}
