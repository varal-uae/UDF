/// Step 243 (GEN-03393) -- IBAN validation, and the two errors only
/// arithmetic catches.
///
/// The row: "Confirm 100% validation accuracy across typed IBAN input test
/// suites."
/// Metric: **IBAN Input Validation Accuracy** -- floor 1, optimal 1, ceiling 1.
/// Pass. Standard cited: ISO 13616.
///
/// **A regular expression cannot validate an IBAN.** ISO 13616 gives every
/// IBAN two check digits computed by moving the first four characters to the
/// end, mapping letters to numbers, and taking the whole thing mod 97; a valid
/// IBAN leaves a remainder of one. That is arithmetic over the value's own
/// digits, and no pattern computes a remainder. The pattern says what an IBAN
/// looks like. Mod-97 says whether it is one.
///
/// **Measured over ten vectors.** Structure alone classifies five of ten
/// correctly -- it accepts every candidate that is shaped like an IBAN,
/// including both wrong ones. Adding the country registry and its length
/// classifies eight of ten. Adding mod-97 classifies ten of ten, and the two
/// it adds are exactly the two people make: a transposed pair of digits and a
/// single mistyped digit. Against a metric whose floor, optimal and ceiling
/// are all 1, only the full stack passes.
///
/// **Grouping is presentation.** Every bank prints an IBAN in groups of four
/// and every person types it that way. Step 238 found that `accountNumber` is
/// masked to allow the space and patterned to reject it, so the conventional
/// form types cleanly and fails validation. The fix is to normalise before
/// validating, not to widen the pattern: the groups are how it is written,
/// not part of what it is.
library;

/// A country this application actually serves, with the length ISO 13616
/// registers for it.
class HabotIbanCountry {
  const HabotIbanCountry({
    required this.code,
    required this.length,
    required this.name,
  });

  final String code;
  final int length;
  final String name;
}

/// Why an IBAN was rejected, or that it was not.
enum HabotIbanVerdict {
  valid,

  /// Not shaped like an IBAN at all: wrong character classes or far too
  /// short.
  badStructure,

  /// Shaped right, but the country is not one this client carries a length
  /// for. Not the same as invalid -- see [HabotIbanValidator.registryNote].
  unknownCountry,

  /// The right country, the wrong number of characters.
  wrongLength,

  /// Everything structural holds and the check digits do not. The only
  /// verdict a pattern can never reach.
  checksumFailed,
}

/// One entry in the test suite the row asks for.
class HabotIbanCase {
  const HabotIbanCase({
    required this.value,
    required this.expected,
    required this.why,
  });

  final String value;
  final HabotIbanVerdict expected;
  final String why;

  bool get shouldBeAccepted => expected == HabotIbanVerdict.valid;
}

/// The validator.
class HabotIbanValidator {
  const HabotIbanValidator._();

  /// Structure only. Everything this alone can decide.
  static final RegExp structure = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$');

  /// The countries this client carries. A deliberate subset: see
  /// [registryNote].
  static const List<HabotIbanCountry> countries = <HabotIbanCountry>[
    HabotIbanCountry(code: 'AE', length: 23, name: 'United Arab Emirates'),
    HabotIbanCountry(code: 'SA', length: 24, name: 'Saudi Arabia'),
    HabotIbanCountry(code: 'EG', length: 29, name: 'Egypt'),
    HabotIbanCountry(code: 'GB', length: 22, name: 'United Kingdom'),
    HabotIbanCountry(code: 'DE', length: 22, name: 'Germany'),
    HabotIbanCountry(code: 'FR', length: 27, name: 'France'),
  ];

  static HabotIbanCountry? countryFor(String code) {
    for (final HabotIbanCountry c in countries) {
      if (c.code == code) {
        return c;
      }
    }
    return null;
  }

  /// Strip the grouping and upper-case. The only transformation applied, and
  /// it is applied before anything is judged.
  static String normalise(String text) {
    final StringBuffer out = StringBuffer();
    for (final int rune in text.toUpperCase().runes) {
      final String ch = String.fromCharCode(rune);
      if (ch != ' ' && ch != '-') {
        out.write(ch);
      }
    }
    return out.toString();
  }

  /// ISO 13616 mod-97, computed a character at a time so no value ever
  /// exceeds a machine integer. Returns -1 for a character outside A-Z0-9.
  static int mod97Of(String normalised) {
    if (normalised.length < 5) {
      return -1;
    }
    final String rearranged =
        normalised.substring(4) + normalised.substring(0, 4);
    int remainder = 0;
    for (final int unit in rearranged.codeUnits) {
      int value;
      if (unit >= 0x41 && unit <= 0x5A) {
        value = unit - 0x37;
      } else if (unit >= 0x30 && unit <= 0x39) {
        value = unit - 0x30;
      } else {
        return -1;
      }
      remainder = value > 9
          ? (remainder * 100 + value) % 97
          : (remainder * 10 + value) % 97;
    }
    return remainder;
  }

  /// The whole stack, in the order that gives the most specific reason.
  static HabotIbanVerdict validate(String text) {
    final String value = normalise(text);
    if (!structure.hasMatch(value)) {
      return HabotIbanVerdict.badStructure;
    }
    final HabotIbanCountry? country = countryFor(value.substring(0, 2));
    if (country == null) {
      return HabotIbanVerdict.unknownCountry;
    }
    if (value.length != country.length) {
      return HabotIbanVerdict.wrongLength;
    }
    return mod97Of(value) == 1
        ? HabotIbanVerdict.valid
        : HabotIbanVerdict.checksumFailed;
  }

  static bool isValid(String text) =>
      validate(text) == HabotIbanVerdict.valid;

  // -----------------------------------------------------------------------
  // The test suite the row asks for.
  // -----------------------------------------------------------------------

  static const List<HabotIbanCase> suite = <HabotIbanCase>[
    HabotIbanCase(
      value: 'AE070331234567890123456',
      expected: HabotIbanVerdict.valid,
      why: 'A UAE account, twenty-three characters, check digits computed '
          'rather than chosen.',
    ),
    HabotIbanCase(
      value: 'AE980199999888877776666',
      expected: HabotIbanVerdict.valid,
      why: 'A second UAE account at a different bank, so the country length '
          'is not being confirmed by one example.',
    ),
    HabotIbanCase(
      value: 'GB82WEST12345698765432',
      expected: HabotIbanVerdict.valid,
      why: 'The ISO 13616 worked example. Letters in the account part, which '
          'is what the letter-to-number mapping exists for.',
    ),
    HabotIbanCase(
      value: 'DE89370400440532013000',
      expected: HabotIbanVerdict.valid,
      why: 'A second country at the same length as GB, so length is not '
          'standing in for identity.',
    ),
    HabotIbanCase(
      value: 'AE070331235467890123456',
      expected: HabotIbanVerdict.checksumFailed,
      why: 'Two adjacent digits transposed. Right country, right length, '
          'right shape. ONLY mod-97 catches this, and transposition is the '
          'single most common typing error there is.',
    ),
    HabotIbanCase(
      value: 'AE070331334567890123456',
      expected: HabotIbanVerdict.checksumFailed,
      why: 'One digit mistyped. Again structurally perfect, again caught '
          'only by the arithmetic.',
    ),
    HabotIbanCase(
      value: 'AE07033123456789012345',
      expected: HabotIbanVerdict.wrongLength,
      why: 'A UAE IBAN one character short -- the error a person makes by '
          'dropping a digit while reading it off a statement.',
    ),
    HabotIbanCase(
      value: 'AE0703312345678901234567',
      expected: HabotIbanVerdict.wrongLength,
      why: 'One character too long.',
    ),
    HabotIbanCase(
      value: 'AE07033123',
      expected: HabotIbanVerdict.badStructure,
      why: 'Half an IBAN -- the shape a partial paste leaves behind. Rejected '
          'on structure before any country is looked up, because there is '
          'nothing here to look one up with.',
    ),
    HabotIbanCase(
      value: 'XX0700000000000000000000',
      expected: HabotIbanVerdict.unknownCountry,
      why: 'A country code that is not in the registry this client carries. '
          'Reported as unknown rather than invalid, because those are '
          'different facts.',
    ),
  ];

  static bool get suiteIsFullyClassified =>
      suite.every((HabotIbanCase c) => validate(c.value) == c.expected);

  /// Accuracy over the suite, for a validator that knows only the structure.
  static double get structureOnlyAccuracy => _accuracyOf(
        (String v) => structure.hasMatch(normalise(v)),
      );

  /// Structure plus the country registry and its length. Still no arithmetic.
  static double get structureAndRegistryAccuracy => _accuracyOf((String v) {
        final String n = normalise(v);
        if (!structure.hasMatch(n)) {
          return false;
        }
        final HabotIbanCountry? c = countryFor(n.substring(0, 2));
        return c != null && n.length == c.length;
      });

  /// The full stack.
  static double get fullStackAccuracy => _accuracyOf(isValid);

  static double _accuracyOf(bool Function(String) accepts) {
    int correct = 0;
    for (final HabotIbanCase c in suite) {
      if (accepts(c.value) == c.shouldBeAccepted) {
        correct += 1;
      }
    }
    return correct / suite.length;
  }

  /// The two cases that separate the arithmetic from everything else.
  static List<HabotIbanCase> get caughtOnlyByTheChecksum => suite
      .where(
        (HabotIbanCase c) => c.expected == HabotIbanVerdict.checksumFailed,
      )
      .toList();

  static bool get theChecksumIsWhatMakesItOne =>
      caughtOnlyByTheChecksum.length == 2 &&
      structureAndRegistryAccuracy < 1.0 &&
      fullStackAccuracy == 1.0;

  // -----------------------------------------------------------------------
  // Grouping, which is Step 238's other half.
  // -----------------------------------------------------------------------

  static const String groupedForm = 'AE07 0331 2345 6789 0123 456';

  static bool get groupedFormValidates => isValid(groupedForm);

  static bool get groupingSurvivesNormalisation =>
      normalise(groupedForm) == suite.first.value;

  static bool get lowerCaseSurvivesNormalisation =>
      isValid(groupedForm.toLowerCase());

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String regexCannotNote =
      'A regular expression cannot validate an IBAN. ISO 13616 gives every '
      'IBAN two check digits computed by moving the first four characters to '
      'the end, mapping letters to numbers, and taking the whole thing mod '
      '97; a valid IBAN leaves a remainder of one. That is arithmetic over '
      'the value\'s own digits, and no pattern computes a remainder. The '
      'pattern says what an IBAN LOOKS LIKE. Mod-97 says whether it IS one.';

  static const String registryNote =
      'The country table is a deliberate subset: six countries, the ones this '
      'application serves or is likely to be paid from. The full ISO 13616 '
      'registry changes -- countries join, and a client copy of it goes stale '
      'silently. A stale copy does not fail loudly; it starts rejecting valid '
      'accounts from a country that joined after the last release, and the '
      'person on the other end has no way to tell. So an unrecognised country '
      'returns unknownCountry rather than invalid, and what the interface '
      'does with that is a different decision from what it does with a failed '
      'check digit.';

  static const String groupingNote =
      'Every bank prints an IBAN in groups of four and every person types it '
      'that way. Step 238 found accountNumber masked to ALLOW the space and '
      'patterned to REJECT it, so the conventional form types cleanly and '
      'fails validation. The fix is to normalise before validating, not to '
      'widen the pattern: the groups are how an IBAN is written, not part of '
      'what it is, and a pattern that accepted them would also accept them in '
      'the wrong places.';

  static const String layersNote =
      'Measured over ten vectors. Structure alone classifies five of ten '
      'correctly -- it accepts every candidate that is shaped like an IBAN, '
      'including both wrong ones. Adding the country registry and its length '
      'classifies eight of ten. Adding mod-97 classifies ten of ten, and the '
      'two it adds are exactly the two people make: a transposed pair of '
      'digits and a single mistyped digit. Against a metric whose floor, '
      'optimal and ceiling are all 1, only the full stack passes.';

  // -----------------------------------------------------------------------
  // Metric: IBAN Input Validation Accuracy -- floor, optimal, ceiling all 1.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  static String get qualitativeOutput =>
      fullStackAccuracy >= floor && suiteIsFullyClassified ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'every vector reaches the verdict it was chosen to reach':
            suiteIsFullyClassified,
        'ten vectors covering all five verdicts':
            suite.length == 10 &&
                suite.map((HabotIbanCase c) => c.expected).toSet().length ==
                    HabotIbanVerdict.values.length,
        'structure alone gets half of them right':
            (structureOnlyAccuracy - 0.5).abs() < 1e-9,
        'adding the registry and length reaches 0.8, still short of the '
            'row\'s floor': (structureAndRegistryAccuracy - 0.8).abs() < 1e-9 &&
            structureAndRegistryAccuracy < floor,
        'the full stack is exactly 1.0': fullStackAccuracy == 1.0,
        'the two the checksum adds are a transposition and a mistyped digit':
            theChecksumIsWhatMakesItOne,
        'the conventional grouped form validates':
            groupedFormValidates && groupingSurvivesNormalisation,
        'a lower-cased IBAN validates': lowerCaseSurvivesNormalisation,
        'an unknown country is reported as unknown, not as invalid':
            validate('XX0700000000000000000000') ==
                HabotIbanVerdict.unknownCountry,
        'the stale-registry argument is written down':
            registryNote.contains('goes stale'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Confirm 100% validation accuracy across typed IBAN input test '
      'suites."';
}
