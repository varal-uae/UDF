import 'package:flutter/material.dart';

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
      padding: SafePlaceholderAssignmentPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          SafePlaceholderAssignmentPanelTokens.vGapMd,
          _buildDisplayVariableCard(),
          SafePlaceholderAssignmentPanelTokens.vGapMd,
          _buildSimulationControls(),
          SafePlaceholderAssignmentPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: SafePlaceholderAssignmentPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: SafePlaceholderAssignmentPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: SafePlaceholderAssignmentPanelTokens.brandPrimary,
                  size: 22,
                ),
                SafePlaceholderAssignmentPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Safe Placeholder Assignment Controller',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SafePlaceholderAssignmentPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlaceholderAssignmentPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Protected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SafePlaceholderAssignmentPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            SafePlaceholderAssignmentPanelTokens.vGapSm,
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
          color: _isExceptionCaught ? SafePlaceholderAssignmentPanelTokens.warning : SafePlaceholderAssignmentPanelTokens.success,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: SafePlaceholderAssignmentPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isExceptionCaught ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: _isExceptionCaught ? SafePlaceholderAssignmentPanelTokens.warning : SafePlaceholderAssignmentPanelTokens.success,
                  size: 20,
                ),
                SafePlaceholderAssignmentPanelTokens.hGapSm,
                Text(
                  _isExceptionCaught ? 'Fallback Value Assigned' : 'Normal Field Value',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isExceptionCaught ? SafePlaceholderAssignmentPanelTokens.warning : SafePlaceholderAssignmentPanelTokens.success,
                  ),
                ),
              ],
            ),
            SafePlaceholderAssignmentPanelTokens.vGapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isExceptionCaught ? SafePlaceholderAssignmentPanelTokens.warningContainer.withValues(alpha: 0.2) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _isExceptionCaught ? SafePlaceholderAssignmentPanelTokens.onWarningContainer : Colors.black87,
                ),
              ),
            ),
            if (_isExceptionCaught) ...[
              SafePlaceholderAssignmentPanelTokens.vGapSm,
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
              backgroundColor: SafePlaceholderAssignmentPanelTokens.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SafePlaceholderAssignmentPanelTokens.hGapSm,
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
        side: BorderSide(color: SafePlaceholderAssignmentPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: SafePlaceholderAssignmentPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: SafePlaceholderAssignmentPanelTokens.brandPrimary,
              ),
            ),
            SafePlaceholderAssignmentPanelTokens.vGapSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class SafePlaceholderAssignmentPanelTokens {
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
            child: SafePlaceholderAssignmentPanel(),
          ),
        ),
      ),
    ),
  );
}
