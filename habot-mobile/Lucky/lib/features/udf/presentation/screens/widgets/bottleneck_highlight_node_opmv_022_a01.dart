// OPMV-022-A01 — BottleneckHighlightNode algorithmic delay visualization wrapper.
// Provides a Material 3 responsive widget that visualizes pipeline latency and bottlenecks using standardized color tokens and mock data lakehouse inputs.

import 'package:flutter/material.dart';

/// Mock data model representing an atomic-level bottleneck entry.
class BottleneckEntry {
  final String objectType;
  final String objectPath;
  final bool isOpen;
  final DateTime timestamp;
  final String fileHandleId;
  final Duration latency;

  const BottleneckEntry({
    required this.objectType,
    required this.objectPath,
    required this.isOpen,
    required this.timestamp,
    required this.fileHandleId,
    required this.latency,
  });
}

/// Hardcoded mock data simulating active data lakehouses and tracking clocks
/// as required by dependencies HC-PAD-0002 and HC-PAD-0013.
const List<BottleneckEntry> _mockBottleneckData = [
  BottleneckEntry(
    objectType: 'Transaction',
    objectPath: '/data/lakehouse/transactions/stream_01',
    isOpen: true,
    timestamp: DateTime(2026, 9, 23, 10, 15),
    fileHandleId: 'FH-99281-A',
    latency: Duration(milliseconds: 1250),
  ),
  BottleneckEntry(
    objectType: 'Query',
    objectPath: '/data/lakehouse/analytics/heavy_query_04',
    isOpen: true,
    timestamp: DateTime(2026, 9, 23, 10, 18),
    fileHandleId: 'FH-99282-B',
    latency: Duration(seconds: 3, milliseconds: 400),
  ),
  BottleneckEntry(
    objectType: 'Sync',
    objectPath: '/data/lakehouse/sync/clock_tracker',
    isOpen: false,
    timestamp: DateTime(2026, 9, 23, 09, 50),
    fileHandleId: 'FH-99283-C',
    latency: Duration(milliseconds: 120),
  ),
];

/// Standardized corporate color style tokens for latency thresholds.
class LatencyColorTokens {
  static const Color optimal = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color critical = Color(0xFFF44336); // Bright Red

  static Color resolve(Duration latency) {
    if (latency.inMilliseconds > 2000) return critical;
    if (latency.inMilliseconds > 800) return warning;
    return optimal;
  }
}

/// A reusable design token component transferable across tracks.
/// Visualizes algorithmic delays and isolates lagging steps immediately.
class BottleneckHighlightNode extends StatelessWidget {
  final List<BottleneckEntry> entries;

  const BottleneckHighlightNode({
    super.key,
    this.entries = _mockBottleneckData,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pipeline Latency Overview',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.timeline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Clean grid sizing metrics to keep layout view proportions highly readable
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isMobile = constraints.maxWidth < 600;
                final int crossAxisCount = isMobile ? 1 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: isMobile ? 3.5 : 4.0,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final BottleneckEntry entry = entries[index];
                    final Color indicatorColor = LatencyColorTokens.resolve(entry.latency);

                    return _BottleneckTile(
                      entry: entry,
                      indicatorColor: indicatorColor,
                      textTheme: textTheme,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottleneckTile extends StatelessWidget {
  final BottleneckEntry entry;
  final Color indicatorColor;
  final TextTheme textTheme;

  const _BottleneckTile({
    required this.entry,
    required this.indicatorColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          // Visual indicator mapped using standardized corporate color style tokens
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
              boxShadow: indicatorColor == LatencyColorTokens.critical
                  ? [
                      BoxShadow(
                        color: indicatorColor.withOpacity(0.4),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${entry.objectType} (${entry.fileHandleId})',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  entry.objectPath,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.latency.inMilliseconds} ms',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: indicatorColor,
                ),
              ),
              Text(
                entry.isOpen ? 'OPEN' : 'CLOSED',
                style: textTheme.labelSmall?.copyWith(
                  color: entry.isOpen ? Colors.redAccent : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}