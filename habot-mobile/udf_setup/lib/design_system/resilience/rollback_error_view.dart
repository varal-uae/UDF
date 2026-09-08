/// AISS Step 106 -- ETMDI-020-05
/// Setup Step: "Design Triangular Check (TC) Rollback Error UI."
/// Description: "Map error view to high-contrast semantic error-container
///              theme."
/// Metric: Text/UI Contrast Ratio.
///
/// ROW QUALITY, RECORDED: this row populates 21 of 49 columns. There is no
/// Expected Output, no Completion Measures, no substeps and no estimate.
/// Nothing has been invented to fill them. The step is gated against the two
/// columns that ARE populated, and against REF-197 (Step 19), which already
/// owns what a rollback says to a user.
///
/// WHAT A TRIANGULAR CHECK IS, AND WHY THE ERROR VIEW IS DIFFERENT. A TC
/// compares three independently derived values that must agree. When they do
/// not, the safe action is to roll the write back -- and the user is then
/// looking at a screen whose contents have just been REVERTED underneath
/// them. That is not an ordinary failure message. Two things follow:
///
///   1. The message must say what was undone, not only that something failed.
///      "We could not save" leaves a user wondering which of their edits
///      survived. Step 19's templates carry the sentence; this adds the
///      reverted-to state.
///   2. It renders in the error-container role at the HIGH-CONTRAST end,
///      because it appears at the moment a user has lost work and is least
///      inclined to squint.
///
/// WHAT THIS REUSES rather than rebuilds: `HabotErrorTemplates` (Step 19) for
/// the words, `HabotFailureClassifier` (Step 20) for the category, and the
/// Step 105 high-contrast scheme for the colours. It adds no new palette and
/// no second error vocabulary.
library;

import 'package:flutter/material.dart';

import '../a11y/contrast.dart';
import '../tokens/color_tokens.dart';
import '../tokens/high_contrast_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'error_templates.dart';

/// Which of the three legs of the check disagreed.
enum HabotTriangularLeg { source, derived, control }

/// One triangular-check failure, with the write that was undone.
@immutable
class HabotRollbackEvent {
  const HabotRollbackEvent({
    required this.recordId,
    required this.disagreeingLegs,
    required this.revertedToLabel,
    required this.category,
  });

  final String recordId;

  /// The legs that did not agree. Two or three; one leg cannot disagree alone.
  final List<HabotTriangularLeg> disagreeingLegs;

  /// What the record now shows, in the user's terms -- "the values as of
  /// 09:14", not "baseline#3".
  final String revertedToLabel;

  final HabotErrorCategory category;

  HabotErrorTemplate get template => HabotErrorTemplates.of(category);

  /// The sentence Step 19 owns, plus the sentence this step adds.
  String get message =>
      '${template.body} This record has been put back to $revertedToLabel.';

  bool get isWellFormed => disagreeingLegs.length >= 2;

  Map<String, Object?> toJson() => <String, Object?>{
    'record_id': recordId,
    'disagreeing_legs':
        disagreeingLegs.map((HabotTriangularLeg l) => l.name).toList(),
    'reverted_to': revertedToLabel,
    'category': category.name,
    'title': template.title,
    'message': message,
    'retryable': template.retryable,
  };
}

/// The colour contract this view is held to, as numbers rather than intent.
class HabotRollbackErrorPalette {
  const HabotRollbackErrorPalette._();

  /// The role pair, named once. Everything below reads these two.
  static const String foregroundRole = 'onErrorContainer';
  static const String backgroundRole = 'errorContainer';

  /// The high-contrast scheme is the one this view uses in BOTH brightnesses,
  /// not only when the user has asked for high contrast. A rollback notice is
  /// read once, under stress, and often outdoors.
  static HabotColorScheme schemeFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? HabotHighContrast.dark
      : HabotHighContrast.light;

  static Color foreground(Brightness b) =>
      schemeFor(b).roles[foregroundRole]!;

  static Color background(Brightness b) =>
      schemeFor(b).roles[backgroundRole]!;

  /// The measured ratio for [brightness]. Computed, never stated.
  static double ratioFor(Brightness brightness) =>
      Contrast.ratio(foreground(brightness), background(brightness));

  /// This view's own floor: the AAA figure, matching Step 105's promise.
  static double get floor => HabotHighContrast.textFloor;

  static bool meetsFloor(Brightness b) => ratioFor(b) >= floor;
}

/// The rollback error surface.
class HabotRollbackErrorView extends StatelessWidget {
  const HabotRollbackErrorView({
    required this.event,
    this.onRetry,
    super.key,
  });

  final HabotRollbackEvent event;

  /// Offered only when the template says the failure is retryable. A retry
  /// button on a conflict is an invitation to lose the same work twice.
  final VoidCallback? onRetry;

  static const Key viewKey = Key('habot.rollback.error');
  static const Key retryKey = Key('habot.rollback.retry');

  bool get offersRetry => event.template.retryable && onRetry != null;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color fg = HabotRollbackErrorPalette.foreground(brightness);
    final Color bg = HabotRollbackErrorPalette.background(brightness);

    return Semantics(
      key: viewKey,
      container: true,
      liveRegion: true,
      label: event.template.title,
      value: event.message,
      child: Container(
        color: bg,
        padding: const EdgeInsets.all(HabotSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(
              child: Text(
                event.template.title,
                style: HabotTypography.titleMedium
                    .toTextStyle(HabotTypography.fontName)
                    .copyWith(color: fg),
              ),
            ),
            const SizedBox(height: HabotSpacing.xs),
            ExcludeSemantics(
              child: Text(
                event.message,
                style: HabotTypography.bodyMedium
                    .toTextStyle(HabotTypography.fontName)
                    .copyWith(color: fg),
              ),
            ),
            if (offersRetry) ...<Widget>[
              const SizedBox(height: HabotSpacing.sm),
              TextButton(
                key: retryKey,
                onPressed: onRetry,
                child: Text(
                  event.template.retryLabel,
                  style: HabotTypography.labelLarge
                      .toTextStyle(HabotTypography.fontName)
                      .copyWith(color: fg),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
