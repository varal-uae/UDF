/// AISS Step 104 -- GEN-02279
/// "Configure the mobile UI to use progressive disclosure."
/// Metric: UI Compliance Rate -- floor 0.95.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// WHY THIS SITS AFTER 99-101 rather than with the other layout work. A
/// disclosure control is exactly the kind of "complex interactive component"
/// Step 99 is about: it changes what is on the screen, and unless it says so,
/// a non-visual user is moved to content that was not there a moment ago with
/// no announcement. So:
///
///   * the trigger carries a Step 99 hint, not just a label;
///   * expansion state is exposed to the semantics tree (`toggled`), so a
///     reader says "expanded" / "collapsed" rather than nothing;
///   * revealed content is INSIDE the trigger's semantics container, so
///     swipe-next lands on it rather than skipping past.
///
/// THE POKA-YOKE. Progressive disclosure fails in one predictable way: the
/// "more" section quietly becomes where required information lives. A field a
/// user must fill, behind a control they need not open, is a form that cannot
/// be completed by anyone who does not think to expand it.
/// [HabotDisclosureGroup] refuses that at construction: content marked
/// [HabotDisclosureTier.essential] cannot be placed in the collapsed half.
library;

import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'semantic_hints.dart';

/// What a piece of content is worth to a first-time reader.
enum HabotDisclosureTier {
  /// Needed to understand or complete the screen. Never hidden.
  essential,

  /// Useful, not required. The thing progressive disclosure exists for.
  supporting,

  /// Diagnostic detail: ids, timestamps, provenance.
  forensic,
}

/// One disclosable section.
@immutable
class HabotDisclosureSection {
  const HabotDisclosureSection({
    required this.title,
    required this.tier,
    required this.builder,
  });

  final String title;
  final HabotDisclosureTier tier;
  final WidgetBuilder builder;

  bool get mayBeHidden => tier != HabotDisclosureTier.essential;
}

/// Thrown when essential content is put behind a disclosure control.
class HabotDisclosureViolation implements Exception {
  const HabotDisclosureViolation(this.sectionTitle);

  final String sectionTitle;

  @override
  String toString() =>
      'HabotDisclosureViolation: "$sectionTitle" is marked essential and '
      'cannot be placed behind a disclosure control. Content a user must read '
      'or fill has to be visible without an extra action -- otherwise the '
      'screen is only completable by someone who guesses to expand it.';
}

/// A primary block plus sections that reveal on request.
class HabotDisclosureGroup extends StatefulWidget {
  HabotDisclosureGroup({
    required this.primary,
    required this.sections,
    this.initiallyExpanded = const <String>{},
    super.key,
  }) {
    for (final HabotDisclosureSection s in sections) {
      if (!s.mayBeHidden) {
        throw HabotDisclosureViolation(s.title);
      }
    }
  }

  /// Always visible.
  final Widget primary;

  /// Revealed on request. None of these may be essential.
  final List<HabotDisclosureSection> sections;

  final Set<String> initiallyExpanded;

  static const Key groupKey = Key('habot.a11y.disclosure');
  static Key triggerKeyFor(String title) =>
      Key('habot.a11y.disclosure.trigger.$title');
  static Key panelKeyFor(String title) =>
      Key('habot.a11y.disclosure.panel.$title');

  /// The compliance figure the sheet's metric names, computed rather than
  /// asserted: the share of sections correctly tiered and reachable.
  static double complianceRate(List<HabotDisclosureSection> sections) {
    if (sections.isEmpty) {
      return 1;
    }
    final int ok = sections
        .where((HabotDisclosureSection s) => s.mayBeHidden)
        .length;
    return ok / sections.length;
  }

  @override
  State<HabotDisclosureGroup> createState() => _HabotDisclosureGroupState();
}

class _HabotDisclosureGroupState extends State<HabotDisclosureGroup> {
  late final Set<String> _expanded = <String>{...widget.initiallyExpanded};

  void _toggle(String title) {
    setState(() {
      if (!_expanded.remove(title)) {
        _expanded.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: HabotDisclosureGroup.groupKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        widget.primary,
        for (final HabotDisclosureSection s in widget.sections)
          _DisclosureRow(
            section: s,
            expanded: _expanded.contains(s.title),
            onToggle: () => _toggle(s.title),
          ),
      ],
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  const _DisclosureRow({
    required this.section,
    required this.expanded,
    required this.onToggle,
  });

  final HabotDisclosureSection section;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            container: true,
            button: true,
            // `toggled` is what makes a reader say "expanded"/"collapsed".
            // Without it the control announces as a plain button and the
            // state is invisible.
            toggled: expanded,
            label: section.title,
            hint: HabotHints.of(HabotActionKind.discloseMetadata).hint,
            onTap: onToggle,
            child: ExcludeSemantics(
              child: InkWell(
                key: HabotDisclosureGroup.triggerKeyFor(section.title),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: HabotSpacing.sm,
                    horizontal: HabotSpacing.md,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          section.title,
                          style: HabotTypography.titleSmall.toTextStyle(
                            HabotTypography.fontName,
                          ),
                        ),
                      ),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              key: HabotDisclosureGroup.panelKeyFor(section.title),
              padding: const EdgeInsets.only(
                left: HabotSpacing.md,
                right: HabotSpacing.md,
                bottom: HabotSpacing.md,
              ),
              child: Builder(builder: section.builder),
            ),
        ],
      ),
    );
  }
}
