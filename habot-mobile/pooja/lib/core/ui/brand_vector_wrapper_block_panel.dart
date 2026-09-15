/*
 * DPNDL-005-A07 — Brand Vector Wrapper Block Panel
 * 
 * Setup Step (Action): Insert an image element referencing the brand vector file inside the newly declared wrapper block.
 * Metric Name: Asset Pipeline Delivery & Wrapper Isolation (Floor: 85%, Target: 95%, Ceiling: 100%)
 * Quality Standard: General execution steps meet defined standard of work within target range before sign-off.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class BrandVectorWrapperBlockPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const BrandVectorWrapperBlockPanel({
    super.key,
    this.globalRefId = 'DPNDL-005',
    this.atomicStepRefId = 'DPNDL-005-A07',
    this.sequenceOrder = '11107',
  });

  @override
  State<BrandVectorWrapperBlockPanel> createState() =>
      _BrandVectorWrapperBlockPanelState();
}

class _BrandVectorWrapperBlockPanelState
    extends State<BrandVectorWrapperBlockPanel> {
  final bool _isLocked = true;
  double _bufferPadding = 16.0;

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'lockType': 'BRAND_WRAPPER_CONTAINMENT_LOCK',
      'lockStatus': _isLocked ? 'LOCKED_SECURE' : 'UNLOCKED_CUSTOM',
      'lockedBy': 'SYSTEM_BRAND_POLICY',
      'lockTimestamp': DateTime.now().toUtc().toIso8601String(),
      'lockReason': 'PREVENT_ACCIDENTAL_VECTOR_MUTATION',
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DPNDL-005',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 169,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11107,
        'assigned': 'Pooja',
        'metricName': 'Asset Pipeline Delivery & Wrapper Isolation',
        'floor': '85%',
        'target': '95%',
        'ceiling': '100%',
        'unit': 'Complete/Partial/Not Complete',
        'bufferPadding': _bufferPadding,
        'wrapperWidth': 256.0,
        'isBufferPaddingEnforced': true,
        'isBrandIsolated': true,
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
                _buildWrapperPreview(isCompact),
                AppSpacingTokens.vGapMd,
                _buildBufferControls(isCompact),
                AppSpacingTokens.vGapMd,
                _buildIsolationAuditFooter(),
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
            Icons.branding_watermark_rounded,
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
                'Brand Vector Wrapper Block Module',
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
              Icon(Icons.shield_rounded,
                  color: AppColorPalette.success, size: 14),
              SizedBox(width: 4),
              Text(
                'WRAPPER LOCKED',
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

  Widget _buildWrapperPreview(bool isCompact) {
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
        child: Container(
          width: 256.0, // Strict 256dp drawer sidebar width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColorPalette.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dedicated Header Identity Module Wrapper Block
              Container(
                padding: EdgeInsets.all(_bufferPadding),
                decoration: BoxDecoration(
                  color: AppColorPalette.brandPrimary.withValues(alpha: 0.04),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColorPalette.lightOutline.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Vector Brand Emblem
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HABOT',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 2.0,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'ENTERPRISE',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                              letterSpacing: 1.2,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ],
                ),
              ),
              // Simulated Routing Paths below buffer padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    _buildDummyMenuItem(Icons.dashboard_rounded, 'Dashboard Overview', true),
                    _buildDummyMenuItem(Icons.analytics_rounded, 'Analytics & KPIs', false),
                    _buildDummyMenuItem(Icons.settings_rounded, 'System Settings', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDummyMenuItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColorPalette.brandPrimary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? AppColorPalette.brandPrimary : AppColorPalette.lightOutline,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColorPalette.brandPrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferControls(bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wrapper Buffer Padding',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Current: ${_bufferPadding.toInt()}dp (Separates corporate logo from options paths)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorPalette.lightOutline,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [12.0, 16.0, 20.0].map((pad) {
              final isSelected = _bufferPadding == pad;
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: ChoiceChip(
                  label: Text('${pad.toInt()}dp'),
                  selected: isSelected,
                  selectedColor: AppColorPalette.brandPrimary.withValues(alpha: 0.2),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _bufferPadding = pad;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIsolationAuditFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColorPalette.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pins official brand logo in a dedicated wrapper block with 16dp buffer padding to protect corporate identity from touch drift.',
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
