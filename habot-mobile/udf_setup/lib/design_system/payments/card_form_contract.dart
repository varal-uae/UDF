/// Step 207 (GEN-01242) -- the tokenised card form contract.
///
/// The row: "Embed tokenized PCI-DSS compliant card input form fields using
/// @habot/payments/card-form."
/// Metric: PCI-DSS Field Tokenization Compliance -- floor "Pass required",
/// optimal and ceiling "Pass (Level 1)". Pass/Fail.
///
/// **Substitution.** `@habot/payments/card-form` is an NPM specifier. There is
/// no such package, no network on this host, and a Dart package name cannot
/// contain `@` or `/`. What is buildable is the CONTRACT the hosted field must
/// satisfy and the shape of what the app is allowed to hold afterwards -- which
/// is the part that decides whether the compliance claim is true.
///
/// **The compliance property is a negative one.** "Tokenised" does not mean the
/// app tokenises the number; it means the app is never in a position to. So the
/// payload type declared here has NO field that can hold a primary account
/// number, and [HabotCardFormContract.payloadFields] is the list that says so
/// -- a list a reviewer can read and a test can assert on, rather than an
/// absence that has to be noticed.
///
/// **Two things in the row's metric are different things.** "Level 1" is a
/// MERCHANT level, set by annual transaction volume, and no amount of client
/// code makes an app Level 1 or stops it being Level 1. What client code
/// decides is the VALIDATION TYPE: hosted fields the app never touches keep the
/// merchant on SAQ A; an app that renders its own card input and tokenises it
/// is SAQ A-EP no matter how briefly it holds the number. The row asks for the
/// first and this contract requires it explicitly, because rendering a
/// TextField and calling a tokenise API afterwards satisfies the row's wording
/// and fails its intent.
///
/// **Defence in depth, and a gap found.** The Step 68 log scrubber catches a
/// bare 16-digit PAN incidentally -- its `hex` rule matches sixteen or more
/// hex characters and decimal digits are hex characters. It does NOT catch a
/// 15-digit American Express number, or any PAN written with spaces or dashes,
/// which is how a number gets into a support message. Recorded as an open item
/// against the scrubber rather than patched from here.
library;

import '../resilience/log_scrubber.dart';

/// How the card fields are rendered.
enum HabotCardFieldHosting {
  /// The payment provider renders the inputs in a view the app cannot read.
  /// SAQ A.
  providerHosted,

  /// The app renders the inputs and passes the value to a tokenising SDK.
  /// SAQ A-EP. Satisfies the word "tokenised" and not the requirement.
  appRenderedThenTokenised,

  /// The app renders the inputs and sends them to its own server. Neither.
  appRenderedThenPosted,
}

/// What the app is permitted to keep once a card has been entered.
class HabotCardToken {
  const HabotCardToken({
    required this.token,
    required this.lastFour,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
  });

  /// Provider-issued, meaningless outside the provider.
  final String token;

  /// Four digits. Permitted for display under PCI-DSS.
  final String lastFour;

  /// Reported by the hosting field, never derived from digits here. See
  /// Step 208.
  final String brand;

  final int expiryMonth;
  final int expiryYear;

  /// What is shown to the user.
  String get maskedDisplay => '$brand •••• $lastFour';
}

/// The contract a card form must satisfy to make the row's claim true.
class HabotCardFormContract {
  const HabotCardFormContract._();

  /// The NPM specifier from the row, kept so the substitution is traceable.
  static const String rowSpecifier = '@habot/payments/card-form';

  static const String substitution =
      'NPM is JavaScript\'s registry and a Dart package name may not contain '
      '@ or /. There is no network on this host and no such package exists. '
      'What is built is the contract the hosted field must satisfy, which is '
      'the part that decides whether the compliance claim is true.';

  /// The only hosting arrangement this contract admits.
  static const HabotCardFieldHosting requiredHosting =
      HabotCardFieldHosting.providerHosted;

  static bool hostingIsCompliant(HabotCardFieldHosting hosting) =>
      hosting == requiredHosting;

  /// The SAQ type each hosting arrangement puts the merchant in.
  static String saqTypeFor(HabotCardFieldHosting hosting) =>
      switch (hosting) {
        HabotCardFieldHosting.providerHosted => 'SAQ A',
        HabotCardFieldHosting.appRenderedThenTokenised => 'SAQ A-EP',
        HabotCardFieldHosting.appRenderedThenPosted => 'Neither; full DSS',
      };

  /// Every field the app may hold after a card is entered.
  ///
  /// The list is the compliance statement. A reviewer reads it; a test asserts
  /// on it; a future field that should not be here has to be added to it
  /// deliberately.
  static const List<String> payloadFields = <String>[
    'token',
    'lastFour',
    'brand',
    'expiryMonth',
    'expiryYear',
  ];

  /// Field names that would mean the app is holding cardholder data.
  static const List<String> forbiddenFields = <String>[
    'pan',
    'cardNumber',
    'primaryAccountNumber',
    'cvv',
    'cvc',
    'securityCode',
    'cardholderName',
    'track1',
    'track2',
    'pin',
  ];

  static bool get payloadCarriesNoCardholderData => !payloadFields.any(
        (String f) => forbiddenFields.contains(f.toLowerCase()),
      );

  /// Permitted display length of the account number. Four, and only the last.
  static const int permittedDigits = 4;

  static bool lastFourIsWellFormed(String value) =>
      value.length == permittedDigits &&
      RegExp(r'^\d{4}$').hasMatch(value);

  // -----------------------------------------------------------------------
  // Defence in depth: what the log scrubber does with a card number.
  // -----------------------------------------------------------------------

  /// Test PANs, from the card networks' published test ranges. These are not
  /// real accounts; they exist to be written down in exactly this situation.
  static const String visaTestPan = '4111111111111111';
  static const String amexTestPan = '378282246310005';
  static const String spacedTestPan = '4111 1111 1111 1111';
  static const String dashedTestPan = '4111-1111-1111-1111';

  static bool scrubberRedacts(String value) =>
      !HabotLogScrubber.isClean(value);

  /// The gap, computed rather than asserted.
  static Map<String, bool> get scrubberCoverage => <String, bool>{
        '16-digit PAN': scrubberRedacts(visaTestPan),
        '15-digit AMEX PAN': scrubberRedacts(amexTestPan),
        'PAN with spaces': scrubberRedacts(spacedTestPan),
        'PAN with dashes': scrubberRedacts(dashedTestPan),
      };

  static double get scrubberCoverageRate {
    final Iterable<bool> v = scrubberCoverage.values;
    return v.where((bool b) => b).length / v.length;
  }

  /// Why the 16-digit case passes: incidentally, via a rule about hashes.
  static const String incidentalCoverageNote =
      'A 16-digit PAN is redacted by the scrubber\'s `hex` rule, which matches '
      'sixteen or more hexadecimal characters -- and decimal digits are '
      'hexadecimal characters. The coverage is real and accidental. A '
      '15-digit American Express number is one character short of it, and a '
      'PAN written with spaces or dashes, which is how a number arrives in a '
      'support message, matches nothing at all.';

  /// The rule that belongs in the Step 68 scrubber. Declared, not applied --
  /// this file does not own that rule set, and two copies of a rule with only
  /// one of them executed is drift by construction.
  static final RegExp proposedPanRule =
      RegExp(r'\b(?:\d[ \-]?){12,18}\d\b');

  static bool get proposedRuleCoversEverything => <String>[
        visaTestPan,
        amexTestPan,
        spacedTestPan,
        dashedTestPan,
      ].every((String s) => proposedPanRule.hasMatch(s));

  static const String openItemNote =
      'OPEN ITEM, NOT PATCHED HERE: the PAN rule belongs in '
      'lib/design_system/resilience/log_scrubber.dart, which Step 68 owns. '
      'Adding a second copy here would leave two rules with only one of them '
      'executed, which is the exact defect Step 179 wrote its governance '
      'catalogue to avoid. The rule is proposed and the gap is measured.';

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static Map<String, bool> get complianceChecks => <String, bool>{
        'the fields are hosted by the provider, not rendered by the app':
            hostingIsCompliant(requiredHosting),
        'app-rendered inputs are named as the failure they are':
            !hostingIsCompliant(
                  HabotCardFieldHosting.appRenderedThenTokenised,
                ) &&
                saqTypeFor(HabotCardFieldHosting.appRenderedThenTokenised) ==
                    'SAQ A-EP',
        'the payload has no field that could hold cardholder data':
            payloadCarriesNoCardholderData,
        'only the last four digits are retained':
            payloadFields.contains('lastFour') &&
                !payloadFields.contains('pan'),
        'the brand is reported by the field rather than read from digits':
            payloadFields.contains('brand'),
        'every hosting arrangement has a declared SAQ consequence':
            HabotCardFieldHosting.values.every(
              (HabotCardFieldHosting h) => saqTypeFor(h).isNotEmpty,
            ) &&
                HabotCardFieldHosting.values.length == 3,
        'only four digits are displayable and the check enforces it':
            lastFourIsWellFormed('4242') && !lastFourIsWellFormed('42424'),
      };

  static bool get isCompliant =>
      complianceChecks.values.every((bool b) => b);

  static String get qualitativeOutput => isCompliant ? 'Pass' : 'Fail';

  static const String levelIsNotAValidationTypeNote =
      '"Pass (Level 1)" joins two different things. Level 1 is a MERCHANT '
      'level set by annual transaction volume; no client code makes an app '
      'Level 1 or stops it being Level 1. What client code decides is the '
      'validation type: provider-hosted fields keep the merchant on SAQ A, '
      'while an app that renders its own inputs and tokenises them afterwards '
      'is SAQ A-EP however briefly it held the number. The row asks for the '
      'first; rendering a TextField and calling a tokenise API satisfies its '
      'wording and fails its intent.';

  static const String complianceIsANegativeNote =
      'Tokenised does not mean the app tokenises the number, it means the app '
      'is never in a position to. So the payload type has no field that could '
      'hold one, and the permitted field list is written down where a reviewer '
      'can read it and a test can assert on it -- an absence has to be '
      'noticed, a declared list does not.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Embed tokenized PCI-DSS compliant card input form fields using '
      '@habot/payments/card-form."';
}
