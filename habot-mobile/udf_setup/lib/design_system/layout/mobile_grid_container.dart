/// AISS: RCGLA-012-A01 -- substep 3 "Build a pure MobileGridContainer
/// component restricted to 20 lines."
///
/// "Pure" is taken literally: this widget reads nothing but its own arguments
/// and the incoming constraints. No Theme lookup, no MediaQuery, no state.
/// That is what makes it testable at any width without a full app around it,
/// and it is asserted by `RCGLA-012-G3`, which counts the lines of `build`.
///
/// The 20-line budget is a real constraint, not decoration: it forces the
/// arithmetic out into [HabotGrid] where it can be unit-tested as pure
/// functions, instead of hiding inside a widget.
library;

import 'package:flutter/widgets.dart';

import '../tokens/grid_tokens.dart';

/// The foundational layout block. Every visual view inherits from this.
class MobileGridContainer extends StatelessWidget {
  const MobileGridContainer({
    required this.child,
    this.applyOuterMargin = true,
    super.key,
  });

  final Widget child;
  final bool applyOuterMargin;

  // BUILD-BUDGET: RCGLA-012 substep 3 caps this method at 20 lines.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double margin = applyOuterMargin ? HabotGrid.outerMargin : 0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: HabotGrid.maxContentWidthFor(constraints.maxWidth),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
