// GEN-02328 — Modal Scrim Background Component.
// Applies Material 3 scrim backgrounds to modals to focus user attention on error states, with responsive single/multi-column layout support.

import 'package:flutter/material.dart';

/// Enum representing the completion state for M3 status chips.
enum StepCompletionState { complete, partial, notComplete }

/// A reusable widget that wraps modal content with a focused scrim background,
/// specifically designed to draw user attention to error states per M3 guidelines.
class ErrorScrimModal extends StatelessWidget {
  final String errorMessage;
  final StepCompletionState completionState;
  final VoidCallback? onDismiss;

  const ErrorScrimModal({
    super.key,
    required this.errorMessage,
    this.completionState = StepCompletionState.notComplete,
    this.onDismiss,
  });

  /// Helper method to show this modal as a dialog with a custom scrim.
  static Future<void> show(
    BuildContext context, {
    required String errorMessage,
    StepCompletionState completionState = StepCompletionState.notComplete,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6), // Enhanced scrim for focus
      builder: (BuildContext context) {
        return ErrorScrimModal(
          errorMessage: errorMessage,
          completionState: completionState,
          onDismiss: onDismiss,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth >= 840;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : (isMobile ? screenWidth - 32 : 600),
          ),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28.0), // M3 shape large
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Error Attention Required',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  _StatusChip(state: completionState),
                ],
              ),
              const SizedBox(height: 16),
              if (!isMobile)
                // Multi-column layout for tablet/desktop
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Text(
                        errorMessage,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                )
              else
                // Single-column layout for mobile
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48), // 48x48dp touch target
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Acknowledge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 Status Chip indicating step completion state.
class _StatusChip extends StatelessWidget {
  final StepCompletionState state;

  const _StatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color chipColor;
    IconData icon;
    String label;

    switch (state) {
      case StepCompletionState.complete:
        chipColor = colorScheme.primary;
        icon = Icons.check_circle_outline;
        label = 'Complete';
        break;
      case StepCompletionState.partial:
        chipColor = colorScheme.tertiary;
        icon = Icons.warning_amber_rounded;
        label = 'Partial';
        break;
      case StepCompletionState.notComplete:
        chipColor = colorScheme.error;
        icon = Icons.cancel_outlined;
        label = 'Not Complete';
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: chipColor),
      label: Text(label),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.w500),
      side: BorderSide(color: chipColor.withOpacity(0.5)),
      backgroundColor: chipColor.withOpacity(0.1),
    );
  }
}

/// Example usage demonstrating the scrim modal in an engineering console context.
class EngineeringConsoleDemo extends StatelessWidget {
  const EngineeringConsoleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engineering Console')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ErrorScrimModal.show(
              context,
              errorMessage:
                  'Process Completion Rate dropped below floor threshold (0%). '
                  'Automated Liveness Handshake triggered rollback. '
                  'Review BigQuery partitioned logs for trace_id analysis.',
              completionState: StepCompletionState.notComplete,
            );
          },
          child: const Text('Trigger Error Scrim Modal'),
        ),
      ),
    );
  }
}