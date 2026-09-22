// NSKFI-003-A10 — StandardModalOverlayShell: Focus-locking accessible overlay modal container.
// Provides a full-screen mobile or centered desktop modal with backdrop dimming, focus trapping, explicit delete confirmation, and keyboard support.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock telemetry data model for atomic-level tracking as per Data Requirement.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome,
        'User ID': userId,
      };
}

/// Poka-Yoke (Mistake-Proofing) state controller for high-risk actions.
class DeleteConfirmationController extends ChangeNotifier {
  bool _isConfirmed = false;
  bool get isConfirmed => _isConfirmed;

  void toggleConfirmation(bool value) {
    _isConfirmed = value;
    notifyListeners();
  }
}

/// Core reusable component stored in `mobile-atomic-core-ui`.
/// Implements Material 3 standards, responsive layouts, and accessibility requirements.
class StandardModalOverlayShell extends StatefulWidget {
  final String title;
  final String message;
  final Widget? content;
  final VoidCallback? onConfirm;
  final VoidCallback? onDelete;
  final bool showDeleteAction;
  final String confirmLabel;
  final String deleteLabel;

  const StandardModalOverlayShell({
    super.key,
    required this.title,
    required this.message,
    this.content,
    this.onConfirm,
    this.onDelete,
    this.showDeleteAction = false,
    this.confirmLabel = 'Confirm',
    this.deleteLabel = 'Delete',
  });

  @override
  State<StandardModalOverlayShell> createState() => _StandardModalOverlayShellState();
}

class _StandardModalOverlayShellState extends State<StandardModalOverlayShell> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final DeleteConfirmationController _deleteController = DeleteConfirmationController();
  late final FocusNode _confirmFocusNode;
  late final FocusNode _closeFocusNode;

  @override
  void initState() {
    super.initState();
    _confirmFocusNode = FocusNode();
    _closeFocusNode = FocusNode();
    // Self-Chasing: Automatically request focus when modal opens to trap navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode.requestFocus(_confirmFocusNode);
    });
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _deleteController.dispose();
    _confirmFocusNode.dispose();
    _closeFocusNode.dispose();
    super.dispose();
  }

  void _handleClose(BuildContext context) {
    // Record mock telemetry before closing
    final record = StepExecutionRecord(
      stepExecutionId: 'NSKFI-003-A10-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: 'Completed',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'User closed modal',
      userId: 'mock-user-001',
    );
    debugPrint('Telemetry Captured: ${record.toJson()}');

    // Self-Chasing: Return interface focus automatically back to the exact button that launched popups after closure.
    Navigator.of(context).pop();
  }

  void _handleKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Support direct desktop keyboard controls (Enter keys to confirm actions)
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        widget.onConfirm?.call();
        _handleClose(context);
      }
      // Escape to close
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleClose(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return FocusScope(
      node: _focusScopeNode,
      autofocus: true,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyboardEvent,
        child: Dialog(
          insetPadding: isMobile
              ? EdgeInsets.zero // Shift centered popup boxes into clean full-screen layout panels on small mobile screens
              : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 0.0 : 28.0),
          ),
          backgroundColor: theme.colorScheme.surface,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 560.0, // Center modal windows neatly on desktop screens, sizing boxes to set grid metrics
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          focusNode: _closeFocusNode,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => _handleClose(context),
                          tooltip: 'Close modal',
                        ),
                      ],
                    ),
                  ),
                  // Processing message text / AISS requirement
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      widget.message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Custom Content Area
                  if (widget.content != null)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: widget.content!,
                      ),
                    ),
                  // Mistake-Proofing (Poka-Yoke): Explicit confirmation box for high-risk Delete buttons
                  if (widget.showDeleteAction && widget.onDelete != null)
                    ListenableBuilder(
                      listenable: _deleteController,
                      builder: (context, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: CheckboxListTile(
                            value: _deleteController.isConfirmed,
                            onChanged: (val) => _deleteController.toggleConfirmation(val ?? false),
                            title: Text(
                              'I explicitly confirm I want to permanently delete this item.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: theme.colorScheme.error,
                          ),
                        );
                      },
                    ),
                  const Divider(height: 32.0),
                  // Action Buttons - Move primary confirm buttons to lower screen edge boundaries for comfortable mobile thumb access
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: isMobile ? 32.0 : 24.0,
                      top: 8.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ensure the primary confirm action button stands out with high-contrast styling
                        FilledButton.icon(
                          focusNode: _confirmFocusNode,
                          onPressed: () {
                            widget.onConfirm?.call();
                            _handleClose(context);
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(widget.confirmLabel),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                        if (widget.showDeleteAction && widget.onDelete != null) ...[
                          const SizedBox(height: 12.0),
                          ListenableBuilder(
                            listenable: _deleteController,
                            builder: (context, _) {
                              return OutlinedButton.icon(
                                onPressed: _deleteController.isConfirmed
                                    ? () {
                                        widget.onDelete!.call();
                                        _handleClose(context);
                                      }
                                    : null, // Locked until checkbox is checked
                                icon: const Icon(Icons.delete_forever_rounded),
                                label: Text(widget.deleteLabel),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to launch the overlay manager, freezing active views underneath.
Future<void> showStandardModalOverlay({
  required BuildContext context,
  required String title,
  required String message,
  Widget? content,
  VoidCallback? onConfirm,
  VoidCallback? onDelete,
  bool showDeleteAction = false,
}) async {
  // Background screens dim quietly and a sharp confirmation window opens
  await showDialog(
    context: context,
    barrierDismissible: true, // Outside clicks close modules cleanly
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (BuildContext dialogContext) {
      return StandardModalOverlayShell(
        title: title,
        message: message,
        content: content,
        onConfirm: onConfirm,
        onDelete: onDelete,
        showDeleteAction: showDeleteAction,
      );
    },
  );
}
