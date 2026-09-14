// FLADE-012-09 — Real-Time Pipeline Oversight Feed & Alert Stream Screen.
// Implements an M3 Feed Layout displaying color-coded pipeline failures and failed Triangular Checks
// with adaptive grid metrics, SLA freshness benchmarks, and localized text boundary management.

import 'dart:async';
import 'package:flutter/material.dart';

/// Severity classifications aligned with Material 3 dynamic color tokens.
enum AlertSeverity {
  critical,
  triangularFailure,
  warning,
  info,
}

/// Freshness SLA status based on Google Cloud Data Engineering Latency Benchmarks.
enum FreshnessSla {
  good, // ≤1 minute (Ceiling)
  average, // ≤5 minutes (Optimal)
  poor, // ≤15 minutes (Floor Boundary)
  breached, // >15 minutes
}

/// Atomic layout specification container.
class FeedLayoutConfig {
  final String layoutType;
  final int crossAxisCount;
  final double maxCrossAxisExtent;
  final double spacing;
  final WrapAlignment alignment;
  final bool isValidated;

  const FeedLayoutConfig({
    this.layoutType = 'M3 Adaptive Feed Grid',
    this.crossAxisCount = 2,
    this.maxCrossAxisExtent = 420.0,
    this.spacing = 12.0,
    this.alignment = WrapAlignment.start,
    this.isValidated = true,
  });
}

/// Model representing an atomic pipeline or triangular check failure alert.
class PipelineAlertItem {
  final String id;
  final String title;
  final String pipelineStage;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String localizedActionLabel;
  final bool isTriangularCheck;

  const PipelineAlertItem({
    required this.id,
    required this.title,
    required this.pipelineStage,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.localizedActionLabel,
    this.isTriangularCheck = false,
  });

  FreshnessSla get freshnessSla {
    final latency = DateTime.now().difference(timestamp);
    if (latency.inMinutes <= 1) return FreshnessSla.good;
    if (latency.inMinutes <= 5) return FreshnessSla.average;
    if (latency.inMinutes <= 15) return FreshnessSla.poor;
    return FreshnessSla.breached;
  }
}

/// Real-time oversight tool screen featuring an M3 Feed Layout for alert streams.
class PipelineOversightFeedScreen extends StatefulWidget {
  final FeedLayoutConfig layoutConfig;

  const PipelineOversightFeedScreen({
    super.key,
    this.layoutConfig = const FeedLayoutConfig(),
  });

  @override
  State<PipelineOversightFeedScreen> createState() =>
      _PipelineOversightFeedScreenState();
}

class _PipelineOversightFeedScreenState extends State<PipelineOversightFeedScreen> {
  late List<PipelineAlertItem> _alerts;
  String _selectedFilter = 'ALL';
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _alerts = _generateInitialAlerts();
    // Periodic refresh to update relative SLA indicators
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void disposeカット() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  List<PipelineAlertItem> _generateInitialAlerts() {
    final now = DateTime.now();
    return [
      PipelineAlertItem(
        id: 'ALT-1091',
        title: 'Triangular Parity Discrepancy',
        pipelineStage: 'FX Reconciliation Sync',
        description:
            'Validation discrepancy detected between source currency pair conversion and cross-rate ledger.',
        severity: AlertSeverity.triangularFailure,
        timestamp: now.subtract(const Duration(seconds: 40)),
        localizedActionLabel: 'Inspect Ledger',
        isTriangularCheck: true,
      ),
      PipelineAlertItem(
        id: 'ALT-1092',
        title: 'Structural Pipeline Serialization Error',
        pipelineStage: 'UDF Ingestion Worker #4',
        description:
            'Schema definition mismatch in downstream payload ingestion parser.',
        severity: AlertSeverity.critical,
        timestamp: now.subtract(const Duration(minutes: 3)),
        localizedActionLabel: 'Restart Stage',
      ),
      PipelineAlertItem(
        id: 'ALT-1093',
        title: 'Triangular Dimension Check Mismatch',
        pipelineStage: 'Audit Matrix Compute',
        description:
            'Three-way matrix checksum failed invariant boundary test during transformation.',
        severity: AlertSeverity.triangularFailure,
        timestamp: now.subtract(const Duration(minutes: 8)),
        localizedActionLabel: 'View Trace',
        isTriangularCheck: true,
      ),
      PipelineAlertItem(
        id: 'ALT-1094',
        title: 'High Latency Ingestion Buffer Warning',
        pipelineStage: 'Stream Gateway',
        description:
            'Buffer backlog approaching 80% watermark threshold. Consumer scaling recommended.',
        severity: AlertSeverity.warning,
        timestamp: now.subtract(const Duration(minutes: 18)),
        localizedActionLabel: 'Scale Pods',
      ),
      PipelineAlertItem(
        id: 'ALT-1095',
        title: 'Routine Sync Heartbeat Verified',
        pipelineStage: 'Telemetry Exporter',
        description: 'Scheduled batch pipeline sync completed with 0 errors.',
        severity: AlertSeverity.info,
        timestamp: now.subtract(const Duration(seconds: 25)),
        localizedActionLabel: 'Acknowledge',
      ),
    ];
  }

  List<PipelineAlertItem> get _filteredAlerts {
    if (_selectedFilter == 'CRITICAL') {
      return _alerts
          .where((a) =>
              a.severity == AlertSeverity.critical ||
              a.severity == AlertSeverity.triangularFailure)
          .toList();
    }
    if (_selectedFilter == 'TRIANGULAR') {
      return _alerts.where((a) => a.isTriangularCheck).toList();
    }
    return _alerts;
  }

  Color _getSeverityColor(AlertSeverity severity, ColorScheme colorScheme) {
    switch (severity) {
      case AlertSeverity.critical:
        return colorScheme.error;
      case AlertSeverity.triangularFailure:
        return colorScheme.errorContainer;
      case AlertSeverity.warning:
        return colorScheme.tertiary;
      case AlertSeverity.info:
        return colorScheme.secondary;
    }
  }

  Color _getSeverityTextColor(AlertSeverity severity, ColorScheme colorScheme) {
    switch (severity) {
      case AlertSeverity.critical:
        return colorScheme.onError;
      case AlertSeverity.triangularFailure:
        return colorScheme.onErrorContainer;
      case AlertSeverity.warning:
        return colorScheme.onTertiary;
      case AlertSeverity.info:
        return colorScheme.onSecondary;
    }
  }

  Color _getSlaBadgeColor(FreshnessSla sla, ColorScheme colorScheme) {
    switch (sla) {
      case FreshnessSla.good:
        return Colors.teal;
      case FreshnessSla.average:
        return Colors.amber.shade700;
      case FreshnessSla.poor:
        return Colors.deepOrange;
      case FreshnessSla.breached:
        return colorScheme.error;
    }
  }

  String _getSlaLabel(FreshnessSla sla) {
    switch (sla) {
      case FreshnessSla.good:
        return '≤1m (Good)';
      case FreshnessSla.average:
        return '≤5m (Optimal)';
      case FreshnessSla.poor:
        return '≤15m (Floor)';
      case FreshnessSla.breached:
        return '>15m (Breached)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Oversight'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Feed',
            onPressed: () {
              setState(() {
                _alerts = _generateInitialAlerts();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: _buildFilterBar(theme),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final items = _filteredAlerts;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    const [
                  Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.teal),
                  SizedBox(height: 12),
                  Text(
                    'No pipeline failures detected.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(widget.layoutConfig.spacing),
                sliver: SliverToBoxAdapter(
                  child: _buildLayoutStatusBar(theme),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: widget.layoutConfig.spacing),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: widget.layoutConfig.maxCrossAxisExtent,
                    mainAxisSpacing: widget.layoutConfig.spacing,
                    crossAxisSpacing: widget.layoutConfig.spacing,
                    childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.35,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = items[index];
                      return _buildAlertCard(alert, theme, colorScheme);
                    },
                    childCount: items.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All Alerts'),
            selected: _selectedFilter == 'ALL',
            onSelected: (val) => setState(() => _selectedFilter = 'ALL'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Critical & Failures'),
            selected: _selectedFilter == 'CRITICAL',
            onSelected: (val) => setState(() => _selectedFilter = 'CRITICAL'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Triangular Checks'),
            selected: _selectedFilter == 'TRIANGULAR',
            onSelected: (val) => setState(() => _selectedFilter = 'TRIANGULAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutStatusBar(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              widget.layoutConfig.isValidated
                  ? Icons.verified_outlined
                  : Icons.warning_amber_rounded,
              size: 20,
              color: widget.layoutConfig.isValidated
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.layoutConfig.layoutType} • Spacing: ${widget.layoutConfig.spacing.toInt()}dp • Target Freshness: ≤1m',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    PipelineAlertItem alert,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isTriangular = alert.isTriangularCheck;
    final primaryColor = _getSeverityColor(alert.severity, colorScheme);
    final textColor = _getSeverityTextColor(alert.severity, colorScheme);
    final slaStatus = alert.freshnessSla;
    final slaColor = _getSlaBadgeColor(slaStatus, colorScheme);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isTriangular ? colorScheme.error.withValues(alpha: 0.8) : colorScheme.outlineVariant,
          width: isTriangular ? 1.5 : 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected Alert ${alert.id} (${alert.pipelineStage})'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top badges row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert.severity.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isTriangular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.change_circle_outlined,
                              size: 14, color: colorScheme.onErrorContainer),
                          const SizedBox(width: 4),
                          Text(
                            'TRIANGULAR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // SLA Freshness Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: slaColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.Border.all(color: slaColor, width: 0.8),
                    ),
                    child: Text(
                      _getSlaLabel(slaStatus),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: slaColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Alert Title
              Text(
                alert.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Stage & ID
              Text(
                '${alert.id} • ${alert.pipelineStage}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Description
              Expanded(
                child: Text(
                  alert.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // Localized Action Button with character bounds safeguard
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 32,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Executing: ${alert.localizedActionLabel}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      alert.localizedActionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
