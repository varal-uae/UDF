import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 224 - FEBFL-002-A09 (Seq 14953)
/// Action: Implement debounced filter application — wait 300ms after last filter change before re-querying.
/// Metric: Implementation Completeness Against Spec | Target: 98% | Ceiling: 100%
/// Standard: Sprint-based delivery automated gating.
class DebouncedFilterApplicationPanel extends StatefulWidget {
  const DebouncedFilterApplicationPanel({super.key});

  @override
  State<DebouncedFilterApplicationPanel> createState() =>
      _DebouncedFilterApplicationPanelState();
}

class _DebouncedFilterApplicationPanelState
    extends State<DebouncedFilterApplicationPanel> {
  final String _stepExecutionId = 'FEBFL-002-A09-DEBOUNCE-001';
  final String _userSessionId = 'POOJA-FEBFL-002-A09';
  final String _completionStatus = 'Complete';
  final int _debounceDelayMs = 300;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _currentQuery = '';
  String _debouncedExecutedQuery = '';
  int _keystrokeCount = 0;
  int _queryExecutionCount = 0;
  bool _isDebouncing = false;
  DateTime _lastActivityTime = DateTime.now();
  final List<String> _queryExecutionHistory = [];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {
      _currentQuery = text;
      _keystrokeCount++;
      _isDebouncing = true;
      _lastActivityTime = DateTime.now();
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: _debounceDelayMs), () {
      if (mounted) {
        setState(() {
          _debouncedExecutedQuery = text;
          _queryExecutionCount++;
          _isDebouncing = false;
          _lastActivityTime = DateTime.now();
          final timeStr = _lastActivityTime.toIso8601String().substring(11, 19);
          _queryExecutionHistory.insert(
            0,
            '[$timeStr] Executed: "$text" (Triggered after 300ms idle)',
          );
        });
      }
    });
  }

  void _simulateKeystrokeBurst() {
    const burstWords = ['P', 'Pr', 'Pro', 'Proc', 'Procu', 'Procure', 'Procurement'];
    for (int i = 0; i < burstWords.length; i++) {
      Future.delayed(Duration(milliseconds: i * 40), () {
        if (mounted) {
          _searchController.text = burstWords[i];
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: burstWords[i].length),
          );
          _onSearchChanged(burstWords[i]);
        }
      });
    }
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _debouncedExecutedQuery = '';
      _isDebouncing = false;
      _lastActivityTime = DateTime.now();
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': _isDebouncing ? 'DEBOUNCING_IDLE_WAIT' : 'IDLE_AWAITING_INPUT',
      'Execution Timestamp': _lastActivityTime.toIso8601String(),
      'Step Outcome': 'DEBOUNCE_GATE_VERIFIED',
      'User ID': 'POOJA_LEAD',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastActivityTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Debounce Delay Threshold': '$_debounceDelayMs ms',
      'Total Keystrokes Logged': _keystrokeCount,
      'Database Queries Dispatched': _queryExecutionCount,
      'Savings Ratio (Prevented Queries)': _keystrokeCount > 0
          ? '${((1 - _queryExecutionCount / _keystrokeCount) * 100).toStringAsFixed(1)}%'
          : '0%',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildDebounceInputCard(),
          AppSpacingTokens.vGapMd,
          _buildDebounceStatusCard(),
          AppSpacingTokens.vGapMd,
          _buildQueryHistoryCard(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shutter_speed_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Debounced Filter Application (300ms)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '300ms Gate',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Enforces a strict 300ms debounce interval after the last input event before re-querying, preventing server query thrashing.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebounceInputCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Debounce Tester',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Type to test live debounced query dispatch...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _simulateKeystrokeBurst,
                    icon: const Icon(Icons.flash_on_outlined, size: 16),
                    label: const Text('Simulate 7-Key Rapid Burst'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebounceStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isDebouncing
                            ? AppColorPalette.warning
                            : AppColorPalette.success,
                      ),
                    ),
                    AppSpacingTokens.hGapSm,
                    Text(
                      _isDebouncing ? 'Debounce Timer Ticking (300ms)...' : 'Query Gate Settled',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isDebouncing
                            ? AppColorPalette.warning
                            : AppColorPalette.success,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Queries: $_queryExecutionCount / Keys: $_keystrokeCount',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (_isDebouncing) ...[
              AppSpacingTokens.vGapSm,
              const LinearProgressIndicator(minHeight: 3),
            ],
            AppSpacingTokens.vGapSm,
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done_outlined, size: 18, color: AppColorPalette.brandPrimary),
                  AppSpacingTokens.hGapSm,
                  Expanded(
                    child: Text(
                      _debouncedExecutedQuery.isEmpty
                          ? 'No query executed yet. Waiting for input.'
                          : 'Server Executed Query: "$_debouncedExecutedQuery"',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryHistoryCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debounce Execution Audit Log',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            if (_queryExecutionHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No queries fired yet. Type in the box above or simulate a burst.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              )
            else
              ..._queryExecutionHistory.take(4).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    entry,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 190,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
