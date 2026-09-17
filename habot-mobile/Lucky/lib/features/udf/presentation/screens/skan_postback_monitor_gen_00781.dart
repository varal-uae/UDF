// GEN-00781 — SKAdNetwork Postback Monitor Screen.
// Displays automated checks for missing postbacks when SKAN window expires, using M3 Elevated Cards and status chips in a responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum PostbackStatus { pass, fail, pending }

class SkanPostbackModel {
  final String traceId;
  final DateTime timestamp;
  final PostbackStatus status;
  final double alertSpeedSeconds;

  const SkanPostbackModel({
    required this.traceId,
    required this.timestamp,
    required this.status,
    required this.alertSpeedSeconds,
  });
}

class SkanPostbackMonitorScreen extends StatefulWidget {
  const SkanPostbackMonitorScreen({super.key});

  @override
  State<SkanPostbackMonitorScreen> createState() => _SkanPostbackMonitorScreenState();
}

class _SkanPostbackMonitorScreenState extends State<SkanPostbackMonitorScreen> {
  Timer? _pollingTimer;
  List<SkanPostbackModel> _postbacks = [];
  bool _isLoading = false;

  static const Duration _pollingInterval = Duration(seconds: 30);
  static const double _floorBoundarySecs = 3.0;
  static const double _optimalTargetSecs = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchPostbackData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (mounted) _fetchPostbackData();
    });
  }

  Future<void> _fetchPostbackData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 60));

    if (!mounted) return;
    setState(() {
      _postbacks = [
        const SkanPostbackModel(
          traceId: 'trace-001-gen-00781',
          timestamp: null as dynamic,
          status: PostbackStatus.pass,
          alertSpeedSeconds: 0.8,
        ),
        const SkanPostbackModel(
          traceId: 'trace-002-gen-00781',
          timestamp: null as dynamic,
          status: PostbackStatus.fail,
          alertSpeedSeconds: 4.2,
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchPostbackData();
  }

  Color _getStatusColor(BuildContext context, PostbackStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case PostbackStatus.pass:
        return colorScheme.primary;
      case PostbackStatus.fail:
        return colorScheme.error;
      case PostbackStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusLabel(PostbackStatus status) {
    switch (status) {
      case PostbackStatus.pass:
        return 'Pass';
      case PostbackStatus.fail:
        return 'Fail';
      case PostbackStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKAN Postback Monitor'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            if (_isLoading && _postbacks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: isDesktop ? 2.5 : 2.0,
              ),
              itemCount: _postbacks.length,
              itemBuilder: (context, index) {
                final item = _postbacks[index];
                return _buildPostbackCard(context, item);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostbackCard(BuildContext context, SkanPostbackModel model) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _getStatusColor(context, model.status);

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showConfigurationSheet(context, model),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      model.traceId,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: Text(
                      _getStatusLabel(model.status),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.15),
                    side: BorderSide(color: statusColor, width: 1.0),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Alert Speed: ${model.alertSpeedSeconds.toStringAsFixed(2)}s',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4.0),
              LinearProgressIndicator(
                value: (model.alertSpeedSeconds / 5.0).clamp(0.0, 1.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4.0,
                borderRadius: BorderRadius.circular(2.0),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(
                    model.alertSpeedSeconds <= _optimalTargetSecs
                        ? Icons.check_circle_outline
                        : model.alertSpeedSeconds <= _floorBoundarySecs
                            ? Icons.warning_amber_rounded
                            : Icons.error_outline,
                    size: 16.0,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    model.alertSpeedSeconds <= _floorBoundarySecs
                        ? 'Within SLA'
                        : 'SLA Breached',
                    style: textTheme.labelSmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationSheet(BuildContext context, SkanPostbackModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Postback Configuration',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Text('Trace ID: ${model.traceId}'),
              const SizedBox(height: 8.0),
              Text('Current Status: ${_getStatusLabel(model.status)}'),
              const SizedBox(height: 8.0),
              Text('Alert Speed: ${model.alertSpeedSeconds}s'),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Close'),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }
}