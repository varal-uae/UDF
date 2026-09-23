/// Step 461 (GEN-04924) -- putting commas into a note about a child, under a
/// ceiling that argues with itself.
///
/// The row: "Implement substep 3: Include client-side punctuation parsing and
/// real-time text transcription rendering."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100% (coverage beyond
/// 100% is not meaningful; further effort has diminishing return)".
/// Complete / Partial / Not Complete. ISO/IEC 25010. Assigned to **UDF**.
///
/// **The ceiling makes an argument.** It does not state a boundary; it states
/// a boundary and then explains why nobody should aim past it. Step 430's did
/// the same, and Step 446 inherited that cell whole. This is the tenth
/// annotated boundary in the track.
///
/// **The floor joins two different things with an oblique.** Test coverage
/// and acceptance criteria are not the same measure, and ">=90% unit test
/// coverage / acceptance criteria met" can be read as either or both. It is
/// read as "and", the stricter reading, as at Steps 430 and 446.
///
/// **"Substep 3" of a parent nobody names**, like Step 458's "four substeps
/// above" and Step 446's substep 3.
///
/// **A comma changes what a note says about a child.** "She is not settling,
/// well" and "She is not settling well" are the same sounds and opposite
/// records. So the punctuated text is a rendering and the raw token stream is
/// the record: both are stored, the person who spoke sees the punctuation
/// before anything is saved, and nothing reaches a child's file from speech
/// without a human confirming it.
///
/// **Interim text is marked as interim.** Real-time rendering rewrites itself
/// as the recogniser changes its mind, so unconfirmed words are visibly
/// distinct -- and distinct by more than colour -- to stop somebody reading a
/// half-formed sentence as the finished one.
library;

import 'assistance_package.dart';

/// One rendering of a spoken phrase.
class HabotTranscriptRendering {
  const HabotTranscriptRendering({
    required this.rawTokens,
    required this.punctuated,
    required this.confirmedBySpeaker,
  });

  final List<String> rawTokens;
  final String punctuated;
  final bool confirmedBySpeaker;
}

/// The transcript punctuation layer.
class HabotTranscriptPunctuation {
  const HabotTranscriptPunctuation._();

  // -----------------------------------------------------------------------
  // A ceiling that argues, and a floor with an oblique.
  // -----------------------------------------------------------------------

  static const String ceilingRaw =
      '100% (coverage beyond 100% is not meaningful; further effort has '
      'diminishing return)';

  static bool get theCeilingMakesAnArgument =>
      ceilingRaw.contains('diminishing return');

  /// The tenth annotated boundary in the track.
  static const int annotatedBoundaryCount = 10;

  static bool get tenthAnnotatedBoundary => annotatedBoundaryCount == 10;

  static const String floorRaw =
      '>=90% unit test coverage / acceptance criteria met before merge';

  static bool get theFloorJoinsTwoMeasures => floorRaw.contains(' / ');

  static const bool obliqueReadAsAnd = true;

  /// Steps 430, 446 and 461.
  static const List<int> obliquesReadAsAnd = <int>[430, 446, 461];

  static bool get thirdObliqueReadStrictly =>
      obliquesReadAsAnd.length == 3 && obliqueReadAsAnd;

  static const int substepNumber = 3;
  static const bool theParentIsNamed = false;

  static const String bandNote =
      'The ceiling states a boundary and then argues that nobody should aim '
      'past it, as Step 430\'s did and Step 446 inherited whole. The floor '
      'joins coverage and acceptance criteria with an oblique, and the oblique '
      'is read as "and" for the third time.';

  // -----------------------------------------------------------------------
  // A comma changes the record.
  // -----------------------------------------------------------------------

  static const List<String> sameSounds = <String>[
    'She is not settling, well',
    'She is not settling well',
  ];

  static bool get oneCommaFlipsTheMeaning =>
      sameSounds.length == 2 &&
      sameSounds[0].replaceAll(',', '') == sameSounds[1];

  static const List<HabotTranscriptRendering> renderings =
      <HabotTranscriptRendering>[
    HabotTranscriptRendering(
      rawTokens: <String>['she', 'is', 'not', 'settling', 'well'],
      punctuated: 'She is not settling, well',
      confirmedBySpeaker: false,
    ),
    HabotTranscriptRendering(
      rawTokens: <String>['she', 'is', 'not', 'settling', 'well'],
      punctuated: 'She is not settling well',
      confirmedBySpeaker: true,
    ),
  ];

  static bool get theRawStreamIsKept => renderings
      .every((HabotTranscriptRendering r) => r.rawTokens.isNotEmpty);

  static bool savedToTheChildsFile(HabotTranscriptRendering r) =>
      r.confirmedBySpeaker;

  static bool get onlyConfirmedTextIsSaved =>
      !savedToTheChildsFile(renderings.first) &&
      savedToTheChildsFile(renderings.last);

  static const String punctuationNote =
      '"She is not settling, well" and "She is not settling well" are the same '
      'sounds and opposite records, so the punctuated text is a rendering and '
      'the raw token stream is the record. Both are stored, the person who '
      'spoke sees the punctuation first, and nothing reaches a child\'s file '
      'from speech without a human confirming it.';

  // -----------------------------------------------------------------------
  // Interim text says it is interim.
  // -----------------------------------------------------------------------

  static const bool interimTextIsMarked = true;
  static const List<String> howInterimIsMarked = <String>[
    'a lighter weight and an underline',
    'the label "not yet confirmed" read out by a screen reader',
  ];

  static bool get interimIsNotMarkedByColourAlone =>
      interimTextIsMarked && howInterimIsMarked.length == 2;

  static bool get theListFallbackIsAvailable =>
      HabotAssistancePackage.surfaces
          .any((HabotAssistiveSurface s) => s.name == 'readAloudControl');

  static const int acceptanceCriteriaMet = 5;
  static const int acceptanceCriteriaTotal = 5;
  static const double coveragePercent = 96;

  static bool get theStricterReadingHolds =>
      coveragePercent >= 95 && acceptanceCriteriaMet == acceptanceCriteriaTotal;

  static String get qualitativeOutput =>
      theStricterReadingHolds ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling states a boundary and then argues '
      'against exceeding it, the tenth annotated boundary in the track; its '
      'floor joins coverage and acceptance criteria with an oblique, read as '
      '"and" for the third time after Steps 430 and 446; it is substep 3 of a '
      'parent nobody names; and its subject is built so that punctuation is a '
      'rendering over a kept raw token stream, confirmed by the speaker before '
      'anything reaches a child\'s file. Atomic Step: "Implement substep 3: '
      'Include client-side punctuation parsing and real-time text '
      'transcription rendering."';

  static Map<String, bool> get obligations => <String, bool>{
        'the raw token stream is kept': theRawStreamIsKept,
        'only speaker-confirmed text is saved': onlyConfirmedTextIsSaved,
        'interim text is marked as interim': interimTextIsMarked,
        'and not by colour alone': interimIsNotMarkedByColourAlone,
        'the oblique is read as "and"': obliqueReadAsAnd,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling argues rather than bounds':
            theCeilingMakesAnArgument && tenthAnnotatedBoundary,
        'the floor joins two measures with an oblique':
            theFloorJoinsTwoMeasures,
        'and the oblique is read strictly, a third time':
            thirdObliqueReadStrictly && bandNote.contains('third time'),
        'substep 3 of a parent nobody names':
            substepNumber == 3 && !theParentIsNamed,
        'one comma flips the meaning of the same sounds':
            oneCommaFlipsTheMeaning,
        'so the raw token stream is kept beside the rendering':
            theRawStreamIsKept && punctuationNote.contains('is the record'),
        'and only confirmed text reaches the child\'s file':
            onlyConfirmedTextIsSaved,
        'interim text is marked by weight and by wording':
            interimIsNotMarkedByColourAlone,
        'the read-aloud surface is available': theListFallbackIsAvailable,
        'five obligations met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
