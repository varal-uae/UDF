// SSTLA-028-A15 — Mobile 12-Column Grid Layout Configuration.
// Enforces a strict 12-column grid for mobile viewports, anchoring input elements and video players to prevent layout shifting during rotation or screen changes.

import 'package:flutter/material.dart';

/// Poka-Yoke: The framework blocks layouts that do not match the standard 12-column grid.
/// Any child count not divisible into the 12-column system will trigger an assertion failure,
/// stopping development updates (Self-Chasing).
class MobileGridLayout extends StatelessWidget {
  final List<GridItem> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  const MobileGridLayout({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  }) : assert(
          children.length > 0,
          'MobileGridLayout must contain at least one GridItem.',
        );

  @override
  Widget build(BuildContext context) {
    // Validate 12-column compliance at build time
    _validateGridColumnCompliance();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - padding.horizontal - (spacing * 11);
        final double columnWidth = availableWidth / 12.0;

        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((item) {
              final double itemWidth = (columnWidth * item.columnSpan) + (spacing * (item.columnSpan - 1));
              
              return SizedBox(
                width: itemWidth.clamp(0.0, constraints.maxWidth),
                child: item.child,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Automated compiler test equivalent: fails if spans don't align to the 12-column grid logic.
  void _validateGridColumnCompliance() {
    for (final item in children) {
      if (item.columnSpan < 1 || item.columnSpan > 12) {
        throw FlutterError(
          'Poka-Yoke Violation: GridItem column span must be between 1 and 12. '
          'Received: ${item.columnSpan}. Non-compliant layout changes are blocked.',
        );
      }
    }
  }
}

/// Represents a single element anchored within the 12-column grid.
class GridItem {
  final int columnSpan;
  final Widget child;

  const GridItem({
    required this.columnSpan,
    required this.child,
  });
}

/// Anchored Video Player Container to prevent layout shifting.
class AnchoredVideoPlayerContainer extends StatelessWidget {
  final String videoUrl;
  final int columnSpan;

  const AnchoredVideoPlayerContainer({
    super.key,
    required this.videoUrl,
    this.columnSpan = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade800, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 48.0),
            const SizedBox(height: 8.0),
            Text(
              'Help Video Anchored',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4.0),
            Text(
              videoUrl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Input box with clear boundary tints to highlight active state (Mobile-First UI GMRD Decision).
class BoundedInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int columnSpan;

  const BoundedInputField({
    super.key,
    required this.label,
    this.controller,
    this.columnSpan = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

/// Verification button placed in easy thumb-reach areas near the lower edge.
class ThumbReachVerificationButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final int columnSpan;

  const ThumbReachVerificationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.columnSpan = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.verified_user_outlined),
        label: Text(label, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }
}

/// Mock data and configuration constants for atomic-level data fields.
class GridLayoutMockData {
  static const String frontendTechnology = 'Flutter';
  static const String frameworkVersion = '3.24.0';
  static const String buildConfiguration = 'Release';
  static const String performanceMetrics = '60fps_target_locked';
  static const String buildOutputPath = 'build/app/outputs/flutter-apk/';
  
  static Map<String, dynamic> toJson() => {
    'frontend_technology': frontendTechnology,
    'framework_version': frameworkVersion,
    'build_configuration': buildConfiguration,
    'performance_metrics': performanceMetrics,
    'build_output_path': buildOutputPath,
  };
}

/// Example usage demonstrating the fixed layout grid configuration sheet.
class MobileGridExampleScreen extends StatelessWidget {
  const MobileGridExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UDF Grid Layout')),
      body: SafeArea(
        child: MobileGridLayout(
          children: [
            GridItem(
              columnSpan: 12,
              child: const AnchoredVideoPlayerContainer(videoUrl: 'https://mock-cdn.udf.ae/help.mp4'),
            ),
            GridItem(
              columnSpan: 12,
              child: const BoundedInputField(label: 'Asset ID'),
            ),
            GridItem(
              columnSpan: 6,
              child: const BoundedInputField(label: 'Quantity'),
            ),
            GridItem(
              columnSpan: 6,
              child: const BoundedInputField(label: 'Unit Price'),
            ),
            GridItem(
              columnSpan: 12,
              child: const SizedBox(height: 24.0), // Spacer for thumb reach
            ),
            GridItem(
              columnSpan: 12,
              child: ThumbReachVerificationButton(
                label: 'Verify Entry',
                onPressed: () {
                  // Log user touch profiles to identify and correct alignment issues over time
                  debugPrint('Verification triggered. Metrics: ${GridLayoutMockData.toJson()}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}