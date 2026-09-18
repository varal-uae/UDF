// GEN-01335 — Zero-Delay Feature Flag Evaluator & Engineering Console KPI Card.
// Implements synchronous feature flag evaluation on app launch to eliminate UI flicker, with M3 Elevated Cards and responsive layout.

import 'package:flutter/material.dart';

/// Mock data representing feature flags evaluated synchronously at launch.
class _MockFeatureFlag {
  final String key;
  final bool enabled;
  final String variant;
  final double statisticalPower;
  final String qualitativeStatus; // Good / Average / Poor

  const _MockFeatureFlag({
    required this.key,
    required this.enabled,
    required this.variant,
    required this.statisticalPower,
    required this.qualitativeStatus,
  });
}

const List<_MockFeatureFlag> _mockFlags = [
  _MockFeatureFlag(
    key: 'zero_delay_ui_flicker_fix',
    enabled: true,
    variant: 'treatment_a',
    statisticalPower: 0.96,
    qualitativeStatus: 'Good',
  ),
  _MockFeatureFlag(
    key: 'm3_elevated_card_v2',
    enabled: true,
    variant: 'control',
    statisticalPower: 0.85,
    qualitativeStatus: 'Average',
  ),
  _MockFeatureFlag(
    key: 'background_polling_30s',
    enabled: false,
    variant: 'treatment_b',
    statisticalPower: 0.72,
    qualitativeStatus: 'Poor',
  ),
];

/// Synchronous evaluator that resolves flags immediately to prevent UI flicker.
class FeatureFlagEvaluatorGen01335 {
  FeatureFlagEvaluatorGen01335._();

  static final FeatureFlagEvaluatorGen01335 instance = FeatureFlagEvaluatorGen01335._();

  late final List<_MockFeatureFlag> _evaluatedFlags;
  bool _isInitialized = false;

  /// Must be called synchronously before runApp or inside main() prior to widget tree build.
  void evaluateSync() {
    if (_isInitialized) return;
    _evaluatedFlags = List.unmodifiable(_mockFlags);
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  bool isEnabled(String key) {
    if (!_isInitialized) {
      throw StateError('Feature flags not evaluated. Call evaluateSync() on app launch.');
    }
    return _evaluatedFlags.firstWhere((f) => f.key == key).enabled;
  }

  List<_MockFeatureFlag> get allFlags {
    if (!_isInitialized) {
      throw StateError('Feature flags not evaluated. Call evaluateSync() on app launch.');
    }
    return _evaluatedFlags;
  }
}

/// Responsive M3 Engineering Console Widget displaying step health and KPI cards.
class FeatureFlagConsoleCardGen01335 extends StatefulWidget {
  const FeatureFlagConsoleCardGen01335({super.key});

  @override
  State<FeatureFlagConsoleCardGen01335> createState() => _FeatureFlagConsoleCardGen01335State();
}

class _FeatureFlagConsoleCardGen01335State extends State<FeatureFlagConsoleCardGen01335> {
  late List<_MockFeatureFlag> _flags;

  @override
  void initState() {
    super.initState();
    FeatureFlagEvaluatorGen01335.instance.evaluateSync();
    _flags = FeatureFlagEvaluatorGen01335.instance.allFlags;
  }

  void _triggerManualSync() {
    setState(() {
      // Simulate pull-to-refresh manual sync
      _flags = FeatureFlagEvaluatorGen01335.instance.allFlags;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync triggered successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Good':
        return colorScheme.primary;
      case 'Average':
        return colorScheme.tertiary;
      case 'Poor':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final int crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

        return RefreshIndicator(
          onRefresh: () async => _triggerManualSync(),
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engineering Console - Step Health',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: isMobile ? 2.5 : 2.0,
                  ),
                  itemCount: _flags.length,
                  itemBuilder: (context, index) {
                    final flag = _flags[index];
                    return _buildM3ElevatedCard(context, flag);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildM3ElevatedCard(BuildContext context, _MockFeatureFlag flag) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context, flag.qualitativeStatus);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showConfigBottomSheet(context, flag),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      flag.key,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // M3 Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      flag.qualitativeStatus,
                      style: textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Variant: ${flag.variant}',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                'Stat Power: ${flag.statisticalPower.toStringAsFixed(2)} (Floor: 0.80)',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              Row(
                children: [
                  Icon(
                    flag.enabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 18,
                    color: flag.enabled ? colorScheme.primary : colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    flag.enabled ? 'Enabled' : 'Disabled',
                    style: textTheme.bodySmall?.copyWith(
                      color: flag.enabled ? colorScheme.primary : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(BuildContext context, _MockFeatureFlag flag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration: ${flag.key}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // 48x48dp touch targets enforced via min sizes
              SizedBox(
                height: 48,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Metric Config Value',
                    hintText: 'A/B Experiment Statistical Power',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  readOnly: true, // Read-only M3 KPI cards constraint
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}