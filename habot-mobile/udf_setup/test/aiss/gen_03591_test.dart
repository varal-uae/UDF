/// AISS GATE -- Step 95 of 95
/// Global Reference ID:       GEN-03591
/// Atomic Steps Reference ID: GEN-03591-A01
/// Setup Step (Action):       "Produce the expected output: SLA Timer
///                             Component and Automated Escalation Engine."
/// Metric: Output Acceptance Criteria -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
///
/// A ROW WRITTEN AS A DELIVERABLE, RECORDED. The Setup Step and its
/// Description are the same sentence and both are phrased as an output rather
/// than an action, and the metric measures whether that output was accepted --
/// which is project tracking, not a property of the component. Recorded as
/// such. The two named artefacts are gated as behaviour instead.
///
/// THE SLA TARGET IS THE SHEET'S OWN 15 MINUTES. MCIIM-021's Self-Chasing
/// column -- the row that anchors this batch -- says "workers will fail the
/// 15-minute timer because they cannot read the image." That is the only task
/// deadline named anywhere in these fifteen rows, so it is the one used, and
/// it lives in the token file next to the Step 66 dispatch clock rather than
/// inline in the engine.
///
/// ESCALATION GOES WHERE ESCALATIONS ALREADY GO. Step 73 built the
/// un-ignorable alert panel and Step 80 built the admission join. An
/// escalation is a notification, so it passes both -- and because it is raised
/// as `critical`, the Step 80 map makes it non-suppressible, which is the
/// decision that step recorded so it could be argued with.
///
/// EXACTLY ONCE. An engine that re-raises the same breach on every tick trains
/// operators to ignore the panel, which is the opposite of escalating.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/task_queue.dart';
import 'package:udf_setup/design_system/notifications/alert_panel.dart';
import 'package:udf_setup/design_system/notifications/alert_priority.dart';
import 'package:udf_setup/design_system/notifications/delivery_router.dart';
import 'package:udf_setup/design_system/notifications/notification_preference_join.dart';
import 'package:udf_setup/design_system/preferences/preference_manager.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

final DateTime _base = DateTime(2026, 8, 18, 9);

HabotMtoTask _task(String id, {DateTime? allocatedAt, DateTime? completedAt}) =>
    HabotMtoTask(
      byt: HabotByt.fromDelivery(
        id: id,
        box: _box,
        snippet: Uri.parse(
          'https://assets.habot.internal/crops/$id.png'
          '?crop=${HabotCropContract.signatureFor(_box)}',
        ),
        prompt: 'Read the invoice total',
        expectedFormat: 'digits and a decimal point',
      )!,
      priority: HabotAlertPriority.p1,
      queuedAt: _base,
      allocatedTo: allocatedAt == null ? null : 'worker-a',
      allocatedAt: allocatedAt,
      completedAt: completedAt,
    );

/// Preferences with everything switched off, to prove a critical escalation
/// still gets through the Step 80 join.
({
  PreferenceStore store,
  HabotNotificationPreferenceManager manager,
}) _preferences() {
  final PreferenceStore store = PreferenceStore(
    writer: (HabotPreferenceColumn column, bool value) async =>
        HabotPreferenceWriteResult.written,
    initial: <HabotPreferenceColumn, bool>{
      HabotPreferenceColumn.allowPromo: false,
      HabotPreferenceColumn.allowTransaction: false,
    },
  );
  final HabotNotificationPreferenceManager manager =
      HabotNotificationPreferenceManager(
        store: store,
        registry: HabotPushTokenRegistry(refresh: () async => 'token'),
      );
  return (store: store, manager: manager);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  int measuredEscalations = -1;

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

  group('GEN-03591-A01 :: the SLA timer', () {
    gate(
      'GEN-03591-G1',
      'Named artefact 1: "SLA Timer Component". Its target is MCIIM-021\'s '
          'own Self-Chasing column: "workers will fail the 15-MINUTE TIMER '
          'because they cannot read the image."',
      'The target is fifteen minutes from the token file, the warning point '
          'sits at three quarters of it, and progress is clamped so a badly '
          'overdue task cannot render past the end of its own track',
      () =>
          HabotSlaPolicy.target == const Duration(minutes: 15) &&
          HabotSlaPolicy.target == HabotMotion.mtoSlaTarget &&
          HabotSlaPolicy.warning == HabotMotion.mtoSlaWarning &&
          !HabotSlaPolicy.isBreached(const Duration(minutes: 14, seconds: 59)) &&
          HabotSlaPolicy.isBreached(const Duration(minutes: 15)) &&
          HabotSlaPolicy.isWarning(const Duration(minutes: 12)) &&
          !HabotSlaPolicy.isWarning(const Duration(minutes: 16)) &&
          HabotSlaPolicy.progressFor(const Duration(minutes: 30)) == 1.0 &&
          HabotSlaPolicy.progressFor(Duration.zero) == 0.0 &&
          HabotSlaPolicy.remainingFor(const Duration(minutes: 20)) ==
              Duration.zero &&
          HabotSlaPolicy.remainingFor(const Duration(minutes: 5)) ==
              const Duration(minutes: 10),
    );
  });

  group('GEN-03591-A01 :: the escalation engine', () {
    test('[GEN-03591-G2] a breach escalates exactly once and reaches the '
        'Step 73 panel', () {
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final ({
        PreferenceStore store,
        HabotNotificationPreferenceManager manager,
      })
      prefs = _preferences();
      addTearDown(() {
        prefs.manager.dispose();
        prefs.store.dispose();
        panel.dispose();
      });
      final HabotEscalationEngine engine = HabotEscalationEngine(
        panel: panel,
        preferences: prefs.manager,
        clock: () => _base,
      );

      final HabotMtoTask task = _task('byt-1', allocatedAt: _base);
      final bool first = engine.evaluate(
        task: task,
        elapsed: const Duration(minutes: 16),
      );
      final bool second = engine.evaluate(
        task: task,
        elapsed: const Duration(minutes: 30),
      );
      measuredEscalations = engine.escalationCount;

      expect(first, isTrue);
      expect(second, isFalse, reason: 'the same breach must not raise twice');
      expect(measuredEscalations, 1);
      expect(engine.hasEscalated('byt-1'), isTrue);
      expect(panel.active.length, 1);
      expect(panel.active.single.severity, HabotAlertSeverity.critical);
      expect(panel.active.single.headline, contains('byt-1'));
      expect(panel.active.single.detail, contains('15-minute target'));
      expect(panel.isBlocking, isTrue);

      gates.add(
        AissGate(
          id: 'GEN-03591-G2',
          requirementSource:
              'Named artefact 2: "Automated Escalation Engine", read against '
              'FLADE-011-10 (Step 73), which owns the un-ignorable panel.',
          description:
              'A task past its SLA raises exactly one escalation, on the '
              'existing alert panel, with the elapsed time and the target in '
              'the message -- and a second evaluation of the same task raises '
              'nothing',
          passed: true,
          detail: '2 evaluations, $measuredEscalations escalation',
        ),
      );
    });

    test('[GEN-03591-G3] an escalation passes the Step 80 join, and passes it '
        'even with every preference switched off', () {
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final ({
        PreferenceStore store,
        HabotNotificationPreferenceManager manager,
      })
      prefs = _preferences();
      addTearDown(() {
        prefs.manager.dispose();
        prefs.store.dispose();
        panel.dispose();
      });
      final HabotEscalationEngine engine = HabotEscalationEngine(
        panel: panel,
        preferences: prefs.manager,
        clock: () => _base,
      );

      expect(
        prefs.store.valueOf(HabotPreferenceColumn.allowPromo),
        isFalse,
        reason: 'offers off',
      );
      expect(
        prefs.store.valueOf(HabotPreferenceColumn.allowTransaction),
        isFalse,
        reason: 'receipts off too',
      );

      engine.evaluate(
        task: _task('byt-2', allocatedAt: _base),
        elapsed: const Duration(minutes: 20),
      );

      expect(engine.escalations.single.admitted, isTrue);
      expect(prefs.manager.decisions.single.delivered, isTrue);
      expect(
        prefs.manager.decisions.single.reason,
        HabotSuppressionReason.none,
      );
      expect(panel.active, isNotEmpty);

      gates.add(
        const AissGate(
          id: 'GEN-03591-G3',
          requirementSource:
              'PNSAD-010 (Step 80): every notification passes the admission '
              'join, and `critical` is one of the two kinds recorded as NOT '
              'suppressible.',
          description:
              'The escalation is admitted through the same join every other '
              'notification passes, and is admitted even with both preference '
              'columns switched off -- because a missed SLA is a system fact, '
              'not marketing',
          passed: true,
        ),
      );
    });

    gate(
      'GEN-03591-G4',
      'Setup Step (Action): an escalation ENGINE, which runs over a queue '
          'rather than over one task. Read with GEN-00843 (Step 94).',
      'A sweep over a queue escalates only the tasks that are actually late, '
          'leaves completed and in-time tasks alone, and measures untouched '
          'tasks from when they were queued rather than from when someone '
          'picked them up',
      () {
        final HabotAlertPanelController panel = HabotAlertPanelController();
        final ({
          PreferenceStore store,
          HabotNotificationPreferenceManager manager,
        })
        prefs = _preferences();
        addTearDown(() {
          prefs.manager.dispose();
          prefs.store.dispose();
          panel.dispose();
        });
        final HabotTaskQueue queue = HabotTaskQueue(clock: () => _base);
        addTearDown(queue.dispose);
        final HabotEscalationEngine engine = HabotEscalationEngine(
          panel: panel,
          preferences: prefs.manager,
          clock: () => _base,
        );

        queue
          // Untouched since it was queued 20 minutes ago: late.
          ..enqueue(_task('stale'))
          // Picked up two minutes ago: in time.
          ..enqueue(
            _task(
              'fresh',
              allocatedAt: _base.add(const Duration(minutes: 18)),
            ),
          )
          // Finished, however long it took: not an escalation.
          ..enqueue(
            _task(
              'done',
              allocatedAt: _base,
              completedAt: _base.add(const Duration(minutes: 5)),
            ),
          );

        final int raised = engine.sweep(
          queue,
          _base.add(const Duration(minutes: 20)),
        );
        return raised == 1 &&
            engine.hasEscalated('stale') &&
            !engine.hasEscalated('fresh') &&
            !engine.hasEscalated('done') &&
            panel.active.length == 1;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03591',
        atomicStepReferenceId: 'GEN-03591-A01',
        setupStepAction:
            'Produce the expected output: SLA Timer Component and Automated '
            'Escalation Engine.',
        implementationOrder: 95,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'SLA Timer Component':
              'target ${HabotSlaPolicy.target.inMinutes} minutes, warning at '
              '${HabotSlaPolicy.warning.inMinutes} minutes, progress clamped '
              'to [0, 1]',
          'Automated Escalation Engine':
              'one escalation per task, raised on the Step 73 panel and '
              'admitted through the Step 80 join',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'A ROW WRITTEN AS A DELIVERABLE -- Setup Step and Description '
              'are the same sentence, phrased as an output, and the metric '
              '("Output Acceptance Criteria") measures whether the deliverable '
              'was accepted rather than how the component behaves. Recorded; '
              'the two named artefacts are gated as behaviour instead. SLA '
              'TARGET SOURCED: the 15 minutes comes from MCIIM-021\'s '
              'Self-Chasing column, the only task deadline named in this '
              'batch, and lives in the token file.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Output Acceptance Criteria',
            observed:
                'Both named artefacts exist and were measured as behaviour: '
                'the SLA policy breaches at exactly '
                '${HabotSlaPolicy.target.inMinutes} minutes with progress '
                'clamped to 1.0 beyond it, and the engine raised '
                '${measuredEscalations < 0 ? "not measured" : measuredEscalations} '
                'escalation from two evaluations of the same breach. '
                'ACCEPTANCE ITSELF IS NOT PRODUCED -- whether an output is '
                '"accepted" is a project-tracking judgement, not something a '
                'suite observes.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_queue.dart',
        ],
      ),
    );
  });
}
