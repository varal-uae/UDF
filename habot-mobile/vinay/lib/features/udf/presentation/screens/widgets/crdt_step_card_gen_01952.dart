// GEN-01952 — CRDT Step Completion Status Card.
// Displays the Conflict-Free Replicated Data Types (CRDT) application status using M3 Elevated Cards, responsive layout, and mock data with 30-second polling simulation.

import 'dart:async';
import 'package:flutter/material.dart';

enum CrdtCompletionStatus { complete, partial, notComplete }

class CrdtStepData {
  final String atomicId;
  final String description;
  final CrdtCompletionStatus status;
  final int completionRate;
  final DateTime lastUpdated;

  const CrdtStepData({
    required this.atomicId,
    required this.description,
    required this.status,
    required this.completionRate,
    required this.lastUpdated,
  });
}

class MockCrdtRepository {
  static CrdtStepData fetchStepData() {
    return CrdtStepData(
      atomicId: 'GEN-01952',
      description: 'Apply Conflict-Free Replicated Data Types (CRDTs) to data structures.',
      status: CrdtCompletionStatus.complete,
      completionRate: 98,
      lastUpdated: DateTime.now(),
    );
  }
}

class CrdtStepCard extends StatefulWidget {
  const CrdtStepCard({super.key});

  @override
  State<CrdtStepCard> createState() => _CrdtStepCardState();
}

class _CrdtStepCardState extends State<CrdtStepCard> {
  late CrdtStepData _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = MockCrdtRepository.fetchStepData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _data = MockCrdtRepository.fetchStepData();
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(CrdtCompletionStatus status, ColorScheme cs) {
    switch (status) {
      case CrdtCompletionStatus.complete:
        return cs.primary;
      case CrdtCompletionStatus.partial:
        return cs.tertiary;
      case CrdtCompletionStatus.notComplete:
        return cs.error;
    }
  }

  String _statusLabel(CrdtCompletionStatus status) {
    switch (status) {
      case CrdtCompletionStatus.complete:
        return 'Complete';
      case CrdtCompletionStatus.partial:
        return 'Partial';
      case CrdtCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        final cardContent = Padding(
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
                      _data.atomicId,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (_isRefreshing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _data.description,
                style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: _statusColor(_data.status, cs),
                    ),
                    label: Text(
                      _statusLabel(_data.status),
                      style: textTheme.labelLarge?.copyWith(
                        color: _statusColor(_data.status, cs),
                      ),
                    ),
                    backgroundColor: _statusColor(_data.status, cs).withOpacity(0.12),
                    side: BorderSide.none,
                  ),
                  Text(
                    'Completion Rate: ${_data.completionRate}%',
                    style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Last Updated: ${_data.lastUpdated.toIso8601String().substring(0, 19)}',
                style: textTheme.bodySmall?.copyWith(color: cs.outline),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: 48,
                child: OutlinedButton(
                  onPressed: () => _showConfigSheet(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.settings_outlined, size: 24),
                ),
              ),
            ],
          ),
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildElevatedCard(cs, cardContent)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildElevatedCard(
                  cs,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KPI Details', style: textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text('Floor Boundary: 90%'),
                        Text('Optimal Target: 99%'),
                        Text('Ceiling Boundary: 100%'),
                        const SizedBox(height: 8),
                        Text('Standard: ISO/IEC 27001:2022', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return _buildElevatedCard(cs, cardContent);
      },
    );
  }

  Widget _buildElevatedCard(ColorScheme cs, Widget child) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surfaceContainerLow,
      child: child,
    );
  }

  void _showConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Inputs',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Metric Config Override',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: const Text('Apply Changes'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
