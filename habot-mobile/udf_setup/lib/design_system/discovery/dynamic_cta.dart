/// Step 200 (GEN-01165) -- the vendor-profile-dependent call to action.
///
/// The row: "Implement dynamic CTA text logic that replaces the booking action
/// with 'Contact for Details' if the vendor profile is incomplete."
///
/// Three things the row leaves open, each of which is the part that breaks.
///
/// **"Incomplete" is not defined.** Left to the call site, every screen invents
/// its own notion and they disagree -- the list says bookable, the detail page
/// says contact. Completeness is defined once here, as a named required field
/// set, and what is missing is reportable rather than a boolean.
///
/// **Only the text is said to change.** A button labelled "Contact for Details"
/// that opens the booking flow is worse than one labelled "Book", because the
/// second at least tells the truth. Label and action change together, as one
/// value.
///
/// **"Contact for Details" is nineteen characters.** Step 144's button label
/// budget is twelve, set because translated labels wrap and a wrapped button is
/// a button whose height nobody designed. This label breaks that budget in
/// English before translation. It is not silently truncated -- it is placed on
/// a full-width action where the budget does not apply, and the budget is
/// declared per placement rather than globally, because a twelve-character
/// limit on a full-width button is a rule with no reason behind it.
library;

import '../i18n/language_toggle.dart';

/// Fields a vendor profile must carry before it can be booked directly.
enum HabotVendorField {
  /// Legal or trading name.
  displayName,

  /// At least one service with a price.
  pricedService,

  /// Where the service happens.
  location,

  /// The hours the vendor accepts bookings for.
  availability,

  /// A route the parent can use if something goes wrong on the day.
  contactChannel,

  /// Required by the operator before money can be taken.
  verifiedStatus,
}

/// Where a call to action is being rendered.
enum HabotCtaPlacement {
  /// A constrained row of actions -- two or three buttons side by side.
  actionRow,

  /// One button across the width of the surface.
  fullWidth,

  /// Inside a list item, beside content.
  listItemTrailing,
}

/// What the user should be offered.
enum HabotCtaIntent {
  /// Start the booking flow.
  book,

  /// Open the vendor's contact route.
  contact,

  /// Neither is available -- the vendor cannot be transacted with at all.
  unavailable,
}

/// A resolved call to action: label and behaviour as one value.
class HabotCta {
  const HabotCta({
    required this.intent,
    required this.label,
    required this.placement,
  });

  final HabotCtaIntent intent;
  final String label;
  final HabotCtaPlacement placement;

  int get labelLength => label.length;

  /// Whether this label fits the budget for where it is being drawn.
  bool get fitsPlacement =>
      labelLength <= HabotDynamicCta.budgetFor(placement);
}

/// The rule.
class HabotDynamicCta {
  const HabotDynamicCta._();

  /// Fields without which direct booking is not offered.
  ///
  /// `contactChannel` is deliberately NOT here: a vendor with no contact route
  /// and an incomplete profile cannot be contacted either, and that case gets
  /// its own intent rather than a button that goes nowhere.
  static const Set<HabotVendorField> requiredForBooking = <HabotVendorField>{
    HabotVendorField.displayName,
    HabotVendorField.pricedService,
    HabotVendorField.location,
    HabotVendorField.availability,
    HabotVendorField.verifiedStatus,
  };

  /// What is missing, in declaration order, so two screens report the same
  /// thing in the same order.
  static List<HabotVendorField> missingFrom(Set<HabotVendorField> present) =>
      HabotVendorField.values
          .where(
            (HabotVendorField f) =>
                requiredForBooking.contains(f) && !present.contains(f),
          )
          .toList();

  static bool isBookable(Set<HabotVendorField> present) =>
      missingFrom(present).isEmpty;

  /// Label and behaviour together.
  static HabotCta resolve({
    required Set<HabotVendorField> present,
    required HabotCtaPlacement placement,
  }) {
    if (isBookable(present)) {
      return HabotCta(
        intent: HabotCtaIntent.book,
        label: bookLabel,
        placement: placement,
      );
    }
    if (present.contains(HabotVendorField.contactChannel)) {
      return HabotCta(
        intent: HabotCtaIntent.contact,
        label: contactLabel,
        placement: placement,
      );
    }
    return HabotCta(
      intent: HabotCtaIntent.unavailable,
      label: unavailableLabel,
      placement: placement,
    );
  }

  /// Labels, declared here rather than typed at the call site. A string written
  /// where it is drawn is a string nobody translated.
  static const String bookLabel = 'Book';
  static const String contactLabel = 'Contact for Details';
  static const String unavailableLabel = 'Unavailable';

  /// The Step 144 budget, which applies to a constrained action row.
  static int get actionRowBudget => HabotLanguageToggle.buttonLabelBudget;

  /// A full-width button has the width of the surface, so the budget that
  /// exists to stop side-by-side buttons wrapping does not apply. A generous
  /// but real limit is kept, because a label long enough to wrap a full-width
  /// button on a 320dp screen is still a label nobody designed.
  static const int fullWidthBudget = 24;

  /// A trailing action in a list item is the tightest placement of all.
  static const int listItemTrailingBudget = 8;

  static int budgetFor(HabotCtaPlacement placement) => switch (placement) {
        HabotCtaPlacement.actionRow => HabotLanguageToggle.buttonLabelBudget,
        HabotCtaPlacement.fullWidth => fullWidthBudget,
        HabotCtaPlacement.listItemTrailing => listItemTrailingBudget,
      };

  /// The placements each declared label may be used in.
  static List<HabotCtaPlacement> placementsFor(String label) =>
      HabotCtaPlacement.values
          .where((HabotCtaPlacement p) => label.length <= budgetFor(p))
          .toList();

  /// The row's own label, measured against the row's own design system.
  static int get contactLabelLength => contactLabel.length;

  static bool get contactLabelBreaksActionRowBudget =>
      contactLabelLength > actionRowBudget;

  static bool get contactLabelFitsFullWidth =>
      contactLabelLength <= fullWidthBudget;

  // -----------------------------------------------------------------------
  // Metric: Information Architecture Task Success Rate. 0.8 / 0.95 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.8;
  static const double optimal = 0.95;
  static const double ceiling = 1;

  /// The success condition this step can be graded on: for every profile
  /// state, does the offered action do what its label says?
  static List<Set<HabotVendorField>> get profileStates =>
      <Set<HabotVendorField>>[
        HabotVendorField.values.toSet(),
        requiredForBooking,
        <HabotVendorField>{HabotVendorField.contactChannel},
        <HabotVendorField>{},
        HabotVendorField.values.toSet()
          ..remove(HabotVendorField.verifiedStatus),
        <HabotVendorField>{
          HabotVendorField.displayName,
          HabotVendorField.pricedService,
        },
      ];

  /// True when the label and the intent agree for every profile state.
  static bool labelMatchesIntent(HabotCta cta) => switch (cta.intent) {
        HabotCtaIntent.book => cta.label == bookLabel,
        HabotCtaIntent.contact => cta.label == contactLabel,
        HabotCtaIntent.unavailable => cta.label == unavailableLabel,
      };

  static double taskSuccessRateAt(HabotCtaPlacement placement) {
    final List<Set<HabotVendorField>> states = profileStates;
    int agreed = 0;
    for (final Set<HabotVendorField> s in states) {
      final HabotCta cta = resolve(present: s, placement: placement);
      if (labelMatchesIntent(cta) && cta.fitsPlacement) {
        agreed++;
      }
    }
    return agreed / states.length;
  }

  /// The rate at the placement this CTA is actually drawn in.
  static double get taskSuccessRate =>
      taskSuccessRateAt(HabotCtaPlacement.fullWidth);

  /// The same rate if the row's label were put in a constrained action row.
  ///
  /// Lower, because the states that resolve to "Contact for Details" fail the
  /// twelve-character budget. This is the number that says the placement
  /// decision is load-bearing rather than cosmetic.
  static double get taskSuccessRateInActionRow =>
      taskSuccessRateAt(HabotCtaPlacement.actionRow);

  static String get qualitativeOutput {
    final double r = taskSuccessRate;
    if (r >= optimal) {
      return 'Good';
    }
    if (r >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  static const String labelAndActionMoveTogetherNote =
      'The row changes the text. A button reading "Contact for Details" that '
      'opens the booking flow is worse than one reading "Book", because the '
      'second at least tells the truth about what happens next. Label and '
      'intent are one value here, so the two cannot be changed separately.';

  static const String budgetCollisionNote =
      '"Contact for Details" is nineteen characters against Step 144\'s '
      'twelve-character button budget, in English, before translation. The '
      'budget exists because translated labels wrap and a wrapped button has a '
      'height nobody designed. Rather than truncating the row\'s own words, '
      'the budget is declared per placement: twelve in a constrained action '
      'row, twenty-four full-width, eight in a list item. A twelve-character '
      'limit on a full-width button is a rule with no reason behind it.';

  static const String thirdIntentNote =
      'A vendor with an incomplete profile AND no contact route cannot be '
      'contacted either. The row\'s binary would put "Contact for Details" on '
      'a button with nowhere to go. The third intent says so instead.';

  static const String completenessDefinedOnceNote =
      'The row does not define "incomplete". Left to the call site, the list '
      'and the detail page disagree about the same vendor. The required field '
      'set is declared once and what is missing is reportable, so a support '
      'question about one vendor has an answer.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement dynamic CTA text logic that replaces the booking action with '
      '\'Contact for Details\' if the vendor profile is incomplete."';
}
