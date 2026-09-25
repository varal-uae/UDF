// SCTSS-009-A06 — Semantic Traffic Light Status Tokens & Compliance Indicator.
// Standardizes color data structures (HEX, contrast, shape pairings) for compliance health with WCAG-safe color+icon combinations and mock backend API models.

import 'package:flutter/material.dart';

/// Mock backend compliance status API model emitting standardized traffic light data.
class ComplianceStatusModel {
  final String pipelineId;
  final String pipelineName;
  final TrafficLightStatus status;
  final DateTime timestamp;

  const ComplianceStatusModel({
    required this.pipelineId,
    required this.pipelineName,
    required this.status,
    required this.timestamp,
  });

  factory ComplianceStatusModel.fromJson(Map<String, dynamic> json) {
    return ComplianceStatusModel(
      pipelineId: json['pipeline_id'] as String,
      pipelineName: json['pipeline_name'] as String,
      status: TrafficLightStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TrafficLightStatus.unknown,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

enum TrafficLightStatus {
  healthy,
  warning,
  critical,
  unknown,
}

class SemanticColorToken {
  final Color color;
  final String hexCode;
  final String colorName;
  final String colorScheme;
  final double contrastRatio;
  final IconData pairedIcon;
  final String colorApplicationMap;

  const SemanticColorToken({
    required this.color,
    required this.hexCode,
    required this.colorName,
    required this.colorScheme,
    required this.contrastRatio,
    required this.pairedIcon,
    required this.colorApplicationMap,
  });
}

class SemanticTrafficLightTokens {
  SemanticTrafficLightTokens._();

  static const SemanticColorToken healthy = SemanticColorToken(
    color: Color(0xFF2E7D32),
    hexCode: '#2E7D32',
    colorName: 'Compliance Green',
    colorScheme: 'Semantic Traffic Light',
    contrastRatio: 4.8,
    pairedIcon: Icons.check_circle,
    colorApplicationMap: 'System Healthy / Compliant',
  );

  static const SemanticColorToken warning = SemanticColorToken(
    color: Color(0xFFF57F17),
    hexCode: '#F57F17',
    colorName: 'Compliance Amber',
    colorScheme: 'Semantic Traffic Light',
    contrastRatio: 4.6,
    pairedIcon: Icons.warning_amber_rounded,
    colorApplicationMap: 'Warning / Degraded Performance',
  );

  static const SemanticColorToken critical = SemanticColorToken(
    color: Color(0xFFC62828),
    hexCode: '#C62828',
    colorName: 'Compliance Red',
    colorScheme: 'Semantic Traffic Light',
    contrastRatio: 5.2,
    pairedIcon: Icons.error_outline,
    colorApplicationMap: 'Critical / Pipeline Broken',
  );

  static const SemanticColorToken unknown = SemanticColorToken(
    color: Color(0xFF616161),
    hexCode: '#616161',
    colorName: 'Compliance Grey',
    colorScheme: 'Semantic Traffic Light',
    contrastRatio: 7.0,
    pairedIcon: Icons.help_outline,
    colorApplicationMap: 'Unknown / Pending Data',
  );

  static SemanticColorToken fromStatus(TrafficLightStatus status) {
    switch (status) {
      case TrafficLightStatus.healthy:
        return healthy;
      case TrafficLightStatus.warning:
        return warning;
      case TrafficLightStatus.critical:
        return critical;
      case TrafficLightStatus.unknown:
        return unknown;
    }
  }
}

/// Poka-Yoke enforced indicator pairing color with shape/icon for colorblind accessibility.
class SemanticTrafficLightIndicator extends StatelessWidget {
  final TrafficLightStatus status;
  final double size;
  final bool showResolveAction;
  final VoidCallback? onResolve;

  const SemanticTrafficLightIndicator({
    super.key,
    required this.status,
    this.size = 24.0,
    this.showResolveAction = false,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final token = SemanticTrafficLightTokens.fromStatus(status);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: token.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: token.color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                token.pairedIcon,
                color: token.color,
                size: size,
                semanticLabel: token.colorApplicationMap,
              ),
              const SizedBox(width: 8),
              Text(
                token.colorName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: token.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Self-Chasing: Red indicator automatically expands to show Resolve Now CTA
          if (showResolveAction && status == TrafficLightStatus.critical) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onResolve,
              icon: const Icon(Icons.build_circle_outlined, size: 18),
              label: const Text('Resolve Now'),
              style: FilledButton.styleFrom(
                backgroundColor: token.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mock repository simulating backend compliance status API.
class MockComplianceRepository {
  static final List<ComplianceStatusModel> mockPipelineStatuses = [
    ComplianceStatusModel(
      pipelineId: 'pipe-001',
      pipelineName: 'Data Ingestion',
      status: TrafficLightStatus.healthy,
      timestamp: DateTime.now(),
    ),
    ComplianceStatusModel(
      pipelineId: 'pipe-002',
      pipelineName: 'Transformation Layer',
      status: TrafficLightStatus.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ComplianceStatusModel(
      pipelineId: 'pipe-003',
      pipelineName: 'Export Service',
      status: TrafficLightStatus.critical,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ComplianceStatusModel(
      pipelineId: 'pipe-004',
      pipelineName: 'Audit Logger',
      status: TrafficLightStatus.unknown,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<ComplianceStatusModel>> fetchStatuses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return mockPipelineStatuses;
  }
}

/// Dashboard widget demonstrating pure semantic color usage for system status.
class ComplianceDashboardView extends StatefulWidget {
  const ComplianceDashboardView({super.key});

  @override
  State<ComplianceDashboardView> createState() => _ComplianceDashboardViewState();
}

class _ComplianceDashboardViewState extends State<ComplianceDashboardView> {
  final MockComplianceRepository _repository = MockComplianceRepository();
  List<ComplianceStatusModel> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() => _isLoading = true);
    final data = await _repository.fetchStatuses();
    if (mounted) {
      setState(() {
        _statuses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance Health Dashboard'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading compliance statuses',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStatuses,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _statuses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _statuses[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.pipelineName,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${item.pipelineId}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SemanticTrafficLightIndicator(
                            status: item.status,
                            showResolveAction: true,
                            onResolve: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Resolving ${item.pipelineName}...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}