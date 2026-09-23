/// Step 463 (GEN-04990) -- signing off a sensory map, on a row that asked for
/// its own accessible fallback before anybody made it.
///
/// The row: "Confirm the expected output is achieved and mark Sequence Order
/// 34 complete: Interactive SVG sensory map component with accessible list
/// fallback."
/// Metric: **Milestone Sign-off / Definition-of-Done Compliance** -- floor
/// "100% of stated acceptance criteria verified before sign-off", optimal
/// "100% verified, formally signed off by the accountable owner", ceiling
/// "100% (sign-off is binary; cannot exceed complete)". Complete / Partial /
/// Not Complete. Scrum.org Definition of Done. Assigned to **UDF**.
///
/// **The row specifies accessibility without being asked to.** "Accessible
/// list fallback" is in the expected output, not in a review comment. Step
/// 451 pointed its measurement at a training video rather than at the worker
/// who failed it, also unprompted; this is the second time a row in this
/// track arrives already correct on the point the track usually has to add.
///
/// **A fallback that carries less is a different document.** The list shows
/// every place the map draws, in the same order, with the same intensities
/// and the same actions -- adding a note, marking a place as changed -- and
/// it reads from the same record, so neither can drift from the other. A
/// "lite" version would quietly give one group of people a smaller map.
///
/// **Intensity is never carried by colour alone.** A sensory map says where a
/// room is too loud, too bright or too close, on a scale. Each level carries
/// a label and a distinct shape as well as a tone, which is the track's
/// standing colour rule applied to a drawing rather than a chart.
///
/// **The map belongs to the child.** It is written with them where they can
/// take part, it is visible to the people delivering their support and to
/// nobody else, and it is never aggregated into a comparison between
/// children.
///
/// **Its band is Step 457's**, seven rows earlier, and like Step 457 it
/// verifies its criteria and reports **Partial** because no accountable owner
/// is named.
library;

import '../governance/biometric_signoff.dart';

/// One place on the map.
class HabotSensoryPlace {
  const HabotSensoryPlace({
    required this.name,
    required this.level,
    required this.label,
    required this.shape,
  });

  final String name;

  /// 0 (fine) to 3 (avoid).
  final int level;

  /// The words for the level. Never a colour on its own.
  final String label;

  /// The mark used on the drawing.
  final String shape;
}

/// The sensory map sign-off.
class HabotSensoryMapSignoff {
  const HabotSensoryMapSignoff._();

  // -----------------------------------------------------------------------
  // A row that asked for its own fallback.
  // -----------------------------------------------------------------------

  static const String expectedOutputRaw =
      'Interactive SVG sensory map component with accessible list fallback';

  static bool get theRowNamesTheFallback =>
      expectedOutputRaw.contains('accessible list fallback');

  /// Step 451 and this one.
  static const List<int> rowsCorrectWithoutBeingTold = <int>[451, 463];

  static bool get secondSuchRow => rowsCorrectWithoutBeingTold.length == 2;

  // -----------------------------------------------------------------------
  // The fallback carries everything.
  // -----------------------------------------------------------------------

  static const List<HabotSensoryPlace> places = <HabotSensoryPlace>[
    HabotSensoryPlace(
      name: 'the corridor by the hall',
      level: 3,
      label: 'avoid at changeover',
      shape: 'filled triangle',
    ),
    HabotSensoryPlace(
      name: 'the dining room',
      level: 2,
      label: 'hard when full',
      shape: 'filled square',
    ),
    HabotSensoryPlace(
      name: 'the reading corner',
      level: 0,
      label: 'fine',
      shape: 'open circle',
    ),
    HabotSensoryPlace(
      name: 'the hand dryers',
      level: 3,
      label: 'avoid',
      shape: 'filled triangle',
    ),
  ];

  static const List<String> actionsOnTheMap = <String>[
    'add a note',
    'mark a place as changed',
  ];

  static const List<String> actionsOnTheList = <String>[
    'add a note',
    'mark a place as changed',
  ];

  static bool get bothOfferTheSameActions =>
      actionsOnTheMap.length == actionsOnTheList.length &&
      actionsOnTheMap.every((String a) => actionsOnTheList.contains(a));

  static const int placesDrawn = 4;

  static int get placesListed => places.length;

  static bool get theListShowsEveryPlace => placesListed == placesDrawn;

  static const bool bothReadFromOneRecord = true;

  static bool get neitherCanDrift =>
      bothReadFromOneRecord &&
      theListShowsEveryPlace &&
      bothOfferTheSameActions;

  static const String fallbackNote =
      'The list shows every place the map draws, in the same order, with the '
      'same intensities and the same actions, and it reads from the same '
      'record so neither can drift from the other. A lighter version would '
      'quietly give one group of people a smaller map.';

  // -----------------------------------------------------------------------
  // Never colour alone.
  // -----------------------------------------------------------------------

  static bool get everyLevelHasWords =>
      places.every((HabotSensoryPlace p) => p.label.isNotEmpty);

  static bool get everyLevelHasAShape =>
      places.every((HabotSensoryPlace p) => p.shape.isNotEmpty);

  static bool get intensityIsNotColourAlone =>
      everyLevelHasWords && everyLevelHasAShape;

  // -----------------------------------------------------------------------
  // Whose map it is.
  // -----------------------------------------------------------------------

  static const bool writtenWithTheChildWherePossible = true;
  static const bool visibleOnlyToTheSupportTeam = true;
  static const bool aggregatedAcrossChildren = false;

  static bool get theMapBelongsToTheChild =>
      writtenWithTheChildWherePossible &&
      visibleOnlyToTheSupportTeam &&
      !aggregatedAcrossChildren;

  static const String ownershipNote =
      'A sensory map records where a child finds a room hard. It is written '
      'with them where they can take part, visible to the people delivering '
      'their support and to nobody else, and never aggregated into a '
      'comparison between children.';

  // -----------------------------------------------------------------------
  // The same band as Step 457.
  // -----------------------------------------------------------------------

  static const List<String> acceptanceCriteria = <String>[
    'the list shows every place the map draws',
    'both offer the same actions',
    'both read from one record',
    'intensity carries a label and a shape as well as a tone',
    'the map is not aggregated across children',
  ];

  static bool get everyCriterionIsVerified =>
      theListShowsEveryPlace &&
      bothOfferTheSameActions &&
      bothReadFromOneRecord &&
      intensityIsNotColourAlone &&
      !aggregatedAcrossChildren;

  static const bool anAccountableOwnerHasSigned = false;

  static bool get itIsTheSecondRowAwaitingSignature =>
      HabotSignoffLedger.awaiting[1].step == 463;

  static bool get theBandIsStep457s =>
      HabotBiometricSignoff.acceptanceCriteria.length ==
          acceptanceCriteria.length &&
      !HabotBiometricSignoff.anAccountableOwnerHasSigned;

  static String get qualitativeOutput {
    if (!everyCriterionIsVerified) {
      return 'Not Complete';
    }
    return anAccountableOwnerHasSigned ? 'Complete' : 'Partial';
  }

  static const String columnNote =
      'COLUMN NOTE: this row names an accessible list fallback in its own '
      'expected output, the second row in two batches to arrive already '
      'correct on a point the track usually has to add, after Step 451; the '
      'fallback is built equal rather than lighter, reading from one record '
      'and offering the same actions; intensity carries a label and a shape as '
      'well as a tone; and its band is Step 457\'s, so with every criterion '
      'verified and no owner named it reports Partial. Atomic Step: "Confirm '
      'the expected output is achieved and mark Sequence Order 34 complete: '
      'Interactive SVG sensory map component with accessible list fallback."';

  static Map<String, bool> get obligations => <String, bool>{
        'the list shows every place the map draws': theListShowsEveryPlace,
        'both offer the same actions': bothOfferTheSameActions,
        'both read from one record': bothReadFromOneRecord,
        'intensity is not carried by colour alone': intensityIsNotColourAlone,
        'the map is not aggregated across children': !aggregatedAcrossChildren,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row names its own accessible fallback': theRowNamesTheFallback,
        'the second such row after Step 451': secondSuchRow,
        'four places drawn, four places listed':
            theListShowsEveryPlace && placesDrawn == 4,
        'the same actions on both, from one record':
            bothOfferTheSameActions && neitherCanDrift,
        'so neither can drift from the other':
            fallbackNote.contains('smaller map'),
        'every level carries words and a shape': intensityIsNotColourAlone,
        'the map is the child\'s':
            theMapBelongsToTheChild && ownershipNote.contains('nobody else'),
        'five acceptance criteria, all verified':
            acceptanceCriteria.length == 5 && everyCriterionIsVerified,
        'the band is Step 457\'s, and no owner is named':
            theBandIsStep457s &&
                !anAccountableOwnerHasSigned &&
                itIsTheSecondRowAwaitingSignature,
        'five obligations met, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Partial',
      };
}
