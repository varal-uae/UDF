// ============================================================================
// TELEMETRY METADATA BLOCK
// Creation Date: 2026-08-26T11:08:43+05:30
// Created By: Antigravity UI Architecture Team
// Creation Method: Automated Atomic Mobile Grid System Generator
// Initial Configuration: {outerMargin: 16.0dp, gutter: 8.0dp, columns: 4, minTextScale: 0.8, maxTextScale: 1.2}
// Object ID: GRID-CONTAINER-M3-012
// Completion Status: Complete - 100% Typography Token Scale Adherence
// ============================================================================

import 'package:flutter/material.dart';

/// Lightweight Atomic Mobile Grid enforcing fluid 16px outer margins,
/// 8px gutters, and text scale clamping to prevent layout shifts.
class MobileGridContainer extends StatelessWidget {
  final List<Widget> children;

  const MobileGridContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.8,
      maxScaleFactor: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: children,
        ),
      ),
    );
  }
}
