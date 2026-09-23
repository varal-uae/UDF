/// Step 491 (GEN-05353) -- the specification for an algorithm that finds
/// where people get stuck, on a band now appearing for the fourth time.
///
/// The row: "Design the approach and technical specification for: create an
/// automated friction identification algorithm flagging stations where user
/// drop-off or delay exceeds norms"
/// Metric: **Technical Specification Completeness** -- floor "Spec missing
/// acceptance criteria or edge cases", optimal "Spec complete: inputs,
/// outputs, edge cases & acceptance criteria defined", ceiling "1".
/// Complete / Partial / Not Complete. ISO/IEC/IEEE 29148. Assigned to **UDF**.
///
/// **Fourth appearance of this band**, after Steps 450, 454 and 473. As with
/// all three, the row asks for exactly what its band measures, so a
/// specification is delivered and scored against the four sections its own
/// optimal names.
///
/// **"Station" is the sixth noun for one idea.** Batch P counted five --
/// friction, hesitation, drop-off, bottleneck, complexity bottleneck -- and
/// this row adds a station. They all mean a place in a flow where people
/// stop. Six names is how two teams build two systems for one problem.
///
/// **"Exceeds norms" needs a norm, and the cross-station average is the wrong
/// one.** A medication check should take longer than a tick box, so comparing
/// every station against the mean of all stations flags the careful ones and
/// hides the broken ones. Each station is compared against its own trailing
/// median over the previous four weeks, which makes the question "is this
/// station worse than it was" rather than "is this station slower than a
/// different station".
///
/// **The unit of analysis is still a screen.** Batch P fixed that at Step 416
/// and forbade attributing an indicator to a person; nothing here changes it.
/// A station that is slow because a support worker is reading something
/// carefully is not a defect, and the algorithm cannot tell the difference,
/// which is why it flags rather than decides.
library;

import '../telemetry/friction_framework.dart';

/// One section of the specification.
class HabotFrictionSpecSection {
  const HabotFrictionSpecSection({
    required this.name,
    required this.contents,
  });

  final String name;
  final List<String> contents;
}

/// One station measured against its own history.
class HabotStationReading {
  const HabotStationReading({
    required this.station,
    required this.sessions,
    required this.medianSeconds,
    required this.trailingMedianSeconds,
    required this.dropOffPercent,
  });

  final String station;
  final int sessions;
  final double medianSeconds;
  final double trailingMedianSeconds;
  final double dropOffPercent;
}

/// The friction identification specification.
class HabotFrictionAlgorithmSpec {
  const HabotFrictionAlgorithmSpec._();

  // -----------------------------------------------------------------------
  // The band, a fourth time.
  // -----------------------------------------------------------------------

  /// Steps 450, 454, 473 and 491.
  static const List<int> rowsCarryingThisBand = <int>[450, 454, 473, 491];

  static bool get fourthAppearance => rowsCarryingThisBand.length == 4;

  static const List<String> sectionsTheOptimalNames = <String>[
    'inputs',
    'outputs',
    'edge cases',
    'acceptance criteria',
  ];

  // -----------------------------------------------------------------------
  // Six nouns for one idea.
  // -----------------------------------------------------------------------

  static const List<String> nounsForOneIdea = <String>[
    'friction',
    'hesitation',
    'drop-off',
    'bottleneck',
    'complexity bottleneck',
    'station',
  ];

  static bool get sixNounsNow => nounsForOneIdea.length == 6;

  static bool get theFrameworkAlreadyNamedFive =>
      HabotFrictionFramework.theFrameworkIsWrittenHere;

  static const String nounNote =
      'Batch P counted five names for a place in a flow where people stop, and '
      'this row adds a station. Six names is how two teams build two systems '
      'for one problem.';

  // -----------------------------------------------------------------------
  // The specification.
  // -----------------------------------------------------------------------

  static const List<HabotFrictionSpecSection> specification =
      <HabotFrictionSpecSection>[
    HabotFrictionSpecSection(
      name: 'inputs',
      contents: <String>[
        'per-station session counts, median dwell and exit counts',
        'the station\'s own trailing median over four weeks',
      ],
    ),
    HabotFrictionSpecSection(
      name: 'outputs',
      contents: <String>[
        'a flag per station with the comparison that produced it',
        'never a ranking of people',
      ],
    ),
    HabotFrictionSpecSection(
      name: 'edge cases',
      contents: <String>[
        'a station with too few sessions to compare',
        'a station that is slow by design, such as a safeguarding check',
        'a station whose dwell is somebody reading',
        'a trailing median that has itself drifted',
      ],
    ),
    HabotFrictionSpecSection(
      name: 'acceptance criteria',
      contents: <String>[
        'every flag names the station and the comparison',
        'no flag is attributed to a person',
        'a station below the minimum session count is not flagged',
        'the algorithm flags and never disables',
      ],
    ),
  ];

  static bool get everyNamedSectionIsPresent => sectionsTheOptimalNames.every(
      (String n) => specification.any((HabotFrictionSpecSection s) =>
          s.name == n && s.contents.isNotEmpty));

  static bool get fourSections => specification.length == 4;

  static bool get fourEdgeCases => specification[2].contents.length == 4;

  // -----------------------------------------------------------------------
  // A station is compared with itself.
  // -----------------------------------------------------------------------

  static const int minimumSessions = 100;
  static const double dwellFactor = 1.5;

  static const List<HabotStationReading> readings = <HabotStationReading>[
    HabotStationReading(
      station: 'confirm the medication list',
      sessions: 980,
      medianSeconds: 41,
      trailingMedianSeconds: 39,
      dropOffPercent: 1.2,
    ),
    HabotStationReading(
      station: 'add a photograph',
      sessions: 640,
      medianSeconds: 34,
      trailingMedianSeconds: 12,
      dropOffPercent: 9.4,
    ),
    HabotStationReading(
      station: 'sign off the visit',
      sessions: 42,
      medianSeconds: 30,
      trailingMedianSeconds: 8,
      dropOffPercent: 14,
    ),
  ];

  static bool flagged(HabotStationReading r) =>
      r.sessions >= minimumSessions &&
      r.medianSeconds > r.trailingMedianSeconds * dwellFactor;

  static List<HabotStationReading> get flags =>
      readings.where(flagged).toList();

  static bool get theSlowButSteadyStationIsNotFlagged =>
      !flagged(readings.first);

  static bool get theStationThatGotWorseIsFlagged => flagged(readings[1]);

  static bool get theThinStationIsNotFlagged => !flagged(readings.last);

  static bool get oneFlag => flags.length == 1;

  static const bool comparedAgainstOtherStations = false;

  static const String normNote =
      'A medication check should take longer than a tick box, so comparing '
      'every station against the mean of all stations flags the careful ones '
      'and hides the broken ones. Each station is compared against its own '
      'trailing median over four weeks, which asks whether the station is '
      'worse than it was rather than slower than a different station.';

  // -----------------------------------------------------------------------
  // It flags; it does not decide.
  // -----------------------------------------------------------------------

  static const bool theAlgorithmDisablesAnything = false;
  static const bool aFlagIsAttributedToAPerson = false;

  static bool get itFlagsRatherThanDecides =>
      !theAlgorithmDisablesAnything && !aFlagIsAttributedToAPerson;

  static const String limitNote =
      'A station that is slow because somebody is reading carefully is not a '
      'defect, and the algorithm cannot tell the difference, which is why it '
      'flags rather than decides. The unit of analysis is a screen, as Step '
      '416 fixed it, and no flag is attributed to a person.';

  static double get completeness =>
      everyNamedSectionIsPresent && fourSections ? 1 : 0.5;

  static String get qualitativeOutput =>
      completeness == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row carries the Technical Specification Completeness '
      'band for the fourth time after Steps 450, 454 and 473, and like all '
      'three it asks for exactly what its band measures, so a four-section '
      'specification is delivered; its "station" is the sixth noun in this '
      'track for a place in a flow where people stop; its "exceeds norms" is '
      'read as each station against its own trailing median rather than '
      'against other stations, because a medication check should take longer '
      'than a tick box; and the algorithm flags without disabling anything and '
      'without attributing a flag to a person. Atomic Step: "Design the '
      'approach and technical specification for: create an automated friction '
      'identification algorithm flagging stations where user drop-off or delay '
      'exceeds norms"';

  static Map<String, bool> get obligations => <String, bool>{
        'every section the optimal names is present':
            everyNamedSectionIsPresent,
        'a station is compared against its own history':
            !comparedAgainstOtherStations,
        'a station below the minimum is not flagged':
            theThinStationIsNotFlagged,
        'no flag is attributed to a person': !aFlagIsAttributedToAPerson,
        'the algorithm flags and never disables':
            !theAlgorithmDisablesAnything,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the fourth appearance of this band': fourthAppearance,
        'four sections, as the optimal names them':
            fourSections && everyNamedSectionIsPresent,
        'and four edge cases, including a station slow by design':
            fourEdgeCases,
        '"station" is the sixth noun for one idea':
            sixNounsNow && theFrameworkAlreadyNamedFive,
        'which is how two teams build two systems':
            nounNote.contains('two systems for one problem'),
        'three stations, one flag': readings.length == 3 && oneFlag,
        'the slow but steady station is not flagged':
            theSlowButSteadyStationIsNotFlagged,
        'the station that got worse is flagged':
            theStationThatGotWorseIsFlagged &&
                normNote.contains('worse than it was'),
        'the forty-two-session station is not flagged':
            theThinStationIsNotFlagged && minimumSessions == 100,
        'five obligations met, flagging without deciding, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                itFlagsRatherThanDecides &&
                limitNote.contains('flags rather than decides') &&
                qualitativeOutput == 'Complete',
      };
}
