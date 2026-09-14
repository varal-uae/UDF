/// AISS GATE -- Step 160 of 175
/// Global Reference ID:       GEN-04649
/// Atomic Steps Reference ID: GEN-04649
/// Setup Step (Action) / Atomic Step: "Capture funnel progression events
///   across multi-step support ticket flows."
/// Metric: Analytics Event Schema Validation Rate -- Floor 0.95,
///         Optimal 0.999, Ceiling 1.0. Pass / Fail.
///
/// THE HARD PART OF A FUNNEL IS THE ABANDONMENT, NOT THE PROGRESSION. A
/// completion has a trigger; an abandonment has none -- the user simply stops.
/// These gates check the inference explicitly, and check that the validation
/// rate is computed BEFORE emission rather than after, which is the difference
/// between a number that is always green and one that is true.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/funnel_events.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double validationRate = 0;
  double fallenRate = 1;

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

  group('GEN-04649 :: progression', () {
    gate(
      'GEN-04649-G1',
      'Atomic Step: "...across multi-step SUPPORT TICKET flows." The '
          'multi-step flow this app has is the Step 147 wizard.',
      'The substitution is recorded in the code, and the tracker is built to '
          'the shape the row describes -- numbered steps, a time per step and '
          'a drop-off point -- rather than to tickets, so the first other flow '
          'does not need a rewrite',
      () =>
          HabotFunnelTracker.flowSubstitution.contains('Step 147 wizard') &&
          HabotFunnelTracker.flowSubstitution.contains('rewrite') &&
          HabotFunnelTracker.abandonmentNote.contains('no trigger') &&
          HabotFunnelTracker.validateBeforeEmitNote
              .contains('always green and never true'),
    );

    gate(
      'GEN-04649-G2',
      'GCP alignment: "Step transition timestamp, time-per-step, and step '
          'drop-off rates logged."',
      'A completed step emits a schema-valid event carrying the flow, the '
          'position, the length of the flow and the time spent on the step -- '
          'the last of which the row names explicitly and which a tracker '
          'without a clock cannot produce',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker t = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => now,
        );
        t.start(flowId: 'f1', stepCount: 5, traceId: 'trace-1');
        now = now.add(const Duration(seconds: 4, milliseconds: 100));
        final HabotEvent? e = t.completeStep('f1');
        return e != null &&
            e.kind == HabotEventKind.stepCompleted &&
            HabotEventSchema.matches(e) &&
            e.payload['flow_id'] == 'f1' &&
            e.payload['step_index'] == 0 &&
            e.payload['step_count'] == 5 &&
            e.payload['time_on_step_ms'] == 4100 &&
            e.traceId == 'trace-1' &&
            e.toRow()['event_date'] == '2026-08-24' &&
            t.runs.single.stepIndex == 1;
      },
    );

    gate(
      'GEN-04649-G3',
      '"Without step_count, step 4 of 5 and step 4 of 40 look identical."',
      'Reach and drop-off are computed from the EMITTED events rather than '
          'from in-memory state, so the figures are the ones the warehouse '
          'would produce from the same rows, and a drop-off over nobody '
          'returns null instead of a confident 1.0',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker t = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => now,
        );
        t.start(flowId: 'f1', stepCount: 5, traceId: 'trace-1');
        t.start(flowId: 'f2', stepCount: 5, traceId: 'trace-2');
        for (int i = 0; i < 3; i++) {
          now = now.add(const Duration(seconds: 2));
          t.completeStep('f1');
        }
        for (int i = 0; i < 2; i++) {
          now = now.add(const Duration(seconds: 2));
          t.completeStep('f2');
        }
        final Map<int, int> reached = t.reachedByStep;
        return reached[0] == 2 &&
            reached[1] == 2 &&
            reached[2] == 1 &&
            t.dropOffAfter(0) == 0.0 &&
            t.dropOffAfter(1) == 0.5 &&
            t.dropOffAfter(2) == 1.0 &&
            t.dropOffAfter(4) == null &&
            t.dropOffAfter(9) == null;
      },
    );
  });

  group('GEN-04649 :: the abandonment, which has no trigger', () {
    gate(
      'GEN-04649-G4',
      '"A tracker that only records completions can tell you 300 people '
          'reached step 4 and 120 reached step 5, and cannot tell you whether '
          'the other 180 gave up or are still typing."',
      'The sweep is an explicit inference run at the two moments the app '
          'learns the user has gone: a run still open is recorded as '
          'abandoned, a run that completed is not, and a second sweep records '
          'nothing further -- a user who backgrounds the app three times has '
          'abandoned once',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker t = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => now,
        );
        t.start(flowId: 'finished', stepCount: 2, traceId: 'trace-done');
        t.start(flowId: 'left', stepCount: 5, traceId: 'trace-left');
        now = now.add(const Duration(seconds: 3));
        t.completeStep('finished');
        now = now.add(const Duration(seconds: 3));
        t.completeStep('finished');
        now = now.add(const Duration(seconds: 3));
        t.completeStep('left');

        final List<HabotEvent> first = t.sweepAbandoned();
        final List<HabotEvent> second = t.sweepAbandoned();

        return first.length == 1 &&
            second.isEmpty &&
            first.single.kind == HabotEventKind.flowAbandoned &&
            first.single.payload['flow_id'] == 'left' &&
            first.single.payload['step_index'] == 1 &&
            first.single.traceId == 'trace-left' &&
            HabotEventSchema.matches(first.single) &&
            t.abandonedTotal == 1;
      },
    );

    gate(
      'GEN-04649-G5',
      '"They left at step 4" is a fact nobody can act on. "They left at step 4 '
          'with a validation error on screen" is a bug report.',
      'had_visible_error is set from the navigation outcome rather than '
          'guessed, travels on the abandonment event, and is cleared by a '
          'completed step -- because a step that completed means whatever was '
          'wrong got fixed',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker blocked = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => now,
        );
        blocked.start(flowId: 'f1', stepCount: 5, traceId: 'trace-1');
        blocked.noteVisibleError('f1', visible: true);
        blocked.sweepAbandoned();

        DateTime later = DateTime.utc(2026, 8, 24, 11);
        final HabotFunnelTracker recovered = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => later,
        );
        recovered.start(flowId: 'f2', stepCount: 5, traceId: 'trace-2');
        recovered.noteVisibleError('f2', visible: true);
        later = later.add(const Duration(seconds: 5));
        recovered.completeStep('f2');
        recovered.sweepAbandoned();

        return blocked.abandonedWithVisibleError == 1 &&
            blocked.abandonedTotal == 1 &&
            recovered.abandonedTotal == 1 &&
            recovered.abandonedWithVisibleError == 0;
      },
    );
  });

  group('GEN-04649 :: the metric, measured before emission', () {
    gate(
      'GEN-04649-G6',
      'Metric: Analytics Event Schema Validation Rate -- floor 0.95, optimal '
          '0.999, ceiling 1.0.',
      'Every event the tracker produces on a well-formed run passes the Step '
          '156 schema, so the validation rate is 1.0 with nothing rejected',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker t = HabotFunnelTracker(
          view: 'referral_form',
          clock: () => now,
        );
        t.start(flowId: 'f1', stepCount: 3, traceId: 'trace-1');
        for (int i = 0; i < 2; i++) {
          now = now.add(const Duration(seconds: 2));
          t.completeStep('f1');
        }
        t.sweepAbandoned();
        validationRate = t.schemaValidationRate;
        return t.attempted == 3 &&
            t.emitted.length == 3 &&
            t.rejected.isEmpty &&
            t.emitted.every(HabotEventSchema.matches) &&
            validationRate == 1.0 &&
            validationRate >= HabotFunnelTracker.optimal &&
            validationRate >= HabotFunnelTracker.floor;
      },
    );

    gate(
      'GEN-04649-G7',
      '"Emitting it and letting the warehouse reject it later would leave the '
          'app\'s own validation rate at 100% while the pipeline quietly '
          'dropped rows."',
      'A tracker built without the view the Step 156 envelope requires emits '
          'nothing at all: the events are rejected with the field named, the '
          'rate falls to 0.0 -- below the floor -- and the failure is visible '
          'in the app rather than in a warehouse nobody is watching',
      () {
        DateTime now = DateTime.utc(2026, 8, 24, 10);
        final HabotFunnelTracker broken = HabotFunnelTracker(
          view: '   ',
          clock: () => now,
        );
        broken.start(flowId: 'f1', stepCount: 3, traceId: 'trace-1');
        now = now.add(const Duration(seconds: 2));
        broken.completeStep('f1');
        broken.sweepAbandoned();
        fallenRate = broken.schemaValidationRate;
        return broken.attempted == 2 &&
            broken.emitted.isEmpty &&
            broken.rejected.isNotEmpty &&
            broken.rejected.every(
              (HabotSchemaFinding f) =>
                  f.violation == HabotSchemaViolation.missingEnvelopeField,
            ) &&
            broken.rejected.any((HabotSchemaFinding f) => f.field == 'view') &&
            fallenRate == 0.0 &&
            fallenRate < HabotFunnelTracker.floor &&
            // ...and nothing was counted in the funnel either, so a broken
            // emitter cannot masquerade as a flow nobody used.
            broken.reachedByStep.isEmpty &&
            broken.abandonedTotal == 0;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04649',
        atomicStepReferenceId: 'GEN-04649',
        setupStepAction:
            'Capture funnel progression events across multi-step support '
            'ticket flows.',
        implementationOrder: 160,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFunnelTracker / HabotFunnelRun',
          'Component Properties':
              'Emits stepCompleted and flowAbandoned events against the Step '
              '156 schema; abandonment inferred at background (Step 119) and '
              'session end, idempotent per run; reach and drop-off computed '
              'from emitted events rather than in-memory state',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: the row says "support ticket flows". The '
              'multi-step flow this app has is the Step 147 wizard, which is '
              'the same shape -- numbered steps, a time per step, a drop-off '
              'point. The tracker is built to that shape rather than to '
              'tickets.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Analytics Event Schema Validation Rate',
            observed:
                '${validationRate.toStringAsFixed(3)} over a complete run: '
                'every event validated against the Step 156 schema BEFORE '
                'emission, nothing rejected. On a tracker missing an envelope '
                'field the same figure is '
                '${fallenRate.toStringAsFixed(3)} with every event rejected '
                'and the offending field named, so the rate is a measurement '
                'rather than a constant.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Abandonments inferred rather than missed',
            observed:
                'A run still open at the sweep is recorded as abandoned with '
                'the step it stopped on and whether an error was on screen; a '
                'completed run is not; a second sweep records nothing further. '
                'Without the inference the same data reports only that fewer '
                'people reached step N+1 than step N, with no way to tell '
                'giving up from still typing.',
            floor: '1 abandonment per abandoned run',
            optimal: '1 abandonment per abandoned run',
            ceiling: '1 abandonment per abandoned run',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/funnel_events.dart',
        ],
      ),
    );
  });
}
