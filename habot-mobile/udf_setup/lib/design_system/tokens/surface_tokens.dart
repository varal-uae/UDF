/// AISS: GEN-00055-A01 (BottomSheet atomic component), GEN-00954-A01 (MD3
/// bottom-sheet standardisation), GEN-00235-A01 (default snapping point),
/// GEN-01452-A01 (card chassis), GEN-01275-A01 (status badges),
/// GEN-01848-A01 (progress indicators), GEN-01297-A01 (empty state).
///
/// Every dimension the surface and feedback layers use. Nothing in
/// `lib/design_system/surfaces/` or `lib/design_system/feedback/` may declare
/// a number of its own -- it reads one from here, and here reads
/// `tokens.json`.
///
/// Source of truth: `lib/design_system/tokens/tokens.json` -> "surfaces" and
/// "feedback". Drift between the two fails `RCGLA-001-G6`.
library;

import 'shape_tokens.dart';
import 'spacing_tokens.dart';

/// Bottom-sheet geometry and behaviour.
class HabotSheet {
  const HabotSheet._();

  /// GEN-00055: MD3 gives a modal sheet an extra-large radius on its leading
  /// corners only -- the trailing edge is flush with the screen.
  static const double topCornerRadius = HabotShape.xl;

  /// The drag handle MD3 draws at the top of a draggable sheet.
  static const double dragHandleWidth = HabotSpacing.xl;
  static const double dragHandleHeight = HabotSpacing.xxs;
  static const double dragHandleTopMargin = HabotSpacing.sm;

  /// Internal padding. There is no padding parameter on the sheet widget --
  /// the same rule the master scaffold follows.
  static const double contentPadding = HabotSpacing.md;
  static const double contentGap = HabotSpacing.sm;

  /// GEN-00235: "Set the default snapping point to 60% viewport height for
  /// optimal thumb interaction." One value for every device -- a per-device
  /// override is what the Cross-Viewport Rendering Consistency metric exists
  /// to catch.
  static const double defaultSnapFraction = 0.60;

  /// The sheet may be dragged down to this before it dismisses, and up to this
  /// before it stops. Both are snap stops as well as bounds.
  static const double minSnapFraction = 0.30;
  static const double maxSnapFraction = 0.95;

  /// Every stop the sheet settles on, ascending.
  static const List<double> snapFractions = <double>[
    minSnapFraction,
    defaultSnapFraction,
    maxSnapFraction,
  ];

  /// GEN-00954: "Configure backdrop scrim color to 32% opacity black."
  static const double scrimOpacity = 0.32;

  /// A sheet is a level-1 surface: lifted off the page, not floating above it.
  static const int elevationLevel = 1;

  /// Below this height the 60% stop cannot hold a title, one row and one
  /// action at the minimum touch size, so the gate checks every device against
  /// it rather than trusting the fraction alone.
  static const double minUsableSheetHeight = 240;
}

/// Card chassis (GEN-01452).
enum HabotCardVariant {
  /// A tinted, borderless surface. The default for content that is part of the
  /// page rather than lifted off it.
  filled,

  /// A bordered surface with no shadow. Preferred on dense lists, where a
  /// shadow per row turns into visual noise.
  outlined,

  /// A lifted surface. Reserved for content that genuinely floats.
  elevated,
}

class HabotCardSpec {
  const HabotCardSpec._();

  static const double cornerRadius = HabotShape.md;
  static const double contentPadding = HabotSpacing.md;
  static const double borderWidth = HabotShape.borderWidth;

  /// Elevation level per variant. Outlined and filled are deliberately flat --
  /// a border and a shadow saying the same thing is redundancy, not emphasis.
  static const Map<HabotCardVariant, int> elevationLevel =
      <HabotCardVariant, int>{
        HabotCardVariant.filled: 0,
        HabotCardVariant.outlined: 0,
        HabotCardVariant.elevated: 1,
      };

  static const Map<HabotCardVariant, bool> hasBorder = <HabotCardVariant, bool>{
    HabotCardVariant.filled: false,
    HabotCardVariant.outlined: true,
    HabotCardVariant.elevated: false,
  };
}

/// Feedback surfaces: snackbars, progress, empty states, badges.
class HabotFeedback {
  const HabotFeedback._();

  // --- GEN-01363 snackbar -------------------------------------------------

  static const double snackbarCornerRadius = HabotShape.xs;
  static const double snackbarHorizontalMargin = HabotSpacing.md;
  static const double snackbarVerticalMargin = HabotSpacing.xs;

  /// MD3 caps a snackbar at two lines; past that it is a panel, not a
  /// snackbar, and belongs in [ErrorPanel].
  static const int snackbarMaxLines = 2;

  // --- GEN-01848 progress -------------------------------------------------

  static const double progressTrackHeight = HabotSpacing.xxs;
  static const double progressCornerRadius = HabotShape.xs;
  static const double progressSpinnerSize = HabotSpacing.xl;
  static const double progressSpinnerStroke = HabotSpacing.xxs;

  // --- GEN-01297 empty state ---------------------------------------------

  static const double emptyStateIconSize = 64;
  static const double emptyStateMaxContentWidth = 320;
  static const double emptyStateGap = HabotSpacing.sm;

  // --- GEN-01275 badge ----------------------------------------------------

  /// MD3 small (dot) and large (labelled) badge diameters.
  static const double badgeDotSize = HabotSpacing.xs;
  static const double badgeLabelledHeight = HabotSpacing.md;
  static const double badgeHorizontalPadding = HabotSpacing.xxs;
  static const double badgeIconSize = HabotSpacing.sm;
}

/// ANSA-006 header search and CPNCA-006 list virtualisation.
class HabotDiscovery {
  const HabotDiscovery._();

  /// CPNCA-006 substep 2: "fetch record batches (e.g., 20 items per request)
  /// rather than loading entire datasets at once."
  static const int chunkSize = 20;

  /// How close to the end of the loaded window a scroll gets before the next
  /// chunk is requested, in items. Small enough that the fetch is not
  /// speculative, large enough that the user does not see the seam.
  static const int prefetchThreshold = 5;

  /// CPNCA-006 Completion Measure: "Loading a test collection of 10,000 items
  /// preserves a consistent, low DOM element count during continuous
  /// scrolling." The Flutter equivalent of DOM element count is the number of
  /// materialised child elements; this is the ceiling the gate asserts.
  static const int maxMaterialisedItems = 60;

  /// ANSA-006 substep 4: "Save successful lookup keyword values locally."
  static const int recentSearchLimit = 8;

  /// ANSA-006 Poka-Yoke: "Filter out invalid code punctuation marks from
  /// search inputs automatically to prevent database query errors."
  ///
  /// Quotes, escapes, statement separators, wildcards and bracket forms. The
  /// underscore is deliberately NOT here even though it is a SQL LIKE
  /// wildcard: asset references in this domain contain underscores, and a
  /// filter that mangles a legitimate identifier costs more than it saves.
  /// Parameterised queries are the actual defence; this is input hygiene.
  static const String forbiddenSearchPunctuation = r'''`"'\;%(){}[]<>|&$*''';

  /// A query shorter than this does not run -- one character matches
  /// everything, which is a slow way to return nothing useful.
  static const int minQueryLength = 2;

  static const double searchResultRowHeight = HabotSpacing.xxxl;
  static const int maxVisibleResults = 6;
}
