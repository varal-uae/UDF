// GEN-04025 — Video SOP Coverage Status Card.
// M3 Elevated Card displaying step completion state with 30-second background polling, pull-to-refresh, and responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum SopStatus { pass, fail, pending }

class VideoSopStepData {
  final String atomicId;
  final String description;
  final SopStatus status;
  final DateTime timestamp;
  final String sessionId;

  const VideoSopStepData({
    required this.atomicId,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.sessionId,
  });
}

class MockVideoSopRepository {
  static const List<VideoSopStepData> mockSteps = [
    VideoSopStepData(
      atomicId: 'GEN-04025',
      description: 'Record a visual demonstration or video SOP illustrating exact task execution.',
      status: SopStatus.pass,
      timestamp: _mockTimestamp,
      sessionId: 'session_udf_001',
    ),
  ];

  static final DateTime _mockTimestamp = DateTime(2026, 9, 28, 10, 0);

  Future<List<VideoSopStepData>> fetchSopCoverage() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return mockSteps;
  }
}

class VideoSopCardGen04025 extends StatefulWidget {
  const VideoSopCardGen04025({super.key});

  @override
  State<VideoSopCardGen04025> createState() => _VideoSopCardGen04025State();
}

class _VideoSopCardGen04025State extends State<VideoSopCardGen04025> {
  final MockVideoSopRepository _repository = MockVideoSopRepository();
  List<VideoSopStepData> _steps = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
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
      final data = await _repository.fetchSopCoverage();
      if (mounted) setState(() { _steps = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(SopStatus status, ColorScheme cs) {
    switch (status) {
      case SopStatus.pass: return cs.primary;
      case SopStatus.fail: return cs.error;
      case SopStatus.pending: return cs.tertiary;
    }
  }

  String _statusLabel(SopStatus status) {
    switch (status) {
      case SopStatus.pass: return 'Pass';
      case SopStatus.fail: return 'Fail';
      case SopStatus.pending: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

        return RefreshIndicator(
          onRefresh: _loadData,
          color: cs.primary,
          child: _isLoading && _steps.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: cs.primary)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isMobile ? 2.8 : 3.2,
                  ),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _buildElevatedCard(step, cs, textTheme, isMobile);
                  },
                ),
        );
      },
    );
  }

  Widget _buildElevatedCard(VideoSopStepData step, ColorScheme cs, TextTheme textTheme, bool isMobile) {
    return Card(
      elevation: 3,
      surfaceTintColor: cs.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBottomSheet(context, step, cs),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.atomicId,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _statusLabel(step.status),
                      style: textTheme.labelSmall?.copyWith(color: cs.onPrimary),
                    ),
                    backgroundColor: _statusColor(step.status, cs),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  step.description,
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: isMobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: cs.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${step.timestamp.year}-${step.timestamp.month.toString().padLeft(2, '0')}-${step.timestamp.day.toString().padLeft(2, '0')}',
                    style: textTheme.labelSmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, VideoSopStepData step, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Input', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.badge, color: cs.primary),
                title: const Text('Atomic ID'),
                subtitle: Text(step.atomicId),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.description_outlined, color: cs.primary),
                title: const Text('Description'),
                subtitle: Text(step.description),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety, color: _statusColor(step.status, cs)),
                title: const Text('Completion Status'),
                subtitle: Text(_statusLabel(step.status)),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.fingerprint, color: cs.primary),
                title: const Text('Session ID'),
                subtitle: Text(step.sessionId),
                contentPadding: EdgeInsets.zero,
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
                        content: const Text('Configuration confirmed.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(label: 'DISMISS', onPressed: () {}),
                      ),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}