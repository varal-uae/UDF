// SSELC-023-A07 — Split-Screen Byt Deconstruction Crop Box Component.
// Implements a touch-locked, single-action crop box that isolates document regions within a 360px mobile viewport, preventing double-scroll and cognitive overload using Material 3 elevation shifts.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing the isolated document region for testing.
class _MockBytRegion {
  final String id;
  final String title;
  final String content;
  final String testType;
  final String testResult;
  final double testCoverage;
  final DateTime testTimestamp;
  final String testLogPath;

  const _MockBytRegion({
    required this.id,
    required this.title,
    required this.content,
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testTimestamp,
    required this.testLogPath,
  });
}

const List<_MockBytRegion> _mockRegions = [
  _MockBytRegion(
    id: 'BYT-001',
    title: 'Invoice Total Amount',
    content: 'AED 4,500.00',
    testType: 'Functional',
    testResult: 'Pass',
    testCoverage: 1.0,
    testTimestamp: null,
    testLogPath: '/logs/byt_001.log',
  ),
  _MockBytRegion(
    id: 'BYT-002',
    title: 'Vendor Tax ID',
    content: '1004938271',
    testType: 'Validation',
    testResult: 'Pass',
    testCoverage: 0.98,
    testTimestamp: null,
    testLogPath: '/logs/byt_002.log',
  ),
];

/// A reusable template component that deconstructs screens into single-action Byts.
/// Enforces strict viewport constraints to block double scroll interactions.
class SplitScreenBytCropBox extends StatefulWidget {
  final VoidCallback? onTimeoutEscalation;

  const SplitScreenBytCropBox({
    super.key,
    this.onTimeoutEscalation,
  });

  @override
  State<SplitScreenBytCropBox> createState() => _SplitScreenBytCropBoxState();
}

class _SplitScreenBytCropBoxState extends State<SplitScreenBytCropBox> {
  int _currentIndex = 0;
  bool _isLocked = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isLocked) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _isLocked = true;
          _timer?.cancel();
          widget.onTimeoutEscalation?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _completeAction() {
    if (_isLocked) return;
    setState(() {
      if (_currentIndex < _mockRegions.length - 1) {
        _currentIndex++;
        _remainingSeconds = 60;
        _startCountdown();
      } else {
        _isLocked = true;
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final region = _mockRegions[_currentIndex];

    // Constrain strictly to active device window scopes (max 360px width for mobile-first)
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 600),
        child: ClipRect(
          // Container clipping mapping bounds to mask irrelevant document context
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            body: Column(
              children: [
                // Countdown Timer & Lock Status Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: _isLocked ? colorScheme.errorContainer : colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task ${_currentIndex + 1}/${_mockRegions.length}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _isLocked ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _isLocked ? Icons.lock : Icons.timer_outlined,
                            size: 16,
                            color: _isLocked ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isLocked ? 'LOCKED' : _formatTime(_remainingSeconds),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isLocked ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Primary Observation Surface with distinct surface elevation shift
                Expanded(
                  child: SingleChildScrollView(
                    // Prevents double scroll interactions by constraining physics when locked
                    physics: _isLocked ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4.0,
                      surfaceTintColor: colorScheme.surfaceTint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              region.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // The actual isolated data point
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                region.content,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Atomic-level data fields display
                            _buildMetaRow(theme, 'Test Type', region.testType),
                            _buildMetaRow(theme, 'Test Result', region.testResult),
                            _buildMetaRow(theme, 'Test Coverage', '${(region.testCoverage * 100).toStringAsFixed(0)}%'),
                            _buildMetaRow(theme, 'Log Path', region.testLogPath),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Action Card separated by sharp structural contrast parameters
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: _isLocked ? null : _completeAction,
                    icon: Icon(_isLocked ? Icons.lock : Icons.check_circle_outline),
                    label: Text(_isLocked ? 'Escalated / Locked' : 'Confirm & Next'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56), // Thumb-friendly action
                      textStyle: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
