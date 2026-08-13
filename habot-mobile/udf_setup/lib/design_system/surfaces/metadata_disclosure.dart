/// AISS: MUFCE-028-A01 -- "Mandatory removal of all mouse hover tooltips and
/// replacement with touch long-press modal sheets."
///
/// 4 Substeps:
///   1. "Strip all .onHover logic actions from mobile codebase templates."
///   2. "Bind formula lookup scripts to explicit touch-and-hold gestures."
///   3. "Route rich metadata descriptions to smooth bottom drawer overlays."
///   4. "Set up an alternative quick-tap option icon next to dynamic labels."
///
/// Substep 1 is the interesting one, because it is a requirement about code
/// that must NOT exist. Prose cannot enforce that, so it is enforced by two
/// rules in `test/guards/poka_yoke_no_hardcoded_values_test.dart`:
/// `HOVER_CALLBACK` (no hover callback anywhere under `lib/`) and
/// `HOVER_TOOLTIP` (no tooltip widget construction under `lib/`). A hover
/// tooltip cannot be reintroduced without the build failing.
///
/// Why this matters beyond tidiness: a hover tooltip is unreachable on a touch
/// device. Any information that only appears on hover is, on a phone,
/// information that does not exist.
library;

import 'package:flutter/material.dart';

import '../interaction/touch_target.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';
import 'bottom_sheet.dart';

/// Rich metadata attached to a label or a control.
class HabotMetadata {
  const HabotMetadata({
    required this.title,
    required this.description,
    this.formula,
    this.source,
  });

  final String title;

  /// Substep 3: "rich metadata descriptions" -- the long text that used to sit
  /// inside a tooltip and get truncated.
  final String description;

  /// Substep 2: "formula lookup scripts" -- the derivation behind a computed
  /// value, shown verbatim so a user can check the arithmetic.
  final String? formula;

  /// Where the value came from. Optional, but when present it is the thing
  /// users actually ask about.
  final String? source;

  bool get hasFormula => formula != null && formula!.isNotEmpty;
}

/// The single route by which metadata reaches the screen.
class HabotMetadataDisclosure {
  const HabotMetadataDisclosure._();

  /// Substep 3: routes the metadata to a bottom drawer overlay.
  ///
  /// Returns the future of the sheet, so a caller can await dismissal.
  static Future<void> show(BuildContext context, HabotMetadata metadata) {
    return HabotBottomSheet.show<void>(
      context: context,
      title: metadata.title,
      builder: (BuildContext context) => _MetadataBody(metadata: metadata),
    );
  }
}

class _MetadataBody extends StatelessWidget {
  const _MetadataBody({required this.metadata});

  final HabotMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(metadata.description, style: text.bodyMedium),
        if (metadata.hasFormula) const SizedBox(height: HabotSheet.contentGap),
        if (metadata.hasFormula) Text(metadata.formula!, style: text.bodySmall),
        if (metadata.source != null)
          const SizedBox(height: HabotSheet.contentGap),
        if (metadata.source != null)
          Text(metadata.source!, style: text.labelSmall),
      ],
    );
  }
}

/// Substep 4: "an alternative quick-tap option icon next to dynamic labels."
///
/// Long-press anywhere on the label opens the metadata; so does a single tap
/// on the trailing icon. Two routes to the same sheet, because long-press is
/// discoverable only by people who already know it is there.
class HabotMetadataLabel extends StatelessWidget {
  const HabotMetadataLabel({
    required this.label,
    required this.metadata,
    this.style,
    super.key,
  });

  final String label;
  final HabotMetadata metadata;
  final TextStyle? style;

  /// The trailing affordance icon. Public so the gate can find it by name
  /// rather than by position.
  static const IconData disclosureIcon = Icons.info_outline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: GestureDetector(
            onLongPress: () => HabotMetadataDisclosure.show(context, metadata),
            child: Text(label, style: style ?? _defaultStyle(context)),
          ),
        ),
        const SizedBox(width: HabotSpacing.xxs),
        HabotTouchTarget(
          semanticLabel: 'About ${metadata.title}',
          onPressed: () => HabotMetadataDisclosure.show(context, metadata),
          child: const Icon(disclosureIcon, size: HabotSpacing.lg),
        ),
      ],
    );
  }

  TextStyle? _defaultStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
}
