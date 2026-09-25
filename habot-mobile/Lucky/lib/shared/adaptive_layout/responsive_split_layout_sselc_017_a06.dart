// SSELC-017-A06 — Responsive Split-Screen Layout for Landscape Mobile Orientations.
// Implements Material 3 window size classes (compact, medium, expanded) to display
// reference files on the left and input fields on the right during landscape usage,
// with isolated scroll areas, sticky action trays, and high-contrast dividers.

import 'package:flutter/material.dart';

/// Window size class based on Material 3 specifications.
enum WindowSizeClass { compact, medium, expanded }

/// Determines the [WindowSizeClass] based on viewport width in dp.
WindowSizeClass getWindowSizeClass(double width) {
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}

/// A responsive layout widget that transitions between stacked (portrait/compact)
/// and split-screen (landscape/medium/expanded) configurations.
class ResponsiveSplitLayout extends StatelessWidget {
  final Widget referencePanel;
  final Widget inputPanel;
  final List<Widget> stickyActions;

  const ResponsiveSplitLayout({
    super.key,
    required this.referencePanel,
    required this.inputPanel,
    this.stickyActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final WindowSizeClass sizeClass = getWindowSizeClass(constraints.maxWidth);

        // Poka-Yoke: Lock into stacked view if dimensions are too narrow
        // to prevent unreadable layouts.
        if (sizeClass == WindowSizeClass.compact) {
          return _buildStackedLayout(context, constraints);
        }

        return _buildSplitLayout(context, constraints, sizeClass);
      },
    );
  }

  Widget _buildStackedLayout(BuildContext context, BoxConstraints constraints) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    referencePanel,
                    const SizedBox(height: 24.0),
                    inputPanel,
                  ],
                ),
              ),
            ),
            if (stickyActions.isNotEmpty) _buildStickyTray(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitLayout(BuildContext context, BoxConstraints constraints, WindowSizeClass sizeClass) {
    final double dividerThickness = 1.0;
    final Color dividerColor = Theme.of(context).colorScheme.outlineVariant;
    final EdgeInsets panelPadding = sizeClass == WindowSizeClass.expanded
        ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
        : const EdgeInsets.all(16.0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Panel: Reference Materials (Isolated Scroll)
                  Expanded(
                    flex: sizeClass == WindowSizeClass.expanded ? 1 : 1,
                    child: Padding(
                      padding: panelPadding,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: referencePanel,
                      ),
                    ),
                  ),
                  // Thin, high-contrast divider element
                  VerticalDivider(
                    width: dividerThickness,
                    thickness: dividerThickness,
                    color: dividerColor,
                  ),
                  // Right Panel: Input Data Fields (Isolated Scroll)
                  Expanded(
                    flex: sizeClass == WindowSizeClass.expanded ? 1 : 1,
                    child: Padding(
                      padding: panelPadding,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: inputPanel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fixed, sticky tray for immediate thumb access
            if (stickyActions.isNotEmpty) _buildStickyTray(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyTray(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: stickyActions,
        ),
      ),
    );
  }
}

// --- MOCK DATA & USAGE EXAMPLE ---

/// Mock reference document widget simulating backend data.
class MockReferencePanel extends StatelessWidget {
  const MockReferencePanel({super.key});

  @override
  Widget build(BuildContext context) {
    const String mockDocumentText = '''
UDF Transaction Reference Document
----------------------------------
Transaction ID: TXN-2026-09-25-001
Date: September 25, 2026
Status: Pending Verification

Description:
This document serves as the source material for data entry validation.
The user must verify the transaction details against the input form 
provided on the adjacent panel.

Terms & Conditions:
1. All fields must match exactly.
2. Discrepancies require manual override approval.
3. Timestamps are recorded in UTC.
''';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source Reference',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12.0),
            const Text(mockDocumentText),
          ],
        ),
      ),
    );
  }
}

/// Mock input form widget simulating data entry fields.
class MockInputPanel extends StatelessWidget {
  const MockInputPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Entry Form',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Transaction ID',
                hintText: 'TXN-2026-09-25-001',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Verification Status',
                hintText: 'Pending',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example screen demonstrating the ResponsiveSplitLayout integration.
class UdfSplitScreenExample extends StatelessWidget {
  const UdfSplitScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSplitLayout(
      referencePanel: const MockReferencePanel(),
      inputPanel: const MockInputPanel(),
      stickyActions: [
        TextButton(
          onPressed: () {},
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12.0),
        FilledButton(
          onPressed: () {},
          child: const Text('Submit Verification'),
        ),
      ],
    );
  }
}