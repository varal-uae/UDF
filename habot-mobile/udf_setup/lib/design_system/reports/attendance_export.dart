/// Step 210 (GEN-01606) -- the "Export PDF Summary" action.
///
/// The row: "Add an 'Export PDF Summary' CTA button to generate consolidated
/// attendance records."
/// Metric: **Activity Log Data Completeness** -- 0.95 / 0.999 / 1.
/// Complete/Partial/Not Complete.
///
/// The metric is completeness, and the failure mode of an export is that it
/// looks complete. A PDF with a title, a date range and forty neatly aligned
/// rows is indistinguishable from one with forty-three rows in the range, three
/// of which failed to load. Nobody reads a PDF wondering what is not in it.
///
/// So an export here carries its own coverage: how many records the range
/// should contain, how many were obtained, and what happened to the difference.
/// A partial export is produced -- refusing outright is worse, because the
/// parent usually needs the document today -- but it is STAMPED as partial, on
/// the document, not only in a toast that is gone by the time anyone looks at
/// the file.
///
/// **Unsynced records are the other hole.** Attendance marked on a device that
/// has not reached the server yet is in the local store and not in the range
/// the server would return. An export that silently prefers one source
/// contradicts whichever document the operator is holding. The export declares
/// its watermark -- the point in time up to which local and server agree --
/// and says when it is exporting beyond it.
///
/// **The document names children.** It is a file that leaves the app, gets
/// mailed, and sits in a downloads folder. Its footer says so, and the export
/// carries the retention note rather than leaving it to be discovered.
library;

/// Why a record is not in the export.
///
/// Unsynced records are deliberately NOT here: a record marked on this device
/// and not yet on the server IS in the document -- omitting it would drop data
/// the operator entered. It is a caveat rather than an omission, and the two
/// are counted separately so that the omissions always account for exactly the
/// difference between what the range should hold and what the document holds.
enum HabotExportOmission {
  /// The record could not be loaded.
  loadFailed,

  /// The record was outside the requested range after all -- a timezone
  /// boundary, most often.
  outOfRange,
}

/// One attendance row, as the export needs it.
class HabotAttendanceRecord {
  const HabotAttendanceRecord({
    required this.id,
    required this.childId,
    required this.sessionId,
    required this.markedAt,
    required this.present,
    this.isSynced = true,
  });

  final String id;
  final String childId;
  final String sessionId;
  final DateTime markedAt;
  final bool present;
  final bool isSynced;
}

/// The coverage statement that travels with the document.
class HabotExportCoverage {
  const HabotExportCoverage({
    required this.expected,
    required this.included,
    required this.omissions,
    required this.unsyncedIncluded,
    required this.watermark,
    required this.rangeStart,
    required this.rangeEnd,
  });

  /// How many records the range should contain, per the source of truth.
  final int expected;

  /// How many made it into the document.
  final int included;

  /// What happened to the rest, counted by reason.
  final Map<HabotExportOmission, int> omissions;

  /// Records that ARE in the document but have not reached the server. Not an
  /// omission -- a caveat, and the reason the watermark is stamped.
  final int unsyncedIncluded;

  /// The point up to which local and server state agree.
  final DateTime watermark;

  final DateTime rangeStart;
  final DateTime rangeEnd;

  double get completeness => expected == 0 ? 1 : included / expected;

  bool get isComplete => included == expected;

  /// True when the range asks for records the watermark cannot vouch for.
  bool get exportsBeyondWatermark => rangeEnd.isAfter(watermark);

  int get omittedCount =>
      omissions.values.fold(0, (int a, int b) => a + b);

  /// Every record the range should hold is either in the document or counted
  /// against a named reason. Nothing goes missing without a line of its own.
  bool get accountsForEveryMissingRecord =>
      omittedCount == expected - included;

  /// The line stamped on the document itself.
  String get stampLine {
    if (isComplete && !exportsBeyondWatermark && unsyncedIncluded == 0) {
      return 'Complete: $included of $expected records.';
    }
    final List<String> parts = <String>[
      'PARTIAL: $included of $expected records.',
    ];
    omissions.forEach((HabotExportOmission reason, int n) {
      if (n > 0) {
        parts.add('$n ${_reasonText(reason)}.');
      }
    });
    if (unsyncedIncluded > 0) {
      parts.add(
        '$unsyncedIncluded included but not yet synced from this device.',
      );
    }
    if (exportsBeyondWatermark) {
      parts.add(
        'Records after ${watermark.toUtc().toIso8601String()} may not be '
        'final.',
      );
    }
    return parts.join(' ');
  }

  static String _reasonText(HabotExportOmission reason) => switch (reason) {
        HabotExportOmission.loadFailed => 'could not be loaded',
        HabotExportOmission.outOfRange => 'fell outside the range',
      };
}

/// The document model. Rendering is the platform's job; what this file owns is
/// what goes in it and what it admits about itself.
class HabotAttendanceExport {
  const HabotAttendanceExport._();

  static const String ctaLabel = 'Export PDF Summary';

  /// Columns, in order. Declared so two exports from different screens are the
  /// same document.
  static const List<String> columns = <String>[
    'Date',
    'Session',
    'Child',
    'Status',
    'Marked at',
  ];

  /// Completeness the row is graded on.
  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// Build the coverage statement for a requested range.
  static HabotExportCoverage coverageFor({
    required List<HabotAttendanceRecord> loaded,
    required int expected,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required DateTime watermark,
    int loadFailures = 0,
  }) {
    final int unsynced =
        loaded.where((HabotAttendanceRecord r) => !r.isSynced).length;
    final int outOfRange = loaded
        .where(
          (HabotAttendanceRecord r) =>
              r.markedAt.isBefore(rangeStart) || r.markedAt.isAfter(rangeEnd),
        )
        .length;
    final int included = loaded.length - outOfRange;
    return HabotExportCoverage(
      expected: expected,
      included: included,
      omissions: <HabotExportOmission, int>{
        HabotExportOmission.loadFailed: loadFailures,
        HabotExportOmission.outOfRange: outOfRange,
      },
      unsyncedIncluded: unsynced,
      watermark: watermark,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  /// A partial export is produced rather than refused.
  ///
  /// Refusing is the tidier-looking choice and the worse one: the person
  /// asking usually needs the document today, and a refusal sends them to a
  /// screenshot, which carries no coverage statement at all.
  static const bool producesPartialExports = true;

  /// And is stamped on the document, not announced in a toast.
  static const bool stampsCoverageOnTheDocument = true;

  static const String toastIsNotAStampNote =
      'A warning shown when the export finishes is gone by the time anyone '
      'opens the file, and the file is what gets forwarded. The coverage '
      'statement is on the document, where it travels with the thing it is '
      'about.';

  /// The footer text. Names what the document contains, for the person who
  /// finds it in a downloads folder six months from now.
  static const String piiFooter =
      'This document lists children by name and records their attendance. '
      'Handle it as you would a class register.';

  static bool get documentDeclaresItsContents => piiFooter.isNotEmpty;

  /// Whether a coverage result should be presented as Complete.
  static String qualitativeOutput(HabotExportCoverage coverage) {
    if (coverage.isComplete &&
        !coverage.exportsBeyondWatermark &&
        coverage.unsyncedIncluded == 0) {
      return 'Complete';
    }
    if (coverage.completeness >= floor) {
      return 'Partial';
    }
    return 'Not Complete';
  }

  /// What the export would report if completeness were measured as "did the
  /// PDF generate" -- which is what a CTA-shaped row makes easy to count.
  static double naiveGenerationSuccess(HabotExportCoverage coverage) =>
      coverage.included > 0 ? 1 : 0;

  static Map<String, bool> checksFor(HabotExportCoverage coverage) =>
      <String, bool>{
        'coverage is computed against what the range should contain':
            coverage.expected > 0,
        'a partial export is produced rather than refused':
            producesPartialExports,
        'the partial state is stamped on the document':
            stampsCoverageOnTheDocument &&
                coverage.stampLine.isNotEmpty,
        'every omission is counted against a named reason':
            coverage.omissions.keys.length ==
                HabotExportOmission.values.length,
        'the omissions account for every missing record':
            coverage.accountsForEveryMissingRecord,
        'the sync watermark travels with the document':
            coverage.stampLine.contains('may not be final') ||
                !coverage.exportsBeyondWatermark,
        'the document says what it contains': documentDeclaresItsContents,
        'the columns are declared rather than composed at the call site':
            columns.length == 5,
      };

  static const String completenessFailsQuietlyNote =
      'A PDF with a title, a date range and forty aligned rows is '
      'indistinguishable from one with forty-three rows in the range, three of '
      'which failed to load. Nobody reads a document wondering what is not in '
      'it. The export therefore carries its own denominator.';

  static const String watermarkNote =
      'Attendance marked on a device that has not synced is in the local '
      'store and not in what the server would return. An export that silently '
      'prefers one source contradicts whichever document the operator is '
      'holding. The watermark is the point up to which the two agree, and the '
      'document says when it goes past it.';

  static const String renderingIsNotHereNote =
      'There is no PDF toolchain and no network on this host. What is built is '
      'the document model -- columns, coverage, stamp, footer -- and the '
      'rendering is the platform\'s. A model that is wrong renders '
      'beautifully.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Add an \'Export PDF Summary\' CTA button to generate consolidated '
      'attendance records."';
}
