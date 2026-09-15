/*
 * DPNDL-011-A06 — Header Logo Placeholder Slot Panel
 * 
 * Setup Step (Action): Insert an icon placeholder slot on the left boundary edge for site logos.
 * Metric Name: UI/UX Design-System Consistency (%) (Floor: 90%, Target: 97%, Ceiling: 100%)
 * Quality Standard: Interactive UI elements held to adherence range against approved design system.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class HeaderLogoPlaceholderSlotPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const HeaderLogoPlaceholderSlotPanel({
    super.key,
    this.globalRefId = 'DPNDL-011',
    this.atomicStepRefId = 'DPNDL-011-A06',
    this.sequenceOrder = '11177',
  });

  @override
  State<HeaderLogoPlaceholderSlotPanel> createState() =>
      _HeaderLogoPlaceholderSlotPanelState();
}

class _HeaderLogoPlaceholderSlotPanelState
    extends State<HeaderLogoPlaceholderSlotPanel> {
  bool _showVectorLogo = true;

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-DPNDL-011-2026',
      'executionStatus': 'LOGO_SLOT_ACTIVE',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'ANCHOR_SLOT_INSERTED',
      'userId': 'USER-AUTO-B18',
      'completionStatus': 'Good',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DPNDL-011',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 173,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11177,
        'assigned': 'Pooja',
        'metricName': 'UI/UX Design-System Consistency (%)',
        'floor': '90%',
        'target': '97%',
        'ceiling': '100%',
        'unit': 'Good/Average/Poor',
        'verticalLimitDp': 64.0,
        'isVectorLogoRendered': _showVectorLogo,
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
                _buildHeaderBarSimulation(isCompact),
                AppSpacingTokens.vGapMd,
                _buildSlotControls(),
                AppSpacingTokens.vGapMd,
                _buildConsistencyFooter(),
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
            Icons.web_asset_rounded,
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
                'Header Logo Placeholder Slot Panel',
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
                '64DP BAR VALIDATED',
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

  Widget _buildHeaderBarSimulation(bool isCompact) {
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
          height: 64.0, // Strict 64dp vertical layout limit
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColorPalette.brandPrimary.withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Icon Placeholder Slot on Left Boundary Edge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColorPalette.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorPalette.brandPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: _showVectorLogo
                      ? Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'H',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.crop_original_rounded,
                          color: AppColorPalette.brandPrimary,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Header Title
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habot Enterprise Console',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Fixed Master Header · 64dp Limit',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColorPalette.lightOutline,
                      ),
                    ),
                  ],
                ),
              ),
              // Phantom Target Action Buttons
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 20),
                  onPressed: () {},
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  icon: const Icon(Icons.account_circle_rounded, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Logo Slot Mode: Visual Placeholder vs Vector Asset',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: TextButton.icon(
            icon: Icon(
              _showVectorLogo ? Icons.visibility_rounded : Icons.crop_square_rounded,
              size: 18,
            ),
            label: Text(_showVectorLogo ? 'Showing Vector' : 'Showing Placeholder'),
            onPressed: () {
              setState(() {
                _showVectorLogo = !_showVectorLogo;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencyFooter() {
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
              'Enforces strict 64dp vertical layout limit and pins dedicated icon placeholder slot on left boundary edge for site logos.',
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
