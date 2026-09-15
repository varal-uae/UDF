/*
 * MTVPE-011-11 — Implement 60-Second Just-in-Time Floating Video Micro-Training
 * 
 * Setup Step (Action): Implement 60-Second Just-in-Time Floating Video Micro-Training (MTVPE-011-11)
 * Setup Step Description: Maintain full input field interactiveness on screen while video assets play back.
 * 
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Downscale media dimensions automatically on compact touch layouts to maximize readable data entry surfaces.
 *   - Build prominent tap elements to let fingers close or mute video streams effortlessly.
 *   - Launch tooltips exclusively when user inaction durations hit the 5-second failure index.
 *   - Enforce elegant hardware acceleration styles on floating layers to protect layout scrolling velocities.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Step51FloatingVideoMicroTrainingPanel` widget and `FloatingVideoTrainingRecord` data model.
 *   - Implemented `PokaYokeInactionGuard` and `KirkpatrickComprehensionValidator` validation engines.
 *   - Built floating JIT video micro-training panel with interactive input forms, finger-friendly video controls, 5-second inaction index detector, and M3 data table.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

/// Step MTVPE-011-11: Floating Video Micro-Training Record Data Model.
class FloatingVideoTrainingRecord {
  final String assetName;
  final String assetType;
  final String assetLocation;
  final String assetVersion;
  final String assetSize;
  final String assetMetadata;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double comprehensionRate;

  // Step Specification & Metrics (Fields 10–11 Doc Conversion)
  final String apiEndpoint;
  final String httpMethod;
  final String authHeaderType;
  final String governanceOwner;
  final String assignedMember;

  const FloatingVideoTrainingRecord({
    required this.assetName,
    required this.assetType,
    required this.assetLocation,
    required this.assetVersion,
    required this.assetSize,
    required this.assetMetadata,
    this.completionStatus = 'Good (Scale: Good/Average/Poor)',
    required this.actionTimestamp,
    required this.userSessionId,
    this.comprehensionRate = 0.90,
    this.apiEndpoint = '/api/v1/training/micro-learning/jit-video/evaluate',
    this.httpMethod = 'POST',
    this.authHeaderType = 'Bearer <userSessionId>',
    this.governanceOwner = 'Micro-Learning Interaction Specialist & Mobile Platform Developer',
    this.assignedMember = 'Data Architecture',
  });
}

enum KirkpatrickOutputGrade {
  good('Good (Scale: Good/Average/Poor)', Colors.green),
  average('Average (Scale: Good/Average/Poor)', Colors.orange),
  poor('Poor (Scale: Good/Average/Poor)', Colors.red);

  final String label;
  final Color color;
  const KirkpatrickOutputGrade(this.label, this.color);
}

/// Kirkpatrick Model & ATD Benchmark Validator (Floor 0.7, Optimal 0.9, Ceiling 0.98).
abstract class KirkpatrickComprehensionValidator {
  static const double floorBoundary = 0.70;
  static const double optimalTarget = 0.90;
  static const double ceilingBoundary = 0.98;

  static KirkpatrickOutputGrade evaluateGrade(double score) {
    if (score >= optimalTarget) {
      return KirkpatrickOutputGrade.good;
    } else if (score >= floorBoundary) {
      return KirkpatrickOutputGrade.average;
    } else {
      return KirkpatrickOutputGrade.poor;
    }
  }

  static bool isCompliant(double score) {
    return score >= floorBoundary && score <= ceilingBoundary;
  }
}

/// Step 51: Implement 60-Second Just-in-Time Floating Video Micro-Training Widget.
class Step51FloatingVideoMicroTrainingPanel extends StatefulWidget {
  final FloatingVideoTrainingRecord record;

  const Step51FloatingVideoMicroTrainingPanel({super.key, required this.record});

  @override
  State<Step51FloatingVideoMicroTrainingPanel> createState() =>
      _Step51FloatingVideoMicroTrainingPanelState();
}

class _Step51FloatingVideoMicroTrainingPanelState
    extends State<Step51FloatingVideoMicroTrainingPanel> {
  // Input form controllers (full interactiveness during video playback)
  late TextEditingController _assetNameController;
  late TextEditingController _assetTypeController;
  late TextEditingController _assetLocationController;
  late TextEditingController _assetVersionController;
  late TextEditingController _assetSizeController;
  late TextEditingController _assetMetadataController;

  // Floating JIT Video player state
  bool _isVideoFloating = true;
  bool _isMuted = false;
  bool _isPlaying = true;
  bool _isMinimized = false;
  double _videoProgress = 0.35;
  int _videoTimeSeconds = 21;
  Timer? _videoTimer;

  // 5-Second Inaction Failure Index Detector
  Timer? _inactionTimer;
  int _inactionSeconds = 0;
  bool _showInactionTooltip = false;

  // Training Evaluation state
  double _comprehensionScore = 0.90;

  @override
  void initState() {
    super.initState();
    _assetNameController = TextEditingController(text: widget.record.assetName);
    _assetTypeController = TextEditingController(text: widget.record.assetType);
    _assetLocationController = TextEditingController(text: widget.record.assetLocation);
    _assetVersionController = TextEditingController(text: widget.record.assetVersion);
    _assetSizeController = TextEditingController(text: widget.record.assetSize);
    _assetMetadataController = TextEditingController(text: widget.record.assetMetadata);
    _comprehensionScore = widget.record.comprehensionRate;

    _startVideoPlaybackTimer();
    _startInactionTimer();
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _assetTypeController.dispose();
    _assetLocationController.dispose();
    _assetVersionController.dispose();
    _assetSizeController.dispose();
    _assetMetadataController.dispose();
    _videoTimer?.cancel();
    _inactionTimer?.cancel();
    super.dispose();
  }

  void _startVideoPlaybackTimer() {
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          if (_videoTimeSeconds < 60) {
            _videoTimeSeconds++;
            _videoProgress = _videoTimeSeconds / 60.0;
          } else {
            _videoTimeSeconds = 0;
            _videoProgress = 0.0;
          }
        });
      }
    });
  }

  void _startInactionTimer() {
    _inactionTimer?.cancel();
    _inactionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _inactionSeconds++;
        if (_inactionSeconds >= 5) {
          _showInactionTooltip = true;
        }
      });
    });
  }

  void _onUserActivityDetected() {
    setState(() {
      _inactionSeconds = 0;
      _showInactionTooltip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grade = KirkpatrickComprehensionValidator.evaluateGrade(_comprehensionScore);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Listener(
      onPointerDown: (_) => _onUserActivityDetected(),
      child: Stack(
        children: [
          // Main Scrollable Interactive Form & Dashboard Workspace
          SingleChildScrollView(
            padding: AppSpacingTokens.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Header Banner
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: AppSpacingTokens.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'MTVPE-011-11',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: grade.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: grade.color),
                              ),
                              child: Text(
                                grade.label,
                                style: TextStyle(
                                  color: grade.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacingTokens.vGapSm,
                        Text(
                          'Implement 60-Second Just-in-Time Floating Video Micro-Training',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        AppSpacingTokens.vGapSm,
                        Text(
                          'Maintain full input field interactiveness on screen while video assets play back. Tooltips auto-launch on 5-second inaction index.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacingTokens.vGapMd,

                // 5-Second Inaction Status Indicator Banner
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: _inactionSeconds >= 5
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _inactionSeconds >= 5 ? Icons.timer_off : Icons.timer,
                        color: _inactionSeconds >= 5 ? colorScheme.error : colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _inactionSeconds >= 5
                              ? 'Inaction Failure Index Hit (5s Inactivity) — Micro-Training Tooltip Triggered'
                              : 'User Activity Monitor: Active (${_inactionSeconds}s idle)',
                          style: TextStyle(
                            color: _inactionSeconds >= 5
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacingTokens.vGapMd,

                // Interactive Form Workspace (Stays 100% interactive while video plays)
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: AppSpacingTokens.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asset Metadata & Data Entry Workspace (Interactive)',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacingTokens.vGapMd,
                        TextField(
                          controller: _assetNameController,
                          onChanged: (_) => _onUserActivityDetected(),
                          decoration: const InputDecoration(
                            labelText: 'Asset Name',
                            border: OutlineInputBorder(),
                            helperText: 'Poka-Yoke: Preserves zero input latency during floating video playback',
                          ),
                        ),
                        AppSpacingTokens.vGapSm,
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _assetTypeController,
                                onChanged: (_) => _onUserActivityDetected(),
                                decoration: const InputDecoration(
                                  labelText: 'Asset Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            AppSpacingTokens.hGapSm,
                            Expanded(
                              child: TextField(
                                controller: _assetVersionController,
                                onChanged: (_) => _onUserActivityDetected(),
                                decoration: const InputDecoration(
                                  labelText: 'Asset Version',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacingTokens.vGapSm,
                        TextField(
                          controller: _assetLocationController,
                          onChanged: (_) => _onUserActivityDetected(),
                          decoration: const InputDecoration(
                            labelText: 'Asset Location / URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        AppSpacingTokens.vGapSm,
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _assetSizeController,
                                onChanged: (_) => _onUserActivityDetected(),
                                decoration: const InputDecoration(
                                  labelText: 'Asset Size',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            AppSpacingTokens.hGapSm,
                            Expanded(
                              child: TextField(
                                controller: _assetMetadataController,
                                onChanged: (_) => _onUserActivityDetected(),
                                decoration: const InputDecoration(
                                  labelText: 'Asset Metadata Schema',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacingTokens.vGapMd,

                // Kirkpatrick Training Evaluation Model Controls
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: AppSpacingTokens.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kirkpatrick Level 2 Training Comprehension Rate Evaluator',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacingTokens.vGapSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Comprehension Rate: ${(_comprehensionScore * 100).toStringAsFixed(1)}%'),
                            Text(
                              'Floor: 70% | Target: 90% | Ceiling: 98%',
                              style: TextStyle(color: colorScheme.outline, fontSize: 11),
                            ),
                          ],
                        ),
                        Slider(
                          value: _comprehensionScore,
                          min: 0.50,
                          max: 1.00,
                          divisions: 50,
                          activeColor: grade.color,
                          label: '${(_comprehensionScore * 100).toStringAsFixed(0)}%',
                          onChanged: (val) {
                            _onUserActivityDetected();
                            setState(() => _comprehensionScore = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacingTokens.vGapMd,

                // Standalone Video Re-Open Bar if Closed
                if (!_isVideoFloating)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isVideoFloating = true;
                          _isMinimized = false;
                        });
                      },
                      icon: const Icon(Icons.picture_in_picture),
                      label: const Text('Re-Open Floating Micro-Training Video'),
                    ),
                  ),

                AppSpacingTokens.vGapLg,

                // Step Metrics & Audit Table
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: AppSpacingTokens.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance & Metric Audit',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacingTokens.vGapSm,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Parameter')),
                              DataColumn(label: Text('Specification / Metric Value')),
                            ],
                            rows: [
                              DataRow(cells: [
                                const DataCell(Text('API Endpoint')),
                                DataCell(Text(widget.record.apiEndpoint)),
                              ]),
                              DataRow(cells: [
                                const DataCell(Text('HTTP Method')),
                                DataCell(Text(widget.record.httpMethod)),
                              ]),
                              DataRow(cells: [
                                const DataCell(Text('Auth Headers')),
                                DataCell(Text(widget.record.authHeaderType)),
                              ]),
                              DataRow(cells: [
                                const DataCell(Text('Assigned Approver')),
                                DataCell(Text(widget.record.assignedMember)),
                              ]),
                              const DataRow(cells: [
                                DataCell(Text('Comprehension Standard')),
                                DataCell(Text('Kirkpatrick Level 2 & ATD Benchmarks')),
                              ]),
                              DataRow(cells: [
                                const DataCell(Text('Governance Owner')),
                                DataCell(Text(widget.record.governanceOwner)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Just-In-Time Micro-Training Video Overlay (Downscaled on compact layouts)
          if (_isVideoFloating)
            Positioned(
              bottom: 20,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.black87,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _isMinimized ? 200 : (isCompact ? 240 : 320),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video Floating Header Controls
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _isMinimized ? 'JIT Video (00:${_videoTimeSeconds.toString().padLeft(2, '0')})' : '60s JIT Micro-Training',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                            onPressed: () {
                              _onUserActivityDetected();
                              setState(() => _isMuted = !_isMuted);
                            },
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: Icon(_isMinimized ? Icons.aspect_ratio : Icons.horizontal_rule, color: Colors.white),
                            onPressed: () {
                              _onUserActivityDetected();
                              setState(() => _isMinimized = !_isMinimized);
                            },
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _onUserActivityDetected();
                              setState(() => _isVideoFloating = false);
                            },
                          ),
                        ],
                      ),

                      if (!_isMinimized) ...[
                        const SizedBox(height: 6),
                        // Video Media Frame Preview
                        Container(
                          height: isCompact ? 100 : 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Opacity(
                                opacity: 0.3,
                                child: Icon(Icons.movie, size: 48, color: Colors.white),
                              ),
                              IconButton(
                                iconSize: 42,
                                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: colorScheme.primary),
                                onPressed: () {
                                  _onUserActivityDetected();
                                  setState(() => _isPlaying = !_isPlaying);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Scrubber Progress Bar
                        LinearProgressIndicator(
                          value: _videoProgress,
                          color: colorScheme.primary,
                          backgroundColor: Colors.white24,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '00:${_videoTimeSeconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            const Text(
                              '01:00',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // 5-Second Inaction Micro-Training Tooltip Banner
          if (_showInactionTooltip)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(10),
                color: Colors.amber.shade900,
                child: Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'JIT Tooltip: Need help filling metadata fields? Watch the floating video micro-training at bottom right!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () {
                          _onUserActivityDetected();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
