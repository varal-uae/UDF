/// AISS GATE -- Step 175 of 175
/// Global Reference ID:       GEN-01132
/// Atomic Steps Reference ID: GEN-01132
/// Setup Step (Action) / Atomic Step: "Render zero-result search query reports
///   on the catalog operational dashboard."
/// Metric: Dashboard Data Refresh Latency -- Floor "<1 hour",
///         Optimal "<5 minutes", Ceiling "<24 hours". Good / Average / Poor.
///
/// THE REPORT IS ONLY USEFUL IF IT SAYS WHAT PEOPLE SEARCHED FOR, AND WHAT
/// PEOPLE TYPE INTO A SEARCH BOX IS THE MOST PERSONAL TEXT IN THE APP. The
/// resolution is a distinction rather than a compromise: a term already in the
/// catalogue is public vocabulary; a term that is not is the user's own words.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/zero_result_report.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/pii_sanitizer.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int stockGapTerms = 0;
  int unknownSearches = 0;

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

  const HabotZeroResultReport report = HabotZeroResultReport(
    catalogueVocabulary: <String>{
      'nappies',
      'wipes',
      'formula',
      'stroller',
      'cot',
      'nursery',
      'highchair',
    },
  );

  HabotZeroResultRecord record(
    String query, {
    bool filters = false,
    String salt = 'install-a',
  }) =>
      report.record(
        query: query,
        hadFilters: filters,
        installSalt: salt,
      );

  /// A day of zero-result searches on one install.
  List<HabotZeroResultRecord> day() => <HabotZeroResultRecord>[
        record('nappies size 4'),
        record('nappys'),
        record('xylophone'),
        record('wipes', filters: true),
        record('nappies size 4'),
      ];

  group('GEN-01132 :: what may travel, and what may not', () {
    gate(
      'GEN-01132-G1',
      'Atomic Step: "Render zero-result SEARCH QUERY reports." "A report with '
          'the raw queries in it is a warehouse table containing names, '
          'addresses and phone numbers, because a search box is where people '
          'type anything."',
      'The raw text never leaves the method that reduces it: a query '
          'containing a person\'s name yields a record with the catalogue term '
          'in clear and nothing else of what was typed, anywhere in the row',
      () {
        final HabotZeroResultRecord r = record('nappies for Amara Okafor');
        final String row = r.toRow().values.join(' ');
        return r.knownTerms.single == 'nappies' &&
            r.termCount == 4 &&
            !row.contains('Amara') &&
            !row.contains('amara') &&
            !row.contains('Okafor') &&
            !row.contains('okafor') &&
            !row.contains('for ') &&
            row.contains('nappies') &&
            !r.isEntirelyUnknownVocabulary &&
            HabotZeroResultReport.tensionNote.contains('type anything');
      },
    );

    gate(
      'GEN-01132-G2',
      '"A term already in the catalogue is public vocabulary -- it is on a '
          'category page and in the app\'s own navigation. A term that is not '
          'is the user\'s own words."',
      'The distinction is applied term by term rather than to the query as a '
          'whole: known terms are kept, unknown terms are dropped, and a query '
          'with no known terms at all is marked as entirely the user\'s own '
          'vocabulary',
      () {
        final HabotZeroResultRecord mixed = record('nappies size 4');
        final HabotZeroResultRecord unknown = record('xylophone');
        return mixed.knownTerms.single == 'nappies' &&
            mixed.termCount == 3 &&
            !mixed.isEntirelyUnknownVocabulary &&
            unknown.knownTerms.isEmpty &&
            unknown.isEntirelyUnknownVocabulary &&
            unknown.termCount == 1 &&
            HabotZeroResultReport.vocabularyDistinction
                .contains('salted hash');
      },
    );

    gate(
      'GEN-01132-G3',
      '"The hash groups repeats and nothing else. Because it is per-install '
          'the same query from two devices does not collide -- which is a '
          'deliberate loss."',
      'The same query on one install hashes to one value, so repeats collapse; '
          'the same query on another install hashes differently, so the report '
          'cannot be used to follow a person between devices -- and a global '
          'hash would be one dictionary away from the plaintext',
      () {
        final HabotZeroResultRecord first = record('rain jacket size 4');
        final HabotZeroResultRecord repeat = record('rain jacket size 4');
        final HabotZeroResultRecord elsewhere =
            record('rain jacket size 4', salt: 'install-b');
        return first.queryHash == repeat.queryHash &&
            first.queryHash != elsewhere.queryHash &&
            HabotPiiSanitizer.isOpaqueId(first.queryHash) &&
            !first.queryHash.contains('rain') &&
            !first.queryHash.contains('jacket') &&
            // Case and surrounding whitespace do not create a second group.
            record('  Rain Jacket Size 4 ').queryHash == first.queryHash &&
            HabotZeroResultReport.perInstallHashNote
                .contains('group across users');
      },
    );

    gate(
      'GEN-01132-G4',
      '"Term count separates a one-word catalogue gap from someone pasting a '
          'paragraph; the longest matching prefix says whether the user was '
          'close. None of the three is text."',
      'The shape features carry real signal without carrying words: a '
          'misspelling of a catalogue term scores a high prefix match while an '
          'unrelated word scores none, and neither the term nor the prefix '
          'itself appears in the row',
      () {
        final HabotZeroResultRecord misspelling = record('nappys');
        final HabotZeroResultRecord unrelated = record('xylophone');
        final HabotZeroResultRecord exact = record('wipes');
        final String row = misspelling.toRow().values.join(' ');
        return misspelling.longestKnownPrefix == 4 &&
            unrelated.longestKnownPrefix == 0 &&
            exact.longestKnownPrefix == 5 &&
            record('nappies size 4').longestKnownPrefix == 7 &&
            !row.contains('nappys') &&
            misspelling.toRow()['longest_known_prefix'] == 4 &&
            misspelling.toRow()['term_count'] == 1 &&
            HabotZeroResultReport.shapeFeaturesNote.contains('None of the '
                'three is text');
      },
    );
  });

  group('GEN-01132 :: what the dashboard actually shows', () {
    gate(
      'GEN-01132-G5',
      'Atomic Step: "...reports on the CATALOG OPERATIONAL dashboard." The '
          'actionable output is a category the catalogue has a name for and no '
          'stock in.',
      'Stock gaps are counted by catalogue term, filter exclusions are '
          'separated from an empty catalogue, near misses are identified by '
          'prefix, and repeats of one query by one person count once rather '
          'than twenty',
      () {
        final List<HabotZeroResultRecord> records = day();
        final Map<String, int> gaps = HabotZeroResultReport.stockGaps(records);
        stockGapTerms = gaps.length;
        unknownSearches =
            HabotZeroResultReport.unknownVocabularySearches(records);
        return gaps['nappies'] == 2 &&
            gaps['wipes'] == 1 &&
            stockGapTerms == 2 &&
            unknownSearches == 2 &&
            HabotZeroResultReport.filterExclusions(records) == 1 &&
            HabotZeroResultReport.nearMisses(records) == 1 &&
            HabotZeroResultReport.nearMisses(records, minimumPrefix: 6) == 0 &&
            HabotZeroResultReport.distinctQueries(records) == 4 &&
            records.length == 5;
      },
    );

    gate(
      'GEN-01132-G6',
      '"Counted, not itemised: this is where the personal text would have '
          'been."',
      'Searches whose terms the catalogue does not know at all are reported as '
          'a number and never as a list, and the near-miss figure -- the one '
          'that says a user was a letter away -- is derived from the prefix '
          'rather than from the words',
      () {
        final List<HabotZeroResultRecord> records = day();
        final int unknown =
            HabotZeroResultReport.unknownVocabularySearches(records);
        final int near = HabotZeroResultReport.nearMisses(records);
        return unknown == 2 &&
            near == 1 &&
            near < unknown &&
            records
                .where((HabotZeroResultRecord r) =>
                    r.isEntirelyUnknownVocabulary)
                .every((HabotZeroResultRecord r) => r.knownTerms.isEmpty) &&
            HabotZeroResultReport.tensionNote.contains('nobody can act on');
      },
    );

    gate(
      'GEN-01132-G7',
      'GCP alignment: events stream partitioned by event_date, clustered by '
          'trace_id.',
      'A zero-result search becomes a Step 156 event that passes the schema '
          'AND the Step 157 sanitiser -- the query hash travels because it '
          'carries the prefix that distinguishes a minted opaque id from a '
          'leaked hash, and the known terms are deliberately not on the event',
      () {
        final HabotZeroResultRecord r = record('nappies for Amara Okafor');
        final HabotEvent e = report.toEvent(
          r,
          view: 'catalogue_search',
          traceId: 'trace-1',
          at: DateTime.utc(2026, 8, 24, 10),
          sessionOrdinal: 3,
        );
        return HabotEventSchema.matches(e) &&
            e.kind == HabotEventKind.searchEmpty &&
            e.payload['query_hash'] == r.queryHash &&
            e.payload['term_count'] == 4 &&
            e.payload['had_filters'] == false &&
            e.payload.length == 3 &&
            !e.payload.containsKey('known_terms') &&
            HabotPiiSanitizer.rowIsClean(e.toRow()) &&
            e.toRow()['event_date'] == '2026-08-24';
      },
    );

    gate(
      'GEN-01132-G8',
      'Metric: Dashboard Data Refresh Latency -- floor "<1 hour", optimal '
          '"<5 minutes", ceiling "<24 hours".',
      'The row\'s bands are implemented against the shared dashboard tokens '
          'and reach every state, and past the ceiling the panel is reported '
          'as stale rather than shown as a number a catalogue team would act '
          'on',
      () =>
          HabotZeroResultReport.optimal ==
              HabotMotion.dashboardRefreshOptimal &&
          HabotZeroResultReport.floor == HabotMotion.dashboardRefreshFloor &&
          HabotZeroResultReport.ceiling ==
              HabotMotion.dashboardRefreshCeiling &&
          HabotZeroResultReport.bandFor(const Duration(minutes: 3)) ==
              'Good' &&
          HabotZeroResultReport.bandFor(const Duration(minutes: 45)) ==
              'Average' &&
          HabotZeroResultReport.bandFor(const Duration(hours: 12)) ==
              'Average' &&
          HabotZeroResultReport.bandFor(const Duration(hours: 26)) == 'Poor' &&
          HabotZeroResultReport.isStale(const Duration(hours: 26)) &&
          !HabotZeroResultReport.isStale(const Duration(hours: 24)),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01132',
        atomicStepReferenceId: 'GEN-01132',
        setupStepAction:
            'Render zero-result search query reports on the catalog '
            'operational dashboard.',
        implementationOrder: 175,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotZeroResultReport / HabotZeroResultRecord',
          'Component Properties':
              'Queries reduced to known catalogue terms in clear plus a '
              'per-install salted hash and three non-text shape features '
              '(term count, filters active, longest known prefix); dashboard '
              'outputs are stock gaps by term, unknown-vocabulary searches as '
              'a count, filter exclusions, near misses and distinct queries',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'PRIVACY DECISION RECORDED: a zero-result report with the '
              'queries removed is a count of failures nobody can act on; one '
              'with the raw queries in it is a warehouse table containing '
              'names, addresses and phone numbers, because a search box is '
              'where people type anything. The resolution is a distinction '
              'rather than a compromise: a term already in the catalogue is '
              'public vocabulary and travels in clear; everything else travels '
              'as a count and a salted hash. The hash is PER-INSTALL, which is '
              'a deliberate loss of cross-device grouping -- a global hash '
              'would group across users and would be one dictionary away from '
              'the plaintext.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'Bands implemented against HabotMotion.dashboardRefresh* -- '
                'Good under 5 minutes, Average to 24 hours, Poor beyond -- and '
                'past the ceiling the panel reports itself stale rather than '
                'showing a number a catalogue team would act on. The observed '
                'age is supplied by whatever renders the panel.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Query text leaving the device',
            observed:
                'None. Over the gate fixture, $stockGapTerms catalogue terms '
                'were reported as stock gaps in clear and $unknownSearches '
                'searches were reported only as a count with a hash and three '
                'shape features. A query containing a person\'s name produces '
                'a row in which no part of the name appears, and the event it '
                'emits passes both the Step 156 schema and the Step 157 '
                'sanitiser.',
            floor: '0 raw queries transmitted',
            optimal: '0 raw queries transmitted',
            ceiling: '0 raw queries transmitted',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/zero_result_report.dart',
        ],
      ),
    );
  });
}
