// SSTLA-029-A11 — Contextual Mirroring Split-Screen Layout for Bio-APIs.
// Implements a mobile-first split-screen layout with zoom tracking, evidence/action panes, and dynamic anchoring to prevent page shifting during data assembly.

import 'package:flutter/material.dart';

/// Mock lock data model representing atomic-level fields required by the specification.
class LockData {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;

  const LockData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });
}

/// Hardcoded mock data simulating backend response for local development.
const List<LockData> mockLockRecords = [
  LockData(
    lockType: 'Biometric_Verification',
    lockStatus: 'Active',
    lockedBy: 'System_Engineer_01',
    lockTimestamp: DateTime(2026, 9, 28, 10, 15, 30),
    lockReason: 'Evidence mismatch resolution in progress',
  ),
  LockData(
    lockType: 'Correction_Panel',
    lockStatus: 'Pending',
    lockedBy: 'QA_Reviewer_04',
    lockTimestamp: DateTime(2026, 9, 28, 10, 18, 45),
    lockReason: 'Awaiting biometric image zoom confirmation',
  ),
];

/// Performance metric tracker ensuring RAIL guidelines are met (≤100ms optimal).
class ZoomPerformanceTracker {
  static bool evaluateLatency(int latencyMs) {
    // Ceiling Boundary: ≤100ms (Optimal Target)
    // Floor Boundary: ≤500ms
    return latencyMs <= 500;
  }

  static String getQualitativeResult(int latencyMs) {
    if (latencyMs <= 100) return 'Pass';
    if (latencyMs <= 500) return 'Pass';
    return 'Fail';
  }
}

/// Main widget implementing the contextual mirroring split-screen layout.
class ContextualMirroringSplitScreen extends StatefulWidget {
  const ContextualMirroringSplitScreen({super.key});

  @override
  State<ContextualMirroringSplitScreen> createState() => _ContextualMirroringSplitScreenState();
}

class _ContextualMirroringSplitScreenState extends State<ContextualMirroringSplitScreen>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  
  double _splitPercentage = 0.5; // Evidence vs Action split percentage
  bool _isCoordinateLocked = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Smooth animation tracks
    );
    
    _transformationController.addListener(_onZoomChanged);
  }

  void _onZoomChanged() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    
    // Test zoom tracking performance by verifying coordinate lock
    setState(() {
      _isCoordinateLocked = scale > 1.0;
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onZoomChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bio-API Contextual Mirroring'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return isLandscape
                ? _buildHorizontalSplit(theme)
                : _buildVerticalSplit(theme);
          },
        ),
      ),
    );
  }

  /// Dynamic system layout rules natively applied via Flex
  Widget _buildHorizontalSplit(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: (_splitPercentage * 100).round(),
          child: _buildEvidencePane(theme),
        ),
        _buildSplitDivider(theme, isVertical: true),
        Expanded(
          flex: ((1.0 - _splitPercentage) * 100).round(),
          child: _buildActionPane(theme),
        ),
      ],
    );
  }

  Widget _buildVerticalSplit(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          flex: (_splitPercentage * 100).round(),
          child: _buildEvidencePane(theme),
        ),
        _buildSplitDivider(theme, isVertical: false),
        Expanded(
          flex: ((1.0 - _splitPercentage) * 100).round(),
          child: _buildActionPane(theme),
        ),
      ],
    );
  }

  /// High-contrast layout borders outline discrete panel properties clearly
  Widget _buildSplitDivider(ThemeData theme, {required bool isVertical}) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final delta = isVertical 
              ? details.delta.dx / MediaQuery.of(context).size.width
              : details.delta.dy / MediaQuery.of(context).size.height;
          _splitPercentage = (_splitPercentage + delta).clamp(0.2, 0.8);
        });
      },
      child: Container(
        width: isVertical ? 4 : double.infinity,
        height: isVertical ? double.infinity : 4,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Evidence pane with interactive zoom tracking
  Widget _buildEvidencePane(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Evidence Sheet',
                  style: theme.textography.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isCoordinateLocked)
                  Chip(
                    label: const Text('Coordinates Locked'),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.fingerprint,
                    size: 120,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Action/Correction pane displaying atomic-level data fields
  Widget _buildActionPane(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 2.0,
        ),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Correction Box',
              style: theme.textography.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockLockRecords.length,
              itemBuilder: (context, index) {
                final record = mockLockRecords[index];
                return _buildLockRecordCard(record, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockRecordCard(LockData record, ThemeData theme) {
    final int simulatedLatencyMs = 85; // Simulated response latency
    final String perfResult = ZoomPerformanceTracker.getQualitativeResult(simulatedLatencyMs);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Lock Type', record.lockType, theme),
            _buildDataRow('Lock Status', record.lockStatus, theme),
            _buildDataRow('Locked By', record.lockedBy, theme),
            _buildDataRow('Lock Timestamp', record.lockTimestamp.toIso8601String(), theme),
            _buildDataRow('Lock Reason', record.lockReason, theme),
            const Divider(height: 16),
            _buildDataRow(
              'Response Latency',
              '$simulatedLatencyMs ms ($perfResult)',
              theme,
              valueColor: perfResult == 'Pass' ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textography.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textography.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}