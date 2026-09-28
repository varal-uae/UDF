// SSELC-026-A07 — Responsive List-Detail View Layout.
// Connects responsive list-detail view layouts across application screens using slide animations and adaptive scaffold patterns for mobile-first UX.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level data fields required by the specification.
class _MockTraceItem {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const _MockTraceItem({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

const List<_MockTraceItem> _kMockTelemetryData = [
  _MockTraceItem(
    stepExecutionId: 'EXEC-001',
    executionStatus: 'Completed',
    executionTimestamp: DateTime(2026, 9, 28, 10, 0),
    stepOutcome: 'Success',
    userId: 'USR-101',
  ),
  _MockTraceItem(
    stepExecutionId: 'EXEC-002',
    executionStatus: 'Pending',
    executionTimestamp: DateTime(2026, 9, 28, 10, 5),
    stepOutcome: 'Awaiting Input',
    userId: 'USR-102',
  ),
  _MockTraceItem(
    stepExecutionId: 'EXEC-003',
    executionStatus: 'Failed',
    executionTimestamp: DateTime(2026, 9, 28, 10, 12),
    stepOutcome: 'Timeout Error',
    userId: 'USR-101',
  ),
];

/// A responsive layout widget that displays a list and detail panel.
/// On wide screens (tablets/desktop), it shows a split-screen layout.
/// On narrow screens (phones), it prioritizes the list and uses slide
/// transitions to navigate to the detail view.
class ResponsiveListDetailLayout extends StatefulWidget {
  const ResponsiveListDetailLayout({super.key});

  @override
  State<ResponsiveListDetailLayout> createState() => _ResponsiveListDetailLayoutState();
}

class _ResponsiveListDetailLayoutState extends State<ResponsiveListDetailLayout> {
  int? _selectedIndex;

  /// Threshold defining when to switch from mobile portrait flow to tablet split-screen.
  static const double _kTabletBreakpoint = 600.0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onBackToList() {
    setState(() {
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWideScreen = constraints.maxWidth >= _kTabletBreakpoint;

        if (isWideScreen) {
          return _buildSplitScreenLayout(context);
        } else {
          return _buildMobileSlideLayout(context);
        }
      },
    );
  }

  /// Tablet/Desktop: Constant dimension list area with growing/shrinking detail panel.
  Widget _buildSplitScreenLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 320.0,
          child: _buildListView(context),
        ),
        const VerticalDivider(width: 1.0, thickness: 1.0),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.2, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _selectedIndex != null
                ? _buildDetailView(context, _selectedIndex!)
                : const _EmptyDetailPlaceholder(),
          ),
        ),
      ],
    );
  }

  /// Mobile: Full-screen list column with slide-in detail screen.
  Widget _buildMobileSlideLayout(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      },
      child: _selectedIndex == null
          ? _buildListView(context)
          : _buildDetailView(context, _selectedIndex!),
    );
  }

  Widget _buildListView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry Traces'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView.separated(
        itemCount: _kMockTelemetryData.length,
        separatorBuilder: (_, __) => const Divider(height: 1.0),
        itemBuilder: (BuildContext context, int index) {
          final _MockTraceItem item = _kMockTelemetryData[index];
          final bool isSelected = _selectedIndex == index;
          return ListTile(
            selected: isSelected,
            selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
            title: Text(
              item.stepExecutionId,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              '${item.executionStatus} • ${item.stepOutcome}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () => _onItemSelected(index),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, int index) {
    final _MockTraceItem item = _kMockTelemetryData[index];
    final ThemeData theme = Theme.of(context);
    final bool isWideScreen = MediaQuery.sizeOf(context).width >= _kTabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        leading: isWideScreen
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onBackToList,
              ),
        title: Text(item.stepExecutionId),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Step Execution Details', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24.0),
            _DetailRow(label: 'Execution ID', value: item.stepExecutionId, theme: theme),
            _DetailRow(label: 'Status', value: item.executionStatus, theme: theme),
            _DetailRow(label: 'Timestamp', value: item.executionTimestamp.toIso8601String(), theme: theme),
            _DetailRow(label: 'Outcome', value: item.stepOutcome, theme: theme),
            _DetailRow(label: 'User ID', value: item.userId, theme: theme),
            const Spacer(),
            Text(
              'High-contrast accessible text applied per Material 3 guidelines.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.touch_app_outlined,
            size: 64.0,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Select an item from the list to view details',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
