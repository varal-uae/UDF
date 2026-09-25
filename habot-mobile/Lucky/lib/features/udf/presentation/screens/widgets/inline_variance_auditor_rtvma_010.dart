// RTVMA-010 — Inline Variance UI Auditor.
// Provides touch-locked bounds, dynamic color states tracking math changes, visual state tracking maps, and native progress rings for variance auditing with mock data.

import 'package:flutter/material.dart';

enum DefinitionType { numeric, percentage, boolean }

enum ValidationStatus { notComplete, partial, complete }

class VarianceDefinition {
  final String definitionId;
  final String definitionName;
  final Map<String, dynamic> definitionParameters;
  final DefinitionType definitionType;
  final ValidationStatus validationStatus;
  final double currentValue;
  final double targetValue;
  final double tolerance;

  const VarianceDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionParameters,
    required this.definitionType,
    required this.validationStatus,
    required this.currentValue,
    required this.targetValue,
    required this.tolerance,
  });

  double get variance => (currentValue - targetValue).abs();
  bool get isWithinTolerance => variance <= tolerance;
}

const List<VarianceDefinition> _mockDefinitions = [
  VarianceDefinition(
    definitionId: 'DEF-001',
    definitionName: 'Auth Token Expiry Variance',
    definitionParameters: {'unit': 'seconds', 'source': 'jwt_payload'},
    definitionType: DefinitionType.numeric,
    validationStatus: ValidationStatus.complete,
    currentValue: 3600,
    targetValue: 3600,
    tolerance: 50,
  ),
  VarianceDefinition(
    definitionId: 'DEF-002',
    definitionName: 'API Gateway Latency',
    definitionParameters: {'unit': 'ms', 'source': 'telemetry'},
    definitionType: DefinitionType.numeric,
    validationStatus: ValidationStatus.partial,
    currentValue: 245,
    targetValue: 200,
    tolerance: 30,
  ),
  VarianceDefinition(
    definitionId: 'DEF-003',
    definitionName: 'Unauthorized Request Block Rate',
    definitionParameters: {'unit': '%', 'source': 'security_logs'},
    definitionType: DefinitionType.percentage,
    validationStatus: ValidationStatus.notComplete,
    currentValue: 98.5,
    targetValue: 100.0,
    tolerance: 1.0,
  ),
];

class InlineVarianceAuditor extends StatefulWidget {
  const InlineVarianceAuditor({super.key});

  @override
  State<InlineVarianceAuditor> createState() => _InlineVarianceAuditorState();
}

class _InlineVarianceAuditorState extends State<InlineVarianceAuditor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<VarianceDefinition> _definitions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _definitions = List.from(_mockDefinitions);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getVarianceColor(VarianceDefinition def) {
    if (def.isWithinTolerance) return Colors.green;
    if (def.variance <= def.tolerance * 2) return Colors.orange;
    return Colors.red;
  }

  String _statusLabel(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.notComplete:
        return 'Not Complete';
      case ValidationStatus.partial:
        return 'Partial';
      case ValidationStatus.complete:
        return 'Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Inline Variance Auditor',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inline Variance UI Auditor',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._definitions.map((def) => _buildAuditorRow(def, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditorRow(VarianceDefinition def, ThemeData theme) {
    final color = _getVarianceColor(def);
    final progress = def.targetValue == 0
        ? 0.0
        : (def.currentValue / def.targetValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AbsorbPointer(
        absorbing: true,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: progress * _controller.value,
                        strokeWidth: 4,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.definitionName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${def.definitionId} | Type: ${def.definitionType.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Var: ${def.variance.toStringAsFixed(2)} (Tol: ${def.tolerance})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              _statusLabel(def.validationStatus),
                              style: theme.textTheme.labelSmall,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}
