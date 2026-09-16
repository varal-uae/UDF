// GEN-00406 — UDF Step Health Console (API Gateway Terraform Configuration Step).
// Read-only M3 engineering console screen displaying step health for the API Gateway
// configuration step via M3 Elevated Cards with inline status chips. Background polling
// refreshes every 30 seconds; pull-to-refresh triggers a manual sync. Single-column on
// mobile (<600dp), multi-column on desktop (>=840dp), 48x48dp touch targets.

import 'dart:async';

import 'package:flutter/material.dart';

/// Immutable model describing the health state of step GEN-00406.
class UdfStepHealth {
  const UdfStepHealth({
    required this.stepId,
    required this.title,
    required this.isComplete,
    required this.configDrift,
    required this.floorThreshold,
    required this.lastSyncedAt,
    required this.traceId,
  });

  final String stepId;
  final String title;
  final bool isComplete;

  /// 'Infrastructure Configuration Drift' metric. Floor threshold: 0.0.
  final double configDrift;
  final double floorThreshold;
  final DateTime lastSyncedAt;
  final String traceId;

  bool get isWithinFloor => configDrift >= floorThreshold;

  String get completionLabel => isComplete ? 'Complete' : 'Not Complete';
}

/// Contract for fetching step health. Backed by the engineering console API;
/// all execution events stream to BigQuery partitioned by event_date,
/// clustered by trace_id.
abstract class UdfStepHealthRepository {
  Future<UdfStepHealth> fetchStepHealth(String stepId);
}

/// Read-only mobile engineering console for GEN-00406.
///
/// - M3 Elevated Card (Level 2) with inline status chip.
/// - Background polling every 30 seconds.
/// - Pull-to-refresh for manual sync.
/// - Deep-link drill-down into metric detail.
class UdfStepHealthConsoleGen00406 extends StatefulWidget {
  const UdfStepHealthConsoleGen00406({
    super.key,
    required this.repository,
    this.pollInterval = const Duration(seconds: 30),
    this.onDrillDown,
  });

  static const String stepId = 'GEN-00406';
  static const String stepTitle =
      'Deploy API Gateway configurations using Terraform';

  final UdfStepHealthRepository repository;
  final Duration pollInterval;

  /// Deep-link drill-down handler, e.g. opens the drift metric detail route.
  final ValueChanged<UdfStepHealth>? onDrillDown;

  @override
  State<UdfStepHealthConsoleGen00406> createState() =>
      _UdfStepHealthConsoleGen00406State();
}

class _UdfStepHealthConsoleGen00406State
    extends State<UdfStepHealthConsoleGen00406> {
  Timer? _pollTimer;
  UdfStepHealth? _health;
  Object? _error;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh(showSnackBar: false);
    _pollTimer = Timer.periodic(widget.pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool showSnackBar = false}) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final health = await widget.repository
          .fetchStepHealth(UdfStepHealthConsoleGen00406.stepId);
      if (!mounted) return;
      setState(() {
        _health = health;
        _error = null;
      });
      if (showSnackBar) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Step health synced'),
            ),
          );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Health · GEN-00406')),
      body: RefreshIndicator.adaptive(
        onRefresh: () => _refresh(showSnackBar: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive: single-column <600dp, multi-column >=840dp.
            final isWide = constraints.maxWidth >= 840;
            final content = _buildContent(context);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (isWide)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: content,
                    ),
                  )
                else
                  content,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final health = _health;
    if (health == null && _error != null) {
      return _ErrorCard(
        message: 'Unable to load step health. Pull to retry.',
        onRetry: () => _refresh(showSnackBar: true),
      );
    }
    if (health == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 96),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHealthCard(
          health: health,
          onDrillDown: widget.onDrillDown == null
              ? null
              : () => widget.onDrillDown!(health),
        ),
        const SizedBox(height: 16),
        _MetricCard(health: health),
        const SizedBox(height: 16),
        _SyncCard(health: health, isRefreshing: _isRefreshing),
      ],
    );
  }
}

/// M3 Elevated Card (Level 2) with inline status chip for step completion.
class _StepHealthCard extends StatelessWidget {
  const _StepHealthCard({required this.health, this.onDrillDown});

  final UdfStepHealth health;
  final VoidCallback? onDrillDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor =
        health.isComplete ? colorScheme.primary : colorScheme.error;

    return Card(
      elevation: 3, // M3 Elevated Card Level 2.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDrillDown,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      health.stepId,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      health.isComplete
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 18,
                      color: statusColor,
                    ),
                    label: Text(health.completionLabel),
                    side: BorderSide(color: statusColor.withOpacity(0.4)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(health.title, style: theme.textTheme.titleMedium),
              if (onDrillDown != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 48, // 48x48dp minimum touch target.
                    child: TextButton.icon(
                      onPressed: onDrillDown,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Drill down'),
                    ),
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

/// Read-only M3 KPI card for the 'Infrastructure Configuration Drift' metric.
class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.health});

  final UdfStepHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ok = health.isWithinFloor;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              ok ? Icons.verified_outlined : Icons.warning_amber_rounded,
              color: ok ? colorScheme.primary : colorScheme.error,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Infrastructure Configuration Drift',
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Value ${health.configDrift.toStringAsFixed(2)} · '
                    'Floor ${health.floorThreshold.toStringAsFixed(1)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(ok ? 'Within floor' : 'Below floor'),
              backgroundColor:
                  (ok ? colorScheme.primary : colorScheme.error)
                      .withOpacity(0.12),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sync metadata card: last refresh time, trace id, refresh action.
class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.health, required this.isRefreshing});

  final UdfStepHealth health;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = TimeOfDay.fromDateTime(health.lastSyncedAt).format(context);
    return Card(
      elevation: 3,
      child: ListTile(
        leading: isRefreshing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        title: Text('Last synced $time'),
        subtitle: Text('trace_id: ${health.traceId}'),
        minVerticalPadding: 16, // keeps 48dp touch target.
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
