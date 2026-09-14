// FLADE-011-13 — Shakti Alert Panel (Critical System Breach UI).
// Provides an un-ignorable, top-pinned global alert banner for P1 architectural breaches and manual system overrides, adhering to WCAG 2.1 AA accessibility and Material 3 design tokens.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Identifiers for critical architectural and security breach signals.
enum ShaktiBreachSignalType {
  p1ArchitecturalBreachSignal('P1_ARCHITECTURAL_BREACH_SIGNAL', 'CRITICAL P1 ARCHITECTURAL BREACH'),
  manualOverrideSignal('MANUAL_OVERRIDE_SIGNAL', 'CRITICAL SYSTEM MANUAL OVERRIDE'),
  securityIntegrityBreach('SECURITY_INTEGRITY_BREACH', 'SYSTEM INTEGRITY COMPROMISED');

  final String code;
  final String title;
  const ShaktiBreachSignalType(this.code, this.title);
}

/// Payload model representing a critical system breach incident.
class ShaktiBreachPayload {
  final ShaktiBreachSignalType signalType;
  final String breachMessage;
  final DateTime timestamp;
  final String incidentId;
  final Map<String, dynamic>? metadata;

  const ShaktiBreachPayload({
    required this.signalType,
    required this.breachMessage,
    required this.timestamp,
    required this.incidentId,
    this.metadata,
  });
}

/// Global coordinator for broadcasting and acknowledging critical breach signals.
class ShaktiAlertController extends ChangeNotifier {
  static final ShaktiAlertController _instance = ShaktiAlertController._internal();
  factory ShaktiAlertController() => _instance;
  ShaktiAlertController._internal();

  ShaktiBreachPayload? _currentBreach;
  ShaktiBreachPayload? get currentBreach => _currentBreach;
  bool get hasActiveBreach => _currentBreach != null;

  void injectBreachSignal({
    required ShaktiBreachSignalType signalType,
    required String message,
    String? incidentId,
    Map<String, dynamic>? metadata,
  }) {
    _currentBreach = ShaktiBreachPayload(
      signalType: signalType,
      breachMessage: message,
      timestamp: DateTime.now().toUtc(),
      incidentId: incidentId ?? 'INC-${DateTime.now().millisecondsSinceEpoch}',
      metadata: metadata,
    );
    notifyListeners();
  }

  void clearBreach() {
    _currentBreach = null;
    notifyListeners();
  }
}

/// Global overlay wrapper ensuring critical alerts appear persistently on top of all screens.
class ShaktiAlertPanel extends StatefulWidget {
  final Widget child;
  final ShaktiAlertController? controller;

  const ShaktiAlertPanel({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<ShaktiAlertPanel> createState() => _ShaktiAlertPanelState();
}

class _ShaktiAlertPanelState extends State<ShaktiAlertPanel> with SingleTickerProviderStateMixin {
  late final ShaktiAlertController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ShaktiAlertController();
    _controller.addListener(_onStateChange);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_controller.hasActiveBreach) {
      _pulseController.repeat(reverse: true);
      _announceBreachToAccessibility(_controller.currentBreach!);
    }
  }

  void _onStateChange() {
    if (mounted) {
      if (_controller.hasActiveBreach) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        _announceBreachToAccessibility(_controller.currentBreach!);
      } else {
        _pulseController.stop();
      }
      setState(() {});
    }
  }

  void _announceBreachToAccessibility(ShaktiBreachPayload breach) {
    SemanticsService.announce(
      'Critical Alert: ${breach.signalType.title}. ${breach.breachMessage}',
      TextDirection.ltr,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBreach = _controller.currentBreach;

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (activeBreach != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              type: MaterialType.transparency,
              elevation: 24.0,
              child: SafeArea(
                bottom: false,
                child: Semantics(
                  liveRegion: true,
                  alert: true,
                  focused: true,
                  label: '${activeBreach.signalType.title}: ${activeBreach.breachMessage}',
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB00020),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 28,
                            semanticLabel: 'Breach alert icon',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activeBreach.signalType.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeBreach.breachMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Signal: ${activeBreach.signalType.code} | ID: ${activeBreach.incidentId}',
                                style: const TextStyle(
                                  color: Color(0xFFFFCDD2),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
