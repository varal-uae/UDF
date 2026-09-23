// GEN-01963 — True Black Theme Step Completion Card.
// Renders an M3 Elevated Card with true-black pixels for OLED displays, displaying step completion state with mock telemetry data.

import 'package:flutter/material.dart';

/// Mock data model representing the step execution event streamed to BigQuery.
class StepCompletionEvent {
  final String atomicId;
  final String globalRefId;
  final String description;
  final String completionStatus; // 'Complete', 'Partial', 'Not Complete'
  final double completionRate;
  final DateTime timestamp;
  final String sessionId;

  const StepCompletionEvent({
    required this.atomicId,
    required this.globalRefId,
    required this.description,
    required this.completionStatus,
    required this.completionRate,
    required this.timestamp,
    required this.sessionId,
  });
}

/// Realistic local mock data simulating backend API response.
const List<StepCompletionEvent> mockStepEvents = [
  StepCompletionEvent(
    atomicId: 'GEN-01963',
    globalRefId: 'GEN-01963',
    description: 'Render true-black pixels to reduce eye strain and save battery life.',
    completionStatus: 'Complete',
    completionRate: 99.5,
    timestamp: DateTime(2026, 9, 23, 10, 15, 0),
    sessionId: 'sess_udf_8832a1',
  ),
];

/// A Material 3 Elevated Card (Level 2, 3dp elevation) that uses true-black
/// background (#000000) to reduce eye strain and save battery on OLED screens.
/// Implements single-column mobile layout (<600dp) with 48x48dp touch targets.
class TrueBlackThemeCardGen01963 extends StatelessWidget {
  final StepCompletionEvent event;

  const TrueBlackThemeCardGen01963({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      color: const Color(0xFF000000), // True-black pixels
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.atomicId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(event.completionStatus, colorScheme),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.87),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Completion Rate:',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${event.completionRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: event.completionRate >= 90.0
                        ? colorScheme.primary
                        : colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Last Sync: ${event.timestamp.toLocal().toString().substring(0, 19)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16.0),
            // 48x48dp touch target for deep-link drill-down
            SizedBox(
              height: 48.0,
              width: 48.0,
              child: IconButton(
                onPressed: () {
                  _showConfigurationBottomSheet(context, event);
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                ),
                tooltip: 'View Details',
                iconSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color chipColor;
    switch (status) {
      case 'Complete':
        chipColor = colorScheme.primaryContainer;
        break;
      case 'Partial':
        chipColor = colorScheme.tertiaryContainer;
        break;
      case 'Not Complete':
      default:
        chipColor = colorScheme.errorContainer;
        break;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontSize: 12.0,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showConfigurationBottomSheet(
    BuildContext context,
    StepCompletionEvent event,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000000), // True-black bottom sheet
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Step Configuration Details',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16.0),
              _buildDetailRow(ctx, 'Atomic ID', event.atomicId),
              _buildDetailRow(ctx, 'Global Ref', event.globalRefId),
              _buildDetailRow(ctx, 'Status', event.completionStatus),
              _buildDetailRow(ctx, 'Session', event.sessionId),
              _buildDetailRow(ctx, 'Standard', 'ISO/IEC 27001:2022'),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration synced successfully.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    );
                  },
                  child: const Text('Sync Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper widget to render the list of cards using mock data.
/// Implements pull-to-refresh and responsive single-column layout.
class TrueBlackStepDashboardGen01963 extends StatefulWidget {
  const TrueBlackStepDashboardGen01963({super.key});

  @override
  State<TrueBlackStepDashboardGen01963> createState() => _TrueBlackStepDashboardGen01963State();
}

class _TrueBlackStepDashboardGen01963State extends State<TrueBlackStepDashboardGen01963> {
  List<StepCompletionEvent> _events = mockStepEvents;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _startBackgroundPolling();
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  /// Background polling refreshes data every 30 seconds.
  void _startBackgroundPolling() {
    _isPolling = true;
    Future.delayed(const Duration(seconds: 30), () {
      if (_isPolling && mounted) {
        _refreshData();
        _startBackgroundPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    // Simulate network delay for pull-to-refresh manual sync
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        // In production, fetch from BigQuery / API. Using mock data here.
        _events = List.from(mockStepEvents);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // True-black scaffold
      appBar: AppBar(
        title: const Text('Engineering Console'),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            if (constraints.maxWidth >= 840) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return TrueBlackThemeCardGen01963(event: _events[index]);
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return TrueBlackThemeCardGen01963(event: _events[index]);
              },
            );
          },
        ),
      ),
    );
  }
}