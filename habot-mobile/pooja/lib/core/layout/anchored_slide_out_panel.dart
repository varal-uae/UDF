import 'package:flutter/material.dart';

/// Row 268: FLADE-008-05 (Seq 15878)
/// Action: Build the absolute positioned slide-out panel component anchored to the right side of the UI.
/// Quality Gate: Material Design 3 Guidelines / Nielsen Norman Group Heuristic Evaluation (≥85% floor, ≥95% target, 100% ceiling).
class AnchoredSlideOutPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AnchoredSlideOutPanel({
    super.key,
    this.globalRefId = 'FLADE-008-05',
    this.atomicStepRefId = 'FLADE-008-05',
    this.sequenceOrder = 15878,
  });

  @override
  State<AnchoredSlideOutPanel> createState() => _AnchoredSlideOutPanelState();
}

class _AnchoredSlideOutPanelState extends State<AnchoredSlideOutPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  bool _isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      if (_isPanelOpen) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.vertical_split_rounded,
                          color: theme.colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anchored Slide-Out Drawer Panel',
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
                          color: _isPanelOpen
                              ? Colors.purple.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPanelOpen ? Colors.purple : theme.colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          _isPanelOpen ? 'PANEL EXPANDED' : 'COLLAPSED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isPanelOpen ? Colors.purple[800] : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Absolute-positioned slide-out panel anchored to the right viewport border with smooth M3 cubic motion curves.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _togglePanel,
                    icon: Icon(_isPanelOpen ? Icons.close : Icons.menu_open_rounded, size: 18),
                    label: Text(_isPanelOpen ? 'Dismiss Right Panel' : 'Open Right Slide-Out Panel'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        'Primary Canvas Workspace Area\n(Tap button to slide in right panel)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right-anchored slide-out panel overlay
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isPanelOpen,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          left: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: theme.colorScheme.primaryContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Right Anchored Panel',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: _togglePanel,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Contextual Quick Tools:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 8),
                                _buildQuickToolRow(Icons.filter_list_rounded, 'Filter Entity Set'),
                                _buildQuickToolRow(Icons.download_rounded, 'Export CSV Data'),
                                _buildQuickToolRow(Icons.history_rounded, 'View Audit History'),
                                const Divider(height: 16),
                                const Text('Properties:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 4),
                                const Text('Anchor: Right Edge (0dp)', style: TextStyle(fontSize: 11)),
                                const Text('Curve: Curves.easeOutCubic', style: TextStyle(fontSize: 11)),
                                const Text('Duration: 300ms', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: AnchoredSlideOutPanel(),
          ),
        ),
      ),
    ),
  );
}
