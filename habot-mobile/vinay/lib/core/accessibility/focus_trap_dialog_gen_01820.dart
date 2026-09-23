// GEN-01820 — Focus Trap Dialog for Gesture-Based Screen Readers.
// Ensures focus traps correctly confine gesture-based screen readers to the dialog using M3 Elevated Cards and 48x48dp touch targets.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing step completion state for the engineering console.
class _MockStepData {
  final String id;
  final String name;
  final String status; // High/Medium/Low
  final double gestureAccuracy;

  const _MockStepData({
    required this.id,
    required this.name,
    required this.status,
    required this.gestureAccuracy,
  });
}

const List<_MockStepData> _mockSteps = [
  _MockStepData(
    id: 'GEN-01819',
    name: 'Foundational Configuration',
    status: 'High',
    gestureAccuracy: 99.8,
  ),
  _MockStepData(
    id: 'GEN-01820',
    name: 'Focus Trap Validation',
    status: 'Medium',
    gestureAccuracy: 96.5,
  ),
];

/// A dialog widget that implements a strict focus trap to confine
/// gesture-based screen readers within its boundaries.
class FocusTrapDialogGen01820 extends StatefulWidget {
  const FocusTrapDialogGen01820({super.key});

  @override
  State<FocusTrapDialogGen01820> createState() => _FocusTrapDialogGen01820State();
}

class _FocusTrapDialogGen01820State extends State<FocusTrapDialogGen01820> {
  late final FocusScopeNode _dialogFocusNode;

  @override
  void initState() {
    super.initState();
    _dialogFocusNode = FocusScopeNode(debugLabel: 'GEN-01820 Focus Trap');
    // Request focus immediately to trap it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _dialogFocusNode.dispose();
    super.dispose();
  }

  /// Intercepts back button / escape key to maintain focus trap
  Future<bool> _onWillPop() async {
    // Keep focus trapped unless explicitly closed via the close button
    return false;
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'High':
        return colorScheme.primary;
      case 'Medium':
        return colorScheme.tertiary;
      case 'Low':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Re-request focus to ensure screen reader stays trapped
          _dialogFocusNode.requestFocus();
        }
      },
      child: FocusScope(
        node: _dialogFocusNode,
        autofocus: true,
        // Skip traversal outside this scope
        skipTraversal: false,
        child: Dialog(
          elevation: 3, // M3 Elevated Card Level 2 (3dp)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          backgroundColor: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Semantics(
              label: 'Engineering Console Step Health Dialog',
              explicitChildNodes: true,
              container: true,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Status Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Step Health: GEN-01820',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // M3 Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ensure focus traps correctly confine gesture-based screen readers to the dialog.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 32),

                    // M3 KPI Cards (Single-column mobile layout)
                    ..._mockSteps.map((step) => _buildKpiCard(context, step)),

                    const SizedBox(height: 24),

                    // Close Button - 48x48dp touch target
                    Align(
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        button: true,
                        label: 'Close dialog and release focus trap',
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            tooltip: 'Close',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, _MockStepData step) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusColor = _getStatusColor(context, step.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 3, // M3 Elevated Card Level 2
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    step.id,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      step.status,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step.name,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Gesture Recognition Accuracy: ',
                    style: textTheme.bodySmall,
                  ),
                  Text(
                    '${step.gestureAccuracy.toStringAsFixed(1)}%',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: step.gestureAccuracy >= 95.0
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the focus-trapped dialog from anywhere in the app.
void showFocusTrapDialogGen01820(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return const FocusTrapDialogGen01820();
    },
  );
}