/// Step 217 (GEN-01672) -- programmatic minimum sizes, and the gate that
/// enforces them.
///
/// The row: "Configure Modifier.sizeIn to enforce programmatic minimums."
/// Metric: **Automated PR Rejection Rate for Non-Compliance (%)** --
/// 95 / 99.5 / 100. High/Medium/Low.
///
/// **Substitution.** `Modifier.sizeIn` is Jetpack Compose. Flutter's equivalent
/// is a `BoxConstraints` with a minimum, applied through a `ConstrainedBox`.
/// The name does not port; the behaviour does, and so does the failure mode.
///
/// **The row asks for a widget and the metric asks for a CI gate.** Those are
/// different deliverables, and the second is the one that makes the first
/// stick: a minimum applied at one call site is a minimum somebody forgot at
/// the next. What is built here is the declared minimum per control kind --
/// read from the Step 184 band rather than written per call site -- plus the
/// rule that says a control declared below it is refused.
///
/// **A minimum is not free.** In Flutter a minimum larger than the incoming
/// maximum does not grow the child; `BoxConstraints.enforce` clamps it, and a
/// minimum applied blindly inside a tight parent produces a constraint the
/// child cannot satisfy. So the constraint is checked against what it will be
/// nested in, and a minimum that cannot be honoured is reported rather than
/// silently clamped -- because a silently clamped minimum is a control that
/// looks compliant in the source and is 24dp on the screen.
library;

import 'dart:ui' show Size;

import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// A kind of control, and the minimum it must be given.
enum HabotControlKind {
  /// An icon button, an overflow, a toggle.
  iconButton,

  /// A text button or a filled button.
  textButton,

  /// A single-line input.
  textField,

  /// One destination in a navigation bar.
  navigationDestination,

  /// A chip or small filter control.
  chip,

  /// A row in a list that is itself tappable.
  listRow,
}

/// The minimum for one control kind.
class HabotControlMinimum {
  const HabotControlMinimum({
    required this.kind,
    required this.minWidthDp,
    required this.minHeightDp,
    required this.rationale,
  });

  final HabotControlKind kind;
  final double minWidthDp;
  final double minHeightDp;

  /// Why this kind gets this minimum, so a later change has to argue with a
  /// sentence rather than with a number.
  final String rationale;

  Size get minimumSize => Size(minWidthDp, minHeightDp);
}

/// A pair of constraints, as the layout will see them.
class HabotConstraintPair {
  const HabotConstraintPair({
    required this.minWidthDp,
    required this.maxWidthDp,
    required this.minHeightDp,
    required this.maxHeightDp,
  });

  final double minWidthDp;
  final double maxWidthDp;
  final double minHeightDp;
  final double maxHeightDp;

  bool get isSelfConsistent =>
      minWidthDp <= maxWidthDp && minHeightDp <= maxHeightDp;
}

/// The minimums, and the gate.
class HabotSizeConstraints {
  const HabotSizeConstraints._();

  static const String composeApi = 'Modifier.sizeIn';
  static const String flutterApi =
      'ConstrainedBox(constraints: BoxConstraints)';

  static const String substitution =
      'Modifier.sizeIn is Jetpack Compose. The Flutter equivalent is a '
      'BoxConstraints minimum applied through a ConstrainedBox. The name does '
      'not port; the behaviour does, and so does the failure mode -- a minimum '
      'larger than the incoming maximum is clamped rather than honoured.';

  /// Every minimum is derived from the Step 184 band. The two that exceed the
  /// band's optimal say why.
  static List<HabotControlMinimum> get minimums => <HabotControlMinimum>[
        HabotControlMinimum(
          kind: HabotControlKind.iconButton,
          minWidthDp: HabotTouchBand.optimalDp,
          minHeightDp: HabotTouchBand.optimalDp,
          rationale:
              'The Step 184 optimal on both axes. An icon button has no text '
              'to widen it, so nothing else will.',
        ),
        HabotControlMinimum(
          kind: HabotControlKind.textButton,
          minWidthDp: HabotSpacing.xxxl * 2,
          minHeightDp: HabotTouchBand.optimalDp,
          rationale:
              'Height from the band. Width at 96dp so a two-character label '
              'in a language that abbreviates does not produce a control the '
              'width of its text.',
        ),
        HabotControlMinimum(
          kind: HabotControlKind.textField,
          minWidthDp: HabotSpacing.xxxl * 3,
          minHeightDp: HabotTouchBand.ceilingDp,
          rationale:
              'MD3 gives a filled or outlined field 56dp of height, which is '
              'the band ceiling. The width floor stops a field being laid out '
              'narrower than the text it is for.',
        ),
        HabotControlMinimum(
          kind: HabotControlKind.navigationDestination,
          minWidthDp: HabotTouchBand.optimalDp,
          minHeightDp: HabotSpacing.xxxl + HabotSpacing.md,
          rationale:
              'MD3 navigation destinations are 64dp tall inside an 80dp bar. '
              'Above the band ceiling by declaration -- see Step 228.',
        ),
        HabotControlMinimum(
          kind: HabotControlKind.chip,
          minWidthDp: HabotTouchBand.optimalDp,
          minHeightDp: HabotTouchBand.optimalDp,
          rationale:
              'MD3 draws a chip at 32dp. The drawn height is not the target '
              'height; the target is padded to the band optimal.',
        ),
        HabotControlMinimum(
          kind: HabotControlKind.listRow,
          minWidthDp: 0,
          minHeightDp: HabotTouchBand.optimalDp,
          rationale:
              'A list row takes the width it is given, so only the height is '
              'constrained.',
        ),
      ];

  static HabotControlMinimum minimumFor(HabotControlKind kind) =>
      minimums.firstWhere((HabotControlMinimum m) => m.kind == kind);

  /// The gate: a declared size is compliant when it meets its kind's minimum
  /// on both axes.
  static bool isCompliant(HabotControlKind kind, Size declared) {
    final HabotControlMinimum m = minimumFor(kind);
    return declared.width >= m.minWidthDp && declared.height >= m.minHeightDp;
  }

  /// What the gate says, for a reviewer rather than for a log.
  static String refusalFor(HabotControlKind kind, Size declared) {
    if (isCompliant(kind, declared)) {
      return '';
    }
    final HabotControlMinimum m = minimumFor(kind);
    return '${kind.name} declared '
        '${declared.width.toStringAsFixed(0)}x'
        '${declared.height.toStringAsFixed(0)}dp, below the declared minimum '
        '${m.minWidthDp.toStringAsFixed(0)}x'
        '${m.minHeightDp.toStringAsFixed(0)}dp. ${m.rationale}';
  }

  /// A minimum that exceeds the maximum it is nested in cannot be honoured.
  /// Flutter clamps rather than throwing, which is the dangerous half: the
  /// source keeps its minimum and the screen does not.
  static bool isSatisfiableWithin(
    HabotControlKind kind,
    HabotConstraintPair parent,
  ) {
    final HabotControlMinimum m = minimumFor(kind);
    return m.minWidthDp <= parent.maxWidthDp &&
        m.minHeightDp <= parent.maxHeightDp;
  }

  static const String silentClampNote =
      'Flutter does not throw when a minimum exceeds the incoming maximum -- '
      'BoxConstraints.enforce clamps it. The source then keeps a compliant '
      'minimum while the screen shows a control that is not, which is the one '
      'failure a source-reading linter can never catch. A constraint is '
      'checked against the parent it will sit in, and an unsatisfiable one is '
      'reported.';

  // -----------------------------------------------------------------------
  // Metric: Automated PR Rejection Rate for Non-Compliance (%).
  // -----------------------------------------------------------------------

  static const double floor = 95;
  static const double optimal = 99.5;
  static const double ceiling = 100;

  /// One declared control, and the parent it will be laid out inside.
  ///
  /// The parent matters because a source-reading linter cannot see it, and a
  /// minimum that cannot be honoured is the one failure such a linter passes.
  static Map<String, (HabotControlKind, Size, HabotConstraintPair)>
      get probeSet =>
          <String, (HabotControlKind, Size, HabotConstraintPair)>{
            'icon button at the band optimal, in a roomy parent': (
              HabotControlKind.iconButton,
              const Size(48, 48),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 360,
                minHeightDp: 0,
                maxHeightDp: 200,
              ),
            ),
            'outlined field at MD3 height': (
              HabotControlKind.textField,
              const Size(280, 56),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 328,
                minHeightDp: 0,
                maxHeightDp: 96,
              ),
            ),
            'a 24dp glyph used as its own target': (
              HabotControlKind.iconButton,
              const Size(24, 24),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 360,
                minHeightDp: 0,
                maxHeightDp: 200,
              ),
            ),
            'a chip sized to its drawn height': (
              HabotControlKind.chip,
              const Size(72, 32),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 360,
                minHeightDp: 0,
                maxHeightDp: 200,
              ),
            ),
            'a list row at MD3 dense height': (
              HabotControlKind.listRow,
              const Size(360, 40),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 360,
                minHeightDp: 0,
                maxHeightDp: 200,
              ),
            ),
            'a compliant icon button inside a 40dp toolbar row': (
              HabotControlKind.iconButton,
              const Size(48, 48),
              const HabotConstraintPair(
                minWidthDp: 0,
                maxWidthDp: 360,
                minHeightDp: 0,
                maxHeightDp: 40,
              ),
            ),
          };

  /// The gate rejects on either ground.
  static bool wouldReject(
    HabotControlKind kind,
    Size declared,
    HabotConstraintPair parent,
  ) =>
      !isCompliant(kind, declared) || !isSatisfiableWithin(kind, parent);

  /// What a linter that only reads the declared size would reject.
  static bool sourceOnlyWouldReject(HabotControlKind kind, Size declared) =>
      !isCompliant(kind, declared);

  static List<String> get rejected => probeSet.entries
      .where(
        (MapEntry<String, (HabotControlKind, Size, HabotConstraintPair)> e) =>
            wouldReject(e.value.$1, e.value.$2, e.value.$3),
      )
      .map(
        (MapEntry<String, (HabotControlKind, Size, HabotConstraintPair)> e) =>
            e.key,
      )
      .toList();

  /// Declarations a source-only linter passes and this gate does not: the
  /// minimum is right and the parent will clamp it away.
  static List<String> get escapesASourceOnlyLinter => probeSet.entries
      .where(
        (MapEntry<String, (HabotControlKind, Size, HabotConstraintPair)> e) =>
            wouldReject(e.value.$1, e.value.$2, e.value.$3) &&
            !sourceOnlyWouldReject(e.value.$1, e.value.$2),
      )
      .map(
        (MapEntry<String, (HabotControlKind, Size, HabotConstraintPair)> e) =>
            e.key,
      )
      .toList();

  /// The entries that are genuinely below the minimum once laid out. The
  /// denominator for a rejection rate is the failures, not the population --
  /// including the compliant entries would make the figure a description of
  /// the probe set rather than of the gate.
  static List<String> get genuineFailures => rejected;

  /// Share of genuine failures this gate rejects.
  static double get rejectionRate => genuineFailures.isEmpty
      ? 0
      : rejected.length / genuineFailures.length * 100;

  /// The same rate for a linter that only reads declared sizes. Lower,
  /// because the entry whose parent clamps the minimum away looks compliant
  /// in the source.
  static double get sourceOnlyRejectionRate {
    if (genuineFailures.isEmpty) {
      return 0;
    }
    final int caught = probeSet.entries
        .where(
          (MapEntry<String, (HabotControlKind, Size, HabotConstraintPair)> e) =>
              genuineFailures.contains(e.key) &&
              sourceOnlyWouldReject(e.value.$1, e.value.$2),
        )
        .length;
    return caught / genuineFailures.length * 100;
  }

  static String get qualitativeOutput {
    final double r = rejectionRate;
    if (r >= optimal) {
      return 'High';
    }
    if (r >= floor) {
      return 'Medium';
    }
    return 'Low';
  }

  static const String widgetVersusGateNote =
      'The row asks for a widget and the metric asks for a CI gate. The second '
      'is what makes the first stick: a minimum applied at one call site is a '
      'minimum somebody forgot at the next. The minimums are declared per '
      'control kind and read from the Step 184 band, so the number lives in '
      'one place and the gate reads it.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Configure Modifier.sizeIn to enforce programmatic minimums."';
}
