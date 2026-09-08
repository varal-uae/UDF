/// AISS GATE -- Step 119 of 135
/// Global Reference ID:       GEN-04418
/// Atomic Steps Reference ID: GEN-04418
/// Atomic Step: "Create an app-lifecycle listener triggering state cleanup
///               when app goes to background."
/// Metric: Memory Leak Incident Rate -- Floor < 1 per session (gate),
///         Optimal 0 per session, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// METRIC NOT PRODUCIBLE: a leak rate needs a profiler on a handset. What is
/// gated is its precondition -- that every registered resource released.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/lifecycle_observer.dart';

import 'aiss_reporter.dart';

/// A well-behaved resource.
class _Cache implements HabotLifecycleSensitive {
  _Cache(this.lifecycleLabel);

  @override
  final String lifecycleLabel;

  bool _held = true;
  int backgrounded = 0;
  int foregrounded = 0;

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.release;

  @override
  bool get isReleased => !_held;

  @override
  void onBackgrounded() {
    backgrounded++;
    _held = false;
  }

  @override
  void onForegrounded() {
    foregrounded++;
    _held = true;
  }
}

/// One that says it released and did not. The failure this step exists to
/// make visible.
class _LeakyCache implements HabotLifecycleSensitive {
  @override
  String get lifecycleLabel => 'LeakyCache';

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.release;

  @override
  bool get isReleased => false;

  @override
  void onBackgrounded() {}

  @override
  void onForegrounded() {}
}

/// One that throws.
class _ThrowingResource implements HabotLifecycleSensitive {
  @override
  String get lifecycleLabel => 'ThrowingResource';

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.detach;

  @override
  bool get isReleased => true;

  @override
  void onBackgrounded() => throw StateError('boom');

  @override
  void onForegrounded() {}
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);

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

  HabotLifecycleObserver observer() =>
      HabotLifecycleObserver(clock: () => now);

  group('GEN-04418 :: the app is finally told', () {
    gate(
      'GEN-04418-G1',
      'From the build order: "the app has never once been told it was '
          'backgrounded. Nothing in 118 steps reacts to it."',
      'Every registered resource is told on backgrounding and told again on '
          'return, and the observer reports what was released',
      () {
        final HabotLifecycleObserver o = observer();
        final _Cache a = _Cache('A');
        final _Cache b = _Cache('B');
        o
          ..register(a)
          ..register(b);
        final HabotLifecycleSweep sweep = o.background();
        o.foreground();
        return sweep.registered == 2 &&
            sweep.released == 2 &&
            sweep.isClean &&
            a.backgrounded == 1 &&
            b.backgrounded == 1 &&
            a.foregrounded == 1 &&
            o.isInForeground;
      },
    );

    gate(
      'GEN-04418-G2',
      'A callback in the widget tree is a callback a refactor deletes, and '
          'nothing breaks visibly when it does.',
      'A resource that CLAIMS to release and does not is named in the sweep, '
          'so a failure has an address rather than being a count nobody can '
          'act on',
      () {
        final HabotLifecycleObserver o = observer();
        o
          ..register(_Cache('good'))
          ..register(_LeakyCache());
        final HabotLifecycleSweep sweep = o.background();
        return !sweep.isClean &&
            sweep.released == 1 &&
            sweep.registered == 2 &&
            sweep.releaseRate == 0.5 &&
            sweep.failures.single.contains('LeakyCache') &&
            sweep.failures.single.contains('release') &&
            o.allFailures.length == 1;
      },
    );

    gate(
      'GEN-04418-G3',
      'A resource that throws on the way down must not stop the ones behind '
          'it from being told.',
      'A throwing resource is recorded as a failure and the sweep continues',
      () {
        final HabotLifecycleObserver o = observer();
        final _Cache after = _Cache('after');
        o
          ..register(_ThrowingResource())
          ..register(after);
        final HabotLifecycleSweep sweep = o.background();
        return sweep.failures.length == 1 &&
            sweep.failures.single.contains('threw on background') &&
            after.backgrounded == 1 &&
            sweep.released == 1;
      },
    );
  });

  group('GEN-04418 :: the platform is not tidy', () {
    gate(
      'GEN-04418-G4',
      '`inactive` fires for a notification shade pull and an incoming call '
          'banner. Releasing there would tear the app down every time a '
          'notification arrives.',
      'Only paused, detached and hidden trigger a sweep; inactive is '
          'deliberately ignored, and resumed brings everything back',
      () {
        final HabotLifecycleObserver o = observer();
        final _Cache c = _Cache('cache');
        o.register(c);

        o.didChangeAppLifecycleState(AppLifecycleState.inactive);
        final bool ignoredInactive = o.isInForeground && o.sweeps.isEmpty;

        o.didChangeAppLifecycleState(AppLifecycleState.paused);
        final bool sweptOnPaused = !o.isInForeground && o.sweeps.length == 1;

        o.didChangeAppLifecycleState(AppLifecycleState.resumed);
        return ignoredInactive &&
            sweptOnPaused &&
            o.isInForeground &&
            c.foregrounded == 1;
      },
    );

    gate(
      'GEN-04418-G5',
      'The platform can send paused twice, and does not promise that every '
          'background is paired with a foreground.',
      'Backgrounding twice sweeps once, and foregrounding without a preceding '
          'background is a no-op rather than a spurious resume',
      () {
        final HabotLifecycleObserver o = observer();
        final _Cache c = _Cache('cache');
        o.register(c);
        o.background();
        o.background();
        final bool sweptOnce = o.sweeps.length == 1 && c.backgrounded == 1;
        o.foreground();
        final Duration second = o.foreground();
        return sweptOnce && second == Duration.zero && c.foregrounded == 1;
      },
    );

    gate(
      'GEN-04418-G6',
      'Step 120 subtracts backgrounded time from anything a worker is being '
          'timed against, so the observer has to measure it.',
      'Time away is accumulated across separate backgroundings rather than '
          'only the most recent one',
      () {
        final HabotLifecycleObserver o = observer();
        o.register(_Cache('c'));
        o.background();
        now = now.add(const Duration(minutes: 3));
        o.foreground();
        now = now.add(const Duration(minutes: 1));
        o.background();
        now = now.add(const Duration(minutes: 2));
        o.foreground();
        return o.totalBackgrounded == const Duration(minutes: 5) &&
            o.sweeps.length == 2 &&
            HabotLifecycleObserver.metricNote.contains('NOT PRODUCED');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04418',
        atomicStepReferenceId: 'GEN-04418',
        setupStepAction:
            'Create an app-lifecycle listener triggering state cleanup when '
            'app goes to background.',
        implementationOrder: 119,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLifecycleObserver / HabotLifecycleSensitive',
          'Component Properties':
              '${HabotLifecycleAction.values.length} declared actions '
              '(release, suspend, detach); resources register rather than '
              'being called back, so a failure to release is countable and '
              'named; total backgrounded time accumulated for Step 120',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Registered resources released on backgrounding',
            observed:
                'All of them, in the clean case. A resource that claims to '
                'release and does not drops the rate and is NAMED in the '
                'sweep; a resource that throws is recorded and does not stop '
                'the ones behind it being told.',
            floor: 'every registered resource released',
            optimal: 'every registered resource released',
            ceiling: 'every registered resource released',
          ),
          const AissMeasurement(
            metricName: 'Memory Leak Incident Rate (the sheet metric)',
            observed:
                'NOT PRODUCED. It needs a profiler attached to a handset over '
                'a real session; no widget test can observe it and no number '
                'is invented. What was measured is its precondition -- that '
                'everything registered actually let go -- which is the part a '
                'client can be held to.',
            floor: '< 1 per session',
            optimal: '0 per session',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/lifecycle_observer.dart',
        ],
      ),
    );
  });
}
