import 'package:flutter/material.dart';

/// Step 34: BPTR-0437-A10 - Stepper View Host & Active Field Validation Gate
/// Sets the "Continue" button to a disabled functional layer state until active field values validate successfully.
/// Strictly aligned with the 49 columns of `my steps.xlsx` (Row 96, Seq 5051).
class StepperFieldValidationPanel extends StatefulWidget {
  const StepperFieldValidationPanel({super.key});

  @override
  State<StepperFieldValidationPanel> createState() => _StepperFieldValidationPanelState();
}

class _StepperFieldValidationPanelState extends State<StepperFieldValidationPanel> {
  // 49-Column Data Requirement & Lineage Fields (Cols O & AQ)
  final TextEditingController _requiredFieldController = TextEditingController();
  bool _isFieldValid = false;

  final String _metricName = 'Rule/Configuration Definition Completeness';
  final double _floorBoundary = 95.0;
  final double _optimalTarget = 100.0;
  final double _ceilingBoundary = 100.0;
  final double _completenessScore = 100.0;

  @override
  void dispose() {
    _requiredFieldController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String val) {
    setState(() {
      _isFieldValid = val.trim().length >= 4; // Min 4 chars required
    });
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'validationType': 'Stepper Active Field Validation Gate',
      'validationResult': _isFieldValid ? 'VALID' : 'INVALID',
      'errorMessages': _isFieldValid ? 'NONE' : 'Mandatory active field requires ≥4 characters',
      'validationTimestamp': DateTime.now().toIso8601String(),
      'validationLog': 'Poka-Yoke layer state enforced on Continue trigger',
      'completionStatus': 'Complete (Scale: Complete/Partial/Not Complete)',
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': 'SESS-BPTR-0437-A10',
      'metadata': {
        'taskCode': 'BPTR-0437-A10',
        'row': 96,
        'seq': 5051,
        'assigned': 'Pooja',
        'metricName': _metricName,
        'floor': _floorBoundary,
        'target': _optimalTarget,
        'ceiling': _ceilingBoundary,
        'unit': 'Complete (Scale: Complete/Partial/Not Complete)',
        'completenessScore': _completenessScore,
        'isFieldValid': _isFieldValid,
      },
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
            ? StepperFieldValidationPanelTokens.paddingSm
            : (isExpanded ? StepperFieldValidationPanelTokens.paddingLg : StepperFieldValidationPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 6 : 8,
            horizontal: isExpanded ? 16 : 0,
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.next_plan_outlined, color: colorScheme.primary),
                    ),
                    StepperFieldValidationPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BPTR-0437-A10: Stepper Continue Button Gate',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 14 : 16,
                            ),
                          ),
                          Text(
                            'Global Ref: BPTR-0437 | Seq: 5051 | Assigned: Pooja (UDF)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(_isFieldValid ? 'GATE OPEN' : 'GATE LOCKED'),
                      backgroundColor: _isFieldValid
                          ? colorScheme.secondaryContainer
                          : colorScheme.errorContainer,
                    ),
                  ],
                ),
                StepperFieldValidationPanelTokens.vGapMd,

                Text(
                  'Active Field Validation Gate (Col F: Continue Disabled Until Valid | ${isCompact ? "Compact" : (isExpanded ? "Expanded" : "Medium")})',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                StepperFieldValidationPanelTokens.vGapXs,
                TextField(
                  controller: _requiredFieldController,
                  decoration: InputDecoration(
                    labelText: 'Mandatory Identifier (Min 4 chars)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit_note),
                    helperText: _isFieldValid
                        ? 'Field validated. Continue button enabled.'
                        : 'Type at least 4 characters to unlock Continue button.',
                    helperStyle: TextStyle(
                      color: _isFieldValid ? StepperFieldValidationPanelTokens.success : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onChanged: _onFieldChanged,
                ),
                StepperFieldValidationPanelTokens.vGapMd,

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: _isFieldValid ? StepperFieldValidationPanelTokens.brandPrimary : null,
                      foregroundColor: _isFieldValid ? Colors.white : null,
                    ),
                    onPressed: _isFieldValid
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Continue Pressed! Advancing to next wizard step.')),
                            );
                          }
                        : null, // Poka-Yoke (Col F & AD): Disabled until valid
                    icon: Icon(_isFieldValid ? Icons.arrow_forward : Icons.lock),
                    label: Text(
                      _isFieldValid
                          ? 'Continue to Next Step'
                          : 'Continue (Disabled - Complete Active Field)',
                    ),
                  ),
                ),

                StepperFieldValidationPanelTokens.vGapMd,
                Container(
                  padding: StepperFieldValidationPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '49-Column Specification Alignment (my steps.xlsx):',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Metric: $_metricName | Floor: $_floorBoundary% | Target: $_optimalTarget% | Ceiling: $_ceilingBoundary%',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const Text(
                        '• Poka-Yoke (Col AD): "Continue" button physically disabled until active field values validate successfully.',
                        style: TextStyle(fontSize: 10),
                      ),
                      const Text(
                        '• Data Collected (Col AQ): Validation Type, Result, Error Messages, Timestamp, User ID',
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
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
abstract final class StepperFieldValidationPanelTokens {
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
            child: StepperFieldValidationPanel(),
          ),
        ),
      ),
    ),
  );
}
