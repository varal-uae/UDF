// ============================================================================
// TELEMETRY METADATA BLOCK
// Template Name: Supporting Pane Layout Wrapper
// Template Version: 1.0.0
// Template Type: Material Design Adaptive Side-Sheet
// Template Configuration: Fluid Responsive LayoutBuilder
// Layout Type: Row (Web > 800px) / Column + ExpansionTile (Mobile <= 800px)
// Layout Grid Dimensions: Flex 7:3 / Fluid 100%
// Spacing Rules: 16dp Container Padding, 12dp Gap
// Alignment Settings: CrossAxisAlignment.start
// Layout Validation Status: Validated
// Completion Status: Pass - Asset/Resource Location & Access Confirmation
// ============================================================================

import 'package:flutter/material.dart';

/// RCGLA-033: Supporting Pane Layout Wrapper
///
/// Material Design adaptive side-sheet architecture. Renders side-by-side (flex 7:3)
/// on Web/Desktop (> 800px) and fluid Column with ExpansionTile support pane on Mobile (<= 800px).
class SupportingPaneLayoutWrapper extends StatelessWidget {
  final Widget primaryContent;
  final Widget supportingPane;
  final double? staticWidthOverride;

  const SupportingPaneLayoutWrapper({
    super.key,
    required this.primaryContent,
    required this.supportingPane,
    this.staticWidthOverride,
  }) : assert(
         staticWidthOverride == null,
         'SupportingPaneLayoutWrapper Poka-Yoke Failure: Static width overrides are strictly prohibited. '
         'Fluid flex layouts (flex 7:flex 3) must be utilized to maintain design system responsiveness.',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopWeb = constraints.maxWidth > 800;

        if (isDesktopWeb) {
          // Web/Desktop View (Side-by-Side): Row with flex 7 (primary) and flex 3 (supporting side-sheet)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: primaryContent,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 1,
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Supporting Pane",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        supportingPane,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile View (<= 800px): Primary content top + ExpansionTile collapsible support pane below
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primaryContent,
                const SizedBox(height: 16.0),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      "View Contextual Tips / Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: supportingPane,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Demo Workspace Screen for SupportingPaneLayoutWrapper
class SupportingPaneDemoScreen extends StatelessWidget {
  const SupportingPaneDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supporting Pane Layout (RCGLA-033)"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SupportingPaneLayoutWrapper(
            primaryContent: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Primary Focus Workspace Pane",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Main operations, data tables, and primary form inputs stay centered in the viewport.",
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: "Primary Task Field",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            supportingPane: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Contextual Assistance & Guidelines",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "• Side-sheet expands on screens > 800px width.\n"
                  "• Reflows into collapsible ExpansionTile on mobile.\n"
                  "• Poka-yoke assertion blocks static pixel overrides.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
