// NSKFI-003-A12 — StandardModalOverlayShell focus-locking overlay container.
// Provides a full-screen mobile or centered desktop modal with auto-release timeout, focus trapping, keyboard support, and Poka-Yoke delete confirmation.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable atomic overlay shell for high-importance tasks.
/// Freezes background views, traps focus, and supports responsive layouts.
class StandardModalOverlayShell extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  final VoidCallback? onConfirm;
  final Duration timeoutDuration;
  final String title;
  final bool requireDeleteConfirmation;
  final FocusNode? triggerFocusNode;

  const StandardModalOverlayShell({
    super.key,
    required this.child,
    required this.onClose,
    this.onConfirm,
    this.timeoutDuration = const Duration(seconds: 30),
    this.title = 'Action Required',
    this.requireDeleteConfirmation = false,
    this.triggerFocusNode,
  });

  @override
  State<StandardModalOverlayShell> createState() => _StandardModalOverlayShellState();
}

class _StandardModalOverlayShellState extends State<StandardModalOverlayShell> {
  Timer? _autoReleaseTimer;
  final FocusNode _overlayFocusNode = FocusNode();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool _isDeleteConfirmed = false;

  @override
  void initState() {
    super.initState();
    _startAutoReleaseTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode.requestFocus(_overlayFocusNode);
    });
  }

  void _startAutoReleaseTimer() {
    _autoReleaseTimer = Timer(widget.timeoutDuration, () {
      if (mounted) _handleClose();
    });
  }

  void _handleClose() {
    _autoReleaseTimer?.cancel();
    widget.onClose();
    // Return focus to the exact button that launched the popup
    widget.triggerFocusNode?.requestFocus();
  }

  void _handleConfirm() {
    if (widget.requireDeleteConfirmation && !_isDeleteConfirmed) return;
    _autoReleaseTimer?.cancel();
    widget.onConfirm?.call();
    _handleClose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleClose();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        _handleConfirm();
        return KeyEventResult.handled;
      }
      // Basic focus trap: prevent tabbing out of the scope
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        _focusScopeNode.nextFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _autoReleaseTimer?.cancel();
    _overlayFocusNode.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return FocusScope(
      node: _focusScopeNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Focus(
        focusNode: _overlayFocusNode,
        child: Material(
          color: Colors.black54,
          child: GestureDetector(
            onTap: _handleClose, // Outside clicks close modules cleanly
            behavior: HitBehavior.opaque,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap propagation to backdrop
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 500,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(24.0),
                  padding: EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: isMobile ? 32 : 24, // Lower edge boundary for thumb access on mobile
                  ),
                  width: isMobile ? double.infinity : null,
                  height: isMobile ? double.infinity : null,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _handleClose,
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Flexible(child: widget.child),
                        if (widget.requireDeleteConfirmation) ...[
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: _isDeleteConfirmed,
                            onChanged: (val) {
                              setState(() {
                                _isDeleteConfirmed = val ?? false;
                              });
                            },
                            title: Text(
                              'I explicitly confirm this high-risk deletion.',
                              style: theme.textTheme.bodyMedium,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Align(
                          alignment: isMobile ? Alignment.bottomCenter : Alignment.centerRight,
                          child: Row(
                            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: isMobile ? 1 : 0,
                                child: OutlinedButton(
                                  onPressed: _handleClose,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: isMobile ? const Size(double.infinity, 48) : const Size(120, 48),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: isMobile ? 1 : 0,
                                child: FilledButton(
                                  onPressed: (widget.requireDeleteConfirmation && !_isDeleteConfirmed)
                                      ? null
                                      : _handleConfirm,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: widget.requireDeleteConfirmation
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onError,
                                    minimumSize: isMobile ? const Size(double.infinity, 48) : const Size(120, 48),
                                  ),
                                  child: Text(widget.requireDeleteConfirmation ? 'Delete' : 'Confirm'),
                                ),
                              ),
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
        ),
      ),
    );
  }
}

/// Helper function to show the overlay programmatically, blocking script closure on enterprise displays.
Future<T?> showStandardModalOverlay<T>({
  required BuildContext context,
  required Widget child,
  String title = 'Action Required',
  bool requireDeleteConfirmation = false,
  Duration timeoutDuration = const Duration(seconds: 30),
  FocusNode? triggerFocusNode,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true, // Outside clicks close modules cleanly
    builder: (dialogContext) {
      return PopScope(
        canPop: true,
        child: StandardModalOverlayShell(
          title: title,
          requireDeleteConfirmation: requireDeleteConfirmation,
          timeoutDuration: timeoutDuration,
          triggerFocusNode: triggerFocusNode,
          onClose: () => Navigator.of(dialogContext).pop(),
          onConfirm: () => Navigator.of(dialogContext).pop(),
          child: child,
        ),
      );
    },
  );
}

// --- Mock Data & Usage Example ---

class MockDefinitionData {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final Map<String, dynamic> parameters;
  final String validationStatus;

  const MockDefinitionData({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.parameters,
    required this.validationStatus,
  });
}

const List<MockDefinitionData> mockDefinitions = [
  MockDefinitionData(
    definitionId: 'DEF-001',
    definitionName: 'High-Risk Account Deletion',
    definitionType: 'Destructive Action',
    parameters: {'threshold': 100, 'requires_approval': true},
    validationStatus: 'Complete',
  ),
  MockDefinitionData(
    definitionId: 'DEF-002',
    definitionName: 'Bulk Export Trigger',
    definitionType: 'Data Operation',
    parameters: {'max_rows': 50000},
    validationStatus: 'Partial',
  ),
];

/// Example screen demonstrating the overlay integration.
class OverlayDemoScreen extends StatelessWidget {
  const OverlayDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FocusNode launchFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(title: const Text('NSKFI-003-A12 Overlay Demo')),
      body: Center(
        child: ElevatedButton(
          focusNode: launchFocusNode,
          onPressed: () {
            showStandardModalOverlay(
              context: context,
              title: mockDefinitions.first.definitionName,
              requireDeleteConfirmation: true,
              triggerFocusNode: launchFocusNode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Definition ID: ${mockDefinitions.first.definitionId}'),
                  const SizedBox(height: 8),
                  Text('Type: ${mockDefinitions.first.definitionType}'),
                  const SizedBox(height: 8),
                  Text('Validation Status: ${mockDefinitions.first.validationStatus}'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Input Value',
                      helperText: 'Ensure clear helper text guidelines match current input types.',
                      border: const OutlineInputBorder(),
                      errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    onChanged: (value) {
                      // Real-time input formatting trigger point
                    },
                  ),
                ],
              ),
            );
          },
          child: const Text('Launch High-Risk Modal'),
        ),
      ),
    );
  }
}