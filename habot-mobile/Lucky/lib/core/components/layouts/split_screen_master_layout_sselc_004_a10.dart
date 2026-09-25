// SSELC-004-A10 — Split Screen Master Layout Component.
// Implements a responsive 12-column twin-pane layout that collapses to a single vertical scroll on viewports below 600dp, enforcing Material 3 high-contrast styling and precise touch bounds.

import 'package:flutter/material.dart';

/// Mock data models for the split-screen compliance mapping fields.
class ComplianceMappingData {
  final String sourceElementId;
  final String targetElementId;
  final String mappingRule;
  final String mappingStatus;
  final bool mappingValidation;

  const ComplianceMappingData({
    required this.sourceElementId,
    required this.targetElementId,
    required this.mappingRule,
    required this.mappingStatus,
    required this.mappingValidation,
  });
}

/// Local mock data repository simulating backend ingress.
class MockComplianceRepository {
  static const List<ComplianceMappingData> mappings = [
    ComplianceMappingData(
      sourceElementId: 'SRC-001',
      targetElementId: 'TGT-101',
      mappingRule: 'Direct Match',
      mappingStatus: 'Pending Review',
      mappingValidation: false,
    ),
    ComplianceMappingData(
      sourceElementId: 'SRC-002',
      targetElementId: 'TGT-102',
      mappingRule: 'Transform & Map',
      mappingStatus: 'Validated',
      mappingValidation: true,
    ),
    ComplianceMappingData(
      sourceElementId: 'SRC-003',
      targetElementId: 'TGT-103',
      mappingRule: 'Fallback Default',
      mappingStatus: 'Exception',
      mappingValidation: false,
    ),
  ];
}

/// Master split-screen layout component handling twin data visibility streams.
/// Extensible for all custom exception review portals.
class SplitScreenMasterLayout extends StatelessWidget {
  final Widget leftPaneContent;
  final Widget rightPaneContent;
  final String title;

  const SplitScreenMasterLayout({
    super.key,
    required this.leftPaneContent,
    required this.rightPaneContent,
    this.title = 'Compliance Review Portal',
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        centerTitle: !isMobile,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: isMobile
            ? _buildMobileVerticalLayout(theme)
            : _buildDesktopSplitLayout(theme),
      ),
    );
  }

  /// Collapses side-by-side sections into a single vertical scrolling layout on phones.
  Widget _buildMobileVerticalLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPaneContainer(
            theme: theme,
            label: 'Evidence Reference',
            child: leftPaneContent,
          ),
          const SizedBox(height: 24.0),
          _buildPaneContainer(
            theme: theme,
            label: 'Action Panel',
            child: rightPaneContent,
          ),
        ],
      ),
    );
  }

  /// Builds structured split-screen view using responsive 12-column template architecture.
  /// Left panel takes 5 columns, Right panel takes 7 columns (interactive compliance fields).
  Widget _buildDesktopSplitLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 5/12 columns for reference/evidence
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildPaneContainer(
              theme: theme,
              label: 'Evidence Reference',
              child: leftPaneContent,
            ),
          ),
        ),
        // Vertical divider for clear visual separation
        VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: theme.colorScheme.outlineVariant,
        ),
        // 7/12 columns for interactive action components mapped strictly to right panel grid space
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildPaneContainer(
              theme: theme,
              label: 'Action Panel',
              child: rightPaneContent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaneContainer({
    required ThemeData theme,
    required String label,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Standardized widget for displaying mock evidence data in the left pane.
class EvidenceReferencePanel extends StatelessWidget {
  const EvidenceReferencePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mappings = MockComplianceRepository.mappings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children mappings.map((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Source ID: ${data.sourceElementId}', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4.0),
                  Text('Target ID: ${data.targetElementId}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4.0),
                  Text('Rule: ${data.mappingRule}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Interactive compliance fields mapped strictly into the right panel grid space.
/// Enforces minimum 48x48dp touch targets for accessibility.
class ComplianceActionPanel extends StatefulWidget {
  const ComplianceActionPanel({super.key});

  @override
  State<ComplianceActionPanel> createState() => _ComplianceActionPanelState();
}

class _ComplianceActionPanelState extends State<ComplianceActionPanel> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _validationStates = {};

  @override
  void initState() {
    super.initState();
    for (final data in MockComplianceRepository.mappings) {
      _controllers[data.sourceElementId] = TextEditingController(text: data.mappingStatus);
      _validationStates[data.sourceElementId] = data.mappingValidation;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mappings = MockComplianceRepository.mappings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...mappings.map((data) {
          final controller = _controllers[data.sourceElementId]!;
          final isValid = _validationStates[data.sourceElementId] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validate ${data.sourceElementId} -> ${data.targetElementId}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: isValid ? theme.colorScheme.outline : theme.colorScheme.error,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: Icon(
                      isValid ? Icons.check_circle_outline : Icons.error_outline,
                      color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _validationStates[data.sourceElementId] = value.trim().isNotEmpty && value == 'Validated';
                    });
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8.0),
        FilledButton.icon(
          onPressed: () {
            // Poka-Yoke: Ingress validation configuration check before submission
            final allValid = _validationStates.values.every((v) => v);
            if (!allValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All fields must be validated before submission.'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compliance mappings submitted successfully.')),
            );
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Submit Validations'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48.0), // Strict finger-reach bounds
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}

/// Usage Example / Entry Point for testing orientation locking execution and layout accuracy.
class SplitScreenMasterScreen extends StatelessWidget {
  const SplitScreenMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitScreenMasterLayout(
      title: 'UDF Exception Review',
      leftPaneContent: const EvidenceReferencePanel(),
      rightPaneContent: const ComplianceActionPanel(),
    );
  }
}
