/// AISS: GEN-00055-A01 -- "Build the BottomSheet atomic component using
///   MD3 design tokens."
/// AISS: GEN-00954-A01 -- "Standardize Material Design 3 (MD3) Bottom-Sheet UI
///   for Mobile Complex Action Flows" / "Configure backdrop scrim color to 32%
///   opacity black."
/// AISS: GEN-00235-A01 -- "Set the default snapping point to 60% viewport
///   height for optimal thumb interaction."
///
/// Three steps, one component. They are separated in the sheet because they
/// decide different things -- the chassis, the scrim, the snap point -- but
/// they describe a single surface, and splitting the surface across three
/// files would mean three places to forget a token.
///
/// The sheet takes no padding, colour, radius or duration parameter. Every one
/// of those comes from a token, which is what makes "MD3 compliant" a property
/// of the component rather than of each call site.
library;

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// GEN-00954: the backdrop behind a modal sheet.
class HabotSheetScrim {
  const HabotSheetScrim._();

  /// "Configure backdrop scrim color to 32% opacity black."
  ///
  /// Both halves of that requirement are tokens: the colour is
  /// [HabotColors.scrim], the opacity is [HabotSheet.scrimOpacity]. Composing
  /// them here means there is exactly one scrim in the app.
  static Color get color =>
      HabotColors.scrim.withValues(alpha: HabotSheet.scrimOpacity);

  /// The scrim always takes the pointer. A modal surface that lets taps
  /// through is not modal, and MD3 treats the scrim as the dismiss affordance.
  static const bool absorbsPointer = true;
}

/// GEN-00235: where the sheet comes to rest.
class HabotSheetSnap {
  const HabotSheetSnap._();

  /// Height in logical pixels of the default resting position on a viewport
  /// [viewportHeight] tall.
  static double defaultHeightFor(double viewportHeight) =>
      viewportHeight * HabotSheet.defaultSnapFraction;

  /// Whether the default stop leaves enough room to be worth opening on a
  /// viewport this tall. Checked against every device in the matrix by
  /// `GEN-00235-G3` rather than assumed from the fraction.
  static bool isUsableOn(double viewportHeight) =>
      defaultHeightFor(viewportHeight) >= HabotSheet.minUsableSheetHeight;

  /// The stops, ascending, with the bounds included exactly once.
  static List<double> get stops => HabotSheet.snapFractions;

  /// True when [fraction] is one of the stops. The sheet may pass through
  /// other values while dragging; it may not settle on them.
  static bool isStop(double fraction) => stops.contains(fraction);
}

/// The sheet chassis: drag handle, MD3 corners, tokenised surface and padding.
///
/// Pumped directly by the gates, so the surface can be measured without
/// standing up a route.
class HabotSheetSurface extends StatelessWidget {
  const HabotSheetSurface({
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  /// Stable handle for the gates, so the drag affordance is found by identity
  /// rather than by guessing at a position in the tree.
  static const Key dragHandleKey = Key('habot.sheet.dragHandle');

  /// MD3 shapes only the leading corners -- the trailing edge is flush with
  /// the screen, which is what makes it read as attached rather than floating.
  static BorderRadius get shape => const BorderRadius.vertical(
    top: Radius.circular(HabotSheet.topCornerRadius),
  );

  static HabotElevationLevel get elevation =>
      HabotElevationLevel.values[HabotSheet.elevationLevel];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: HabotElevation.dp[elevation]!,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(HabotSheet.contentPadding),
        child: SafeArea(
          top: false,
          child: _SheetBody(title: title, actions: actions, child: child),
        ),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.actions,
    required this.child,
  });

  final String title;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _DragHandle(),
        const SizedBox(height: HabotSheet.contentGap),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: HabotSheet.contentGap),
        Flexible(child: child),
        if (actions.isNotEmpty) const SizedBox(height: HabotSheet.contentGap),
        if (actions.isNotEmpty)
          Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
      ],
    );
  }
}

/// The MD3 drag handle. Decorative: it is not the only way to dismiss the
/// sheet, so it carries no semantics and no touch target of its own.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: HabotSheetSurface.dragHandleKey,
        width: HabotSheet.dragHandleWidth,
        height: HabotSheet.dragHandleHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(HabotShape.full),
        ),
      ),
    );
  }
}

/// The presentation API. Everything that opens a sheet in this app goes
/// through here, so the scrim, the snap point and the motion are not
/// per-call-site decisions.
class HabotBottomSheet {
  const HabotBottomSheet._();

  /// Opens a modal sheet resting at [HabotSheet.defaultSnapFraction].
  ///
  /// Motion is resolved through HabotMotionPolicy, so a user who has asked the
  /// OS to reduce motion gets the sheet without the slide.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    List<Widget> actions = const <Widget>[],
    bool draggable = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      barrierColor: HabotSheetScrim.color,
      backgroundColor: Colors.transparent,
      elevation: HabotElevation.dp[HabotSheetSurface.elevation],
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      sheetAnimationStyle: animationStyleFor(context),
      builder: (BuildContext sheetContext) => draggable
          ? _DraggableSheet(title: title, actions: actions, builder: builder)
          : HabotSheetSurface(
              title: title,
              actions: actions,
              child: builder(sheetContext),
            ),
    );
  }

  /// Motion for the sheet route, collapsed to nothing under reduced motion.
  static AnimationStyle animationStyleFor(
    BuildContext context,
  ) => AnimationStyle(
    duration: HabotMotionPolicy.resolve(context, HabotMotion.sheetEnter),
    reverseDuration: HabotMotionPolicy.resolve(context, HabotMotion.sheetExit),
    curve: HabotMotionPolicy.resolveCurve(context, HabotEasing.sheet),
    reverseCurve: HabotMotionPolicy.resolveCurve(context, HabotEasing.sheet),
  );
}

class _DraggableSheet extends StatelessWidget {
  const _DraggableSheet({
    required this.title,
    required this.actions,
    required this.builder,
  });

  final String title;
  final List<Widget> actions;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      initialChildSize: HabotSheet.defaultSnapFraction,
      minChildSize: HabotSheet.minSnapFraction,
      maxChildSize: HabotSheet.maxSnapFraction,
      snapSizes: HabotSheetSnap.stops,
      snapAnimationDuration: HabotMotion.sheetSnap,
      builder: _buildSheet,
    );
  }

  Widget _buildSheet(BuildContext context, ScrollController controller) {
    return HabotSheetSurface(
      title: title,
      actions: actions,
      child: SingleChildScrollView(
        controller: controller,
        child: Padding(
          padding: const EdgeInsets.only(bottom: HabotSpacing.xs),
          child: builder(context),
        ),
      ),
    );
  }
}
