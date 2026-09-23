// GEN-01930 — Pinned Video Player Widget.
// Pins the video securely above the input interaction zone using M3 Elevated Cards, status chips, and responsive single/multi-column layouts.

import 'package:flutter/material.dart';

/// Mock data for video playback metrics as per requirement.
class _MockVideoMetric {
  final String metricName;
  final double successRate;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String qualitativeOutput;

  const _MockVideoMetric({
    required this.metricName,
    required this.successRate,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.qualitativeOutput,
  });
}

const _MockVideoMetric _mockMetric = _MockVideoMetric(
  metricName: 'Video Playback Success Rate (%)',
  successRate: 99.2,
  floorBoundary: 98.0,
  optimalTarget: 99.5,
  ceilingBoundary: 100.0,
  qualitativeOutput: 'High',
);

/// A widget that pins a video player securely above the input interaction zone.
/// Implements M3 Elevated Card (Level 2, 3dp), Status Chips, 48x48dp touch targets,
/// and responsive layout (single-column <600dp, multi-column >=840dp).
class PinnedVideoPlayerGen01930 extends StatefulWidget {
  const PinnedVideoPlayerGen01930({super.key});

  @override
  State<PinnedVideoPlayerGen01930> createState() => _PinnedVideoPlayerGen01930State();
}

class _PinnedVideoPlayerGen01930State extends State<PinnedVideoPlayerGen01930> {
  bool _isPlaying = false;

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_mockMetric.successRate >= _mockMetric.optimalTarget) {
      return colorScheme.primary;
    } else if (_mockMetric.successRate >= _mockMetric.floorBoundary) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isDesktop = constraints.maxWidth >= 840;

        // M3 Elevated Card Level 2 (3dp elevation)
        return Card(
          elevation: 3.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pinned Video Zone
              _buildVideoZone(context),
              const Divider(height: 1),
              // Metrics & Interaction Zone
              if (isDesktop)
                _buildDesktopLayout(context)
              else
                _buildMobileLayout(context, isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoZone(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      color: colorScheme.surfaceContainerHighest,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 64,
            color: colorScheme.primary,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Chip(
              label: Text(
                'PINNED',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              padding: EdgeInsets.zero,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePlayback,
                // 48x48dp minimum touch target enforced by Material InkWell
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, {required bool isMobile}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(context),
          const SizedBox(height: 12),
          _buildInteractionControls(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildMetricCard(context)),
          const SizedBox(width: 24),
          Expanded(child: _buildInteractionControls(context)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mockMetric.metricName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${_mockMetric.successRate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 12),
            // M3 Status Chip
            Chip(
              avatar: Icon(Icons.circle, size: 12, color: statusColor),
              label: Text(_mockMetric.qualitativeOutput),
              side: BorderSide(color: statusColor.withOpacity(0.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Floor: ${_mockMetric.floorBoundary}% | Target: ${_mockMetric.optimalTarget}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildInteractionControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 48x48dp touch target button
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Configuration synced successfully.'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'DISMISS',
                    onPressed: () {},
                  ),
                ),
              );
            },
            icon: const Icon(Icons.sync, size: 20),
            label: const Text('Manual Sync'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => _buildConfigBottomSheet(ctx),
              );
            },
            icon: const Icon(Icons.settings, size: 20),
            label: const Text('Configure'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Configuration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'HLS/DASH Stream URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Configuration'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}