// DRVUT-008-A11 — Picture-in-Picture Under-60s Task SOP Micro-Video Loader.
// Material 3 PiP overlay with minimize/close controls, playback-completion gating, and telemetry hooks.

import 'package:flutter/material.dart';

typedef Drvut008A11TelemetryCallback = void Function(Map<String, Object?> event);

class Drvut008A11PipVideoOverlay extends StatefulWidget {
  const Drvut008A11PipVideoOverlay({
    super.key,
    required this.video,
    this.onMinimize,
    this.onClose,
    this.onPlaybackComplete,
    this.onTelemetry,
    this.initialCompleted = false,
  });

  final Widget video;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;
  final ValueChanged<bool>? onPlaybackComplete;
  final Drvut008A11TelemetryCallback? onTelemetry;
  final bool initialCompleted;

  @override
  State<Drvut008A11PipVideoOverlay> createState() => _Drvut008A11PipVideoOverlayState();
}

class _Drvut008A11PipVideoOverlayState extends State<Drvut008A11PipVideoOverlay> {
  late bool _isMinimized;
  late bool _isCompleted;
  int _interactionCount = 0;
  DateTime? _openedAt;

  @override
  void initState() {
    super.initState();
    _isMinimized = false;
    _isCompleted = widget.initialCompleted;
    _openedAt = DateTime.now();
    _emitTelemetry('overlay_open', {'completed': _isCompleted});
  }

  @override
  void dispose() {
    _emitTelemetry('overlay_close', {
      'completed': _isCompleted,
      'interaction_count': _interactionCount,
      'duration_ms': _openedAt == null ? null : DateTime.now().difference(_openedAt!).inMilliseconds,
    });
    super.dispose();
  }

  void _emitTelemetry(String eventName, Map<String, Object?> payload) {
    widget.onTelemetry?.call({
      'atomic_id': 'DRVUT-008-A11',
      'event': eventName,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      ...payload,
    });
  }

  void _toggleMinimize() {
    setState(() => _isMinimized = !_isMinimized);
    _interactionCount++;
    _emitTelemetry(_isMinimized ? 'minimize' : 'restore', {'completed': _isCompleted});
    widget.onMinimize?.call();
  }

  void _handleClose() {
    _interactionCount++;
    _emitTelemetry('close', {'completed': _isCompleted});
    widget.onClose?.call();
  }

  void markPlaybackComplete() {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);
    _emitTelemetry('playback_complete', {'completed': true});
    widget.onPlaybackComplete?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      children: [
        if (_isMinimized)
          _buildMinimizedBar(theme, scheme)
        else
          _buildExpandedOverlay(theme, scheme),
      ],
    );
  }

  Widget _buildExpandedOverlay(ThemeData theme, ColorScheme scheme) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 240),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: scheme.surfaceContainerLow, child: widget.video),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _controlButton(
                          icon: Icons.minimize,
                          label: 'Minimize instructional video',
                          onPressed: _toggleMinimize,
                        ),
                        _controlButton(
                          icon: Icons.close,
                          label: 'Close instructional video',
                          onPressed: _handleClose,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                    size: 18,
                    color: _isCompleted ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isCompleted ? 'Completed' : 'Under-60s SOP',
                      style: theme.textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_isCompleted)
                    TextButton(
                      onPressed: markPlaybackComplete,
                      child: const Text('Mark complete'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimizedBar(ThemeData theme, ColorScheme scheme) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      color: scheme.surfaceContainerHigh,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _toggleMinimize,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_in_picture_alt, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text('SOP video', style: theme.textTheme.labelLarge),
              const SizedBox(width: 8),
              _controlButton(
                icon: Icons.close,
                label: 'Close instructional video',
                onPressed: _handleClose,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        iconSize: compact ? 18 : 20,
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

/// Optional gate for forms that must remain disabled until SOP playback completes.
class Drvut008A11PlaybackGate extends ValueNotifier<bool> {
  Drvut008A11PlaybackGate() : super(false);

  void complete() => value = true;
  void reset() => value = false;
}
