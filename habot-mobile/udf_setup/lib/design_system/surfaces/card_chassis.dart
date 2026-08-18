/// AISS: GEN-01452-A01 -- "Construct the card UI chassis using M3 Outlined or
/// Elevated Card specifications."
///
/// Every list row, empty state host and badge container in the app renders
/// inside one of these three variants. The chassis exists so that "which card
/// is this?" is a choice between three named intents rather than an open
/// invitation to invent a fourth with a slightly different radius.
///
/// The elevation-vs-border rule is deliberate: a variant may have a shadow or
/// a border, never both. Two boundary signals saying the same thing is noise,
/// and on a dense list it is the difference between scannable and busy.
library;

import 'package:flutter/material.dart';

import '../tokens/elevation_tokens.dart';
import '../tokens/surface_tokens.dart';

// `HabotCardVariant` is this component's own vocabulary -- a caller cannot use
// `HabotCard` without naming one -- so it travels with the component rather
// than forcing every call site to also import the token file it happens to be
// declared in. Caught by the strict-import check while building Step 58: two
// files were already relying on it reaching them transitively, which Dart does
// not do.
export '../tokens/surface_tokens.dart' show HabotCardVariant;

/// The card chassis.
class HabotCard extends StatelessWidget {
  const HabotCard({
    required this.child,
    this.variant = HabotCardVariant.filled,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final HabotCardVariant variant;

  /// When non-null the whole card is the target, which is why there is no
  /// nested button inside a card in this design system.
  final VoidCallback? onPressed;

  final String? semanticLabel;

  HabotElevationLevel get elevation =>
      HabotElevationLevel.values[HabotCardSpec.elevationLevel[variant]!];

  bool get hasBorder => HabotCardSpec.hasBorder[variant]!;

  static BorderRadius get shape =>
      BorderRadius.circular(HabotCardSpec.cornerRadius);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      button: onPressed != null,
      child: Material(
        color: _surfaceColor(scheme),
        elevation: HabotElevation.dp[elevation]!,
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: _side(scheme),
        ),
        clipBehavior: Clip.antiAlias,
        child: _CardBody(onPressed: onPressed, child: child),
      ),
    );
  }

  Color _surfaceColor(ColorScheme scheme) => variant == HabotCardVariant.filled
      ? scheme.surfaceContainerHighest
      : scheme.surfaceContainerLow;

  BorderSide _side(ColorScheme scheme) => hasBorder
      ? BorderSide(color: scheme.outlineVariant, width: HabotCardSpec.borderWidth)
      : BorderSide.none;
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget padded = Padding(
      padding: const EdgeInsets.all(HabotCardSpec.contentPadding),
      child: child,
    );
    if (onPressed == null) {
      return padded;
    }
    return InkWell(
      onTap: onPressed,
      borderRadius: HabotCard.shape,
      child: padded,
    );
  }
}
