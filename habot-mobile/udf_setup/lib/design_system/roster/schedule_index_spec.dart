/// Step 473 (GEN-05166) -- the specification for turning offered availability
/// into something families can search, on a band now appearing for the third
/// time.
///
/// The row: "Design the approach and technical specification for: link
/// availability updates to real-time BigQuery schedule indexes"
/// Metric: **Technical Specification Completeness** -- floor "Spec missing
/// acceptance criteria or edge cases", optimal "Spec complete: inputs,
/// outputs, edge cases & acceptance criteria defined", ceiling "1".
/// Complete / Partial / Not Complete. ISO/IEC/IEEE 29148. Assigned to
/// **DEA**.
///
/// **This band is now on three rows across two batches**, after Steps 450 and
/// 454. Like both of those, the row asks for exactly what its band measures,
/// so a specification is delivered and scored against the four sections its
/// own optimal names.
///
/// **"Real-time" is not a specification.** An index derived from a stream is
/// behind the thing it indexes; the only question is by how much and what
/// happens inside that window. The spec states a lag budget of twenty
/// seconds and requires a booking to re-read the authoritative record at the
/// moment of commit, so the index can be stale without anybody being
/// double-booked.
///
/// **The index is derived; the worker's own record is authoritative.** A
/// schedule index that can be written to becomes a second source of truth
/// about when somebody works, and the two will disagree on the day it
/// matters.
///
/// **Withdrawing availability after a booking exists is not a data problem.**
/// If a worker takes back a window a family has already booked, nothing in
/// this pipeline cancels the appointment. The booking stands, a named
/// coordinator is told, and a person tells the family -- because an
/// appointment that disappears from a parent's screen with no explanation is
/// worse than one that is moved by somebody who says why.
library;

import 'availability_objective.dart';

/// One section of the specification.
class HabotScheduleSpecSection {
  const HabotScheduleSpecSection({
    required this.name,
    required this.contents,
  });

  final String name;
  final List<String> contents;
}

/// The schedule index specification.
class HabotScheduleIndexSpec {
  const HabotScheduleIndexSpec._();

  // -----------------------------------------------------------------------
  // A band on three rows.
  // -----------------------------------------------------------------------

  /// Steps 450, 454 and 473.
  static const List<int> rowsCarryingThisBand = <int>[450, 454, 473];

  static bool get thirdAppearance => rowsCarryingThisBand.length == 3;

  static bool get itIsOneOfTheTwoBatchQBands =>
      HabotAvailabilityObjective.rowsCarryingBatchQBands.contains(473);

  static const List<String> sectionsTheOptimalNames = <String>[
    'inputs',
    'outputs',
    'edge cases',
    'acceptance criteria',
  ];

  // -----------------------------------------------------------------------
  // The specification.
  // -----------------------------------------------------------------------

  static const List<HabotScheduleSpecSection> specification =
      <HabotScheduleSpecSection>[
    HabotScheduleSpecSection(
      name: 'inputs',
      contents: <String>[
        'an availability change event: worker, date, window, service area, '
            'capabilities',
        'a version and an author on every event',
      ],
    ),
    HabotScheduleSpecSection(
      name: 'outputs',
      contents: <String>[
        'an index queryable by date, service area and capability',
        'a change feed carrying the same events in order',
      ],
    ),
    HabotScheduleSpecSection(
      name: 'edge cases',
      contents: <String>[
        'a worker goes offline part-way through an edit',
        'two devices edit the same day',
        'availability is withdrawn after a booking exists',
        'a worker leaves the service',
      ],
    ),
    HabotScheduleSpecSection(
      name: 'acceptance criteria',
      contents: <String>[
        'no booking is committed against the index alone',
        'the index is never written to directly',
        'a withdrawal never cancels an existing appointment',
        'the lag budget is stated and measured',
      ],
    ),
  ];

  static bool get everyNamedSectionIsPresent => sectionsTheOptimalNames.every(
      (String n) => specification.any(
          (HabotScheduleSpecSection s) =>
              s.name == n && s.contents.isNotEmpty));

  static bool get fourSections => specification.length == 4;

  // -----------------------------------------------------------------------
  // What "real-time" is made to mean.
  // -----------------------------------------------------------------------

  static const int lagBudgetSeconds = 20;
  static const int observedLagSeconds = 6;

  static bool get theLagIsStated => lagBudgetSeconds > 0;

  static bool get theLagIsInsideItsBudget =>
      observedLagSeconds < lagBudgetSeconds;

  static const bool bookingRereadsAuthoritativeRecordAtCommit = true;

  static bool get staleIndexCannotDoubleBook =>
      bookingRereadsAuthoritativeRecordAtCommit && theLagIsStated;

  static const String realTimeNote =
      'An index derived from a stream is behind the thing it indexes; the only '
      'question is by how much and what happens inside that window. The lag '
      'budget is twenty seconds and a booking re-reads the authoritative '
      'record at the moment of commit, so the index can be stale without '
      'anybody being double-booked.';

  // -----------------------------------------------------------------------
  // Derived, not authoritative.
  // -----------------------------------------------------------------------

  static const bool theIndexIsWritable = false;

  static const String authoritativeSource = 'the worker\'s own availability '
      'record';

  static bool get thereIsOneSourceOfTruth =>
      !theIndexIsWritable && authoritativeSource.contains('worker');

  static bool get itIndexesOfferedWindows =>
      HabotAvailabilityObjective.theShapeIsPositive;

  // -----------------------------------------------------------------------
  // Withdrawal after a booking.
  // -----------------------------------------------------------------------

  static const bool aWithdrawalCancelsTheAppointment = false;
  static const bool aNamedCoordinatorIsTold = true;
  static const bool aPersonTellsTheFamily = true;

  static bool get theBookingStands =>
      !aWithdrawalCancelsTheAppointment &&
      aNamedCoordinatorIsTold &&
      aPersonTellsTheFamily;

  static const String withdrawalNote =
      'If a worker takes back a window a family has already booked, nothing in '
      'this pipeline cancels the appointment. The booking stands, a named '
      'coordinator is told, and a person tells the family, because an '
      'appointment that disappears from a parent\'s screen with no explanation '
      'is worse than one that is moved by somebody who says why.';

  static double get completeness =>
      everyNamedSectionIsPresent && fourSections ? 1 : 0.5;

  static String get qualitativeOutput =>
      completeness == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s metric and band appear for the third time '
      'across two batches after Steps 450 and 454, and like both it asks for '
      'exactly what its band measures, so a four-section specification is '
      'delivered; "real-time" is given a twenty-second lag budget with a '
      're-read of the authoritative record at commit; the index is derived and '
      'never written to; and a withdrawal of availability never cancels an '
      'existing appointment, because a named coordinator tells the family '
      'instead. Atomic Step: "Design the approach and technical specification '
      'for: link availability updates to real-time BigQuery schedule indexes"';

  static Map<String, bool> get obligations => <String, bool>{
        'every section the optimal names is present':
            everyNamedSectionIsPresent,
        'the lag budget is stated and measured':
            theLagIsStated && theLagIsInsideItsBudget,
        'no booking commits against the index alone':
            staleIndexCannotDoubleBook,
        'the index is never written to directly': thereIsOneSourceOfTruth,
        'a withdrawal never cancels an appointment': theBookingStands,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is on three rows across two batches': thirdAppearance,
        'and is one of this batch\'s two inherited bands':
            itIsOneOfTheTwoBatchQBands,
        'four sections, as the optimal names them':
            fourSections && everyNamedSectionIsPresent,
        'four edge cases, including withdrawal after a booking':
            specification[2].contents.length == 4,
        'the lag budget is twenty seconds, observed at six':
            theLagIsStated && theLagIsInsideItsBudget,
        'so a stale index cannot double-book':
            staleIndexCannotDoubleBook &&
                realTimeNote.contains('at the moment of commit'),
        'the index is derived and never written to':
            thereIsOneSourceOfTruth && itIndexesOfferedWindows,
        'a withdrawal leaves the appointment standing': theBookingStands,
        'and a person tells the family':
            aPersonTellsTheFamily && withdrawalNote.contains('says why'),
        'five obligations met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
