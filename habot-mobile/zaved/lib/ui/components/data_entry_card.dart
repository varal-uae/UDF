// ============================================================================
// COMPONENT METADATA BLOCK
// Object Type: Stateful Widget / Data Entry Card Component
// Object Location/Path: universal_library/ui/components/data_entry_card.dart
// Open Status: Active / Open
// Timestamp: 2026-08-19T11:16:34+05:30
// File Handle ID: FILE-RCGLA-040-DEC
// Completion Status: Complete - Requirements/Discovery Coverage
// ============================================================================

import 'package:flutter/material.dart';

/// RCGLA-040: Data Entry Card Component
///
/// POKA-YOKE ARCHITECTURAL CONSTRAINTS:
/// 1. Single-Input Bouncer: Accepts strictly ONE input child widget. Multi-child
///    layouts (Column, Row, ListView, etc.) passed as the input child trigger build assertions.
/// 2. Multi-layer nested card variations (e.g. embedding DataEntryCard within
///    another DataEntryCard or Card) are EXPLICITLY PROHIBITED to maintain flat,
///    predictable layout simplicity.
class DataEntryCard extends StatefulWidget {
  final Widget inputChild;
  final String title;
  final String? errorMessage;
  final bool initialHasError;
  final ValueChanged<bool>? onErrorStateChanged;

  const DataEntryCard({
    super.key,
    required this.inputChild,
    required this.title,
    this.errorMessage,
    this.initialHasError = false,
    this.onErrorStateChanged,
  }) : assert(
         inputChild is! MultiChildRenderObjectWidget,
         'DataEntryCard Poka-Yoke Failure: Multi-child layouts (Column, Row, ListView, Flex, etc.) '
         'or multiple input widgets are strictly prohibited. Pass exactly ONE single input widget.',
       );

  @override
  State<DataEntryCard> createState() => _DataEntryCardState();
}

class _DataEntryCardState extends State<DataEntryCard> {
  late bool _hasError;

  @override
  void initState() {
    super.initState();
    _hasError = widget.initialHasError;
  }

  @override
  void didUpdateWidget(covariant DataEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHasError != widget.initialHasError) {
      setState(() {
        _hasError = widget.initialHasError;
      });
    }
  }

  void _toggleErrorState() {
    setState(() {
      _hasError = !_hasError;
    });
    if (widget.onErrorStateChanged != null) {
      widget.onErrorStateChanged!(_hasError);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assert again in build logic for runtime safety against multi-child widgets
    assert(
      widget.inputChild is! Column &&
          widget.inputChild is! Row &&
          widget.inputChild is! ListView &&
          widget.inputChild is! Flex &&
          widget.inputChild is! Wrap &&
          widget.inputChild is! Stack,
      'DataEntryCard Poka-Yoke Build Failure: Cannot embed multi-child layout containers as input child.',
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dynamic background color rule:
    // If hasError is true, card color switches to errorContainer (red background flash).
    final cardColor =
        _hasError ? colorScheme.errorContainer : colorScheme.surfaceContainerLow;

    final borderColor =
        _hasError ? colorScheme.error : colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Card(
        color: cardColor,
        elevation: _hasError ? 4.0 : 1.0,
        // Forced standard rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: borderColor,
            width: _hasError ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header & Error Toggle Simulator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _hasError
                            ? colorScheme.onErrorContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleErrorState,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _hasError
                            ? colorScheme.error.withValues(alpha: 0.2)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hasError ? Icons.warning : Icons.check_circle_outline,
                            size: 16,
                            color: _hasError
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _hasError ? "Flash: Error" : "Flash: Normal",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _hasError
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Single Input Bouncer Slot
              widget.inputChild,

              // Isolated Validation Text Line (Visible ONLY when hasError is true)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasError
                    ? Padding(
                        key: const ValueKey('error_text_key'),
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16.0,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                widget.errorMessage ??
                                    'Validation Error: Input payload fails poka-yoke criteria.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_error_key')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive Stacking Architecture Parent Layout for DataEntryCards
class DataEntryCardResponsiveLayout extends StatelessWidget {
  const DataEntryCardResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      DataEntryCard(
        title: "Account Identifier",
        errorMessage: "Account ID must be formatted as ACC-XXXX",
        initialHasError: true,
        inputChild: const TextField(
          decoration: InputDecoration(
            hintText: "Enter ACC-XXXX",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge),
          ),
        ),
      ),
      DataEntryCard(
        title: "Primary Authorization Key",
        errorMessage: "Key must contain at least 16 characters",
        initialHasError: false,
        inputChild: const TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter auth key",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.key),
          ),
        ),
      ),
      DataEntryCard(
        title: "Target Destination Route",
        errorMessage: "Destination URL host unreachable",
        initialHasError: false,
        inputChild: const TextField(
          decoration: InputDecoration(
            hintText: "https://api.internal/endpoint",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Entry Card Layout (RCGLA-040)"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth <= 600;

              if (isMobile) {
                // Mobile View (maxWidth <= 600): Single vertical column stacking
                return ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => cards[index],
                );
              } else {
                // Tablet/Web View (maxWidth > 600): Wrap/Grid layout for standalone cards
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: cards
                        .map(
                          (card) => SizedBox(
                            width: (constraints.maxWidth - 48) / 2 > 350
                                ? 380
                                : (constraints.maxWidth - 48) / 2,
                            child: card,
                          ),
                        )
                        .toList(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
