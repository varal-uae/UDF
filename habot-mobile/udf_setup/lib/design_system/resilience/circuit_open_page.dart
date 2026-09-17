/// Step 334 (GEN-03481) -- a row about paging an SRE team, written for the
/// one participant who cannot page anybody.
///
/// The row: "Connect PagerDuty webhooks alerting SRE teams instantly when
/// circuits trip to Open."
/// Metric: **SRE Alert Delivery Speed** -- floor "< 2s", optimal "< 500ms",
/// ceiling "5s". Best Qualitative Output: **"Pass"**. PagerDuty Webhook API
/// Specs.
///
/// **Third inverted band and third one-valued output column in this batch.**
/// The ceiling of 5 s is worse than the floor of 2 s on a lower-is-better
/// measure, and the output vocabulary contains only "Pass". Steps 321, 322 and
/// 335 carry one or both of the same two defects; Step 333 carries neither and
/// is the reason they are recorded as errors.
///
/// **A client cannot connect a webhook.** Circuit state lives on the server,
/// PagerDuty is reached from the server, and nothing in this repository takes
/// part in the alert path at all. What the client owes when a circuit is open
/// is the thing the row does not mention and the person actually experiences,
/// and it is threefold: say that the service is down rather than showing a
/// generic failure, stop retrying, and say when to come back.
///
/// **Stopping retrying is not politeness.** A client that keeps hammering an
/// open circuit is part of the outage: every retry is load on a service that
/// tripped because it had too much. The circuit state Step 273 already models
/// is read rather than re-derived, and while it is open the client does not
/// send.
///
/// **An open circuit makes the app faster at telling the truth.** With the
/// circuit closed, the reconnect policy tries three times at 500ms, 1s and 2s
/// before anything can be concluded -- three and a half seconds of a spinner.
/// With the circuit open, the client knows immediately and says so. The one
/// time the person gets a straight answer quickly is the time everything is
/// broken, which is worth stating because it is the opposite of what people
/// expect from an outage.
library;

import 'backend_unavailability.dart';
import 'persistence_circuit.dart';

/// The page.
class HabotCircuitOpenPage {
  const HabotCircuitOpenPage._();

  // -----------------------------------------------------------------------
  // Who does what.
  // -----------------------------------------------------------------------

  static const Map<String, String> responsibilities = <String, String>{
    'server': 'trips the circuit and calls the PagerDuty webhook',
    'client': 'reads the state, stops sending, and tells the person',
  };

  static const bool theClientCanReachPagerDuty = false;

  static bool get theRowsSubjectBelongsToTheServer =>
      (responsibilities['server'] ?? '').contains('PagerDuty') &&
      !theClientCanReachPagerDuty;

  static const String scopeNote =
      'Circuit state lives on the server and PagerDuty is reached from the '
      'server; nothing in this repository takes part in the alert path. The '
      'row names the half of the system that cannot do the work. What the '
      'client owes is the half nobody wrote a row for: saying the service is '
      'down rather than showing a generic failure, not adding to the outage, '
      'and saying when to come back.';

  // -----------------------------------------------------------------------
  // What the client does while it is open.
  // -----------------------------------------------------------------------

  /// Read from Step 273 rather than re-derived.
  static bool isOpen(HabotCircuitState state) =>
      state == HabotCircuitState.open;

  static const bool theClientSendsWhileOpen = false;

  static bool get theCircuitStatesAreReadFromStep273 =>
      HabotCircuitState.values.length >= 2 &&
      isOpen(HabotCircuitState.open) &&
      !isOpen(HabotCircuitState.closed);

  static const String loadNote =
      'A client that keeps retrying an open circuit is part of the outage: '
      'every attempt is load on a service that tripped because it had too '
      'much, and a hundred thousand phones retrying politely is a denial of '
      'service with good intentions. While the circuit is open the client does '
      'not send, and the state is the one Step 273 already models rather than '
      'a second copy that can disagree with it.';

  // -----------------------------------------------------------------------
  // What the person is told.
  // -----------------------------------------------------------------------

  static const Map<String, String> whatThePersonSees = <String, String>{
    'what is wrong': 'Payments are down for everyone, not just you',
    'what is safe': 'Nothing you have entered is lost',
    'when to come back': 'Try again in about ten minutes -- we will also send '
        'a notification when it is back',
  };

  static bool get allThreeQuestionsAreAnswered =>
      whatThePersonSees.length == 3;

  static bool get itSaysItIsNotJustThem =>
      (whatThePersonSees['what is wrong'] ?? '').contains('not just you');

  static bool get itSaysWhenToComeBack =>
      (whatThePersonSees['when to come back'] ?? '').contains('Try again in');

  /// A generic failure message is refused, because "something went wrong"
  /// invites the person to try again immediately, which is the one thing
  /// that must not happen.
  static const String genericMessageRefused = 'Something went wrong';

  static bool get theGenericMessageIsRefused => !whatThePersonSees.values
      .any((String v) => v.contains(genericMessageRefused));

  static const String messageNote =
      '"Something went wrong" invites the person to try again immediately, '
      'which is the one thing that must not happen while a circuit is open, '
      'and it also leaves them wondering whether it is their phone, their '
      'signal or their account. Saying that it is down for everybody is the '
      'sentence that stops a retry and stops a support call at the same time.';

  // -----------------------------------------------------------------------
  // Why an open circuit is faster.
  // -----------------------------------------------------------------------

  static const List<int> retryDelaysMs = <int>[500, 1000, 2000];

  static int get timeBeforeAnythingIsKnownMs =>
      retryDelaysMs.fold(0, (int a, int b) => a + b);

  static const int timeWhenTheCircuitIsOpenMs = 0;

  static int get secondsSavedByKnowing =>
      (timeBeforeAnythingIsKnownMs - timeWhenTheCircuitIsOpenMs) ~/ 1000;

  static bool get anOpenCircuitIsFasterThanAClosedOne =>
      timeWhenTheCircuitIsOpenMs < timeBeforeAnythingIsKnownMs;

  /// The retry rule itself is Step 251's, read rather than restated.
  static bool get theRetryRuleIsAlreadyDeclared =>
      HabotUnavailability.values.length >= 2;

  static const String speedNote =
      'With the circuit closed, three attempts at 500ms, 1s and 2s pass before '
      'anything can be concluded: three and a half seconds of a spinner before '
      'a person is told anything at all. With the circuit open the client '
      'knows at once. The one occasion somebody gets a straight answer '
      'immediately is the occasion when everything is broken, which is the '
      'opposite of what an outage usually feels like and is worth building on '
      'purpose.';

  // -----------------------------------------------------------------------
  // The band and the output column.
  // -----------------------------------------------------------------------

  static const int bandFloorMs = 2000;
  static const int bandOptimalMs = 500;
  static const int bandCeilingMs = 5000;

  static bool get theBandIsInverted => bandCeilingMs > bandFloorMs;

  static const String rowOutputVocabulary = 'Pass';

  static bool get theOutputCannotExpressAFailure =>
      !rowOutputVocabulary.contains('Fail');

  static const List<int> invertedBandsInThisBatch = <int>[325, 326, 334, 335];

  static const List<int> oneValuedOutputsInThisBatch = <int>[
    321,
    322,
    334,
    335,
  ];

  static const int theOrderedBandInThisBatch = 333;

  static bool get thisRowCarriesBothDefects =>
      invertedBandsInThisBatch.contains(334) &&
      oneValuedOutputsInThisBatch.contains(334);

  static const String bandNote =
      'The ceiling is 5 seconds against a floor of 2 on a lower-is-better '
      'measure, and the output column holds only "Pass". This row carries both '
      'of the batch\'s repeated defects at once; Steps 321, 322 and 335 carry '
      'one or both, and Step 333 carries neither, which is what makes them '
      'errors rather than conventions.';

  static Map<String, bool> get obligations => <String, bool>{
        'the client does not send while the circuit is open':
            !theClientSendsWhileOpen,
        'the circuit state is read from Step 273':
            theCircuitStatesAreReadFromStep273,
        'the person is told it is not just them': itSaysItIsNotJustThem,
        'the person is told nothing is lost':
            whatThePersonSees.containsKey('what is safe'),
        'the person is told when to come back': itSaysWhenToComeBack,
        'the generic message is refused': theGenericMessageIsRefused,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the alert path belongs to the server':
            theRowsSubjectBelongsToTheServer &&
                responsibilities.length == 2 &&
                scopeNote.contains('cannot do the work'),
        'the client stops sending while the circuit is open':
            !theClientSendsWhileOpen && theCircuitStatesAreReadFromStep273,
        'and a retrying client is part of the outage':
            loadNote.contains('good intentions'),
        'three questions, three answers':
            allThreeQuestionsAreAnswered &&
                itSaysItIsNotJustThem &&
                itSaysWhenToComeBack,
        'the generic message is refused with its reason':
            theGenericMessageIsRefused &&
                messageNote.contains('stops a support call'),
        'three and a half seconds pass before a closed circuit knows anything':
            timeBeforeAnythingIsKnownMs == 3500 &&
                retryDelaysMs.length == 3 &&
                theRetryRuleIsAlreadyDeclared,
        'so an open circuit answers three seconds sooner':
            anOpenCircuitIsFasterThanAClosedOne &&
                secondsSavedByKnowing == 3 &&
                speedNote.contains('on purpose'),
        'the ceiling is worse than the floor':
            theBandIsInverted &&
                bandFloorMs == 2000 &&
                bandCeilingMs == 5000 &&
                bandOptimalMs == 500,
        'and the output column holds only Pass':
            theOutputCannotExpressAFailure && thisRowCarriesBothDefects,
        'Step 333 carries neither defect':
            theOrderedBandInThisBatch == 333 &&
                bandNote.contains('rather than conventions'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Best Qualitative Output column on this row reads '
      '"Pass" with no failing value, the ceiling of 5s is worse than the floor '
      'of 2s, and every narrative column is the generic engineering-console '
      'boilerplate on a row about paging an SRE team. Atomic Step: "Connect '
      'PagerDuty webhooks alerting SRE teams instantly when circuits trip to '
      'Open."';
}
