// EDEBS-038-13 — Backward Data Lineage (ED -> PD -> SD) interactive graph for Operations.
// Touch-first pan/zoom, thick connection lines, large node targets, double-tap schema bottom-sheet, and linear animated child panel height.

import 'package:flutter/material.dart';

enum DataSourceType { ed, pd, sd }

extension DataSourceTypeX on DataSourceType {
  IconData get icon {
    switch (this) {
      case DataSourceType.ed:
        return Icons.cloud_outlined;
      case DataSourceType.pd:
        return Icons.settings_suggest_outlined;
      case DataSourceType.sd:
        return Icons.storage_outlined;
    }
  }

  String get label {
    switch (this) {
      case DataSourceType.ed:
        return 'ED';
      case DataSourceType.pd:
        return 'PD';
      case DataSourceType.sd:
        return 'SD';
    }
  }

  Color get accent {
    switch (this) {
      case DataSourceType.ed:
        return const Color(0xFF3B82F6);
      case DataSourceType.pd:
        return const Color(0xFF8B5CF6);
      case DataSourceType.sd:
        return const Color(0xFF10B981);
    }
  }
}

class LineageNode {
  const LineageNode({
    required this.id,
    required this.title,
    required this.type,
    required this.position,
    required this.fields,
  });

  final String id;
  final String title;
  final DataSourceType type;
  final Offset position;
  final Map<String, String> fields;
}

class LineageEdge {
  const LineageEdge({required this.fromId, required this.toId});
  final String fromId;
  final String toId;
}

class DataLineageViewEDEBS03813 extends StatefulWidget {
  const DataLineageViewEDEBS03813({super.key});

  @override
  State<DataLineageViewEDEBS03813> createState() => _DataLineageViewEDEBS03813State();
}

class _DataLineageViewEDEBS03813State extends State<DataLineageViewEDEBS03813> {
  static const Size _nodeSize = Size(184, 104);

  final List<LineageNode> _nodes = const [
    LineageNode(
      id: 'ED',
      title: 'External Data',
      type: DataSourceType.ed,
      position: Offset(72, 72),
      fields: {
        'Step Execution ID': 'ED-EXEC-001',
        'Execution Status': 'Completed',
        'Execution Timestamp': '2026-09-11T08:15:00Z',
        'Step Outcome': 'Good',
        'User ID': 'ops.user@habot',
      },
    ),
    LineageNode(
      id: 'PD',
      title: 'Processed Data',
      type: DataSourceType.pd,
      position: Offset(356, 260),
      fields: {
        'Step Execution ID': 'PD-EXEC-001',
        'Execution Status': 'Completed',
        'Execution Timestamp': '2026-09-11T08:16:12Z',
        'Step Outcome': 'Good',
        'User ID': 'ops.user@habot',
      },
    ),
    LineageNode(
      id: 'SD',
      title: 'Stored Data',
      type: DataSourceType.sd,
      position: Offset(640, 72),
      fields: {
        'Step Execution ID': 'SD-EXEC-001',
        'Execution Status': 'Completed',
        'Execution Timestamp': '2026-09-11T08:17:45Z',
        'Step Outcome': 'Good',
        'User ID': 'ops.user@habot',
      },
    ),
  ];

  final List<LineageEdge> _edges = const [
    LineageEdge(fromId: 'ED', toId: 'PD'),
    LineageEdge(fromId: 'PD', toId: 'SD'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backward Data Lineage'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'ED -> PD -> SD',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.6,
                maxScale: 2.5,
                boundaryMargin: const EdgeInsets.all(160),
                child: SizedBox(
                  width: 900,
                  height: 520,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LineageEdgePainter(
                            edges: _edges,
                            nodes: _nodes,
                            nodeSize: _nodeSize,
                          ),
                        ),
                      ),
                      for (final node in _nodes)
                        Positioned(
                          left: node.position.dx,
                          top: node.position.dy,
                          child: _LineageNodeCard(
                            node: node,
                            size: _nodeSize,
                            onDoubleTap: () => _openSchemaSheet(context, node),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSchemaSheet(BuildContext context, LineageNode node) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SchemaBottomSheet(node: node),
    );
  }
}

class _LineageNodeCard extends StatelessWidget {
  const _LineageNodeCard({
    required this.node,
    required this.size,
    required this.onDoubleTap,
  });

  final LineageNode node;
  final Size size;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = node.type.accent;
    return Semantics(
      button: true,
      label: '${node.type.label} ${node.title}. Double-tap for schema details.',
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.75), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(node.type.icon, color: accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.type.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      node.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineageEdgePainter extends CustomPainter {
  _LineageEdgePainter({
    required this.edges,
    required this.nodes,
    required this.nodeSize,
  });

  final List<LineageEdge> edges;
  final List<LineageNode> nodes;
  final Size nodeSize;

  @override
  void paint(Canvas canvas, Size size) {
    final nodeById = {for (final node in nodes) node.id: node};
    final paint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final from = nodeById[edge.fromId];
      final to = nodeById[edge.toId];
      if (from == null || to == null) continue;
      final start = _centerOf(from);
      final end = _centerOf(to);
      final direction = end - start;
      final length = direction.distance;
      if (length == 0) continue;
      final unit = direction / length;
      final shortenedEnd = end - unit * 42;
      canvas.drawLine(start, shortenedEnd, paint);
      _drawArrowHead(canvas, shortenedEnd, unit, paint.color);
    }
  }

  Offset _centerOf(LineageNode node) {
    return node.position + Offset(nodeSize.width / 2, nodeSize.height / 2);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset unit, Color color) {
    const arrowSize = 18.0;
    final normal = Offset(-unit.dy, unit.dx);
    final base = tip - unit * arrowSize;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + normal.dx * arrowSize * 0.55, base.dy + normal.dy * arrowSize * 0.55)
      ..lineTo(base.dx - normal.dx * arrowSize * 0.55, base.dy - normal.dy * arrowSize * 0.55)
      ..close();
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _LineageEdgePainter oldDelegate) {
    return oldDelegate.edges != edges || oldDelegate.nodes != nodes || oldDelegate.nodeSize != nodeSize;
  }
}

class _SchemaBottomSheet extends StatefulWidget {
  const _SchemaBottomSheet({required this.node});
  final LineageNode node;

  @override
  State<_SchemaBottomSheet> createState() => _SchemaBottomSheetState();
}

class _SchemaBottomSheetState extends State<_SchemaBottomSheet> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _expanded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = widget.node;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${node.type.label} Schema Details',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(node.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            curve: Curves.linear,
            height: _expanded ? 360 : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final entry in node.fields.entries)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(node.type.icon, color: node.type.accent),
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
