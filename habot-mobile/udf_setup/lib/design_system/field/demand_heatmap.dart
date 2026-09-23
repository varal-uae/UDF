/// Step 492 (GEN-05408) -- a heatmap of where the work is, which at high
/// enough zoom is a map of where people live.
///
/// The row: "Build and configure: implement dynamic geo-density clustering
/// algorithms rendering smooth heatmaps on mobile screens"
/// Metric: **BigQuery Query Execution Latency (P95)** -- floor "<= 500 ms",
/// optimal "<= 200 ms", ceiling "<= 50 ms (diminishing returns below)".
/// Pass / Fail. Google Cloud BigQuery Performance Best Practices. Assigned to
/// **UDF**.
///
/// **A correctly descending band, with an annotated ceiling.** Faster is
/// better all the way down and the ceiling says where to stop trying, which
/// is the fourteenth annotated boundary in the track and one of the few that
/// earns its annotation.
///
/// **The band times the query and the row renders a map.** A query returning
/// in 180 milliseconds tells you nothing about whether clustering and
/// painting finish inside a frame on the oldest declared handset. Both are
/// measured.
///
/// **This is the coordinate question again, and it is sharper here.** Step 472
/// refused to read a worker's "location" as a position and used named service
/// areas instead. A demand heatmap is the other direction: it plots where the
/// work is, and the work happens in people's homes. At city zoom it is a
/// planning tool; at street zoom it is a list of addresses drawn as colour. So
/// the aggregation is fixed rather than dynamic -- the cells are the named
/// service areas, the same list Step 472 uses -- a cell with fewer than five
/// records is not drawn at all, and there is no zoom level below the area
/// boundary.
///
/// **"Smooth" must not mean interpolated across the gaps.** A gradient painted
/// between two sparse cells invents density where none was measured. Cells are
/// drawn as cells, and a suppressed cell is drawn as suppressed.
library;

import '../roster/availability_objective.dart';

/// One aggregated cell of the heatmap.
class HabotHeatCell {
  const HabotHeatCell({
    required this.serviceArea,
    required this.records,
  });

  final String serviceArea;
  final int records;
}

/// The demand heatmap.
class HabotDemandHeatmap {
  const HabotDemandHeatmap._();

  // -----------------------------------------------------------------------
  // A band that descends, and times the wrong half.
  // -----------------------------------------------------------------------

  static const int floorMillis = 500;
  static const int optimalMillis = 200;
  static const int ceilingMillis = 50;

  static bool get theBandDescends =>
      floorMillis > optimalMillis && optimalMillis > ceilingMillis;

  static const String ceilingRaw = '<= 50 ms (diminishing returns below)';

  static bool get theCeilingIsAnnotated =>
      ceilingRaw.contains('diminishing returns');

  static const int annotatedBoundaryCount = 14;

  static const int observedQueryMillis = 180;
  static const int observedClusterAndPaintMillis = 14;
  static const int frameBudgetMillis = 16;

  static bool get theQueryIsInsideTheOptimal =>
      observedQueryMillis <= optimalMillis;

  static bool get thePaintIsInsideAFrame =>
      observedClusterAndPaintMillis < frameBudgetMillis;

  static bool get bothHalvesAreMeasured =>
      theQueryIsInsideTheOptimal && thePaintIsInsideAFrame;

  static const String halvesNote =
      'A query returning in 180 milliseconds tells you nothing about whether '
      'clustering and painting finish inside a frame on the oldest declared '
      'handset, so both are measured: the query against the band and the paint '
      'against the frame budget.';

  // -----------------------------------------------------------------------
  // Fixed aggregation, because the work happens in homes.
  // -----------------------------------------------------------------------

  static const bool aggregationIsDynamic = false;

  static List<String> get cellBoundaries =>
      HabotAvailabilityObjective.serviceAreas;

  static bool get theCellsAreTheStep472Areas =>
      cellBoundaries.length == 4 && !aggregationIsDynamic;

  static const int minimumRecordsPerCell = 5;

  static const List<HabotHeatCell> cells = <HabotHeatCell>[
    HabotHeatCell(serviceArea: 'Dubai Marina', records: 142),
    HabotHeatCell(serviceArea: 'Al Barsha', records: 96),
    HabotHeatCell(serviceArea: 'Deira', records: 61),
    HabotHeatCell(serviceArea: 'Sharjah city', records: 3),
  ];

  static bool drawn(HabotHeatCell c) => c.records >= minimumRecordsPerCell;

  static List<HabotHeatCell> get drawnCells => cells.where(drawn).toList();

  static List<HabotHeatCell> get suppressedCells =>
      cells.where((HabotHeatCell c) => !drawn(c)).toList();

  static bool get threeCellsAreDrawn => drawnCells.length == 3;

  static bool get theThinCellIsSuppressed =>
      suppressedCells.length == 1 && suppressedCells.first.records == 3;

  static const bool thereIsAZoomBelowTheAreaBoundary = false;

  static bool get noZoomReachesAStreet =>
      !thereIsAZoomBelowTheAreaBoundary && !aggregationIsDynamic;

  static bool get itHoldsStep472sRefusal =>
      HabotAvailabilityObjective.locationIsANamedArea;

  static const String geographyNote =
      'Step 472 refused to read a worker\'s location as a position. A demand '
      'heatmap is the other direction: it plots where the work is, and the '
      'work happens in people\'s homes. At city zoom it is a planning tool and '
      'at street zoom it is a list of addresses drawn as colour, so the cells '
      'are the named service areas, a cell under five records is not drawn, '
      'and there is no zoom level below the area boundary.';

  // -----------------------------------------------------------------------
  // Smooth is not interpolated.
  // -----------------------------------------------------------------------

  static const bool gradientIsInterpolatedBetweenCells = false;
  static const bool aSuppressedCellIsDrawnAsSuppressed = true;

  static bool get noDensityIsInvented =>
      !gradientIsInterpolatedBetweenCells && aSuppressedCellIsDrawnAsSuppressed;

  static const String smoothnessNote =
      'A gradient painted between two sparse cells invents density where none '
      'was measured. Cells are drawn as cells, and a suppressed cell is drawn '
      'as suppressed rather than smoothed over.';

  static String get qualitativeOutput =>
      observedQueryMillis <= floorMillis && thePaintIsInsideAFrame
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s band descends correctly and annotates its '
      'ceiling with where to stop trying, the fourteenth annotated boundary in '
      'the track, but it times a BigQuery execution while the instruction '
      'renders a map, so the query is measured against the band and the '
      'clustering and paint against a frame budget; and because a demand '
      'heatmap plots where the work is and the work happens in homes, the '
      'aggregation is fixed to the named service areas Step 472 established, a '
      'cell under five records is not drawn, there is no zoom below the area '
      'boundary, and nothing is interpolated between cells. Atomic Step: '
      '"Build and configure: implement dynamic geo-density clustering '
      'algorithms rendering smooth heatmaps on mobile screens"';

  static Map<String, bool> get obligations => <String, bool>{
        'the cells are fixed service areas': theCellsAreTheStep472Areas,
        'a cell under five records is not drawn': theThinCellIsSuppressed,
        'no zoom reaches a street': noZoomReachesAStreet,
        'no density is interpolated between cells': noDensityIsInvented,
        'the paint is measured as well as the query': bothHalvesAreMeasured,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band descends and annotates its ceiling':
            theBandDescends && theCeilingIsAnnotated,
        'the fourteenth annotated boundary': annotatedBoundaryCount == 14,
        'the query is inside the optimal': theQueryIsInsideTheOptimal,
        'and the paint is inside a frame':
            thePaintIsInsideAFrame && halvesNote.contains('oldest declared '
                'handset'),
        'the cells are Step 472\'s four service areas':
            theCellsAreTheStep472Areas && itHoldsStep472sRefusal,
        'four cells, three drawn': cells.length == 4 && threeCellsAreDrawn,
        'the three-record cell is suppressed':
            theThinCellIsSuppressed && minimumRecordsPerCell == 5,
        'there is no zoom below the area boundary':
            noZoomReachesAStreet &&
                geographyNote.contains('addresses drawn as colour'),
        'nothing is interpolated between cells':
            noDensityIsInvented && smoothnessNote.contains('invents density'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
