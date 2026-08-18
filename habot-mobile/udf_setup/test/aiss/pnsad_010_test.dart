/// AISS GATE -- Step 80 of 80
/// Global Reference ID:       PNSAD-010
/// Atomic Steps Reference ID: PNSAD-010
/// Setup Step (Action):       "Build Mobile Push Notification Layout &
///                             Preference Control Manager"
/// Setup Step Description:    "Program subscription registration flow
///                             targeting device token engines."
/// Metric: Device Push-Token Freshness Rate --
///         Floor ">= 90% of active devices holding a valid, unexpired token",
///         Optimal 0.97, Ceiling "99.5%+". Output field: 'PASS'.
///
/// THE MOST CONTAMINATED ROW IN ANY BATCH SO FAR, RECORDED. Eleven columns
/// describe an authentication and API-gateway step, verbatim:
///   Decision Before       "Auth provider selection."
///   Why This Matters      "Secures identity and access management for mobile
///                          users."
///   Mobile App First      "Stateless auth allows mobile apps to scale without
///                          hitting a central session database."
///   UX Translation        "Invisible session handling."
///   Flow Impact           "Secure API access."
///   Dashboard Implication "Auth success/failure metrics."
///   Must Standardize      "API Gateway JWT validation."
///   Atomic Reusability    "Universal Auth middleware."
///   Common Library        "Infra Repo / API Gateway."
///   Expected Output       "Secure Auth flow ... 100% of unauthorized requests
///                          blocked at Gateway."
///   Poka-Yoke             "API Gateway inherently rejects invalid signatures
///                          before hitting Cloud Run."
/// None are gated. The Standard column is contaminated in its own way -- it
/// cites WCAG 2.1 AA for a push-token freshness metric, which is a standard
/// about contrast and interaction, not about token rotation. Recorded, not
/// reconciled.
///
/// TWO COLUMNS ARE COHERENT and are what this step is measured against: the
/// Setup Step Description ("subscription registration flow targeting device
/// token engines") and the Metric, which genuinely fits a subscription step.
/// The Data Requirement column also names the real UI work -- "Style
/// preference toggle items using standard MD3 switch component specifications"
/// -- which is Step 50, already built and gated.
///
/// WHAT THIS STEP ACTUALLY IS, AND WHY IT IS LAST. Steps 49-50 built a
/// preference store and a screen where a user says what they want. Steps 66-79
/// built everything that produces and delivers notifications. Until this file
/// existed, nothing connected them: a user could switch offers off and keep
/// receiving them, and the preference screen would be decorative. This is the
/// enforcement point: G4 gates the registration flow, and it also asserts that
/// the shell presents nothing without passing through `admit()` first -- a
/// join with a way around it is not a join.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/delivery_router.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';
import 'package:udf_setup/design_system/notifications/notification_preference_join.dart';
import 'package:udf_setup/design_system/preferences/preference_manager.dart';

import 'aiss_reporter.dart';

PreferenceStore _store({bool promo = true, bool transaction = true}) =>
    PreferenceStore(
      writer: (HabotPreferenceColumn column, bool value) async =>
          HabotPreferenceWriteResult.written,
      initial: <HabotPreferenceColumn, bool>{
        HabotPreferenceColumn.allowPromo: promo,
        HabotPreferenceColumn.allowTransaction: transaction,
      },
    );

HabotPushTokenRegistry _registry({bool succeeds = true}) =>
    HabotPushTokenRegistry(
      refresh: () async => succeeds ? 'token-1' : null,
      clock: () => DateTime(2026, 8, 14, 9),
    );

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredAdmission = -1;

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

  group('PNSAD-010 :: the mapping', () {
    gate(
      'PNSAD-010-G1',
      'Setup Step (Action): "PREFERENCE CONTROL Manager" -- read against '
          'GEN-03404 (Step 50), which built the columns a user actually sees.',
      'Every notification kind resolves through the mapping, so no kind can '
          'arrive with nobody having decided whether it is suppressible -- '
          'informational answers to the promo column, approval and failure to '
          'the transactional one',
      () =>
          HabotNotificationPreferenceMap.mappingIsTotal &&
          HabotNotificationPreferenceMap.columnFor(
                HabotNotificationKind.informational,
              ) ==
              HabotPreferenceColumn.allowPromo &&
          HabotNotificationPreferenceMap.columnFor(
                HabotNotificationKind.approval,
              ) ==
              HabotPreferenceColumn.allowTransaction &&
          HabotNotificationPreferenceMap.columnFor(
                HabotNotificationKind.failure,
              ) ==
              HabotPreferenceColumn.allowTransaction,
    );

    gate(
      'PNSAD-010-G2',
      'THE RECORDED DECISION, stated so it can be argued with: a P1 breach is '
          'not marketing, and a dispatch offer is work the user is on shift '
          'for. Neither is suppressible by a notification toggle.',
      'critical and dispatch map to no column at all and are always allowed, '
          'and the reason given is "not suppressible" rather than "allowed" -- '
          'so the record says which of the two it was',
      () {
        final PreferenceStore store = _store(
          promo: false,
          transaction: false,
        );
        addTearDown(store.dispose);
        final HabotNotificationPreferenceManager manager =
            HabotNotificationPreferenceManager(
              store: store,
              registry: _registry(),
            );
        addTearDown(manager.dispose);

        return !HabotNotificationPreferenceMap.isSuppressible(
              HabotNotificationKind.critical,
            ) &&
            !HabotNotificationPreferenceMap.isSuppressible(
              HabotNotificationKind.dispatch,
            ) &&
            // Every toggle off, and these two still get through.
            manager.allows(HabotNotificationKind.critical) &&
            manager.allows(HabotNotificationKind.dispatch) &&
            manager.reasonFor(HabotNotificationKind.critical) ==
                HabotSuppressionReason.notSuppressible &&
            manager.reasonFor(HabotNotificationKind.informational) ==
                HabotSuppressionReason.userPreference &&
            !manager.allows(HabotNotificationKind.informational) &&
            !manager.allows(HabotNotificationKind.approval);
      },
    );

    gate(
      'PNSAD-010-G3',
      'Setup Step (Action): the manager is what makes the preference screen '
          'MEAN something -- a switch that changes nothing is worse than no '
          'switch.',
      'With offers off and receipts on, four of five kinds are admitted and '
          'the suppressed one is recorded with its reason, so a user asking '
          'why they heard nothing can be answered',
      () {
        final PreferenceStore store = _store(promo: false);
        addTearDown(store.dispose);
        final HabotNotificationPreferenceManager manager =
            HabotNotificationPreferenceManager(
              store: store,
              registry: _registry(),
            );
        addTearDown(manager.dispose);

        for (final HabotNotificationKind kind in HabotNotificationKind.values) {
          manager.admit(id: 'n-${kind.name}', kind: kind);
        }
        measuredAdmission = manager.admissionRate;

        final HabotSuppressionRecord suppressed = manager.decisions.singleWhere(
          (HabotSuppressionRecord d) => !d.delivered,
        );
        return manager.decisions.length == 5 &&
            manager.admittedCount == 4 &&
            manager.suppressedCount == 1 &&
            measuredAdmission == 0.8 &&
            suppressed.kind == HabotNotificationKind.informational &&
            suppressed.reason == HabotSuppressionReason.userPreference;
      },
    );
  });

  group('PNSAD-010 :: the registration flow', () {
    test('[PNSAD-010-G4] changing a preference registers or drops the '
        'subscription, without anyone remembering to call anything', () async {
      final PreferenceStore store = _store();
      addTearDown(store.dispose);
      final List<String> subscriptionEvents = <String>[];
      final HabotNotificationPreferenceManager manager =
          HabotNotificationPreferenceManager(
            store: store,
            registry: _registry(),
            onSubscriptionChanged:
                (HabotPreferenceColumn column, bool subscribed) =>
                    subscriptionEvents.add(
                      '${column.columnName}=$subscribed',
                    ),
          );
      addTearDown(manager.dispose);

      // Startup: register the current state of everything, so a device that
      // was offline when a preference changed catches up.
      expect(await manager.synchronise(), isTrue);
      expect(subscriptionEvents, <String>[
        'allow_promo=true',
        'allow_transaction=true',
      ]);

      subscriptionEvents.clear();
      await store.set(HabotPreferenceColumn.allowPromo, false);
      expect(
        subscriptionEvents,
        contains('allow_promo=false'),
        reason: 'the store notified, and the join acted on it',
      );
      expect(
        subscriptionEvents.where(
          (String e) => e.startsWith('allow_transaction'),
        ),
        isEmpty,
        reason: 'a column that did not change does not re-register',
      );
      expect(
        manager.allows(HabotNotificationKind.informational),
        isFalse,
        reason: 'and the suppression takes effect immediately',
      );

      // A join with a way around it is not a join: the shell's only
      // presentation path asks the manager first.
      final String shell = File('lib/habot_shell_page.dart').readAsStringSync();
      expect(
        shell.contains('_notificationPreferences.admit('),
        isTrue,
        reason: 'the shell presents nothing without passing the join',
      );

      gates.add(
        AissGate(
          id: 'PNSAD-010-G4',
          requirementSource:
              'Setup Step Description: "Program SUBSCRIPTION REGISTRATION FLOW '
              'targeting device token engines."',
          description:
              'The join listens to the preference store, so a switch moving '
              'registers or drops the matching subscription with no call site '
              'having to remember; an unchanged column produces no event',
          passed: true,
          detail:
              '${subscriptionEvents.length} subscription event(s) from one '
              'toggle',
        ),
      );
    });

    test('[PNSAD-010-G5] the metric this row does own: synchronise reports '
        'honestly when the device has no usable token', () async {
      final PreferenceStore store = _store();
      addTearDown(store.dispose);
      final HabotPushTokenRegistry registry = _registry(succeeds: false);
      addTearDown(registry.dispose);
      final HabotNotificationPreferenceManager manager =
          HabotNotificationPreferenceManager(
            store: store,
            registry: registry,
          );
      addTearDown(manager.dispose);

      final bool fresh = await manager.synchronise();
      expect(
        fresh,
        isFalse,
        reason:
            'the refresh returned nothing, so the device holds no valid token',
      );
      expect(registry.deviceFreshness, 0);
      expect(
        registry.isFresh,
        isFalse,
        reason: 'no token is not the same as a token that might work',
      );

      gates.add(
        const AissGate(
          id: 'PNSAD-010-G5',
          requirementSource:
              'Metric: Device Push-Token Freshness Rate -- Floor ">= 90% of '
              'active devices holding a VALID, UNEXPIRED token."',
          description:
              'Registration reports the token state it actually has: a failed '
              'refresh makes synchronise return false rather than registering '
              'subscriptions against a token the device does not hold',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PNSAD-010',
        atomicStepReferenceId: 'PNSAD-010-A01',
        setupStepAction:
            'Build Mobile Push Notification Layout & Preference Control '
            'Manager',
        implementationOrder: 80,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'the notification id carried on every decision',
          'Execution Status':
              'delivered / suppressed, with the reason kept apart from the '
              'outcome: "switched off" and "cannot be switched off" are '
              'different facts',
          'Execution Timestamp':
              'held by the notification, not duplicated here',
          'Step Outcome':
              'HabotSuppressionReason -- none / userPreference / '
              'notSuppressible',
          'User ID':
              'not held by the join; the preference store is already scoped to '
              'the signed-in user (Step 49)',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'MOST CONTAMINATED ROW IN ANY BATCH -- eleven columns describe '
              'an authentication and API-gateway step (Expected Output '
              '"Secure Auth flow", Poka-Yoke about Cloud Run signatures, Must '
              'Standardize "API Gateway JWT validation"). None gated. The '
              'Standard column cites WCAG 2.1 AA for a token-freshness metric, '
              'which is a standard about contrast and interaction; recorded, '
              'not reconciled. Two columns are coherent -- the Setup Step '
              'Description and the Metric -- and are what the five gates are '
              'drawn from. SCOPE RECORDED, as in Step 76: the fleet '
              'percentage is a backend aggregate; this suite observes one '
              'device.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Device Push-Token Freshness Rate',
            observed:
                'THIS DEVICE ONLY -- registration refuses to proceed as though '
                'fresh when the refresh returns nothing (G5). The fleet '
                'percentage the metric names is a backend aggregate and is NOT '
                'PRODUCED here; the same scope note was recorded for PNSAD-021 '
                '(Step 76), which shares this metric verbatim.',
            floor: '>= 90% of active devices holding a valid, unexpired token',
            optimal: '0.97',
            ceiling: '99.5%+',
          ),
          AissMeasurement(
            metricName:
                'Notification admission rate (this step\'s own, not from the '
                'sheet)',
            observed: measuredAdmission < 0
                ? 'not measured'
                : '${measuredAdmission.toStringAsFixed(2)} with offers off -- '
                      'four of five kinds admitted, the suppressed one '
                      'recorded with its reason',
            floor: 'no sheet band',
            optimal: 'no sheet band',
            ceiling: 'no sheet band',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/notification_preference_join.dart',
          'lib/habot_shell_page.dart',
        ],
      ),
    );
  });
}
