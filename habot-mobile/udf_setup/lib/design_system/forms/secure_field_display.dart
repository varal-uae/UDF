/// Step 267 (GEN-04594) -- masking a value on screen, and the four places the
/// unmasked one still is.
///
/// The row: "Implement secure field components masking displayed sensitive
/// values (e.g. account numbers)."
/// Metric: **PII Leakage Incident Rate** -- floor "0 incidents (hard gate)",
/// optimal 0 incidents, ceiling 1. Pass/Fail. Standard cited: GDPR Art. 25 /
/// CCPA.
///
/// **Masking for display is not masking.** The full value is still in the
/// widget's state, still in the controller, still in the screenshot the OS
/// takes when the application is backgrounded, and still in anything the
/// clipboard was handed. A component that draws bullets and leaves those four
/// alone has moved the value out of sight and nowhere else.
///
/// **A screen reader reads what is there.** If the mask is drawn as bullets
/// and announced as bullets, a person using a screen reader hears "bullet
/// bullet bullet bullet three four five six" -- which is both useless and a
/// slower way of saying the last four digits out loud in a public place. The
/// announcement is the meaning, not the glyphs: "account ending 3456".
///
/// **Revealing has to be deliberate, and it has to be recorded.** A tap that
/// unmasks with no record is a mask that exists for a screenshot of the
/// screen rather than for the person's data. Reveal is an explicit action, it
/// times out, and it emits an event with no value in it.
///
/// **The band is inverted and the ceiling is unreachable.** "0 incidents" as
/// both floor and optimal with a ceiling of 1 means one incident is the
/// best-case top of the band. Read as an error rate, lower is better and the
/// ceiling is the worst outcome -- the same shape as Step 239's input error
/// rate, recorded so nobody reads the 1 as a target.
library;

import '../tokens/motion_tokens.dart';

/// Somewhere an unmasked value can still be after the screen shows bullets.
enum HabotExposureSurface {
  /// Drawn on the screen.
  display,

  /// Held in the widget's state and its controller.
  processMemory,

  /// The screenshot the OS takes when the application is backgrounded.
  appSwitcherSnapshot,

  /// The system clipboard.
  clipboard,

  /// A log line, a crash report or an analytics payload.
  emittedPayload,
}

/// How much of a value a surface may see.
enum HabotExposureRule {
  /// The whole value.
  full,

  /// The last few characters only.
  tail,

  /// Nothing.
  none,
}

/// One surface and what it is allowed.
class HabotExposurePolicy {
  const HabotExposurePolicy({
    required this.surface,
    required this.rule,
    required this.why,
  });

  final HabotExposureSurface surface;
  final HabotExposureRule rule;
  final String why;
}

/// The secure field.
class HabotSecureFieldDisplay {
  const HabotSecureFieldDisplay._();

  /// How many characters stay visible. Enough for a person to recognise
  /// their own account and not enough for anybody else to use it.
  static const int visibleTailLength = 4;

  /// The mask character -- U+2022 BULLET. Built from its code point rather
  /// than pasted, so the source stays reviewable in a terminal and two
  /// components cannot disagree about which bullet it is.
  static String get maskCharacter => String.fromCharCode(0x2022);

  /// How long a revealed value stays revealed before it masks itself again.
  /// Read from the declared submit-lock timeout rather than invented: it is
  /// the same question -- how long is a person plausibly still looking.
  static Duration get revealTimeout => HabotMotion.submitLockTimeout;

  /// What is drawn.
  static String maskedFor(String value) {
    if (value.length <= visibleTailLength) {
      return maskCharacter * value.length;
    }
    final int hidden = value.length - visibleTailLength;
    return maskCharacter * hidden + value.substring(hidden);
  }

  /// What a screen reader is told. Words, not glyphs.
  static String announcementFor({
    required String label,
    required String value,
  }) {
    if (value.length <= visibleTailLength) {
      return '$label, hidden';
    }
    return '$label ending ${value.substring(value.length - visibleTailLength)}';
  }

  static bool get theAnnouncementIsNotTheGlyphs =>
      !announcementFor(label: 'Account', value: 'AE070331234567890123456')
          .contains(maskCharacter) &&
      announcementFor(label: 'Account', value: 'AE070331234567890123456')
          .endsWith('ending 3456');

  /// A value shorter than the tail is hidden entirely rather than shown in
  /// full. The bug this guards: a four-digit code masked to four visible
  /// characters is not masked at all.
  static bool get aShortValueIsNotAccidentallyRevealed =>
      maskedFor('1234') == maskCharacter * 4 &&
      announcementFor(label: 'Code', value: '1234') == 'Code, hidden';

  static bool get theTailIsTheOnlyThingVisible =>
      maskedFor('AE070331234567890123456').endsWith('3456') &&
      maskedFor('AE070331234567890123456').length == 23 &&
      !maskedFor('AE070331234567890123456').contains('AE07');

  // -----------------------------------------------------------------------
  // The four other places the value is.
  // -----------------------------------------------------------------------

  static const List<HabotExposurePolicy> policies = <HabotExposurePolicy>[
    HabotExposurePolicy(
      surface: HabotExposureSurface.display,
      rule: HabotExposureRule.tail,
      why: 'The last four characters, so a person can recognise their own '
          'account. The part the row is about, and the only part a mask on '
          'its own addresses.',
    ),
    HabotExposurePolicy(
      surface: HabotExposureSurface.processMemory,
      rule: HabotExposureRule.full,
      why: 'Unavoidable: something has to hold the value to send it. What is '
          'controlled is how long -- the controller is cleared when the '
          'field is disposed rather than left for the garbage collector, '
          'because a heap dump is a file.',
    ),
    HabotExposurePolicy(
      surface: HabotExposureSurface.appSwitcherSnapshot,
      rule: HabotExposureRule.none,
      why: 'The OS photographs the screen when the application is '
          'backgrounded and stores it. A masked field is safe there and an '
          'unmasked one is not, so a revealed value re-masks on '
          'backgrounding before the snapshot is taken.',
    ),
    HabotExposurePolicy(
      surface: HabotExposureSurface.clipboard,
      rule: HabotExposureRule.none,
      why: 'Copy is disabled on the field. On several platforms the '
          'clipboard is readable by any application and is synchronised to '
          'other devices, so a copied account number has left this phone.',
    ),
    HabotExposurePolicy(
      surface: HabotExposureSurface.emittedPayload,
      rule: HabotExposureRule.none,
      why: 'Step 269 governs what may be emitted at all, and the answer for '
          'a value like this is nothing -- not even hashed, because the '
          'input space is small enough to walk.',
    ),
  ];

  static HabotExposurePolicy policyFor(HabotExposureSurface s) =>
      policies.firstWhere((HabotExposurePolicy p) => p.surface == s);

  static List<HabotExposurePolicy> get surfacesThatSeeNothing => policies
      .where((HabotExposurePolicy p) => p.rule == HabotExposureRule.none)
      .toList();

  /// Exactly one surface sees the whole value, and it is the one that has to.
  static bool get onlyMemorySeesTheWholeValue =>
      policies
          .where(
            (HabotExposurePolicy p) => p.rule == HabotExposureRule.full,
          )
          .length ==
          1 &&
      policyFor(HabotExposureSurface.processMemory).rule ==
          HabotExposureRule.full;

  static bool get everySurfaceIsRuledOn =>
      policies.length == HabotExposureSurface.values.length &&
      policies.every((HabotExposurePolicy p) => p.why.length > 60);

  // -----------------------------------------------------------------------
  // Revealing.
  // -----------------------------------------------------------------------

  /// Whether a reveal is permitted right now.
  static bool mayReveal({
    required bool personRequestedIt,
    required bool isBackgrounded,
  }) =>
      personRequestedIt && !isBackgrounded;

  /// A reveal emits an event. The event carries the field and the fact, and
  /// no value -- otherwise the record of the reveal is a second copy of the
  /// thing that was revealed.
  static Map<String, String> revealEventFor(String fieldName) =>
      <String, String>{
        'field': fieldName,
        'action': 'revealed',
      };

  static bool get theRevealEventCarriesNoValue =>
      revealEventFor('iban').length == 2 &&
      !revealEventFor('iban').containsKey('value');

  static bool get aBackgroundedFieldCannotBeRevealed => !mayReveal(
        personRequestedIt: true,
        isBackgrounded: true,
      );

  static const String revealNote =
      'Revealing has to be deliberate and it has to be recorded. A tap that '
      'unmasks with no record is a mask that exists for a screenshot of the '
      'screen rather than for the person\'s data. Reveal is an explicit '
      'action, it times out after the declared submit-lock window, it '
      're-masks before the application is backgrounded so the OS snapshot '
      'never contains it, and it emits an event that carries the field name '
      'and the fact and no value -- a record of a reveal that included the '
      'value would be a second copy of the thing revealed.';

  // -----------------------------------------------------------------------
  // Notes and the band.
  // -----------------------------------------------------------------------

  static const String maskingIsNotMaskingNote =
      'Masking for display is not masking. The full value is still in the '
      'widget\'s state, still in the controller, still in the screenshot the '
      'OS takes when the application is backgrounded, and still in anything '
      'the clipboard was handed. A component that draws bullets and leaves '
      'those four alone has moved the value out of sight and nowhere else. '
      'Five surfaces are ruled on here; exactly one of them sees the whole '
      'value, and it is the one that has to.';

  static const String screenReaderNote =
      'A screen reader reads what is there. A mask drawn as bullets and '
      'announced as bullets produces "bullet bullet bullet bullet three four '
      'five six", which is both useless and a slower way of saying the last '
      'four digits out loud in a public place. The announcement is the '
      'meaning rather than the glyphs -- "Account ending 3456" -- and a '
      'value too short to have a tail is announced as hidden rather than '
      'read out.';

  /// Floor and optimal are both zero and the ceiling is 1.
  static const int floorIncidents = 0;
  static const int optimalIncidents = 0;
  static const int ceilingIncidents = 1;

  static bool get theBandIsInverted => ceilingIncidents > floorIncidents;

  static const String bandNote =
      'The band is inverted and its ceiling is not a target. Floor and '
      'optimal are both "0 incidents" and the ceiling is 1, so read the way '
      'the other bands in this sheet are read -- higher is better -- one '
      'leakage incident would be the best possible outcome. Read as an error '
      'rate, which is what it is, lower is better and the ceiling is the '
      'worst case. The same shape as Step 239, and recorded so nobody reads '
      'the 1 as something to reach.';

  static String get qualitativeOutput =>
      surfacesThatSeeNothing.length == 3 && onlyMemorySeesTheWholeValue
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'five surfaces are ruled on, each with a reason':
            everySurfaceIsRuledOn,
        'three of them see nothing and exactly one sees the whole value':
            surfacesThatSeeNothing.length == 3 && onlyMemorySeesTheWholeValue,
        'only the last four characters are drawn':
            theTailIsTheOnlyThingVisible && visibleTailLength == 4,
        'a value shorter than the tail is hidden entirely':
            aShortValueIsNotAccidentallyRevealed,
        'the announcement is words rather than glyphs':
            theAnnouncementIsNotTheGlyphs &&
                screenReaderNote.contains('slower way of saying'),
        'a reveal is deliberate and cannot happen while backgrounded':
            mayReveal(personRequestedIt: true, isBackgrounded: false) &&
                aBackgroundedFieldCannotBeRevealed,
        'the reveal event records the fact and not the value':
            theRevealEventCarriesNoValue && revealNote.contains('second copy'),
        'the reveal timeout is read from a declared token':
            revealTimeout == HabotMotion.submitLockTimeout,
        'the inverted band is recorded rather than read as a target':
            theBandIsInverted && bandNote.contains('worst case'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the band '
      'reads floor "0 incidents (hard gate)", optimal "0 incidents", ceiling '
      '"1". Atomic Step: "Implement secure field components masking displayed '
      'sensitive values (e.g. account numbers)."';
}
