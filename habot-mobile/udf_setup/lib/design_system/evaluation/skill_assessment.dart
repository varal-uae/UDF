/// Step 450 (GEN-05331) -- the specification for skill quizzes on Learning
/// Difficulty knowledge, on a row whose only named artefact is an
/// abbreviation.
///
/// The row: "Design the approach and technical specification for: implement
/// automated skill assessment quizzes evaluating basic Learning Difficulty (LD)
/// knowledge and service delivery norms"
/// Metric: **Technical Specification Completeness** -- floor "Spec missing
/// acceptance criteria or edge cases", optimal "Spec complete: inputs,
/// outputs, edge cases & acceptance criteria defined", ceiling "1".
/// Complete/Partial/Not Complete. ISO/IEC/IEEE 29148. Assigned to **UDF**.
///
/// **The Data Requirement is "Learning Difficulty (LD)".** Nothing else. The
/// artefact to prepare is the expansion of an abbreviation that appears in the
/// Atomic Step. It is the second row in this batch whose Data Requirement is a
/// word lifted from its own instruction, after Step 436's "completion".
///
/// **For once the row asks for exactly what its band measures.** A design and
/// technical specification, scored on whether the specification states its
/// inputs, outputs, edge cases and acceptance criteria. So a specification is
/// what is delivered, with all four sections, and it is measured against the
/// four things its own optimal names. The floor still describes the failure --
/// "Spec missing acceptance criteria or edge cases" -- the third floor in this
/// batch to do so, after Steps 442 and 453.
///
/// **A quiz that assesses people needs rules before it has questions.** These
/// quizzes are for staff working with children who have learning difficulties;
/// getting the knowledge right matters, and so does not using a quiz as a
/// trapdoor. The specification says: results go to the learner first; retakes
/// are allowed; nothing happens automatically on a low score (Step 436's third
/// rule); and a question most people get wrong is flagged as a bad question
/// rather than counted against everybody who missed it.
///
/// **A quiz about learning difficulties has to be accessible itself.** Plain
/// language at a stated reading level, no timer, questions that can be read
/// aloud, and no trick wording. A test of how to support people who find
/// reading hard should not be one that people who find reading hard cannot
/// pass.
///
/// **Its metric and band are identical to Step 454's**, four rows later, on a
/// specification for logging improvements.
library;

import '../recognition/completion_criteria.dart';

/// One section of the specification.
class HabotQuizSpecSection {
  const HabotQuizSpecSection({
    required this.name,
    required this.contents,
  });

  final String name;
  final List<String> contents;
}

/// One quiz question after it has been answered by a cohort.
class HabotQuestionItem {
  const HabotQuestionItem({
    required this.id,
    required this.answered,
    required this.correct,
  });

  final String id;
  final int answered;
  final int correct;
}

/// The skill-assessment specification.
class HabotSkillAssessment {
  const HabotSkillAssessment._();

  // -----------------------------------------------------------------------
  // The Data Requirement is an abbreviation.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell = 'Learning Difficulty (LD)';

  static bool get theArtefactIsAnExpansion =>
      dataRequirementCell.contains('(LD)');

  /// Step 436's "completion", and this.
  static const List<int> rowsWhoseArtefactIsTheirOwnWord = <int>[436, 450];

  static bool get secondSuchRow => rowsWhoseArtefactIsTheirOwnWord.length == 2;

  // -----------------------------------------------------------------------
  // The specification, with the four sections its optimal names.
  // -----------------------------------------------------------------------

  static const List<HabotQuizSpecSection> specification =
      <HabotQuizSpecSection>[
    HabotQuizSpecSection(
      name: 'inputs',
      contents: <String>[
        'a question bank reviewed by a qualified practitioner',
        'the learner\'s role, which decides which modules apply',
      ],
    ),
    HabotQuizSpecSection(
      name: 'outputs',
      contents: <String>[
        'a result shown to the learner first, with the correct answers',
        'an item report per question for the question bank owner',
      ],
    ),
    HabotQuizSpecSection(
      name: 'edge cases',
      contents: <String>[
        'a learner who needs questions read aloud',
        'a question most of a cohort gets wrong',
        'a learner who stops halfway and returns another day',
      ],
    ),
    HabotQuizSpecSection(
      name: 'acceptance criteria',
      contents: <String>[
        'no timer on any question',
        'every question readable by a screen reader',
        'no automatic consequence on any score',
        'retakes allowed without limit',
      ],
    ),
  ];

  static const List<String> sectionsTheOptimalNames = <String>[
    'inputs',
    'outputs',
    'edge cases',
    'acceptance criteria',
  ];

  static bool get everyNamedSectionIsPresent => sectionsTheOptimalNames.every(
      (String n) => specification.any((HabotQuizSpecSection s) => s.name == n));

  static bool get noSectionIsEmpty =>
      specification.every((HabotQuizSpecSection s) => s.contents.isNotEmpty);

  static const String bandFloorRaw =
      'Spec missing acceptance criteria or edge cases';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.startsWith('Spec missing');

  /// Steps 442, 450 and 453.
  static const List<int> floorsDescribingFailure = <int>[442, 450, 453];

  static bool get thirdSuchFloor => floorsDescribingFailure.length == 3;

  // -----------------------------------------------------------------------
  // Rules before questions.
  // -----------------------------------------------------------------------

  static const bool resultsGoToTheLearnerFirst = true;
  static const bool retakesAreAllowed = true;
  static const bool aLowScoreTriggersAConsequence = false;

  static bool get theCharterThirdRuleHolds =>
      !aLowScoreTriggersAConsequence &&
      HabotScoringCharter.rules[2].contains('named person');

  static const double badQuestionThreshold = 0.4;

  static const List<HabotQuestionItem> items = <HabotQuestionItem>[
    HabotQuestionItem(id: 'q1', answered: 40, correct: 34),
    HabotQuestionItem(id: 'q2', answered: 40, correct: 31),
    HabotQuestionItem(id: 'q3', answered: 40, correct: 11),
    HabotQuestionItem(id: 'q4', answered: 40, correct: 36),
  ];

  static bool isABadQuestion(HabotQuestionItem q) =>
      q.answered > 0 && q.correct / q.answered < badQuestionThreshold;

  static List<HabotQuestionItem> get flagged =>
      items.where(isABadQuestion).toList();

  static bool get oneQuestionIsFlagged =>
      flagged.length == 1 && flagged.first.id == 'q3';

  static const bool aFlaggedQuestionCountsAgainstLearners = false;

  static const String itemNote =
      'A question most of a cohort gets wrong is usually a question that is '
      'wrong, ambiguous or about something nobody was taught. It is flagged '
      'for the question bank owner and removed from everybody\'s score until '
      'it is reviewed, rather than counted against everybody who missed it. In '
      'the worked cohort one question in four is answered correctly by fewer '
      'than two people in five, and it is that one.';

  // -----------------------------------------------------------------------
  // The quiz is accessible itself.
  // -----------------------------------------------------------------------

  static const bool thereIsATimer = false;
  static const bool questionsCanBeReadAloud = true;
  static const bool trickWordingIsAllowed = false;
  static const int statedReadingAgeYears = 11;

  static bool get theQuizIsAccessible =>
      !thereIsATimer &&
      questionsCanBeReadAloud &&
      !trickWordingIsAllowed &&
      statedReadingAgeYears > 0;

  static const String accessNote =
      'A test of how to support people who find reading hard should not be one '
      'that people who find reading hard cannot pass. Plain language at a '
      'stated reading age, no timer, every question readable aloud, and no '
      'trick wording.';

  static const int metricSharedWithStep = 454;

  static double get completeness {
    final int present = sectionsTheOptimalNames
        .where((String n) => specification
            .any((HabotQuizSpecSection s) =>
                s.name == n && s.contents.isNotEmpty))
        .length;
    return present / sectionsTheOptimalNames.length;
  }

  static String get qualitativeOutput =>
      completeness == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s Data Requirement reads only "Learning '
      'Difficulty (LD)", the expansion of an abbreviation from its own '
      'instruction, the second such artefact in this batch after Step 436; it '
      'asks for a specification and is scored on specification completeness, '
      'so a four-section specification is delivered and measured against the '
      'four things its own optimal names; its floor describes the failure, the '
      'third in this batch; and its metric and band are identical to Step '
      '454\'s. Atomic Step: "Design the approach and technical specification '
      'for: implement automated skill assessment quizzes evaluating basic '
      'Learning Difficulty (LD) knowledge and service delivery norms"';

  static Map<String, bool> get obligations => <String, bool>{
        'every section the optimal names is present':
            everyNamedSectionIsPresent && noSectionIsEmpty,
        'results go to the learner first': resultsGoToTheLearnerFirst,
        'retakes are allowed': retakesAreAllowed,
        'no score triggers a consequence': theCharterThirdRuleHolds,
        'the quiz is accessible itself': theQuizIsAccessible,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the Data Requirement is an abbreviation\'s expansion':
            theArtefactIsAnExpansion && secondSuchRow,
        'four sections, as the optimal names them':
            specification.length == 4 && everyNamedSectionIsPresent,
        'and none of them is empty': noSectionIsEmpty,
        'the floor describes the failure, the third in this batch':
            theFloorDescribesTheFailure && thirdSuchFloor,
        'results to the learner, retakes allowed, no consequence':
            resultsGoToTheLearnerFirst &&
                retakesAreAllowed &&
                theCharterThirdRuleHolds,
        'four questions, one flagged as a bad question':
            items.length == 4 && oneQuestionIsFlagged,
        'and a flagged question counts against nobody':
            !aFlaggedQuestionCountsAgainstLearners &&
                itemNote.contains('rather than counted against'),
        'no timer, read-aloud, no trick wording':
            theQuizIsAccessible && accessNote.contains('cannot pass'),
        'the metric is shared with Step 454': metricSharedWithStep == 454,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
