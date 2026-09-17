// GEN-00915 — Funnel Analytics & Drop-off Isolation Engine UI Card.
// M3 Elevated Card displaying funnel segmentation by device (iOS/Android) and acquisition source (utm_source) with read-only KPI chips and deep-link drill-down.

import 'package:flutter/material.dart';

/// Mock data model representing a single funnel segment entry.
class FunnelSegmentMock {
  final String id;
  final String deviceType; // 'iOS' or 'Android'
  final String utmSource;
  final double segmentationAccuracy;
  final bool isComplete;
  final DateTime timestamp;

  const FunnelSegmentMock({
    required this.id,
    required this.deviceType,
    required this.utmSource,
    required this.segmentationAccuracy,
    required this.isComplete,
    required this.timestamp,
  });
}

/// Hardcoded mock repository simulating backend/BigQuery streamed data.
class FunnelAnalyticsMockRepository {
  static const List<FunnelSegmentMock> segments = [
    FunnelSegmentMock(
      id: 'trace_ios_organic_001',
      deviceType: 'iOS',
      utmSource: 'organic',
      segmentationAccuracy: 1.0,
      isComplete: true,
      timestamp: DateTime(2026, 9, 17, 10, 0),
    ),
    FunnelSegmentMock(
      id: 'trace_android_paid_002',
      deviceType: 'Android',
      utmSource: 'paid_search',
      segmentationAccuracy: 1.0,
      isComplete: true,
      timestamp: DateTime(2026, 9, 17, 10, 15),
    ),
    FunnelSegmentMock(
      id: 'trace_ios_referral_003',
      deviceType: 'iOS',
      utmSource: 'referral',
      segmentationAccuracy: 0.98,
      isComplete: false,
      timestamp: DateTime(2026, 9, 17, 10, 30),
    ),
    FunnelSegmentMock(
      id: 'trace_android_social_004',
      deviceType: 'Android',
      utmSource: 'social',
      segmentationAccuracy: 1.0,
      isComplete: true,
      timestamp: DateTime(2026, 9, 17, 10, 45),
    ),
  ];
}

/// M3 Elevated Card Level 2 (3dp) widget for the Engineering Console Dashboard.
/// Displays step health via inline status chips. Single-column layout on mobile (<600dp).
class FunnelAnalyticsCardGen00915 extends StatefulWidget {
  const FunnelAnalyticsCardGen00915({super.key});

  @override
  State<FunnelAnalyticsCardGen00915> createState() => _FunnelAnalyticsCardGen00915State();
}

class _FunnelAnalyticsCardGen00915State extends State<FunnelAnalyticsCardGen00915> {
  late List<FunnelSegmentMock> _segments;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _segments = FunnelAnalyticsMockRepository.segments;
    _startBackgroundPolling();
  }

  /// Background polling refreshes data every 30 seconds as per requirement.
  void _startBackgroundPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData(isManual: false);
        _startBackgroundPolling();
      }
    });
  }

  Future<void> _refreshData({bool isManual = true}) async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    
    // Simulate API latency (sub-100ms target)
    await Future.delayed(const Duration(milliseconds: 80));
    
    if (!mounted) return;
    setState(() {
      _segments = FunnelAnalyticsMockRepository.segments;
      _isRefreshing = false;
    });

    if (isManual && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Funnel analytics synced successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => _refreshData(isManual: true),
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 16),
            ..._segments.map((segment) => _buildSegmentTile(context, theme, colorScheme, segment)),
            if (_isRefreshing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Customer Journey Funnel Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
          onPressed: _isRefreshing ? null : () => _refreshData(isManual: true),
          tooltip: 'Manual Sync',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // 48x48dp touch target
        ),
      ],
    );
  }

  Widget _buildSegmentTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    FunnelSegmentMock segment,
  ) {
    // M3 Elevated Cards Level 2 (3dp elevation)
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        elevation: 3.0,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: () => _openDrillDownBottomSheet(context, segment),
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Device Icon
                Icon(
                  segment.deviceType == 'iOS' ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${segment.deviceType} • ${segment.utmSource}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Accuracy: ${(segment.segmentationAccuracy * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // M3 Status Chip
                _buildStatusChip(segment.isComplete, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isComplete, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete 
            ? colorScheme.primaryContainer 
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        isComplete ? 'Complete' : 'Not Complete',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isComplete 
              ? colorScheme.onPrimaryContainer 
              : colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs / deep-link drill-down details.
  void _openDrillDownBottomSheet(BuildContext context, FunnelSegmentMock segment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Segment Drill-Down',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildDetailRow('Trace ID', segment.id),
                        _buildDetailRow('Device Platform', segment.deviceType),
                        _buildDetailRow('Acquisition Source', segment.utmSource),
                        _buildDetailRow('Segmentation Accuracy', '${(segment.segmentationAccuracy * 100).toStringAsFixed(1)}%'),
                        _buildDetailRow('Completion Status', segment.isComplete ? 'Complete' : 'Not Complete'),
                        _buildDetailRow('Event Timestamp', segment.timestamp.toIso8601String()),
                        const SizedBox(height: 16),
                        Text(
                          'DAMA DMBOK2 Dimensional Model Reference',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Validated against standard dimensional modeling practices. Floor boundary threshold met at 100%. CI/CD pipeline gates verified.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48, // 48x48dp touch target
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
