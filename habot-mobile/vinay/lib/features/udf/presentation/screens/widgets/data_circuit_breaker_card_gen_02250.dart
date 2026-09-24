// GEN-02250 — Data Circuit Breaker Status Card.
// Displays M3 Elevated Card with status chip for packet rejection circuit breaking, background polling every 30s, and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the circuit breaker state.
class CircuitBreakerState {
  final String stepId;
  final String description;
  final bool isCircuitBroken;
  final double integrityAccuracy;
  final DateTime lastChecked;
  final String qualitativeResult;

  const CircuitBreakerState({
    required this.stepId,
    required this.description,
    required this.isCircuitBroken,
    required this.integrityAccuracy,
    required this.lastChecked,
    required this.qualitativeResult,
  });
}

/// Mock repository simulating backend data for GEN-02250.
class MockCircuitBreakerRepository {
  static Future<CircuitBreakerState> fetchState() async {
    await Future.delayed(const Duration(milliseconds: 80)); // sub-100ms mock
    return CircuitBreakerState(
      stepId: 'GEN-02250',
      description: 'Break the data circuit if a packet is rejected.',
      isCircuitBroken: false,
      integrityAccuracy: 0.997,
      lastChecked: DateTime.now(),
      qualitativeResult: 'Pass',
    );
  }
}

class DataCircuitBreakerCardGen02250 extends StatefulWidget {
  const DataCircuitBreakerCardGen02250({super.key});

  @override
  State<DataCircuitBreakerCardGen02250> createState() => _DataCircuitBreakerCardGen02250State();
}

class _DataCircuitBreakerCardGen02250State extends State<DataCircuitBreakerCardGen02250> {
  CircuitBreakerState? _state;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MockCircuitBreakerRepository.fetchState();
      if (mounted) {
        setState(() {
          _state = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCard(theme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                    'Data Circuit Breaker',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(colorScheme),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              _state?.description ?? 'Break the data circuit if a packet is rejected.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildMetrics(theme, colorScheme),
            const SizedBox(height: 16.0),
            Text(
              'Step ID: ${_state?.stepId ?? "GEN-02250"}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    final isPass = _state?.qualitativeResult == 'Pass';
    return Chip(
      avatar: Icon(
        isPass ? Icons.check_circle_outline : Icons.error_outline,
        size: 18.0,
        color: isPass ? colorScheme.primary : colorScheme.error,
      ),
      label: Text(
        _state?.qualitativeResult ?? 'Pending',
        style: TextStyle(
          color: isPass ? colorScheme.primary : colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isPass
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      side: BorderSide.none,
    );
  }

  Widget _buildMetrics(ThemeData theme, ColorScheme colorScheme) {
    final accuracy = _state?.integrityAccuracy ?? 0.0;
    final meetsFloor = accuracy >= 0.95;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Integrity Middleware Accuracy',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: accuracy.clamp(0.0, 1.0),
                minHeight: 8.0,
                borderRadius: BorderRadius.circular(4.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  meetsFloor ? colorScheme.primary : colorScheme.error,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              '${(accuracy * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: meetsFloor ? colorScheme.primary : colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'Floor Threshold: 95% | Target: 99.5%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        if (_state?.lastChecked != null) ...[
          const SizedBox(height: 16.0),
          Text(
            'Last Checked: ${_formatDateTime(_state!.lastChecked)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}