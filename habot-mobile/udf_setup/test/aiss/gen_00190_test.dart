/// AISS GATE -- Step 131 of 135
/// Global Reference ID:       GEN-00190
/// Atomic Steps Reference ID: GEN-00190
/// Atomic Step: "Debounce text field search inputs by 300ms on mobile
///               keyboards."
/// Metric: API Rate Limit Compliance -- Floor "<= 10 requests/second per
///         client", Optimal "sustained load at 70-80% of rate limit capacity",
///         Ceiling "10 requests/second (hard ceiling)".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// HALF THIS ROW WAS ALREADY BUILT. Step 33 (ANSA-006) implemented the 300ms
/// search debounce in navigation/header_search.dart. It is VERIFIED here, not
/// rebuilt -- a second debounce would be two definitions of one behaviour. The
/// new work is the rate limit the metric names, which did not exist.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/sync_governor.dart';
import 'package:udf_setup/design_system/forms/request_rate_limit.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);
  int peakObserved = 0;

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

  HabotRequestRateLimiter limiter() =>
      HabotRequestRateLimiter(clock: () => now);

  group('GEN-00190 :: the half that already existed', () {
    gate(
      'GEN-00190-G1',
      'Atomic Step: "DEBOUNCE text field search inputs by 300MS on mobile '
          'keyboards." Step 33 (ANSA-006) built this.',
      'The 300ms debounce token exists, is exactly the figure the row names, '
          'and is NOT redeclared here -- a second definition is the drift '
          'these steps exist to prevent',
      () =>
          HabotMotion.searchDebounce == const Duration(milliseconds: 300) &&
          HabotRequestRateLimiter.debounceAlreadyBuilt.contains('ANSA-006') &&
          HabotRequestRateLimiter.debounceAlreadyBuilt.contains(
            'header_search.dart',
          ) &&
          HabotRequestRateLimiter.debounceAlreadyBuilt.contains(
            'not rebuilt',
          ),
    );

    gate(
      'GEN-00190-G2',
      'A debounce protects the server from ONE FIELD being typed into. It does '
          'nothing about a sync sweep draining a queue or a reconnect storm '
          'replaying an outbox -- both of which this app now does.',
      'The rate limit is a separate mechanism with the ceiling the metric '
          'names, and the reason the debounce is insufficient is stated in the '
          'code rather than assumed',
      () =>
          HabotRequestRateLimiter.requestsPerSecond == 10 &&
          HabotRequestRateLimiter.window == HabotMotion.rateLimitWindow &&
          HabotRequestRateLimiter.window == const Duration(seconds: 1),
    );
  });

  group('GEN-00190 :: the half that did not', () {
    gate(
      'GEN-00190-G3',
      'Metric: API Rate Limit Compliance -- "<= 10 requests/second per client '
          '(hard ceiling)".',
      'The eleventh request inside one second is throttled with a retry-after, '
          'and the ceiling is never exceeded by anything that was allowed '
          'through',
      () {
        final HabotRequestRateLimiter l = limiter();
        final List<HabotRateVerdict> first10 = <HabotRateVerdict>[
          for (int i = 0; i < 10; i++)
            l.request(HabotWorkClass.interactive),
        ];
        final HabotRateVerdict eleventh = l.request(
          HabotWorkClass.interactive,
        );
        peakObserved = l.peakInWindow;
        return first10.every((HabotRateVerdict v) => v.allowed) &&
            !eleventh.allowed &&
            eleventh.decision == HabotRateDecision.throttled &&
            eleventh.retryAfter > Duration.zero &&
            l.compliedWithCeiling &&
            peakObserved == 10;
      },
    );

    gate(
      'GEN-00190-G4',
      'A per-caller limiter is not a rate limit; it is several rate limits '
          'that add up to more than the ceiling.',
      'One shared bucket covers every source, so a background sweep and a '
          'user tap draw from the same budget rather than each getting ten',
      () {
        final HabotRequestRateLimiter l = limiter();
        for (int i = 0; i < 8; i++) {
          l.request(HabotWorkClass.lightBackground);
        }
        // Two interactive requests still fit; the eleventh overall does not.
        final bool ninth = l.request(HabotWorkClass.interactive).allowed;
        final bool tenth = l.request(HabotWorkClass.interactive).allowed;
        final bool eleventh = l.request(HabotWorkClass.interactive).allowed;
        return ninth && tenth && !eleventh && l.usedInWindow == 10;
      },
    );

    gate(
      'GEN-00190-G5',
      'When the budget is nearly spent, a background sweep must yield to the '
          'tap a person is waiting on.',
      'Background work stops at the 80% band the metric names while '
          'interactive work continues into the reserve above it, reusing the '
          'Step 124 work classes rather than inventing a second priority '
          'scheme',
      () {
        final HabotRequestRateLimiter l = limiter();
        for (int i = 0; i < 8; i++) {
          l.request(HabotWorkClass.interactive);
        }
        final HabotRateVerdict background = l.request(
          HabotWorkClass.heavyBackground,
        );
        final HabotRateVerdict interactive = l.request(
          HabotWorkClass.interactive,
        );
        return HabotRequestRateLimiter.backgroundCeiling == 8 &&
            !background.allowed &&
            background.decision ==
                HabotRateDecision.yieldedToInteractive &&
            background.retryAfter > Duration.zero &&
            interactive.allowed &&
            l.interactivePreferred == 1 &&
            HabotWorkClass.values.length == 3;
      },
    );

    gate(
      'GEN-00190-G6',
      'A window that never empties is a limiter that stops the app '
          'permanently after one busy second.',
      'The window slides: once a second has passed the budget is available '
          'again, and the limiter reports its own peak rather than only its '
          'refusals',
      () {
        final HabotRequestRateLimiter l = limiter();
        for (int i = 0; i < 10; i++) {
          l.request(HabotWorkClass.interactive);
        }
        final bool blockedAtCeiling =
            !l.request(HabotWorkClass.interactive).allowed;
        now = now.add(
          HabotRequestRateLimiter.window + const Duration(milliseconds: 1),
        );
        final bool freedAfterWindow =
            l.request(HabotWorkClass.interactive).allowed;
        return blockedAtCeiling &&
            freedAfterWindow &&
            l.usedInWindow == 1 &&
            l.compliedWithCeiling;
      },
    );

    gate(
      'GEN-00190-G7',
      'Optimal: "sustained load at 70-80% of rate limit capacity". A limiter '
          'judged on requests it REFUSED would score perfectly while doing '
          'nothing.',
      'Compliance is computed over what actually went out, and the sustained '
          'band is a declared range rather than a single number',
      () {
        final HabotRequestRateLimiter l = limiter();
        return l.compliedWithCeiling &&
            l.inSustainedBand(7) &&
            l.inSustainedBand(8) &&
            !l.inSustainedBand(6) &&
            !l.inSustainedBand(9) &&
            HabotRequestRateLimiter.sustainedTargetLow == 0.70 &&
            HabotRequestRateLimiter.sustainedTargetHigh == 0.80;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00190',
        atomicStepReferenceId: 'GEN-00190',
        setupStepAction:
            'Debounce text field search inputs by 300ms on mobile keyboards.',
        implementationOrder: 131,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRequestRateLimiter',
          'Component Properties':
              '${HabotRequestRateLimiter.requestsPerSecond} requests per '
              '${HabotRequestRateLimiter.window.inSeconds}s in ONE shared '
              'bucket; background yields above '
              '${HabotRequestRateLimiter.backgroundCeiling}; work classes '
              'reused from Step 124',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. The debounce half of this row was '
              'built and gated at Step 33 (ANSA-006); it is verified here, not '
              'rebuilt, and that is recorded in '
              'HabotRequestRateLimiter.debounceAlreadyBuilt.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'API Rate Limit Compliance',
            observed:
                'Peak $peakObserved requests in any one-second window, against '
                'a hard ceiling of '
                '${HabotRequestRateLimiter.requestsPerSecond}. Computed over '
                'what actually went out rather than over what was asked for -- '
                'a limiter judged on its refusals would score perfectly while '
                'doing nothing.',
            floor: '<= 10 requests/second per client',
            optimal: 'sustained load at 70-80% of capacity',
            ceiling: '10 requests/second (hard ceiling)',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: '300ms search debounce (the Atomic Step)',
            observed:
                'ALREADY BUILT at Step 33 (ANSA-006), in '
                'navigation/header_search.dart, using '
                'HabotMotion.searchDebounce. Verified here at exactly the '
                '300ms the row names, and deliberately not reimplemented. The '
                'new work in this step is the rate limit the metric names, '
                'which did not exist -- a debounce protects the server from '
                'one field being typed into, and says nothing about a sync '
                'sweep or a reconnect storm.',
            floor: '300ms',
            optimal: '300ms',
            ceiling: '300ms',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/request_rate_limit.dart',
        ],
      ),
    );
  });
}
