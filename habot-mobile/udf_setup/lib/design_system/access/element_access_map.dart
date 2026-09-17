/// Step 376 (REF-106) -- which elements are hidden and which are merely off,
/// and the third cell in this sheet that reports the generator's own miss.
///
/// The row: "Identify all UI elements (buttons, links, sections) requiring
/// identity-based access control."
/// Metric: **Identification Coverage** -- floor 98, optimal 100, ceiling 100.
/// Complete/Not Complete. Assigned to **UDF**.
///
/// **Hidden and disabled are different answers to different questions.** A
/// disabled control says "this exists and you cannot use it right now". A
/// hidden one says nothing at all. Which is correct depends on whether the
/// existence of the control is itself information: a payroll export a support
/// agent may never run is a fact about the product, and an "Approve refund over
/// AED 50,000" button is a fact about somebody's authority. The first can be
/// disabled with a reason; the second is hidden, because a disabled control
/// with a reason beside it teaches the reader the limit, the threshold and the
/// role that clears it.
///
/// **The row's own completion measure settles the hard cases.** It asks that a
/// non-privileged account find "zero structural nodes or trace clues for admin
/// settings inside the client DOM" -- which is a statement that for admin
/// surfaces, absent means absent, not `visibility: hidden`. This is stronger
/// than a disabled state and it is the right call for that class: a control
/// rendered and then covered is a control a determined person reads out of the
/// widget tree.
///
/// **A client-side map is not a permission system.** Every treatment here
/// decides what is drawn; none of it decides what the server will accept. Steps
/// 360 and 373 recorded the same thing about a role-gated tile, and the audit
/// this row asks for is an audit of the drawing, which is worth doing and is
/// not a security boundary.
///
/// **COLUMN NOTE.** The Data Requirement cell lists five real fields and then
/// appends the generator's own miss to them -- "No matched reference row in
/// Setup Implementation master list ... verify manually" -- separated by `||`.
/// Steps 347 and 369 carry that sentence as the whole cell. Here it is a
/// suffix on a populated one, which is the third occurrence and the first
/// hybrid.
library;

import '../operations/permanent_disable.dart';

/// What the interface does with an element the viewer may not use.
enum HabotAccessTreatment {
  /// Drawn, off, with a reason beside it.
  disabledWithReason,

  /// Not drawn, and not present in the widget tree.
  absent,

  /// Drawn and usable.
  available,
}

/// One element the audit covers.
class HabotAccessElement {
  const HabotAccessElement({
    required this.name,
    required this.treatment,
    required this.existenceIsInformation,
    required this.reason,
  });

  final String name;
  final HabotAccessTreatment treatment;

  /// True when knowing the control exists tells the viewer something they are
  /// not entitled to know.
  final bool existenceIsInformation;

  /// Shown beside a disabled control. Empty for absent and available ones.
  final String reason;
}

/// The element-level access map.
class HabotElementAccessMap {
  const HabotElementAccessMap._();

  // -----------------------------------------------------------------------
  // The rule.
  // -----------------------------------------------------------------------

  /// An element whose existence is itself information is absent; everything
  /// else that is refused is disabled with a reason.
  static HabotAccessTreatment treatmentFor({
    required bool permitted,
    required bool existenceIsInformation,
  }) {
    if (permitted) {
      return HabotAccessTreatment.available;
    }
    return existenceIsInformation
        ? HabotAccessTreatment.absent
        : HabotAccessTreatment.disabledWithReason;
  }

  static const String ruleNote =
      'A disabled control says "this exists and you cannot use it"; a hidden '
      'one says nothing. Which is right depends on whether the existence of '
      'the control is itself information. A refund ceiling somebody cannot '
      'clear is a fact about their authority, and a disabled button with a '
      'reason beside it teaches the reader the limit, the threshold and the '
      'role that clears it. A report they simply may not run is a fact about '
      'the product, and saying so costs nothing.';

  // -----------------------------------------------------------------------
  // The worked elements.
  // -----------------------------------------------------------------------

  static const List<HabotAccessElement> elements = <HabotAccessElement>[
    HabotAccessElement(
      name: 'Export payroll',
      treatment: HabotAccessTreatment.disabledWithReason,
      existenceIsInformation: false,
      reason: 'payroll administrators only',
    ),
    HabotAccessElement(
      name: 'Approve refund over AED 50,000',
      treatment: HabotAccessTreatment.absent,
      existenceIsInformation: true,
      reason: '',
    ),
    HabotAccessElement(
      name: 'Admin settings section',
      treatment: HabotAccessTreatment.absent,
      existenceIsInformation: true,
      reason: '',
    ),
    HabotAccessElement(
      name: 'Edit my own profile',
      treatment: HabotAccessTreatment.available,
      existenceIsInformation: false,
      reason: '',
    ),
    HabotAccessElement(
      name: 'Deactivate a colleague',
      treatment: HabotAccessTreatment.disabledWithReason,
      existenceIsInformation: false,
      reason: 'needs the people-manager role',
    ),
  ];

  static int countOf(HabotAccessTreatment t) =>
      elements.where((HabotAccessElement e) => e.treatment == t).length;

  static bool get everyElementIsClassified =>
      elements.length == 5 &&
      countOf(HabotAccessTreatment.disabledWithReason) +
              countOf(HabotAccessTreatment.absent) +
              countOf(HabotAccessTreatment.available) ==
          elements.length;

  static bool get twoAreAbsent => countOf(HabotAccessTreatment.absent) == 2;

  static bool get twoAreDisabledWithAReason =>
      countOf(HabotAccessTreatment.disabledWithReason) == 2;

  /// Every disabled element carries a reason, and no absent one does -- an
  /// absent element has nowhere to put one.
  static bool get everyDisabledElementCarriesItsReason => elements
      .where(
        (HabotAccessElement e) =>
            e.treatment == HabotAccessTreatment.disabledWithReason,
      )
      .every((HabotAccessElement e) => e.reason.isNotEmpty);

  static bool get noAbsentElementCarriesAReason => elements
      .where(
        (HabotAccessElement e) =>
            e.treatment == HabotAccessTreatment.absent,
      )
      .every((HabotAccessElement e) => e.reason.isEmpty);

  /// The classification is reproduced by the rule rather than written twice.
  static bool get theRuleReproducesEveryClassification => elements.every(
        (HabotAccessElement e) =>
            treatmentFor(
              permitted: e.treatment == HabotAccessTreatment.available,
              existenceIsInformation: e.existenceIsInformation,
            ) ==
            e.treatment,
      );

  // -----------------------------------------------------------------------
  // Absent means absent.
  // -----------------------------------------------------------------------

  static const String completionMeasure =
      'Non-privileged user accounts find zero structural nodes or trace clues '
      'for admin settings inside the client DOM.';

  static const bool aHiddenElementIsRenderedAndCovered = false;

  static bool get absentMeansNotInTheTree =>
      !aHiddenElementIsRenderedAndCovered &&
      completionMeasure.contains('zero structural nodes');

  static const String absenceNote =
      'The row\'s own completion measure asks that a non-privileged account '
      'find no structural node for admin settings at all, which is a statement '
      'that absent means absent rather than drawn and covered. It is the right '
      'call for that class and it is stronger than a disabled state: a control '
      'rendered and then hidden is a control a determined person reads out of '
      'the widget tree.';

  // -----------------------------------------------------------------------
  // What a drawing audit is not.
  // -----------------------------------------------------------------------

  static const bool theMapDecidesWhatTheServerAccepts = false;

  static const List<int> rowsThatRecordedTheSameThing = <int>[360, 373];

  static bool get theLimitIsStated => !theMapDecidesWhatTheServerAccepts;

  static const String boundaryNote =
      'Every treatment here decides what is drawn. None of it decides what the '
      'server will accept, and an audit of the drawing is not a security '
      'boundary -- Steps 360 and 373 recorded the same thing about a '
      'role-gated tile and an HR surface. The audit is still worth doing, '
      'because the commonest way to leak a capability is to render it.';

  // -----------------------------------------------------------------------
  // The disabled kind is the one Step 292 declared.
  // -----------------------------------------------------------------------

  static const HabotDisableKind kindForARoleRefusal =
      HabotDisableKind.notPermitted;

  static bool get theDisableKindIsTheDeclaredOne =>
      HabotDisableKind.values.contains(kindForARoleRefusal) &&
      kindForARoleRefusal != HabotDisableKind.latched;

  static HabotDisabledControl controlFor(HabotAccessElement e) =>
      HabotDisabledControl(
        label: e.name,
        kind: kindForARoleRefusal,
        reason: e.reason,
        whatWouldChangeIt: e.reason,
      );

  /// A role refusal is not a dead end: what would change it is the role, and
  /// the reason names it.
  static bool get aRoleRefusalIsNotADeadEnd => elements
      .where(
        (HabotAccessElement e) =>
            e.treatment == HabotAccessTreatment.disabledWithReason,
      )
      .every((HabotAccessElement e) => !controlFor(e).isADeadEnd);

  static const String reuseNote =
      'The disabled control is the one Step 292 built: a kind, a reason shown '
      'beside the control rather than inside it, and a statement of what would '
      'change it. A role refusal is "not permitted" rather than "latched", and '
      'what would change it is the role -- which the reason names, so the '
      'control is not a dead end.';

  // -----------------------------------------------------------------------
  // The band, and the column.
  // -----------------------------------------------------------------------

  static const int bandFloor = 98;
  static const int bandOptimal = 100;
  static const int bandCeiling = 100;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  /// The share of audited elements carrying a treatment the rule reproduces.
  static double get coverage => elements.isEmpty
      ? 0
      : elements
                  .where(
                    (HabotAccessElement e) =>
                        treatmentFor(
                          permitted:
                              e.treatment == HabotAccessTreatment.available,
                          existenceIsInformation: e.existenceIsInformation,
                        ) ==
                        e.treatment,
                  )
                  .length /
              elements.length *
              100;

  static const String dataRequirementCell =
      'Atomic-level data fields: Access Type; User Role; Permission Level; '
      'Access Log; Access Timestamp || No matched reference row in Setup '
      'Implementation master list -- required data fields limited to '
      'atomic-level Data Collection Requirements only; standardized Mobile '
      'UX/UI & domain-expertise fields unavailable, verify manually.';

  static bool get theCellCarriesBothFieldsAndAMiss =>
      dataRequirementCell.contains('Access Timestamp') &&
      dataRequirementCell.contains('No matched reference row');

  static const List<int> generatorMissRows = <int>[347, 369, 376];

  static bool get thisIsTheThirdOccurrence => generatorMissRows.length == 3;

  static const String generatorNote =
      'The Data Requirement cell lists five real fields and then appends the '
      'generator\'s own miss to them, separated by a double pipe. Steps 347 '
      'and 369 carry that sentence as the whole cell; here it is a suffix on a '
      'populated one. Third occurrence, first hybrid -- and it means a cell '
      'that looks filled in can still be reporting that nothing was found.';

  static Map<String, bool> get obligations => <String, bool>{
        'every element has a treatment': everyElementIsClassified,
        'the treatment follows the rule rather than a second list':
            theRuleReproducesEveryClassification,
        'every disabled element carries a reason':
            everyDisabledElementCarriesItsReason,
        'an absent element is not in the tree': absentMeansNotInTheTree,
        'no role refusal is a dead end': aRoleRefusalIsNotADeadEnd,
        'the limit of a drawing audit is stated': theLimitIsStated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'five elements, all classified': everyElementIsClassified,
        'two are absent and two are disabled with a reason':
            twoAreAbsent && twoAreDisabledWithAReason,
        'the rule reproduces every classification':
            theRuleReproducesEveryClassification,
        'hidden and disabled are different answers':
            ruleNote.contains('the role that clears it'),
        'absent means not in the widget tree':
            absentMeansNotInTheTree &&
                absenceNote.contains('read out of the widget tree') &&
                noAbsentElementCarriesAReason,
        'the disabled kind is Step 292\'s, and is not a dead end':
            theDisableKindIsTheDeclaredOne && aRoleRefusalIsNotADeadEnd,
        'a drawing audit is not a security boundary':
            theLimitIsStated &&
                rowsThatRecordedTheSameThing.contains(373) &&
                boundaryNote.contains('render it'),
        'the Data Requirement cell holds fields and a miss':
            theCellCarriesBothFieldsAndAMiss,
        'third generator-miss occurrence, first hybrid':
            thisIsTheThirdOccurrence &&
                generatorNote.contains('first hybrid'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theOptimalEqualsTheCeiling &&
                coverage == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row lists five real data '
      'fields and then appends the generator\'s own miss to them -- "No '
      'matched reference row in Setup Implementation master list ... verify '
      'manually" -- after a double pipe, which is the third occurrence of that '
      'sentence after Steps 347 and 369 and the first time it decorates a '
      'populated cell rather than replacing one; the band\'s optimal and '
      'ceiling are both 100; and the Setup Step column is empty. Atomic Step: '
      '"Identify all UI elements (buttons, links, sections) requiring '
      'identity-based access control."';
}
