// SCTSS-009-A05 — Semantic Traffic Light Design Tokens & Status Indicators.
// Standardizes color+shape+icon combinations for system health statuses to ensure WCAG-compliant, mobile-first visual accessibility without relying on text reading.

import 'package:flutter/material.dart';

/// Represents the semantic health status of a system or pipeline.
enum SystemHealthStatus {
  onlineSynced,
  offlineModality,
  syncingInProgress,
  errorCritical,
}

/// Immutable design token holding all visual cues for a specific [SystemHealthStatus].
/// Enforces Poka-Yoke: pairs colors with distinct shapes/icons so colorblind users are never misled.
class SemanticTrafficLightToken {
  final SystemHealthStatus status;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final ShapeBorder shape;
  final String semanticLabel;
  final bool autoExpandCta; // Self-chasing: Red indicator automatically expands to show CTA

  const SemanticTrafficLightToken({
    required this.status,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.shape,
    required this.semanticLabel,
    this.autoExpandCta = false,
  });
}

/// Centralized registry for Semantic Traffic Light tokens.
/// Maps directly to Material 3 high-contrast standards and WCAG AA/AAA requirements.
class SemanticTrafficLightTokens {
  SemanticTrafficLightTokens._();

  /// Online / Synced (Green + Circle + Check)
  static const SemanticTrafficLightToken onlineSynced = SemanticTrafficLightToken(
    status: SystemHealthStatus.onlineSynced,
    backgroundColor: Color(0xFF1B5E20), // High contrast dark green
    foregroundColor: Color(0xFFFFFFFF),
    icon: Icons.check_circle_rounded,
    shape: CircleBorder(),
    semanticLabel: 'Online and Synced',
  );

  /// Offline Modality (Amber/Orange + Rounded Rectangle + Cloud Off)
  static const SemanticTrafficLightToken offlineModality = SemanticTrafficLightToken(
    status: SystemHealthStatus.offlineModality,
    backgroundColor: Color(0xFFE65100), // High contrast dark orange
    foregroundColor: Color(0xFFFFFFFF),
    icon: Icons.cloud_off_rounded,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    semanticLabel: 'Offline Modality Active',
  );

  /// Syncing In Progress (Blue + Stadium + Sync Animated representation)
  static const SemanticTrafficLightToken syncingInProgress = SemanticTrafficLightToken(
    status: SystemHealthStatus.syncingInProgress,
    backgroundColor: Color(0xFF0D47A1), // High contrast dark blue
    foregroundColor: Color(0xFFFFFFFF),
    icon: Icons.sync_rounded,
    shape: StadiumBorder(),
    semanticLabel: 'Syncing In Progress',
  );

  /// Error / Critical (Red + Triangle + Warning) - Triggers self-chasing CTA
  static const SemanticTrafficLightToken errorCritical = SemanticTrafficLightToken(
    status: SystemHealthStatus.errorCritical,
    backgroundColor: Color(0xFFB71C1C), // High contrast dark red
    foregroundColor: Color(0xFFFFFFFF),
    icon: Icons.warning_amber_rounded,
    shape: BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    semanticLabel: 'Critical Error Detected',
    autoExpandCta: true,
  );

  /// Retrieves the token for a given status.
  static SemanticTrafficLightToken getToken(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.onlineSynced:
        return onlineSynced;
      case SystemHealthStatus.offlineModality:
        return offlineModality;
      case SystemHealthStatus.syncingInProgress:
        return syncingInProgress;
      case SystemHealthStatus.errorCritical:
        return errorCritical;
    }
  }

  /// All available tokens for iteration/testing.
  static const List<SemanticTrafficLightToken> all = [
    onlineSynced,
    offlineModality,
    syncingInProgress,
    errorCritical,
  ];
}

/// A reusable widget that renders the semantic traffic light indicator.
/// Implements progressive disclosure and smooth height transitions for self-chasing CTAs.
class SemanticStatusIndicator extends StatefulWidget {
  final SystemHealthStatus status;
  final VoidCallback? onResolvePressed;
  final double size;

  const SemanticStatusIndicator({
    super.key,
    required this.status,
    this.onResolvePressed,
    this.size = 48.0,
  });

  @override
  State<SemanticStatusIndicator> createState() => _SemanticStatusIndicatorState();
}

class _SemanticStatusIndicatorState extends State<SemanticStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));

    // Self-Chasing: Auto-expand if critical error
    final token = SemanticTrafficLightTokens.getToken(widget.status);
    if (token.autoExpandCta) {
      _isExpanded = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant SemanticStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      final token = SemanticTrafficLightTokens.getToken(widget.status);
      if (token.autoExpandCta && !_isExpanded) {
        setState(() => _isExpanded = true);
        _controller.forward();
      } else if (!token.autoExpandCta && _isExpanded) {
        setState(() => _isExpanded = false);
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = SemanticTrafficLightTokens.getToken(widget.status);

    return Semantics(
      label: token.semanticLabel,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: token.backgroundColor,
            shape: token.shape,
            elevation: 2.0,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Icon(
                token.icon,
                color: token.foregroundColor,
                size: widget.size * 0.6,
              ),
            ),
          ),
          // Progressive Disclosure / Smooth CSS-like height transition
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: FilledButton.tonalIcon(
                onPressed: widget.onResolvePressed ?? () {},
                icon: const Icon(Icons.build_circle_outlined, size: 16),
                label: const Text('Resolve Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: token.backgroundColor.withOpacity(0.15),
                  foregroundColor: token.backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MOCK DATA FOR LOCAL TESTING / DASHBOARD PREVIEW ---

/// Mock data representing real-time pipeline statuses aligned with GCP/BigQuery threshold alerts.
class MockPipelineStatusRepository {
  MockPipelineStatusRepository._();

  static final List<Map<String, dynamic>> mockPipelines = [
    {
      'pipelineId': 'pl-001',
      'name': 'User Auth Sync',
      'status': SystemHealthStatus.onlineSynced,
      'lastAccessTimestamp': '2026-09-25T10:00:00Z',
      'userRole': 'Admin',
    },
    {
      'pipelineId': 'pl-002',
      'name': 'Inventory Ledger',
      'status': SystemHealthStatus.syncingInProgress,
      'lastAccessTimestamp': '2026-09-25T10:01:15Z',
      'userRole': 'Operator',
    },
    {
      'pipelineId': 'pl-003',
      'name': 'Payment Gateway',
      'status': SystemHealthStatus.errorCritical,
      'lastAccessTimestamp': '2026-09-25T10:02:30Z',
      'userRole': 'System',
    },
    {
      'pipelineId': 'pl-004',
      'name': 'Analytics Export',
      'status': SystemHealthStatus.offlineModality,
      'lastAccessTimestamp': '2026-09-25T09:45:00Z',
      'userRole': 'Analyst',
    },
  ];

  static List<SystemHealthStatus> getMockStatuses() {
    return mockPipelines.map((e) => e['status'] as SystemHealthStatus).toList();
  }
}
