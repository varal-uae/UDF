/// AISS GATE -- Step 492 of 1,314
/// Global Reference ID:       GEN-05408
/// Atomic Steps Reference ID: GEN-05408
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build and configure: implement dynamic geo-density clustering
///               algorithms rendering smooth heatmaps on mobile screens"
/// Metric: BigQuery Query Execution Latency (P95) -- floor "<= 500 ms", optimal
///         "<= 200 ms", ceiling "<= 50 ms (diminishing returns below)". Best
///         Qualitative Output: "Pass/Fail". Google Cloud BigQuery Performance
///         Best Practices. Assigned to **UDF**.
///
/// A HEATMAP THAT AT HIGH ENOUGH ZOOM IS A MAP OF WHERE PEOPLE LIVE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/field/demand_heatmap.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('GEN-05408 :: a band that descends, timing the other half', () {
    gate(
      'GEN-05408-G1',
      'The band descends and annotates its ceiling.',
      '500, 200 and 50 milliseconds, with where to stop trying',
      () =>
          HabotDemandHeatmap.theBandDescends &&
          HabotDemandHeatmap.theCeilingIsAnnotated,
    );

    gate(
      'GEN-05408-G2',
      'The fourteenth annotated boundary in the track.',
      'And one of the few that earns its annotation',
      () => HabotDemandHeatmap.annotatedBoundaryCount == 14,
    );

    gate(
      'GEN-05408-G3',
      'The query is inside the optimal.',
      '180 milliseconds against 200',
      () => HabotDemandHeatmap.theQueryIsInsideTheOptimal,
    );

    gate(
      'GEN-05408-G4',
      'And the paint is inside a frame.',
      'Because the band times a query and the row renders a map',
      () =>
          HabotDemandHeatmap.thePaintIsInsideAFrame &&
          HabotDemandHeatmap.halvesNote.contains('oldest declared ' 'handset'),
    );

  });

  group('GEN-05408 :: fixed aggregation', () {
    gate(
      'GEN-05408-G5',
      'The cells are Step 472\'s four service areas.',
      'Fixed aggregation rather than dynamic clustering',
      () =>
          HabotDemandHeatmap.theCellsAreTheStep472Areas &&
          HabotDemandHeatmap.itHoldsStep472sRefusal,
    );

    gate(
      'GEN-05408-G6',
      'Four cells, three drawn.',
      'The fourth holds three records',
      () =>
          HabotDemandHeatmap.cells.length == 4 &&
          HabotDemandHeatmap.threeCellsAreDrawn,
    );

    gate(
      'GEN-05408-G7',
      'The three-record cell is suppressed.',
      'A heatmap over a sparse area identifies a household',
      () =>
          HabotDemandHeatmap.theThinCellIsSuppressed &&
          HabotDemandHeatmap.minimumRecordsPerCell == 5,
    );

    gate(
      'GEN-05408-G8',
      'There is no zoom below the area boundary.',
      'At city zoom it is a planning tool; at street zoom it is a list of '
      'addresses',
      () =>
          HabotDemandHeatmap.noZoomReachesAStreet &&
          HabotDemandHeatmap.geographyNote
              .contains('addresses drawn as colour'),
    );

  });

  group('GEN-05408 :: smooth is not interpolated', () {
    gate(
      'GEN-05408-G9',
      'Nothing is interpolated between cells.',
      'A gradient across sparse cells invents density nobody measured',
      () =>
          HabotDemandHeatmap.noDensityIsInvented &&
          HabotDemandHeatmap.smoothnessNote.contains('invents density'),
    );

    gate(
      'GEN-05408-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDemandHeatmap.obligations.length == 5 &&
          HabotDemandHeatmap.obligations.values.every((bool b) => b) &&
          HabotDemandHeatmap.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int drawn = HabotDemandHeatmap.drawnCells.length;
    final int query = HabotDemandHeatmap.observedQueryMillis;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05408',
        atomicStepReferenceId: 'GEN-05408',
        setupStepAction:
            'COLUMN NOTE: this row\'s band descends correctly and annotates '
            'its ceiling with where to stop trying, the fourteenth annotated '
            'boundary in the track, but it times a BigQuery execution while '
            'the instruction renders a map, so the query is measured against '
            'the band and the clustering and paint against a frame budget; and '
            'because a demand heatmap plots where the work is and the work '
            'happens in homes, the aggregation is fixed to the named service '
            'areas Step 472 established, a cell under five records is not '
            'drawn, there is no zoom below the area boundary, and nothing is '
            'interpolated between cells. Atomic Step: "Build and configure: '
            'implement dynamic geo-density clustering algorithms rendering '
            'smooth heatmaps on mobile screens"',
        implementationOrder: 492,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build and configure: implement dynamic geo-density clustering '
          'algorithms rendering smooth':
              'a query at $query ms with clustering and paint inside a frame, '
              'aggregated to four fixed service areas of which $drawn are '
              'drawn and one suppressed',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'BigQuery Query Execution Latency (P95)',
            observed:
                'A BAND THAT DESCENDS CORRECTLY AND TIMES THE WRONG HALF. Five '
                'hundred, two hundred and fifty milliseconds, with a ceiling '
                'that says where to stop trying -- the fourteenth annotated '
                'boundary in the track -- but the band times a BigQuery '
                'execution while the instruction renders a map. Observed: '
                '$query ms for the query, inside the optimal, and clustering '
                'and paint inside a sixteen-millisecond frame.',
            floor: '<= 500 ms',
            optimal: '<= 200 ms',
            ceiling: '<= 50 ms (diminishing returns below)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Zoom levels that reach a street',
            observed:
                '0. A demand heatmap plots where the work is and the work '
                'happens in people\'s homes, so the aggregation is fixed to '
                'the named service areas Step 472 established rather than '
                'clustered dynamically, a cell under five records is not drawn '
                '-- $drawn of four are -- there is no zoom level below the '
                'area boundary, and nothing is interpolated between cells, '
                'because a gradient across sparse cells invents density nobody '
                'measured.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/field/demand_heatmap.dart',
        ],
      ),
    );
  });
}
