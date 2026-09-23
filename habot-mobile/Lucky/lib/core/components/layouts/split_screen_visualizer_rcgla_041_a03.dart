// RCGLA-041-A03 — SplitScreenVisualizer Layout Component.
// Provides a standardized split-screen layout with single-pixel dividing lines, fixed canvas boundaries, and Material 3 chip navigation. Adapts responsively for mobile-first constraints without manual scaling.

import 'package:flutter/material.dart';

/// Mock data representing secure image payloads fetched via signed URLs.
class _MockImagePayload {
  final String id;
  final String signedUrl;
  final String status;

  const _MockImagePayload({
    required this.id,
    required this.signedUrl,
    required this.status,
  });
}

const List<_MockImagePayload> _mockPayloads = [
  _MockImagePayload(
    id: 'step_exec_001',
    signedUrl: 'https://storage.mock.gcp/payload_001?sig=abc123',
    status: 'corporate',
  ),
  _MockImagePayload(
    id: 'step_exec_002',
    signedUrl: 'https://storage.mock.gcp/payload_002?sig=def456',
    status: 'clinical',
  ),
];

/// A reusable split-screen visualizer component that enforces strict layout rules.
/// Inherits styles exclusively from the core theme and disables manual view scaling.
class SplitScreenVisualizer extends StatelessWidget {
  const SplitScreenVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = constraints.maxWidth < 600;

        // Disable manual view scaling by constraining the root container
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Split Screen Visualizer'),
              actions: [
                // Navigation guided by standard chip elements
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: const Text('Overview'),
                    avatar: const Icon(Icons.dashboard_outlined, size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            body: isCompact
                ? _buildCompactLayout(context)
                : _buildWideLayout(context),
          ),
        );
      },
    );
  }

  /// Wide layout: Tabular tracking panels side-by-side separated by a single pixel line.
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPanel(context, _mockPayloads[0]),
        ),
        // Single pixel dividing line to maintain grid simplicity
        Container(
          width: 1.0,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _buildPanel(context, _mockPayloads[1]),
        ),
      ],
    );
  }

  /// Compact layout: Re-flows into clean horizontal menu choices / stacked panels.
  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        // Horizontal menu choices replacing wide tabular panels on compact layouts
        SizedBox(
          height: 48.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _mockPayloads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8.0),
            itemBuilder: (context, index) {
              final payload = _mockPayloads[index];
              return ChoiceChip(
                label: Text('Track ${index + 1}'),
                selected: index == 0,
                onSelected: (_) {},
              );
            },
          ),
        ),
        // Single pixel dividing line
        Container(
          height: 1.0,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _buildPanel(context, _mockPayloads[0]),
        ),
      ],
    );
  }

  /// Builds an individual panel with programmatically clipped canvas boundaries.
  Widget _buildPanel(BuildContext context, _MockImagePayload payload) {
    final Color badgeColor = payload.status == 'corporate'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Execution ID: ${payload.id}',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.clip, // Preserve string lengths without truncation
              ),
              // Separate visual badge themes to distinguish corporate from clinical statuses
              Badge(
                backgroundColor: badgeColor,
                label: Text(
                  payload.status.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _ClippedCanvasViewer(signedUrl: payload.signedUrl),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

/// Programmatically clips source documents using strict canvas coordinate boundaries.
/// Ensures absolute context removal security patterns.
class _ClippedCanvasViewer extends StatelessWidget {
  final String signedUrl;

  const _ClippedCanvasViewer({required this.signedUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // Strict canvas coordinate boundaries enforced via ClipRect
      child: CustomPaint(
        size: Size.infinite,
        painter: _SecureCanvasPainter(
          signedUrl: signedUrl,
          borderColor: Theme.of(context).colorScheme.outline,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

/// Custom painter simulating secure media transformation and boundary clipping.
class _SecureCanvasPainter extends CustomPainter {
  final String signedUrl;
  final Color borderColor;
  final Color backgroundColor;

  _SecureCanvasPainter({
    required this.signedUrl,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // Single pixel boundary

    // Draw fixed component canvas element
    final Rect bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(bounds, bgPaint);
    canvas.drawRect(bounds, borderPaint);

    // Simulate drawing clipped content based on signed URL payload
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'Secure Payload:\n$signedUrl\n\n[Context Removed]',
        style: TextStyle(
          color: borderColor,
          fontSize: 12.0,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16.0);

    textPainter.paint(canvas, const Offset(8.0, 8.0));
  }

  @override
  bool shouldRepaint(covariant _SecureCanvasPainter oldDelegate) {
    return oldDelegate.signedUrl != signedUrl ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}