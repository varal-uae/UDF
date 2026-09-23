/*
 * CSIVW-002-A08 — Strict Text Field Length Validator
 * 
 * Setup Step (Action): Implement length validation on all text fields — reject input beyond the maximum character limit.
 * Metric Name: Implementation Completeness Against Spec (Floor: 90%, Target: 98%, Ceiling: 100%)
 * Quality Standard: Build tasks in a sprint-based delivery model are tracked to completion against spec. Zero character overflow beyond limit.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldLengthValidatorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const TextFieldLengthValidatorPanel({
    super.key,
    this.globalRefId = 'CSIVW-002',
    this.atomicStepRefId = 'CSIVW-002-A08',
    this.sequenceOrder = '8968',
  });

  @override
  State<TextFieldLengthValidatorPanel> createState() =>
      _TextFieldLengthValidatorPanelState();
}

class _TextFieldLengthValidatorPanelState
    extends State<TextFieldLengthValidatorPanel> {
  final TextEditingController _textController =
      TextEditingController(text: 'Loyalty Reward Voucher - Corporate VIP Class');
  final int _maxChars = 60;
  final double _completenessRate = 1.0; // 100%

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _remainingChars => _maxChars - _textController.text.length;

  Color _getCounterColor(ColorScheme colorScheme) {
    if (_remainingChars < 5) return TextFieldLengthValidatorPanelTokens.lightError;
    if (_remainingChars < 15) return TextFieldLengthValidatorPanelTokens.warning;
    return colorScheme.onSurfaceVariant;
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': 'COMPLIANT_LENGTH_ENFORCED',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'ZERO_LENGTH_VIOLATION',
      'userId': 'USER-AUTO-B15',
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 149,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Implementation Completeness Against Spec',
        'floor': '90%',
        'target': '98%',
        'ceiling': '100%',
        'unit': 'Complete (Scale: Complete/Partial/Not Complete)',
        'completenessRate': _completenessRate,
        'maxAllowedChars': _maxChars,
        'currentLength': _textController.text.length,
        'remainingCapacity': _remainingChars,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final counterColor = _getCounterColor(colorScheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? TextFieldLengthValidatorPanelTokens.paddingSm
            : (isExpanded ? TextFieldLengthValidatorPanelTokens.paddingLg : TextFieldLengthValidatorPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: TextFieldLengthValidatorPanelTokens.brandPrimary.withValues(alpha: 0.3),
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
                        color: TextFieldLengthValidatorPanelTokens.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.text_fields_rounded,
                        color: TextFieldLengthValidatorPanelTokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    TextFieldLengthValidatorPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: TextFieldLengthValidatorPanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Text Field Length Validator (Seq: ${widget.sequenceOrder})',
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
                        color: TextFieldLengthValidatorPanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Complete (Max 60)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: TextFieldLengthValidatorPanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFieldLengthValidatorPanelTokens.vGapMd,

                // Input Field with Physical Keyboard Limiting
                TextField(
                  controller: _textController,
                  maxLength: _maxChars,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxChars),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Campaign Voucher Title (Strictly Max $_maxChars Chars)',
                    hintText: 'Enter title...',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: const OutlineInputBorder(),
                    helperText: 'Physical keyboard locks when capacity reaches maximum limit',
                    counterText: '${_textController.text.length} / $_maxChars characters ($_remainingChars remaining)',
                    counterStyle: TextStyle(
                      color: counterColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                TextFieldLengthValidatorPanelTokens.vGapMd,

                // Real-time Capacity Progress Bar
                LinearProgressIndicator(
                  value: (_textController.text.length / _maxChars).clamp(0.0, 1.0),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: counterColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                TextFieldLengthValidatorPanelTokens.vGapMd,

                // Telemetry Data Card
                Container(
                  padding: TextFieldLengthValidatorPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Current Usage', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${_textController.text.length} chars', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Remaining Room', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('$_remainingChars chars', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: counterColor)),
                        ],
                      ),
                      const Column(
                        children: [
                          Text('Overflow Status', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('ZERO (Hard Gate)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TextFieldLengthValidatorPanelTokens.success)),
                        ],
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
abstract final class TextFieldLengthValidatorPanelTokens {
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
            child: TextFieldLengthValidatorPanel(),
          ),
        ),
      ),
    ),
  );
}
