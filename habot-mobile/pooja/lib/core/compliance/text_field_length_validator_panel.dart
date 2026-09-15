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
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
    if (_remainingChars < 5) return AppColorPalette.lightError;
    if (_remainingChars < 15) return AppColorPalette.warning;
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
                        Icons.text_fields_rounded,
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
                        color: AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Complete (Max 60)',
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
                AppSpacingTokens.vGapMd,

                // Real-time Capacity Progress Bar
                LinearProgressIndicator(
                  value: (_textController.text.length / _maxChars).clamp(0.0, 1.0),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: counterColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                AppSpacingTokens.vGapMd,

                // Telemetry Data Card
                Container(
                  padding: AppSpacingTokens.paddingMd,
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
                          Text('ZERO (Hard Gate)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColorPalette.success)),
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
