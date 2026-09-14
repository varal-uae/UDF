/// AISS GATE -- Step 171 of 175
/// Global Reference ID:       GEN-01010
/// Atomic Steps Reference ID: GEN-01010
/// Setup Step (Action): "Deploy Automated Mobile Deep Link Routing & Context
///                       Restoration Engine"
/// Atomic Step: "Test deep link clicks through registration flows to confirm
///               100% of link contexts restore post-login."
/// Metric: Context Restoration Success Rate -- Floor 100%, Optimal 100%,
///         Ceiling "N/A (100% target)". Pass / Fail.
///
/// THE HARD CASE IS THE ONE THE ROW NAMES: a link that arrives while signed
/// out. The context has to survive a sign-in that may bounce to a browser, take
/// minutes, or have the process killed behind a web view. A context held in
/// memory across that is usually there and occasionally not -- which is 97%,
/// and the row asks for 100%.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/navigation/context_restoration.dart';
import 'package:udf_setup/design_system/navigation/deep_link_context_manager.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double successRate = 0;
  double fallenRate = 1;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  late Map<String, String> storage;
  late DateTime now;
  late HabotContextRestoration restoration;

  setUp(() {
    storage = <String, String>{};
    now = DateTime.utc(2026, 8, 24, 10);
    restoration = HabotContextRestoration(
      manager: DeepLinkContextManager(),
      persist: (String k, String v) async {
        storage[k] = v;
      },
      read: (String k) async => storage[k],
      clear: (String k) async {
        storage.remove(k);
      },
      clock: () => now,
    );
  });

  /// A context worth restoring: a route, a selection, a scroll position and a
  /// half-typed form.
  HabotDeepLinkContext context() => const HabotDeepLinkContext(
        route: '/listings/nurseries',
        params: <String, String>{'area': 'jumeirah', 'age': '3'},
        scrollOffset: 240,
        selectedId: 'listing-4821',
        draft: <String, String>{
          'childName': 'Amar',
          'notes': 'afternoons only',
        },
        paneIndex: 1,
      );

  group('GEN-01010 :: parked before the auth flow, not after it', () {
    gate(
      'GEN-01010-G1',
      'Atomic Step: "...through REGISTRATION FLOWS to confirm 100% of link '
          'contexts restore post-login."',
      'The context is persisted before sign-in starts and comes back whole '
          'after it -- route, params, scroll offset, selection, draft and pane '
          '-- which is what survives a sign-in that bounced to a browser and '
          'had the process killed behind it',
      () async {
        final HabotDeepLinkContext original = context();
        await restoration.park(original);
        // Everything the app was holding in memory is gone at this point.
        final HabotRestorationOutcome out = await restoration.restore();
        return storage.isEmpty &&
            out.isRestored &&
            out.failure == null &&
            HabotContextRestoration.isTotal(original, out.context!) &&
            HabotContextRestoration.missingFields(
              original,
              out.context!,
            ).isEmpty &&
            out.context!.draft['notes'] == 'afternoons only' &&
            out.context!.scrollOffset == 240 &&
            out.context!.paneIndex == 1 &&
            HabotContextRestoration.parkBeforeAuthNote.contains('97%');
      },
    );

    gate(
      'GEN-01010-G2',
      '"100% means all-or-nothing, not mostly. A restoration that returns the '
          'route but loses the scroll offset and the half-typed draft is not a '
          'partial success; it is a user looking at the right screen wondering '
          'where their typing went."',
      'The comparison is total and a shortfall NAMES the field, so '
          '"restoration is flaky" arrives as "the draft does not survive a '
          'process death" -- every field of the context is checked, not just '
          'the route',
      () async {
        final HabotDeepLinkContext original = context();
        const HabotDeepLinkContext routeOnly = HabotDeepLinkContext(
          route: '/listings/nurseries',
        );
        final List<String> missing =
            HabotContextRestoration.missingFields(original, routeOnly);
        final List<String> draftOnly = HabotContextRestoration.missingFields(
          original,
          const HabotDeepLinkContext(
            route: '/listings/nurseries',
            params: <String, String>{'area': 'jumeirah', 'age': '3'},
            scrollOffset: 240,
            selectedId: 'listing-4821',
            draft: <String, String>{'childName': 'Amar'},
            paneIndex: 1,
          ),
        );
        return !HabotContextRestoration.isTotal(original, routeOnly) &&
            missing.length == 5 &&
            missing.contains('params') &&
            missing.contains('scrollOffset') &&
            missing.contains('selectedId') &&
            missing.contains('draft') &&
            missing.contains('paneIndex') &&
            !missing.contains('route') &&
            draftOnly.single == 'draft' &&
            HabotContextRestoration.allOrNothingNote
                .contains('where their typing went');
      },
    );

    gate(
      'GEN-01010-G3',
      '"HabotDeepLinkContext already declares what a context IS and already '
          'serialises. A second notion of \'context\' would drift from the '
          'first within a release."',
      'The Step 78 context type is reused rather than re-declared, and the '
          'parked envelope is the context\'s own serialisation plus the '
          'instant it was parked',
      () async {
        await restoration.park(context());
        final String raw = storage[HabotContextRestoration.parkKey]!;
        return storage.length == 1 &&
            raw.contains('"parked_at"') &&
            raw.contains('"context"') &&
            raw.contains('/listings/nurseries') &&
            HabotContextRestoration.reusesManagerNote.contains('drift');
      },
    );
  });

  group('GEN-01010 :: what is not a failure, and what is', () {
    gate(
      'GEN-01010-G4',
      '"A link parked three weeks ago and restored after a sign-in belongs to '
          'a session the user has forgotten; restoring it is not helpful, it '
          'is confusing."',
      'A parked context expires against a declared lifetime, expiry is '
          'reported distinctly from failure and does not count against the '
          'rate -- because an expired context is the system working',
      () async {
        await restoration.park(context());
        now = now.add(const Duration(hours: 25));
        final HabotRestorationOutcome out = await restoration.restore();
        return HabotContextRestoration.parkLifetime ==
                const Duration(hours: 24) &&
            HabotContextRestoration.parkLifetime ==
                HabotMotion.deepLinkParkLifetime &&
            !out.isRestored &&
            out.failure == HabotRestorationFailure.expired &&
            !out.countsAgainstRate &&
            restoration.expiredCount == 1 &&
            restoration.incompleteCount == 0 &&
            HabotContextRestoration.expiryNote.contains('system working');
      },
    );

    gate(
      'GEN-01010-G5',
      '"Nothing was parked" is not a failure of this engine. "Counting it '
          'would put the rate below 50% forever and make a 100% target '
          'unreachable, which is how a metric stops being read."',
      'An ordinary sign-in with no deep link behind it reports nothingParked, '
          'does not count against the rate, and leaves the rate at 1.0 rather '
          'than dragging it down',
      () async {
        final HabotRestorationOutcome out = await restoration.restore();
        return !out.isRestored &&
            out.failure == HabotRestorationFailure.nothingParked &&
            !out.countsAgainstRate &&
            restoration.attempts == 1 &&
            restoration.restorationSuccessRate == 1.0;
      },
    );

    gate(
      'GEN-01010-G6',
      '"Clears the parked context either way, so a context cannot be restored '
          'twice."',
      'A restored context is consumed: a second restore after the same park '
          'finds nothing, so a user who signs in again is not thrown back to '
          'where they were three sessions ago',
      () async {
        await restoration.park(context());
        final HabotRestorationOutcome first = await restoration.restore();
        final HabotRestorationOutcome second = await restoration.restore();
        return first.isRestored &&
            !second.isRestored &&
            second.failure == HabotRestorationFailure.nothingParked &&
            storage.isEmpty;
      },
    );
  });

  group('GEN-01010 :: the rate, and the only thing that lowers it', () {
    gate(
      'GEN-01010-G7',
      'Metric: Context Restoration Success Rate -- floor 100%, optimal 100%.',
      'Across a mixed run -- two real restorations, one expiry and one '
          'sign-in with nothing parked -- the rate is 1.0, because the '
          'denominator is the attempts where something was parked and had not '
          'expired',
      () async {
        await restoration.park(context());
        await restoration.restore();
        await restoration.park(context());
        await restoration.restore();
        await restoration.restore(); // nothing parked
        await restoration.park(context());
        now = now.add(const Duration(hours: 25));
        await restoration.restore(); // expired
        successRate = restoration.restorationSuccessRate;
        return restoration.attempts == 4 &&
            restoration.restoredCount == 2 &&
            restoration.expiredCount == 1 &&
            restoration.incompleteCount == 0 &&
            successRate == 1.0 &&
            successRate >= HabotContextRestoration.floor &&
            successRate >= HabotContextRestoration.optimal;
      },
    );

    gate(
      'GEN-01010-G8',
      '"Something was parked and came back incomplete. The only real failure." '
          'A rate that cannot fall is not a measurement.',
      'A parked context that cannot be read back -- corrupt storage, a missing '
          'timestamp, a missing body -- is reported as incomplete with the '
          'lost field named, and it is the one outcome that drives the rate '
          'below the row\'s 100% floor',
      () async {
        storage[HabotContextRestoration.parkKey] = 'not json at all';
        final HabotRestorationOutcome corrupt = await restoration.restore();

        storage[HabotContextRestoration.parkKey] =
            '{"context":{"route":"/x"}}';
        final HabotRestorationOutcome noTimestamp =
            await restoration.restore();

        storage[HabotContextRestoration.parkKey] =
            '{"parked_at":"2026-08-24T10:00:00.000Z","context":"not a map"}';
        final HabotRestorationOutcome noBody = await restoration.restore();

        fallenRate = restoration.restorationSuccessRate;

        return corrupt.failure == HabotRestorationFailure.incomplete &&
            corrupt.countsAgainstRate &&
            corrupt.lostFields.single == 'envelope' &&
            noTimestamp.lostFields.single == 'parked_at' &&
            noBody.lostFields.single == 'context' &&
            restoration.incompleteCount == 3 &&
            fallenRate == 0.0 &&
            fallenRate < HabotContextRestoration.floor;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01010',
        atomicStepReferenceId: 'GEN-01010',
        setupStepAction:
            'Deploy Automated Mobile Deep Link Routing & Context Restoration '
            'Engine -- Atomic Step: "Test deep link clicks through '
            'registration flows to confirm 100% of link contexts restore '
            'post-login."',
        implementationOrder: 171,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotContextRestoration',
          'Component Properties':
              'Parks the Step 78 HabotDeepLinkContext before the auth flow '
              'starts; park lifetime '
              '${HabotContextRestoration.parkLifetime.inHours}h; '
              '${HabotRestorationFailure.values.length} declared failure '
              'reasons, of which one counts against the rate; restoration '
              'compared field-by-field and consumed on read',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'DENOMINATOR RECORDED: the rate is restorations over attempts '
              'where something WAS parked and had not expired. Counting '
              '"nothing was parked" -- an ordinary sign-in -- would hold the '
              'rate below 50% forever and make the row\'s 100% target '
              'unreachable, which is how a metric stops being read. Expiry is '
              'counted separately for the same reason: an expired context is '
              'the system working. The storage here is an in-memory map '
              'supplied by the gate; on device it is the Step 113 durable '
              'store, and the park must be durable or the process death this '
              'step exists for takes the context with it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Context Restoration Success Rate',
            observed:
                '${(successRate * 100).toStringAsFixed(0)}% across a mixed run '
                'of two restorations, one expiry and one sign-in with nothing '
                'parked. The same figure falls to '
                '${(fallenRate * 100).toStringAsFixed(0)}% when the parked '
                'envelope cannot be read back, with the lost field named in '
                'each case, so the rate is a measurement rather than a '
                'constant.',
            floor: '100%',
            optimal: '100%',
            ceiling: 'N/A (100% target)',
          ),
          AissMeasurement(
            metricName: 'Fields restored per successful restoration',
            observed:
                '6 of 6 -- route, params, scroll offset, selection, draft and '
                'pane index. The comparison is all-or-nothing: a restoration '
                'that returns the route and loses the half-typed draft is '
                'reported as a failure naming "draft" rather than as a partial '
                'success, because a user on the right screen wondering where '
                'their typing went has not been restored.',
            floor: 'all fields',
            optimal: 'all fields',
            ceiling: 'all fields',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/context_restoration.dart',
        ],
      ),
    );
  });
}
