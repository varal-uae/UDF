/// Step 472 (GEN-05155) -- reviewing the objective for a rota people set
/// themselves, and refusing to read "locations" as a position feed.
///
/// The row: "Review the step objective: build a touch-optimized interface
/// allowing LSAs and therapists to set daily working hours, locations, and
/// service capabilities with zero desktop dependency"
/// Metric: **Requirement/Objective Comprehension Completeness** -- floor
/// "Partial understanding; unresolved ambiguities", optimal "Objective fully
/// documented & stakeholder-confirmed", ceiling "1". Complete / Partial / Not
/// Complete. BABOK v3. Assigned to **UDF**.
///
/// **Its band is Step 453's, character for character**, from the previous
/// batch: the same floor describing the failure, the same optimal requiring a
/// stakeholder, the same bare ceiling of 1 under two prose cells. Two rows in
/// this batch carry bands first seen in Batch Q; this is one of them.
///
/// **Four ambiguities.** "LSA" is never expanded -- learning support
/// assistant, probably, and a guess is not a definition. "Service
/// capabilities" has no list behind it. "Locations" does not say whose, how
/// precise, or for how long. And "zero desktop dependency" could be a
/// requirement that the phone is sufficient or a prohibition on the desktop
/// ever being used; they are different products.
///
/// **"Locations" is a named service area, not a position.** Batch P refused
/// coordinate capture at Step 428 and the same refusal holds here: a worker
/// types the area they can work in, from a list. Availability is not a
/// tracking feed, and nothing in this objective needs to know where anybody
/// is.
///
/// **Availability is what somebody can do, never what they declined.** For
/// people on agency or variable-hours terms, a rota that records gaps becomes
/// a record of who refused work. So the stored shape is positive -- windows
/// somebody has offered -- there is no "unavailable" reason field, and no
/// manager sees an availability figure as a percentage of anything.
///
/// **The optimal needs a stakeholder, so this row reports Partial**, the
/// third of the four rows in this batch that stop there.
library;

import '../governance/biometric_signoff.dart';

/// One thing the objective leaves open.
class HabotObjectiveAmbiguity {
  const HabotObjectiveAmbiguity({
    required this.phrase,
    required this.question,
    required this.proposal,
    required this.confirmer,
  });

  final String phrase;
  final String question;
  final String proposal;
  final String confirmer;
}

/// One offered window of availability.
class HabotAvailabilityWindow {
  const HabotAvailabilityWindow({
    required this.date,
    required this.fromHour,
    required this.toHour,
    required this.serviceArea,
    required this.capabilities,
  });

  final String date;
  final int fromHour;
  final int toHour;

  /// A named area from a list, never a coordinate.
  final String serviceArea;

  final List<String> capabilities;
}

/// The availability objective review.
class HabotAvailabilityObjective {
  const HabotAvailabilityObjective._();

  // -----------------------------------------------------------------------
  // A band from the previous batch.
  // -----------------------------------------------------------------------

  static const int bandFirstSeenAtStep = 453;

  static const String bandFloorRaw =
      'Partial understanding; unresolved ambiguities';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.contains('unresolved');

  /// Steps 472 and 473 carry bands first seen in Batch Q.
  static const List<int> rowsCarryingBatchQBands = <int>[472, 473];

  static bool get twoSuchRows => rowsCarryingBatchQBands.length == 2;

  // -----------------------------------------------------------------------
  // Four ambiguities.
  // -----------------------------------------------------------------------

  static const List<HabotObjectiveAmbiguity> ambiguities =
      <HabotObjectiveAmbiguity>[
    HabotObjectiveAmbiguity(
      phrase: 'LSA',
      question: 'What does LSA stand for?',
      proposal: 'Learning Support Assistant',
      confirmer: 'Head of Service Delivery',
    ),
    HabotObjectiveAmbiguity(
      phrase: 'service capabilities',
      question: 'Which capabilities, from what list?',
      proposal: 'The capability list held with each certification record',
      confirmer: 'Head of Service Delivery',
    ),
    HabotObjectiveAmbiguity(
      phrase: 'locations',
      question: 'Whose location, how precise, and for how long?',
      proposal: 'A named service area chosen from a list, held only for the '
          'day it applies to',
      confirmer: 'Head of Safeguarding',
    ),
    HabotObjectiveAmbiguity(
      phrase: 'zero desktop dependency',
      question: 'Must the phone be sufficient, or must the desktop be '
          'unusable?',
      proposal: 'The phone is sufficient; the desktop is not withdrawn',
      confirmer: 'Head of Service Delivery',
    ),
  ];

  static bool get fourAmbiguities => ambiguities.length == 4;

  static bool get everyAmbiguityHasAProposalAndAConfirmer =>
      ambiguities.every((HabotObjectiveAmbiguity a) =>
          a.proposal.isNotEmpty && a.confirmer.isNotEmpty);

  /// ZII at Step 453, LSA here, DCYN at Step 474.
  static const List<String> unexpandedAbbreviations = <String>[
    'ZII',
    'LSA',
    'DCYN',
  ];

  static bool get theThirdUnexpandedAbbreviation =>
      unexpandedAbbreviations.length == 3 &&
      unexpandedAbbreviations[1] == 'LSA';

  // -----------------------------------------------------------------------
  // A place, not a position.
  // -----------------------------------------------------------------------

  static const List<String> serviceAreas = <String>[
    'Dubai Marina',
    'Al Barsha',
    'Deira',
    'Sharjah city',
  ];

  static const bool coordinatesAreCaptured = false;
  static const bool locationIsContinuous = false;

  /// Batch P refused coordinate capture at Step 428.
  static const int theRowThatRefusedCoordinatesFirst = 428;

  static bool get locationIsANamedArea =>
      !coordinatesAreCaptured &&
      !locationIsContinuous &&
      serviceAreas.length == 4;

  static const String locationNote =
      'A worker types the area they can work in, from a list. Batch P refused '
      'coordinate capture at Step 428 and the same refusal holds here: '
      'availability is not a tracking feed, and nothing in this objective '
      'needs to know where anybody is.';

  // -----------------------------------------------------------------------
  // Offered, never declined.
  // -----------------------------------------------------------------------

  static const List<HabotAvailabilityWindow> offered =
      <HabotAvailabilityWindow>[
    HabotAvailabilityWindow(
      date: '2026-09-24',
      fromHour: 9,
      toHour: 13,
      serviceArea: 'Al Barsha',
      capabilities: <String>['one-to-one support', 'home visit'],
    ),
    HabotAvailabilityWindow(
      date: '2026-09-25',
      fromHour: 14,
      toHour: 18,
      serviceArea: 'Deira',
      capabilities: <String>['speech and language session'],
    ),
  ];

  static const bool anUnavailableReasonIsStored = false;
  static const bool managersSeeAnAvailabilityPercentage = false;

  static bool get theShapeIsPositive =>
      offered.every((HabotAvailabilityWindow w) => w.toHour > w.fromHour) &&
      !anUnavailableReasonIsStored;

  static bool get nobodyIsScoredOnAvailability =>
      !managersSeeAnAvailabilityPercentage && theShapeIsPositive;

  static const String availabilityNote =
      'For people on agency or variable-hours terms a rota that records gaps '
      'becomes a record of who refused work. The stored shape is positive -- '
      'windows somebody has offered -- there is no unavailable-reason field, '
      'and no manager sees availability as a percentage of anything.';

  // -----------------------------------------------------------------------
  // Documented, not confirmed.
  // -----------------------------------------------------------------------

  static const bool theObjectiveIsDocumented = true;
  static const bool aStakeholderHasConfirmed = false;
  static const bool aSignOffIsClaimed = false;

  static bool get theOptimalIsMet =>
      theObjectiveIsDocumented && aStakeholderHasConfirmed;

  static bool get itIsTheThirdRowAwaitingSignature =>
      HabotSignoffLedger.awaiting[2].step == 472;

  static double get comprehension => theOptimalIsMet ? 1 : 0.5;

  static String get qualitativeOutput {
    if (theOptimalIsMet) {
      return 'Complete';
    }
    return theObjectiveIsDocumented ? 'Partial' : 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: this row carries Step 453\'s band character for character, '
      'one of two rows in this batch whose band was first seen in the previous '
      'one; it leaves four phrases open -- LSA, service capabilities, '
      'locations and zero desktop dependency -- each recorded with a proposal '
      'and a named confirmer; "locations" is read as a named service area '
      'rather than a position, holding Batch P\'s refusal at Step 428; '
      'availability is stored as offered windows with no unavailable-reason '
      'field; and because its optimal requires a stakeholder it reports '
      'Partial. Atomic Step: "Review the step objective: build a '
      'touch-optimized interface allowing LSAs and therapists to set daily '
      'working hours, locations, and service capabilities with zero desktop '
      'dependency"';

  static Map<String, bool> get obligations => <String, bool>{
        'every ambiguity has a proposal and a confirmer':
            everyAmbiguityHasAProposalAndAConfirmer,
        'no sign-off is claimed': !aSignOffIsClaimed,
        'location is a named area, not a position': locationIsANamedArea,
        'availability is stored as offered windows': theShapeIsPositive,
        'nobody is scored on availability': nobodyIsScoredOnAvailability,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is Step 453\'s':
            bandFirstSeenAtStep == 453 && theFloorDescribesTheFailure,
        'one of two rows carrying a Batch Q band': twoSuchRows,
        'four ambiguities, each with a proposal and a confirmer':
            fourAmbiguities && everyAmbiguityHasAProposalAndAConfirmer,
        'LSA is the third unexpanded abbreviation':
            theThirdUnexpandedAbbreviation,
        'location is a named area from a list of four':
            locationIsANamedArea,
        'and Step 428\'s refusal holds':
            theRowThatRefusedCoordinatesFirst == 428 &&
                locationNote.contains('not a tracking feed'),
        'two offered windows, no unavailable-reason field':
            offered.length == 2 && theShapeIsPositive,
        'and no manager sees an availability percentage':
            nobodyIsScoredOnAvailability &&
                availabilityNote.contains('who refused work'),
        'documented, unconfirmed, and no sign-off claimed':
            theObjectiveIsDocumented &&
                !aStakeholderHasConfirmed &&
                itIsTheThirdRowAwaitingSignature,
        'five obligations met, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Partial',
      };
}
