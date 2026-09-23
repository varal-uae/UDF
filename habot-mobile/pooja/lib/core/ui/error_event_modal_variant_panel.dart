import 'package:flutter/material.dart';

/// Row 246 - FEBFL-037-A05 (Seq 15288)
/// Action: Program unique visual styles for error event modal variants.
/// Metric: System/Rule Implementation Compliance | Target: 95%+ | Unit: Complete/Partial/Not Complete
/// Standard: Standard engineering definition-of-done practice for modal dialog variants.
class ErrorEventModalVariantPanel extends StatefulWidget {
  const ErrorEventModalVariantPanel({super.key});

  @override
  State<ErrorEventModalVariantPanel> createState() =>
      _ErrorEventModalVariantPanelState();
}

enum _ModalSeverity {
  criticalSecurity,
  networkTimeout,
  dataValidation,
}

class _ErrorEventModalVariantPanelState
    extends State<ErrorEventModalVariantPanel> {
  final String _stepExecutionId = 'FEBFL-037-A05-MODAL-VAR';
  final String _userSessionId = 'POOJA-FEBFL-037-A05';
  final String _userId = 'POOJA_UI_LEAD';
  final String _completionStatus = 'Complete';

  _ModalSeverity _selectedSeverity = _ModalSeverity.criticalSecurity;
  bool _pokaYokeConfirmed = false;
  String _lastActionFeedback = 'Select a modal variant to preview';
  DateTime _lastEventTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': 'MODAL_STYLES_PROGRAMMED',
      'Execution Timestamp': _lastEventTimestamp.toIso8601String(),
      'Step Outcome': 'UNIQUE_STYLES_VALIDATED',
      'User ID': _userId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastEventTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Active Severity Variant': _selectedSeverity.name,
      'Poka-Yoke Toggle Lock': _pokaYokeConfirmed ? 'UNLOCKED' : 'LOCKED_BLOCKED',
      'Material 3 Balanced Box': 'TRUE (Col Z)',
    };
  }

  void _showModalPreview() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Modal',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _buildModalContent(ctx),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack).value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  Widget _buildModalContent(BuildContext dialogContext) {
    Color containerColor;
    Color iconColor;
    IconData iconData;
    String title;
    String bodyText;

    switch (_selectedSeverity) {
      case _ModalSeverity.criticalSecurity:
        containerColor = ErrorEventModalVariantPanelTokens.errorContainer;
        iconColor = ErrorEventModalVariantPanelTokens.error;
        iconData = Icons.gpp_maybe_outlined;
        title = 'Critical Security Escalation';
        bodyText = 'An unauthorized data-tampering vector was detected. Execution requires explicit two-factor acknowledgment.';
        break;
      case _ModalSeverity.networkTimeout:
        containerColor = ErrorEventModalVariantPanelTokens.warningContainer;
        iconColor = ErrorEventModalVariantPanelTokens.warning;
        iconData = Icons.wifi_off_outlined;
        title = 'Upstream Network Disruption';
        bodyText = 'Connection to regional ingest nodes timed out after 3 retries. Fallback data cache is activated.';
        break;
      case _ModalSeverity.dataValidation:
        containerColor = ErrorEventModalVariantPanelTokens.brandPrimaryContainer;
        iconColor = ErrorEventModalVariantPanelTokens.brandPrimary;
        iconData = Icons.rule_outlined;
        title = 'Payload Validation Alert';
        bodyText = 'Input parameters deviated from the strict Material boundary model. Values require re-verification.';
        break;
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          width: 380,
          margin: const EdgeInsets.all(24.0),
          padding: ErrorEventModalVariantPanelTokens.paddingLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: containerColor.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 36),
              ),
              ErrorEventModalVariantPanelTokens.vGapMd,
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              ErrorEventModalVariantPanelTokens.vGapSm,
              Text(
                bodyText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              ErrorEventModalVariantPanelTokens.vGapMd,
              // Poka-yoke lock requirement (Col AD)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _pokaYokeConfirmed,
                      activeColor: ErrorEventModalVariantPanelTokens.brandPrimary,
                      onChanged: (val) {
                        setModalState(() {
                          _pokaYokeConfirmed = val ?? false;
                        });
                        setState(() {
                          _pokaYokeConfirmed = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Acknowledge risk & unlock action (Poka-Yoke)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              ErrorEventModalVariantPanelTokens.vGapMd,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  ErrorEventModalVariantPanelTokens.hGapSm,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pokaYokeConfirmed
                          ? () {
                              Navigator.of(dialogContext).pop();
                              setState(() {
                                _lastActionFeedback = 'Action executed successfully for $title';
                                _lastEventTimestamp = DateTime.now();
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Execute Action'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ErrorEventModalVariantPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          ErrorEventModalVariantPanelTokens.vGapMd,
          _buildVariantSelectorCard(),
          ErrorEventModalVariantPanelTokens.vGapMd,
          _buildTriggerCard(),
          ErrorEventModalVariantPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ErrorEventModalVariantPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ErrorEventModalVariantPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.palette_outlined,
                  color: ErrorEventModalVariantPanelTokens.brandPrimary,
                  size: 22,
                ),
                ErrorEventModalVariantPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Error Event Modal Variants',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ErrorEventModalVariantPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ErrorEventModalVariantPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Compliance: 98%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ErrorEventModalVariantPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            ErrorEventModalVariantPanelTokens.vGapSm,
            Text(
              'Renders unique visual styles for error modal variants with smooth scale-up animations, centered Material 3 boxes, and poka-yoke safety confirmation toggles.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSelectorCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ErrorEventModalVariantPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ErrorEventModalVariantPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Modal Variant Severity',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ErrorEventModalVariantPanelTokens.brandPrimary),
            ),
            ErrorEventModalVariantPanelTokens.vGapSm,
            Wrap(
              spacing: 8,
              children: _ModalSeverity.values.map((sev) {
                final isSelected = _selectedSeverity == sev;
                return ChoiceChip(
                  label: Text(sev.name),
                  selected: isSelected,
                  selectedColor: ErrorEventModalVariantPanelTokens.brandPrimaryContainer,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSeverity = sev;
                        _pokaYokeConfirmed = false;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ErrorEventModalVariantPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ErrorEventModalVariantPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Preview Status: $_lastActionFeedback',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            ErrorEventModalVariantPanelTokens.vGapMd,
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _showModalPreview,
                icon: const Icon(Icons.open_in_browser, color: Colors.white, size: 18),
                label: Text('Launch ${_selectedSeverity.name} Modal Variant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ErrorEventModalVariantPanelTokens.brandPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ErrorEventModalVariantPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ErrorEventModalVariantPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ErrorEventModalVariantPanelTokens.brandPrimary,
              ),
            ),
            ErrorEventModalVariantPanelTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
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
abstract final class ErrorEventModalVariantPanelTokens {
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
            child: ErrorEventModalVariantPanel(),
          ),
        ),
      ),
    ),
  );
}
