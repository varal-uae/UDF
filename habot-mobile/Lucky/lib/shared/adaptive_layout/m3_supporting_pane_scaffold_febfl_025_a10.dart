// FEBFL-025-A10 — Material 3 Supporting Pane Layout Scaffold.
// Implements MD3 window size classes (Compact, Medium, Expanded) with responsive single-column mobile flow, sticky supporting pane for filters and search metrics, and accessible fade-slide transitions.

import 'package:flutter/material.dart';

/// Window size class based on standard Material 3 canonical layout guidelines.
enum M3WindowSizeClass {
  compact,
  medium,
  expanded;

  static M3WindowSizeClass fromWidth(double width) {
    if (width < 600) {
      return M3WindowSizeClass.compact;
    } else if (width < 840) {
      return M3WindowSizeClass.medium;
    } else {
      return M3WindowSizeClass.expanded;
    }
  }
}

/// Telemetry payload for layout lifecycle and execution tracking.
class LayoutExecutionTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final M3WindowSizeClass windowClass;

  const LayoutExecutionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.windowClass,
  });

  Map<String, dynamic> toMap() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'window_size_class': windowClass.name,
      };
}

/// Filter & metrics model controlled via the supporting pane.
class SupportingPaneFilterState {
  final String searchQuery;
  final Set<String> activeFilters;
  final double thresholdValue;
  final int totalCount;
  final int filteredCount;

  const SupportingPaneFilterState({
    this.searchQuery = '',
    this.activeFilters = const {},
    this.thresholdValue = 100.0,
    this.totalCount = 0,
    this.filteredCount = 0,
  });

  SupportingPaneFilterState copyWith({
    String? searchQuery,
    Set<String>? activeFilters,
    double? thresholdValue,
    int? totalCount,
    int? filteredCount,
  }) {
    return SupportingPaneFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      thresholdValue: thresholdValue ?? this.thresholdValue,
      totalCount: totalCount ?? this.totalCount,
      filteredCount: filteredCount ?? this.filteredCount,
    );
  }
}

/// Material 3 Canonical Layout Scaffold implementing Supporting Pane pattern.
class M3SupportingPaneScaffoldFEBFL025A10 extends StatefulWidget {
  final String userId;
  final String stepExecutionId;
  final Widget mainContent;
  final Widget? customSupportingPane;
  final List<String> availableFilterTags;
  final ValueChanged<SupportingPaneFilterState>? onFilterChanged;
  final ValueChanged<LayoutExecutionTelemetry>? onTelemetryLogged;
  final VoidCallback? onPrimaryActionPressed;

  const M3SupportingPaneScaffoldFEBFL025A10({
    super.key,
    this.userId = 'system_user',
    this.stepExecutionId = 'FEBFL-025-A10-INIT',
    required this.mainContent,
    this.customSupportingPane,
    this.availableFilterTags = const ['Active', 'Pending', 'Verified', 'Urgent'],
    this.onFilterChanged,
    this.onTelemetryLogged,
    this.onPrimaryActionPressed,
  });

  @override
  State<M3SupportingPaneScaffoldFEBFL025A10> createState() =>
      _M3SupportingPaneScaffoldFEBFL025A10State();
}

class _M3SupportingPaneScaffoldFEBFL025A10State
    extends State<M3SupportingPaneScaffoldFEBFL025A10> {
  late SupportingPaneFilterState _filterState;
  late TextEditingController _searchController;
  M3WindowSizeClass? _lastSizeClass;

  @override
  void initState() {
    super.initState();
    _filterState = const SupportingPaneFilterState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _emitTelemetry(M3WindowSizeClass windowClass, String status, String outcome) {
    final telemetry = LayoutExecutionTelemetry(
      stepExecutionId: widget.stepExecutionId,
      executionStatus: status,
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: outcome,
      userId: widget.userId,
      windowClass: windowClass,
    );
    widget.onTelemetryLogged?.call(telemetry);
  }

  void _toggleFilterTag(String tag) {
    setState(() {
      final updatedTags = Set<String>.from(_filterState.activeFilters);
      if (updatedTags.contains(tag)) {
        updatedTags.remove(tag);
      } else {
        updatedTags.add(tag);
      }
      _filterState = _filterState.copyWith(activeFilters: updatedTags);
    });
    widget.onFilterChanged?.call(_filterState);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _filterState = _filterState.copyWith(searchQuery: query);
    });
    widget.onFilterChanged?.call(_filterState);
  }

  void _showMobileFilterModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(modalContext).size.height * 0.7,
            child: _buildSupportingPaneWidget(modalContext, isModal: true),
          ),
        );
      },
    );
  }

  Widget _buildSupportingPaneWidget(BuildContext context, {required bool isModal}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Search and Filtering Supporting Pane',
      child: Container(
        width: isModal ? double.infinity : 320,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: isModal
              ? null
              : Border(left: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search & Filters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (_filterState.activeFilters.isNotEmpty ||
                          _filterState.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filterState = const SupportingPaneFilterState();
                            });
                            widget.onFilterChanged?.call(_filterState);
                          },
                          child: const Text('Reset'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2.0),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search metrics & cards...',
                    leading: const Icon(Icons.search, size: 20),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _updateSearchQuery('');
                          },
                        ),
                    ],
                    onChanged: _updateSearchQuery,
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3.0),
                  child: Text(
                    'Metrics Scope',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.availableFilterTags.map((tag) {
                    final isSelected = _filterState.activeFilters.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => _toggleFilterTag(tag),
                      showCheckmark: true,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(4.0),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Filters: ${_filterState.activeFilters.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Status: Compliant with MD3 Canonical Spec',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.customSupportingPane != null) ...[
                  const SizedBox(height: 16.0),
                  widget.customSupportingPane!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowSizeClass = M3WindowSizeClass.fromWidth(constraints.maxWidth);

        if (_lastSizeClass != windowSizeClass) {
          _lastSizeClass = windowSizeClass;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _emitTelemetry(
              windowSizeClass,
              'Complete',
              'Window resized to ${windowSizeClass.name}',
            );
          });
        }

        final isExpanded = windowSizeClass == M3WindowSizeClass.expanded;

        return Scaffold(
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey<M3WindowSizeClass>(windowSizeClass),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary scrollable single-column content container
                  Expanded(
                    child: FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: widget.mainContent,
                    ),
                  ),
                  // Supporting pane: locked sticky panel on large/expanded screens
                  if (isExpanded)
                    _buildSupportingPaneWidget(context, isModal: false),
                ],
              ),
            ),
          ),
          // Floating Call-To-Action trigger for compact/mobile form factors
          floatingActionButton: !isExpanded
              ? FloatingActionButton.extended(
                  onPressed: () => _showMobileFilterModal(context),
                  icon: const Icon(Icons.tune),
                  label: const Text('Filters & Metrics'),
                  tooltip: 'Open Supporting Pane Filters',
                )
              : null,
        );
      },
    );
  }
}
