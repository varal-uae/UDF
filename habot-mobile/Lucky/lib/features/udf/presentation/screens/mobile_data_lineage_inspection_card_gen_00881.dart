// GEN-00881 — Automated Mobile Data Lineage Graph Visualizer: Inspection Cards.
// Renders read-only M3 Elevated Card (Level 2, 3dp) inspection cards that display
// transformation_hash, timestamp, and status (Pass/Fail) with M3 Status Chips.
// Responsive single-column on mobile (<600dp), multi-column on desktop (>=840dp).
// Background liveness polling every 30s + pull-to-refresh manual sync.

import 'dart:async';

import 'package:flutter/material.dart';

/// Immutable view-model for a single lineage inspection record.
///
/// Captures the read-only fields mandated by GEN-00881:
/// [transformationHash], [timestamp], and [status].
@immutable
class LineageInspectionRecord {
  const LineageInspectionRecord({
    required this.transformationHash,
    required this.timestamp,
    required this.status,
  });

  /// Hash of the transformation applied in the lineage graph.
  final String transformationHash;

  /// Event/action timestamp captured by the system.
  final DateTime timestamp;

  /// Pass / Fail completion status for this atomic step.
  final LineageInspectionStatus status;
}

/// Enumeration of the binary qualitative output for GEN-00881.
enum LineageInspectionStatus {
  pass,
  fail;

  /// Human-readable label matching the requirement's output field.
  String get label => this == LineageInspectionStatus.pass ? 'Pass' : 'Fail';
}

/// Raised when an inspection snapshot cannot be retrieved from the source.
class LineageInspectionException implements Exception {
  const LineageInspectionException(this.message);

  final String message;

  @override
  String toString() => 'LineageInspectionException: $message';
}

/// Contract for a lineage inspection data source.
///
/// Concrete implementations should stream execution events to BigQuery
/// partitioned by `event_date` and clustered by `trace_id`.
abstract class LineageInspectionRepository {
  /// Fetch the current snapshot of PASS/FAIL inspection records.
  Future<List<LineageInspectionRecord>> fetchInspections();
}

/// Screen that visualizes automated mobile data lineage inspection cards.
///
/// Behaviour:
/// * Read-only M3 KPI cards with status chips and deep-link drill-down.
/// * Single-column layout below 600dp; multi-column at/above 840dp.
/// * Background polling refreshes data every 30 seconds.
/// * Pull-to-refresh triggers a manual sync.
/// * All touch targets honour the 48x48dp minimum.
class MobileDataLineageInspectionCardGen00881 extends StatefulWidget {
  const MobileDataLineageInspectionCardGen00881({
    super.key,
    required this.repository,
    this.pollInterval = const Duration(seconds: 30),
  });

  /// Source of inspection records.
  final LineageInspectionRepository repository;

  /// Liveness handshake cadence (defaults to 30s per GEN-00881).
  final Duration pollInterval;

  @override
  State<MobileDataLineageInspectionCardGen00881> createState() =>
      _MobileDataLineageInspectionCardGen00881State();
}

class _MobileDataLineageInspectionCardGen00881State
    extends State<MobileDataLineageInspectionCardGen00881> {
  static const double _singleColumnBreakpoint = 600;
  static const double _multiColumnBreakpoint = 840;

  Timer? _pollTimer;
  List<LineageInspectionRecord> _records = const <LineageInspectionRecord>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refresh();
    _pollTimer = Timer.periodic(widget.pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Refresh the inspection snapshot and reconcile UI state.
  Future<void> _refresh() async {
    try {
      final List<LineageInspectionRecord> records =
          await widget.repository.fetchInspections();
      if (!mounted) {
        return;
      }
      setState(() {
        _records = records;
        _errorMessage = null;
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unable to load lineage inspections: $error';
        _isLoading = false;
      });
    }
  }

  /// Deep-link drill-down into a single inspection record.
  void _openDrillDown(LineageInspectionRecord record) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Opening trace ${record.transformationHash}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Lineage Inspections'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Builder(
            builder: (BuildContext context) {
              if (_isLoading) {
                return const _CenteredScrollable(
                  child: CircularProgressIndicator(),
                );
              }
              if (_errorMessage != null && _records.isEmpty) {
                return _CenteredScrollable(
                  child: _ErrorState(message: _errorMessage!),
                );
              }
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  final int columns = width >= _multiColumnBreakpoint
                      ? 2
                      : (width < _singleColumnBreakpoint ? 1 : 2);
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: columns == 1 ? 2.4 : 2.0,
                    ),
                    itemCount: _records.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _LineageInspectionCard(
                        record: _records[index],
                        onDrillDown: _openDrillDown,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// M3 Elevated Card (Level 2, 3dp) presenting a single lineage inspection.
class _LineageInspectionCard extends StatelessWidget {
  const _LineageInspectionCard({
    required this.record,
    required this.onDrillDown,
  });

  final LineageInspectionRecord record;
  final ValueChanged<LineageInspectionRecord> onDrillDown;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onDrillDown(record),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Transformation Hash',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  _StatusChip(status: record.status),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                record.transformationHash,
                maxLines: 2,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatTimestamp(record.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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

  static String _formatTimestamp(DateTime value) {
    final DateTime utc = value.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${utc.year}-${two(utc.month)}-${two(utc.day)} '
        '${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)} UTC';
  }
}

/// M3 Status Chip reflecting PASS/FAIL completion state.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LineageInspectionStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isPass = status == LineageInspectionStatus.pass;
    final Color background = isPass
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.errorContainer;
    final Color foreground = isPass
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onErrorContainer;

    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isPass ? Icons.check_circle : Icons.error,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Error state shown when no records could be retrieved.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.cloud_off,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Centres a child inside a scrollable so pull-to-refresh remains usable.
class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
