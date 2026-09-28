// SSELC-033-A09 — Contextual Mirror Layout for Universal Split-Screen.
// Locks evidence displays securely to the top 40% viewport area on collapsed mobile views, preventing double scroll and keyboard displacement issues using Material 3 standards.

import 'package:flutter/material.dart';

/// Mock data representing background data item delivery hooks.
class _MockEvidenceData {
  static const String title = 'Secure Evidence Observation';
  static const String description =
      'Ironclad visual protection of personal information arrays. This surface provides radical scaling of processing capacity by removing layout variance issues.';
  static const List<String> fields = [
    'Mobile Platform: Android / iOS',
    'OS Version: 14.0+',
    'Device Type: Handheld',
    'Screen Dimensions: Dynamic',
    'Configuration: Mobile-First'
  ];
}

/// A master workspace container system structure that dynamically collapses
/// a desktop 50/50 split panel view into a single vertical stacked configuration
/// on smaller screen breakpoints, locking evidence securely to the top 40% viewport area.
class ContextualMirrorLayoutSSELC033A09 extends StatelessWidget {
  const ContextualMirrorLayoutSSELC033A09({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isMobile = mediaQuery.size.width < 600;

    // Hard-lock view container sizing definitions programmatically to prevent
    // soft-keyboard expansion events from shoving observation boxes off-screen.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Contextual Workspace'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (isMobile) {
              return _buildMobileLayout(theme, constraints);
            }
            return _buildDesktopLayout(theme, constraints);
          },
        ),
      ),
    );
  }

  /// Dynamically collapses into a single vertical stacked configuration,
  /// locking evidence securely to the top 40% viewport area.
  Widget _buildMobileLayout(ThemeData theme, BoxConstraints constraints) {
    final double totalHeight = constraints.maxHeight;
    final double evidenceHeight = totalHeight * 0.40; // Top 40% locked
    final double actionHeight = totalHeight * 0.60; // Remaining 60%

    return Column(
      children: <Widget>[
        SizedBox(
          height: evidenceHeight,
          child: _buildEvidenceSurface(theme),
        ),
        SizedBox(
          height: actionHeight,
          child: _buildActionSurface(theme),
        ),
      ],
    );
  }

  /// Desktop 50/50 split panel view.
  Widget _buildDesktopLayout(ThemeData theme, BoxConstraints constraints) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: _buildEvidenceSurface(theme),
        ),
        Expanded(
          flex: 1,
          child: _buildActionSurface(theme),
        ),
      ],
    );
  }

  /// Primary observation surface with sharp structural contrast parameters
  /// and distinct surface elevation shifts.
  Widget _buildEvidenceSurface(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        // Block double scroll interactions by constraining physics where appropriate
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.shield_outlined,
                  color: theme.colorScheme.primary,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Text(
                  _MockEvidenceData.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              _MockEvidenceData.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            ..._MockEvidenceData.fields.map((String field) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        size: 16.0,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          field,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Action card surface separated by distinct surface elevation shifts.
  /// Contains entry forms built using standard user flow design patterns.
  Widget _buildActionSurface(ThemeData theme) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Sharp structural contrast
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Active Collection Fields',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Tooltip(
              message: 'Structural form requirements: Enter verified data only.',
              preferBelow: false,
              child: Icon(
                Icons.info_outline,
                size: 16.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Observation Reference ID',
                hintText: 'Enter ID',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Evaluator Notes',
                hintText: 'Type evaluation notes here...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined),
                label: const Text('Submit Evaluation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
