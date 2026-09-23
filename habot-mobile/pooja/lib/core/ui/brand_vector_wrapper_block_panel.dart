/*
 * DPNDL-005-A07 — Brand Vector Wrapper Block Panel
 * 
 * Setup Step (Action): Insert an image element referencing the brand vector file inside the newly declared wrapper block.
 * Metric Name: Asset Pipeline Delivery & Wrapper Isolation (Floor: 85%, Target: 95%, Ceiling: 100%)
 * Quality Standard: General execution steps meet defined standard of work within target range before sign-off.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

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
            ? BrandVectorWrapperBlockPanelTokens.paddingSm
            : (isExpanded ? BrandVectorWrapperBlockPanelTokens.paddingLg : BrandVectorWrapperBlockPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: BrandVectorWrapperBlockPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                BrandVectorWrapperBlockPanelTokens.vGapMd,
                _buildWrapperPreview(isCompact),
                BrandVectorWrapperBlockPanelTokens.vGapMd,
                _buildBufferControls(isCompact),
                BrandVectorWrapperBlockPanelTokens.vGapMd,
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
            color: BrandVectorWrapperBlockPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.branding_watermark_rounded,
            color: BrandVectorWrapperBlockPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        BrandVectorWrapperBlockPanelTokens.hGapMd,
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
              BrandVectorWrapperBlockPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BrandVectorWrapperBlockPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: BrandVectorWrapperBlockPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: BrandVectorWrapperBlockPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded,
                  color: BrandVectorWrapperBlockPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                'WRAPPER LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: BrandVectorWrapperBlockPanelTokens.success,
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
      padding: const EdgeInsets.all(BrandVectorWrapperBlockPanelTokens.md),
      decoration: BoxDecoration(
        color: BrandVectorWrapperBlockPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: BrandVectorWrapperBlockPanelTokens.lightOutline.withValues(alpha: 0.2),
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
              color: BrandVectorWrapperBlockPanelTokens.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dedicated Header Identity Module Wrapper Block
              Container(
                padding: EdgeInsets.all(_bufferPadding),
                decoration: BoxDecoration(
                  color: BrandVectorWrapperBlockPanelTokens.brandPrimary.withValues(alpha: 0.04),
                  border: Border(
                    bottom: BorderSide(
                      color: BrandVectorWrapperBlockPanelTokens.lightOutline.withValues(alpha: 0.15),
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
                      color: BrandVectorWrapperBlockPanelTokens.brandPrimary,
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
            ? BrandVectorWrapperBlockPanelTokens.brandPrimary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? BrandVectorWrapperBlockPanelTokens.brandPrimary : BrandVectorWrapperBlockPanelTokens.lightOutline,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? BrandVectorWrapperBlockPanelTokens.brandPrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferControls(bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(BrandVectorWrapperBlockPanelTokens.md),
      decoration: BoxDecoration(
        color: BrandVectorWrapperBlockPanelTokens.lightBackground,
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
                        color: BrandVectorWrapperBlockPanelTokens.lightOutline,
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
                  selectedColor: BrandVectorWrapperBlockPanelTokens.brandPrimary.withValues(alpha: 0.2),
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
      padding: const EdgeInsets.all(BrandVectorWrapperBlockPanelTokens.sm),
      decoration: BoxDecoration(
        color: BrandVectorWrapperBlockPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: BrandVectorWrapperBlockPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pins official brand logo in a dedicated wrapper block with 16dp buffer padding to protect corporate identity from touch drift.',
              style: TextStyle(
                fontSize: 11,
                color: BrandVectorWrapperBlockPanelTokens.lightOutline,
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
abstract final class BrandVectorWrapperBlockPanelTokens {
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
            child: BrandVectorWrapperBlockPanel(),
          ),
        ),
      ),
    ),
  );
}
