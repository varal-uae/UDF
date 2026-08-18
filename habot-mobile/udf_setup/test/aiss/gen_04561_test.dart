/// AISS GATE -- Step 67 of 80
/// Global Reference ID:       GEN-04561
/// Atomic Steps Reference ID: GEN-04561-A01
/// Setup Step (Action):       "Build notification payload generators setting
///                             titles, bodies, and target routes."
/// Metric: Push Notification Delivery Rate -- Floor 0.95, Optimal 0.99,
///         Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC NOTE, RECORDED: delivery rate is a property of the push service. A
/// perfectly formed payload can still be dropped by FCM, and a generator
/// cannot influence that. What a generator owns is whether what it produced is
/// DELIVERABLE -- complete, within platform limits, and pointed at a real
/// destination. That is what is measured.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/route_table.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';
import 'package:udf_setup/design_system/shell/app_shell.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int attempted = 0;
  int deliverable = 0;

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

  HabotNotificationFactory factory() =>
      HabotNotificationFactory(router: HabotShellRoutes.router());

  group('GEN-04561-A01 :: titles and bodies', () {
    gate(
      'GEN-04561-G1',
      'Setup Step (Action): "Build notification payload generators setting '
          'TITLES, BODIES, and target routes."',
      'A payload cannot be constructed with an empty or over-long title or '
          'body: there is no public constructor, and the factory returns null '
          'with a named defect rather than a silently truncated notification',
      () {
        final HabotNotificationFactory f = factory();
        HabotPayloadValidation? rejection;
        attempted += 5;

        final HabotNotificationPayload? good = f.build(
          id: 'n1',
          kind: HabotNotificationKind.informational,
          title: 'Job ready',
          body: 'Tap to accept.',
          targetRoute: '/tasks',
        );
        if (good != null) {
          deliverable++;
        }

        final bool emptyTitle = f.build(
              id: 'n2',
              kind: HabotNotificationKind.informational,
              title: '   ',
              body: 'Tap to accept.',
              targetRoute: '/tasks',
              onRejected: (HabotPayloadValidation v) => rejection = v,
            ) ==
            null;
        final bool namedDefect = rejection!.defects.contains(
          HabotPayloadDefect.emptyTitle,
        );

        final bool longTitle = f.build(
              id: 'n3',
              kind: HabotNotificationKind.informational,
              title: 'x' * (HabotPayloadLimits.maxTitleChars + 1),
              body: 'Tap to accept.',
              targetRoute: '/tasks',
            ) ==
            null;
        final bool emptyBody = f.build(
              id: 'n4',
              kind: HabotNotificationKind.informational,
              title: 'Job ready',
              body: '',
              targetRoute: '/tasks',
            ) ==
            null;
        final bool longBody = f.build(
              id: 'n5',
              kind: HabotNotificationKind.informational,
              title: 'Job ready',
              body: 'y' * (HabotPayloadLimits.maxBodyChars + 1),
              targetRoute: '/tasks',
            ) ==
            null;

        return good != null &&
            emptyTitle &&
            namedDefect &&
            longTitle &&
            emptyBody &&
            longBody;
      },
    );

    gate(
      'GEN-04561-G2',
      'Platform reality: a title past the platform limit is not rejected by '
          'the device, it is TRUNCATED silently -- which loses the tail of the '
          'message without telling anyone.',
      'The limits are stated, held well under the FCM 4KB data ceiling, and an '
          'over-large payload is refused rather than sent to be truncated',
      () {
        final HabotNotificationFactory f = factory();
        attempted++;
        final HabotPayloadValidation oversized = f.validate(
          title: 'Job ready',
          body: 'Tap to accept.',
          targetRoute: '/tasks',
          data: <String, String>{
            'blob': 'z' * (HabotPayloadLimits.maxDataBytes + 1),
          },
        );
        return HabotPayloadLimits.maxDataBytes < 4096 &&
            HabotPayloadLimits.maxTitleChars > 0 &&
            HabotPayloadLimits.maxBodyChars >
                HabotPayloadLimits.maxTitleChars &&
            !oversized.isDeliverable &&
            oversized.defects.contains(HabotPayloadDefect.payloadTooLarge);
      },
    );
  });

  group('GEN-04561-A01 :: the target route', () {
    gate(
      'GEN-04561-G3',
      'Setup Step (Action): "...and TARGET ROUTES." + GEN-02082 (Step 43): a '
          'link that resolves to nothing is a blank screen, "which is the '
          'worst possible answer to a tapped notification".',
      'The route is checked against the Step 43 router at CONSTRUCTION time, '
          'not at tap time: a real route builds, an unrouted one is refused, '
          'and a parameterised route resolves',
      () {
        final HabotNotificationFactory f = factory();
        attempted += 2;
        final HabotNotificationPayload? real = f.build(
          id: 'n6',
          kind: HabotNotificationKind.approval,
          title: 'Approval needed',
          body: 'Batch B-2026-08 is waiting.',
          targetRoute: '/tasks/42',
        );
        if (real != null) {
          deliverable++;
        }
        HabotPayloadValidation? rejection;
        final bool refused = f.build(
              id: 'n7',
              kind: HabotNotificationKind.informational,
              title: 'Nowhere',
              body: 'This goes nowhere.',
              targetRoute: '/does-not-exist',
              onRejected: (HabotPayloadValidation v) => rejection = v,
            ) ==
            null;
        return real != null &&
            real.targetRoute == '/tasks/42' &&
            f.routeIsReal('/tasks/42') &&
            !f.routeIsReal('/does-not-exist') &&
            !f.routeIsReal('') &&
            refused &&
            rejection!.defects.contains(HabotPayloadDefect.unroutableTarget);
      },
    );

    gate(
      'GEN-04561-G4',
      'Setup Step (Action) -- the Step 43 router FALLS BACK so a tap never '
          'lands nowhere. That is right at tap time and the wrong standard '
          'here: a notification that silently opens the overview has not '
          'delivered its news.',
      'The factory treats a fallback match as unroutable rather than accepting '
          'it, so an addressing mistake is caught by the sender instead of '
          'being absorbed by the receiver',
      () {
        final HabotRouter router = HabotShellRoutes.router();
        final HabotNotificationFactory f =
            HabotNotificationFactory(router: router);
        // The router itself resolves the bad link -- to the fallback.
        final HabotRouteMatch match = router.match('/does-not-exist');
        return match.isFallback &&
            match.route.path == HabotShellRoutes.fallback.path &&
            !f.routeIsReal('/does-not-exist');
      },
    );

    gate(
      'GEN-04561-G5',
      'Setup Step (Action) -- the payload has to survive the wire.',
      'The message form carries the id, the kind and the route in its data '
          'block, so the receiver in Step 68 has everything it needs to route '
          'without a second lookup',
      () {
        final HabotNotificationPayload payload = factory().build(
          id: 'n8',
          kind: HabotNotificationKind.critical,
          title: 'Override in effect',
          body: 'A P1 breach is being investigated.',
          targetRoute: '/settings',
          data: <String, String>{'incident': 'INC-4102'},
        )!;
        attempted++;
        deliverable++;
        final Map<String, Object> wire = payload.toMessage();
        final Map<String, String> data =
            wire['data']! as Map<String, String>;
        final Map<String, String> note =
            wire['notification']! as Map<String, String>;
        return data['id'] == 'n8' &&
            data['kind'] == 'critical' &&
            data['route'] == '/settings' &&
            data['incident'] == 'INC-4102' &&
            note['title'] == 'Override in effect' &&
            payload.approximateBytes < HabotPayloadLimits.maxDataBytes;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04561',
        atomicStepReferenceId: 'GEN-04561-A01',
        setupStepAction:
            'Build notification payload generators setting titles, bodies, '
            'and target routes.',
        implementationOrder: 67,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotNotificationFactory',
          'Component Properties':
              'title <= ${HabotPayloadLimits.maxTitleChars} chars, body <= '
              '${HabotPayloadLimits.maxBodyChars} chars, data <= '
              '${HabotPayloadLimits.maxDataBytes} bytes; every route checked '
              'against the Step 43 router at construction',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row, so the derivation had two '
              'distinct inputs rather than three.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Payload deliverability (what a generator owns)',
            observed:
                '$deliverable of $attempted attempted payloads came out '
                'deliverable; every rejection named its defect rather than '
                'failing silently, and every accepted payload points at a '
                'route the Step 43 router resolves without falling back',
            floor: 'every defect named',
            optimal: 'every defect named',
            ceiling: 'every defect named',
          ),
          const AissMeasurement(
            metricName: 'Push Notification Delivery Rate (the sheet metric)',
            observed:
                'NOT PRODUCED -- delivery is a property of the push service, '
                'not of a payload generator. A perfectly formed payload can '
                'still be dropped by FCM, and no client-side test can observe '
                'that. No number is asserted here in its place.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '0.999',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/notification_payload.dart',
        ],
      ),
    );
  });
}
