/// AISS GATE -- Step 76 of 80
/// Global Reference ID:       PNSAD-021
/// Atomic Steps Reference ID: PNSAD-021
/// Setup Step (Action):       "Mobile Push-Driven Notification Routing
///                             Infrastructure"
/// Setup Step Description:    "Build client-side rendering handlers to display
///                             structured local alert sheets."
/// Metric: Device Push-Token Freshness Rate --
///         Floor ">= 90% of active devices holding a valid, unexpired token",
///         Optimal 0.97, Ceiling "99.5%+". Output field: 'PASS'.
///
/// CONTAMINATED ROW, RECORDED: eleven columns describe document access control
/// and row-level security. Why This Matters ("Protects sensitive customer
/// records against unauthorized data viewing attempts"), UX Translation
/// ("Governs document attachment listing displays and access control cards"),
/// Flow Impact ("Users browse allowed platform document lists safely based on
/// role privileges"), Dashboard Implication ("Security dashboards monitor
/// document isolation states"), Atomic Reusability ("Access level parameters
/// operate uniformly across all repository tables"), Common Library
/// ("habot.io/library/security/document_access.json"), GCP Alignment ("object
/// level security rules inside Google Cloud IAM"), Expected Output ("Document
/// Isolation Nomenclature Sheet"), Poka-Yoke ("Repository access modules drop
/// file fetch requests if session profiles miss required classification
/// keys"), Self-Chasing and the four Material Design columns (lock banners on
/// restricted list rows, security tags in card grids). None are gated.
///
/// The Data Collected column is contaminated in a different way -- "Build
/// Status; Build Timestamp; Build Artifacts Path; Build Logs; Build Duration"
/// are CI fields, not routing fields. Recorded, and the evidence below reports
/// what this step actually collects instead of filling those five in with
/// something invented.
///
/// COHERENT AND GATED: the Setup Step, the Setup Step Description, and the
/// Metric -- which fits its step and is measurable client-side, unusually for
/// this batch. A device holds a push token, the token has an issue time, and a
/// token past its rotation horizon is stale.
///
/// SCOPE STATED PLAINLY: the metric is a FLEET percentage ("% of active
/// devices"). One client can observe its own token and nothing else. G4
/// measures the device reading and says so; the fleet aggregate is a backend
/// sum of exactly this signal, and no fleet number is invented here.
///
/// THE ALERT SHEET IS THE STEP 21 SHEET. "structured local alert sheets" is
/// `HabotBottomSheet`, which already owns the scrim, the snap ladder and the
/// drag handle. A fifth surface would duplicate four gated decisions.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/deep_link_context_manager.dart';
import 'package:udf_setup/design_system/navigation/route_table.dart';
import 'package:udf_setup/design_system/notifications/delivery_router.dart';
import 'package:udf_setup/design_system/notifications/message_receiver.dart';
import 'package:udf_setup/design_system/notifications/notification_center.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';

import 'aiss_reporter.dart';

const List<HabotRoute> _routes = <HabotRoute>[
  HabotRoute(path: '/overview', title: 'Overview'),
  HabotRoute(path: '/tasks', title: 'Tasks'),
  HabotRoute(path: '/batches/:id', title: 'Batch', requiresId: true),
];

const HabotRoute _fallback = HabotRoute(path: '/', title: 'Home');

HabotParsedMessage _message({
  required String id,
  required HabotNotificationKind kind,
  required String route,
  HabotMessageSource source = HabotMessageSource.foreground,
  int second = 0,
}) => HabotParsedMessage(
  id: id,
  kind: kind,
  title: 'title $id',
  body: 'body $id',
  route: route,
  source: source,
  receivedAt: DateTime(2026, 8, 14, 9, 0, second),
  data: const <String, String>{},
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredReach = -1;
  double measuredFreshness = -1;

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

  HabotDeliveryRouter buildRouter({
    HabotApprovalSender? sender,
    DeepLinkContextManager? contexts,
    HabotNotificationCenter? centre,
  }) => HabotDeliveryRouter(
    router: HabotRouter(routes: _routes, fallback: _fallback),
    centre: centre ?? HabotNotificationCenter(),
    contextManager: contexts ?? DeepLinkContextManager(),
    approvalSender: sender,
  );

  group('PNSAD-021 :: routing', () {
    gate(
      'PNSAD-021-G1',
      'Setup Step (Action): "Mobile Push-Driven Notification ROUTING '
          'Infrastructure" -- read against GEN-02082 (Step 43), the router '
          'that already decides what a path means.',
      'A delivered notification is routed through the existing route table, '
          'and the outcome depends on what arrived: an approval opens a sheet, '
          'a tap from the tray navigates and restores context, a foreground '
          'informational message is presented and stored',
      () {
        final DeepLinkContextManager contexts = DeepLinkContextManager();
        contexts.capture(
          const HabotDeepLinkContext(
            route: '/tasks',
            params: <String, String>{'filter': 'open'},
          ),
        );
        final HabotDeliveryRouter router = buildRouter(contexts: contexts);
        addTearDown(router.dispose);

        final HabotDeliveryOutcome approval = router.route(
          _message(
            id: 'ap1',
            kind: HabotNotificationKind.approval,
            route: '/tasks',
          ),
        );
        final HabotDeliveryOutcome tapped = router.route(
          _message(
            id: 'inf1',
            kind: HabotNotificationKind.informational,
            route: '/tasks',
            source: HabotMessageSource.tapped,
            second: 1,
          ),
        );
        final HabotDeliveryOutcome foreground = router.route(
          _message(
            id: 'inf2',
            kind: HabotNotificationKind.informational,
            route: '/overview',
            second: 2,
          ),
        );
        final HabotDeliveryOutcome dispatch = router.route(
          _message(
            id: 'd1',
            kind: HabotNotificationKind.dispatch,
            route: '/overview',
            second: 3,
          ),
        );

        return approval == HabotDeliveryOutcome.sheetOpened &&
            router.pendingApproval?.id == 'ap1' &&
            tapped == HabotDeliveryOutcome.navigated &&
            foreground == HabotDeliveryOutcome.presentedAndStored &&
            // A dispatch offer is ephemeral (Step 75), so it is presented and
            // not stored -- the classification is honoured here rather than
            // re-decided.
            dispatch == HabotDeliveryOutcome.presented &&
            router.records.length == 4;
      },
    );

    gate(
      'PNSAD-021-G2',
      'GEN-02082 (Step 43) falls back so a TAP never lands on a blank screen. '
          'A notification whose target does not resolve is a different '
          'problem: the SENDER addressed something that does not exist.',
      'An unresolvable target is dropped and recorded with the reason, rather '
          'than quietly delivered to the fallback route where the user would '
          'find nothing to do',
      () {
        final HabotDeliveryRouter router = buildRouter();
        addTearDown(router.dispose);
        final HabotDeliveryOutcome outcome = router.route(
          _message(
            id: 'bad',
            kind: HabotNotificationKind.informational,
            route: '/nowhere/at/all',
          ),
        );
        final HabotDeliveryRecord record = router.records.single;
        return outcome == HabotDeliveryOutcome.dropped &&
            !record.reachedTheUser &&
            (record.reason ?? '').contains('/nowhere/at/all') &&
            router.droppedCount == 1;
      },
    );

    gate(
      'PNSAD-021-G3',
      'Setup Step (Action): routing INFRASTRUCTURE -- every delivery accounted '
          'for, not only the ones that worked.',
      'The reach rate is computed from the recorded outcomes, so a dropped '
          'notification lowers it: four routed, one addressed to nothing, and '
          'the number falls out at 0.75 rather than being reported as success',
      () {
        final HabotDeliveryRouter router = buildRouter();
        addTearDown(router.dispose);
        router
          ..route(
            _message(
              id: 'a',
              kind: HabotNotificationKind.informational,
              route: '/overview',
            ),
          )
          ..route(
            _message(
              id: 'b',
              kind: HabotNotificationKind.critical,
              route: '/tasks',
              second: 1,
            ),
          )
          ..route(
            _message(
              id: 'c',
              kind: HabotNotificationKind.informational,
              route: '/batches/42',
              second: 2,
            ),
          )
          ..route(
            _message(
              id: 'd',
              kind: HabotNotificationKind.informational,
              route: '/batches',
              second: 3,
            ),
          );
        measuredReach = router.reachRate;
        // '/batches' without an id does not resolve: the route requires one.
        return router.records.length == 4 &&
            router.droppedCount == 1 &&
            measuredReach == 0.75;
      },
    );
  });

  group('PNSAD-021 :: the metric', () {
    test('[PNSAD-021-G4] token freshness is measured on this device, and the '
        'fleet reading is not invented', () async {
      final DateTime now = DateTime(2026, 8, 14, 9);
      int refreshes = 0;
      final HabotPushTokenRegistry registry = HabotPushTokenRegistry(
        refresh: () async {
          refreshes++;
          return 'token-$refreshes';
        },
        clock: () => now,
      );
      addTearDown(registry.dispose);

      // No token at all is not fresh, and is not an exception either.
      expect(registry.hasToken, isFalse);
      expect(registry.isFresh, isFalse);
      expect(registry.deviceFreshness, 0);

      expect(await registry.ensureFresh(), isTrue);
      expect(registry.isFresh, isTrue);
      expect(registry.deviceFreshness, 1);
      expect(refreshes, 1);

      // Already fresh: no second network call.
      expect(await registry.ensureFresh(), isTrue);
      expect(refreshes, 1, reason: 'a fresh token is not refreshed again');

      // A token issued beyond the rotation horizon is stale, and refreshing is
      // what the client owes -- noticing before a send fails, not after.
      registry.adopt(
        'old',
        now.subtract(
          HabotPushTokenRegistry.refreshHorizon + const Duration(days: 1),
        ),
      );
      expect(registry.isFresh, isFalse);
      expect(await registry.ensureFresh(), isTrue);
      expect(refreshes, 2);

      measuredFreshness = registry.deviceFreshness;
      expect(measuredFreshness, greaterThanOrEqualTo(
        HabotPushTokenRegistry.freshnessFloor,
      ));

      gates.add(
        AissGate(
          id: 'PNSAD-021-G4',
          requirementSource:
              'Metric: Device Push-Token Freshness Rate -- Floor ">= 90% of '
              'active devices holding a valid, unexpired token", Optimal 0.97.',
          description:
              'This device reports 1.0 when it holds a token inside the '
              'rotation horizon and 0.0 when it does not; a stale token is '
              'noticed and refreshed before a send fails, and a fresh one is '
              'not refreshed for nothing',
          passed: true,
          detail:
              'horizon ${HabotPushTokenRegistry.refreshHorizon.inDays} days; '
              'device freshness ${measuredFreshness.toStringAsFixed(1)}; '
              'SCOPE: one device. The fleet percentage the metric names is a '
              'backend sum of this signal and is NOT produced here.',
        ),
      );
    });

    test('[PNSAD-021-G5] a refresh that fails leaves the device honestly '
        'stale rather than optimistically fresh', () async {
      final HabotPushTokenRegistry registry = HabotPushTokenRegistry(
        refresh: () async => throw const _NoNetwork(),
        clock: () => DateTime(2026, 8, 14, 9),
      );
      addTearDown(registry.dispose);

      expect(await registry.ensureFresh(), isFalse);
      expect(registry.isFresh, isFalse);
      expect(registry.deviceFreshness, 0);
      expect(registry.refreshSuccessRate, 0);

      gates.add(
        const AissGate(
          id: 'PNSAD-021-G5',
          requirementSource:
              'Metric: "holding a VALID, UNEXPIRED token" -- the floor is '
              'about what the device actually has, not about what it tried '
              'to get.',
          description:
              'A throwing refresh is caught and reported as a failure: the '
              'registry keeps no token it did not receive, and the attempt is '
              'counted against the success rate',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PNSAD-021',
        atomicStepReferenceId: 'PNSAD-021-A01',
        setupStepAction: 'Mobile Push-Driven Notification Routing '
            'Infrastructure',
        implementationOrder: 76,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Routing Outcome':
              'presented / presentedAndStored / navigated / sheetOpened / '
              'dropped -- one record per delivery, with a reason on every drop',
          'Target Route':
              'resolved through the Step 43 route table; an unresolvable '
              'target is dropped, not delivered to the fallback',
          'Token Freshness':
              measuredFreshness < 0
                  ? 'not measured'
                  : 'device reading ${measuredFreshness.toStringAsFixed(1)}, '
                        'horizon '
                        '${HabotPushTokenRegistry.refreshHorizon.inDays} days',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED ROW -- eleven columns describe document access '
              'control and row-level security (Expected Output "Document '
              'Isolation Nomenclature Sheet", Poka-Yoke about classification '
              'keys, GCP Alignment about Cloud IAM). Not gated. The Data '
              'Collected column is contaminated separately: "Build Status; '
              'Build Timestamp; Build Artifacts Path; Build Logs; Build '
              'Duration" are CI fields, not routing fields -- they are '
              'recorded here as not applicable rather than filled in with '
              'something invented. The Setup Step, the Description and the '
              'Metric are coherent. SCOPE RECORDED: the metric is a fleet '
              'percentage; a client can only observe its own token, and no '
              'fleet figure is asserted.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Device Push-Token Freshness Rate',
            observed: measuredFreshness < 0
                ? 'not measured'
                : 'THIS DEVICE: ${measuredFreshness.toStringAsFixed(1)} '
                      '(holds a token inside the '
                      '${HabotPushTokenRegistry.refreshHorizon.inDays}-day '
                      'rotation horizon). FLEET RATE NOT PRODUCED -- "% of '
                      'active devices" is a backend aggregate of this same '
                      'signal across devices, which no client-side suite can '
                      'observe.',
            floor: '>= 90% of active devices holding a valid, unexpired token',
            optimal: '0.97',
            ceiling: '99.5%+',
          ),
          AissMeasurement(
            metricName:
                'Delivery reach rate (this step\'s own, not from the sheet)',
            observed: measuredReach < 0
                ? 'not measured'
                : '${measuredReach.toStringAsFixed(2)} -- 4 routed, 1 '
                      'addressed to a route that does not resolve',
            floor: 'no sheet band',
            optimal: 'no sheet band',
            ceiling: 'no sheet band',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/delivery_router.dart',
        ],
      ),
    );
  });
}

class _NoNetwork implements Exception {
  const _NoNetwork();
  @override
  String toString() => 'No network';
}
