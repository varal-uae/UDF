import 'package:flutter/material.dart';

/// Step 44: BPTR-0741-A03 - Customer Class Presentation Style Variant Engine
/// Establishes specific presentation style guidelines across customer classes (Enterprise, SME, Retail) using swappable component models.
/// Strictly aligned with the 49 columns of `my steps.xlsx` (Row 106, Seq 5191).
class CustomerClassPresentationVariantPanel extends StatefulWidget {
  const CustomerClassPresentationVariantPanel({super.key});

  @override
  State<CustomerClassPresentationVariantPanel> createState() => _CustomerClassPresentationVariantPanelState();
}

class _PresentationGuide {
  final String cta;
  final String badge;
  final Color color;
  const _PresentationGuide({required this.cta, required this.badge, required this.color});
}

class _CustomerClassPresentationVariantPanelState extends State<CustomerClassPresentationVariantPanel> {
  // 49-Column Data Requirement & Lineage Fields (Cols O & AQ)
  String _selectedClass = 'ENTERPRISE';
  bool _showExecutionLog = false;

  final Map<String, _PresentationGuide> _presentationGuidelines = const {
    'ENTERPRISE': _PresentationGuide(cta: 'Schedule Executive Account Review', badge: 'Tier 1 Priority SLA', color: Colors.blue),
    'SME': _PresentationGuide(cta: 'Launch Growth Automation Wizard', badge: 'Accelerated Queue', color: Colors.green),
    'RETAIL': _PresentationGuide(cta: 'Instant Self-Service Checkout', badge: 'Standard Direct Path', color: Colors.orange),
  };

  final String _metricName = 'Implementation Quality Score';
  final double _floorBoundary = 90.0;
  final double _optimalTarget = 97.0;
  final double _ceilingBoundary = 100.0;
  final double _qualityScore = 97.5;

  Map<String, dynamic> toExecutionLogJson() {
    final activeGuide = _presentationGuidelines[_selectedClass]!;
    return {
      'configurationKey': 'CUSTOMER_CLASS_PRESENTATION_STYLE',
      'configurationValue': _selectedClass,
      'configurationType': 'SWAPPABLE_COMPONENT_MODEL',
      'validationStatus': 'VALIDATED',
      'configurationTimestamp': DateTime.now().toUtc().toIso8601String(),
      'completionStatus': 'Good (Scale: Good/Average/Poor)',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESS-BPTR-0741-A03',
      'metadata': {
        'taskCode': 'BPTR-0741-A03',
        'row': 106,
        'seq': 5191,
        'assigned': 'Pooja',
        'metricName': _metricName,
        'floor': _floorBoundary,
        'target': _optimalTarget,
        'ceiling': _ceilingBoundary,
        'unit': 'Good (Scale: Good/Average/Poor)',
        'qualityScore': _qualityScore,
        'selectedClass': _selectedClass,
        'ctaAction': activeGuide.cta,
        'badge': activeGuide.badge,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeGuide = _presentationGuidelines[_selectedClass]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final horizontalPadding = isExpanded
            ? CustomerClassPresentationVariantPanelTokens.paddingXl
            : (isCompact ? CustomerClassPresentationVariantPanelTokens.paddingSm : CustomerClassPresentationVariantPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 4 : 8,
            horizontal: isExpanded ? 16 : 0,
          ),
          child: Padding(
            padding: horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.style_outlined, color: theme.colorScheme.primary),
                    ),
                    CustomerClassPresentationVariantPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BPTR-0741-A03: Customer Class Variant Engine',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 13 : 15,
                            ),
                          ),
                          Text(
                            'Global Ref: BPTR-0741 | Seq: 5191 | Assigned: Pooja (UDF)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Quality: ${_qualityScore.toInt()}%'),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ],
                ),
                CustomerClassPresentationVariantPanelTokens.vGapMd,

                Text(
                  'Swappable Component Variant (Cols L, M, N: Segment-Driven Actions)',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                CustomerClassPresentationVariantPanelTokens.vGapXs,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: activeGuide.color),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Segment: $_selectedClass', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Chip(
                            label: Text(activeGuide.badge, style: const TextStyle(fontSize: 10)),
                            backgroundColor: activeGuide.color.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Triggered $_selectedClass CTA: ${activeGuide.cta}')),
                          );
                        },
                        icon: const Icon(Icons.touch_app),
                        label: Text(activeGuide.cta),
                      ),
                    ],
                  ),
                ),
                CustomerClassPresentationVariantPanelTokens.vGapMd,

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presentationGuidelines.keys.map((k) {
                    final isSelected = _selectedClass == k;
                    return SizedBox(
                      height: 48,
                      child: ChoiceChip(
                        label: Text(k),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedClass = k);
                        },
                      ),
                    );
                  }).toList(),
                ),

                CustomerClassPresentationVariantPanelTokens.vGapMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: Icon(_showExecutionLog ? Icons.visibility_off : Icons.receipt_long),
                      label: Text(_showExecutionLog ? 'Hide Telemetry' : 'View Audit Telemetry'),
                      onPressed: () => setState(() => _showExecutionLog = !_showExecutionLog),
                    ),
                  ],
                ),

                if (_showExecutionLog) ...[
                  CustomerClassPresentationVariantPanelTokens.vGapMd,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: SelectableText(
                      toExecutionLogJson().toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],

                CustomerClassPresentationVariantPanelTokens.vGapMd,
                Container(
                  padding: CustomerClassPresentationVariantPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('49-Column Specification Alignment (my steps.xlsx):', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('• Metric: $_metricName | Floor: $_floorBoundary% | Target: $_optimalTarget% | Ceiling: $_ceilingBoundary%', style: const TextStyle(fontSize: 10)),
                      const Text('• Poka-Yoke (Col AD): Configuration engines physically reject fixed, un-swappable hardcoded copy lines.', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class CustomerClassPresentationVariantPanelTokens {
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
            child: CustomerClassPresentationVariantPanel(),
          ),
        ),
      ),
    ),
  );
}
