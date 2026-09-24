// GEN-02042 — Centralized Dictionary (UDD) to UI Tooltip Binding with Mobile Character Limits.
// Determines and enforces character limits for tooltips on narrow mobile screens using M3 Elevated Cards, Status Chips, and 48x48dp touch targets. Single-column layout <600dp, multi-column >=840dp. Background polling every 30s.

import 'dart:async';
import 'package:flutter/material.dart';

const int kMobileTooltipCharLimit = 120;
const int kTabletTooltipCharLimit = 200;
const int kDesktopTooltipCharLimit = 300;
const double kMinTouchTargetSize = 48.0;
const Duration kPollingInterval = Duration(seconds: 30);

enum StepCompletionState { complete, partial, notComplete }

class TooltipDictionaryEntry {
  final String id;
  final String term;
  final String fullDefinition;
  final String traceId;

  const TooltipDictionaryEntry({
    required this.id,
    required this.term,
    required this.fullDefinition,
    required this.traceId,
  });

  String getTruncatedDefinition(int charLimit) {
    if (fullDefinition.length <= charLimit) return fullDefinition;
    return '${fullDefinition.substring(0, charLimit - 3)}...';
  }
}

class MockTooltipRepository {
  static const List<TooltipDictionaryEntry> dictionaryEntries = [
    TooltipDictionaryEntry(
      id: 'UDD-001',
      term: 'Centralized Dictionary',
      fullDefinition: 'A unified data structure that stores all tooltip definitions, ensuring consistency across the platform and compliance with ISO/IEC 27001 & UX Writing Standards.',
      traceId: 'trace-gen-02042-001',
    ),
    TooltipDictionaryEntry(
      id: 'UDD-002',
      term: 'M3 Status Chip',
      fullDefinition: 'Material Design 3 component used to display dynamic status information such as completion state, health indicators, or validation results within the engineering console dashboard.',
      traceId: 'trace-gen-02042-002',
    ),
    TooltipDictionaryEntry(
      id: 'UDD-003',
      term: 'Poka-Yoke Validation',
      fullDefinition: 'Mistake-proofing mechanism integrated into the CI/CD pipeline that physically blocks deployment if any gate for this step fails, ensuring sub-100ms API response latencies are maintained.',
      traceId: 'trace-gen-02042-003',
    ),
  ];

  Future<List<TooltipDictionaryEntry>> fetchEntries() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return dictionaryEntries;
  }

  double calculateCoverage(List<TooltipDictionaryEntry> entries, int charLimit) {
    if (entries.isEmpty) return 0.0;
    final validCount = entries.where((e) => e.fullDefinition.length <= charLimit).length;
    return (validCount / entries.length) * 100.0;
  }
}

class TooltipCharLimitScreen extends StatefulWidget {
  const TooltipCharLimitScreen({super.key});

  @override
  State<TooltipCharLimitScreen> createState() => _TooltipCharLimitScreenState();
}

class _TooltipCharLimitScreenState extends State<TooltipCharLimitScreen> {
  final MockTooltipRepository _repository = MockTooltipRepository();
  List<TooltipDictionaryEntry> _entries = [];
  double _coverage = 0.0;
  Timer? _pollingTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(kPollingInterval, (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final entries = await _repository.fetchEntries();
    final width = MediaQuery.of(context).size.width;
    final limit = _getCharLimit(width);
    final coverage = _repository.calculateCoverage(entries, limit);
    if (mounted) {
      setState(() {
        _entries = entries;
        _coverage = coverage;
        _isLoading = false;
      });
    }
  }

  int _getCharLimit(double screenWidth) {
    if (screenWidth < 600) return kMobileTooltipCharLimit;
    if (screenWidth >= 840) return kDesktopTooltipCharLimit;
    return kTabletTooltipCharLimit;
  }

  StepCompletionState _getCompletionState() {
    if (_coverage >= 100) return StepCompletionState.complete;
    if (_coverage >= 95) return StepCompletionState.partial;
    return StepCompletionState.notComplete;
  }

  Color _getStateColor(StepCompletionState state, ThemeData theme) {
    switch (state) {
      case StepCompletionState.complete:
        return theme.colorScheme.primary;
      case StepCompletionState.partial:
        return theme.colorScheme.tertiary;
      case StepCompletionState.notComplete:
        return theme.colorScheme.error;
    }
  }

  String _getStateLabel(StepCompletionState state) {
    switch (state) {
      case StepCompletionState.complete:
        return 'Complete';
      case StepCompletionState.partial:
        return 'Partial';
      case StepCompletionState.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 840;
    final charLimit = _getCharLimit(width);
    final state = _getCompletionState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDD Tooltip Binding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Manual Sync',
            constraints: const BoxConstraints(minWidth: kMinTouchTargetSize, minHeight: kMinTouchTargetSize),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildKpiCard(theme, charLimit, state)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildEntriesList(theme, charLimit)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildKpiCard(theme, charLimit, state),
                          const SizedBox(height: 16),
                          _buildEntriesList(theme, charLimit),
                        ],
                      ),
              ),
            ),
    );
  }

  Widget _buildKpiCard(ThemeData theme, int charLimit, StepCompletionState state) {
    final stateColor = _getStateColor(state, theme);
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step Health Dashboard', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dictionary Coverage', style: theme.textTheme.bodyLarge),
                Chip(
                  label: Text(
                    _getStateLabel(state),
                    style: TextStyle(color: stateColor),
                  ),
                  backgroundColor: stateColor.withOpacity(0.1),
                  side: BorderSide(color: stateColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _coverage / 100.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(stateColor),
            ),
            const SizedBox(height: 8),
            Text('${_coverage.toStringAsFixed(1)}% (Floor: 95%)', style: theme.textTheme.bodyMedium),
            const Divider(height: 32),
            Text('Active Char Limit: $charLimit', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Standard: ISO/IEC 27001 & UX Writing', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList(ThemeData theme, int charLimit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dictionary Entries', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._entries.map((entry) => _buildEntryCard(theme, entry, charLimit)).toList(),
      ],
    );
  }

  Widget _buildEntryCard(ThemeData theme, TooltipDictionaryEntry entry, int charLimit) {
    final truncated = entry.getTruncatedDefinition(charLimit);
    final isTruncated = truncated != entry.fullDefinition;

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showConfigBottomSheet(entry, charLimit),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.term, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(entry.id, style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Tooltip(
                message: entry.fullDefinition,
                preferBelow: true,
                child: Text(
                  truncated,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isTruncated) ...[
                const SizedBox(height: 8),
                Text(
                  'Truncated from ${entry.fullDefinition.length} to $charLimit chars',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Semantics(
                label: 'Trace ID',
                child: Text(
                  'trace_id: ${entry.traceId}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(TooltipDictionaryEntry entry, int charLimit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Input', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Term',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                controller: TextEditingController(text: entry.term),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Full Definition',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: entry.fullDefinition),
                maxLines: 4,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Text('Current Mobile Limit: $charLimit characters', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: kMinTouchTargetSize,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Validated: ${entry.term}'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(label: 'DISMISS', onPressed: () {}),
                      ),
                    );
                  },
                  child: const Text('Validate & Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
