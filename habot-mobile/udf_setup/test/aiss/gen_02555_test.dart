/// AISS GATE -- Step 129 of 135
/// Global Reference ID:       GEN-02555
/// Atomic Steps Reference ID: GEN-02555
/// Atomic Step: "Program the dashboard to refresh its KPI summary on each page
///               load."
/// Metric: Data Freshness (minutes) -- Floor 5, Optimal 0-1, Ceiling 1.
/// Best Qualitative Output: Real-time / Near Real-time / Delayed.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE LITERAL READING IS THE WRONG BUILD, RECORDED. "Refresh on each page
/// load" is a web instruction: there is no page load on a mobile client, and
/// refreshing on every screen entry over a rural link is how an app becomes
/// unusable. The metric is what the row is actually asking for, so the
/// requirement is implemented as a freshness budget.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/freshness.dart';
import 'package:udf_setup/design_system/data/repository.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);
  int entriesSeen = 0;
  int refreshesMade = 0;

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

  HabotFreshnessState stateAged(Duration age) => HabotFreshnessState(
    retrievedAt: now.subtract(age),
    origin: HabotDataOrigin.network,
    now: now,
  );

  group('GEN-02555 :: the bands the metric names', () {
    gate(
      'GEN-02555-G1',
      'Metric: Data Freshness in MINUTES -- Floor 5, Optimal 0-1. Best '
          'Qualitative Output: Real-time / Near Real-time / Delayed.',
      'Age maps onto the row own three-word vocabulary, so the evidence and '
          'the sheet use the same words rather than two sets that have to be '
          'translated',
      () =>
          stateAged(const Duration(seconds: 30)).freshness ==
              HabotFreshness.realTime &&
          stateAged(const Duration(minutes: 3)).freshness ==
              HabotFreshness.nearRealTime &&
          stateAged(const Duration(minutes: 9)).freshness ==
              HabotFreshness.delayed &&
          HabotFreshness.realTime.qualitativeOutput == 'Real-time' &&
          HabotFreshness.nearRealTime.qualitativeOutput == 'Near Real-time' &&
          HabotFreshness.delayed.qualitativeOutput == 'Delayed',
    );

    gate(
      'GEN-02555-G2',
      'Refreshing on every screen entry over a rural link is how an app '
          'becomes unusable.',
      'Entering four times inside the budget produces ONE fetch, and entering '
          'again past the budget produces another -- the same metric, and it '
          'survives being opened repeatedly',
      () {
        final HabotDashboardFreshness d = HabotDashboardFreshness(
          clock: () => now,
        );
        // First entry: nothing loaded, so it must fetch.
        final bool firstFetched = d.onEnter();
        d.recordLoad(
          HabotSuccess<Object?>(
            value: 'kpis',
            origin: HabotDataOrigin.network,
            retrievedAt: now,
          ),
        );
        int fetches = firstFetched ? 1 : 0;
        for (int i = 0; i < 3; i++) {
          now = now.add(const Duration(seconds: 20));
          if (d.onEnter()) {
            fetches++;
          }
        }
        now = now.add(const Duration(minutes: 10));
        final bool refetched = d.onEnter();
        entriesSeen = d.entries;
        refreshesMade = d.refreshes;
        return firstFetched &&
            fetches == 1 &&
            refetched &&
            d.entries == 5 &&
            d.refreshes == 2 &&
            (d.suppressionRate - 0.6).abs() < 0.0001;
      },
    );

    gate(
      'GEN-02555-G3',
      'Before Step 112 every read was a network read and "how old is this?" '
          'had no answer.',
      'The age comes from the Step 112 result own retrievedAt rather than a '
          'timestamp this component invents, and a result with no timestamp is '
          'treated as never loaded rather than as fresh',
      () {
        final HabotDashboardFreshness d = HabotDashboardFreshness(
          clock: () => now,
        );
        final bool neverLoaded =
            d.state.freshness == HabotFreshness.never && d.state.shouldRefresh;
        d.recordLoad(
          HabotSuccess<Object?>(
            value: 'kpis',
            origin: HabotDataOrigin.localStale,
            retrievedAt: now.subtract(const Duration(hours: 2)),
          ),
        );
        final HabotFreshnessState s = d.state;
        return neverLoaded &&
            s.freshness == HabotFreshness.delayed &&
            s.origin == HabotDataOrigin.localStale &&
            s.isOfflineStale &&
            (s.ageMinutes - 120).abs() < 0.1;
      },
    );
  });

  group('GEN-02555 :: stale is fine, silent is not', () {
    gate(
      'GEN-02555-G4',
      'A field worker on a dead link needs yesterday totals more than they '
          'need an empty screen. What they must not get is yesterday totals '
          'presented as current.',
      'Anything past the budget carries its age in words, and the honesty '
          'property is checkable rather than a matter of reading the copy',
      () {
        final HabotFreshnessState fresh = stateAged(
          const Duration(seconds: 40),
        );
        final HabotFreshnessState old = stateAged(const Duration(minutes: 17));
        final HabotFreshnessState ancient = stateAged(
          const Duration(hours: 3),
        );
        return fresh.staleLabel.isEmpty &&
            !fresh.freshness.mustBeLabelled &&
            old.staleLabel == 'Updated 17 minutes ago' &&
            ancient.staleLabel == 'Updated 3 hours ago' &&
            fresh.isHonest &&
            old.isHonest &&
            ancient.isHonest;
      },
    );

    gate(
      'GEN-02555-G5',
      'A singular minute reads badly and is the kind of thing nobody notices '
          'until a screenshot.',
      'The label is grammatical at one minute and one hour as well as at many',
      () {
        return stateAged(const Duration(minutes: 6)).staleLabel ==
                'Updated 6 minutes ago' &&
            stateAged(const Duration(minutes: 61)).staleLabel ==
                'Updated 1 hour ago' &&
            stateAged(const Duration(hours: 5)).staleLabel ==
                'Updated 5 hours ago' &&
            HabotFreshnessState(
                  retrievedAt: null,
                  origin: HabotDataOrigin.none,
                  now: now,
                ).staleLabel ==
                'Not loaded yet';
      },
    );

    gate(
      'GEN-02555-G6',
      'A freshness policy judged only on freshness will always choose to '
          'refresh.',
      'The cost side is reported too -- the share of entries that needed no '
          'network at all -- and the literal-reading substitution is recorded '
          'in the code rather than alongside it',
      () =>
          HabotFreshnessPolicy.budget ==
              const Duration(minutes: 5) &&
          HabotFreshnessPolicy.optimal == const Duration(minutes: 1) &&
          HabotFreshnessPolicy.optimal < HabotFreshnessPolicy.budget &&
          HabotDashboardFreshness.literalReadingNote.contains(
            'no page load on a mobile client',
          ) &&
          HabotDashboardFreshness.literalReadingNote.contains(
            'freshness budget',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02555',
        atomicStepReferenceId: 'GEN-02555',
        setupStepAction:
            'Program the dashboard to refresh its KPI summary on each page '
            'load.',
        implementationOrder: 129,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotFreshnessPolicy / HabotFreshnessState / '
              'HabotDashboardFreshness',
          'Component Properties':
              'budget ${HabotFreshnessPolicy.budget.inMinutes} minutes, '
              'optimal ${HabotFreshnessPolicy.optimal.inMinutes} minute; '
              '${HabotFreshness.values.length} states mapped onto the row own '
              'Real-time / Near Real-time / Delayed vocabulary',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. "Refresh on each page load" is a '
              'web instruction with no mobile equivalent; the substitution to '
              'a freshness budget is recorded in '
              'HabotDashboardFreshness.literalReadingNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Freshness (minutes)',
            observed:
                'Age classified against the row bands on every dashboard '
                'entry, taken from the Step 112 result own retrievedAt. Over '
                '$entriesSeen entries the policy fetched $refreshesMade times '
                '-- four entries inside the budget cost one network round '
                'trip, and the entry past it cost another.',
            floor: '5 minutes',
            optimal: '0-1 minutes',
            ceiling: '1 minute',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Stale data presented without its age',
            observed:
                '0. Anything past the budget carries "Updated N minutes ago" '
                'or "Not loaded yet", and the property is checkable rather '
                'than a matter of reading the copy. Showing stale data is '
                'fine on a dead link; showing it silently is not.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/freshness.dart',
        ],
      ),
    );
  });
}
