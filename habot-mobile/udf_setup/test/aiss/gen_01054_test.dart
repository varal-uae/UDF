/// AISS GATE -- Step 159 of 175
/// Global Reference ID:       GEN-01054
/// Atomic Steps Reference ID: GEN-01054
/// Setup Step (Action) / Atomic Step: "Configure Sentry exception capture
///   filters to capture unhandled runtime errors, network timeouts, and UI
///   breaks."
/// Metric: Crash-Free Session Rate -- Floor 0.99, Optimal 0.999, Ceiling 1.0.
///         Good / Average / Poor.
///
/// THE FILTER IS THE WORK. Two mistakes inflate this metric and both are
/// checked here: counting errors rather than sessions, and counting a handled
/// network timeout as a crash. The row asks for timeouts to be CAPTURED; they
/// are, and they are not fatal.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/telemetry/crash_capture.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';

import 'aiss_reporter.dart';

/// A reporter written here, for the gate. Nothing like it ships -- see G2.
class _RecordingReporter implements HabotCrashReporter {
  final List<HabotCrashReport> received = <HabotCrashReport>[];

  @override
  void report(HabotCrashReport report) => received.add(report);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double sessionRate = 0;
  double errorWeighted = 0;

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

  StackTrace traceFor(String symbol) => StackTrace.fromString(
        '#0      $symbol '
        '(package:udf_setup/design_system/data/outbox.dart:88:12)\n'
        '#1      HabotSyncLoop.tick '
        '(package:udf_setup/design_system/data/sync_loop.dart:142:7)',
      );

  HabotCrashCapture session(String id, {HabotCrashReporter? reporter}) =>
      HabotCrashCapture(
        sessionId: id,
        reporter: reporter,
        clock: () => DateTime.utc(2026, 8, 24, 10),
      );

  HabotCrashReport? capture(
    HabotCrashCapture c, {
    required HabotErrorClass errorClass,
    required String symbol,
    Object? error,
    HabotErrorCategory category = HabotErrorCategory.timeout,
  }) =>
      c.capture(
        error: error ?? StateError('failure in $symbol'),
        trace: traceFor(symbol),
        errorClass: errorClass,
        category: category,
        traceId: 'trace-$symbol',
      );

  group('GEN-01054 :: the filter the row asks for', () {
    gate(
      'GEN-01054-G1',
      'Atomic Step: "...capture unhandled runtime errors, network timeouts, '
          'and UI breaks."',
      'All three named classes are captured, and the one that is NOT a crash '
          'is separated by type rather than by a convention: a network timeout '
          'is captured and is not fatal, while an unhandled error and a UI '
          'break are',
      () {
        final HabotCrashCapture c = session('s1');
        final HabotCrashReport? timeout = capture(
          c,
          errorClass: HabotErrorClass.networkTimeout,
          symbol: 'HabotOutbox.dispatch',
        );
        final HabotCrashReport? unhandled = capture(
          c,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          category: HabotErrorCategory.unknown,
        );
        final HabotCrashReport? ui = capture(
          c,
          errorClass: HabotErrorClass.uiBreak,
          symbol: 'HabotWizard.build',
          category: HabotErrorCategory.unknown,
        );
        return HabotCrashCapture.capturedClasses.length == 3 &&
            HabotErrorClass.values.length == 3 &&
            timeout != null &&
            unhandled != null &&
            ui != null &&
            !timeout.isFatal &&
            unhandled.isFatal &&
            ui.isFatal &&
            !HabotErrorClass.networkTimeout.isFatal &&
            HabotErrorClass.unhandled.isFatal &&
            HabotErrorClass.uiBreak.isFatal &&
            c.captured.length == 3 &&
            c.fatalCount == 2 &&
            !c.sessionIsCrashFree;
      },
    );

    gate(
      'GEN-01054-G2',
      '"A crash reporter is a dependency that receives every unhandled error '
          'in the app, including whatever is attached to it, from every '
          'device." The row names Sentry; no SDK is added.',
      'The destination is an interface with no shipped implementation and no '
          'default, so a capture with no reporter still filters, still counts '
          'and sends nothing -- and anything that wants the reports has to be '
          'written deliberately, as this gate had to write one',
      () {
        final HabotCrashCapture silent = session('s-silent');
        capture(
          silent,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          category: HabotErrorCategory.unknown,
        );
        final _RecordingReporter wired = _RecordingReporter();
        final HabotCrashCapture loud = session('s-loud', reporter: wired);
        capture(
          loud,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          category: HabotErrorCategory.unknown,
        );
        return silent.captured.length == 1 &&
            wired.received.length == 1 &&
            wired.received.single.sessionId == 's-loud' &&
            HabotCrashCapture.noSdkNote.contains('compile-time obstacle') &&
            HabotCrashCapture.noSdkNote.contains('Step 114');
      },
    );

    gate(
      'GEN-01054-G3',
      '"A report carries the error TYPE, the frame signature, the category '
          'and the trace id -- never the message."',
      'A report built from an exception whose message names a person carries '
          'neither the name nor a message field at all, and the frames it does '
          'carry have every file location stripped',
      () {
        final HabotCrashCapture c = session('s3');
        final HabotCrashReport r = capture(
          c,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          error: StateError('no referral found for Amara Okafor'),
          category: HabotErrorCategory.notFound,
        )!;
        final Map<String, Object?> row = r.toRow();
        final String flattened = row.values.join(' ');
        return !row.containsKey('message') &&
            !flattened.contains('Amara') &&
            !flattened.contains('.dart') &&
            !flattened.contains('package:') &&
            r.errorType == 'StateError' &&
            r.frameSignature.first == 'HabotFormGate.submit' &&
            row['fatal'] == true &&
            row['trace_id'] == 'trace-HabotFormGate.submit';
      },
    );

    gate(
      'GEN-01054-G4',
      '"One defect firing in a loop is one defect. Reporting it forty times '
          'costs the user\'s battery and tells nobody anything new."',
      'A second occurrence of the same fingerprint in one session is dropped '
          'and the drop is counted with its reason, while the same defect in a '
          'different session is captured again -- because the dedupe is per '
          'session, not global',
      () {
        final HabotCrashCapture c = session('s4');
        final HabotCrashReport? first = capture(
          c,
          errorClass: HabotErrorClass.uiBreak,
          symbol: 'HabotWizard.build',
          category: HabotErrorCategory.unknown,
        );
        final HabotCrashReport? second = capture(
          c,
          errorClass: HabotErrorClass.uiBreak,
          symbol: 'HabotWizard.build',
          category: HabotErrorCategory.unknown,
        );
        final HabotCrashCapture other = session('s4b');
        final HabotCrashReport? elsewhere = capture(
          other,
          errorClass: HabotErrorClass.uiBreak,
          symbol: 'HabotWizard.build',
          category: HabotErrorCategory.unknown,
        );
        return first != null &&
            second == null &&
            elsewhere != null &&
            c.captured.length == 1 &&
            c.dropped[HabotDropReason.duplicateInSession] == 1 &&
            elsewhere.fingerprint == first.fingerprint;
      },
    );

    gate(
      'GEN-01054-G5',
      '"Refusing to send is the right failure: a report that leaks is worse '
          'than a report that is missing."',
      'A report whose own fields would carry something the Step 157 sanitiser '
          'flags -- a session id somebody derived from an email address -- is '
          'refused rather than sent, and the refusal is counted with its '
          'reason',
      () {
        final HabotCrashCapture leaky = HabotCrashCapture(
          sessionId: 'sess-worker@example.com',
          clock: () => DateTime.utc(2026, 8, 24, 10),
        );
        final HabotCrashReport? r = capture(
          leaky,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          category: HabotErrorCategory.unknown,
        );
        return r == null &&
            leaky.captured.isEmpty &&
            leaky.dropped[HabotDropReason.failedSanitisation] == 1 &&
            leaky.sessionIsCrashFree;
      },
    );
  });

  group('GEN-01054 :: the rate, counted the way the row means it', () {
    gate(
      'GEN-01054-G6',
      'Metric: Crash-Free Session Rate. "One session that throws forty times '
          'is one unhappy user, not forty data points."',
      'A session carrying three captured network timeouts and no fatal error '
          'is crash-free, so the session rate stays at 1.0 while the '
          'error-weighted reading of the same data reports 0.25 -- the '
          'difference between the two is demonstrated rather than asserted',
      () {
        final HabotCrashCapture noisy = session('s6a');
        for (final String symbol in <String>[
          'HabotOutbox.dispatch',
          'HabotSyncLoop.tick',
          'HabotHeartbeat.ping',
        ]) {
          capture(
            noisy,
            errorClass: HabotErrorClass.networkTimeout,
            symbol: symbol,
          );
        }
        final List<HabotCrashCapture> sessions = <HabotCrashCapture>[
          noisy,
          session('s6b'),
          session('s6c'),
          session('s6d'),
        ];
        sessionRate = HabotCrashCapture.crashFreeSessionRate(sessions);
        errorWeighted = HabotCrashCapture.errorWeightedRate(sessions);
        return noisy.captured.length == 3 &&
            noisy.fatalCount == 0 &&
            noisy.sessionIsCrashFree &&
            sessionRate == 1.0 &&
            sessionRate >= HabotCrashCapture.optimal &&
            errorWeighted == 0.25 &&
            errorWeighted < HabotCrashCapture.floor &&
            HabotCrashCapture.sessionsNotErrorsNote.contains('forty times') &&
            HabotCrashCapture.timeoutNotFatalNote
                .contains('connectivity metric');
      },
    );

    gate(
      'GEN-01054-G7',
      'Floor 0.99, optimal 0.999, ceiling 1.0. A rate that cannot fall is not '
          'a measurement.',
      'One fatal error in two hundred sessions takes the rate to 0.995 -- '
          'above the floor, below the optimal, and banded Average -- and four '
          'fatal sessions in two hundred takes it below the floor and bands '
          'Poor',
      () {
        List<HabotCrashCapture> fleet(int fatalSessions) {
          final List<HabotCrashCapture> out = <HabotCrashCapture>[];
          for (int i = 0; i < 200; i++) {
            final HabotCrashCapture c = session('fleet-$i');
            if (i < fatalSessions) {
              capture(
                c,
                errorClass: HabotErrorClass.uiBreak,
                symbol: 'HabotWizard.build',
                category: HabotErrorCategory.unknown,
              );
            }
            out.add(c);
          }
          return out;
        }

        final double one = HabotCrashCapture.crashFreeSessionRate(fleet(1));
        final double four = HabotCrashCapture.crashFreeSessionRate(fleet(4));
        return one == 0.995 &&
            one >= HabotCrashCapture.floor &&
            one < HabotCrashCapture.optimal &&
            HabotCrashCapture.bandFor(one) == 'Average' &&
            four == 0.98 &&
            four < HabotCrashCapture.floor &&
            HabotCrashCapture.bandFor(four) == 'Poor' &&
            HabotCrashCapture.bandFor(1.0) == 'Good' &&
            HabotCrashCapture.ceiling == 1.0;
      },
    );

    gate(
      'GEN-01054-G8',
      'GCP alignment: "All step execution events stream to BigQuery '
          'partitioned by event_date, clustered by trace_id."',
      'A captured report emits a Step 156 event that passes the schema, so a '
          'crash can be joined on its trace id to the funnel step the user was '
          'on rather than sitting in a separate system',
      () {
        final HabotCrashCapture c = session('s8');
        final HabotCrashReport r = capture(
          c,
          errorClass: HabotErrorClass.unhandled,
          symbol: 'HabotFormGate.submit',
          category: HabotErrorCategory.unknown,
        )!;
        final HabotEvent e = r.toEvent(
          view: 'referral_form',
          sessionOrdinal: 7,
        );
        return HabotEventSchema.matches(e) &&
            e.kind == HabotEventKind.errorCaptured &&
            e.traceId == r.traceId &&
            e.payload['fatal'] == true &&
            e.payload['fingerprint'] == r.fingerprint &&
            e.toRow()['event_date'] == '2026-08-24';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01054',
        atomicStepReferenceId: 'GEN-01054',
        setupStepAction:
            'Configure Sentry exception capture filters to capture unhandled '
            'runtime errors, network timeouts, and UI breaks.',
        implementationOrder: 159,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCrashCapture / HabotCrashReport',
          'Component Properties':
              '${HabotErrorClass.values.length} captured error classes '
              '(networkTimeout captured and NOT fatal); '
              '${HabotDropReason.values.length} declared drop reasons; reports '
              'carry error type, fingerprint, frame signature, category and '
              'trace id, and no message',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: the row names Sentry. No SDK is added -- '
              'a crash reporter receives every unhandled error from every '
              'device, and wiring one up before deciding what may be attached '
              'is how a product ships worker addresses to a third party. '
              'HabotCrashReporter is an interface with no default, so the '
              'absence is a compile-time obstacle rather than an oversight.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Crash-Free Session Rate',
            observed:
                '${sessionRate.toStringAsFixed(3)} over four sessions, one of '
                'which captured three network timeouts. The error-weighted '
                'reading of the identical data is '
                '${errorWeighted.toStringAsFixed(3)}, which would report a '
                'connectivity problem as a stability collapse. The session '
                'reading falls to 0.995 on one fatal session in two hundred '
                'and to 0.980 on four, so it is a measurement rather than a '
                'constant.',
            floor: '0.99',
            optimal: '0.999',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Reports refused rather than sent',
            observed:
                'A report whose session id had been derived from an email '
                'address is dropped with reason failedSanitisation and never '
                'reaches a reporter. A report that leaks is worse than a '
                'report that is missing, so the refusal is the correct '
                'failure and is counted rather than silent.',
            floor: '0 leaked reports',
            optimal: '0 leaked reports',
            ceiling: '0 leaked reports',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/crash_capture.dart',
        ],
      ),
    );
  });
}
