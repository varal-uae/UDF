import 'package:flutter/material.dart';

/// Graph Node Model
class GraphNodeData {
  final String id;
  final String name;
  final Offset position;
  final List<String> targetIds;
  final String traceParam;

  const GraphNodeData({
    required this.id,
    required this.name,
    required this.position,
    required this.targetIds,
    required this.traceParam,
  });

  GraphNodeData copyWith({
    String? id,
    String? name,
    Offset? position,
    List<String>? targetIds,
    String? traceParam,
  }) {
    return GraphNodeData(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      targetIds: targetIds ?? this.targetIds,
      traceParam: traceParam ?? this.traceParam,
    );
  }
}

/// Line Painter connecting graph nodes using secondary color scheme
class GraphLinePainter extends CustomPainter {
  final List<GraphNodeData> nodes;
  final Color lineColor;

  GraphLinePainter({required this.nodes, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nodeMap = {for (var n in nodes) n.id: n};

    for (var source in nodes) {
      final sourceCenter = source.position + const Offset(64.0, 32.0);
      for (var targetId in source.targetIds) {
        final target = nodeMap[targetId];
        if (target != null) {
          final targetCenter = target.position + const Offset(64.0, 32.0);

          // Draw bezier curve for smooth gesture-driven canvas route visualization
          final path = Path();
          path.moveTo(sourceCenter.dx, sourceCenter.dy);
          final controlPointX = (sourceCenter.dx + targetCenter.dx) / 2;
          path.cubicTo(
            controlPointX,
            sourceCenter.dy,
            controlPointX,
            targetCenter.dy,
            targetCenter.dx,
            targetCenter.dy,
          );
          canvas.drawPath(path, paint);

          // Draw directional indicator dot
          canvas.drawCircle(
            Offset(targetCenter.dx - 12, targetCenter.dy),
            5.0,
            Paint()..color = lineColor,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphLinePainter oldDelegate) => true;
}

/// Lineage Graph & Terminal Alert Dashboard Stateful Widget (BPWSO-007-12)
class LineageGraphTerminalAlertDashboard extends StatefulWidget {
  const LineageGraphTerminalAlertDashboard({super.key});

  @override
  State<LineageGraphTerminalAlertDashboard> createState() =>
      _LineageGraphTerminalAlertDashboardState();
}

class _LineageGraphTerminalAlertDashboardState
    extends State<LineageGraphTerminalAlertDashboard> {
  late List<GraphNodeData> _nodes;
  String? _selectedNodeId;
  String? _terminalErrorAlert;

  @override
  void initState() {
    super.initState();
    _resetGraphToValidState();
  }

  void _resetGraphToValidState() {
    setState(() {
      _terminalErrorAlert = null;
      _selectedNodeId = 'N-1';
      _nodes = const [
        GraphNodeData(
          id: 'N-1',
          name: 'Root Ingestion',
          position: Offset(50, 150),
          targetIds: ['N-2'],
          traceParam: 'Kafka Partition 0, Offset 40921',
        ),
        GraphNodeData(
          id: 'N-2',
          name: 'Spark Stream Transformer',
          position: Offset(320, 100),
          targetIds: ['N-3'],
          traceParam: 'Spark Micro-batch 14, 120ms execution',
        ),
        GraphNodeData(
          id: 'N-3',
          name: 'BigQuery Sink',
          position: Offset(600, 220),
          targetIds: [],
          traceParam: 'Dataset `analytics_prod.events_table`',
        ),
      ];
    });
  }

  // 3. Poka-Yoke Cycle Detection (Graph Logic)
  // Basic cycle detection algorithm using Depth-First Search (DFS)
  void validateStructuralLinks(List<GraphNodeData> nodes) {
    final adjMap = <String, List<String>>{};
    for (var node in nodes) {
      adjMap[node.id] = List.from(node.targetIds);
    }

    final visited = <String>{};
    final recStack = <String>{};

    bool hasCycleDFS(String current, List<String> path) {
      visited.add(current);
      recStack.add(current);

      final neighbors = adjMap[current] ?? [];
      for (var neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          if (hasCycleDFS(neighbor, [...path, neighbor])) return true;
        } else if (recStack.contains(neighbor)) {
          // Closed loop cycle detected!
          return true;
        }
      }

      recStack.remove(current);
      return false;
    }

    for (var node in nodes) {
      if (!visited.contains(node.id)) {
        if (hasCycleDFS(node.id, [node.id])) {
          throw StateError(
            'POKA-YOKE GRAPH CYCLE DETECTED: Closed loop detected in structural links (Cycle: Node Sink -> Node Source). Update blocked.',
          );
        }
      }
    }
  }

  void _attemptInjectCycleLink() {
    // Attempting to create N-3 -> N-1 closed loop cycle
    final candidateNodes = _nodes.map((node) {
      if (node.id == 'N-3') {
        return node.copyWith(targetIds: ['N-1']); // Creates closed loop N-1 -> N-2 -> N-3 -> N-1
      }
      return node;
    }).toList();

    try {
      validateStructuralLinks(candidateNodes);
      // If valid (no error), apply
      setState(() {
        _nodes = candidateNodes;
        _terminalErrorAlert = null;
      });
    } catch (e) {
      // Catch error, block update, and trigger WCAG AAA Terminal Alert UI
      setState(() {
        _terminalErrorAlert = e.toString().replaceAll('Bad state: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lineage Graph & Terminal Alert'),
        actions: [
          IconButton.filledTonal(
            onPressed: _resetGraphToValidState,
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Graph State',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
            onPressed: _attemptInjectCycleLink,
            icon: const Icon(Icons.loop_outlined),
            label: const Text('Trigger Cycle Alert'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return Column(
            children: [
              // WCAG AAA Terminal Alert Display (Requirement 4)
              if (_terminalErrorAlert != null)
                _buildWCAGAAATerminalAlert(theme),

              // Main Workspace: Panning Canvas & Granular Trace Parameters
              Expanded(
                child: isMobile
                    ? Column(
                        children: [
                          Expanded(child: _buildPanningCanvas(theme)),
                          _buildMobileAccordionTracePanel(theme),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildPanningCanvas(theme)),
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                            child: _buildWebTabletSidePanel(theme),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 1. Gesture-Driven Panning Canvas with InteractiveViewer
  Widget _buildPanningCanvas(ThemeData theme) {
    final secondaryColor = theme.colorScheme.secondary;

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 2.5,
        child: SizedBox(
          width: 1000,
          height: 600,
          child: Stack(
            children: [
              // CustomPaint drawing lineage connections using secondary color
              CustomPaint(
                size: const Size(1000, 600),
                painter: GraphLinePainter(
                  nodes: _nodes,
                  lineColor: secondaryColor,
                ),
              ),

              // Interactive Nodes enforcing 48dp minimum hit boxes (Requirement 2)
              ..._nodes.map((node) {
                final isSelected = node.id == _selectedNodeId;

                return Positioned(
                  left: node.position.dx,
                  top: node.position.dy,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedNodeId = node.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(16.0),
                      child: ConstrainedBox(
                        // 2. Strict 48dp Hit Boxes requirement
                        constraints: const BoxConstraints(
                          minWidth: 48.0,
                          minHeight: 48.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.account_tree
                                    : Icons.hub_outlined,
                                size: 20,
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    node.id,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    node.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 4. WCAG AAA 7:1 Contrast Error Typography Terminal Alert Container
  Widget _buildWCAGAAATerminalAlert(ThemeData theme) {
    // Contrast Analysis for WCAG AAA:
    // Background: Pure Black `#000000` (Luminance = 0.0)
    // Foreground Text: High visibility bright pink/red `#FFB4AB` (Luminance ~ 0.50)
    // Contrast Ratio: (0.50 + 0.05) / (0.00 + 0.05) = 11.0 : 1
    // (Strictly surpasses the WCAG AAA requirement of >= 7.0:1)
    const backgroundColor = Color(0xFF000000); // Stark black
    const errorTextColor = Color(0xFFFFB4AB); // High contrast light pink-red

    final errorTextStyle = const TextStyle(
      color: errorTextColor,
      fontFamily: 'monospace',
      fontSize: 13.0,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.terminal_outlined,
                color: errorTextColor,
                size: 20,
              ),
              const SizedBox(width: 8.0),
              Text(
                'SYSTEM TERMINAL ALERT (WCAG AAA 7:1 COMPLIANT)',
                style: errorTextStyle.copyWith(letterSpacing: 1.1),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: errorTextColor, size: 18),
                onPressed: () {
                  setState(() {
                    _terminalErrorAlert = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E0004),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: errorTextColor.withValues(alpha: 0.5)),
            ),
            child: SelectableText(
              '[ERROR 500] $_terminalErrorAlert\nContrast Ratio: 11.0:1 (Guaranteed >= 7:1 AAA Threshold)',
              style: errorTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Mobile Accordion Drawers (maxWidth <= 600)
  Widget _buildMobileAccordionTracePanel(ThemeData theme) {
    final selectedNode =
        _nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => _nodes.first);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.tune, color: theme.colorScheme.primary),
        title: Text(
          'Deep Granular Trace Parameters (${selectedNode.id})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTraceDetailsContent(theme, selectedNode),
          ),
        ],
      ),
    );
  }

  // Persistent Side Panel for Web/Tablet (maxWidth > 600)
  Widget _buildWebTabletSidePanel(ThemeData theme) {
    final selectedNode =
        _nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => _nodes.first);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: theme.colorScheme.primary),
              const SizedBox(width: 8.0),
              Text(
                'Deep Granular Trace',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24.0),
          _buildTraceDetailsContent(theme, selectedNode),
        ],
      ),
    );
  }

  Widget _buildTraceDetailsContent(ThemeData theme, GraphNodeData node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Node ID'),
          subtitle: Text(node.id, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Node Name'),
          subtitle: Text(node.name),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Granular Trace Parameter'),
          subtitle: Text(node.traceParam),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Outgoing Connections'),
          subtitle: Text(
            node.targetIds.isEmpty ? 'None (Sink Node)' : node.targetIds.join(', '),
          ),
        ),
      ],
    );
  }
}
