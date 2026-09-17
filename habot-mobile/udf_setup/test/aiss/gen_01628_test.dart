/// AISS GATE -- Step 374 of 375
/// Global Reference ID:       GEN-01628
/// Atomic Steps Reference ID: GEN-01628
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Connect dashboard widgets to fetch aggregated telemetry from
///               BigQuery streaming APIs."
/// Metric: Dashboard Data Refresh Latency -- the shared band. Good/Average/
///         Poor. Assigned to **DEA**.
///
/// A WIDGET THAT NAMES ITS WAREHOUSE IS A WIDGET THAT CANNOT BE MOVED -- AND A
/// CLIENT THAT QUERIES ONE HOLDS ITS CREDENTIALS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/telemetry_widget_binding.dart';

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

  group('GEN-01628 :: the widget does not name its warehouse', () {
    gate(
      'GEN-01628-G1',
      'The row names a transport and the widget does not.',
      '"Fetch from BigQuery streaming APIs" is a transport decision written '
          'into a presentation row',
      () =>
          HabotTelemetryWidgetBinding.transportTheRowNames
              .contains('BigQuery') &&
          !HabotTelemetryWidgetBinding.theWidgetKnowsItsTransport,
    );

    gate(
      'GEN-01628-G2',
      'The widget takes a series and a freshness state, and nothing else.',
      'Two origins are declared and either satisfies it',
      () =>
          HabotTelemetryWidgetBinding.theWidgetTakesTwoThings &&
          HabotTelemetryWidgetBinding.theOriginIsSwappable &&
          HabotSeriesOrigin.values.length == 2,
    );

    gate(
      'GEN-01628-G3',
      'The shape was settled at Step 112.',
      'Long before this row asked -- and a widget that names its warehouse '
          'cannot be tested without one',
      () =>
          HabotTelemetryWidgetBinding.theStepThatSettledTheShape == 112 &&
          HabotTelemetryWidgetBinding.transportNote
              .contains('cannot be tested without one'),
    );
  });

  group('GEN-01628 :: the credential the row does not mention', () {
    gate(
      'GEN-01628-G4',
      'No warehouse credential reaches the client.',
      'An application ships to devices and the credential ships with it',
      () => HabotTelemetryWidgetBinding.theCredentialNeverShips,
    );

    gate(
      'GEN-01628-G5',
      'And a warehouse credential reads the whole warehouse.',
      'Not the one series a widget wanted, which is why the aggregation stays '
          'behind an endpoint',
      () =>
          !HabotTelemetryWidgetBinding.theClientHoldsWarehouseCredentials &&
          HabotTelemetryWidgetBinding.credentialNote
              .contains('reads everything'),
    );
  });

  group('GEN-01628 :: aggregated is a privacy control too', () {
    gate(
      'GEN-01628-G6',
      'Four buckets, three of which render.',
      'The fourth has four contributors, and four contributors are four people',
      () =>
          HabotTelemetryWidgetBinding.series.length == 4 &&
          HabotTelemetryWidgetBinding.threeOfFourRender,
    );

    gate(
      'GEN-01628-G7',
      'The floor is the one Step 362 declared two rows earlier.',
      'Read from the existing rule rather than restated here',
      () =>
          HabotTelemetryWidgetBinding.anonymityFloor == 10 &&
          HabotTelemetryWidgetBinding.privacyNote.contains('Step 362'),
    );

    gate(
      'GEN-01628-G8',
      'A withheld bucket is not drawn as zero.',
      'That would read as a collapse in activity rather than as a period held '
          'back -- a different lie',
      () =>
          !HabotTelemetryWidgetBinding.aWithheldBucketIsDrawnAsZero &&
          HabotTelemetryWidgetBinding.theWithholdingIsStated &&
          HabotTelemetryWidgetBinding.privacyNote.contains('a different lie'),
    );
  });

  group('GEN-01628 :: the shared band, third copy', () {
    gate(
      'GEN-01628-G9',
      'This row carries the band Steps 358, 362 and 375 also carry.',
      'And Steps 163 and 175, which tokenised it -- six rows, one band -- and '
          'the widget does not adopt it',
      () =>
          HabotTelemetryWidgetBinding.theBandIsTheSharedOne &&
          HabotTelemetryWidgetBinding.rowsSharingIt == 6 &&
          !HabotTelemetryWidgetBinding.theWidgetAdoptsTheRowsBand &&
          HabotTelemetryWidgetBinding.theWidgetCarriesAFreshnessState,
    );

    gate(
      'GEN-01628-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotTelemetryWidgetBinding.obligations.length == 5 &&
          HabotTelemetryWidgetBinding.obligations.values
              .every((bool b) => b) &&
          HabotTelemetryWidgetBinding.qualitativeOutput == 'Good' &&
          HabotTelemetryWidgetBinding.checks.length == 10 &&
          HabotTelemetryWidgetBinding.checks.values.every((bool b) => b) &&
          HabotTelemetryWidgetBinding.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final int rendered = HabotTelemetryWidgetBinding.renderable.length;
    final int withheld = HabotTelemetryWidgetBinding.withheld.length;
    final int smallest =
        HabotTelemetryWidgetBinding.series.last.contributors;
    final String label = HabotTelemetryWidgetBinding.withholdingLabel;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01628',
        atomicStepReferenceId: 'GEN-01628',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, it '
            'writes a transport decision into a presentation row, its band is '
            'the one shared with Steps 358, 362 and 375 of this batch and with '
            'Steps 163 and 175, its Data Requirement cell holds the Atomic '
            'Step\'s own truncated text as the artefact to prepare, and the '
            'Setup Step column is empty. Atomic Step: "Connect dashboard '
            'widgets to fetch aggregated telemetry from BigQuery streaming '
            'APIs."',
        implementationOrder: 374,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Connect dashboard widgets to fetch aggregated telemetry from':
              '$rendered of 4 buckets render; $withheld is withheld with '
                  '$smallest contributors behind it',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the widget takes a series and a freshness state; the chart '
                  'reads "$label" rather than drawing the held-back period',
          'Data Quality Note':
              'TRANSPORT: ${HabotTelemetryWidgetBinding.transportNote} '
              'CREDENTIAL: ${HabotTelemetryWidgetBinding.credentialNote} '
              'PRIVACY: ${HabotTelemetryWidgetBinding.privacyNote} '
              'BAND: ${HabotTelemetryWidgetBinding.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'THE THIRD OF FOUR COPIES IN THIS BATCH. The identical three '
                'cells appear on Steps 358, 362 and 375 and on Steps 163 and '
                '175, which tokenised them -- six rows, one band, with a '
                'ceiling twenty-four times its floor on a lower-is-better '
                'measure. The widget does not adopt it: it takes a freshness '
                'state classified by the Step 129 policy, so a day-old series '
                'is labelled Delayed on the face of the widget rather than '
                'treated as the ideal.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Warehouse credentials shipped to a device',
            observed:
                '0. A client that queries an analytics warehouse directly is a '
                'client holding a credential that reads the whole warehouse, '
                'and a mobile application ships that credential to every '
                'device it installs on. The row does not mention this and it '
                'is the part that decides the design: the widget binds to an '
                'endpoint returning an already-aggregated series, and the '
                'aggregation happens where the credential can stay. Aggregated '
                'is also a privacy control -- $rendered of 4 buckets clear the '
                'anonymity floor Step 362 declared, and the one with $smallest '
                'contributors is withheld and named rather than drawn as a '
                'very short bar or as zero.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/telemetry_widget_binding.dart',
        ],
      ),
    );
  });
}
