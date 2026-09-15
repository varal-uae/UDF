import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 229 - FEBFL-013-A09 (Seq 15072)
/// Action: Assign the defined safe placeholder value to the form display variable if an exception is caught.
/// Metric: Process Execution Quality (%) | Target: 95% | Ceiling: 100%
/// Standard: General execution steps in mature delivery pipeline.
class SafePlaceholderAssignmentPanel extends StatefulWidget {
  const SafePlaceholderAssignmentPanel({super.key});

  @override
  State<SafePlaceholderAssignmentPanel> createState() =>
      _SafePlaceholderAssignmentPanelState();
}

class _SafePlaceholderAssignmentPanelState
    extends State<SafePlaceholderAssignmentPanel> {
  final String _stepExecutionId = 'FEBFL-013-A09-ASSIGN-001';
  final String _userSessionId = 'POOJA-FEBFL-013-A09';
  final String _completionStatus = 'Complete';
  final String _safeDefaultPlaceholder = '— (Pending Data Sync)';

  String _displayValue = '';
  String _simulatedRawInput = 'MALFORMED_JSON_STRING_NaN';
  bool _isExceptionCaught = false;
  String? _caughtExceptionDetail;
  DateTime _lastEventTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _processFieldInput(_simulatedRawInput);
  }

  void _processFieldInput(String rawInput) {
    setState(() {
      _simulatedRawInput = rawInput;
      _lastEventTimestamp = DateTime.now();
      try {
        if (rawInput.contains('MALFORMED')) {
          throw FormatException('Malformed field payload in stream: $rawInput');
        }
        _displayValue = 'Parsed Successfully: $rawInput';
        _isExceptionCaught = false;
        _caughtExceptionDetail = null;
      } catch (e) {
        // Safe placeholder assignment on caught exception
        _displayValue = _safeDefaultPlaceholder;
        _isExceptionCaught = true;
        _caughtExceptionDetail = e.toString();
      }
    });
  }

  void _simulateValidInput() {
    _processFieldInput('VALID_METRIC_VALUE_100');
  }

  void _simulateExceptionInput() {
    _processFieldInput('MALFORMED_JSON_STRING_NaN');
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Definition Name': 'Safe Placeholder Assignment Controller',
      'Definition Parameters': 'Target Field: VendorQualityScore',
      'Definition Type': 'Runtime Exception Guard & Interceptor',
      'Validation Status': _isExceptionCaught ? 'EXCEPTION_INTERCEPTED_SAFE_FALLBACK' : 'CLEAN_PAYLOAD',
      'Definition ID': _stepExecutionId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastEventTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Assigned Display Value': _displayValue,
      'Exception Interception Status': _isExceptionCaught ? 'PROTECTION_ACTIVE' : 'IDLE',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildDisplayVariableCard(),
          AppSpacingTokens.vGapMd,
          _buildSimulationControls(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Safe Placeholder Assignment Controller',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Protected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Safely catches field-level parsing exceptions in real time and automatically swaps corrupt values with the defined safe placeholder to preserve UI stability.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayVariableCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: _isExceptionCaught ? AppColorPalette.warning : AppColorPalette.success,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isExceptionCaught ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: _isExceptionCaught ? AppColorPalette.warning : AppColorPalette.success,
                  size: 20,
                ),
                AppSpacingTokens.hGapSm,
                Text(
                  _isExceptionCaught ? 'Fallback Value Assigned' : 'Normal Field Value',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isExceptionCaught ? AppColorPalette.warning : AppColorPalette.success,
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isExceptionCaught ? AppColorPalette.warningContainer.withValues(alpha: 0.2) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _isExceptionCaught ? AppColorPalette.onWarningContainer : Colors.black87,
                ),
              ),
            ),
            if (_isExceptionCaught) ...[
              AppSpacingTokens.vGapSm,
              Text(
                'Caught Exception: $_caughtExceptionDetail',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _simulateExceptionInput,
            icon: const Icon(Icons.error_outline, color: Colors.white, size: 16),
            label: const Text('Trigger Exception Input'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorPalette.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        AppSpacingTokens.hGapSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _simulateValidInput,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Supply Clean Input'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
