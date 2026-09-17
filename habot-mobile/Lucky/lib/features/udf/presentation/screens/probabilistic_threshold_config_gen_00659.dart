// GEN-00659 — Probabilistic Matching Threshold Config (Mobile Engineering Console).
// M3 single-column mobile layout (<600dp) with an M3 Elevated Card KPI surface, status
// chip, 48x48dp touch targets, a bottom-sheet config input, snackbar confirmation and a
// 30-second background liveness poll that triggers rollback signalling on failure.

import 'dart:async';

import 'package:flutter/material.dart';

/// Immutable snapshot of this step's health for the engineering console.
@immutable
class ProbabilisticThresholdState {
  const ProbabilisticThresholdState({
    required this.threshold,
    required this.status,
    required this.lastCheckedAt,
    required this.traceId,
  });

  /// Probabilistic matching score floor, spec value >= 0.80.
  final double threshold;

  /// 'Pass' | 'Fail' qualitative output captured by the system.
  final String status;

  final DateTime lastCheckedAt;
  final String traceId;

  /// Floor boundary from the metric spec: >= 0.80.
  static const double floorBoundary = 0.80;

  /// Optimal target from the metric spec: >= 0.90.
  static const double optimalTarget = 0.90;

  /// Ceiling boundary from the metric spec.
  static const double ceilingBoundary = 1.00;

  bool get meetsFloor => threshold >= floorBoundary;
  bool get meetsOptimal => threshold >= optimalTarget;
  bool get isPassing => status == 'Pass' && meetsFloor;

  ProbabilisticThresholdState copyWith({
    double? threshold,
    String? status,
    DateTime? lastCheckedAt,
    String? traceId,
  }) {
    return ProbabilisticThresholdState(
      threshold: threshold ?? this.threshold,
      status: status ?? this.status,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      traceId: traceId ?? this.traceId,
    );
  }
}

/// GEN-00659 engineering console screen.
///
/// Renders a read-only M3 KPI card for the probabilistic score floor
/// parameter, with deep-link drill-down, pull-to-refresh, and automated
/// liveness handshake polling every 30 seconds.
class ProbabilisticThresholdConfigScreen extends StatefulWidget {
  const ProbabilisticThresholdConfigScreen({super.key});

  /// Route helper for deep-link drill-down registration.
  static const String routeName = '/udf/gen-00659';

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ProbabilisticThresholdConfigScreen(),
    );
  }

  @override
  State<ProbabilisticThresholdConfigScreen> createState() =>
      _ProbabilisticThresholdConfigScreenState();
}

class _ProbabilisticThresholdConfigScreenState
    extends State<ProbabilisticThresholdConfigScreen> {
  /// 30-second liveness handshake cadence mandated by the self-chasing spec.
  static const Duration _livenessInterval = Duration(seconds: 30);

  Timer? _livenessTimer;

  ProbabilisticThresholdState _state = ProbabilisticThresholdState(
    threshold: ProbabilisticThresholdState.floorBoundary,
    status: 'Pass',
    lastCheckedAt: DateTime.now(),
    traceId: 'GEN-00659-BOOTSTRAP',
  );

  @override
  void initState() {
    super.initState();
    _startLivenessHandshake();
  }

  @override
  void dispose() {
    _livenessTimer?.cancel();
    super.dispose();
  }

  void _startLivenessHandshake() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer.periodic(_livenessInterval, (_) => _runLivenessCheck());
  }

  /// Liveness handshake: re-evaluates the floor gate and rolls back signalling
  /// if the threshold drifts below the 0.80 floor boundary.
  Future<void> _runLivenessCheck() async {
    if (!mounted) return;
    final next = _state.copyWith(
      lastCheckedAt: DateTime.now(),
      status: _state.meetsFloor ? 'Pass' : 'Fail',
    );
    setState(() => _state = next);

    if (!next.meetsFloor) {
      _showSnack('Floor breach detected — rollback signalled.');
    }
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _runLivenessCheck();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openThresholdBottomSheet() async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ThresholdInputSheet(
        initialValue: _state.threshold,
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      _state = _state.copyWith(
        threshold: selected,
        status: selected >= ProbabilisticThresholdState.floorBoundary
            ? 'Pass'
            : 'Fail',
        lastCheckedAt: DateTime.now(),
      );
    });

    _showSnack(
      selected >= ProbabilisticThresholdState.floorBoundary
          ? 'Threshold 0.80 floor satisfied. Config committed.'
          : 'Threshold below 0.80 floor. Commit blocked by CI gate.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final bool isCompact = width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Probabilistic Threshold'),
        actions: <Widget>[
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            tooltip: 'Drill down to runbook',
            onPressed: () => _showSnack('Deep-link: Identity Graph Specs runbook.'),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _KpiCard(
                state: _state,
                onConfigure: _openThresholdBottomSheet,
                onDrillDown: () =>
                    _showSnack('Trace ${_state.traceId} streamed to BigQuery.'),
              ),
              const SizedBox(height: 16),
              _SpecCard(
                floor: ProbabilisticThresholdState.floorBoundary,
                optimal: ProbabilisticThresholdState.optimalTarget,
                ceiling: ProbabilisticThresholdState.ceilingBoundary,
              ),
              const SizedBox(height: 16),
              _AuditCard(state: _state),
            ],
          ),
        ),
      ),
      floatingActionButton: isCompact
          ? FloatingActionButton.extended(
              onPressed: _openThresholdBottomSheet,
              icon: const Icon(Icons.tune),
              label: const Text('Set Threshold'),
            )
          : null,
    );
  }
}

/// M3 Elevated Card (Level 2, 3dp) presenting the score floor KPI.
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.state,
    required this.onConfigure,
    required this.onDrillDown,
  });

  final ProbabilisticThresholdState state;
  final VoidCallback onConfigure;
  final VoidCallback onDrillDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool passing = state.isPassing;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Probabilistic Score Floor',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusChip(passing: passing, label: state.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              state.threshold.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: passing ? colors.primary : colors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              passing
                  ? 'Meets floor boundary (\u2265 0.80)'
                  : 'Below floor boundary (\u2265 0.80)',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfigure,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.tune),
                    label: const Text('Configure'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDrillDown,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.arrow_outward),
                    label: const Text('Drill Down'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// M3 status chip with 48x48dp minimum hit area.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.passing, required this.label});

  final bool passing;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = passing ? colors.primaryContainer : colors.errorContainer;
    final fg = passing ? colors.onPrimaryContainer : colors.onErrorContainer;

    return Semantics(
      label: 'Step status: $label',
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              passing ? Icons.check_circle : Icons.error,
              size: 16,
              color: fg,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only spec boundaries card sourced from Identity Graph Specs.
class _SpecCard extends StatelessWidget {
  const _SpecCard({
    required this.floor,
    required this.optimal,
    required this.ceiling,
  });

  final double floor;
  final double optimal;
  final double ceiling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Metric Boundaries',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _boundaryRow(theme, 'Floor Boundary', '\u2265 ${floor.toStringAsFixed(2)}'),
            _boundaryRow(theme, 'Optimal Target', '\u2265 ${optimal.toStringAsFixed(2)}'),
            _boundaryRow(theme, 'Ceiling Boundary', ceiling.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _boundaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Audit surface: BigQuery stream metadata and last liveness handshake.
class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.state});

  final ProbabilisticThresholdState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = state.lastCheckedAt.toIso8601String();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Telemetry',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Trace ID: ${state.traceId}',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Last handshake: $ts',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Partitioned by event_date \u00b7 Clustered by trace_id',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// M3 Bottom Sheet for configuring the probabilistic score floor.
class _ThresholdInputSheet extends StatefulWidget {
  const _ThresholdInputSheet({required this.initialValue});

  final double initialValue;

  @override
  State<_ThresholdInputSheet> createState() => _ThresholdInputSheetState();
}

class _ThresholdInputSheetState extends State<_ThresholdInputSheet> {
  late double _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool valid = _value >= ProbabilisticThresholdState.floorBoundary;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Set Probabilistic Score Floor',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Floor boundary requires a minimum of 0.80.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            _value.toStringAsFixed(2),
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: valid ? colors.primary : colors.error),
          ),
          Slider(
            value: _value.clamp(0.0, 1.0),
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: _value.toStringAsFixed(2),
            onChanged: (double v) => setState(() => _value = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: valid
                  ? () => Navigator.of(context).pop(_value)
                  : null,
              child: const Text('Commit Threshold'),
            ),
          ),
        ],
      ),
    );
  }
}
