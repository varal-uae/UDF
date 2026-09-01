import 'package:flutter/material.dart';

/// Data Model for CI/CD Accessibility Linter Violation
class CicdAccessibilityViolation {
  final String id;
  final String ruleId;
  final String componentName;
  final String violationDescription;
  final String impact; // Critical, Serious, Moderate

  const CicdAccessibilityViolation({
    required this.id,
    required this.ruleId,
    required this.componentName,
    required this.violationDescription,
    required this.impact,
  });
}

/// Responsive CI/CD Linter Dashboard for WCAG 2.2 AA Compliance (TECH-ENG-038)
/// Features 100% ARIA/Semantics screen reader accessibility wrapper, high-contrast M3 FAIL banner,
/// and LayoutBuilder dual-pane timeline vs DataTable (Web/Tablet) & Mobile Card list.
class CicdLinterAccessibilityDashboard extends StatefulWidget {
  const CicdLinterAccessibilityDashboard({super.key});

  @override
  State<CicdLinterAccessibilityDashboard> createState() =>
      _CicdLinterAccessibilityDashboardState();
}

class _CicdLinterAccessibilityDashboardState
    extends State<CicdLinterAccessibilityDashboard> {
  final List<CicdAccessibilityViolation> _violations = const [
    CicdAccessibilityViolation(
      id: 'VIO-101',
      ruleId: 'WCAG 2.2 1.3.1',
      componentName: 'ProfileAvatar',
      violationDescription: 'Missing semantic label and accessible name attribute.',
      impact: 'Critical',
    ),
    CicdAccessibilityViolation(
      id: 'VIO-102',
      ruleId: 'WCAG 2.2 1.4.3',
      componentName: 'SecondaryBodyText',
      violationDescription: 'Contrast ratio below 4.5:1 requirement (measured 3.1:1).',
      impact: 'Serious',
    ),
    CicdAccessibilityViolation(
      id: 'VIO-103',
      ruleId: 'WCAG 2.2 2.5.8',
      componentName: 'IconButtonSubmit',
      violationDescription: 'Touch target height is 36dp (below 48.0 minHeight rule).',
      impact: 'Serious',
    ),
    CicdAccessibilityViolation(
      id: 'VIO-104',
      ruleId: 'WCAG 2.2 2.4.7',
      componentName: 'CustomCheckboxInput',
      violationDescription: 'Keyboard focus indicator outline missing during tab navigation.',
      impact: 'Moderate',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3. CI/CD Status UI: High-Contrast M3 Error Banner
        _buildHighContrastFailBanner(theme),
        const SizedBox(height: 20.0),

        // 2. Fully Responsive Architecture
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWebTablet = constraints.maxWidth > 600;

            if (isDesktopWebTablet) {
              return _buildWebTabletDualPaneLayout(theme);
            } else {
              return _buildMobileSingleColumnLayout(theme);
            }
          },
        ),
      ],
    );
  }

  /// 3. High-contrast visual banner using Material 3 semantic error colors
  Widget _buildHighContrastFailBanner(ThemeData theme) {
    return Semantics(
      label: 'Build Failure Alert Banner: Build Failed: WCAG 2.2 AA Compliance < 100%',
      container: true,
      child: Card(
        elevation: 3,
        color: theme.colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Semantics(
                label: 'Error Alert Icon',
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  child: const Icon(Icons.gpp_bad_rounded, size: 28.0),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CI/CD PIPELINE GATE REJECTED',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Build Failed: WCAG 2.2 AA Compliance < 100%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Found ${_violations.length} accessibility linter violations blocking deployment.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Re-run Linter Pipeline Button',
                button: true,
                hint: 'Triggers CI/CD linter build re-evaluation',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48.0),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Re-running WCAG 2.2 AA Accessibility Linter...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Re-run Linter'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Web/Tablet View Layout (maxWidth > 600): Row with Timeline & DataTable
  Widget _buildWebTabletDualPaneLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pane: Pipeline Steps Timeline
        Expanded(
          flex: 4,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CI/CD Pipeline Stages',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildPipelineStepTile(
                    theme,
                    stepNumber: '1',
                    title: 'Static Code Analysis',
                    subtitle: 'PASSED (0 errors)',
                    isSuccess: true,
                  ),
                  const SizedBox(height: 12.0),
                  _buildPipelineStepTile(
                    theme,
                    stepNumber: '2',
                    title: 'WCAG 2.2 AA Accessibility Linter',
                    subtitle: 'FAILED (4 violations)',
                    isSuccess: false,
                  ),
                  const SizedBox(height: 12.0),
                  _buildPipelineStepTile(
                    theme,
                    stepNumber: '3',
                    title: 'Container Security Gate',
                    subtitle: 'BLOCKED (Pending Linter)',
                    isPending: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16.0),

        // Right Pane: DataTable of Specific Violations
        Expanded(
          flex: 7,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 600.0),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.surfaceContainerHigh,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text('Violation ID',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('WCAG Rule',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Component',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Impact',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: _violations.map((v) {
                      final isCritical = v.impact == 'Critical';
                      final impactColor = isCritical
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(v.id,
                                style: const TextStyle(fontFamily: 'monospace')),
                          ),
                          DataCell(
                            Chip(
                              label: Text(v.ruleId,
                                  style: const TextStyle(fontSize: 11.0)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          DataCell(
                            Text(v.componentName,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: impactColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                v.impact,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  color: impactColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile View Layout (maxWidth <= 600): Stacked list of error logs
  Widget _buildMobileSingleColumnLayout(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _violations.length,
      itemBuilder: (context, index) {
        final v = _violations[index];
        final isCritical = v.impact == 'Critical';
        final impactColor =
            isCritical ? theme.colorScheme.error : theme.colorScheme.tertiary;

        return Semantics(
          label:
              'Accessibility Violation: ${v.componentName}, ${v.ruleId}, Impact: ${v.impact}',
          hint: v.violationDescription,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: impactColor.withValues(alpha: 0.4)),
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
                        v.componentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          v.impact,
                          style: TextStyle(
                            fontSize: 11.0,
                            color: impactColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: impactColor.withValues(alpha: 0.15),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    v.violationDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rule: ${v.ruleId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        v.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPipelineStepTile(
    ThemeData theme, {
    required String stepNumber,
    required String title,
    required String subtitle,
    bool isSuccess = false,
    bool isPending = false,
  }) {
    final stepColor = isSuccess
        ? theme.colorScheme.primary
        : (isPending ? theme.colorScheme.outline : theme.colorScheme.error);

    return Semantics(
      label: 'Pipeline Step $stepNumber: $title, Status: $subtitle',
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: stepColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: stepColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14.0,
              backgroundColor: stepColor,
              foregroundColor: isSuccess
                  ? theme.colorScheme.onPrimary
                  : (isPending
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onError),
              child: Text(
                stepNumber,
                style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: stepColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
