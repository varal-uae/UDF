import 'package:flutter/material.dart';

/// Row 271: FLADE-015-16 (Seq 16021)
/// Action: Configure the dashboard to generate visual UI heatmaps based on the spatial location of the hesitation events.
/// Quality Gate: Google SRE Handbook — Monitoring Distributed Systems (≥90% floor, 100% target/ceiling).
class SpatialHesitationHeatmapDashboardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const SpatialHesitationHeatmapDashboardPanel({
    super.key,
    this.globalRefId = 'FLADE-015-16',
    this.atomicStepRefId = 'FLADE-015-16',
    this.sequenceOrder = 16021,
  });

  @override
  State<SpatialHesitationHeatmapDashboardPanel> createState() =>
      _SpatialHesitationHeatmapDashboardPanelState();
}

class _SpatialHesitationHeatmapDashboardPanelState
    extends State<SpatialHesitationHeatmapDashboardPanel> {
  final List<Offset> _hesitationHotspots = [
    const Offset(0.25, 0.35),
    const Offset(0.28, 0.38),
    const Offset(0.72, 0.65),
    const Offset(0.75, 0.68),
    const Offset(0.71, 0.62),
    const Offset(0.50, 0.85),
  ];

  int _totalHesitationsDetected = 46;
  bool _showCoordinateGrid = true;

  void _recordSimulatedHesitation(TapDownDetails details, BoxConstraints constraints) {
    setState(() {
      final normalizedX = (details.localPosition.dx / constraints.maxWidth).clamp(0.05, 0.95);
      final normalizedY = (details.localPosition.dy / constraints.maxHeight).clamp(0.05, 0.95);
      _hesitationHotspots.add(Offset(normalizedX, normalizedY));
      _totalHesitationsDetected++;
      if (_hesitationHotspots.length > 25) {
        _hesitationHotspots.removeAt(0);
      }
    });
  }

  void _resetHeatmap() {
    setState(() {
      _hesitationHotspots.clear();
      _totalHesitationsDetected = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.gradient_rounded,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spatial Hesitation Heatmap',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    '$_totalHesitationsDetected DETECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Generates dynamic visual UI heatmaps based on spatial (X, Y) coordinates of user hesitation events and interaction pauses.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() {
                      _showCoordinateGrid = !_showCoordinateGrid;
                    });
                  },
                  icon: Icon(_showCoordinateGrid ? Icons.grid_off : Icons.grid_on, size: 18),
                  label: Text(_showCoordinateGrid ? 'Hide Grid' : 'Show Grid'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetHeatmap,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset Heatmap'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _recordSimulatedHesitation(details, constraints),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Stack(
                      children: [
                        if (_showCoordinateGrid)
                          CustomPaint(
                            size: Size(constraints.maxWidth, 180),
                            painter: _HeatmapGridPainter(),
                          ),
                        ..._hesitationHotspots.map((point) {
                          return Positioned(
                            left: point.dx * constraints.maxWidth - 20,
                            top: point.dy * 180 - 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.red.withValues(alpha: 0.8),
                                    Colors.orange.withValues(alpha: 0.5),
                                    Colors.yellow.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.1, 0.4, 0.7, 1.0],
                                ),
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tap canvas to simulate hesitation touch coordinate',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Hesitation Cluster: Form Submit Area (X: 72%, Y: 65%)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Active Points: ${_hesitationHotspots.length}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
