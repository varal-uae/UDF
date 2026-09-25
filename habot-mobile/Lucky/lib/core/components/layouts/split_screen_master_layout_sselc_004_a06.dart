// SSELC-004-A06 — Split Screen Master Layout Component.
// Implements a responsive 12-column twin-pane layout that allocates columns 1-6 to the left context pane and 7-12 to the right action pane, collapsing to a vertical stack below 600dp.

import 'package:flutter/material.dart';

/// Atomic-level data model for layout validation and telemetry.
class LayoutValidationData {
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final String layoutValidationStatus;
  final String completionStatus;
  final DateTime actionTimestamp;
  final String userSessionId;

  const LayoutValidationData({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
  });

  Map<String, dynamic> toJson() => {
        'Layout Type': layoutType,
        'Layout Grid Dimensions': layoutGridDimensions,
        'Spacing Rules': spacingRules,
        'Alignment Settings': alignmentSettings,
        'Layout Validation Status': layoutValidationStatus,
        'Completion Status': completionStatus,
        'Action/Event Timestamp': actionTimestamp.toIso8601String(),
        'User/Session ID': userSessionId,
      };
}

/// Mock data repository satisfying backend data requirements locally.
class LayoutMockRepository {
  static const LayoutValidationData mockValidationData = LayoutValidationData(
    layoutType: 'Split-Screen 12-Column Master',
    layoutGridDimensions: '12 Columns, Fluid Container',
    spacingRules: '8dp base structural multiples',
    alignmentSettings: 'Top-Start',
    layoutValidationStatus: 'Validated',
    completionStatus: 'Good',
    actionTimestamp: null as dynamic,
    userSessionId: 'MOCK-SESSION-001',
  );

  static LayoutValidationData getInitialData() {
    return LayoutValidationData(
      layoutType: mockValidationData.layoutType,
      layoutGridDimensions: mockValidationData.layoutGridDimensions,
      spacingRules: mockValidationData.spacingRules,
      alignmentSettings: mockValidationData.alignmentSettings,
      layoutValidationStatus: mockValidationData.layoutValidationStatus,
      completionStatus: mockValidationData.completionStatus,
      actionTimestamp: DateTime.now(),
      userSessionId: mockValidationData.userSessionId,
    );
  }
}

/// State mutation event listener controller for interactive form inputs.
class FormStateMutationController extends ChangeNotifier {
  String _currentInputValue = '';
  String get currentInputValue => _currentInputValue;

  void updateInputValue(String newValue) {
    _currentInputValue = newValue;
    notifyListeners();
  }
}

/// The master split-screen component handling twin data visibility streams.
/// Extensible by all custom exception review portals.
class SplitScreenMasterLayout extends StatefulWidget {
  final Widget leftContextPane;
  final Widget rightActionPane;
  final FormStateMutationController? mutationController;

  const SplitScreenMasterLayout({
    super.key,
    required this.leftContextPane,
    required this.rightActionPane,
    this.mutationController,
  });

  @override
  State<SplitScreenMasterLayout> createState() => _SplitScreenMasterLayoutState();
}

class _SplitScreenMasterLayoutState extends State<SplitScreenMasterLayout> {
  late final LayoutValidationData _layoutData;

  @override
  void initState() {
    super.initState();
    _layoutData = LayoutMockRepository.getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Mobile-First & Responsive UX: Stack vertically when viewport < 600dp
        final bool isMobileViewport = constraints.maxWidth < 600.0;

        if (isMobileViewport) {
          return _buildVerticalStackLayout(context);
        }

        return _buildSplitScreenLayout(context);
      },
    );
  }

  /// Desktop/Tablet: 12-Column Template Architecture
  /// Columns 1-6 exclusively dedicated to Left Context pane.
  /// Columns 7-12 dedicated to Right Action pane.
  Widget _buildSplitScreenLayout(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double spacing = 8.0; // Exact structural layout spacing multiple

    return Container(
      color: theme.colorScheme.surface, // Clean neutral shade for legibility
      padding: EdgeInsets.all(spacing * 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Context Pane (Columns 1 through 6 -> 50% width)
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: widget.leftContextPane,
            ),
          ),
          SizedBox(width: spacing * 2),
          // Right Action Pane (Columns 7 through 12 -> 50% width)
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: widget.rightActionPane,
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile: Collapses side-by-side sections into a single vertical scrolling layout.
  Widget _buildVerticalStackLayout(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double spacing = 8.0;

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section: Left Context Pane
            Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: widget.leftContextPane,
            ),
            SizedBox(height: spacing * 2),
            // Bottom Section: Right Action Pane
            Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: widget.rightActionPane,
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized touch layout constraints wrapper ensuring proper finger-reach bounds.
class TouchOptimizedInteractiveZone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TouchOptimizedInteractiveZone({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Minimum 48x48dp touch target per Material Design accessibility guidelines
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0,
        minWidth: 48.0,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// High-contrast active data field style configuration.
class ActiveDataField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;

  const ActiveDataField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 3.0, // High contrast distinction for active fields
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}