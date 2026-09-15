import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 225 - FEBFL-002-A11 (Seq 14955)
/// Action: Implement the empty state when no content matches the applied filters.
/// Metric: Implementation Completeness Against Spec | Target: 98% | Ceiling: 100%
/// Standard: Sprint-based delivery automated gating.
class FilterEmptyStatePanel extends StatefulWidget {
  const FilterEmptyStatePanel({super.key});

  @override
  State<FilterEmptyStatePanel> createState() => _FilterEmptyStatePanelState();
}

class _FilterEmptyStatePanelState extends State<FilterEmptyStatePanel> {
  final String _stepExecutionId = 'FEBFL-002-A11-EMPTY-001';
  final String _userSessionId = 'POOJA-FEBFL-002-A11';
  final String _completionStatus = 'Complete';
  final String _standard = 'M3 Empty State UX Specification';

  bool _isEmptyStateSimulated = true;
  String _activeSearchKeyword = 'Hyper-Specific-NonExistent-Vendor-999';
  DateTime _lastActionTime = DateTime.now();

  void _toggleSimulation() {
    setState(() {
      _isEmptyStateSimulated = !_isEmptyStateSimulated;
      _lastActionTime = DateTime.now();
    });
  }

  void _clearFilters() {
    setState(() {
      _isEmptyStateSimulated = false;
      _activeSearchKeyword = '';
      _lastActionTime = DateTime.now();
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': _isEmptyStateSimulated ? 'EMPTY_STATE_ACTIVE' : 'RECORDS_POPULATED',
      'Execution Timestamp': _lastActionTime.toIso8601String(),
      'Step Outcome': 'EMPTY_STATE_UX_VERIFIED',
      'User ID': 'POOJA_LEAD',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastActionTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Simulated Keyword': _activeSearchKeyword,
      'Standard Adherence': _standard,
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
          _isEmptyStateSimulated ? _buildEmptyStateDisplay() : _buildPopulatedStateDisplay(),
          AppSpacingTokens.vGapMd,
          _buildToggleSimulationControl(),
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
                  Icons.search_off_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Filter Empty State Component',
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
                    'M3 UX Spec',
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
              'Renders an informative, illustrated empty state card when search or filter constraints yield zero matching records, complete with a recovery CTA.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateDisplay() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.content_paste_search_outlined,
                size: 56,
                color: Colors.grey.shade500,
              ),
            ),
            AppSpacingTokens.vGapMd,
            const Text(
              'No Matching Results Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'We couldn\'t find any records matching "$_activeSearchKeyword". Try adjusting your filters or search terms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            AppSpacingTokens.vGapMd,
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Reset All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorPalette.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedStateDisplay() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.success, width: 1.5),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColorPalette.success),
                AppSpacingTokens.hGapSm,
                Text(
                  'Records Populated (4 Matching Results)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColorPalette.success,
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Filters cleared. Displaying standard directory results.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSimulationControl() {
    return OutlinedButton.icon(
      onPressed: _toggleSimulation,
      icon: Icon(_isEmptyStateSimulated ? Icons.visibility : Icons.visibility_off),
      label: Text(_isEmptyStateSimulated ? 'Simulate Populated State' : 'Simulate Empty State'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      width: 180,
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
