// CUITC-012-A14 — Corporate Tax Liability Dashboard Layout.
// Material 3, 8dp-grid dashboard shell with reusable trend cards, 48dp+ touch
// targets, graceful fallback states, and <60 FPS frame-rate telemetry.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Cuitc012A14TaxTrend {
  const Cuitc012A14TaxTrend({
    required this.label,
    required this.value,
    required this.period,
    this.previousValue,
  });

  final String label;
  final double value;
  final String period;
  final double? previousValue;

  double? get delta => previousValue == null ? null : value - previousValue!;
  double? get deltaPercent => previousValue == null || previousValue == 0
      ? null
      : ((value - previousValue!) / previousValue!) * 100;
}

class Cuitc012A14FrameRateMonitor extends StatefulWidget {
  const Cuitc012A14FrameRateMonitor({
    super.key,
    required this.child,
    this.thresholdFps = 60,
  });

  final Widget child;
  final double thresholdFps;

  @override
  State<Cuitc012A14FrameRateMonitor> createState() =>
      _Cuitc012A14FrameRateMonitorState();
}

class _Cuitc012A14FrameRateMonitorState
    extends State<Cuitc012A14FrameRateMonitor> {
  late final TimingsCallback _timingsCallback;

  @override
  void initState() {
    super.initState();
    _timingsCallback = _onFrameTimings;
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_timingsCallback);
    super.dispose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    final totalMicros = timings.fold<int>(
      0,
      (sum, timing) => sum + timing.totalSpan.inMicroseconds,
    );
    final averageMicros = totalMicros / timings.length;
    if (averageMicros <= 0) return;
    final fps = 1000000 / averageMicros;
    if (fps < widget.thresholdFps) {
      debugPrint(
        '[CUITC-012-A14] Frame rate drop: ${fps.toStringAsFixed(1)} FPS '
        '(threshold ${widget.thresholdFps.toStringAsFixed(0)} FPS)',
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class Cuitc012A14DashboardLayout extends StatelessWidget {
  const Cuitc012A14DashboardLayout({
    super.key,
    this.trends = const <Cuitc012A14TaxTrend>[],
    this.isLoading = false,
    this.hasError = false,
    this.onRefresh,
  });

  final List<Cuitc012A14TaxTrend> trends;
  final bool isLoading;
  final bool hasError;
  final Future<void> Function()? onRefresh;

  static const double _grid = 8;

  @override
  Widget build(BuildContext context) {
    return Cuitc012A14FrameRateMonitor(
      child: Scaffold(
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (hasError) {
      return _FallbackState(
        icon: Icons.cloud_off_outlined,
        title: 'Dashboard unavailable',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: onRefresh,
      );
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (trends.isEmpty) {
      return const _FallbackState(
        icon: Icons.insights_outlined,
        title: 'No tax trends yet',
        message: 'Real-time liability trends will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: GridView.builder(
        padding: const EdgeInsets.all(_grid * 2),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 112,
          crossAxisSpacing: _grid,
          mainAxisSpacing: _grid,
        ),
        itemCount: trends.length,
        itemBuilder: (context, index) {
          final trend = trends[index];
          return Cuitc012A14TrendCard(trend: trend, onTap: onRefresh);
        },
      ),
    );
  }
}

class Cuitc012A14TrendCard extends StatelessWidget {
  const Cuitc012A14TrendCard({super.key, required this.trend, this.onTap});

  final Cuitc012A14TaxTrend trend;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final delta = trend.delta;
    final deltaPercent = trend.deltaPercent;
    final isPositive = delta != null && delta >= 0;
    final deltaColor = isPositive ? colorScheme.primary : colorScheme.error;

    return Semantics(
      button: true,
      label: '${trend.label}, ${trend.period}, '
          'value ${trend.value.toStringAsFixed(0)}',
      child: Card(
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null ? null : () { onTap!(); },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trend.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        trend.period,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          trend.value.toStringAsFixed(0),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (deltaPercent != null)
                        Text(
                          '${isPositive ? '+' : ''}${deltaPercent!.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: deltaColor),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackState extends StatelessWidget {
  const _FallbackState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                  child: FilledButton(
                    onPressed: () { onAction!(); },
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
