import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

/// Phase 2: Responsive Grid & Layout System
enum AppDisplayBreakpoint {
  mobile,      // 360px+ : 4 cols, 16px margin, 8px gap
  tablet,      // 600px+ : 8 cols, 24px margin, 16px gap
  tabletLarge, // 840px+ : 12 cols, 24px margin, 24px gap
  desktop,     // 1200px+: 12 cols, 32px margin, 24px gap, max 1200px
}

class AppResponsiveHelper {
  static AppDisplayBreakpoint getBreakpoint(double width) {
    if (width >= 1200) return AppDisplayBreakpoint.desktop;
    if (width >= 840) return AppDisplayBreakpoint.tabletLarge;
    if (width >= 600) return AppDisplayBreakpoint.tablet;
    return AppDisplayBreakpoint.mobile;
  }

  static double getMargin(double width) {
    if (width >= 1200) return AppDesignTokens.spaceXl; // 32.0
    if (width >= 600) return AppDesignTokens.spaceL;  // 24.0
    return AppDesignTokens.spaceM;                     // 16.0
  }

  static double getGap(double width) {
    if (width >= 840) return AppDesignTokens.spaceL;  // 24.0
    if (width >= 600) return AppDesignTokens.spaceM;  // 16.0
    return AppDesignTokens.spaceS;                    // 8.0
  }

  static int getColumns(double width) {
    if (width >= 840) return 12;
    if (width >= 600) return 8;
    return 4;
  }
}

/// 2.2 Full-Width Container Widget
/// Dynamic padding (16px mobile to 32px desktop) constrained at max 1200px width.
class AppFullWidthContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppFullWidthContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final margin = AppResponsiveHelper.getMargin(width);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200.0),
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: margin),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 2.2 Card Grid Widget
/// Stacks 1 column on mobile, 2 columns on tablet, and 4 columns on desktop.
class AppCardGrid extends StatelessWidget {
  final List<Widget> children;

  const AppCardGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 1;

        if (width >= 1200) {
          crossAxisCount = 4;
        } else if (width >= 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        final gap = AppResponsiveHelper.getGap(width);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: 220.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// 2.2 Dual-Pane Data Entry Layout Widget
/// Desktop/Tablet (>=600px): Split 50/50 horizontally. Left pane = read-only Context/Evidence; Right pane = Data Entry form.
/// Mobile (<600px): Vertical stack where Context becomes a collapsible sticky header while Data Entry scrolls beneath.
class AppDualPaneLayout extends StatefulWidget {
  final Widget contextPane;
  final Widget dataEntryPane;
  final String contextTitle;

  const AppDualPaneLayout({
    super.key,
    required this.contextPane,
    required this.dataEntryPane,
    this.contextTitle = 'Read-Only Context & Evidence',
  });

  @override
  State<AppDualPaneLayout> createState() => _AppDualPaneLayoutState();
}

class _AppDualPaneLayoutState extends State<AppDualPaneLayout> {
  bool _isContextExpandedOnMobile = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          // Desktop / Tablet 50/50 Horizontal Split
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Pane: Read-Only Context / Evidence
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spaceL),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.primary),
                          const SizedBox(width: AppDesignTokens.spaceS),
                          Text(
                            widget.contextTitle,
                            style: AppDesignTokens.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      widget.contextPane,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDesignTokens.spaceL),

              // Right Pane: Data Entry Form
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(AppDesignTokens.spaceL),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: widget.dataEntryPane,
                ),
              ),
            ],
          );
        } else {
          // Mobile: Collapsible Sticky Header Context + Data Entry below
          return Column(
            children: [
              // Collapsible Context Header
              Card(
                elevation: AppDesignTokens.elevation1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ExpansionTile(
                  initiallyExpanded: _isContextExpandedOnMobile,
                  onExpansionChanged: (val) {
                    setState(() {
                      _isContextExpandedOnMobile = val;
                    });
                  },
                  leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                  title: Text(
                    widget.contextTitle,
                    style: AppDesignTokens.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Tap to view/collapse evidence context'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDesignTokens.spaceM),
                      child: widget.contextPane,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesignTokens.spaceM),

              // Data Entry Pane
              Container(
                padding: const EdgeInsets.all(AppDesignTokens.spaceM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: widget.dataEntryPane,
              ),
            ],
          );
        }
      },
    );
  }
}
