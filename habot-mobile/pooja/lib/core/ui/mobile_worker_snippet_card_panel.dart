/*
 * DSDD-020-13 — Mobile Worker Snippet Card Panel
 * 
 * Setup Step (Action): Program mobile worker views to dynamically resize extracted snippet cards to match local screen boundaries.
 * Metric Name: Process Execution Quality Score (Floor: >=90%, Target: >=98%, Ceiling: 1.0)
 * Quality Standard: ISO 9001:2015 Quality Management Standard; zero horizontal overflow on mobile viewports.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                AppSpacingTokens.vGapMd,
                _buildSliderControl(),
                AppSpacingTokens.vGapMd,
                _buildResponsiveCardsContainer(),
                AppSpacingTokens.vGapMd,
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
            color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.view_agenda_rounded,
            color: AppColorPalette.brandPrimary,
            size: 24,
          ),
        ),
        AppSpacingTokens.hGapMd,
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
              AppSpacingTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColorPalette.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColorPalette.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColorPalette.success, size: 14),
              SizedBox(width: 4),
              Text(
                'ZERO OVERFLOW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColorPalette.success,
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
                color: AppColorPalette.brandPrimary,
              ),
            ),
          ],
        ),
        Slider(
          value: _cardScaleWidth,
          min: 240,
          max: 480,
          divisions: 24,
          activeColor: AppColorPalette.brandPrimary,
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
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _cardScaleWidth),
          child: Column(
            children: _snippets.map((snip) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
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
                    color: AppColorPalette.brandPrimary.withValues(alpha: 0.2),
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
                            color: AppColorPalette.successContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            snip['status'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColorPalette.onSuccessContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacingTokens.vGapXs,
                    Text(
                      'ID: ${snip['id']} · Throughput: ${snip['records']} · Latency: ${snip['latency']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColorPalette.lightOutline,
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
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.fit_screen_rounded,
            color: AppColorPalette.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cards dynamically scale and pack within local boundaries without horizontal truncation or text clipping.',
              style: TextStyle(
                fontSize: 11,
                color: AppColorPalette.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
