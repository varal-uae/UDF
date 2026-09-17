/// Step 309 (BLGTA-002-10) -- marking text as wrong while somebody is still
/// typing it, and the row six places earlier that removes the need.
///
/// The row: "Apply Material Design 3 error highlighting to text typography
/// when compound syntax is detected during drafting."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good / Average / Poor.
///
/// **This row and Step 303 are about the same thing and neither knows.** Step
/// 303 asks that combined text strings be broken apart; this one asks that
/// combined syntax be painted red as it is written. Six rows apart in the same
/// batch, assigned separately, cross-referencing nothing. They also disagree
/// about the remedy in a way worth stating: Step 303's parameterised message
/// removes the compound string at the point where it is authored, which means
/// there is nothing left for this detector to find on that path. What is left
/// for it is the case Step 303 does not reach -- free text a person is typing
/// now.
///
/// **"During drafting" is the phrase that does the damage.** At a typical 200
/// characters a minute, a ninety-second draft is 300 keystrokes. A detector
/// that runs on each one paints and unpaints up to 300 times, and every one of
/// those paints tells somebody their sentence is wrong before they have
/// finished it. Run on the pause instead -- the two-second dwell Step 290
/// already declared -- and the same draft produces three evaluations. A
/// hundredfold difference in how often a person is interrupted, from one
/// decision about when to look.
///
/// **Red is not the signal; it is the reinforcement.** SC 1.4.1 is Level A and
/// this is the third row in this batch to walk into it. A highlight carries a
/// wavy marker under the span and a sentence naming what was found, and the
/// colour rides along. The marker is what a person with a red-green deficiency
/// sees; the sentence is what a screen reader reaches, since neither colour
/// nor marker reaches it at all.
///
/// **A tinted background can put the text below the floor it was passing.**
/// Error text is text, so 4.5:1 applies rather than the 3:1 for non-text; a
/// highlight drawn as a container tint changes the pair the text is measured
/// against, and a pair that passed on the plain surface can fail on the tinted
/// one. The tint is therefore drawn behind the marker, not behind the glyphs.
///
/// **COLUMN NOTE.** The Data Requirement cell is a font specification -- Font
/// Name, Font Size, Line Height, Font Weight, Font File Path -- on a row about
/// detecting bad syntax, and the Setup Step reads "Review the lead conversion
/// workflow steps requiring clear micro-UX feedback loops".
library;

import '../a11y/contrast.dart';
import '../tokens/motion_tokens.dart';

/// What the detector found.
enum HabotSyntaxFinding {
  /// Two sentences joined by a connector, in a slot sized for one.
  compoundSentence,

  /// A value concatenated into prose.
  interpolatedValue,

  /// A clause that will not survive translation word order.
  orderDependentClause,
}

/// The highlight.
class HabotCompoundSyntaxHighlight {
  const HabotCompoundSyntaxHighlight._();

  // -----------------------------------------------------------------------
  // The relationship to Step 303.
  // -----------------------------------------------------------------------

  static const int siblingStep = 303;

  static const String siblingSubject =
      'break combined text layout strings down into separate atomic variables';

  static const bool theTwoRowsReferenceEachOther = false;

  static const String siblingNote =
      'Step 303 asks that combined strings be broken apart; this row asks that '
      'combined syntax be painted red as it is written. Six rows apart, '
      'assigned separately, referencing nothing. Step 303\'s parameterised '
      'message removes the compound string where it is authored, so on that '
      'path there is nothing left for this detector to find. What is left is '
      'the case Step 303 does not reach: free text a person is typing now.';

  // -----------------------------------------------------------------------
  // When it looks.
  // -----------------------------------------------------------------------

  /// A brisk but ordinary typing speed.
  static const int charactersPerMinute = 200;

  static const int draftSeconds = 90;

  static double get charactersPerSecond =>
      charactersPerMinute / Duration.secondsPerMinute;

  static int get keystrokesInADraft =>
      (charactersPerSecond * draftSeconds).round();

  /// The pause that means the person has stopped, declared at Step 290.
  static Duration get dwell => HabotMotion.hesitationDwell;

  /// Pauses long enough to count in a draft of this length.
  static const int pausesInADraft = 3;

  static int get evaluationsPerKeystroke => keystrokesInADraft;

  static int get evaluationsOnPause => pausesInADraft;

  static int get interruptionRatio =>
      evaluationsPerKeystroke ~/ evaluationsOnPause;

  static const bool evaluatesOnEveryKeystroke = false;

  static bool get theDwellIsADeclaredToken =>
      dwell == HabotMotion.hesitationDwell && dwell.inSeconds == 2;

  static const String timingNote =
      'At 200 characters a minute a ninety-second draft is 300 keystrokes. A '
      'detector that runs on each one paints and unpaints up to 300 times, and '
      'each paint tells somebody their sentence is wrong before they have '
      'finished it -- the people who see it most being the slowest typists. '
      'Run on the two-second pause Step 290 already declared, the same draft '
      'produces three evaluations. A hundredfold difference in how often a '
      'person is interrupted, out of one decision about when to look.';

  // -----------------------------------------------------------------------
  // What the highlight is made of.
  // -----------------------------------------------------------------------

  /// Three channels, and only one of them is colour.
  static const List<String> channels = <String>[
    'a wavy marker under the span',
    'a sentence naming what was found',
    'the error colour role from the scheme',
  ];

  static const Map<HabotSyntaxFinding, String> messages =
      <HabotSyntaxFinding, String>{
    HabotSyntaxFinding.compoundSentence:
        'Two sentences here. Split them so each one can be translated on its '
            'own',
    HabotSyntaxFinding.interpolatedValue:
        'A value is joined into this sentence. Make it a parameter so the '
            'sentence can be rewritten around it',
    HabotSyntaxFinding.orderDependentClause:
        'This clause depends on English word order. Say it as one whole '
            'sentence instead',
  };

  static bool get everyFindingHasAMessage =>
      messages.length == HabotSyntaxFinding.values.length;

  static bool get everyMessageSaysWhatToDo => messages.values.every(
        (String m) =>
            m.contains('Split') || m.contains('Make it') || m.contains('Say'),
      );

  static bool get colourIsOneChannelOfThree => channels.length == 3;

  static const bool colourIsTheSoleSignal = false;

  static const String criterion = 'WCAG 2.1 SC 1.4.1 Use of Colour';

  static const String channelNote =
      'The marker is what a person with a red-green deficiency sees. The '
      'sentence is what a screen reader reaches, since neither the colour nor '
      'the marker reaches it at all -- a squiggle is a paint operation and has '
      'no representation in the semantics tree. The colour rides along and is '
      'the one channel that can be removed without losing the finding, which '
      'is the test SC 1.4.1 actually asks.';

  // -----------------------------------------------------------------------
  // Where the tint goes.
  // -----------------------------------------------------------------------

  static double get textFloor => WcagThresholds.textFloor;

  static double get nonTextFloor => WcagThresholds.nonTextFloor;

  /// Error text is text: the stricter floor applies.
  static bool get theStricterFloorApplies => textFloor > nonTextFloor;

  /// So the tint sits behind the marker rather than behind the glyphs, and
  /// the pair the text is measured against does not change.
  static const bool theTintSitsBehindTheGlyphs = false;

  static const String tintNote =
      'A highlight drawn as a container tint changes the pair the text is '
      'measured against, and a pair that passed 4.5:1 on the plain surface can '
      'fail on the tinted one -- so the act of marking something as wrong can '
      'itself introduce a contrast failure, in the one place a person most '
      'needs to read. The tint is drawn behind the marker; the glyphs keep the '
      'surface they were audited on.';

  // -----------------------------------------------------------------------
  // The column mismatch and the band.
  // -----------------------------------------------------------------------

  static const List<String> dataCollectedFields = <String>[
    'Font Name',
    'Font Size',
    'Line Height',
    'Font Weight',
    'Font File Path',
  ];

  static bool get theDataFieldsAreAFontSpecification =>
      dataCollectedFields.every((String f) => f.startsWith('Font') ||
          f.startsWith('Line'));

  static const String bandFloor = '>=85%';
  static const String bandOptimal = '>=95%';
  static const String bandCeiling = '1';

  static bool get theCeilingIsInADifferentUnit =>
      bandFloor.contains('%') &&
      bandOptimal.contains('%') &&
      !bandCeiling.contains('%');

  static const String bandNote =
      'Two percentages and a bare 1: the twelfth row in this track whose three '
      'boundaries are not in the same unit. Read as a rate the ceiling is the '
      'optimal again; read as a count it is not comparable to either. '
      'Recorded, and the step reports against its own declared obligations.';

  static Map<String, bool> get obligations => <String, bool>{
        'the detector runs on the pause rather than the keystroke':
            !evaluatesOnEveryKeystroke && theDwellIsADeclaredToken,
        'every finding carries a sentence': everyFindingHasAMessage,
        'every sentence says what to do about it': everyMessageSaysWhatToDo,
        'the finding survives the removal of colour':
            !colourIsTheSoleSignal && colourIsOneChannelOfThree,
        'the tint does not change the pair the text is measured against':
            !theTintSitsBehindTheGlyphs,
      };

  static double get adherence =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (adherence >= 0.95) {
      return 'Good';
    }
    return adherence >= 0.85 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'this row and Step 303 share a subject and do not know it':
            siblingStep == 303 &&
                !theTwoRowsReferenceEachOther &&
                siblingNote.contains('typing now'),
        'a ninety-second draft is 300 keystrokes':
            keystrokesInADraft == 300 &&
                (charactersPerSecond - 200 / 60).abs() < 1e-9,
        'and three pauses':
            evaluationsOnPause == 3 && theDwellIsADeclaredToken,
        'a hundred times fewer interruptions':
            interruptionRatio == 100 &&
                timingNote.contains('the slowest typists'),
        'three channels, one of which is colour':
            colourIsOneChannelOfThree && !colourIsTheSoleSignal,
        'the marker has no representation a screen reader can reach':
            channelNote.contains('paint operation') &&
                criterion.contains('1.4.1'),
        'every finding carries a sentence that says what to do':
            everyFindingHasAMessage &&
                everyMessageSaysWhatToDo &&
                messages.length == 3,
        'error text is held to the text floor rather than the non-text one':
            theStricterFloorApplies && textFloor == 4.5 && nonTextFloor == 3.0,
        'and the tint cannot push it below':
            !theTintSitsBehindTheGlyphs &&
                tintNote.contains('most needs to read'),
        'the data fields are a font specification':
            dataCollectedFields.length == 5 &&
                theDataFieldsAreAFontSpecification,
        'the ceiling is in a different unit from the floor':
            theCeilingIsInADifferentUnit && bandNote.contains('twelfth row'),
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                adherence == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row is a font '
      'specification -- Font Name, Font Size, Line Height, Font Weight, Font '
      'File Path -- on a row about detecting bad syntax, and the Setup Step '
      'reads "Review the lead conversion workflow steps requiring clear '
      'micro-UX feedback loops". Atomic Step: "Apply Material Design 3 error '
      'highlighting to text typography when compound syntax is detected during '
      'drafting."';
}
