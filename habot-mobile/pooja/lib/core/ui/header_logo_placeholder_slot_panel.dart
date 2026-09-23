/*
 * DPNDL-011-A06 — Header Logo Placeholder Slot Panel
 * 
 * Setup Step (Action): Insert an icon placeholder slot on the left boundary edge for site logos.
 * Metric Name: UI/UX Design-System Consistency (%) (Floor: 90%, Target: 97%, Ceiling: 100%)
 * Quality Standard: Interactive UI elements held to adherence range against approved design system.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

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
            ? HeaderLogoPlaceholderSlotPanelTokens.paddingSm
            : (isExpanded ? HeaderLogoPlaceholderSlotPanelTokens.paddingLg : HeaderLogoPlaceholderSlotPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: HeaderLogoPlaceholderSlotPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                HeaderLogoPlaceholderSlotPanelTokens.vGapMd,
                _buildHeaderBarSimulation(isCompact),
                HeaderLogoPlaceholderSlotPanelTokens.vGapMd,
                _buildSlotControls(),
                HeaderLogoPlaceholderSlotPanelTokens.vGapMd,
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
            color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.web_asset_rounded,
            color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        HeaderLogoPlaceholderSlotPanelTokens.hGapMd,
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
              HeaderLogoPlaceholderSlotPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HeaderLogoPlaceholderSlotPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: HeaderLogoPlaceholderSlotPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: HeaderLogoPlaceholderSlotPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: HeaderLogoPlaceholderSlotPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                '64DP BAR VALIDATED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: HeaderLogoPlaceholderSlotPanelTokens.success,
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
      padding: const EdgeInsets.all(HeaderLogoPlaceholderSlotPanelTokens.md),
      decoration: BoxDecoration(
        color: HeaderLogoPlaceholderSlotPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HeaderLogoPlaceholderSlotPanelTokens.lightOutline.withValues(alpha: 0.2),
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
              color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary.withValues(alpha: 0.25),
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
                  color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary.withValues(alpha: 0.4),
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
                          color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary,
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
                        color: HeaderLogoPlaceholderSlotPanelTokens.lightOutline,
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
      padding: const EdgeInsets.all(HeaderLogoPlaceholderSlotPanelTokens.sm),
      decoration: BoxDecoration(
        color: HeaderLogoPlaceholderSlotPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: HeaderLogoPlaceholderSlotPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Enforces strict 64dp vertical layout limit and pins dedicated icon placeholder slot on left boundary edge for site logos.',
              style: TextStyle(
                fontSize: 11,
                color: HeaderLogoPlaceholderSlotPanelTokens.lightOutline,
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
abstract final class HeaderLogoPlaceholderSlotPanelTokens {
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
            child: HeaderLogoPlaceholderSlotPanel(),
          ),
        ),
      ),
    ),
  );
}
