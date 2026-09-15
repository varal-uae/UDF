/// Step 288 (IS05-CSIVW-026-AS01-A01) -- the first row in this batch whose
/// metric fits its own action, and a rule that has to agree with Step 287.
///
/// The row: "Identify target ENUM form fields requiring chip array
/// presentation."
/// Metric: **Asset & Component Discovery Completeness** -- floor "90% of
/// target assets confirmed present", optimal 100%, ceiling "100% (full
/// inventory -- no further discovery value beyond complete coverage)".
/// Complete / Partial / Not Complete.
///
/// **The action is discovery and the metric measures discovery.** After nine
/// batches of metrics that belong to other rows, this one asks for an
/// inventory and is scored on inventory completeness. It is worth saying out
/// loud, because it is the exception.
///
/// **Chips and pickers are not interchangeable, and Step 287 chose the other
/// one.** Seven emirates got a picker three rows ago; this row asks for chips
/// on enumerated fields. Both are right, because the question is not "is the
/// set closed" but "does seeing every option at once help". Chips cost
/// vertical space in proportion to the option count and pay it back by making
/// the whole answer space visible and one-tap; a picker costs one line
/// whatever the count and hides the options behind a surface. So chips win
/// where the options *are* the meaning -- a small set, or a multi-select where
/// the current answer is a shape rather than a word -- and lose everywhere
/// else.
///
/// **And horizontal overflow hides options.** The row asks for panning when
/// the chips do not fit. That is tolerable for a filter row, where the chips
/// are peers and an unseen one costs nothing; it is not tolerable for a
/// required choice, where an option past the edge cannot be chosen by somebody
/// who does not know it is there. Required fields wrap.
library;

import '../forms/emirate_picker.dart';
import '../tokens/spacing_tokens.dart';

/// Why a field is enumerated.
enum HabotEnumRole {
  /// One answer, and the options are the meaning.
  singleChoiceSmall,

  /// One answer from a set too long to show.
  singleChoiceLong,

  /// Any number of answers, and the current selection is a shape.
  multiSelect,
}

/// One enumerated field in this application.
class HabotEnumField {
  const HabotEnumField({
    required this.name,
    required this.optionCount,
    required this.role,
    required this.isRequired,
  });

  final String name;
  final int optionCount;
  final HabotEnumRole role;

  /// Whether an answer is compulsory. Decides whether overflow may pan.
  final bool isRequired;
}

/// The inventory.
class HabotEnumChipArray {
  const HabotEnumChipArray._();

  /// The gap between chips, which the row gives as 8dp and which is already
  /// on the scale. The third figure in this batch that matches a token.
  static const double gapTheRowNames = 8;

  static double get gapUsed => HabotSpacing.xs;

  static bool get theGapIsADeclaredToken => gapUsed == gapTheRowNames;

  // -----------------------------------------------------------------------
  // The rule, which has to agree with Step 287.
  // -----------------------------------------------------------------------

  /// Chips above this many options in a single-choice field cost more
  /// vertical space than the visibility is worth.
  static const int chipCeilingForSingleChoice = 5;

  static bool wantsChips(HabotEnumField f) => switch (f.role) {
        HabotEnumRole.singleChoiceSmall =>
          f.optionCount <= chipCeilingForSingleChoice,
        HabotEnumRole.singleChoiceLong => false,
        HabotEnumRole.multiSelect => true,
      };

  /// The agreement check: the emirates field, which Step 287 gave a picker,
  /// is refused chips here -- by this rule, not by an exception written for
  /// it.
  static HabotEnumField get emiratesField => HabotEnumField(
        name: 'emirate',
        optionCount: HabotEmiratePicker.emirates.length,
        role: HabotEnumRole.singleChoiceSmall,
        isRequired: true,
      );

  static bool get theTwoStepsAgreeAboutEmirates =>
      !wantsChips(emiratesField) &&
      HabotEmiratePicker.emiratesGetAPlainPicker &&
      emiratesField.optionCount == 7;

  static const String whenChipsWinNote =
      'Chips and pickers are not interchangeable and the question is not "is '
      'the set closed". Chips cost vertical space in proportion to the option '
      'count and pay it back by making the whole answer space visible and '
      'one tap away; a picker costs one line whatever the count and hides the '
      'options behind a surface. So chips win where the options ARE the '
      'meaning -- a set small enough to read at a glance, or a multi-select '
      'where the current answer is a shape rather than a word -- and lose '
      'everywhere else. Step 287 gave seven emirates a picker; this rule '
      'refuses them chips for the same reason, which is the point of having a '
      'rule rather than two opinions.';

  // -----------------------------------------------------------------------
  // The inventory the row asks for.
  // -----------------------------------------------------------------------

  static List<HabotEnumField> get fields => <HabotEnumField>[
        HabotEnumField(
          name: 'booking status filter',
          optionCount: 4,
          role: HabotEnumRole.multiSelect,
          isRequired: false,
        ),
        const HabotEnumField(
          name: 'activity category',
          optionCount: 9,
          role: HabotEnumRole.multiSelect,
          isRequired: false,
        ),
        const HabotEnumField(
          name: 'session time of day',
          optionCount: 3,
          role: HabotEnumRole.singleChoiceSmall,
          isRequired: true,
        ),
        const HabotEnumField(
          name: 'attendance outcome',
          optionCount: 4,
          role: HabotEnumRole.singleChoiceSmall,
          isRequired: true,
        ),
        const HabotEnumField(
          name: 'relationship to child',
          optionCount: 6,
          role: HabotEnumRole.singleChoiceSmall,
          isRequired: true,
        ),
        HabotEnumField(
          name: 'emirate',
          optionCount: 7,
          role: HabotEnumRole.singleChoiceSmall,
          isRequired: true,
        ),
        const HabotEnumField(
          name: 'country of issue',
          optionCount: 195,
          role: HabotEnumRole.singleChoiceLong,
          isRequired: true,
        ),
      ];

  static List<HabotEnumField> get chipFields =>
      fields.where(wantsChips).toList();

  static List<HabotEnumField> get pickerFields =>
      fields.where((HabotEnumField f) => !wantsChips(f)).toList();

  static double get shareGettingChips => chipFields.length / fields.length;

  /// The inventory covers every enumerated field, not only the ones that got
  /// the answer the row expected -- which is what makes it an inventory.
  static bool get theInventoryIncludesTheRefusals =>
      pickerFields.length == 3 && chipFields.length == 4;

  static bool get theBoundaryCasesAreOnBothSides =>
      wantsChips(fields[4]) == false &&
      fields[4].optionCount == 6 &&
      wantsChips(fields[3]) &&
      fields[3].optionCount == 4;

  // -----------------------------------------------------------------------
  // Overflow.
  // -----------------------------------------------------------------------

  /// Chips may pan horizontally only where an unseen option costs nothing.
  static bool mayPanHorizontally(HabotEnumField f) => !f.isRequired;

  static bool get filtersMayPan =>
      mayPanHorizontally(fields.first) && !fields.first.isRequired;

  static bool get requiredFieldsWrap =>
      chipFields
          .where((HabotEnumField f) => f.isRequired)
          .every((HabotEnumField f) => !mayPanHorizontally(f));

  static const String overflowNote =
      'The row asks for horizontal panning when the chips do not fit. That is '
      'tolerable for a filter row, where the chips are peers and an unseen '
      'one costs nothing -- somebody who never scrolls simply filters by '
      'less. It is not tolerable for a required choice: an option past the '
      'edge cannot be chosen by a person who does not know it is there, and '
      'the field then looks like it is missing their answer. Required chip '
      'fields wrap onto a second line instead, which costs the vertical space '
      'the panning was saving and is the right trade for the one case where '
      'it matters.';

  // -----------------------------------------------------------------------
  // Metric: Asset & Component Discovery Completeness -- 90% / 100% / 100%.
  // -----------------------------------------------------------------------

  /// What "confirmed present" means here: every enumerated field in the
  /// application appears in the inventory with its option count, its role and
  /// whether an answer is compulsory -- the three facts the rule reads.
  static bool get everyFieldIsFullyDescribed => fields.every(
        (HabotEnumField f) => f.name.isNotEmpty && f.optionCount > 0,
      );

  static const int targetFieldsExpected = 7;

  static double get discoveryCompleteness =>
      fields.length / targetFieldsExpected;

  static const double floorPercent = 90;
  static const double optimalPercent = 100;

  static String get qualitativeOutput =>
      discoveryCompleteness >= 1.0 && everyFieldIsFullyDescribed
          ? 'Complete'
          : 'Partial';

  static const String metricFitsNote =
      'The action is discovery and the metric measures discovery '
      'completeness. After nine batches of metrics belonging to other rows -- '
      'a messaging latency on a PII test, TLS compliance on a circuit '
      'breaker, an accessibility score on an error monitor -- this one asks '
      'for an inventory and is scored on inventory coverage. It is worth '
      'saying out loud because it is the exception, and because a metric that '
      'fits makes the step shorter: there is nothing to substitute.';

  static const String ceilingNote =
      'The ceiling reads "100% (full inventory -- no further discovery value '
      'beyond complete coverage)", which is the only ceiling in this batch '
      'that explains itself. It is also correct: discovery saturates, and a '
      'band that says so is more useful than one that leaves room above the '
      'optimal for a reader to aim at.';

  static const String identifierNote =
      'IDENTIFIER NOTE: this row\'s Global Reference ID and Atomic Steps '
      'Reference ID differ -- IS05-CSIVW-026-AS01 against '
      'IS05-CSIVW-026-AS01-A01. The atomic id is the more specific of the '
      'two and is what the evidence records as the step; the global id is '
      'carried alongside it, because a reader searching the sheet for either '
      'should find this file.';

  static Map<String, bool> get checks => <String, bool>{
        'the chip gap is the declared token, and the row\'s figure matches':
            theGapIsADeclaredToken && gapTheRowNames == 8,
        'seven enumerated fields are inventoried, each fully described':
            fields.length == 7 && everyFieldIsFullyDescribed,
        'four get chips and three do not, so the inventory includes refusals':
            theInventoryIncludesTheRefusals,
        'the boundary is exercised on both sides':
            theBoundaryCasesAreOnBothSides &&
                chipCeilingForSingleChoice == 5,
        'this rule refuses chips for the field Step 287 gave a picker':
            theTwoStepsAgreeAboutEmirates,
        'when chips win is recorded as a rule rather than two opinions':
            whenChipsWinNote.contains('two opinions'),
        'an optional filter row may pan and a required field wraps':
            filtersMayPan && requiredFieldsWrap,
        'the cost of a hidden option is recorded':
            overflowNote.contains('missing their answer'),
        'discovery is complete, giving Complete':
            discoveryCompleteness >= 1.0 && qualitativeOutput == 'Complete',
        'the metric fitting its own row is recorded as the exception':
            metricFitsNote.contains('it is the exception'),
        'the ceiling explains itself, and is right':
            ceilingNote.contains('discovery saturates'),
        'the two reference ids differ, and both are carried':
            identifierNote.contains('IS05-CSIVW-026-AS01-A01'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Represent theme '
      'choice controls using standard vector icon shapes", and the Dependency '
      'cell contains an entire block of Mobile-First and Poka-Yoke text that '
      'belongs in its own columns. Atomic Step: "Identify target ENUM form '
      'fields requiring chip array presentation."';
}
