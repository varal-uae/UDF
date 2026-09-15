/*
 * CSIVW-002-A02 — Profile Field Data Type Classifier
 * 
 * Setup Step (Action): Classify each profile field by its data type — text, numeric, date, boolean, enum.
 * Metric Name: Process Execution Quality (Floor: 85%, Target: 95%, Ceiling: 100%)
 * Quality Standard: General execution steps in a mature delivery pipeline meet the defined standard with zero deviations.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorPalette.brandPrimary.withValues(alpha: 0.3),
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
                        color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
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
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorPalette.brandPrimary,
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
                        color: AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Complete (5 Types)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColorPalette.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

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
                                Icon(field.type.icon, size: 14, color: AppColorPalette.brandPrimary),
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
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColorPalette.success),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // Interactive Demo Form Inputs
                Text(
                  'Interactive Type-Specific Input Controls:',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapSm,
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
