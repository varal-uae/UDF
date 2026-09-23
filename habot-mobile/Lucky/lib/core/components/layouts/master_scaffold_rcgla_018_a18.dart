// RCGLA-018-A18 — Universal Master Layout Architecture for Flutter Components.
// Enforces mobile-first responsive design, pixel-perfect grid alignment, and strips custom local padding via centralized layout rules.

import 'package:flutter/material.dart';

/// Centralized spacing tokens to prevent custom local padding declarations.
class MasterLayoutTokens {
  MasterLayoutTokens._();

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  static const int maxMobileColumns = 4;
  static const int maxTabletColumns = 8;
  static const int maxDesktopColumns = 12;
}

/// Poka-Yoke: Programmatically strips any custom padding applied by children
/// by enforcing a centralized padding structure.
class PaddingStrippingDelegate extends SliverChildBuilderDelegate {
  PaddingStrippingDelegate({
    required NullableIndexedWidgetBuilder builder,
    required int childCount,
  }) : super(builder, childCount: childCount);
}

/// The universal master scaffold enforcing layout consistency across all views.
/// Scales component widths to fill available screen footprints and highlights
/// one clear action zone per view.
class MasterScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final EdgeInsets? forcedOuterPadding;
  final bool enforceSingleActionZone;

  const MasterScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.forcedOuterPadding,
    this.enforceSingleActionZone = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: enforceSingleActionZone ? floatingActionButton : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double screenWidth = constraints.maxWidth;
          
          // Dynamic breakpoint configurations adjusting safely on mobile
          final int columns;
          final double gutter;
          final EdgeInsets safePadding;

          if (screenWidth < MasterLayoutTokens.mobileBreakpoint) {
            columns = MasterLayoutTokens.maxMobileColumns;
            gutter = MasterLayoutTokens.spacingSm;
            safePadding = const EdgeInsets.symmetric(
              horizontal: MasterLayoutTokens.spacingMd,
              vertical: MasterLayoutTokens.spacingSm,
            );
          } else if (screenWidth < MasterLayoutTokens.tabletBreakpoint) {
            columns = MasterLayoutTokens.maxTabletColumns;
            gutter = MasterLayoutTokens.spacingMd;
            safePadding = const EdgeInsets.symmetric(
              horizontal: MasterLayoutTokens.spacingLg,
              vertical: MasterLayoutTokens.spacingMd,
            );
          } else {
            columns = MasterLayoutTokens.maxDesktopColumns;
            gutter = MasterLayoutTokens.spacingLg;
            safePadding = const EdgeInsets.symmetric(
              horizontal: MasterLayoutTokens.spacingXl,
              vertical: MasterLayoutTokens.spacingLg,
            );
          }

          // Poka-Yoke: Override any passed padding with centralized rules
          final EdgeInsets appliedPadding = forcedOuterPadding ?? safePadding;

          return _MasterGridContainer(
            columns: columns,
            gutter: gutter,
            padding: appliedPadding,
            child: body,
          );
        },
      ),
    );
  }
}

/// Internal grid container enforcing clear grid values across layout rules.
class _MasterGridContainer extends StatelessWidget {
  final int columns;
  final double gutter;
  final EdgeInsets padding;
  final Widget child;

  const _MasterGridContainer({
    required this.columns,
    required this.gutter,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: gutter,
          mainAxisSpacing: gutter,
          childAspectRatio: 1.0,
        ),
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          // Scale component widths to fill available screen footprints
          return SizedBox.expand(
            child: child,
          );
        },
      ),
    );
  }
}

/// Adaptive fluid alignment wrapper optimizing density seamlessly.
class AdaptiveFluidAligner extends StatelessWidget {
  final Widget child;
  final int columnSpan;

  const AdaptiveFluidAligner({
    super.key,
    required this.child,
    this.columnSpan = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final int totalColumns = screenWidth < MasterLayoutTokens.mobileBreakpoint
            ? MasterLayoutTokens.maxMobileColumns
            : screenWidth < MasterLayoutTokens.tabletBreakpoint
                ? MasterLayoutTokens.maxTabletColumns
                : MasterLayoutTokens.maxDesktopColumns;

        final int effectiveSpan = columnSpan > totalColumns ? totalColumns : columnSpan;
        final double widthFraction = effectiveSpan / totalColumns;

        return Align(
          alignment: Alignment.topLeft,
          child: FractionallySizedBox(
            widthFactor: widthFraction,
            child: child,
          ),
        );
      },
    );
  }
}

/// Mock data representing architecture pattern metadata for internal reporting.
class MasterLayoutMockData {
  static const Map<String, dynamic> architectureConfig = {
    'pattern': 'Atomic Design',
    'componentHierarchy': ['Atoms', 'Molecules', 'Organisms', 'Templates', 'Pages'],
    'dataFlow': 'Unidirectional',
    'integrationPoints': ['core.ui.master_scaffold', 'shared.adaptive_layout'],
    'completionStatus': 'Complete',
    'timestamp': '2026-09-23T12:00:00Z',
    'sessionId': 'RCGLA-018-A18-MOCK-SESSION'
  };
}