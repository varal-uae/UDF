// SSTLA-035 — Focused Task Layouts & Workspaces.
// Hides global headers during critical tasks to eliminate choice confusion and intercepts back navigation to protect unsaved inputs.

import 'package:flutter/material.dart';

class FocusedTaskWorkspace extends StatelessWidget {
  const FocusedTaskWorkspace({
    super.key,
    required this.taskTitle,
    required this.child,
    required this.onConfirmExit,
    this.hideGlobalHeader = true,
  });

  final String taskTitle;
  final Widget child;
  final Future<bool> Function() onConfirmExit;
  final bool hideGlobalHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await onConfirmExit();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // Hides global header if hideGlobalHeader is true, displaying focused micro-header
        appBar: hideGlobalHeader
            ? AppBar(
                title: Text(
                  taskTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: cs.surfaceContainerLow,
                automaticallyImplyLeading: false, // Prevents accidental back tap
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Exit Workspace',
                    onPressed: () async {
                      final shouldPop = await onConfirmExit();
                      if (shouldPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
