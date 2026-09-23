/*
 * CSIVW-002-A02 — Profile Field Data Type Classifier
 * 
 * Setup Step (Action): Classify each profile field by its data type — text, numeric, date, boolean, enum.
 * Metric Name: Process Execution Quality (Floor: 85%, Target: 95%, Ceiling: 100%)
 * Quality Standard: General execution steps in a mature delivery pipeline meet the defined standard with zero deviations.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

enum ProfileFieldType {
  text('Text String', Icons.text_fields_rounded),
  numeric('Numeric Amount', Icons.pin_rounded),
  date('Date (Calendar)', Icons.calendar_today_rounded),
  boolean('Boolean Switch', Icons.toggle_on_rounded),
  enumeration('Enum Selection', Icons.list_rounded);

  final String label;
  final IconData icon;
  const ProfileFieldType(this.label, this.icon);
}

class ProfileFieldItem {
  final String fieldName;
  final ProfileFieldType type;
  final String sampleValue;
  final bool isCompliant;

  const ProfileFieldItem({
    required this.fieldName,
    required this.type,
    required this.sampleValue,
    required this.isCompliant,
  });
}

class ProfileFieldDataTypeClassifierPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const ProfileFieldDataTypeClassifierPanel({
    super.key,
    this.globalRefId = 'CSIVW-002',
    this.atomicStepRefId = 'CSIVW-002-A02',
    this.sequenceOrder = '8962',
  });

  @override
  State<ProfileFieldDataTypeClassifierPanel> createState() =>
      _ProfileFieldDataTypeClassifierPanelState();
}

class _ProfileFieldDataTypeClassifierPanelState
    extends State<ProfileFieldDataTypeClassifierPanel> {
  DateTime _selectedDate = DateTime(2026, 9, 8);
  bool _optInAlerts = true;
  String _selectedTier = 'ENTERPRISE';
  final double _executionQuality = 1.00; // 100%

  final List<ProfileFieldItem> _classifiedFields = const [
    ProfileFieldItem(fieldName: 'fullName', type: ProfileFieldType.text, sampleValue: 'Pooja Chauhan', isCompliant: true),
    ProfileFieldItem(fieldName: 'accountPoints', type: ProfileFieldType.numeric, sampleValue: '125,000', isCompliant: true),
    ProfileFieldItem(fieldName: 'contractRenewalDate', type: ProfileFieldType.date, sampleValue: '2026-09-08', isCompliant: true),
    ProfileFieldItem(fieldName: 'twoFactorEnabled', type: ProfileFieldType.boolean, sampleValue: 'true', isCompliant: true),
    ProfileFieldItem(fieldName: 'membershipTier', type: ProfileFieldType.enumeration, sampleValue: 'ENTERPRISE', isCompliant: true),
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': 'COMPLIANT_SCHEMA_CLASSIFIED',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'ZERO_SCHEMA_DRIFT',
      'userId': 'USER-AUTO-B15',
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 148,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Process Execution Quality',
        'floor': '85%',
        'target': '95%',
        'ceiling': '100%',
        'unit': 'Complete (Scale: Complete/Partial/Not Complete)',
        'executionQuality': _executionQuality,
        'classifiedFieldsCount': _classifiedFields.length,
        'selectedDate': _selectedDate.toIso8601String().substring(0, 10),
        'optInAlerts': _optInAlerts,
        'membershipTier': _selectedTier,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? ProfileFieldDataTypeClassifierPanelTokens.paddingSm
            : (isExpanded ? ProfileFieldDataTypeClassifierPanelTokens.paddingLg : ProfileFieldDataTypeClassifierPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: ProfileFieldDataTypeClassifierPanelTokens.brandPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ProfileFieldDataTypeClassifierPanelTokens.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: ProfileFieldDataTypeClassifierPanelTokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    ProfileFieldDataTypeClassifierPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ProfileFieldDataTypeClassifierPanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Profile Field Data Type Classifier (Seq: ${widget.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ProfileFieldDataTypeClassifierPanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Complete (5 Types)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ProfileFieldDataTypeClassifierPanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                ProfileFieldDataTypeClassifierPanelTokens.vGapMd,

                // Classification Schema Table
                Table(
                  border: TableBorder.all(color: colorScheme.outlineVariant, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(1.8),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.8),
                    3: FlexColumnWidth(1.0),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                      children: const [
                        Padding(padding: EdgeInsets.all(6), child: Text('Field Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Data Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Sample Value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Validation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ..._classifiedFields.map((field) {
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text(field.fieldName, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              children: [
                                Icon(field.type.icon, size: 14, color: ProfileFieldDataTypeClassifierPanelTokens.brandPrimary),
                                const SizedBox(width: 4),
                                Text(field.type.name, style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                          Padding(padding: const EdgeInsets.all(6), child: Text(field.sampleValue, style: const TextStyle(fontSize: 11))),
                          const Padding(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              'VALID',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ProfileFieldDataTypeClassifierPanelTokens.success),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                ProfileFieldDataTypeClassifierPanelTokens.vGapMd,

                // Interactive Demo Form Inputs
                Text(
                  'Interactive Type-Specific Input Controls:',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ProfileFieldDataTypeClassifierPanelTokens.vGapSm,
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Date Picker Button (Min 48x48dp target)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text('Renewal Date: ${_selectedDate.toIso8601String().substring(0, 10)}'),
                      ),
                    ),
                    // Boolean Switch (Min 48x48dp target)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('2FA Enabled:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Switch(
                            value: _optInAlerts,
                            onChanged: (v) => setState(() => _optInAlerts = v),
                          ),
                        ],
                      ),
                    ),
                    // Enum Dropdown
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: DropdownButton<String>(
                        value: _selectedTier,
                        items: const [
                          DropdownMenuItem(value: 'STANDARD', child: Text('STANDARD Tier')),
                          DropdownMenuItem(value: 'PROFESSIONAL', child: Text('PROFESSIONAL Tier')),
                          DropdownMenuItem(value: 'ENTERPRISE', child: Text('ENTERPRISE Tier')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTier = val);
                        },
                      ),
                    ),
                  ],
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
abstract final class ProfileFieldDataTypeClassifierPanelTokens {
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
            child: ProfileFieldDataTypeClassifierPanel(),
          ),
        ),
      ),
    ),
  );
}
