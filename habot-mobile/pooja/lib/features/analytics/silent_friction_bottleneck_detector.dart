import 'package:flutter/material.dart';

/// Unique styling tokens for Silent Friction Bottleneck Detector.
abstract final class SilentFrictionTokens {
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color frictionHigh = Color(0xFFDC2626);
  static const Color frictionMedium = Color(0xFFD97706);
  static const Color frictionLow = Color(0xFF16A34A);

  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
}

/// Category of silent friction event.
enum FrictionType {
  rageTaps,
  formHesitation,
  scrollThrashing,
  unresponsiveTouch,
}

/// Model representing a detected silent user friction anomaly.
class SilentFrictionSignal {
  final String signalId;
  final FrictionType type;
  final String screenLocation;
  final int count;
  final double latencyMs;
  final String severity; // High, Medium, Low

  const SilentFrictionSignal({
    required this.signalId,
    required this.type,
    required this.screenLocation,
    required this.count,
    required this.latencyMs,
    required this.severity,
  });
}

/// Passive, silent mobile friction bottleneck detection engine under GA4 & ISO/IEC 27035.
class SilentFrictionBottleneckDetector extends StatefulWidget {
  final void Function(SilentFrictionSignal signal)? onSignalLogged;

  const SilentFrictionBottleneckDetector({
    super.key,
    this.onSignalLogged,
  });

  @override
  State<SilentFrictionBottleneckDetector> createState() =>
      _SilentFrictionBottleneckDetectorState();
}

class _SilentFrictionBottleneckDetectorState
    extends State<SilentFrictionBottleneckDetector> {
  int _interactiveTapCount = 0;
  DateTime? _lastTapTime;
  double _frictionIndex = 14.2; // 0 to 100

  late List<SilentFrictionSignal> _detectedSignals;

  @override
  void initState() {
    super.initState();
    _detectedSignals = [
      const SilentFrictionSignal(
        signalId: 'FRIC-101',
        type: FrictionType.formHesitation,
        screenLocation: 'CheckoutPaymentCard.cvvField',
        count: 3,
        latencyMs: 4200.0,
        severity: 'High',
      ),
      const SilentFrictionSignal(
        signalId: 'FRIC-102',
        type: FrictionType.scrollThrashing,
        screenLocation: 'CatalogFilterSheet.slider',
        count: 5,
        latencyMs: 1800.0,
        severity: 'Medium',
      ),
      const SilentFrictionSignal(
        signalId: 'FRIC-103',
        type: FrictionType.unresponsiveTouch,
        screenLocation: 'OrderSummaryHeader.iconBadge',
        count: 1,
        latencyMs: 310.0,
        severity: 'Low',
      ),
    ];
  }

  void _handleInteractiveSurfaceTap() {
    final now = DateTime.now();
    setState(() {
      _interactiveTapCount++;

      // Detect rapid rage-taps (<250ms delta)
      if (_lastTapTime != null &&
          now.difference(_lastTapTime!).inMilliseconds < 250) {
        _frictionIndex = (_frictionIndex + 6.5).clamp(0.0, 100.0);
        final rageSignal = SilentFrictionSignal(
          signalId: 'FRIC-${now.millisecondsSinceEpoch % 1000}',
          type: FrictionType.rageTaps,
          screenLocation: 'InteractiveTestSurface.tapArea',
          count: _interactiveTapCount,
          latencyMs: now.difference(_lastTapTime!).inMilliseconds.toDouble(),
          severity: 'High',
        );
        _detectedSignals.insert(0, rageSignal);
        widget.onSignalLogged?.call(rageSignal);
      }
      _lastTapTime = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: SilentFrictionTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: SilentFrictionTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SilentFrictionTokens.primaryPurple.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: SilentFrictionTokens.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Silent Friction Bottleneck Detector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SilentFrictionTokens.textDark,
                      ),
                    ),
                    Text(
                      'GA4 & ISO/IEC 27035 Silent Telemetry Ingestion',
                      style: TextStyle(
                        fontSize: 12,
                        color: SilentFrictionTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GA4 STREAM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SilentFrictionTokens.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Friction Score Meter
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SilentFrictionTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SilentFrictionTokens.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aggregated Mobile Friction Index',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SilentFrictionTokens.textDark,
                      ),
                    ),
                    Text(
                      '${_frictionIndex.toStringAsFixed(1)} / 100',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _frictionIndex > 50
                            ? SilentFrictionTokens.frictionHigh
                            : (_frictionIndex > 25
                                ? SilentFrictionTokens.frictionMedium
                                : SilentFrictionTokens.frictionLow),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_frictionIndex / 100).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _frictionIndex > 50
                          ? SilentFrictionTokens.frictionHigh
                          : (_frictionIndex > 25
                              ? SilentFrictionTokens.frictionMedium
                              : SilentFrictionTokens.frictionLow),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Interactive Silent Probe Surface
          GestureDetector(
            onTap: _handleInteractiveSurfaceTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SilentFrictionTokens.primaryPurple.withAlpha(60),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    color: SilentFrictionTokens.primaryPurple,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Interactive Silent Probe Canvas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SilentFrictionTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Double-tap rapidly to simulate rage-tap friction spike ($_interactiveTapCount taps)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SilentFrictionTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Signals Stream List
          const Text(
            'Silently Streamed Friction Signals:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SilentFrictionTokens.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: _detectedSignals.take(3).map((sig) {
              final sevColor = sig.severity == 'High'
                  ? SilentFrictionTokens.frictionHigh
                  : (sig.severity == 'Medium'
                      ? SilentFrictionTokens.frictionMedium
                      : SilentFrictionTokens.frictionLow);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: SilentFrictionTokens.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SilentFrictionTokens.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: sevColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${sig.type.name} - ${sig.screenLocation}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SilentFrictionTokens.textDark,
                            ),
                          ),
                          Text(
                            'Latency: ${sig.latencyMs.toInt()}ms | Occurrences: ${sig.count}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: SilentFrictionTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sevColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sig.severity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sevColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: SilentFrictionBottleneckDetector(),
          ),
        ),
      ),
    ),
  );
}
