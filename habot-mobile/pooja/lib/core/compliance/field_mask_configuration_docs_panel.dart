/*
 * DRVUT-007-A17 — Field Mask Configuration Documentation Panel
 * 
 * Setup Step (Action): Document the mask configurations for each field type.
 * Metric Name: Documentation Completeness (Floor: Informal notes, Target: Structured docs in KB, Ceiling: Published, versioned & reviewed)
 * Quality Standard: Documentation treated as a reviewed deliverable with structured schemas and regex examples.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class FieldMaskConfigurationDocsPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const FieldMaskConfigurationDocsPanel({
    super.key,
    this.globalRefId = 'DRVUT-007',
    this.atomicStepRefId = 'DRVUT-007-A17',
    this.sequenceOrder = '11541',
  });

  @override
  State<FieldMaskConfigurationDocsPanel> createState() =>
      _FieldMaskConfigurationDocsPanelState();
}

class _FieldMaskConfigurationDocsPanelState
    extends State<FieldMaskConfigurationDocsPanel> {
  final List<Map<String, String>> _maskSchemas = [
    {
      'type': 'UAE Mobile Phone',
      'mask': '+971 (##) ###-####',
      'regex': r'^\+971\s\(5[0-9]\)\s[0-9]{3}-[0-9]{4}$',
      'example': '+971 (50) 123-4567',
    },
    {
      'type': 'Credit Card Number',
      'mask': '#### #### #### ####',
      'regex': r'^[0-9]{4}\s[0-9]{4}\s[0-9]{4}\s[0-9]{4}$',
      'example': '4532 8901 2345 6789',
    },
    {
      'type': 'Tax Registration (TRN)',
      'mask': '###-####-####-###',
      'regex': r'^[0-9]{3}-[0-9]{4}-[0-9]{4}-[0-9]{3}$',
      'example': '100-2345-6789-003',
    },
    {
      'type': 'Standard Date (ISO)',
      'mask': 'YYYY-MM-DD',
      'regex': r'^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$',
      'example': '2026-09-09',
    },
  ];

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'configurationKey': 'FIELD_MASK_SCHEMA_REGISTRY',
      'configurationValue': 'DOCS_V2_PUBLISHED',
      'configurationType': 'STRUCTURED_SCHEMA_DOCUMENTATION',
      'validationStatus': 'PEER_REVIEWED_LOCKED',
      'configurationTimestamp': DateTime.now().toUtc().toIso8601String(),
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DRVUT-007',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 177,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11541,
        'assigned': 'Pooja',
        'metricName': 'Documentation Completeness',
        'floor': 'Informal notes only',
        'target': 'Structured documentation in KB',
        'ceiling': 'Published, versioned & peer-reviewed',
        'unit': 'Complete',
        'documentedSchemasCount': _maskSchemas.length,
        'isPeerReviewed': true,
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
            ? FieldMaskConfigurationDocsPanelTokens.paddingSm
            : (isExpanded ? FieldMaskConfigurationDocsPanelTokens.paddingLg : FieldMaskConfigurationDocsPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: FieldMaskConfigurationDocsPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                FieldMaskConfigurationDocsPanelTokens.vGapMd,
                _buildMaskDocItems(isCompact),
                FieldMaskConfigurationDocsPanelTokens.vGapMd,
                _buildAuditDeliverableFooter(),
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
            color: FieldMaskConfigurationDocsPanelTokens.lightSecondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: FieldMaskConfigurationDocsPanelTokens.lightSecondary,
            size: 24,
          ),
        ),
        FieldMaskConfigurationDocsPanelTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Mask Configuration Documentation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              FieldMaskConfigurationDocsPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FieldMaskConfigurationDocsPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FieldMaskConfigurationDocsPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FieldMaskConfigurationDocsPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded,
                  color: FieldMaskConfigurationDocsPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                'KB PUBLISHED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FieldMaskConfigurationDocsPanelTokens.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaskDocItems(bool isCompact) {
    return Column(
      children: _maskSchemas.map((schema) {
        return Container(
          margin: const EdgeInsets.only(bottom: FieldMaskConfigurationDocsPanelTokens.sm),
          padding: const EdgeInsets.all(FieldMaskConfigurationDocsPanelTokens.md),
          decoration: BoxDecoration(
            color: FieldMaskConfigurationDocsPanelTokens.lightBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FieldMaskConfigurationDocsPanelTokens.lightOutline.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    schema['type']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: FieldMaskConfigurationDocsPanelTokens.brandPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      schema['mask']!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: FieldMaskConfigurationDocsPanelTokens.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              FieldMaskConfigurationDocsPanelTokens.vGapXs,
              Text(
                'Pattern Regex: ${schema['regex']!}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: FieldMaskConfigurationDocsPanelTokens.lightOutline,
                ),
              ),
              Text(
                'Valid Input Example: ${schema['example']!}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAuditDeliverableFooter() {
    return Container(
      padding: const EdgeInsets.all(FieldMaskConfigurationDocsPanelTokens.sm),
      decoration: BoxDecoration(
        color: FieldMaskConfigurationDocsPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: FieldMaskConfigurationDocsPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Treats documentation as a versioned, peer-reviewed engineering deliverable published in the knowledge base.',
              style: TextStyle(
                fontSize: 11,
                color: FieldMaskConfigurationDocsPanelTokens.lightOutline,
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
abstract final class FieldMaskConfigurationDocsPanelTokens {
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
            child: FieldMaskConfigurationDocsPanel(),
          ),
        ),
      ),
    ),
  );
}
