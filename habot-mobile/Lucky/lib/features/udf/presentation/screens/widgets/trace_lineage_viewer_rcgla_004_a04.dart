// RCGLA-004-A04 — TraceLineageViewer Side Sheet Progressive Disclosure Component.
// Implements an adaptive MD3 side sheet that promotes to a bottom modal sheet on narrow screens, capped at 400dp width, with asynchronous mock lineage log fetching and error surfacing for missing trace IDs.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Domain model representing a single configuration change log entry.
class LineageLogEntry {
  final String traceId;
  final String configurationParameter;
  final String currentSetting;
  final String previousSetting;
  final String changeLog;
  final DateTime configurationTimestamp;
  final String completionStatus;
  final String userId;

  const LineageLogEntry({
    required this.traceId,
    required this.configurationParameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.changeLog,
    required this.configurationTimestamp,
    required this.completionStatus,
    required this.userId,
  });
}

/// Mock repository simulating asynchronous deep system lineage log fetching.
class MockLineageRepository {
  static const Uuid _uuid = Uuid();

  static Future<List<LineageLogEntry>> fetchLineageLogs(String parentTraceId) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (parentTraceId.isEmpty) {
      throw Exception('Missing tracking ID: Pipeline architecture break detected.');
    }

    return [
      LineageLogEntry(
        traceId: _uuid.v4(),
        configurationParameter: 'max_retries',
        currentSetting: '5',
        previousSetting: '3',
        changeLog: 'Increased max retries for resilience.',
        configurationTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        completionStatus: 'Complete',
        userId: 'usr_9921',
      ),
      LineageLogEntry(
        traceId: _uuid.v4(),
        configurationParameter: 'timeout_ms',
        currentSetting: '3000',
        previousSetting: '1500',
        changeLog: 'Adjusted timeout threshold based on latency metrics.',
        configurationTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        completionStatus: 'Partial',
        userId: 'usr_4412',
      ),
      LineageLogEntry(
        traceId: '', // Orphaned record to trigger Poka-Yoke error bar
        configurationParameter: 'cache_ttl',
        currentSetting: '600',
        previousSetting: '300',
        changeLog: 'Extended cache time-to-live.',
        configurationTimestamp: DateTime.now().subtract(const Duration(days: 3)),
        completionStatus: 'Not Complete',
        userId: 'system',
      ),
    ];
  }
}

/// Adaptive progressive disclosure viewer component.
/// Applies strict 400dp sizing caps on desktop and promotes to immersive modal sheets on mobile.
class TraceLineageViewer extends StatefulWidget {
  final String parentTraceId;

  const TraceLineageViewer({
    super.key,
    required this.parentTraceId,
  });

  /// Opens the viewer respecting mobile-first responsive UX constraints.
  static void show(BuildContext context, {required String parentTraceId}) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    const double mobileThreshold = 600.0;
    const double maxSheetWidth = 400.0;

    if (screenWidth < mobileThreshold) {
      // Mobile-First Implication: Native bottom sheet to preserve tight text area bounds
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => TraceLineageViewer(
            parentTraceId: parentTraceId,
          ),
        ),
      );
    } else {
      // Desktop/Wide: Side sheet overlay keeping user anchored in immediate operating flow
      showDialog<void>(
        context: context,
        barrierColor: Colors.black54, // Crisp dimming canvas over background view systems
        barrierDismissible: true,
        builder: (context) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: maxSheetWidth),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(-8, 0),
                  ),
                ],
              ),
              child: TraceLineageViewer(
                parentTraceId: parentTraceId,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<TraceLineageViewer> createState() => _TraceLineageViewerState();
}

class _TraceLineageViewerState extends State<TraceLineageViewer> {
  late Future<List<LineageLogEntry>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  void _fetchLogs() {
    setState(() {
      _logsFuture = MockLineageRepository.fetchLineageLogs(widget.parentTraceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Lineage Trace',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Parent ID: ${widget.parentTraceId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close panel',
              ),
            ],
          ),
        ),
        const Divider(height: 1.0),
        // Content
        Expanded(
          child: FutureBuilder<List<LineageLogEntry>>(
            future: _logsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // Self-Chasing: Semantic red error bar to flash system architecture pipeline breaks
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      color: colorScheme.errorContainer,
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              snapshot.error.toString().replaceFirst('Exception: ', ''),
                              style: TextStyle(color: colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _fetchLogs,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Fetch'),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'No lineage records found.',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(indent: 16.0, endIndent: 16.0),
                itemBuilder: (context, index) {
                  final entry = logs[index];
                  final bool isOrphaned = entry.traceId.isEmpty;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poka-Yoke / Self-Chasing: Missing tracking IDs instantly throw a semantic red error bar
                        if (isOrphaned)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 16.0, color: colorScheme.onErrorContainer),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    'Orphaned Record: Missing Parent Link',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.configurationParameter,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _StatusChip(status: entry.completionStatus),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        _InfoRow(label: 'Current Setting', value: entry.currentSetting, theme: textTheme),
                        _InfoRow(label: 'Previous Setting', value: entry.previousSetting, theme: textTheme),
                        _InfoRow(label: 'Change Log', value: entry.changeLog, theme: textTheme),
                        _InfoRow(
                          label: 'Timestamp',
                          value: '${entry.configurationTimestamp.toLocal()}'.split('.').first,
                          theme: textTheme,
                        ),
                        _InfoRow(label: 'User/Session ID', value: entry.userId, theme: textTheme),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.0,
            child: Text(
              label,
              style: theme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    Color bgColor;
    Color fgColor;
    
    switch (status) {
      case 'Complete':
        bgColor = colorScheme.primaryContainer;
        fgColor = colorScheme.onPrimaryContainer;
        break;
      case 'Partial':
        bgColor = colorScheme.tertiaryContainer;
        fgColor = colorScheme.onTertiaryContainer;
        break;
      case 'Not Complete':
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        break;
      default:
        bgColor = colorScheme.surfaceContainerHighest;
        fgColor = colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}