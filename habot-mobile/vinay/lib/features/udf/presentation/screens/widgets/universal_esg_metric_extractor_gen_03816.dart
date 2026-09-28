// GEN-03816 — Universal ESG Metric Extractor Component.
// Reusable M3 Elevated Card widget displaying ESG Component Reusability Ratio with responsive layout, status chips, and mock data.

import 'package:flutter/material.dart';

/// Mock data model for ESG Metric extraction.
class EsgMetricData {
  final String componentName;
  final double reusabilityRatio;
  final String qualitativeOutput;
  final DateTime timestamp;
  final String sessionId;

  const EsgMetricData({
    required this.componentName,
    required this.reusabilityRatio,
    required this.qualitativeOutput,
    required this.timestamp,
    required this.sessionId,
  });
}

/// Hardcoded mock data simulating backend API response.
const List<EsgMetricData> kMockEsgMetrics = [
  EsgMetricData(
    componentName: 'Universal ESG Metric Extractor Byt Component',
    reusabilityRatio: 0.95,
    qualitativeOutput: 'High',
    timestamp: DateTime(2026, 9, 28, 10, 30),
    sessionId: 'sess_8832_gen_03816',
  ),
  EsgMetricData(
    componentName: 'DCDF Engine Adapter',
    reusabilityRatio: 0.82,
    qualitativeOutput: 'Medium',
    timestamp: DateTime(2026, 9, 28, 10, 31),
    sessionId: 'sess_8833_gen_03816',
  ),
  EsgMetricData(
    componentName: 'GCP Telemetry Streamer',
    reusabilityRatio: 0.45,
    qualitativeOutput: 'Low',
    timestamp: DateTime(2026, 9, 28, 10, 32),
    sessionId: 'sess_8834_gen_03816',
  ),
];

/// Determines the M3 Status Chip color based on the floor boundary (0.9).
Color _getStatusColor(BuildContext context, double ratio) {
  final colorScheme = Theme.of(context).colorScheme;
  if (ratio >= 0.9) return colorScheme.primary;
  if (ratio >= 0.7) return colorScheme.tertiary;
  return colorScheme.error;
}

String _getStatusLabel(double ratio) {
  if (ratio >= 0.9) return 'Pass';
  if (ratio >= 0.7) return 'Warning';
  return 'Fail';
}

/// Reusable component: Universal ESG Metric Extractor.
/// Implements M3 Elevated Card Level 2 (3dp elevation), single-column mobile layout (<600dp),
/// multi-column desktop layout (>=840dp), and 48x48dp touch targets.
class UniversalEsgMetricExtractor extends StatefulWidget {
  const UniversalEsgMetricExtractor({super.key});

  @override
  State<UniversalEsgMetricExtractor> createState() => _UniversalEsgMetricExtractorState();
}

class _UniversalEsgMetricExtractorState extends State<UniversalEsgMetricExtractor> {
  late List<EsgMetricData> _metrics;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metrics = kMockEsgMetrics;
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    // Simulates background polling every 30 seconds as per requirement.
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    // Simulate network delay for mock data fetch
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _metrics = List.from(kMockEsgMetrics);
      });
    }
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Inputs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Floor Threshold Override',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuration saved successfully.')),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;
        final crossAxisCount = isDesktop ? 2 : 1;

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ESG Metric Extractor',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (_isRefreshing)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48, // 48x48dp touch target
                      child: OutlinedButton.icon(
                        onPressed: () => _showConfigBottomSheet(context),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Configure Extraction'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: isDesktop ? 2.5 : 2.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final metric = _metrics[index];
                      return _EsgMetricCard(metric: metric);
                    },
                    childCount: _metrics.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// M3 Elevated Card Level 2 (3dp elevation) representing a single metric state.
class _EsgMetricCard extends StatelessWidget {
  final EsgMetricData metric;

  const _EsgMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, metric.reusabilityRatio);
    final statusLabel = _getStatusLabel(metric.reusabilityRatio);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down simulation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Drilling down into ${metric.componentName}...')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      metric.componentName,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reusability Ratio',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(metric.reusabilityRatio * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qualitative Output',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.qualitativeOutput,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}