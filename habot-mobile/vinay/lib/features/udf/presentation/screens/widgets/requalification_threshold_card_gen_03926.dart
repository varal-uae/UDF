// GEN-03926 — Requalification Threshold Status Card.
// Displays the consecutive_requalification_passes count against a threshold of 10 using M3 ElevatedCard and StatusChip. Polls mock data every 30 seconds with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data simulating backend response for requalification passes.
class _MockRequalificationRepository {
  static int _currentPasses = 7;

  static Future<Map<String, dynamic>> fetchStatus() async {
    await Future.delayed(const Duration(milliseconds: 45)); // Simulates < 0.01 ms target conceptually
    _currentPasses = (_currentPasses >= 10) ? 0 : _currentPasses + 1;
    return {
      'consecutive_requalification_passes': _currentPasses,
      'threshold': 10,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': 'mock-session-gen-03926',
    };
  }
}

class RequalificationThresholdCardGen03926 extends StatefulWidget {
  const RequalificationThresholdCardGen03926({super.key});

  @override
  State<RequalificationThresholdCardGen03926> createState() => _RequalificationThresholdCardGen03926State();
}

class _RequalificationThresholdCardGen03926State extends State<RequalificationThresholdCardGen03926> {
  int _passes = 0;
  final int _threshold = 10;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _MockRequalificationRepository.fetchStatus();
      if (mounted) {
        setState(() {
          _passes = data['consecutive_requalification_passes'] as int;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  bool get _hasReachedThreshold => _passes >= _threshold;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
            surfaceTintColor: colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Requalification Status',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(colorScheme),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Consecutive Passes',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (_isLoading)
                    const LinearProgressIndicator()
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$_passes',
                          style: textTheme.displaySmall?.copyWith(
                            color: _hasReachedThreshold
                                ? colorScheme.primary
                                : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                          child: Text(
                            '/ $_threshold',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: _isLoading ? 0.0 : (_passes / _threshold).clamp(0.0, 1.0),
                      minHeight: 8.0,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _hasReachedThreshold ? colorScheme.primary : colorScheme.tertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    _hasReachedThreshold
                        ? 'Threshold reached. Requalification complete.'
                        : 'Requires ${_threshold - _passes} more passes to meet threshold.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    final isPass = _hasReachedThreshold;
    return Chip(
      avatar: Icon(
        isPass ? Icons.check_circle_outline : Icons.pending_outlined,
        size: 18.0,
        color: isPass ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
      ),
      label: Text(
        isPass ? 'Pass' : 'Fail',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isPass ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
        ),
      ),
      backgroundColor: isPass ? colorScheme.secondaryContainer : colorScheme.errorContainer,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
