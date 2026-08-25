/// AISS: GEN-00843-A01 -- "Deploy Automated MTO Task Allocation & Exception
/// Ranking Engine."
/// Setup Step Description: "Program auto-reallocation logic RE-ASSIGNING TASKS
/// IF UNCOMPLETED WITHIN 5 MINUTES."
/// Metric: Auto-Reallocation Timer -- Floor 5 mins, Optimal 5 mins,
///         Ceiling 5 mins.
///
/// THE METRIC IS THE REQUIREMENT, which is rare enough to note: floor, optimal
/// and ceiling are the same number, and that number is the rule. So the gate
/// does not check a range -- it checks that the window IS five minutes, that
/// it comes from the token file rather than being written here, and that a
/// task crossing it is actually reassigned.
///
/// RANKING IS STEP 78's, NOT A SECOND ORDERING. `HabotAlertPriority` and the
/// priority-then-oldest rule were built and gated for alerts in Step 78. An
/// exception queue that sorted differently would mean two answers to "what is
/// most urgent", so [HabotTaskQueue.ranked] uses the same comparator, and a
/// gate proves the two agree on the same input.
///
/// AISS: GEN-03591-A01 -- "Produce the expected output: SLA Timer Component
/// and Automated Escalation Engine."
/// Metric: Output Acceptance Criteria -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
///
/// A ROW WRITTEN AS A DELIVERABLE, RECORDED: the Setup Step and its
/// Description are the same sentence, and both are phrased as an output rather
/// than an action. Its metric measures whether the deliverable was accepted,
/// which is project tracking rather than a property of the component --
/// recorded, and the two named artefacts are gated as behaviour instead.
///
/// THE SLA TARGET IS THE SHEET'S OWN 15 MINUTES, from MCIIM-021's Self-Chasing
/// column: "workers will fail the 15-minute timer because they cannot read the
/// image." That is the only task deadline the sheet names anywhere in this
/// batch, so it is the one used, and it lives in the token file next to the
/// Step 66 dispatch clock rather than inline here.
///
/// ESCALATION GOES WHERE ESCALATIONS ALREADY GO. Step 73 built the alert panel
/// and Step 80 built the admission join. An escalation is a notification, so it
/// passes both -- and because it is raised as `critical`, the Step 80 map makes
/// it non-suppressible by design. Exactly once per task: an engine that raises
/// the same breach on every tick teaches operators to ignore it.
library;

import 'package:flutter/foundation.dart';

import '../notifications/alert_panel.dart';
import '../notifications/alert_priority.dart';
import '../notifications/notification_payload.dart';
import '../notifications/notification_preference_join.dart';
import '../tokens/motion_tokens.dart';
import 'byt_isolation.dart';

/// One unit of work in the queue.
///
/// The [byt] is the isolated crop from Step 81 -- the queue moves tasks
/// around, it never widens what one shows.
@immutable
class HabotMtoTask {
  const HabotMtoTask({
    required this.byt,
    required this.priority,
    required this.queuedAt,
    this.allocatedTo,
    this.allocatedAt,
    this.completedAt,
    this.reallocationCount = 0,
  });

  final HabotByt byt;
  final HabotAlertPriority priority;
  final DateTime queuedAt;

  /// Null while the task is waiting.
  final String? allocatedTo;
  final DateTime? allocatedAt;
  final DateTime? completedAt;

  /// How many times this task has been handed to a new worker. Carried on the
  /// task because a task on its third worker is a task with a problem.
  final int reallocationCount;

  String get id => byt.id;
  String get prompt => byt.prompt;

  bool get isAllocated => allocatedTo != null && completedAt == null;
  bool get isComplete => completedAt != null;
  bool get isWaiting => allocatedTo == null && completedAt == null;

  HabotMtoTask copyWith({
    String? allocatedTo,
    DateTime? allocatedAt,
    DateTime? completedAt,
    int? reallocationCount,
    bool clearAllocation = false,
  }) => HabotMtoTask(
    byt: byt,
    priority: priority,
    queuedAt: queuedAt,
    allocatedTo: clearAllocation ? null : (allocatedTo ?? this.allocatedTo),
    allocatedAt: clearAllocation ? null : (allocatedAt ?? this.allocatedAt),
    completedAt: completedAt ?? this.completedAt,
    reallocationCount: reallocationCount ?? this.reallocationCount,
  );
}

/// One reallocation, recorded. A task that silently changed hands is a task
/// nobody can explain later.
@immutable
class HabotReallocation {
  const HabotReallocation({
    required this.taskId,
    required this.from,
    required this.at,
    required this.heldFor,
  });

  final String taskId;
  final String from;
  final DateTime at;
  final Duration heldFor;

  @override
  String toString() =>
      '$taskId returned from $from after ${heldFor.inMinutes} min';
}

/// GEN-00843: allocation, ranking and reallocation.
class HabotTaskQueue extends ChangeNotifier {
  HabotTaskQueue({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<HabotMtoTask> _tasks = <HabotMtoTask>[];
  final List<HabotReallocation> _reallocations = <HabotReallocation>[];

  /// The sheet's number, from the token file.
  static Duration get reallocationWindow => HabotMotion.mtoReallocationWindow;

  List<HabotMtoTask> get tasks => List<HabotMtoTask>.unmodifiable(_tasks);

  List<HabotReallocation> get reallocations =>
      List<HabotReallocation>.unmodifiable(_reallocations);

  int get waitingCount => _tasks.where((HabotMtoTask t) => t.isWaiting).length;
  int get inProgressCount =>
      _tasks.where((HabotMtoTask t) => t.isAllocated).length;
  int get completedCount => _tasks.where((HabotMtoTask t) => t.isComplete).length;

  void enqueue(HabotMtoTask task) {
    _tasks.add(task);
    notifyListeners();
  }

  /// The ranking: priority first, then oldest first inside a priority.
  ///
  /// Identical to [HabotAlertSorting.sort]'s rule, and `GEN-00843-G2` proves
  /// the two agree rather than asserting that they do.
  List<HabotMtoTask> ranked() {
    final List<HabotMtoTask> open = _tasks
        .where((HabotMtoTask t) => !t.isComplete)
        .toList();
    open.sort((HabotMtoTask a, HabotMtoTask b) {
      final int byPriority = a.priority.rank.compareTo(b.priority.rank);
      if (byPriority != 0) {
        return byPriority;
      }
      return a.queuedAt.compareTo(b.queuedAt);
    });
    return List<HabotMtoTask>.unmodifiable(open);
  }

  /// Hands the top-ranked waiting task to [workerId]. Null when there is
  /// nothing waiting.
  HabotMtoTask? allocate(String workerId) {
    final Iterable<HabotMtoTask> waiting = ranked().where(
      (HabotMtoTask t) => t.isWaiting,
    );
    if (waiting.isEmpty) {
      return null;
    }
    final HabotMtoTask next = waiting.first;
    final int position = _tasks.indexWhere((HabotMtoTask t) => t.id == next.id);
    final HabotMtoTask allocated = next.copyWith(
      allocatedTo: workerId,
      allocatedAt: _clock(),
    );
    _tasks[position] = allocated;
    notifyListeners();
    return allocated;
  }

  void complete(String taskId) {
    final int index = _tasks.indexWhere((HabotMtoTask t) => t.id == taskId);
    if (index < 0 || _tasks[index].isComplete) {
      return;
    }
    _tasks[index] = _tasks[index].copyWith(completedAt: _clock());
    notifyListeners();
  }

  /// The five-minute rule. Any task held longer than the window without being
  /// completed goes back to waiting, and the hand-back is recorded.
  ///
  /// Returns the tasks that were reallocated on this pass.
  List<HabotMtoTask> reclaimStale() {
    final DateTime now = _clock();
    final List<HabotMtoTask> reclaimed = <HabotMtoTask>[];
    for (int i = 0; i < _tasks.length; i++) {
      final HabotMtoTask task = _tasks[i];
      final DateTime? since = task.allocatedAt;
      if (!task.isAllocated || since == null) {
        continue;
      }
      final Duration held = now.difference(since);
      if (held < reallocationWindow) {
        continue;
      }
      _reallocations.add(
        HabotReallocation(
          taskId: task.id,
          from: task.allocatedTo!,
          at: now,
          heldFor: held,
        ),
      );
      final HabotMtoTask returned = task.copyWith(
        clearAllocation: true,
        reallocationCount: task.reallocationCount + 1,
      );
      _tasks[i] = returned;
      reclaimed.add(returned);
    }
    if (reclaimed.isNotEmpty) {
      notifyListeners();
    }
    return reclaimed;
  }

  /// Nothing is ever dropped: every task is waiting, in progress or complete.
  bool get isAccountedFor =>
      waitingCount + inProgressCount + completedCount == _tasks.length;
}

/// GEN-03591: the SLA timer, as a policy rather than a widget.
class HabotSlaPolicy {
  const HabotSlaPolicy._();

  /// MCIIM-021 Self-Chasing: the 15-minute timer.
  static Duration get target => HabotMotion.mtoSlaTarget;

  /// Three quarters of the target: still early enough to act.
  static Duration get warning => HabotMotion.mtoSlaWarning;

  static bool isBreached(Duration elapsed) => elapsed >= target;
  static bool isWarning(Duration elapsed) =>
      elapsed >= warning && elapsed < target;

  /// The fraction of the SLA consumed, clamped so a badly overdue task does
  /// not render a progress bar wider than its track.
  static double progressFor(Duration elapsed) {
    final double raw = elapsed.inMilliseconds / target.inMilliseconds;
    if (raw.isNaN || raw < 0) {
      return 0;
    }
    return raw > 1 ? 1 : raw;
  }

  static Duration remainingFor(Duration elapsed) {
    final Duration left = target - elapsed;
    return left.isNegative ? Duration.zero : left;
  }
}

/// One escalation, recorded.
@immutable
class HabotEscalation {
  const HabotEscalation({
    required this.taskId,
    required this.at,
    required this.elapsed,
    required this.admitted,
  });

  final String taskId;
  final DateTime at;
  final Duration elapsed;

  /// False when the Step 80 join refused it -- which cannot happen for a
  /// critical escalation, and is recorded rather than assumed.
  final bool admitted;
}

/// GEN-03591: the escalation engine.
///
/// Reads elapsed time, raises at most one escalation per task, and sends it
/// through the surfaces that already exist.
class HabotEscalationEngine {
  HabotEscalationEngine({
    required this.panel,
    required this.preferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Step 73. Where an un-ignorable alert goes.
  final HabotAlertPanelController panel;

  /// Step 80. The one admission gate every notification passes.
  final HabotNotificationPreferenceManager preferences;

  final DateTime Function() _clock;

  final Set<String> _escalated = <String>{};
  final List<HabotEscalation> _escalations = <HabotEscalation>[];

  List<HabotEscalation> get escalations =>
      List<HabotEscalation>.unmodifiable(_escalations);

  int get escalationCount => _escalations.length;

  bool hasEscalated(String taskId) => _escalated.contains(taskId);

  /// Evaluates one task. Returns true when this call raised an escalation.
  bool evaluate({required HabotMtoTask task, required Duration elapsed}) {
    if (task.isComplete || !HabotSlaPolicy.isBreached(elapsed)) {
      return false;
    }
    if (!_escalated.add(task.id)) {
      // Already raised. An engine that re-raises on every tick trains people
      // to ignore it, which is the opposite of escalating.
      return false;
    }
    final bool admitted = preferences.admit(
      id: 'sla.${task.id}',
      // A missed SLA on a task nobody is working is a system fact, not
      // marketing -- and `critical` is one of the two kinds Step 80 makes
      // non-suppressible.
      kind: HabotNotificationKind.critical,
    );
    if (admitted) {
      panel.raise(
        HabotSystemAlert(
          id: 'sla.${task.id}',
          severity: HabotAlertSeverity.critical,
          headline: 'Task ${task.id} has passed its SLA',
          detail:
              '${task.priority.label} task held for ${elapsed.inMinutes} '
              'minutes against a ${HabotSlaPolicy.target.inMinutes}-minute '
              'target.',
        ),
      );
    }
    _escalations.add(
      HabotEscalation(
        taskId: task.id,
        at: _clock(),
        elapsed: elapsed,
        admitted: admitted,
      ),
    );
    return true;
  }

  /// Evaluates a whole queue against one clock reading.
  int sweep(HabotTaskQueue queue, DateTime now) {
    int raised = 0;
    for (final HabotMtoTask task in queue.tasks) {
      // Elapsed runs from when the task was allocated if it has been, and from
      // when it was queued if nobody has picked it up -- an untouched task
      // breaching its SLA is the more serious of the two.
      final DateTime since = task.allocatedAt ?? task.queuedAt;
      if (evaluate(task: task, elapsed: now.difference(since))) {
        raised++;
      }
    }
    return raised;
  }
}
