/// AISS: TTMCS-001-A01 UI decision -- "UI page frames apply subtle dynamic
/// linear gradients (#F2F6F9 to #EEF2F6) to minimize user reading strain."
///
/// In dark mode the gradient collapses to a flat surface: painting a light
/// wash there would undo the OLED power saving TTMCS-005 exists to deliver, so
/// both gradient stops resolve to the dark surface token.
library;

import 'package:flutter/material.dart';

import '../theme/habot_theme_extension.dart';
import '../tokens/grid_tokens.dart';

class HabotPageFrame extends StatelessWidget {
  const HabotPageFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HabotTokens tokens = HabotTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[tokens.pageFrameStart, tokens.pageFrameEnd],
        ),
      ),
      child: child,
    );
  }
}

/// Decides whether side navigation is collapsed, per the TTMCS-001 rule
/// "Sidebar navigation components auto-collapse smoothly on screen layout sizes
/// under 768px".
///
/// The navigation *chrome* itself is ANSA-012 (Step 9). This is only the policy
/// object, declared now so no component can invent its own collapse threshold
/// before the header lands. The threshold lives in exactly one place --
/// [HabotGrid.navigationCollapse].
class HabotNavigationPolicy {
  const HabotNavigationPolicy._();

  static bool isCollapsed(double width) =>
      HabotGrid.navigationIsCollapsed(width);

  static bool isCollapsedFor(BuildContext context) =>
      isCollapsed(MediaQuery.sizeOf(context).width);
}
