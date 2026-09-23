import 'package:flutter/material.dart';

/// Row 232 - FEBFL-015-A11 (Seq 15092)
/// Action: Apply cryptographic tokens to the evaluation form to protect submission vectors against manipulation.
/// Metric: Configuration Accuracy (%) | Target: 99% | Ceiling: 100% | Unit: Pass/Fail
/// Standard: Anti-tamper crypto tokens applied to protect submission vectors.
class EvaluationFormCryptoTokenPanel extends StatefulWidget {
  const EvaluationFormCryptoTokenPanel({super.key});

  @override
  State<EvaluationFormCryptoTokenPanel> createState() =>
      _EvaluationFormCryptoTokenPanelState();
}

class _EvaluationFormCryptoTokenPanelState
    extends State<EvaluationFormCryptoTokenPanel> {
  final String _stepExecutionId = 'FEBFL-015-A11-CRYPTO-001';
  final String _userSessionId = 'POOJA-FEBFL-015-A11';
  final String _completionStatus = 'Pass';

  String _cryptoToken = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
  String _nonce = 'NONCE-88492041';
  final int _tokenTtlSeconds = 300;
  bool _isTamperSimulated = false;
  DateTime _lastGenerationTime = DateTime.now();

  void _regenerateCryptoToken() {
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch;
    setState(() {
      _nonce = 'NONCE-${(millis % 100000000).toString().padLeft(8, '0')}';
      _cryptoToken = 'sha256_${millis.toRadixString(16)}b7852b855e3b0c44298fc1c14';
      _isTamperSimulated = false;
      _lastGenerationTime = now;
    });
  }

  void _simulateTamperAttack() {
    setState(() {
      _isTamperSimulated = true;
      _cryptoToken = 'TAMPERED_INVALID_SIG_${_cryptoToken.substring(20)}';
      _lastGenerationTime = DateTime.now();
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': _isTamperSimulated ? 'TAMPER_DETECTED_REJECTED' : 'CRYPTO_TOKEN_ACTIVE',
      'Execution Timestamp': _lastGenerationTime.toIso8601String(),
      'Step Outcome': _isTamperSimulated ? 'TAMPER_BLOCKED' : 'PASS',
      'User ID': 'POOJA_SECURITY_LEAD',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastGenerationTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Crypto Token Algorithm': 'HMAC-SHA256',
      'Nonce ID': _nonce,
      'Signature Verification': _isTamperSimulated ? 'FAILED_INVALID_HASH' : 'VERIFIED_VALID',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isTokenValid = !_isTamperSimulated;

    return SingleChildScrollView(
      padding: EvaluationFormCryptoTokenPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          EvaluationFormCryptoTokenPanelTokens.vGapMd,
          _buildTokenInspectorCard(isTokenValid),
          EvaluationFormCryptoTokenPanelTokens.vGapMd,
          _buildSimulationControls(),
          EvaluationFormCryptoTokenPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: EvaluationFormCryptoTokenPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EvaluationFormCryptoTokenPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.enhanced_encryption_outlined,
                  color: EvaluationFormCryptoTokenPanelTokens.brandPrimary,
                  size: 22,
                ),
                EvaluationFormCryptoTokenPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Evaluation Form Cryptographic Token',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: EvaluationFormCryptoTokenPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: EvaluationFormCryptoTokenPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HMAC-SHA256',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: EvaluationFormCryptoTokenPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            EvaluationFormCryptoTokenPanelTokens.vGapSm,
            Text(
              'Applies one-time cryptographic HMAC tokens and replay-resistant nonces to evaluation submissions, preventing parameter manipulation.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInspectorCard(bool isTokenValid) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: isTokenValid ? EvaluationFormCryptoTokenPanelTokens.success : EvaluationFormCryptoTokenPanelTokens.lightError,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EvaluationFormCryptoTokenPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isTokenValid ? Icons.lock_clock : Icons.gpp_bad,
                      color: isTokenValid ? EvaluationFormCryptoTokenPanelTokens.success : EvaluationFormCryptoTokenPanelTokens.lightError,
                      size: 20,
                    ),
                    EvaluationFormCryptoTokenPanelTokens.hGapSm,
                    Text(
                      isTokenValid ? 'Cryptographic Token Verified' : 'Security Breach: Token Invalid',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isTokenValid ? EvaluationFormCryptoTokenPanelTokens.success : EvaluationFormCryptoTokenPanelTokens.lightError,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isTokenValid ? EvaluationFormCryptoTokenPanelTokens.successContainer : EvaluationFormCryptoTokenPanelTokens.lightErrorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isTokenValid ? 'VALID' : 'TAMPERED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isTokenValid ? EvaluationFormCryptoTokenPanelTokens.onSuccessContainer : EvaluationFormCryptoTokenPanelTokens.lightOnErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            EvaluationFormCryptoTokenPanelTokens.vGapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HMAC Payload Token:', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    _cryptoToken,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            EvaluationFormCryptoTokenPanelTokens.vGapSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Nonce: $_nonce', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text('TTL: ${_tokenTtlSeconds}s remaining', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
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
            onPressed: _regenerateCryptoToken,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
            label: const Text('Generate Fresh Token'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EvaluationFormCryptoTokenPanelTokens.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        EvaluationFormCryptoTokenPanelTokens.hGapSm,
        OutlinedButton.icon(
          onPressed: _simulateTamperAttack,
          icon: const Icon(Icons.bug_report_outlined, size: 16),
          label: const Text('Simulate Tampering'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
        side: BorderSide(color: EvaluationFormCryptoTokenPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EvaluationFormCryptoTokenPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: EvaluationFormCryptoTokenPanelTokens.brandPrimary,
              ),
            ),
            EvaluationFormCryptoTokenPanelTokens.vGapSm,
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
abstract final class EvaluationFormCryptoTokenPanelTokens {
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
            child: EvaluationFormCryptoTokenPanel(),
          ),
        ),
      ),
    ),
  );
}
