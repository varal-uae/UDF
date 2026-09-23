// RCGLA-020-A03 — Reusable Contextual Mirror Grid Module.
// Allocates available screen width equally so evidence views take up exactly half of the workspace, shifting from side-by-side to stacked presentation on compact viewports per Material Design 3 window size classes.

import 'package:flutter/material.dart';

/// Data model for workspace context required by the mirror grid.
class WorkspaceConfig {
  final String workspaceName;
  final String workspaceId;
  final Map<String, dynamic> configuration;
  final List<String> memberList;
  final String workspaceStatus;

  const WorkspaceConfig({
    required this.workspaceName,
    required this.workspaceId,
    required this.configuration,
    required this.memberList,
    required this.workspaceStatus,
  });
}

/// Mock data provider satisfying backend data requirements locally.
class MockWorkspaceRepository {
  static const WorkspaceConfig defaultWorkspace = WorkspaceConfig(
    workspaceName: 'UDF Exception Verification',
    workspaceId: 'WS-RCGLA-020-001',
    configuration: {'splitRatio': 0.5, 'highContrast': true},
    memberList: ['Agent-01', 'Agent-02', 'Reviewer-01'],
    workspaceStatus: 'ACTIVE',
  );
}

/// Material Design 3 Window Size Class boundaries.
enum Md3WindowSizeClass { compact, medium, expanded }

Md3WindowSizeClass getWindowSizeClass(double width) {
  if (width < 600) return Md3WindowSizeClass.compact; // 0-599dp
  if (width < 840) return Md3WindowSizeClass.medium; // 600-839dp
  return Md3WindowSizeClass.expanded; // >=840dp
}

/// Reusable Contextual Mirror Grid layout component.
/// Enforces strict equal-width split for evidence views and adapts
/// flex-direction automatically based on device orientation/viewport.
class ContextualMirrorGrid extends StatelessWidget {
  final Widget primaryView;
  final Widget evidenceView;
  final WorkspaceConfig workspaceConfig;

  const ContextualMirrorGrid({
    super.key,
    required this.primaryView,
    required this.evidenceView,
    this.workspaceConfig = const WorkspaceConfig(
      workspaceName: 'Default Workspace',
      workspaceId: 'WS-DEFAULT',
      configuration: {},
      memberList: [],
      workspaceStatus: 'UNKNOWN',
    ),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final Md3WindowSizeClass sizeClass = getWindowSizeClass(maxWidth);

        // Poka-Yoke: Block custom local CSS grid styles by enforcing strict Flex layout.
        // Thin division accents separate interaction sectors clearly.
        final Divider divider = Divider(
          thickness: 1.0,
          color: Theme.of(context).colorScheme.outlineVariant,
        );

        if (sizeClass == Md3WindowSizeClass.compact) {
          // Stacked presentation block on small mobile viewports.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: primaryView),
              divider,
              Expanded(child: evidenceView),
            ],
          );
        }

        // Side-by-side presentation: Evidence views take up exactly half of the workspace.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 1, child: primaryView),
            SizedBox(
              width: 1.0,
              child: VerticalDivider(
                thickness: 1.0,
                width: 1.0,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            Expanded(flex: 1, child: evidenceView),
          ],
        );
      },
    );
  }
}

/// Master split container blueprint wrapper ensuring standardized interface presentations.
class ContextualMirrorGridScreen extends StatelessWidget {
  const ContextualMirrorGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkspaceConfig config = MockWorkspaceRepository.defaultWorkspace;

    return Scaffold(
      appBar: AppBar(
        title: Text(config.workspaceName),
        elevation: 0.0, // Match elevation shading patterns with systematic level structures
      ),
      body: ContextualMirrorGrid(
        workspaceConfig: config,
        primaryView: _buildMockPanel(
          context,
          title: 'Transaction Entry',
          content: 'Primary operational data exception view.',
        ),
        evidenceView: _buildMockPanel(
          context,
          title: 'Evidence Verification',
          content: 'Matching evidence side-by-side for quick resolution.',
        ),
      ),
    );
  }

  Widget _buildMockPanel(BuildContext context, {required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 1.0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            // High contrast ratio rendering to reduce user visual fatigue
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Resolve Exception'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}