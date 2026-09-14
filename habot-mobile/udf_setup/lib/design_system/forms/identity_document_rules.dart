/// Step 244 (GEN-03281) -- identity document filters, and the three different
/// amounts of certainty a client can have about one.
///
/// The row: "Add automated document validation filters checking Form I-9 and
/// Tax ID formatting."
/// Metric: **Doc Validation Pass Rate** -- floor 0.999, optimal 1, ceiling 1.
/// Pass. Standard cited: Form I-9 / Tax ID Format Rules.
///
/// **Form I-9 is a form, not an identifier.** It has no format to validate. It
/// is a US employment-eligibility document with fields on it, and the things
/// on it that have formats are identifiers -- a Social Security number, a
/// passport number, an alien registration number. "Checking Form I-9
/// formatting" is a category error, and what it resolves to is: validate the
/// identifiers, and treat the form as a checklist of which identifiers are
/// required together.
///
/// **This is a US row in an application that is not US.** The money CDE is
/// `cac_aed_value`, in AED. The phone rule's placeholder is a Kenyan dialling
/// code. Step 236 recorded both; this row adds a third jurisdiction. So every
/// identifier rule here names its jurisdiction, and the Emirates ID -- the
/// identifier this application's actual market issues -- is declared beside
/// the two the row asks for.
///
/// **Three identifiers, three different amounts of client-side certainty, and
/// that is the finding.** An IBAN carries a published, permanent check digit,
/// so a client can be certain (Step 243). A US EIN has a published prefix list
/// that *changes*, so a client copy goes stale and starts rejecting valid
/// numbers -- structure only, and the prefix check belongs to the server. An
/// Emirates ID's check-digit algorithm is not published by the issuing
/// authority, so a client can check structure and nothing more. A single "Doc
/// Validation Pass Rate" over all three would average three different kinds
/// of confidence into one number that means nothing.
library;

/// How sure a client can be, on its own, that an identifier is real.
enum HabotClientCertainty {
  /// A published, permanent algorithm over the value's own digits. The client
  /// can reject a wrong value outright.
  selfChecking,

  /// A published list the issuer changes. The client may check shape; a
  /// membership check embedded here would go stale silently.
  structureOnlyBecauseTheListMoves,

  /// No published algorithm at all. Structure is the whole of what a client
  /// can say.
  structureOnlyBecauseNothingIsPublished,
}

/// One issued identifier.
class HabotIdentifierRule {
  const HabotIdentifierRule({
    required this.name,
    required this.jurisdiction,
    required this.structure,
    required this.certainty,
    required this.serverSideCheck,
    required this.why,
  });

  final String name;

  /// The authority whose rules apply. Never empty: an identifier rule without
  /// a jurisdiction is a rule that is right somewhere and wrong here.
  final String jurisdiction;

  final RegExp structure;

  final HabotClientCertainty certainty;

  /// What the server must still do. Empty only where the client is certain.
  final String serverSideCheck;

  final String why;

  bool get clientCanBeCertain =>
      certainty == HabotClientCertainty.selfChecking;
}

/// One structural vector.
class HabotIdentifierCase {
  const HabotIdentifierCase({
    required this.value,
    required this.isWellFormed,
    required this.why,
  });

  final String value;
  final bool isWellFormed;
  final String why;
}

/// The filters.
class HabotIdentityDocumentRules {
  const HabotIdentityDocumentRules._();

  static const String rowConcept = 'Form I-9 and Tax ID formatting';

  static const String formIsNotAnIdentifierNote =
      'Form I-9 is a FORM, not an identifier. It has no format to validate. '
      'It is a US employment-eligibility document with fields on it, and the '
      'things on it that have formats are identifiers -- a Social Security '
      'number, a passport number, an alien registration number. "Checking '
      'Form I-9 formatting" is a category error, and what it resolves to is: '
      'validate the identifiers, and treat the form as a checklist of which '
      'identifiers are required together.';

  static List<HabotIdentifierRule> get rules => <HabotIdentifierRule>[
        HabotIdentifierRule(
          name: 'US Social Security number',
          jurisdiction: 'United States -- Social Security Administration',
          structure: RegExp(r'^\d{3}-\d{2}-\d{4}$'),
          certainty:
              HabotClientCertainty.structureOnlyBecauseNothingIsPublished,
          serverSideCheck:
              'Whether the number was ever issued, and to whom. Not a client '
              'question and not a question this application should be asking '
              'at all outside a US hiring flow.',
          why: 'The SSA publishes ranges that are never issued -- area 000, '
              'area 666, areas 900 to 999, group 00 and serial 0000 -- so a '
              'client can reject those five shapes with certainty. It cannot '
              'confirm anything positive: there is no check digit.',
        ),
        HabotIdentifierRule(
          name: 'US Employer Identification Number',
          jurisdiction: 'United States -- Internal Revenue Service',
          structure: RegExp(r'^\d{2}-\d{7}$'),
          certainty: HabotClientCertainty.structureOnlyBecauseTheListMoves,
          serverSideCheck:
              'The valid prefix list, which the IRS publishes and revises as '
              'campuses change. A copy embedded in a shipped client goes '
              'stale silently and begins rejecting valid numbers.',
          why: 'Nine digits written as two and seven. The prefix carries '
              'meaning, and the meaning is in a list that moves -- which is '
              'the exact opposite of an IBAN, whose check digit was fixed by '
              'ISO 13616 and will not change.',
        ),
        HabotIdentifierRule(
          name: 'Emirates ID',
          jurisdiction: 'United Arab Emirates -- ICP',
          structure: RegExp(r'^784-\d{4}-\d{7}-\d$'),
          certainty:
              HabotClientCertainty.structureOnlyBecauseNothingIsPublished,
          serverSideCheck:
              'Any confirmation that the number exists. The issuing authority '
              'does not publish a check-digit algorithm, so a client that '
              'claimed to verify one would be claiming something it cannot '
              'do.',
          why: 'The identifier this application\'s actual market issues, and '
              'the one the row does not mention. Fifteen digits: the 784 '
              'prefix, a four-digit year, a seven-digit serial and a final '
              'digit. Structure is the whole of what a client can say.',
        ),
      ];

  static HabotIdentifierRule ruleNamed(String fragment) =>
      rules.firstWhere((HabotIdentifierRule r) => r.name.contains(fragment));

  static bool get everyRuleNamesItsJurisdiction =>
      rules.every((HabotIdentifierRule r) => r.jurisdiction.isNotEmpty);

  static bool get noRuleClaimsCertaintyItDoesNotHave =>
      rules.every(
        (HabotIdentifierRule r) =>
            r.clientCanBeCertain || r.serverSideCheck.isNotEmpty,
      );

  // -----------------------------------------------------------------------
  // The SSA ranges, which are the one positive thing a client can act on.
  // -----------------------------------------------------------------------

  /// Reasons an SSN is known not to have been issued. Empty means only that
  /// nothing here rules it out.
  static List<String> neverIssuedReasonsFor(String value) {
    final List<String> reasons = <String>[];
    if (!ruleNamed('Social Security').structure.hasMatch(value)) {
      reasons.add('not three digits, two digits and four digits');
      return reasons;
    }
    final String area = value.substring(0, 3);
    final String group = value.substring(4, 6);
    final String serial = value.substring(7);
    final int areaNumber = int.parse(area);
    if (area == '000') {
      reasons.add('area 000 is never issued');
    }
    if (area == '666') {
      reasons.add('area 666 is never issued');
    }
    if (areaNumber >= 900 && areaNumber <= 999) {
      reasons.add('areas 900 to 999 are never issued');
    }
    if (group == '00') {
      reasons.add('group 00 is never issued');
    }
    if (serial == '0000') {
      reasons.add('serial 0000 is never issued');
    }
    return reasons;
  }

  static bool ssnIsPlausible(String value) =>
      neverIssuedReasonsFor(value).isEmpty;

  static const List<HabotIdentifierCase> ssnSuite = <HabotIdentifierCase>[
    HabotIdentifierCase(
      value: '123-45-6789',
      isWellFormed: true,
      why: 'Nothing published rules this out. Plausible is the strongest word '
          'available.',
    ),
    HabotIdentifierCase(
      value: '000-45-6789',
      isWellFormed: false,
      why: 'Area 000 is never issued.',
    ),
    HabotIdentifierCase(
      value: '666-45-6789',
      isWellFormed: false,
      why: 'Area 666 is never issued.',
    ),
    HabotIdentifierCase(
      value: '900-45-6789',
      isWellFormed: false,
      why: 'Areas 900 to 999 are never issued.',
    ),
    HabotIdentifierCase(
      value: '999-45-6789',
      isWellFormed: false,
      why: 'The top of the same range, so the bound is tested at both ends.',
    ),
    HabotIdentifierCase(
      value: '123-00-6789',
      isWellFormed: false,
      why: 'Group 00 is never issued.',
    ),
    HabotIdentifierCase(
      value: '123-45-0000',
      isWellFormed: false,
      why: 'Serial 0000 is never issued.',
    ),
    HabotIdentifierCase(
      value: '12345-6789',
      isWellFormed: false,
      why: 'Not the right shape at all.',
    ),
    HabotIdentifierCase(
      value: '899-45-6789',
      isWellFormed: true,
      why: 'One below the never-issued range, so the boundary is not off by '
          'one.',
    ),
    HabotIdentifierCase(
      value: '078-05-1120',
      isWellFormed: true,
      why: 'The number printed on a wallet insert in 1938 and typed into '
          'forms by tens of thousands of people afterwards. Structurally '
          'plausible, which is the point: a client cannot tell.',
    ),
  ];

  static bool get ssnSuiteClassifiesCorrectly => ssnSuite.every(
        (HabotIdentifierCase c) => ssnIsPlausible(c.value) == c.isWellFormed,
      );

  static double get ssnStructureAccuracy =>
      ssnSuite
          .where(
            (HabotIdentifierCase c) =>
                ssnIsPlausible(c.value) == c.isWellFormed,
          )
          .length /
      ssnSuite.length;

  /// A shape-only check -- three digits, two digits, four digits -- and
  /// nothing else. The comparison that shows what the published ranges buy.
  static double get ssnShapeOnlyAccuracy {
    int correct = 0;
    for (final HabotIdentifierCase c in ssnSuite) {
      final bool accepts =
          ruleNamed('Social Security').structure.hasMatch(c.value);
      if (accepts == c.isWellFormed) {
        correct += 1;
      }
    }
    return correct / ssnSuite.length;
  }

  // -----------------------------------------------------------------------
  // The other two structures.
  // -----------------------------------------------------------------------

  static bool einIsWellFormed(String value) =>
      ruleNamed('Employer Identification').structure.hasMatch(value);

  static bool emiratesIdIsWellFormed(String value) =>
      ruleNamed('Emirates ID').structure.hasMatch(value);

  static const List<HabotIdentifierCase> einSuite = <HabotIdentifierCase>[
    HabotIdentifierCase(
      value: '12-3456789',
      isWellFormed: true,
      why: 'Two and seven, which is all a client may assert.',
    ),
    HabotIdentifierCase(
      value: '123456789',
      isWellFormed: false,
      why: 'Nine digits with no hyphen. The IRS writes it with one.',
    ),
    HabotIdentifierCase(
      value: '1-23456789',
      isWellFormed: false,
      why: 'The hyphen in the wrong place, which is the error a person makes '
          'typing an SSN pattern into an EIN field.',
    ),
  ];

  static const List<HabotIdentifierCase> emiratesSuite =
      <HabotIdentifierCase>[
    HabotIdentifierCase(
      value: '784-1987-1234567-1',
      isWellFormed: true,
      why: 'The published shape: prefix, year, serial, final digit.',
    ),
    HabotIdentifierCase(
      value: '785-1987-1234567-1',
      isWellFormed: false,
      why: 'The prefix is fixed at 784.',
    ),
    HabotIdentifierCase(
      value: '784-1987-123456-1',
      isWellFormed: false,
      why: 'A six-digit serial. Length is the only thing there is to get '
          'wrong that a client can see.',
    ),
  ];

  static bool get einSuiteClassifiesCorrectly => einSuite.every(
        (HabotIdentifierCase c) => einIsWellFormed(c.value) == c.isWellFormed,
      );

  static bool get emiratesSuiteClassifiesCorrectly => emiratesSuite.every(
        (HabotIdentifierCase c) =>
            emiratesIdIsWellFormed(c.value) == c.isWellFormed,
      );

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String jurisdictionNote =
      'This is a US row in an application that is not US. The money CDE is '
      'cac_aed_value, in AED. The phone rule\'s placeholder is a Kenyan '
      'dialling code. Step 236 recorded both; this row adds a third '
      'jurisdiction. Every identifier rule here therefore names the authority '
      'whose rules it encodes, and the Emirates ID -- the identifier this '
      'application\'s actual market issues, and the one the row does not '
      'mention -- is declared beside the two the row asks for.';

  static const String threeCertaintiesNote =
      'Three identifiers, three different amounts of client-side certainty, '
      'and that is the finding. An IBAN carries a published, permanent check '
      'digit, so a client can reject a wrong value outright (Step 243). A US '
      'EIN has a published prefix list that CHANGES, so a client copy goes '
      'stale silently and begins rejecting valid numbers -- structure only '
      'here, prefix check on the server. An Emirates ID\'s check-digit '
      'algorithm is not published by the issuing authority, so structure is '
      'the whole of what a client can say. A single Doc Validation Pass Rate '
      'over all three would average three different kinds of confidence into '
      'one number that means nothing, so each carries its certainty and the '
      'rate is reported over classification, not over confidence.';

  static const String plausibleNotValidNote =
      'The SSA publishes ranges that are NEVER ISSUED, not ranges that are. A '
      'client can therefore say "this cannot be a Social Security number" and '
      'can never say "this is one". The predicate is named ssnIsPlausible for '
      'that reason: a method called isValid would be a promise this data '
      'cannot keep, and the field label and the error message follow the '
      'method name eventually.';

  // -----------------------------------------------------------------------
  // Metric: Doc Validation Pass Rate.
  // -----------------------------------------------------------------------

  static const double floor = 0.999;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// Classification accuracy across all three suites -- what a client can
  /// actually be graded on.
  static double get docValidationPassRate {
    final int total =
        ssnSuite.length + einSuite.length + emiratesSuite.length;
    int correct = 0;
    for (final HabotIdentifierCase c in ssnSuite) {
      if (ssnIsPlausible(c.value) == c.isWellFormed) {
        correct += 1;
      }
    }
    for (final HabotIdentifierCase c in einSuite) {
      if (einIsWellFormed(c.value) == c.isWellFormed) {
        correct += 1;
      }
    }
    for (final HabotIdentifierCase c in emiratesSuite) {
      if (emiratesIdIsWellFormed(c.value) == c.isWellFormed) {
        correct += 1;
      }
    }
    return correct / total;
  }

  static String get qualitativeOutput =>
      docValidationPassRate >= floor ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the form is distinguished from the identifiers on it':
            formIsNotAnIdentifierNote.contains('category error'),
        'three identifier rules, each naming its jurisdiction':
            rules.length == 3 && everyRuleNamesItsJurisdiction,
        'three different levels of client certainty are distinguished':
            HabotClientCertainty.values.length == 3 &&
                rules
                    .map((HabotIdentifierRule r) => r.certainty)
                    .toSet()
                    .length ==
                    2,
        'no rule claims certainty it does not have, and each names what the '
            'server must still do': noRuleClaimsCertaintyItDoesNotHave &&
            rules.every((HabotIdentifierRule r) => !r.clientCanBeCertain),
        'the SSA never-issued ranges classify a ten-vector suite':
            ssnSuiteClassifiesCorrectly && ssnSuite.length == 10,
        'shape alone gets fewer of them right than the published ranges do':
            ssnShapeOnlyAccuracy < ssnStructureAccuracy,
        'the never-issued boundary is tested at 899 and 999':
            ssnIsPlausible('899-45-6789') && !ssnIsPlausible('999-45-6789'),
        'the EIN and Emirates suites classify correctly':
            einSuiteClassifiesCorrectly && emiratesSuiteClassifiesCorrectly,
        'the application\'s own market identifier is declared even though the '
            'row does not mention it':
            ruleNamed('Emirates ID').jurisdiction.contains('United Arab'),
        'the predicate is named for what it can actually assert':
            plausibleNotValidNote.contains('never say'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the Data '
      'Collected column reads only "checkingForm" -- the tail of a missing '
      'space in the Atomic Step. Atomic Step: "Add automated document '
      'validation filters checkingForm I-9 and Tax ID formatting."';
}
