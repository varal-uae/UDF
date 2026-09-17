// GEN-00681 — UDF Marketing Data Governance & Anomaly Detection Console Screen.
// Material 3 single-column mobile layout (<600dp) rendering anomaly-detection
// step health via Elevated Cards, status chips, KPI drill-down, and read-only
// governance controls for the Anomaly Detection Precision metric (>= 30%).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Immutable view-model describing the GEN-00681 governance step state.
@immutable
class UdfGovernanceStepState {
  const UdfGovernanceStepState({
    required this.atomicId,
    required this.title,
    required this.subtitle,
    required this.metricName,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.result,
    required this.health,
    required this.lastUpdated,
  });

  final String atomicId;
  final String title;
  final String subtitle;
  final String metricName;
  final String floorBoundary;
  final String optimalTarget;
  final GovernanceResult result;
  final GovernanceHealth health;
  final DateTime lastUpdated;

  UdfGovernanceStepState copyWith({
    GovernanceResult? result,
    GovernanceHealth? health,
    DateTime? lastUpdated,
  }) {
    return UdfGovernanceStepState(
      atomicId: atomicId,
      title: title,
      subtitle: subtitle,
      metricName: metricName,
      floorBoundary: floorBoundary,
      optimalTarget: optimalTarget,
      result: result ?? this.result,
      health: health ?? this.health,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Qualitative pass/fail verdict captured for the governance step.
enum GovernanceResult { pass, fail, pending }

/// Semantic health bucket used to drive M3 status chip coloring.
enum GovernanceHealth { healthy, degraded, critical, unknown }

/// Read-only engineering console for the automated marketing data
/// governance and anomaly detection rules (GEN-00681).
class UdfMarketingDataGovernanceAnomalyDetectionGen00681 extends StatefulWidget {
  const UdfMarketingDataGovernanceAnomalyDetectionGen00681({super.key});

  static const String routeName =
      '/udf/governance/marketing-data-anomaly-detection/GEN-00681';

  @override
  State<UdfMarketingDataGovernanceAnomalyDetectionGen00681> createState() =>
      _UdfMarketingDataGovernanceAnomalyDetectionGen00681State();
}

class _UdfMarketingDataGovernanceAnomalyDetectionGen00681State
    extends State<UdfMarketingDataGovernanceAnomalyDetectionGen00681> {
  static const Duration _pollInterval = Duration(seconds: 30);

  late UdfGovernanceStepState _state;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _state = UdfGovernanceStepState(
      atomicId: 'GEN-00681',
      title: 'Marketing Data Governance',
      subtitle: 'Ad spend anomaly assertions — channel spikes > 30% baseline',
      metricName: 'Anomaly Detection Precision',
      floorBoundary: r'\u2265 30%',
      optimalTarget: '30%',
      result: GovernanceResult.pending,
      health: GovernanceHealth.unknown,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _state = _state.copyWith(lastUpdated: DateTime.now());
    });
  }

  void _toggleDetails() {
    setState(() => _showDetails = !_showDetails);
  }

  Color _healthColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (_state.health) {
      case GovernanceHealth.healthy:
        return scheme.primary;
      case GovernanceHealth.degraded:
        return scheme.tertiary;
      case GovernanceHealth.critical:
        return scheme.error;
      case GovernanceHealth.unknown:
        return scheme.outline;
    }
  }

  String _healthLabel() {
    switch (_state.health) {
      case GovernanceHealth.healthy:
        return 'Healthy';
      case GovernanceHealth.degraded:
        return 'Degraded';
      case GovernanceHealth.critical:
        return 'Critical';
      case GovernanceHealth.unknown:
        return 'Pending';
    }
  }

  String _resultLabel() {
    switch (_state.result) {
      case GovernanceResult.pass:
        return 'Pass';
      case GovernanceResult.fail:
        return 'Fail';
      case GovernanceResult.pending:
        return 'Awaiting validation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Governance Console'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 32,
                  vertical: 16,
                ),
                children: <Widget>[
                  _headerCard(theme, scheme),
                  const SizedBox(height: 16),
                  _metricCard(theme, scheme),
                  const SizedBox(height: 16),
                  _assertionCard(theme, scheme),
                  const SizedBox(height: 16),
                  _governanceCard(theme, scheme),
                  const SizedBox(height: 24),
                  _drillDownSection(theme, scheme),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
      bottomSheet: _state.health == GovernanceHealth.critical
          ? _criticalBanner(theme, scheme)
          : null,
    );
  }

  Widget _headerCard(ThemeData theme, ColorScheme scheme) {
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
                    _state.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _statusChip(scheme),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _state.subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(Icons.tag, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(_state.atomicId, style: theme.textTheme.labelMedium),
                const Spacer(),
                Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  TimeOfDay.fromDateTime(_state.lastUpdated).format(context),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Open governance configuration bottom sheet',
              child: SizedBox(
                height: 48,
                child: FilledButton.tonalIcon(
                  onPressed: _openConfigSheet,
                  icon: const Icon(Icons.tune),
                  label: const Text('Configure governance rules'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ColorScheme scheme) {
    final color = _healthColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _healthLabel(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _metricCard(ThemeData theme, ColorScheme scheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('KPI', style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(_state.metricName, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _kpiTile(
                    theme,
                    label: 'Floor',
                    value: _state.floorBoundary,
                  ),
                ),
                Expanded(
                  child: _kpiTile(
                    theme,
                    label: 'Target',
                    value: _state.optimalTarget,
                  ),
                ),
                Expanded(
                  child: _kpiTile(
                    theme,
                    label: 'Result',
                    value: _resultLabel(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiTile(ThemeData theme, {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _assertionCard(ThemeData theme, ColorScheme scheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.rule, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SQL assertion — ad spend anomaly',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy assertion snippet',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(
                        text:
                            'SELECT channel, spend, baseline, '
                            '((spend - baseline) / NULLIF(baseline, 0)) AS delta '
                            'FROM ad_spend_daily '
                            'WHERE event_date = CURRENT_DATE() '
                            'HAVING delta > 0.30;',
                      ),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assertion copied')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Flag channel spend spikes > 30% over baseline.\n'
                'Output field: Pass / Fail.\n'
                'Reference spec: Improvado Governance Rules.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _governanceCard(ThemeData theme, ColorScheme scheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Governance gates', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            _gateRow(
              scheme,
              icon: Icons.verified_user_outlined,
              label: 'EC blueprint signed off',
              value: _state.result == GovernanceResult.pass,
            ),
            _gateRow(
              scheme,
              icon: Icons.bolt_outlined,
              label: 'Liveness handshake (30s)',
              value: _state.health != GovernanceHealth.critical,
            ),
            _gateRow(
              scheme,
              icon: Icons.cloud_outlined,
              label: 'BigQuery event streaming',
              value: true,
            ),
            const Divider(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'CI/CD deploy gate',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch.adaptive(
                  value: _state.result == GovernanceResult.pass,
                  onChanged: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gateRow(
    ColorScheme scheme, {
    required IconData icon,
    required String label,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Icon(
            value ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: value ? scheme.primary : scheme.outline,
          ),
        ],
      ),
    );
  }

  Widget _drillDownSection(ThemeData theme, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Assertion history (read-only)',
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: _toggleDetails,
              icon: Icon(
                _showDetails ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(_showDetails ? 'Hide' : 'Show'),
            ),
          ],
        ),
        if (_showDetails) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('trace_id: 7f3a-…-c9e2', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('partition_date: today', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'collected: completion status, event timestamp, session id',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'handler: @habot/shared-library#anomaly-detector',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _criticalBanner(ThemeData theme, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Anomaly detection anomaly — rollback armed by liveness handshake.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openConfigSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Confirmation', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'Data governance hooks are read-only in this console. Submit '
                'is disabled until every contextual hook validates.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
