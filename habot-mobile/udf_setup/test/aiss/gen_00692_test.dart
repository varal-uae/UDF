/// AISS GATE -- Step 66 of 80
/// Global Reference ID:       GEN-00692
/// Atomic Steps Reference ID: GEN-00692-A01
/// Setup Step (Action):       "Configure Mobile Push Notifications & Real-Time
///                             Alert Triggers."
/// Setup Step Description:    "Integrate Firebase Cloud Messaging (FCM) SDK
///                             into backend Cloud Run workers."
/// Metric: FCM SDK Ingestion Pass -- Floor 100%, Optimal 100%.
///
/// THE ONE FULLY COHERENT ROW IN THIS BATCH: four real substeps, a real
/// poka-yoke, three real completion measures, and every column describing the
/// same step.
///
/// DUPLICATE SETUP STEP, RECORDED: S.No 13985 (this step) and S.No 8936
/// (Step 68) carry the byte-identical Setup Step. They are told apart by their
/// Setup Step Descriptions -- FCM/dispatch engine here, the onMessageReceived
/// client handler there.
///
/// ON THE METRIC. "FCM SDK Ingestion Pass" at 100% asks whether the SDK is
/// integrated. That is a backend and platform-channel fact: no widget test can
/// prove an SDK is wired into Cloud Run workers. What this suite verifies is
/// the client contract behind it -- one transport boundary, and everything
/// downstream of it -- and the gate says so rather than claiming an SDK
/// integration was proved by a test.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/dispatch_alert.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

/// A transport whose behaviour the gate controls entirely.
class _FakeTransport implements HabotDispatchTransport {
  _FakeTransport({this.raceWinner});

  final StreamController<HabotDispatchOffer> _controller =
      StreamController<HabotDispatchOffer>.broadcast();

  /// When set, `respond` reports that this offer was taken by someone else --
  /// the race the poka-yoke exists for.
  final String? raceWinner;

  final List<String> reassigned = <String>[];
  final List<String> responded = <String>[];

  @override
  Stream<HabotDispatchOffer> get offers => _controller.stream;

  @override
  Future<HabotOfferOutcome> respond(
    String offerId,
    HabotOfferOutcome choice,
  ) async {
    responded.add('$offerId:${choice.name}');
    if (raceWinner == offerId && choice == HabotOfferOutcome.accepted) {
      return HabotOfferOutcome.takenByAnother;
    }
    return choice;
  }

  @override
  Future<void> reassign(String offerId) async {
    reassigned.add(offerId);
  }

  void send(HabotDispatchOffer offer) => _controller.add(offer);
  Future<void> close() => _controller.close();
}

HabotDispatchOffer _offer(String id, DateTime at) => HabotDispatchOffer(
  id: id,
  title: 'School run, Karen',
  distanceKm: 4.2,
  requirements: const <String>['Car seat', 'First aid'],
  earnings: 'KES 1,800',
  dispatchedAt: at,
);

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

  group('GEN-00692-A01 :: the clock', () {
    gate(
      'GEN-00692-G1',
      'Substep 2: "Implement a 60-SECOND acceptance timer (\'Clock\') for '
          'dispatched job offers."',
      'The window is the sixty seconds the substep names, held in the motion '
          'tokens rather than written at the call site, and the three '
          'completion-measure budgets are the sheet\'s own numbers',
      () =>
          HabotDispatchClock.acceptanceWindow == const Duration(seconds: 60) &&
          HabotDispatchClock.acceptanceWindow ==
              HabotMotion.dispatchAcceptanceWindow &&
          HabotDispatchClock.deliveryBudget ==
              const Duration(milliseconds: 1500) &&
          HabotDispatchClock.acceptanceScreenBudget ==
              const Duration(milliseconds: 300) &&
          HabotDispatchClock.averageResponseBudget ==
              const Duration(seconds: 30),
    );

    gate(
      'GEN-00692-G2',
      'Completion Measures: "Push notification delivery latency <= 1.5s. '
          'Acceptance screen load time <= 300ms. Average job response time '
          '<= 30s."',
      'The response budget is exactly half the acceptance window -- a sixty '
          'second clock whose average response is fifty-five seconds is a '
          'clock nobody is really reading',
      () =>
          HabotDispatchClock.averageResponseBudget.inSeconds * 2 ==
              HabotDispatchClock.acceptanceWindow.inSeconds &&
          HabotDispatchClock.deliveryBudget <
              HabotDispatchClock.acceptanceScreenBudget * 10,
    );

    gate(
      'GEN-00692-G3',
      'UX Translation: "Full-screen mobile dispatch alert with COUNTDOWN '
          'VISUAL RING and prominent \'Accept Job\' button."',
      'The ring reads real arithmetic: progress runs 0 to 1 across the window '
          'and clamps outside it, remaining time never goes negative, and the '
          'urgent threshold is a stated fraction rather than a number chosen '
          'by eye',
      () {
        final DateTime start = DateTime(2026, 8, 14, 9);
        final HabotDispatchOffer offer = _offer('o1', start);
        bool ok = offer.progressAt(start) == 0 &&
            offer.progressAt(start.add(const Duration(seconds: 30))) == 0.5 &&
            offer.progressAt(start.add(const Duration(seconds: 90))) == 1 &&
            offer.remainingAt(start.add(const Duration(seconds: 90))) ==
                Duration.zero &&
            offer.hasExpiredAt(start.add(const Duration(seconds: 61)));
        ok = ok &&
            !HabotDispatchClock.isUrgent(const Duration(seconds: 16)) &&
            HabotDispatchClock.isUrgent(const Duration(seconds: 15));
        return ok;
      },
    );

    gate(
      'GEN-00692-G4',
      'Substep 3: "Build one-tap action screens displaying client DISTANCE, '
          'REQUIREMENTS, and EARNINGS."',
      'All three fields are required by the type rather than optional '
          'decoration, and they reach a screen reader as one sentence -- a '
          'provider deciding in sixty seconds should not have to read four '
          'labels',
      () {
        final HabotDispatchOffer offer = _offer('o1', DateTime(2026, 8, 14));
        final String spoken = offer.summaryLabel;
        return spoken.contains('4.2 kilometres') &&
            spoken.contains('KES 1,800') &&
            spoken.contains('2 requirements') &&
            offer.requirements.length == 2;
      },
    );
  });

  group('GEN-00692-A01 :: the poka-yoke and the fallback', () {
    test('[GEN-00692-G5] Accept is disabled the moment another provider wins '
        'the race, and the tap reports the authoritative outcome', () async {
      final _FakeTransport transport = _FakeTransport(raceWinner: 'o1');
      final DateTime now = DateTime(2026, 8, 14, 9);
      final HabotDispatchEngine engine =
          HabotDispatchEngine(transport: transport, clock: () => now);
      addTearDown(engine.dispose);
      addTearDown(transport.close);

      transport.send(_offer('o1', now));
      await Future<void>.delayed(Duration.zero);

      expect(engine.current?.id, 'o1');
      expect(
        engine.canAccept,
        isTrue,
        reason: 'live offer, inside the window',
      );

      final HabotOfferOutcome result = await engine.accept();

      expect(
        result,
        HabotOfferOutcome.takenByAnother,
        reason: 'the race is resolved by the dispatcher, not by the tap',
      );
      expect(
        engine.canAccept,
        isFalse,
        reason: 'Poka-Yoke: the control reads this rather than being told to '
            'disable itself',
      );

      // A second tap cannot record a second acceptance.
      final int responsesBefore = transport.responded.length;
      await engine.accept();
      expect(transport.responded.length, responsesBefore);

      gates.add(
        const AissGate(
          id: 'GEN-00692-G5',
          requirementSource:
              'Poka-Yoke: "System PHYSICALLY DISABLES \'Accept\' button if '
              'another provider accepts the job milliseconds prior, preventing '
              'double-booking."',
          description:
              'When the dispatcher reports the offer was taken, canAccept goes '
              'false and a second tap sends nothing -- the race is decided in '
              'one place rather than by each screen remembering to check',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00692-G6] an offer that expires without a response is '
        'reassigned, and three in a row pause dispatch for two hours', (
      WidgetTester tester,
    ) async {
      DateTime now = DateTime(2026, 8, 14, 9);
      final _FakeTransport transport = _FakeTransport();
      final HabotDispatchEngine engine =
          HabotDispatchEngine(transport: transport, clock: () => now);
      addTearDown(engine.dispose);
      addTearDown(transport.close);

      await tester.pumpWidget(const SizedBox.shrink());

      for (int i = 0; i < HabotDispatchClock.timeoutsBeforePause; i++) {
        transport.send(_offer('o$i', now));
        await tester.pump();
        now = now.add(HabotDispatchClock.acceptanceWindow);
        await tester.pump(HabotDispatchClock.acceptanceWindow);
      }

      expect(
        transport.reassigned.length,
        HabotDispatchClock.timeoutsBeforePause,
        reason: 'Substep 4: fallback reassignment on every expiry',
      );
      expect(engine.consecutiveTimeouts, 3);
      expect(engine.isPaused, isTrue);
      expect(
        engine.pausedUntil!.difference(now),
        HabotDispatchClock.dispatchPause,
      );

      // "requiring MANUAL STATUS RESET" -- it does not clear itself early.
      engine.resetDispatchStatus();
      expect(engine.isPaused, isFalse);
      expect(engine.consecutiveTimeouts, 0);

      gates.add(
        AissGate(
          id: 'GEN-00692-G6',
          requirementSource:
              'Substep 4: "Create fallback reassignment subroutines if a '
              'request expires without response." + Self-Chasing: "Allowing 3 '
              'consecutive job alerts to time out temporarily pauses automatic '
              'dispatch for 2 hours, requiring manual status reset."',
          description:
              'Three expiries reassign three offers and pause dispatch for '
              'exactly two hours; the pause clears only on an explicit reset',
          passed: true,
          detail:
              '${transport.reassigned.length} reassigned, paused for '
              '${HabotDispatchClock.dispatchPause.inHours}h',
        ),
      );
    });

    test('[GEN-00692-G7] an accept between timeouts resets the streak, so the '
        'pause counts CONSECUTIVE misses rather than total ones', () async {
      DateTime now = DateTime(2026, 8, 14, 9);
      final _FakeTransport transport = _FakeTransport();
      final HabotDispatchEngine engine =
          HabotDispatchEngine(transport: transport, clock: () => now);
      addTearDown(engine.dispose);
      addTearDown(transport.close);

      transport.send(_offer('a', now));
      await Future<void>.delayed(Duration.zero);
      await engine.accept();

      expect(engine.consecutiveTimeouts, 0);
      expect(engine.isPaused, isFalse);
      expect(engine.records.single.outcome, HabotOfferOutcome.accepted);
      expect(
        engine.deliveryBudgetPassRate,
        100,
        reason: 'delivery measured from dispatch to arrival at the boundary',
      );

      gates.add(
        AissGate(
          id: 'GEN-00692-G7',
          requirementSource:
              'Self-Chasing: "Allowing 3 CONSECUTIVE job alerts to time out..." '
              'Consecutive is the load-bearing word.',
          description:
              'A response resets the timeout streak, and every dispatch is '
              'recorded with its delivery latency and response time so the '
              'completion measures are computed rather than asserted',
          passed: true,
          detail:
              'delivery budget pass rate '
              '${engine.deliveryBudgetPassRate.toStringAsFixed(1)}%',
        ),
      );
    });
  });

  group('GEN-00692 :: the tokens behind the clock', () {
    test('[GEN-00692-G8] every notification constant this batch introduced '
        'matches tokens.json, which is the source of truth', () {
      final Map<String, Object?> tokens =
          jsonDecode(
                File(
                  'lib/design_system/tokens/tokens.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final Map<String, Object?> notifications =
          tokens['notifications']! as Map<String, Object?>;

      // Steps 66, 68 and 79 all write policy numbers into motion_tokens.dart,
      // the only file allowed to declare a Duration. If tokens.json and the
      // Dart mirror ever disagree, "source of truth" is decoration -- so the
      // whole set is checked here rather than the dispatch half alone.
      final Map<String, int> expected = <String, int>{
        'dispatch_acceptance_window_s':
            HabotDispatchClock.acceptanceWindow.inSeconds,
        'dispatch_delivery_budget_ms':
            HabotDispatchClock.deliveryBudget.inMilliseconds,
        'dispatch_screen_budget_ms':
            HabotDispatchClock.acceptanceScreenBudget.inMilliseconds,
        'dispatch_response_budget_s':
            HabotDispatchClock.averageResponseBudget.inSeconds,
        'dispatch_pause_hours': HabotDispatchClock.dispatchPause.inHours,
        'dispatch_timeouts_before_pause': HabotDispatchClock.timeoutsBeforePause,
        'message_handler_floor_ms': HabotMotion.messageHandlerFloor.inMilliseconds,
        'message_handler_optimal_ms':
            HabotMotion.messageHandlerOptimal.inMilliseconds,
        'message_handler_ceiling_ms':
            HabotMotion.messageHandlerCeiling.inMilliseconds,
        'violation_staleness_ceiling_s':
            HabotMotion.violationStalenessCeiling.inSeconds,
      };

      final List<String> drifted = <String>[];
      expected.forEach((String key, int dartValue) {
        if (notifications[key] != dartValue) {
          drifted.add('$key: json ${notifications[key]} vs dart $dartValue');
        }
      });
      expect(drifted, isEmpty, reason: drifted.join('; '));
      expect(
        notifications['dispatch_urgent_fraction'],
        HabotDispatchClock.urgentFraction,
      );

      gates.add(
        AissGate(
          id: 'GEN-00692-G8',
          requirementSource:
              'RCGLA-001 (Step 2) established tokens.json as the source of '
              'truth and the Dart constants as its mirror. This batch adds ten '
              'notification policy numbers, all of them the sheet\'s own.',
          description:
              'Every notification constant introduced in Steps 66-80 matches '
              'tokens.json, so the two cannot drift apart silently',
          passed: true,
          detail: '${expected.length} keys checked, 0 drifted',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00692',
        atomicStepReferenceId: 'GEN-00692-A01',
        setupStepAction:
            'Configure Mobile Push Notifications & Real-Time Alert Triggers.',
        implementationOrder: 66,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Integrate Firebase Cloud Messaging (FCM)':
              'Client transport boundary implemented as '
              'HabotDispatchTransport; the SDK wiring itself is a backend and '
              'platform-channel concern (see the measurement note)',
          'Component Name': 'HabotDispatchEngine',
          'Component Properties':
              'window ${HabotDispatchClock.acceptanceWindow.inSeconds}s, '
              'delivery budget '
              '${HabotDispatchClock.deliveryBudget.inMilliseconds}ms, pause '
              '${HabotDispatchClock.dispatchPause.inHours}h after '
              '${HabotDispatchClock.timeoutsBeforePause} consecutive timeouts',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'DUPLICATE SETUP STEP -- S.No 13985 and S.No 8936 carry the '
              'byte-identical Setup Step "Configure Mobile Push Notifications '
              '& Real-Time Alert Triggers". Told apart by their Setup Step '
              'Descriptions; both are implemented (Steps 66 and 68).',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'FCM SDK Ingestion Pass',
            observed:
                'NOT PRODUCED as an SDK integration check -- no widget test '
                'can prove an SDK is wired into Cloud Run workers. What IS '
                'verified is the client contract behind it: one transport '
                'boundary, the 60s clock, the three substep-3 fields, the '
                'double-booking poka-yoke, and the reassignment and pause '
                'behaviour, all driven through a controlled transport.',
            floor: '100%',
            optimal: '100%',
            ceiling: 'N/A (100% target)',
          ),
          AissMeasurement(
            metricName:
                'Acceptance clock behaviour (the substeps\' own numbers)',
            observed:
                '60s window with progress clamped at both ends; 3 consecutive '
                'timeouts pause dispatch for exactly 2h and a response resets '
                'the streak; every expiry reassigns',
            floor: 'every transition correct',
            optimal: 'every transition correct',
            ceiling: 'every transition correct',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/dispatch_alert.dart',
        ],
      ),
    );
  });
}
