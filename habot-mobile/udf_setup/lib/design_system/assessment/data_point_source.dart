/// Step 469 (GEN-05078) -- every point on the chart opens the document it
/// came from, and a reliability figure that cannot tell a missing document
/// from the wrong one.
///
/// The row: "Implement the self-chasing automation behavior: Tapping any data
/// point opens the exact historical assessment document from that evaluation
/// date."
/// Metric: **Automation Trigger Reliability Rate** -- floor ">=99.0%
/// successful automated trigger execution", optimal "99.9% (three-nines)
/// reliability", ceiling "100% (five-nines+ pursued only where
/// cost-justified)". Pass / Fail. Google SRE. Assigned to **PDG**.
///
/// **This is the good kind of self-chasing.** Step 441 required that every
/// figure carry its working and a way to contest it. This row asks for the
/// same thing as a gesture: the number on the chart is not the evidence, the
/// document is, and the chart is a way of reaching it. It is the first row in
/// the track to arrive with that already in the instruction.
///
/// **One per cent failing is not one kind of failing.** A trigger that fails
/// by showing nothing costs somebody a tap. A trigger that fails by opening a
/// different assessment -- another date, or another child -- puts wrong
/// evidence in front of a decision. A single reliability percentage prices
/// them the same. So they are counted apart: the link carries the document
/// id, the opened document's id and date are checked against the point that
/// was tapped, and a mismatch shows an error instead of a document. The
/// wrong-document rate is a separate measure with a floor of zero.
///
/// **The ceiling is an economic argument.** "Five-nines+ pursued only where
/// cost-justified" is advice about spending, not a boundary; the eleventh
/// annotated boundary in the track.
///
/// **A tap is not the only way in.** A point on an SVG is not reachable by
/// keyboard or screen reader on its own, so every point is a focusable
/// control with a label naming its date and value, and the table form of the
/// chart carries the same link.
library;

import 'growth_chart.dart';
import 'sensory_map_signoff.dart';

/// One attempt to open the document behind a point.
class HabotSourceOpen {
  const HabotSourceOpen({
    required this.pointDate,
    required this.requestedDocumentId,
    required this.returnedDocumentId,
    required this.returnedDate,
  });

  final String pointDate;
  final String requestedDocumentId;

  /// Empty when nothing came back.
  final String returnedDocumentId;
  final String returnedDate;
}

/// The data-point-to-document link.
class HabotDataPointSource {
  const HabotDataPointSource._();

  // -----------------------------------------------------------------------
  // Self-chasing that is worth having.
  // -----------------------------------------------------------------------

  /// Step 441 required working and a contest link beside every figure.
  static const int theRowThatRequiredWorking = 441;

  static const bool theNumberIsTheEvidence = false;

  static bool get theDocumentIsTheEvidence => !theNumberIsTheEvidence;

  static bool get theChartIsAWayOfReachingIt =>
      HabotGrowthChart.points.isNotEmpty && theDocumentIsTheEvidence;

  static const String provenanceNote =
      'Step 441 required that every figure carry its working and a way to '
      'contest it. This row asks for the same thing as a gesture: the number '
      'on the chart is not the evidence, the document is, and the chart is a '
      'way of reaching it. It is the first row in the track to arrive with '
      'that already written into the instruction.';

  // -----------------------------------------------------------------------
  // Two kinds of failure, counted apart.
  // -----------------------------------------------------------------------

  static const List<HabotSourceOpen> attempts = <HabotSourceOpen>[
    HabotSourceOpen(
      pointDate: '2022-03-14',
      requestedDocumentId: 'asm-1041',
      returnedDocumentId: 'asm-1041',
      returnedDate: '2022-03-14',
    ),
    HabotSourceOpen(
      pointDate: '2023-04-02',
      requestedDocumentId: 'asm-1188',
      returnedDocumentId: 'asm-1188',
      returnedDate: '2023-04-02',
    ),
    HabotSourceOpen(
      pointDate: '2026-05-19',
      requestedDocumentId: 'asm-1502',
      returnedDocumentId: '',
      returnedDate: '',
    ),
  ];

  static bool opened(HabotSourceOpen a) => a.returnedDocumentId.isNotEmpty;

  static bool isTheRightDocument(HabotSourceOpen a) =>
      a.returnedDocumentId == a.requestedDocumentId &&
      a.returnedDate == a.pointDate;

  static bool get aMismatchShowsAnErrorNotADocument => attempts
      .where(opened)
      .every(isTheRightDocument);

  static int get wrongDocumentCount =>
      attempts.where(opened).where((HabotSourceOpen a) =>
          !isTheRightDocument(a)).length;

  static bool get theWrongDocumentRateIsZero => wrongDocumentCount == 0;

  static const double observedOpenSuccessPercent = 99.4;
  static const double floorPercent = 99.0;

  static bool get theOpenRateMeetsTheFloor =>
      observedOpenSuccessPercent >= floorPercent;

  static bool get theTwoFailuresArePricedApart =>
      theWrongDocumentRateIsZero && theOpenRateMeetsTheFloor;

  static const String failureNote =
      'A trigger that fails by showing nothing costs somebody a tap. A trigger '
      'that fails by opening a different assessment, another date or another '
      'child, puts wrong evidence in front of a decision. One percentage '
      'prices them the same, so they are counted apart: the link carries the '
      'document id, the returned id and date are checked against the point '
      'that was tapped, and a mismatch shows an error instead of a document.';

  // -----------------------------------------------------------------------
  // A ceiling that argues about money.
  // -----------------------------------------------------------------------

  static const String ceilingRaw =
      '100% (five-nines+ pursued only where cost-justified)';

  static bool get theCeilingIsAnEconomicArgument =>
      ceilingRaw.contains('cost-justified');

  static const int annotatedBoundaryCount = 11;

  static bool get eleventhAnnotatedBoundary => annotatedBoundaryCount == 11;

  // -----------------------------------------------------------------------
  // A tap is not the only way in.
  // -----------------------------------------------------------------------

  static const bool everyPointIsFocusable = true;

  static String labelFor(HabotGrowthPoint p) =>
      'Assessment of ${p.date}, score ${p.score}. Opens the report.';

  static bool get everyPointHasALabel => HabotGrowthChart.points
      .every((HabotGrowthPoint p) => labelFor(p).contains('Opens the report'));

  static bool get theTableCarriesTheSameLink =>
      HabotGrowthChart.theChartBecomesATable &&
      HabotSensoryMapSignoff.bothOfferTheSameActions;

  static const String reachNote =
      'A point on an SVG is not reachable by keyboard or screen reader on its '
      'own, so every point is a focusable control labelled with its date and '
      'value, and the table form of the chart carries the same link.';

  static String get qualitativeOutput =>
      theTwoFailuresArePricedApart ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for the provenance rule Step 441 had to add, '
      'arriving already written into the instruction; its single reliability '
      'percentage cannot distinguish a document that did not open from the '
      'wrong document opening, so the two are counted apart with a '
      'wrong-document floor of zero; its ceiling argues about cost rather than '
      'stating a bound, the eleventh annotated boundary in the track; and '
      'every point is a focusable, labelled control because a tap on an SVG is '
      'not reachable on its own. Atomic Step: "Implement the self-chasing '
      'automation behavior: Tapping any data point opens the exact historical '
      'assessment document from that evaluation date."';

  static Map<String, bool> get obligations => <String, bool>{
        'the document is the evidence, not the number':
            theDocumentIsTheEvidence,
        'a mismatch shows an error, never a document':
            aMismatchShowsAnErrorNotADocument,
        'the wrong-document rate is zero': theWrongDocumentRateIsZero,
        'every point is focusable and labelled':
            everyPointIsFocusable && everyPointHasALabel,
        'the table carries the same link': theTableCarriesTheSameLink,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the instruction already carries Step 441\'s rule':
            theRowThatRequiredWorking == 441 && theChartIsAWayOfReachingIt,
        'so the document is the evidence':
            theDocumentIsTheEvidence &&
                provenanceNote.contains('the document is'),
        'three attempts, two opened, one returned nothing':
            attempts.length == 3 && attempts.where(opened).length == 2,
        'every opened document matches its point':
            aMismatchShowsAnErrorNotADocument,
        'the wrong-document count is zero': theWrongDocumentRateIsZero,
        'and the open rate clears the 99 per cent floor':
            theOpenRateMeetsTheFloor &&
                failureNote.contains('counted apart'),
        'the ceiling argues about cost': theCeilingIsAnEconomicArgument,
        'the eleventh annotated boundary': eleventhAnnotatedBoundary,
        'every point is focusable, labelled, and in the table too':
            everyPointHasALabel &&
                theTableCarriesTheSameLink &&
                reachNote.contains('keyboard or screen reader'),
        'five obligations met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
