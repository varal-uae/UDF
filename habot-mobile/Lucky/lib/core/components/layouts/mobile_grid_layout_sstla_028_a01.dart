// SSTLA-028-A01 — Mobile 12-Column Grid Layout Configuration.
// Enforces a strict 12-column grid for mobile viewports, anchoring input elements and video players to prevent layout shifting during rotation stress tests.

import 'package:flutter/material.dart';

/// Configuration data class for the 12-column mobile grid.
class GridLayoutConfig {
  final String layoutType;
  final int columns;
  final double spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const GridLayoutConfig({
    required this.layoutType,
    required this.columns,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Mock data representing the atomic-level data fields required by the system.
const GridLayoutConfig mockGridConfig = GridLayoutConfig(
  layoutType: 'Mobile_12_Column_Fixed',
  columns: 12,
  spacingRules: 8.0,
  alignmentSettings: Alignment.topCenter,
  layoutValidationStatus: true,
);

/// A layout widget that strictly enforces a 12-column grid configuration
/// specifically tailored for mobile viewport form assets.
/// It anchors input elements and video players to prevent layout shifting.
class MobileGridLayout extends StatelessWidget {
  final List<Widget> children;
  final GridLayoutConfig config;

  const MobileGridLayout({
    super.key,
    required this.children,
    this.config = mockGridConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke: The platform build framework blocks layouts that do not match the standard 12-column grid.
    assert(
      config.columns == 12,
      'Mistake-Proofing Violation: Non-compliant layout changes fail automated compiler tests. '
      'Layout must strictly use a 12-column grid. Provided: ${config.columns}',
    );
    assert(
      config.layoutValidationStatus == true,
      'Layout validation status must be true before rendering.',
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double columnWidth =
            (screenWidth - (config.spacingRules * (config.columns + 1))) /
                config.columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top area for form inputs anchored predictably
            Padding(
              padding: EdgeInsets.symmetric(horizontal: config.spacingRules),
              child: Wrap(
                spacing: config.spacingRules,
                runSpacing: config.spacingRules,
                children: children.map((child) {
                  return SizedBox(
                    width: columnWidth * 12, // Default full width on mobile
                    child: child,
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            // Mobile-First UX GMRD Decision: Place verification buttons in easy thumb-reach areas near the lower edge.
            // Mobile-First UI GMRD Implementation: Anchor the help video player consistently to prevent layout shifting.
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(config.spacingRules),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnchoredVideoPlayer(context, config),
                    SizedBox(height: config.spacingRules),
                    _buildVerificationButton(context, config),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnchoredVideoPlayer(
      BuildContext context, GridLayoutConfig config) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 48),
      ),
    );
  }

  Widget _buildVerificationButton(
      BuildContext context, GridLayoutConfig config) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.verified_user_outlined),
        label: const Text('Verify & Submit'),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// A wrapper input field applying clear boundary tints to highlight active input boxes.
class GridInputField extends StatefulWidget {
  final String label;
  final String? initialValue;

  const GridInputField({
    super.key,
    required this.label,
    this.initialValue,
  });

  @override
  State<GridInputField> createState() => _GridInputFieldState();
}

class _GridInputFieldState extends State<GridInputField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mobile-First UI GMRD Decision: Use clear boundary tints to highlight active input boxes.
    // Mobile-First UI GMRD Implementation: Keep font scales uniform across data boxes to minimize eye strain.
    return TextField(
      focusNode: _focusNode,
      controller: TextEditingController(text: widget.initialValue),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16, // Uniform font scale
          ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isFocused
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2.5, // Clear boundary tint
          ),
        ),
        filled: true,
        fillColor: _isFocused
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withOpacity(0.15)
            : Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

/// Example usage demonstrating the locked layout map ensuring target components stay fixed.
class MobileFormAssetScreen extends StatelessWidget {
  const MobileFormAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Form Assets'),
      ),
      body: MobileGridLayout(
        config: mockGridConfig,
        children: const [
          GridInputField(label: 'Asset ID'),
          GridInputField(label: 'Description'),
          GridInputField(label: 'Location Code'),
        ],
      ),
    );
  }
}
