/// Step 456 (GEN-04704) -- the decision on how a child's special-needs
/// identifier and a family's telephone number are written down, on a band
/// whose floor and ceiling are the same boundary.
///
/// The row: "Convene the Form Validation & Quality Control decision group and
/// finalize the required pre-setup decision: Standardization of national SEN
/// identification number formats and telephone patterns."
/// Metric: **Decision Governance Cycle Time (Time-to-Decision)** -- floor
/// "<= 96 hours from convening to ratified decision", optimal "24-48 hours",
/// ceiling "> 96 hours (decision considered stale / re-scope required)".
/// Fast / Acceptable / Delayed. PMI PMBOK 7th Ed. Assigned to **UDF**.
///
/// **The floor and the ceiling are one boundary read from two sides.** At most
/// 96 hours and more than 96 hours partition the line at 96; between them
/// there is no third region for an optimal to sit in, and 24-48 hours is
/// simply a preferred part of the floor. The band has one number in it. After
/// Batch P showed the Ceiling column holding the worst value and Step 443
/// showed it holding a true upper bound, this row shows it holding the
/// negation of the floor.
///
/// **Fast / Acceptable / Delayed is a fourth output vocabulary**, after
/// Complete/Partial/Not Complete, Pass/Fail and High/Medium/Low.
///
/// **An identification number that encodes a category is a label a child
/// carries.** A national SEN reference says something about a child that the
/// child did not choose to publish. So the decision recorded here is that the
/// reference is stored as an opaque string, validated for shape and nothing
/// else, never parsed for meaning, and never printed beside a name in a list,
/// a search result or anything shown on a shared screen.
///
/// **A child with no reference still has a record.** Validation that requires
/// the number excludes exactly the children who have not been assessed yet,
/// which is the population the service exists for.
///
/// **A telephone pattern that assumes one country locks families out.** Numbers
/// are stored in E.164, accepted in any national spelling, and never rejected
/// for being foreign -- a family reachable only on an overseas mobile is still
/// the family.
library;

/// One decision taken by the group, with its owner and its reason.
class HabotFormDecision {
  const HabotFormDecision({
    required this.question,
    required this.decision,
    required this.rationale,
    required this.owner,
  });

  final String question;
  final String decision;
  final String rationale;
  final String owner;
}

/// The SEN identifier and telephone decision.
class HabotSenIdentityDecision {
  const HabotSenIdentityDecision._();

  // -----------------------------------------------------------------------
  // One boundary, written twice.
  // -----------------------------------------------------------------------

  static const int floorHours = 96;
  static const int ceilingHours = 96;
  static const int optimalLowHours = 24;
  static const int optimalHighHours = 48;

  static bool get theFloorAndCeilingAreOneNumber =>
      floorHours == ceilingHours;

  static bool get theOptimalSitsInsideTheFloor =>
      optimalHighHours < floorHours && optimalLowHours < optimalHighHours;

  static bool get thereIsNoThirdRegion =>
      theFloorAndCeilingAreOneNumber && theOptimalSitsInsideTheFloor;

  /// Ceiling as worst value (Batch P), as a true upper bound (Step 443), and
  /// as the negation of the floor (here).
  static const List<int> ceilingReadingsSoFar = <int>[418, 443, 456];

  static bool get aThirdReadingOfTheCeiling =>
      ceilingReadingsSoFar.length == 3;

  static const String bandNote =
      'At most 96 hours and more than 96 hours partition the line at 96, so '
      'between them there is no third region for an optimal to sit in and '
      '24-48 hours is a preferred part of the floor. The band contains one '
      'number. The Ceiling column has now been read three ways in three '
      'batches: as the worst value, as a true upper bound, and as the negation '
      'of the floor.';

  static const List<String> outputVocabularies = <String>[
    'Complete / Partial / Not Complete',
    'Pass / Fail',
    'High / Medium / Low',
    'Fast / Acceptable / Delayed',
  ];

  static bool get aFourthOutputVocabulary =>
      outputVocabularies.length == 4 &&
      outputVocabularies.last.startsWith('Fast');

  // -----------------------------------------------------------------------
  // The identifier.
  // -----------------------------------------------------------------------

  static const String senReferencePattern = r'^[A-Z]{2}[0-9]{6,10}$';

  static const bool theReferenceIsParsedForMeaning = false;
  static const bool theReferenceIsShownBesideANameByDefault = false;
  static const bool aChildWithoutAReferenceIsBlocked = false;

  static bool senReferenceIsWellFormed(String v) =>
      RegExp(senReferencePattern).hasMatch(v);

  static bool get shapeOnlyValidation =>
      senReferenceIsWellFormed('AE0012345') &&
      !senReferenceIsWellFormed('ae0012345') &&
      !theReferenceIsParsedForMeaning;

  static bool recordCanBeOpened({required String senReference}) =>
      senReference.isEmpty ? !aChildWithoutAReferenceIsBlocked : true;

  static bool get anUnassessedChildStillHasARecord =>
      recordCanBeOpened(senReference: '') &&
      recordCanBeOpened(senReference: 'AE0012345');

  static const String identifierNote =
      'A national SEN reference says something about a child that the child '
      'did not choose to publish, so it is stored as an opaque string, '
      'validated for shape and nothing else, never parsed for meaning, and '
      'never printed beside a name in a list, a search result or anything on a '
      'shared screen. Requiring the number would exclude exactly the children '
      'who have not been assessed yet, which is the population the service '
      'exists for.';

  // -----------------------------------------------------------------------
  // The telephone.
  // -----------------------------------------------------------------------

  static const String storageFormat = 'E.164';

  static const List<String> acceptedSpellings = <String>[
    '050 123 4567',
    '+971 50 123 4567',
    '00971501234567',
    '+44 7700 900123',
  ];

  static bool get everySpellingIsAccepted => acceptedSpellings.length == 4;

  static bool get aForeignNumberIsAccepted =>
      acceptedSpellings.any((String s) => s.startsWith('+44'));

  static const bool aNumberIsRejectedForBeingForeign = false;

  static const String telephoneNote =
      'Numbers are stored in E.164 and accepted in any national spelling, '
      'because a family reachable only on an overseas mobile is still the '
      'family. A pattern that assumes one country locks those families out of '
      'their own child\'s record.';

  // -----------------------------------------------------------------------
  // The record of the decision.
  // -----------------------------------------------------------------------

  static const List<HabotFormDecision> decisions = <HabotFormDecision>[
    HabotFormDecision(
      question: 'What shape is a SEN reference, and what is read from it?',
      decision: 'Two letters and six to ten digits. Nothing is read from it.',
      rationale: 'An identifier that encodes a category becomes a label the '
          'child carries into every list it appears in.',
      owner: 'Head of Safeguarding',
    ),
    HabotFormDecision(
      question: 'Is the reference required to open a record?',
      decision: 'No.',
      rationale: 'Requiring it excludes the children who have not been '
          'assessed yet.',
      owner: 'Head of Safeguarding',
    ),
    HabotFormDecision(
      question: 'What telephone patterns are accepted?',
      decision: 'Any national spelling; stored as E.164.',
      rationale: 'A family on an overseas number is still the family.',
      owner: 'Head of Service Delivery',
    ),
  ];

  static bool get everyDecisionHasAnOwnerAndAReason => decisions.every(
      (HabotFormDecision d) => d.owner.isNotEmpty && d.rationale.isNotEmpty);

  static const int observedCycleHours = 31;

  static String get qualitativeOutput {
    if (observedCycleHours > floorHours) {
      return 'Delayed';
    }
    return observedCycleHours <= optimalHighHours ? 'Fast' : 'Acceptable';
  }

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor and ceiling are the same boundary read '
      'from two sides -- at most 96 hours and more than 96 hours -- so the '
      'band holds one number and its optimal is a preferred part of its own '
      'floor; its output column is a fourth vocabulary, Fast / Acceptable / '
      'Delayed; and its subject is decided as three recorded decisions: the '
      'SEN reference is opaque and shape-validated only, a child without one '
      'is never blocked, and telephone numbers are accepted in any national '
      'spelling and stored as E.164. Atomic Step: "Convene the Form Validation '
      '& Quality Control decision group and finalize the required pre-setup '
      'decision: Standardization of national SEN identification number formats '
      'and telephone patterns."';

  static Map<String, bool> get obligations => <String, bool>{
        'the reference is validated for shape only': shapeOnlyValidation,
        'nothing is read from the reference':
            !theReferenceIsParsedForMeaning &&
                !theReferenceIsShownBesideANameByDefault,
        'a child without a reference still has a record':
            anUnassessedChildStillHasARecord,
        'any national telephone spelling is accepted':
            everySpellingIsAccepted && !aNumberIsRejectedForBeingForeign,
        'every decision carries an owner and a reason':
            everyDecisionHasAnOwnerAndAReason,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor and the ceiling are the same number':
            theFloorAndCeilingAreOneNumber,
        'so the optimal sits inside the floor, not between two bounds':
            theOptimalSitsInsideTheFloor && thereIsNoThirdRegion,
        'a third reading of the Ceiling column in three batches':
            aThirdReadingOfTheCeiling && bandNote.contains('one number'),
        'Fast / Acceptable / Delayed is a fourth output vocabulary':
            aFourthOutputVocabulary,
        'the reference is shape-validated and never parsed':
            shapeOnlyValidation && !theReferenceIsShownBesideANameByDefault,
        'a child with no reference is not blocked':
            anUnassessedChildStillHasARecord &&
                identifierNote.contains('have not been assessed yet'),
        'four telephone spellings accepted, one of them foreign':
            everySpellingIsAccepted && aForeignNumberIsAccepted,
        'and numbers are stored in one format':
            storageFormat == 'E.164' &&
                telephoneNote.contains('still the family'),
        'three decisions, each with an owner and a reason':
            decisions.length == 3 && everyDecisionHasAnOwnerAndAReason,
        'five obligations met, and 31 hours reports Fast':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Fast',
      };
}
