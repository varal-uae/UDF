/// Step 203 (GEN-01209) -- limiting displayed add-ons to three per service.
///
/// The row: "Set structural rules limiting displayed add-on options to a
/// maximum of 3 items per service."
/// Metric: **Add-On Attach Rate** -- floor 0.1, optimal 0.25, ceiling 0.4.
///
/// The row sets a cap and leaves out the decision the cap creates. If a service
/// carries seven add-ons and three are shown, four are invisible, and the
/// attach rate the row is measured on is no longer measuring the catalogue --
/// it is measuring the ordering. Whichever three the list happens to yield
/// first get every attachment; the other four get none and are
/// indistinguishable in the data from add-ons nobody wants.
///
/// So the ordering is declared, deterministic and stable: a ranked rule, not
/// insertion order, not whatever the API returned. And the remainder is
/// reachable, because "three are displayed" and "four do not exist" are
/// different products and only one of them is what the row asked for.
///
/// **The ceiling is not a target.** An attach rate above 0.4 is flagged here
/// rather than celebrated: at that level the add-ons are probably being read as
/// required rather than optional -- an upsell that looks like a mandatory step
/// converts beautifully and shows up later as refund requests.
library;

/// How the visible three are chosen.
enum HabotAddOnRanking {
  /// Operator-set priority, then price ascending, then id. Total and stable.
  curated,

  /// Whatever order the catalogue happened to yield. Kept as a named value so
  /// that choosing it is a decision rather than the default.
  sourceOrder,
}

/// One add-on as the display rule needs it.
class HabotAddOn {
  const HabotAddOn({
    required this.id,
    required this.name,
    required this.priceMinorUnits,
    required this.operatorPriority,
    this.isRequiredByService = false,
  });

  final String id;
  final String name;

  /// Price in the currency's minor unit. Money arithmetic lives in Step 204.
  final int priceMinorUnits;

  /// Lower sorts first. Set by the operator, not by the app.
  final int operatorPriority;

  /// An add-on the service cannot run without. Never hidden by the cap, and
  /// never counted as an attachment, because it was not a choice.
  final bool isRequiredByService;
}

/// The display rule.
class HabotAddOnDisplayRules {
  const HabotAddOnDisplayRules._();

  /// The cap from the row.
  static const int maximumDisplayed = 3;

  /// Deterministic ordering. Ties are broken all the way down to the id, so
  /// two runs over the same catalogue produce the same three.
  static List<HabotAddOn> rank(
    List<HabotAddOn> addOns, {
    HabotAddOnRanking ranking = HabotAddOnRanking.curated,
  }) {
    final List<HabotAddOn> sorted = List<HabotAddOn>.of(addOns);
    if (ranking == HabotAddOnRanking.sourceOrder) {
      return sorted;
    }
    sorted.sort((HabotAddOn a, HabotAddOn b) {
      final int byPriority =
          a.operatorPriority.compareTo(b.operatorPriority);
      if (byPriority != 0) {
        return byPriority;
      }
      final int byPrice = a.priceMinorUnits.compareTo(b.priceMinorUnits);
      if (byPrice != 0) {
        return byPrice;
      }
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  /// Add-ons the service requires. Shown regardless of the cap, because
  /// hiding a mandatory item behind "show all" produces a booking the parent
  /// did not know the price of.
  static List<HabotAddOn> required(List<HabotAddOn> addOns) =>
      addOns.where((HabotAddOn a) => a.isRequiredByService).toList();

  /// The optional add-ons shown by default.
  static List<HabotAddOn> visible(
    List<HabotAddOn> addOns, {
    HabotAddOnRanking ranking = HabotAddOnRanking.curated,
  }) {
    final List<HabotAddOn> optional = rank(addOns, ranking: ranking)
        .where((HabotAddOn a) => !a.isRequiredByService)
        .toList();
    return optional.take(maximumDisplayed).toList();
  }

  /// The optional add-ons the cap hides.
  static List<HabotAddOn> hidden(
    List<HabotAddOn> addOns, {
    HabotAddOnRanking ranking = HabotAddOnRanking.curated,
  }) {
    final List<HabotAddOn> optional = rank(addOns, ranking: ranking)
        .where((HabotAddOn a) => !a.isRequiredByService)
        .toList();
    return optional.skip(maximumDisplayed).toList();
  }

  /// True when there is more to see. Drives the disclosure control.
  static bool hasMore(List<HabotAddOn> addOns) => hidden(addOns).isNotEmpty;

  /// The label for the disclosure, stating the number rather than "more".
  static String disclosureLabel(List<HabotAddOn> addOns) {
    final int n = hidden(addOns).length;
    return n == 1 ? 'Show 1 more option' : 'Show $n more options';
  }

  /// Whether ranking this catalogue twice gives the same visible three.
  static bool isDeterministic(List<HabotAddOn> addOns) {
    final List<String> a =
        visible(addOns).map((HabotAddOn x) => x.id).toList();
    final List<HabotAddOn> shuffled = List<HabotAddOn>.of(addOns.reversed);
    final List<String> b =
        visible(shuffled).map((HabotAddOn x) => x.id).toList();
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  /// The same check for the ordering the row's silence would have produced.
  static bool sourceOrderIsDeterministic(List<HabotAddOn> addOns) {
    final List<String> a =
        visible(addOns, ranking: HabotAddOnRanking.sourceOrder)
            .map((HabotAddOn x) => x.id)
            .toList();
    final List<String> b = visible(
      List<HabotAddOn>.of(addOns.reversed),
      ranking: HabotAddOnRanking.sourceOrder,
    ).map((HabotAddOn x) => x.id).toList();
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  /// Share of the optional catalogue a parent can reach without expanding.
  static double defaultReach(List<HabotAddOn> addOns) {
    final int optional =
        addOns.where((HabotAddOn a) => !a.isRequiredByService).length;
    if (optional == 0) {
      return 1;
    }
    return visible(addOns).length / optional;
  }

  // -----------------------------------------------------------------------
  // Metric: Add-On Attach Rate. 0.1 / 0.25 / 0.4.
  // -----------------------------------------------------------------------

  static const double floor = 0.1;
  static const double optimal = 0.25;
  static const double ceiling = 0.4;

  /// Attach rate over bookings. Required add-ons are excluded from both sides:
  /// an item the service mandates was never an attachment.
  static double attachRate({
    required int bookingsWithAnOptionalAddOn,
    required int bookings,
  }) =>
      bookings == 0 ? 0 : bookingsWithAnOptionalAddOn / bookings;

  /// True when a rate is past the ceiling, which is a signal rather than a win.
  static bool isAboveCeiling(double rate) => rate > ceiling;

  static String qualitativeOutput(double rate) {
    if (isAboveCeiling(rate)) {
      return 'Poor';
    }
    if (rate >= optimal) {
      return 'Good';
    }
    if (rate >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  static const String capCreatesARankingNote =
      'A cap of three over a catalogue of seven does not reduce clutter, it '
      'elects three winners. The attach rate then measures the ordering rather '
      'than the catalogue, and the four hidden add-ons are '
      'indistinguishable in the data from add-ons nobody wanted. The ordering '
      'is declared, ranked and stable so at least the election is on the '
      'record.';

  static const String hiddenIsNotAbsentNote =
      '"Three are displayed" and "four do not exist" are different products. '
      'The remainder stays reachable behind a disclosure that names how many '
      'there are, rather than a "More" that could mean anything.';

  static const String requiredIsNotAnAttachmentNote =
      'An add-on the service mandates is shown regardless of the cap and '
      'counted on neither side of the attach rate. Hiding a mandatory item '
      'behind a disclosure produces a booking whose price the parent did not '
      'see; counting it as an attachment inflates the metric with items nobody '
      'chose.';

  static const String ceilingIsAWarningNote =
      'An attach rate above 0.4 is reported as Poor rather than as excellent. '
      'At that level optional add-ons are most likely being read as required '
      'steps, which converts well and returns later as refund requests. The '
      'ceiling in this row is a bound, not a target.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Set structural rules limiting displayed add-on options to a maximum of '
      '3 items per service."';
}
