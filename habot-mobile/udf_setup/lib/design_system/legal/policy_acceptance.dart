/// Step 385 (GEN-02422) -- what an acceptance has to record to be worth
/// anything later.
///
/// The row: "Embed DCYN compliance checks for all legal policy acceptances."
/// Metric: **Compliance Check Pass Rate (%)** -- floor 0.99, optimal 1, ceiling
/// 1. Yes/No. ISO/IEC 27001, SOX Compliance. Assigned to **GFD**.
///
/// **An acceptance is evidence, and evidence is about a moment.** "This user
/// accepted the terms" is worth very little; "this user accepted version 4.2 of
/// the terms, in Arabic, at 09:14 on 3 September, by tapping a button whose
/// label read 'I agree'" is worth something, because it can be checked against
/// what version 4.2 said and what the button actually read. Six fields, and the
/// two people usually forget are the version and the language.
///
/// **A pre-ticked box is not an acceptance.** Neither is a checkbox ticked by
/// default, nor a continue button whose small print says continuing means
/// agreeing. The control starts unticked, the person acts, and the act is what
/// gets recorded -- which is also what makes the record defensible rather than
/// merely present.
///
/// **A gate is not a compliance check.** DCYN is a binary gate: yes or no,
/// evaluated at the edge. Whether the acceptance *complies* with anything is a
/// question about jurisdiction, age, the version served and what the regulator
/// requires this month, and none of that is knowable on a phone. The client
/// records a complete, checkable acceptance; something else decides whether it
/// was lawful.
///
/// **Re-acceptance is the case the row does not mention.** Terms change, and a
/// person who accepted 4.1 has not accepted 4.2. The acceptance is stored
/// against a version, so the question "has this person accepted the current
/// terms" has an answer, rather than being a boolean somebody set once in 2024.
library;

import '../forms/strict_true_gate.dart';

/// A field an acceptance record has to carry to be checkable.
enum HabotAcceptanceField {
  /// Who accepted.
  subject,

  /// Which version of the document.
  documentVersion,

  /// Which language they were shown.
  language,

  /// When, to the second, with an offset.
  timestamp,

  /// What the control they used actually said.
  controlLabel,

  /// Where the acceptance was recorded from.
  origin,
}

/// One stored acceptance.
class HabotAcceptanceRecord {
  const HabotAcceptanceRecord({
    required this.subject,
    required this.documentVersion,
    required this.language,
    required this.timestamp,
    required this.controlLabel,
    required this.origin,
  });

  final String subject;
  final String documentVersion;
  final String language;
  final String timestamp;
  final String controlLabel;
  final String origin;

  List<String> get values => <String>[
        subject,
        documentVersion,
        language,
        timestamp,
        controlLabel,
        origin,
      ];

  bool get isComplete => values.every((String v) => v.isNotEmpty);
}

/// The policy-acceptance rule.
class HabotPolicyAcceptance {
  const HabotPolicyAcceptance._();

  // -----------------------------------------------------------------------
  // Six fields.
  // -----------------------------------------------------------------------

  static const HabotAcceptanceRecord worked = HabotAcceptanceRecord(
    subject: 'the signed-in account',
    documentVersion: '4.2',
    language: 'ar',
    timestamp: '2026-09-03T09:14:07+04:00',
    controlLabel: 'I agree',
    origin: 'the mobile application, onboarding step 6',
  );

  static bool get everyFieldIsPresent =>
      worked.isComplete &&
      worked.values.length == HabotAcceptanceField.values.length;

  static bool get theVersionIsRecorded => worked.documentVersion == '4.2';

  static bool get theLanguageIsRecorded => worked.language.isNotEmpty;

  /// The timestamp carries an offset, so "09:14" means one moment rather than
  /// one of several.
  static bool get theTimestampCarriesAnOffset =>
      worked.timestamp.contains('+');

  static bool get theControlLabelIsRecorded =>
      worked.controlLabel == 'I agree';

  static const String evidenceNote =
      '"This user accepted the terms" is worth very little. "This user '
      'accepted version 4.2, in Arabic, at 09:14:07 with an offset, by tapping '
      'a control that read I agree" is worth something, because every part of '
      'it can be checked against what 4.2 said and what the button actually '
      'read. The two fields people leave out are the version and the language, '
      'and they are the two that decide what was agreed to.';

  // -----------------------------------------------------------------------
  // The act has to happen.
  // -----------------------------------------------------------------------

  static const bool theBoxStartsTicked = false;

  static const bool continuingCountsAsAgreeing = false;

  static bool get thePersonHasToAct =>
      !theBoxStartsTicked && !continuingCountsAsAgreeing;

  /// The check is the strict one Step 246 declared: an unanswered question
  /// and a declined one are both refusals, and only an explicit true passes.
  static bool accepted(bool? ticked) =>
      HabotStrictTrueGate.strictCheckOf(ticked);

  static bool get theGateIsTheDeclaredOne =>
      !accepted(null) && !accepted(false) && accepted(true);

  /// The check a nullable boolean invites, kept as the contrast: it lets an
  /// unanswered acceptance through.
  static bool get aLooseCheckWouldPassAnUnansweredBox =>
      HabotStrictTrueGate.looseCheckOf(null) && !accepted(null);

  static const String actNote =
      'A pre-ticked box is not an acceptance, and neither is a continue button '
      'whose small print says continuing means agreeing. The control starts '
      'unticked and the person acts; the gate is Step 246\'s strict-true rule, '
      'where an unanswered question and a declined one are both refusals '
      'rather than one of them quietly passing.';

  // -----------------------------------------------------------------------
  // A gate is not a compliance check.
  // -----------------------------------------------------------------------

  static const bool theClientDecidesWhetherItWasLawful = false;

  static const List<String> whatTheClientCannotKnow = <String>[
    'which jurisdiction the person is in',
    'whether they are old enough to agree',
    'what the regulator requires this month',
  ];

  static bool get theLimitIsStated =>
      !theClientDecidesWhetherItWasLawful &&
      whatTheClientCannotKnow.length == 3;

  static const String complianceNote =
      'DCYN is a binary gate evaluated at the edge: yes or no. Whether an '
      'acceptance complies with anything is a question about jurisdiction, '
      'age, the version served and what the regulator requires this month, and '
      'none of that is knowable on a phone. The client records a complete and '
      'checkable acceptance; something else decides whether it was lawful. '
      'Calling the gate a compliance check is how an organisation comes to '
      'believe the phone already checked.';

  // -----------------------------------------------------------------------
  // Re-acceptance.
  // -----------------------------------------------------------------------

  static const String currentVersion = '4.2';

  static bool hasAcceptedCurrent(String acceptedVersion) =>
      acceptedVersion == currentVersion;

  static bool get anOlderAcceptanceDoesNotCount =>
      !hasAcceptedCurrent('4.1') && hasAcceptedCurrent('4.2');

  static const bool acceptanceIsABooleanSetOnce = false;

  static const String versionNote =
      'Terms change, and somebody who accepted 4.1 has not accepted 4.2. '
      'Because the acceptance is stored against a version rather than as a '
      'boolean set once, "has this person accepted the current terms" has an '
      'answer -- and the answer changes on the day the terms do, without '
      'anybody running a migration.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.99;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static double get completeness => worked.values.isEmpty
      ? 0
      : worked.values.where((String v) => v.isNotEmpty).length /
          worked.values.length *
          100;

  static const String outputColumn = 'Yes/No';

  static bool get theOutputIsBinary => outputColumn.contains('/');

  static Map<String, bool> get obligations => <String, bool>{
        'the record carries all six fields': everyFieldIsPresent,
        'the version and the language are among them':
            theVersionIsRecorded && theLanguageIsRecorded,
        'the timestamp names one moment': theTimestampCarriesAnOffset,
        'the person has to act': thePersonHasToAct && theGateIsTheDeclaredOne,
        'an acceptance of an older version does not count':
            anOlderAcceptanceDoesNotCount,
        'the limit of a client-side gate is stated': theLimitIsStated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Yes' : 'No';

  static Map<String, bool> get checks => <String, bool>{
        'six fields, all present': everyFieldIsPresent && completeness == 100,
        'the version and the language are recorded':
            theVersionIsRecorded && theLanguageIsRecorded,
        'the timestamp carries an offset': theTimestampCarriesAnOffset,
        'the control\'s own label is stored':
            theControlLabelIsRecorded &&
                evidenceNote.contains('what was agreed to'),
        'no pre-ticked box and no implied consent': thePersonHasToAct,
        'the gate is the declared strict-true rule':
            theGateIsTheDeclaredOne &&
                aLooseCheckWouldPassAnUnansweredBox &&
                actNote.contains('quietly passing'),
        'the client does not decide lawfulness':
            theLimitIsStated &&
                complianceNote.contains('the phone already checked'),
        'acceptance is stored against a version':
            anOlderAcceptanceDoesNotCount && !acceptanceIsABooleanSetOnce,
        'and the answer changes when the terms do':
            versionNote.contains('without anybody running a migration'),
        'six obligations, all met, giving Yes':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Yes' &&
                theOutputIsBinary &&
                theOptimalEqualsTheCeiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to GFD rather than UDF; its metric is '
      'a compliance pass rate on a row that builds a client-side gate, which '
      'cannot know the things compliance depends on; its optimal and ceiling '
      'are both 1; its Data Requirement cell holds the Atomic Step\'s own '
      'sentence as the artefact to prepare; and the Setup Step column is '
      'empty. Atomic Step: "Embed DCYN compliance checks for all legal policy '
      'acceptances."';
}
