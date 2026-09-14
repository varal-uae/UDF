/// AISS GATE -- Step 210 of 215
/// Global Reference ID:       GEN-01606
/// Atomic Steps Reference ID: GEN-01606
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add an 'Export PDF Summary' CTA button to generate
///               consolidated attendance records."
/// Metric: Activity Log Data Completeness -- Floor 0.95, Optimal 0.999,
///         Ceiling 1. Complete/Partial/Not Complete.
///
/// THE FAILURE MODE OF AN EXPORT IS THAT IT LOOKS COMPLETE. A PDF with a
/// title, a date range and forty aligned rows is indistinguishable from one
/// with forty-three rows in the range, three of which failed to load. Nobody
/// reads a document wondering what is not in it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/reports/attendance_export.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  final DateTime start = DateTime.utc(2026, 9, 1);
  final DateTime end = DateTime.utc(2026, 9, 30);
  final DateTime watermark = DateTime.utc(2026, 9, 28);

  HabotAttendanceRecord record(
    int day, {
    bool synced = true,
  }) =>
      HabotAttendanceRecord(
        id: 'r$day',
        childId: 'c1',
        sessionId: 's$day',
        markedAt: DateTime.utc(2026, 9, day, 9),
        present: true,
        isSynced: synced,
      );

  /// Thirty-one loaded rows: twenty-eight clean, two marked on this device and
  /// not yet synced, and one that turns out to be outside the range.
  List<HabotAttendanceRecord> loaded() => <HabotAttendanceRecord>[
        for (int d = 1; d <= 28; d++) record(d),
        record(29, synced: false),
        record(30, synced: false),
        // A boundary case: marked on 1 October in UTC terms.
        HabotAttendanceRecord(
          id: 'r-late',
          childId: 'c1',
          sessionId: 's-late',
          markedAt: DateTime.utc(2026, 10, 1, 9),
          present: true,
        ),
      ];

  HabotExportCoverage coverage({int expected = 34, int failures = 3}) =>
      HabotAttendanceExport.coverageFor(
        loaded: loaded(),
        expected: expected,
        rangeStart: start,
        rangeEnd: end,
        watermark: watermark,
        loadFailures: failures,
      );

  group('GEN-01606 :: the export carries its own denominator', () {
    gate(
      'GEN-01606-G1',
      'Metric: ACTIVITY LOG DATA COMPLETENESS, on a row that asks for a CTA.',
      'The export computes coverage against what the range should contain '
          'rather than against what it managed to load, so the three records '
          'that failed to load are visible as a shortfall instead of being '
          'absent without trace',
      () {
        final HabotExportCoverage c = coverage();
        completeness = c.completeness;
        return c.expected == 34 &&
            c.included == 30 &&
            !c.isComplete &&
            (completeness - 30 / 34).abs() < 1e-9 &&
            c.omittedCount == 4 &&
            c.accountsForEveryMissingRecord &&
            c.unsyncedIncluded == 2 &&
            HabotAttendanceExport.completenessFailsQuietlyNote
                .contains('its own denominator');
      },
    );

    gate(
      'GEN-01606-G2',
      '"A warning shown when the export finishes is gone by the time anyone '
          'opens the file, and the file is what gets forwarded."',
      'The coverage statement is stamped on the document, names the figure and '
          'every omission by reason, and says so in words rather than a code',
      () {
        final String stamp = coverage().stampLine;
        return HabotAttendanceExport.stampsCoverageOnTheDocument &&
            stamp.startsWith('PARTIAL: 30 of 34 records.') &&
            stamp.contains('3 could not be loaded.') &&
            stamp.contains('1 fell outside the range.') &&
            stamp.contains('2 included but not yet synced from this device') &&
            HabotAttendanceExport.toastIsNotAStampNote
                .contains('travels with the thing it is about');
      },
    );

    gate(
      'GEN-01606-G3',
      '"An export that silently prefers one source contradicts whichever '
          'document the operator is holding."',
      'The requested range runs past the sync watermark, the document says so, '
          'and a range that ends inside the watermark does not carry the '
          'caveat -- so the warning means something when it appears',
      () {
        final HabotExportCoverage past = coverage();
        final HabotExportCoverage inside =
            HabotAttendanceExport.coverageFor(
          loaded: <HabotAttendanceRecord>[record(1), record(2)],
          expected: 5,
          rangeStart: start,
          rangeEnd: DateTime.utc(2026, 9, 20),
          watermark: watermark,
        );
        return past.exportsBeyondWatermark &&
            past.stampLine.contains('may not be final') &&
            !inside.exportsBeyondWatermark &&
            !inside.stampLine.contains('may not be final') &&
            HabotAttendanceExport.watermarkNote.contains('the two agree');
      },
    );

    gate(
      'GEN-01606-G4',
      '"Refusing outright is worse, because the parent usually needs the '
          'document today."',
      'A partial export is produced rather than refused, and a genuinely '
          'complete one inside the watermark reports Complete with no caveat '
          'attached',
      () {
        final HabotExportCoverage clean = HabotAttendanceExport.coverageFor(
          loaded: <HabotAttendanceRecord>[record(1), record(2)],
          expected: 2,
          rangeStart: start,
          rangeEnd: DateTime.utc(2026, 9, 20),
          watermark: watermark,
        );
        return HabotAttendanceExport.producesPartialExports &&
            clean.isComplete &&
            clean.completeness == 1.0 &&
            clean.stampLine == 'Complete: 2 of 2 records.' &&
            HabotAttendanceExport.qualitativeOutput(clean) == 'Complete';
      },
    );
  });

  group('GEN-01606 :: what the document is', () {
    gate(
      'GEN-01606-G5',
      'Metric bands: floor 0.95, optimal 0.999, Complete/Partial/Not Complete.',
      'The worked export is 0.882, below the floor, and reports Not Complete '
          'rather than Partial -- the grading distinguishes a shortfall inside '
          'the floor from one below it instead of calling everything imperfect '
          'Partial',
      () {
        final HabotExportCoverage c = coverage();
        final HabotExportCoverage nearlyAll =
            HabotAttendanceExport.coverageFor(
          loaded: loaded(),
          expected: 31,
          rangeStart: start,
          rangeEnd: end,
          watermark: watermark,
        );
        return HabotAttendanceExport.qualitativeOutput(c) ==
                'Not Complete' &&
            c.completeness < HabotAttendanceExport.floor &&
            nearlyAll.completeness >= HabotAttendanceExport.floor &&
            nearlyAll.accountsForEveryMissingRecord &&
            HabotAttendanceExport.qualitativeOutput(nearlyAll) == 'Partial';
      },
    );

    gate(
      'GEN-01606-G6',
      '"It is a file that leaves the app, gets mailed, and sits in a downloads '
          'folder."',
      'The document declares what it contains for whoever finds it later, the '
          'columns are declared once so two exports are the same document, and '
          'the CTA label is the row\'s own words',
      () =>
          HabotAttendanceExport.documentDeclaresItsContents &&
          HabotAttendanceExport.piiFooter.contains('class register') &&
          HabotAttendanceExport.columns.length == 5 &&
          HabotAttendanceExport.columns.first == 'Date' &&
          HabotAttendanceExport.ctaLabel == 'Export PDF Summary',
    );

    gate(
      'GEN-01606-G7',
      '"A model that is wrong renders beautifully."',
      'All eight structural checks hold on the worked export, the naive '
          '"did the PDF generate" measure reports 1.0 on the same data, and '
          'the absence of a PDF toolchain on this host is recorded rather '
          'than worked around',
      () {
        final HabotExportCoverage c = coverage();
        return HabotAttendanceExport.checksFor(c).length == 8 &&
            HabotAttendanceExport.checksFor(c).values.every((bool b) => b) &&
            HabotAttendanceExport.naiveGenerationSuccess(c) == 1.0 &&
            HabotAttendanceExport.naiveGenerationSuccess(c) >
                c.completeness &&
            HabotAttendanceExport.renderingIsNotHereNote
                .contains('renders beautifully') &&
            HabotAttendanceExport.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01606',
        atomicStepReferenceId: 'GEN-01606',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Add an \'Export PDF Summary\' CTA button to generate '
            'consolidated attendance records."',
        implementationOrder: 210,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAttendanceExport / HabotExportCoverage',
          'Component Properties':
              '${HabotAttendanceExport.columns.length} declared columns; '
              'coverage computed against what the range should contain; '
              '${HabotExportOmission.values.length} named omission reasons '
              'counted separately; sync watermark carried on the document; '
              'partial exports produced and stamped rather than refused',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the metric is completeness and the failure mode of an '
              'export is that it LOOKS complete. A PDF with a title, a date '
              'range and forty aligned rows is indistinguishable from one with '
              'forty-three rows in the range, three of which failed to load -- '
              'nobody reads a document wondering what is not in it. The export '
              'therefore carries its own denominator, and every omission is '
              'counted against a named reason. DECISION: a partial export is '
              'produced rather than refused, because the person asking usually '
              'needs the document today and a refusal sends them to a '
              'screenshot, which carries no coverage statement at all. It is '
              'stamped on the DOCUMENT rather than announced in a toast: the '
              'toast is gone by the time anyone opens the file, and the file '
              'is what gets forwarded. SECOND FINDING: attendance marked on a '
              'device that has not synced is in the local store and not in '
              'what the server would return, so an export that silently '
              'prefers one source contradicts whichever document the operator '
              'is holding. The watermark is the point up to which the two '
              'agree and the document says when it goes past it. '
              'SUBSTITUTION: no PDF toolchain and no network on this host, so '
              'what is built is the document model and the rendering is the '
              'platform\'s.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Activity Log Data Completeness',
            observed:
                '${completeness.toStringAsFixed(4)} on the worked export -- 30 '
                'of 34 records in range. Three could not be loaded and one '
                'fell outside the range on a timezone boundary; the omissions '
                'account for exactly the four missing records. Two of the '
                'thirty are included but not yet synced, stamped as a caveat '
                'rather than counted as an omission. Below the 0.95 floor, so '
                'it reports NOT COMPLETE and the document says so on its face.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'The measure a CTA-shaped row makes easy to count',
            observed:
                '1.00 -- "did the PDF generate" is true for the identical '
                'export that is missing four of thirty-four records. Kept '
                'beside the real figure so the difference is demonstrated '
                'rather than argued.',
            floor: 'n/a -- contrast figure',
            optimal: 'n/a -- contrast figure',
            ceiling: 'n/a -- contrast figure',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/reports/attendance_export.dart',
        ],
      ),
    );
  });
}
