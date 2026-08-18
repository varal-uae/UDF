/// AISS: GEN-01441-A01 -- "Construct a slide-up filter sheet using the M3
/// Modal Bottom Sheet component with a drag handle."
/// Metric: Filter Application Latency -- Floor <1s, Optimal <300ms,
/// Ceiling <2s.
///
/// AISS: GEN-02984-A01 -- "Apply Secondary Container with trailing check icon
/// styling to selected notebook filter chips on mobile."
/// Metric: UI Design System Consistency Score (%) -- Floor 85.0, Optimal 95.0,
/// Ceiling 100.0.
///
/// Two steps, one file, for the reason Steps 21-23 and 39/45 shared one: a
/// chip that only ever appears inside this sheet, and a sheet whose entire
/// content is those chips, would otherwise be a spec in one file and its only
/// consumer in another with nothing to stop them drifting.
///
/// THIS IS NOT A NEW SHEET. `HabotBottomSheet` (Steps 21-23) already owns the
/// 32% scrim, the 30/60/95 snap ladder, the drag handle at 32x4dp and the
/// reduced-motion collapse -- four decisions that were separately gated. A
/// second modal sheet here would duplicate all four and fail the poka-yoke
/// guard on the first raw value it needed. So [HabotFilterSheet.show] is a
/// call into the existing one.
///
/// The chip styling is likewise the sheet's own words made literal: "Secondary
/// Container with trailing check icon". Secondary container is the M3 role for
/// a selected chip, and it is already in the audited scheme; the check icon is
/// the part that matters for WCAG 2.1 SC 1.4.1, because selection carried only
/// by a background colour is selection a colour-blind user cannot see.
library;

import 'package:flutter/material.dart';

import '../surfaces/bottom_sheet.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'filter_model.dart';

/// The filter sheet.
class HabotFilterSheet {
  const HabotFilterSheet._();

  static const String title = 'Filter';
  static const Key sheetKey = Key('habot.filter.sheet');
  static const Key applyKey = Key('habot.filter.apply');
  static const Key clearKey = Key('habot.filter.clear');

  /// Opens the sheet and resolves to the selection the user applied, or null
  /// if they dismissed it. Dismissal is not the same as clearing, and
  /// returning null rather than an empty selection is what keeps them apart.
  static Future<HabotFilterSelection?> show({
    required BuildContext context,
    required List<HabotFilterFacet> facets,
    required HabotFilterSelection selection,
  }) {
    return HabotBottomSheet.show<HabotFilterSelection>(
      context: context,
      title: title,
      builder: (BuildContext sheetContext) => _FilterSheetBody(
        facets: facets,
        initial: selection,
      ),
    );
  }
}

class _FilterSheetBody extends StatefulWidget {
  const _FilterSheetBody({required this.facets, required this.initial});

  final List<HabotFilterFacet> facets;
  final HabotFilterSelection initial;

  @override
  State<_FilterSheetBody> createState() => _FilterSheetBodyState();
}

class _FilterSheetBodyState extends State<_FilterSheetBody> {
  late HabotFilterSelection _selection = widget.initial;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      key: HabotFilterSheet.sheetKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final HabotFilterFacet facet in widget.facets) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: HabotSpacing.xxs),
            child: Text(facet.label, style: theme.textTheme.labelLarge),
          ),
          HabotFilterChipRow(
            facet: facet,
            selection: _selection,
            onToggled: (String value) => setState(
              () => _selection = _selection.toggle(facet.key, value),
            ),
          ),
          const SizedBox(height: HabotSpacing.sm),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                key: HabotFilterSheet.clearKey,
                onPressed: () =>
                    setState(() => _selection = _selection.clear()),
                child: const Text('Clear all'),
              ),
            ),
            const SizedBox(width: HabotSpacing.xs),
            Expanded(
              child: FilledButton(
                key: HabotFilterSheet.applyKey,
                onPressed: () => Navigator.of(context).pop(_selection),
                child: Text(
                  _selection.isEmpty
                      ? 'Show all'
                      : 'Apply ${_selection.activeCount}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A row of chips for one facet.
class HabotFilterChipRow extends StatelessWidget {
  const HabotFilterChipRow({
    required this.facet,
    required this.selection,
    required this.onToggled,
    super.key,
  });

  final HabotFilterFacet facet;
  final HabotFilterSelection selection;
  final void Function(String value) onToggled;

  static Key chipKeyFor(String facetKey, String value) =>
      Key('habot.filter.chip.$facetKey.$value');

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: HabotDashboardTokens.chipGap,
      runSpacing: HabotDashboardTokens.chipGap,
      children: <Widget>[
        for (final HabotFilterOption option in facet.options)
          HabotFilterChip(
            key: chipKeyFor(facet.key, option.value),
            option: option,
            selected: selection.isSelected(facet.key, option.value),
            onPressed: () => onToggled(option.value),
          ),
      ],
    );
  }
}

/// One chip.
///
/// GEN-02984 names the styling exactly: Secondary Container when selected,
/// with a trailing check icon. Both are here, and neither is optional -- there
/// is no `showCheck` parameter, because a chip whose selection is carried only
/// by its fill would fail SC 1.4.1 the moment someone turned it off.
class HabotFilterChip extends StatelessWidget {
  const HabotFilterChip({
    required this.option,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final HabotFilterOption option;
  final bool selected;
  final VoidCallback onPressed;

  /// The M3 role the sheet names for a selected chip.
  static Color selectedContainerColor(ColorScheme scheme) =>
      scheme.secondaryContainer;

  static Color selectedContentColor(ColorScheme scheme) =>
      scheme.onSecondaryContainer;

  static Color unselectedContentColor(ColorScheme scheme) =>
      scheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final Color content = selected
        ? selectedContentColor(scheme)
        : unselectedContentColor(scheme);
    final String countSuffix =
        option.matchCount == null ? '' : ' (${option.matchCount})';

    return Semantics(
      selected: selected,
      button: true,
      label: '${option.label}$countSuffix'
          '${option.yieldsNothing ? ', no matches' : ''}',
      child: Material(
        color: selected
            ? selectedContainerColor(scheme)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HabotShape.sm),
          side: selected
              ? BorderSide.none
              : BorderSide(
                  color: scheme.outline,
                  width: HabotShape.borderWidth,
                ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(HabotShape.sm),
          child: ConstrainedBox(
            // A chip is an interactive element, so TTMAC-011 applies to it
            // exactly as it applies to everything else.
            constraints: const BoxConstraints(
              minHeight: HabotDensity.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HabotSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${option.label}$countSuffix',
                    style: text.labelLarge?.copyWith(color: content),
                  ),
                  // The trailing check the step names. Leading space is
                  // reserved either way so selecting a chip does not resize
                  // it and reflow the row.
                  const SizedBox(width: HabotSpacing.xxs),
                  SizedBox(
                    width: HabotDashboardTokens.chipIconSize,
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: HabotDashboardTokens.chipIconSize,
                            color: content,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
