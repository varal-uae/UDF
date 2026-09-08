/// AISS Step 111 -- GEN-00146
/// "Test disconnecting the mobile network, entering data, and reconnecting."
/// Metric: Test Case Pass Rate -- floor >= 95%, optimal 100%.
///
/// A TEST STEP WITH A TEST METRIC, which is rare enough in this sheet to use
/// literally: the inventory below IS the defined test suite, and the pass rate
/// it returns is the number the metric asks for.
///
/// THE HONEST ANSWER TODAY. Run the row's own sentence against this app as it
/// stands: disconnect, type, reconnect. The entry is gone. 110 steps in, every
/// piece of state this app holds lives in memory. Step 47 built a connectivity
/// state machine and Step 48 built an offline banner, so the app can TELL you
/// it is offline; it cannot do anything about it.
///
/// This step does not fix that -- Steps 112-125 do. What it does is make the
/// gap MEASURABLE, so the steps that follow have an acceptance test that
/// existed before them and was not written to flatter them. That ordering is
/// the whole point: an inventory taken after the fix is an inventory shaped by
/// the fix.
///
/// WHAT IS INVENTORIED. Every state holder the built steps own, classified by
/// what SHOULD survive each of three events:
///
///   rebuild   -- a widget rebuild. Everything survives this; listed for
///                completeness so the three columns are comparable.
///   restart   -- the app process is killed and relaunched.
///   reinstall -- app data is cleared.
///
/// A holder whose `expected` durability is above its `actual` durability is a
/// LOSS. The suite's pass rate is the share of holders with no loss.
library;

/// How long a piece of state survives.
///
/// Ordered deliberately: a later value survives everything an earlier one
/// does, so `index` comparison is a meaningful durability comparison.
enum HabotDurability {
  /// Gone on the next widget rebuild.
  rebuild,

  /// Survives rebuilds, gone when the process dies.
  session,

  /// Survives a restart, gone on reinstall.
  device,

  /// Survives reinstall, because it lives on the server.
  server,
}

/// What kind of thing is holding the state.
enum HabotHolderKind {
  controller,
  inheritedWidget,
  inMemoryQueue,
  formBuffer,
  timer,
  cache,
}

/// One piece of state the app holds.
class HabotStateHolder {
  const HabotStateHolder({
    required this.name,
    required this.owningStep,
    required this.kind,
    required this.actual,
    required this.expected,
    required this.lossConsequence,
  });

  /// The Dart symbol, so this can be checked against the code rather than
  /// remembered.
  final String name;

  /// e.g. 'Step 90 GEN-04042'.
  final String owningStep;

  final HabotHolderKind kind;

  /// What it survives TODAY.
  final HabotDurability actual;

  /// What it SHOULD survive for this app to be usable on rural connectivity.
  final HabotDurability expected;

  /// What the user loses when it goes. Written in terms of the user's work,
  /// not the code -- "the job they accepted", not "the queue".
  final String lossConsequence;

  bool get isLoss => actual.index < expected.index;

  /// True where the state is deliberately ephemeral. Not every holder should
  /// be durable: a scroll offset that survives a restart is a bug, not a
  /// feature.
  bool get isDeliberatelyEphemeral => actual == expected;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'owning_step': owningStep,
    'kind': kind.name,
    'actual_durability': actual.name,
    'expected_durability': expected.name,
    'is_loss': isLoss,
    'loss_consequence': lossConsequence,
  };
}

/// The inventory.
class HabotStateInventory {
  const HabotStateInventory._();

  static const List<HabotStateHolder> holders = <HabotStateHolder>[
    HabotStateHolder(
      name: 'HabotConnectivityMonitor._pending',
      owningStep: 'Step 47 GEN-02720',
      kind: HabotHolderKind.inMemoryQueue,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'Everything the worker did while offline. This is the queue the '
          'offline banner is counting, and closing the app empties it.',
    ),
    HabotStateHolder(
      name: 'HabotTaskQueue',
      owningStep: 'Step 90 ERMWD-031-01',
      kind: HabotHolderKind.inMemoryQueue,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'Every job accepted but not yet submitted. The worker has done the '
          'work; the app has forgotten they were assigned it.',
    ),
    HabotStateHolder(
      name: 'PreferenceStore._values',
      owningStep: 'Step 49 IS22-RCGLA-022',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.server,
      lossConsequence:
          'Notification choices. These are written optimistically and rolled '
          'back on failure, so an offline change is lost twice over: once '
          'from the server and once from the device.',
    ),
    HabotStateHolder(
      name: 'FormBaseline (ErrorRollbackBoundary)',
      owningStep: 'Step 20 FIEVR-033',
      kind: HabotHolderKind.formBuffer,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'A half-completed form. This is the exact case the row names -- '
          'enter data, lose the connection, and the entry is gone.',
    ),
    HabotStateHolder(
      name: 'HabotAlertPanelController._active',
      owningStep: 'Step 73 FLADE-011-10',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'Unacknowledged system alerts. A P1 raised and then not shown again '
          'after a restart is an alert that did not happen.',
    ),
    HabotStateHolder(
      name: 'HabotNotificationCenter (read/unread)',
      owningStep: 'Step 69 GEN-04374',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.server,
      lossConsequence:
          'Which notifications have been read. After a restart everything is '
          'unread again, which trains people to ignore the badge.',
    ),
    HabotStateHolder(
      name: 'HabotDashboardController (filters)',
      owningStep: 'Step 54 GEN-00168',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'The filter a supervisor set. Cheap to re-apply, but re-applied '
          'every single launch.',
    ),
    HabotStateHolder(
      name: 'HabotThemeController._mode',
      owningStep: 'Step 3 TTMCS-004',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'An explicit light/dark choice. Reverting a user to "system" every '
          'launch overrides a preference they deliberately set.',
    ),
    HabotStateHolder(
      name: 'HabotStepMachine (wizard position)',
      owningStep: 'Step 17 IS02-CSIVW-005',
      kind: HabotHolderKind.controller,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'Progress through a multi-step wizard. Restarting mid-wizard puts '
          'the user back at step one with their answers gone.',
    ),
    HabotStateHolder(
      name: 'HabotInteractionTimer',
      owningStep: 'Step 93 GEN-03866',
      kind: HabotHolderKind.timer,
      actual: HabotDurability.session,
      expected: HabotDurability.session,
      lossConsequence:
          'Nothing. A timing measurement of the current interaction is '
          'meaningless across a restart; deliberately ephemeral.',
    ),
    HabotStateHolder(
      name: 'HabotFrictionTracker / HabotHesitationTracker',
      owningStep: 'Steps 26-27 GEN-01848 / GEN-01297',
      kind: HabotHolderKind.cache,
      actual: HabotDurability.session,
      expected: HabotDurability.device,
      lossConsequence:
          'Telemetry gathered while offline -- which is exactly the session '
          'whose friction is worth knowing about.',
    ),
    HabotStateHolder(
      name: 'Scroll offsets / HabotVirtualizedList position',
      owningStep: 'Step 44 GEN-01474',
      kind: HabotHolderKind.inheritedWidget,
      actual: HabotDurability.rebuild,
      expected: HabotDurability.rebuild,
      lossConsequence:
          'Nothing. A scroll position that survived a restart would be a bug.',
    ),
  ];

  /// Holders that lose state they should keep.
  static List<HabotStateHolder> get losses =>
      holders.where((HabotStateHolder h) => h.isLoss).toList();

  /// Holders that are correctly ephemeral.
  static List<HabotStateHolder> get correctlyEphemeral =>
      holders.where((HabotStateHolder h) => !h.isLoss).toList();

  /// The metric the row asks for: the share of inventoried holders that
  /// survive what they are supposed to survive.
  ///
  /// Today this is deliberately, honestly low. Steps 112-125 move it, and the
  /// number is what shows they did.
  static double get passRate =>
      holders.isEmpty ? 0 : correctlyEphemeral.length / holders.length;

  static const double floor = 0.95;
  static const double optimal = 1.0;

  static bool get meetsFloor => passRate >= floor;

  /// Holders whose loss costs the user work, as opposed to convenience. These
  /// are the ones Steps 112-118 have to close first.
  static List<HabotStateHolder> get workLosing => losses
      .where(
        (HabotStateHolder h) =>
            h.kind == HabotHolderKind.inMemoryQueue ||
            h.kind == HabotHolderKind.formBuffer,
      )
      .toList();

  static String report() {
    final StringBuffer b = StringBuffer()
      ..writeln('STATE-LOSS INVENTORY -- ${holders.length} holders')
      ..writeln(
        'Pass rate ${(passRate * 100).toStringAsFixed(1)}% '
        '(floor ${(floor * 100).toStringAsFixed(0)}%) -- '
        '${losses.length} holder(s) lose state they should keep',
      )
      ..writeln();
    for (final HabotStateHolder h in holders) {
      b.writeln(
        '${h.isLoss ? "LOSS " : "ok   "} ${h.name}  '
        '[${h.owningStep}]  ${h.actual.name} -> needs ${h.expected.name}',
      );
      if (h.isLoss) {
        b.writeln('        ${h.lossConsequence}');
      }
    }
    return b.toString();
  }
}

/// The three-phase test the row names: disconnect, enter, reconnect.
///
/// This is a MODEL of the sequence, not a device test -- there is no handset
/// in this suite. It exists so that "does entered data survive?" is answered
/// by running something rather than by reasoning about it, and so that Steps
/// 112-118 have a harness to plug their real store into.
class HabotStateLossScenario {
  const HabotStateLossScenario({
    required this.name,
    required this.holder,
    required this.enteredWhileOffline,
  });

  final String name;
  final HabotStateHolder holder;

  /// What the user did during the disconnected phase.
  final String enteredWhileOffline;

  /// Whether the entry survives a process restart, given the holder's actual
  /// durability. Derived, never asserted.
  bool get survivesRestart =>
      holder.actual.index >= HabotDurability.device.index;

  /// Whether it survives reconnection alone -- i.e. the app stayed open.
  bool get survivesReconnect =>
      holder.actual.index >= HabotDurability.session.index;

  String get outcome {
    if (survivesRestart) {
      return 'kept';
    }
    if (survivesReconnect) {
      return 'kept only if the app is never closed';
    }
    return 'lost immediately';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'scenario': name,
    'holder': holder.name,
    'entered_while_offline': enteredWhileOffline,
    'survives_reconnect': survivesReconnect,
    'survives_restart': survivesRestart,
    'outcome': outcome,
  };
}
