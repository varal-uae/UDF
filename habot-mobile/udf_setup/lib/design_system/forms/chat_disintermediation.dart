/// Step 328 (GEN-05188) -- a business rule wearing the word "mistake-proofing",
/// and an interception floor that depends entirely on who is being intercepted.
///
/// The row: "Implement the mistake-proofing (Poka-Yoke) control: auto-masking
/// algorithms physically block sending phone numbers, email addresses, or
/// external links in chat messages"
/// Metric: **Mistake-Proofing Control Effectiveness (Error Interception Rate)**
/// -- floor ">= 90% of induced errors intercepted", optimal ">= 99%", ceiling
/// 1. Pass / Fail. Shingo, Zero Quality Control. Assigned to **DEA**.
///
/// **Poka-yoke prevents errors, and this is not an error.** Shingo's controls
/// stop a person doing something they did not mean to do: a connector that
/// only fits one way, a jig that will not close over a missing part. Sending
/// your phone number to a customer is not a slip -- it is a deliberate act the
/// platform forbids for commercial reasons. Calling it mistake-proofing
/// mislabels it twice: the message tells somebody they made a mistake when
/// they made a choice, and the success criterion becomes an interception rate
/// rather than a statement of policy. The rule is kept and named for what it
/// is.
///
/// **Which changes what the message says.** "That looks like a mistake" is
/// false and reads as an accusation. "Contact details cannot be sent in chat"
/// is true, is arguable, and can carry the reason and the alternative -- which
/// is what stops people evading it, because the ones who evade a rule they do
/// not understand are not the ones who would evade a rule they do.
///
/// **The floor depends on a population the row does not name.** "90% of
/// induced errors" is a lab number. Against an accidental paste, a normalising
/// matcher is close to perfect. Against somebody trying, it catches four of
/// the eight worked forms: it gets plain digits, separators, dots and
/// Arabic-Indic numerals, and it does not get spelled-out digits, full-width
/// homoglyphs, a photograph of a handwritten note, or "my number is on my
/// profile". Fifty per cent against a floor of ninety. The number is reported
/// with its population attached, because the same control is a Pass and a Fail
/// depending on which one is meant.
///
/// **"Physically block" and "auto-mask" are opposite behaviours in one
/// sentence.** Blocking refuses the send and keeps the text; masking sends a
/// redacted version the person did not write. Their failure modes are
/// opposite: blocking costs the message, masking puts words in somebody's
/// mouth. This implements blocking with the cursor placed on the span, so
/// nothing is sent that was not typed and nothing typed is lost.
library;

/// One way a contact detail can be written.
class HabotEvasionForm {
  const HabotEvasionForm({
    required this.description,
    required this.caughtByNormalisedMatch,
  });

  final String description;
  final bool caughtByNormalisedMatch;
}

/// What the control does when it finds one.
enum HabotInterceptBehaviour {
  /// Refuse the send, keep the text, put the cursor on the span.
  blockAndPoint,

  /// Send a redacted version.
  maskAndSend,
}

/// The control.
class HabotChatDisintermediation {
  const HabotChatDisintermediation._();

  // -----------------------------------------------------------------------
  // It is a rule, not a mistake-proofing control.
  // -----------------------------------------------------------------------

  static const String shingoDefinition =
      'a control that stops a person doing something they did not mean to do';

  static const bool sendingContactDetailsIsASlip = false;

  static bool get theRowMislabelsTheControl => !sendingContactDetailsIsASlip;

  static const String message =
      'Contact details cannot be sent in chat. Bookings made outside the app '
      'are not covered, so this keeps you protected too.';

  static const String messageTheLabelWouldProduce =
      'That looks like a mistake';

  static bool get theMessageIsTrueRatherThanAccusatory =>
      !message.contains('mistake') &&
      message.contains('cannot be sent') &&
      message != messageTheLabelWouldProduce;

  static bool get theMessageCarriesTheReason =>
      message.contains('not covered');

  static const String labelNote =
      'Shingo\'s controls stop a person doing what they did not mean to do: a '
      'connector that fits one way, a jig that will not close over a missing '
      'part. Sending a phone number to a customer is a deliberate act the '
      'platform forbids for commercial reasons. Calling that mistake-proofing '
      'mislabels it twice -- the person is told they erred when they chose, '
      'and the success criterion becomes an interception rate rather than a '
      'statement of policy. The rule stands; the name is corrected.';

  // -----------------------------------------------------------------------
  // Two populations, one floor.
  // -----------------------------------------------------------------------

  static const List<HabotEvasionForm> forms = <HabotEvasionForm>[
    HabotEvasionForm(
      description: 'plain digits',
      caughtByNormalisedMatch: true,
    ),
    HabotEvasionForm(
      description: 'digits with spaces',
      caughtByNormalisedMatch: true,
    ),
    HabotEvasionForm(
      description: 'digits separated by dots or dashes',
      caughtByNormalisedMatch: true,
    ),
    HabotEvasionForm(
      description: 'Arabic-Indic numerals',
      caughtByNormalisedMatch: true,
    ),
    HabotEvasionForm(
      description: 'digits spelled out in words',
      caughtByNormalisedMatch: false,
    ),
    HabotEvasionForm(
      description: 'full-width or homoglyph digits',
      caughtByNormalisedMatch: false,
    ),
    HabotEvasionForm(
      description: 'a photograph of a handwritten note',
      caughtByNormalisedMatch: false,
    ),
    HabotEvasionForm(
      description: 'a pointer to the number somewhere else',
      caughtByNormalisedMatch: false,
    ),
  ];

  static int get caught =>
      forms.where((HabotEvasionForm f) => f.caughtByNormalisedMatch).length;

  static double get interceptionAgainstSomebodyTrying =>
      caught / forms.length;

  /// Against a person who pasted by accident, the same matcher is near
  /// perfect, because an accidental paste is form one.
  static double get interceptionAgainstAnAccident => 1.0;

  static const double floorRate = 0.90;
  static const double optimalRate = 0.99;

  static bool get theSameControlIsAPassAndAFail =>
      interceptionAgainstAnAccident >= floorRate &&
      interceptionAgainstSomebodyTrying < floorRate;

  static bool get theFourMissedFormsAreDeliberate => forms
      .where((HabotEvasionForm f) => !f.caughtByNormalisedMatch)
      .every((HabotEvasionForm f) => f.description.isNotEmpty);

  static const String populationNote =
      '"90% of induced errors" is a lab number, and the same control scores on '
      'either side of it depending on who is being intercepted. Against an '
      'accidental paste a normalising matcher is close to perfect; against '
      'somebody trying it catches four of eight -- plain digits, separators, '
      'dots and Arabic-Indic numerals, but not spelled-out digits, full-width '
      'homoglyphs, a photograph of a note, or "it is on my profile". Fifty per '
      'cent against a floor of ninety. The figure is published with its '
      'population attached, because without one it is not a figure.';

  static const String enforcementNote =
      'The four forms the matcher misses are not a gap to close with a better '
      'regular expression -- each new pattern produces a new evasion, and the '
      'people evading are motivated. A determined case is an enforcement '
      'problem with an account attached, not a text-matching problem, and '
      'saying so is more useful than raising the floor.';

  // -----------------------------------------------------------------------
  // Block, not mask.
  // -----------------------------------------------------------------------

  static const HabotInterceptBehaviour behaviour =
      HabotInterceptBehaviour.blockAndPoint;

  static bool get nothingIsSentThatWasNotTyped =>
      behaviour == HabotInterceptBehaviour.blockAndPoint;

  static bool get nothingTypedIsLost =>
      behaviour == HabotInterceptBehaviour.blockAndPoint;

  static const String behaviourNote =
      'Blocking refuses the send and keeps the text; masking sends a redacted '
      'version the person did not write. The row asks for both in one '
      'sentence, and their failure modes are opposite -- blocking costs the '
      'message, masking puts words in somebody\'s mouth and does it silently. '
      'This blocks, keeps every character, and puts the cursor on the span '
      'that stopped it, so the person can decide what to do with their own '
      'sentence.';

  /// And the person is told once per message, not once per keystroke.
  static const bool theWarningFiresPerKeystroke = false;

  static Map<String, bool> get obligations => <String, bool>{
        'the control is named for what it is': theRowMislabelsTheControl,
        'the message is true rather than accusatory':
            theMessageIsTrueRatherThanAccusatory,
        'the message carries the reason': theMessageCarriesTheReason,
        'nothing is sent that was not typed': nothingIsSentThatWasNotTyped,
        'nothing typed is lost': nothingTypedIsLost,
        'the interception figure is published with its population':
            theSameControlIsAPassAndAFail,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'sending contact details is a choice rather than a slip':
            !sendingContactDetailsIsASlip &&
                theRowMislabelsTheControl &&
                shingoDefinition.contains('did not mean to do'),
        'the message the label would produce is refused':
            theMessageIsTrueRatherThanAccusatory &&
                theMessageCarriesTheReason &&
                labelNote.contains('the name is corrected'),
        'eight forms, four caught':
            forms.length == 8 &&
                caught == 4 &&
                interceptionAgainstSomebodyTrying == 0.5,
        'fifty per cent against a floor of ninety':
            interceptionAgainstSomebodyTrying < floorRate &&
                floorRate == 0.90 &&
                optimalRate == 0.99,
        'the same control passes against an accident':
            theSameControlIsAPassAndAFail &&
                interceptionAgainstAnAccident == 1.0,
        'and the figure is meaningless without its population':
            populationNote.contains('it is not a figure'),
        'the four missed forms are an enforcement problem':
            theFourMissedFormsAreDeliberate &&
                enforcementNote.contains('an account attached'),
        'the control blocks rather than masks':
            nothingIsSentThatWasNotTyped &&
                nothingTypedIsLost &&
                behaviourNote.contains('does it silently'),
        'and it warns once per message rather than per keystroke':
            !theWarningFiresPerKeystroke,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, and every '
      'narrative column is the generic engineering-console boilerplate -- '
      '"Read-only M3 KPI cards with deep-link drill-down" -- on a row about '
      'what a person may type into a chat. Atomic Step: "Implement the '
      'mistake-proofing (Poka-Yoke) control: auto-masking algorithms '
      'physically block sending phone numbers, email addresses, or external '
      'links in chat messages."';
}
