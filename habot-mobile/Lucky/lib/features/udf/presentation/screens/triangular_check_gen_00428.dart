// GEN-00428 — Automated Triangular Check (A−B=0) Validator & M3 Status Card.
// Implements the Habot TKI 8 (A−B=0) rule: pure Dart comparison logic that
// evaluates the mathematical variance between two revenue figures (A and B)
// against a floor threshold of AED 0.00, rendering a Pass/Fail verdict in a
// Material 3 elevated card with an inline status chip on the mobile console.

import 'package:flutter/material.dart';

/// Verdict of a single triangular check evaluation.
enum TriangularCheckVerdict { pass, fail }

/// Immutable outcome of the A−B=0 comparison.
class TriangularCheckResult {
  const TriangularCheckResult({
    required this.operandA,
    required this.operandB,
    required this.variance,
    required this.verdict,
    required this.evaluatedAt,
  });

  /// Revenue figure A (e.g. expected revenue, AED).
  final double operandA;

  /// Revenue figure B (e.g. actual/settled revenue, AED).
  final double operandB;

  /// Computed variance: A − B (AED).
  final double variance;

  /// Pass when |A − B| <= tolerance (floor boundary AED 0.00).
  final TriangularCheckVerdict verdict;

  /// Action/event timestamp, captured for BigQuery event streaming.
  final DateTime evaluatedAt;

  bool get isPass => verdict == TriangularCheckVerdict.pass;
}

/// Pure mathematical comparison logic for the Habot TKI 8 (A−B=0) rule.
/// Stateless and reusable; stored here as the core pattern for this step.
class TriangularCheckEvaluator {
  const TriangularCheckEvaluator({this.tolerance = 0.0});

  /// Maximum permitted absolute variance in AED.
  /// Floor/optimal/ceiling boundary for this metric: AED 0.00.
  final double tolerance;

  /// Evaluates A − B = 0 and returns a Pass/Fail result.
  TriangularCheckResult evaluate({
    required double operandA,
    required double operandB,
    DateTime? evaluatedAt,
  }) {
    final double variance = operandA - operandB;
    final bool passes = variance.abs() <= tolerance;
    return TriangularCheckResult(
      operandA: operandA,
      operandB: operandB,
      variance: variance,
      verdict:
          passes ? TriangularCheckVerdict.pass : TriangularCheckVerdict.fail,
      evaluatedAt: evaluatedAt ?? DateTime.now(),
    );
  }
}

/// Mobile engineering console screen for GEN-00428.
/// Read-only M3 KPI presentation: single-column on mobile (<600dp),
/// multi-column on desktop (≥840dp), 48x48dp touch targets.
class TriangularCheckScreenGen00428 extends StatefulWidget {
  const TriangularCheckScreenGen00428({
    super.key,
    required this.operandA,
    required this.operandB,
    this.evaluator = const TriangularCheckEvaluator(),
    this.onEvaluated,
  });

  final double operandA;
  final double operandB;
  final TriangularCheckEvaluator evaluator;

  /// Telemetry hook: stream evaluation events to BigQuery
  /// (partitioned by event_date, clustered by trace_id).
  final void Function(TriangularCheckResult result)? onEvaluated;

  @override
  State<TriangularCheckScreenGen00428> createState() =>
      _TriangularCheckScreenGen00428State();
}

class _TriangularCheckScreenGen00428State
    extends State<TriangularCheckScreenGen00428> {
  late TriangularCheckResult _result;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  void _runCheck() {
    final TriangularCheckResult result = widget.evaluator.evaluate(
      operandA: widget.operandA,
      operandB: widget.operandB,
    );
    setState(() => _result = result);
    widget.onEvaluated?.call(result);
  }

  String _formatAed(double value) => 'AED ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triangular Check (A−B=0)')),
      body: RefreshIndicator(
        onRefresh: () async => _runCheck(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= 840;
            final Widget card = _TriangularCheckCard(
              result: _result,
              formatAed: _formatAed,
              onReRun: _runCheck,
            );
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (isWide)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: card,
                    ),
                  )
                else
                  card,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// M3 Elevated Card (Level 2) displaying the check verdict
/// with an inline M3 status chip and read-only KPI rows.
class _TriangularCheckCard extends StatelessWidget {
  const _TriangularCheckCard({
    required this.result,
    required this.formatAed,
    required this.onReRun,
  });

  final TriangularCheckResult result;
  final String Function(double) formatAed;
  final VoidCallback onReRun;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final bool isPass = result.isPass;
    final Color statusColor = isPass ? colors.tertiary : colors.error;
    final Color statusBg =
        isPass ? colors.tertiaryContainer : colors.errorContainer;
    final Color onStatusBg =
        isPass ? colors.onTertiaryContainer : colors.onErrorContainer;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Mathematical Variance',
                    style: text.titleMedium,
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isPass ? Icons.check_circle : Icons.error,
                    size: 18,
                    color: onStatusBg,
                  ),
                  label: Text(isPass ? 'Pass' : 'Fail'),
                  backgroundColor: statusBg,
                  labelStyle: text.labelLarge?.copyWith(color: onStatusBg),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _KpiRow(label: 'Operand A', value: formatAed(result.operandA)),
            const Divider(height: 24),
            _KpiRow(label: 'Operand B', value: formatAed(result.operandB)),
            const Divider(height: 24),
            _KpiRow(
              label: 'Variance (A − B)',
              value: formatAed(result.variance),
              valueColor: statusColor,
            ),
            const Divider(height: 24),
            _KpiRow(
              label: 'Floor Threshold',
              value: formatAed(0),
            ),
            const SizedBox(height: 8),
            Text(
              'Evaluated: ${result.evaluatedAt.toIso8601String()}',
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                child: FilledButton.tonalIcon(
                  onPressed: onReRun,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Re-run Check'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only KPI row used inside the triangular check card.
class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: text.bodyMedium),
        Text(
          value,
          style: text.titleSmall?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
