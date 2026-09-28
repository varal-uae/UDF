// GEN-03970 — Daily Task Volume Bar Chart Component.
// Renders a Material 3 bar chart visualising daily task volume completions with mock data, responsive layout, and performance metrics.

import 'package:flutter/material.dart';

/// Mock data model for daily task volume.
class DailyTaskVolume {
  final String day;
  final int completedTasks;

  const DailyTaskVolume({required this.day, required this.completedTasks});
}

/// Realistic local mock data for the bar chart.
const List<DailyTaskVolume> kMockDailyTaskVolumes = [
  DailyTaskVolume(day: 'Mon', completedTasks: 42),
  DailyTaskVolume(day: 'Tue', completedTasks: 58),
  DailyTaskVolume(day: 'Wed', completedTasks: 35),
  DailyTaskVolume(day: 'Thu', completedTasks: 71),
  DailyTaskVolume(day: 'Fri', completedTasks: 64),
  DailyTaskVolume(day: 'Sat', completedTasks: 22),
  DailyTaskVolume(day: 'Sun', completedTasks: 15),
];

/// A responsive M3 bar chart component visualising daily task volume completions.
/// 
/// Implements single-column mobile layout (<600dp) and multi-column desktop (>=840dp).
/// Uses M3 Elevated Cards Level 2 (3dp elevation) and Status Chips.
/// Touch targets are minimum 48x48dp.
class DailyTaskVolumeBarChartGen03970 extends StatefulWidget {
  const DailyTaskVolumeBarChartGen03970({super.key});

  @override
  State<DailyTaskVolumeBarChartGen03970> createState() => _DailyTaskVolumeBarChartGen03970State();
}

class _DailyTaskVolumeBarChartGen03970State extends State<DailyTaskVolumeBarChartGen03970> {
  bool _isHealthy = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 840;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Card(
          elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Daily Task Volume Completions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Chip(
                      avatar: Icon(
                        _isHealthy ? Icons.check_circle : Icons.error,
                        size: 18.0,
                        color: _isHealthy ? colorScheme.primary : colorScheme.error,
                      ),
                      label: Text(_isHealthy ? 'Pass' : 'Fail'),
                      backgroundColor: _isHealthy
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: _isHealthy
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _buildChartArea(theme, colorScheme),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        flex: 1,
                        child: _buildMetricsPanel(theme, colorScheme),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildChartArea(theme, colorScheme),
                      const SizedBox(height: 24.0),
                      _buildMetricsPanel(theme, colorScheme),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartArea(ThemeData theme, ColorScheme colorScheme) {
    final int maxTasks = kMockDailyTaskVolumes.fold<int>(
      0,
      (int prev, DailyTaskVolume element) => element.completedTasks > prev ? element.completedTasks : prev,
    );

    return SizedBox(
      height: 240.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: kMockDailyTaskVolumes.map((DailyTaskVolume data) {
          final double heightRatio = maxTasks == 0 ? 0 : data.completedTasks / maxTasks;
          return _BarColumn(
            label: data.day,
            value: data.completedTasks,
            heightRatio: heightRatio,
            color: colorScheme.primary,
            onSurfaceColor: colorScheme.onSurface,
            textTheme: theme.textTheme,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsPanel(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Render Metrics', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8.0),
        _MetricRow(label: 'Latency Floor', value: '< 50 ms', theme: theme),
        _MetricRow(label: 'Optimal Target', value: '< 16 ms', theme: theme),
        _MetricRow(label: 'Ceiling', value: '100 ms', theme: theme),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 48.0, // 48x48dp touch target
          width: 48.0,
          child: IconButton(
            onPressed: () {
              setState(() {
                _isHealthy = !_isHealthy;
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Simulate Sync',
          ),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.label,
    required this.value,
    required this.heightRatio,
    required this.color,
    required this.onSurfaceColor,
    required this.textTheme,
  });

  final String label;
  final int value;
  final double heightRatio;
  final Color color;
  final Color onSurfaceColor;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          value.toString(),
          style: textTheme.labelSmall?.copyWith(color: onSurfaceColor),
        ),
        const SizedBox(height: 4.0),
        Container(
          width: 32.0,
          height: 200.0 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: onSurfaceColor),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}