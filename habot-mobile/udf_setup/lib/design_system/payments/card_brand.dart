/// Step 208 (GEN-01551) -- showing the card brand as the card is entered.
///
/// The row: "Attach visual card brand detection logic to render Visa,
/// Mastercard, or AMEX icons dynamically upon card entry."
/// Metric: Icon Recognition Accuracy -- 0.8 / 0.95 / 1. Good/Average/Poor.
///
/// **This row and Step 207 point in opposite directions.** Brand detection
/// conventionally reads the first six to eight digits of the account number.
/// Step 207's requirement is that the app is never in a position to see any of
/// them. Both are correct; the reconciliation is that the brand does not come
/// from the app looking at digits -- it comes from the hosted field, which is
/// already looking at them, telling the app what it found. Every real hosted
/// card SDK emits exactly this callback, for exactly this reason.
///
/// So the IIN table below is the CONTRACT the provider is expected to implement
/// and the thing the app's rendering is checked against.
/// [HabotCardBrandDetection.fromProviderIdentifier] takes a brand identifier,
/// not a number, and the one function that accepts
/// digits is [HabotCardBrandDetection.fromIinForProviderSide], which is marked
/// as not for use in this app and exists so the table can be tested at all.
///
/// **Three brands is not the market.** The row names Visa, Mastercard and AMEX.
/// UnionPay and Diners are both accepted in the UAE, JCB turns up on visiting
/// tourists' cards, and a brand the table does not know must render a neutral
/// card glyph -- not nothing, which reads as a broken field, and not the
/// nearest guess, which is worse than nothing.
///
/// **The icons are trademarks.** A redrawn approximation of the Mastercard
/// circles is both a legal problem and an accuracy problem, and the metric on
/// this row is recognition accuracy. The assets come from each network's brand
/// kit; that is recorded as a delivery dependency rather than solved in code.
///
/// **An icon alone says nothing.** A brand mark with no accessible name is
/// invisible to a screen reader, so every brand carries a label.
library;

/// Brands this app can render.
enum HabotCardBrand {
  visa,
  mastercard,
  amex,
  unionPay,
  diners,
  jcb,

  /// A card whose brand the provider did not identify, or identified as
  /// something not in this list.
  unknown,
}

/// One brand's presentation and its issuer identification ranges.
class HabotCardBrandSpec {
  const HabotCardBrandSpec({
    required this.brand,
    required this.displayName,
    required this.assetKey,
    required this.iinPrefixes,
    required this.panLengths,
    required this.namedInRow,
  });

  final HabotCardBrand brand;

  /// The accessible name. Also the text fallback if the asset is missing.
  final String displayName;

  /// Where the network's own artwork is registered. Never a redrawn glyph.
  final String assetKey;

  /// Issuer identification prefixes, as the provider is expected to apply
  /// them. Not used by this app -- see the file header.
  final List<String> iinPrefixes;

  /// Valid account-number lengths for this brand.
  final List<int> panLengths;

  /// Whether the row named this brand.
  final bool namedInRow;
}

/// The brand table.
class HabotCardBrandDetection {
  const HabotCardBrandDetection._();

  static const List<HabotCardBrandSpec> specs = <HabotCardBrandSpec>[
    HabotCardBrandSpec(
      brand: HabotCardBrand.visa,
      displayName: 'Visa',
      assetKey: 'brand/visa',
      iinPrefixes: <String>['4'],
      panLengths: <int>[13, 16, 19],
      namedInRow: true,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.mastercard,
      displayName: 'Mastercard',
      assetKey: 'brand/mastercard',
      iinPrefixes: <String>[
        '51',
        '52',
        '53',
        '54',
        '55',
        '2221',
        '2720',
      ],
      panLengths: <int>[16],
      namedInRow: true,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.amex,
      displayName: 'American Express',
      assetKey: 'brand/amex',
      iinPrefixes: <String>['34', '37'],
      panLengths: <int>[15],
      namedInRow: true,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.unionPay,
      displayName: 'UnionPay',
      assetKey: 'brand/unionpay',
      iinPrefixes: <String>['62'],
      panLengths: <int>[16, 17, 18, 19],
      namedInRow: false,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.diners,
      displayName: 'Diners Club',
      assetKey: 'brand/diners',
      iinPrefixes: <String>['36', '38', '300', '305'],
      panLengths: <int>[14, 16, 19],
      namedInRow: false,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.jcb,
      displayName: 'JCB',
      assetKey: 'brand/jcb',
      iinPrefixes: <String>['3528', '3589'],
      panLengths: <int>[16, 17, 18, 19],
      namedInRow: false,
    ),
    HabotCardBrandSpec(
      brand: HabotCardBrand.unknown,
      displayName: 'Card',
      assetKey: 'brand/generic',
      iinPrefixes: <String>[],
      panLengths: <int>[],
      namedInRow: false,
    ),
  ];

  static HabotCardBrandSpec specFor(HabotCardBrand brand) =>
      specs.firstWhere((HabotCardBrandSpec s) => s.brand == brand);

  /// The app's path: the hosted field reports a brand identifier and this maps
  /// it. No digits pass through here.
  static HabotCardBrand fromProviderIdentifier(String? identifier) {
    if (identifier == null) {
      return HabotCardBrand.unknown;
    }
    final String key = identifier.trim().toLowerCase().replaceAll(' ', '');
    return switch (key) {
      'visa' => HabotCardBrand.visa,
      'mastercard' || 'mc' || 'master' => HabotCardBrand.mastercard,
      'amex' || 'americanexpress' => HabotCardBrand.amex,
      'unionpay' || 'cup' => HabotCardBrand.unionPay,
      'diners' || 'dinersclub' => HabotCardBrand.diners,
      'jcb' => HabotCardBrand.jcb,
      _ => HabotCardBrand.unknown,
    };
  }

  /// The provider's side of the contract, kept here so the table can be
  /// exercised. **Not to be called from this app**: it takes account-number
  /// digits, which Step 207's requirement is that the app never holds.
  static HabotCardBrand fromIinForProviderSide(String digits) {
    HabotCardBrand best = HabotCardBrand.unknown;
    int bestLength = 0;
    for (final HabotCardBrandSpec spec in specs) {
      for (final String prefix in spec.iinPrefixes) {
        if (digits.startsWith(prefix) && prefix.length > bestLength) {
          best = spec.brand;
          bestLength = prefix.length;
        }
      }
    }
    return best;
  }

  static const String notForAppUseNote =
      'fromIinForProviderSide takes account-number digits. It exists so the '
      'IIN table is testable and so the contract handed to the provider is '
      'written in executable form. Calling it from this app would put a PAN in '
      'the app\'s memory, which is the single thing Step 207 exists to '
      'prevent.';

  /// Luhn, for the provider side. Same status as above.
  static bool luhnIsValid(String digits) {
    int sum = 0;
    bool doubling = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      final int d = digits.codeUnitAt(i) - 0x30;
      if (d < 0 || d > 9) {
        return false;
      }
      int v = d;
      if (doubling) {
        v *= 2;
        if (v > 9) {
          v -= 9;
        }
      }
      sum += v;
      doubling = !doubling;
    }
    return digits.isNotEmpty && sum % 10 == 0;
  }

  // -----------------------------------------------------------------------
  // Presentation.
  // -----------------------------------------------------------------------

  /// The accessible name for a brand mark. Never empty, including for the
  /// generic card.
  static String semanticLabelFor(HabotCardBrand brand) =>
      specFor(brand).displayName;

  static String assetKeyFor(HabotCardBrand brand) => specFor(brand).assetKey;

  /// True when a brand renders something rather than an empty slot.
  static bool rendersSomething(HabotCardBrand brand) =>
      assetKeyFor(brand).isNotEmpty;

  static bool get unknownFallsBackToGeneric =>
      assetKeyFor(HabotCardBrand.unknown) == 'brand/generic' &&
      semanticLabelFor(HabotCardBrand.unknown).isNotEmpty;

  /// Brands accepted in this market that the row did not name.
  static List<HabotCardBrand> get beyondTheRow => specs
      .where(
        (HabotCardBrandSpec s) =>
            !s.namedInRow && s.brand != HabotCardBrand.unknown,
      )
      .map((HabotCardBrandSpec s) => s.brand)
      .toList();

  static const String trademarkedArtworkNote =
      'Brand marks are trademarks. A redrawn approximation of the Mastercard '
      'circles is a legal problem and an accuracy problem at once, and '
      'recognition accuracy is the metric on this row. Each asset key points '
      'at artwork obtained from that network\'s own brand kit; supplying those '
      'files is a delivery dependency, recorded rather than solved in code.';

  // -----------------------------------------------------------------------
  // Metric: Icon Recognition Accuracy. 0.8 / 0.95 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.8;
  static const double optimal = 0.95;
  static const double ceiling = 1;

  /// Provider identifiers as they arrive in practice, including the casing and
  /// spacing variations different SDKs use.
  static const Map<String, HabotCardBrand> providerIdentifierCases =
      <String, HabotCardBrand>{
    'visa': HabotCardBrand.visa,
    'Visa': HabotCardBrand.visa,
    'mastercard': HabotCardBrand.mastercard,
    'MasterCard': HabotCardBrand.mastercard,
    'master card': HabotCardBrand.mastercard,
    'amex': HabotCardBrand.amex,
    'American Express': HabotCardBrand.amex,
    'unionpay': HabotCardBrand.unionPay,
    'diners': HabotCardBrand.diners,
    'JCB': HabotCardBrand.jcb,
    'elo': HabotCardBrand.unknown,
    '': HabotCardBrand.unknown,
  };

  /// Share of provider identifiers mapped to the right brand.
  static double get identifierAccuracy {
    int right = 0;
    providerIdentifierCases.forEach((String k, HabotCardBrand expected) {
      if (fromProviderIdentifier(k) == expected) {
        right++;
      }
    });
    return right / providerIdentifierCases.length;
  }

  /// Share of brands that render a mark with an accessible name.
  static double get renderAccuracy =>
      specs
          .where(
            (HabotCardBrandSpec s) =>
                rendersSomething(s.brand) &&
                semanticLabelFor(s.brand).isNotEmpty,
          )
          .length /
      specs.length;

  static double get iconRecognitionAccuracy =>
      (identifierAccuracy + renderAccuracy) / 2;

  static String get qualitativeOutput {
    final double a = iconRecognitionAccuracy;
    if (a >= optimal) {
      return 'Good';
    }
    if (a >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  static const String tensionWithStep207Note =
      'Brand detection conventionally reads the first six to eight digits of '
      'the account number; Step 207 requires that the app never see any of '
      'them. Both are right. The brand comes from the hosted field, which is '
      'already looking, telling the app what it found -- the callback every '
      'real card SDK emits, for this reason. The IIN table here is the '
      'contract handed to the provider, not a code path in this app.';

  static const String unknownIsARenderNote =
      'A brand the table does not know renders a neutral card glyph with the '
      'name "Card". An empty slot reads as a broken field; a nearest guess is '
      'worse than nothing, because it is confidently wrong at the moment '
      'someone is entering their card.';

  static const String threeBrandsIsNotTheMarketNote =
      'The row names Visa, Mastercard and AMEX. UnionPay and Diners are both '
      'accepted in this market and JCB arrives on visiting cards. They are in '
      'the table and marked as beyond the row, so the difference between what '
      'was asked for and what ships is visible rather than quietly added.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Attach visual card brand detection logic to render Visa, Mastercard, '
      'or AMEX icons dynamically upon card entry."';
}
