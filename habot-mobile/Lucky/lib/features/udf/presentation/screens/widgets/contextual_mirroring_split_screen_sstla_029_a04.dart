// SSTLA-029-A04 — Contextual Mirroring Split-Screen Layout for Bio-APIs.
// Implements a split-screen layout with synchronized zoom tracking, pan coordinates mirroring, and dynamic panel dimensions for evidence vs action views.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level definition fields.
class _MockDefinitionData {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final Map<String, dynamic> definitionParameters;
  final String validationStatus;
  final bool completionStatus;

  const _MockDefinitionData({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.definitionParameters,
    required this.validationStatus,
    required this.completionStatus,
  });
}

const List<_MockDefinitionData> _mockDefinitions = [
  _MockDefinitionData(
    definitionId: 'DEF-001',
    definitionName: 'Bio-Metric Verification Rule A',
    definitionType: 'Validation',
    definitionParameters: {'threshold': 0.85, 'method': 'facial_match'},
    validationStatus: 'Pending',
    completionStatus: false,
  ),
  _MockDefinitionData(
    definitionId: 'DEF-002',
    definitionName: 'Document Authenticity Check B',
    definitionType: 'Evidence',
    definitionParameters: {'scan_type': 'UV', 'dpi_min': 300},
    validationStatus: 'Approved',
    completionStatus: true,
  ),
];

/// Controller to synchronize zoom scale and pan coordinates between panels.
class MirroredZoomController extends ChangeNotifier {
  double _zoomScale = 1.0;
  Offset _panOffset = Offset.zero;

  double get zoomScale => _zoomScale;
  Offset get panOffset => _panOffset;

  void updateTransformation(double scale, Offset offset) {
    if (_zoomScale != scale || _panOffset != offset) {
      _zoomScale = scale.clamp(1.0, 5.0);
      _panOffset = offset;
      notifyListeners();
    }
  }

  void reset() {
    _zoomScale = 1.0;
    _panOffset = Offset.zero;
    notifyListeners();
  }
}

/// Split-screen layout widget that mirrors zoom and pan interactions
/// between the Evidence (left/top) and Action (right/bottom) panels.
class ContextualMirroringSplitScreen extends StatefulWidget {
  const ContextualMirroringSplitScreen({super.key});

  @override
  State<ContextualMirroringSplitScreen> createState() =>
      _ContextualMirroringSplitScreenState();
}

class _ContextualMirroringSplitScreenState
    extends State<ContextualMirroringSplitScreen>
    with SingleTickerProviderStateMixin {
  late final MirroredZoomController _zoomController;
  late final AnimationController _animController;
  late Animation<double> _splitAnimation;

  // Dynamic split percentage (e.g., 0.6 means 60% evidence, 40% action)
  double _splitRatio = 0.6;

  @override
  void initState() {
    super.initState();
    _zoomController = MirroredZoomController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _splitAnimation = Tween<double>(begin: 0.5, end: 0.6).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    _zoomController.updateTransformation(
      details.scale,
      details.focalPointDelta,
    );
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // Poka-Yoke: Prevent isolating error corrections from evidence fields.
    // If zoom exceeds boundaries or attempts invalid isolation, reset.
    if (_zoomController.zoomScale < 1.0 || _zoomController.zoomScale > 5.0) {
      _zoomController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;

    return AnimatedBuilder(
      animation: Listenable.merge([_zoomController, _splitAnimation]),
      builder: (context, child) {
        final double currentRatio = _splitAnimation.value;

        final Widget evidencePanel = _buildSyncedPanel(
          context: context,
          title: 'Evidence Sheet',
          color: theme.colorScheme.primaryContainer,
          content: _buildEvidenceContent(theme),
        );

        final Widget actionPanel = _buildSyncedPanel(
          context: context,
          title: 'Correction Box',
          color: theme.colorScheme.secondaryContainer,
          content: _buildActionContent(theme),
        );

        // Mobile-First UX: Vertical split on mobile, horizontal on larger screens
        if (isMobile) {
          return Column(
            children: [
              Expanded(
                flex: (currentRatio * 100).round(),
                child: evidencePanel,
              ),
              Container(
                height: 4.0,
                color: theme.colorScheme.outline,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      final screenHeight = MediaQuery.sizeOf(context).height;
                      _splitRatio = (details.delta.dy / screenHeight + _splitRatio)
                          .clamp(0.3, 0.7);
                      _splitAnimation =
                          AlwaysStoppedAnimation<double>(_splitRatio);
                    });
                  },
                ),
              ),
              Expanded(
                flex: ((1.0 - currentRatio) * 100).round(),
                child: actionPanel,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: (currentRatio * 100).round(),
                child: evidencePanel,
              ),
              Container(
                width: 4.0,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                flex: ((1.0 - currentRatio) * 100).round(),
                child: actionPanel,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSyncedPanel({
    required BuildContext context,
    required String title,
    required Color color,
    required Widget content,
  }) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onScaleUpdate: _onInteractionUpdate,
      onScaleEnd: _onInteractionEnd,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 2.0,
          ),
        ),
        child: ClipRect(
          child: Transform(
            transform: Matrix4.identity()
              ..scale(_zoomController.zoomScale)
              ..translate(
                _zoomController.panOffset.dx / _zoomController.zoomScale,
                _zoomController.panOffset.dy / _zoomController.zoomScale,
              ),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Zoom: ${(_zoomController.zoomScale * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceContent(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _mockDefinitions.length,
      itemBuilder: (context, index) {
        final def = _mockDefinitions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${def.definitionId}',
                    style: theme.textTheme.labelLarge),
                const SizedBox(height: 4.0),
                Text(def.definitionName,
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8.0),
                Text('Type: ${def.definitionType}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4.0),
                Text('Params: ${def.definitionParameters.toString()}',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 8.0),
                Chip(
                  label: Text(def.validationStatus),
                  backgroundColor: def.validationStatus == 'Approved'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Error Correction Pathway',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Correction Notes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16.0),
          FilledButton.icon(
            onPressed: () {
              // Simulate resolution streaming to central data tracking
              debugPrint(
                  '[SSTLA-029-A04] Resolution completion record streamed.');
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Submit Correction'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          OutlinedButton.icon(
            onPressed: _zoomController.reset,
            icon: const Icon(Icons.zoom_out_map),
            label: const Text('Reset Zoom & Pan Sync'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class mimicking AnimatedBuilder since Flutter uses AnimatedBuilder internally
/// but standard naming is AnimatedBuilder in newer SDKs or we use ListenableBuilder.
/// Using ListenableBuilder for modern Flutter compatibility.
class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}