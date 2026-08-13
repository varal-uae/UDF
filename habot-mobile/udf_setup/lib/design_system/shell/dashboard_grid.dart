/// AISS: SSTLA-018-A01 -- "Formulating the responsive layout rules to organize
/// parent command sections on 5.5-inch mobile viewports."
/// AISS: GEN-00022-A01 -- "Configure dashboard widgets and audit forms to
///   stack vertically in a single-column or 2x2 grid on mobile."
///
/// SSTLA-018 Setup Step Description: "Identify target 5.5-inch mobile viewport
/// dimensions and resolution constraints (e.g., 1080x1920 pixels at 16:9)."
/// Mobile App First Implication: "Screen elements must collapse into vertical
/// layout stacks to eliminate horizontal scroll glitches."
/// Flow Impact: "Navigation bars sit comfortably within standard thumb
/// interaction spaces."
/// Poka-Yoke: "Selection items lock automatically if required preceding
/// details stay empty."
///
/// Two steps, one file, for the same reason Steps 21-23 shared one: SSTLA-018
/// writes the rules and GEN-00022 is the stacking those rules produce.
/// Splitting them would mean a spec in one file and its only consumer in
/// another, with nothing to stop them drifting.
///
/// The 5.5-inch reference device: 1080x1920 physical pixels at 16:9 is
/// 360x640dp at a device pixel ratio of 3. That is what HabotReferenceViewport
/// pins, in the units a layout actually sees.
library;

import 'package:flutter/material.dart';

import '../interaction/interaction_states.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// The reference viewport the step names, in the units layout actually uses.
class HabotReferenceViewport {
  const HabotReferenceViewport._();

  /// "1080x1920 pixels at 16:9" -- physical.
  static const double physicalWidthPx = 1080;
  static const double physicalHeightPx = 1920;
  static const double devicePixelRatio = 3;

  /// The same device in logical pixels, which is what a layout sees.
  static const double widthDp = physicalWidthPx / devicePixelRatio;
  static const double heightDp = physicalHeightPx / devicePixelRatio;

  /// 16:9, stated so a change to either dimension has to justify itself.
  static const double aspectRatio = physicalHeightPx / physicalWidthPx;

  static bool matchesAspect(double width, double height) =>
      ((height / width) - aspectRatio).abs() < 0.01;
}

/// How many columns a dashboard uses at a given width.
///
/// GEN-00022 names the two shapes: "a single-column or 2x2 grid on mobile".
/// The rule is one column while the screen is compact, two once it is not --
/// there is no three-column dashboard on a phone, because the third column is
/// where horizontal scrolling comes from.
class HabotDashboardGrid {
  const HabotDashboardGrid._();

  static const int singleColumn = 1;
  static const int quadColumns = 2;

  /// The thumb band: the bottom third of the viewport, where a navigation bar
  /// has to sit to be reachable one-handed. Flow Impact row, as a number.
  static const double thumbZoneFraction = 0.33;

  static int columnsFor(double width) =>
      width < HabotGrid.breakpointMedium ? singleColumn : quadColumns;

  /// True when a control at [topDp] on a viewport [heightDp] tall is inside
  /// the thumb band.
  static bool isWithinThumbZone(double topDp, double heightDp) =>
      topDp >= heightDp * (1 - thumbZoneFraction);

  /// The widest a dashboard tile may be before it must wrap. Equal to the
  /// content width, so a tile can never be the thing that introduces a
  /// horizontal scroll.
  static double maxTileWidth(double viewportWidth) =>
      HabotGrid.contentWidth(viewportWidth);
}

/// One command section on the dashboard.
///
/// Poka-Yoke: "Selection items lock automatically if required preceding
/// details stay empty." A section declares what it depends on; the grid works
/// out whether it may be touched. A caller cannot enable a section by passing
/// a flag, because there is no flag to pass.
class HabotCommandSection {
  const HabotCommandSection({
    required this.id,
    required this.title,
    required this.child,
    this.requires = const <String>{},
  });

  final String id;
  final String title;
  final Widget child;

  /// Ids of sections that must be complete before this one unlocks.
  final Set<String> requires;
}

/// The dashboard.
class HabotCommandGrid extends StatelessWidget {
  const HabotCommandGrid({
    required this.sections,
    this.completed = const <String>{},
    this.onSectionTapped,
    super.key,
  });

  final List<HabotCommandSection> sections;

  /// Ids the caller reports as complete. Everything else is derived.
  final Set<String> completed;

  final void Function(HabotCommandSection section)? onSectionTapped;

  /// The poka-yoke, as a pure function: a section is locked while any of its
  /// prerequisites is outstanding.
  static bool isLocked(HabotCommandSection section, Set<String> completed) =>
      !section.requires.every(completed.contains);

  /// The sections a user may currently act on.
  List<HabotCommandSection> get unlocked => sections
      .where((HabotCommandSection s) => !isLocked(s, completed))
      .toList();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = HabotDashboardGrid.columnsFor(width);
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: HabotGrid.verticalRhythm,
      crossAxisSpacing: HabotGrid.gutter,
      childAspectRatio: columns == HabotDashboardGrid.singleColumn ? 2.6 : 1.1,
      shrinkWrap: true,
      children: <Widget>[
        for (final HabotCommandSection section in sections)
          _SectionTile(
            section: section,
            locked: isLocked(section, completed),
            onTap: onSectionTapped,
          ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.locked,
    required this.onTap,
  });

  final HabotCommandSection section;
  final bool locked;
  final void Function(HabotCommandSection section)? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: locked
          ? '${section.title}, locked until earlier steps are complete'
          : section.title,
      button: !locked,
      enabled: !locked,
      // The tile is one semantic element: its label above is authoritative, so
      // the inner title/count text must not merge in and duplicate it. Without
      // this the locked node reads "Release, locked...\nRelease", which is not
      // the label a screen reader (or the gate) expects.
      excludeSemantics: true,
      child: Opacity(
        opacity: locked ? HabotStateLayer.disabledContentOpacity : 1,
        child: IgnorePointer(
          ignoring: locked,
          child: _SectionBody(
            section: section,
            theme: theme,
            onTap: onTap == null ? null : () => onTap!(section),
          ),
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.theme,
    required this.onTap,
  });

  final HabotCommandSection section;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(section.title, style: theme.textTheme.titleSmall, maxLines: 2),
          const SizedBox(height: HabotSpacing.xxs),
          Flexible(child: section.child),
        ],
      ),
    );
  }
}
