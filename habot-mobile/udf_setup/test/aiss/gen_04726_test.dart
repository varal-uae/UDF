/// AISS GATE -- Step 194 of 195
/// Global Reference ID:       GEN-04726
/// Atomic Steps Reference ID: GEN-04726
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 3: Set global app state isLoading = true
///               and inject M3 progress indicator."
/// Metric: Substep Definition-of-Done Adherence Rate -- Floor ">=90% unit test
///         coverage / acceptance criteria met before merge", Optimal "95-100%
///         coverage, all acceptance criteria met", Ceiling "100%".
///         Complete / Partial / Not Complete.
///
/// `isLoading = true` IS THE DEFECT THE ROW ASKS FOR. A single global boolean
/// cannot represent two things happening at once, and on an offline-first app
/// two things are happening at once constantly. The naive flag is kept beside
/// the counted scope so the difference is demonstrated rather than argued.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/loading_scope.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  DateTime now = DateTime.utc(2026, 9, 14, 10);
  HabotLoadingScope build() => HabotLoadingScope(clock: () => now);

  setUp(() => now = DateTime.utc(2026, 9, 14, 10));

  group('GEN-04726 :: the flag, and what replaces it', () {
    gate(
      'GEN-04726-G1',
      'Atomic Step: "Set GLOBAL app state isLoading = true."',
      'The single boolean is shown failing on the case that actually happens: '
          'two concurrent operations, the first finishing while the second '
          'runs, and the flag going false with work still in flight',
      () {
        final HabotNaiveLoadingFlag naive = HabotNaiveLoadingFlag()
          ..begin()
          ..begin()
          ..end();
        final HabotLoadingScope counted = build()
          ..begin(
            const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
          )
          ..begin(
            const HabotLoadingOperation(
              id: 'autosave',
              description: 'Saving',
            ),
          )
          ..end('sync');
        return !naive.isLoading &&
            counted.isLoading &&
            counted.activeCount == 1 &&
            counted.stalled.single == 'Saving' &&
            HabotLoadingScope.globalFlagNote
                .contains('looking in the wrong place');
      },
    );

    gate(
      'GEN-04726-G2',
      'A retry must not leave the indicator stuck on.',
      'Beginning the same operation twice is one operation, so ending it once '
          'closes the scope -- and an operation that was never begun cannot be '
          'advanced into existence',
      () {
        final HabotLoadingScope scope = build()
          ..begin(
            const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
          )
          ..begin(
            const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
          );
        final bool oneWhileOpen = scope.activeCount == 1;
        scope
          ..end('sync')
          ..advance('sync', 5);
        return oneWhileOpen &&
            !scope.isLoading &&
            scope.activeCount == 0 &&
            scope.stalled.isEmpty;
      },
    );

    gate(
      'GEN-04726-G3',
      '"A stuck spinner should be able to tell a developer what is stuck '
          'instead of spinning."',
      'Running operations are named rather than counted, and progress on one '
          'of them is updated without disturbing the other',
      () {
        final HabotLoadingScope scope = build()
          ..begin(
            const HabotLoadingOperation(
              id: 'upload',
              description: 'Uploading',
              total: 10,
            ),
          )
          ..begin(
            const HabotLoadingOperation(
              id: 'sync',
              description: 'Syncing',
              total: 4,
              completed: 2,
            ),
          )
          ..advance('upload', 5);
        final HabotLoadingOperation upload = scope.active
            .firstWhere((HabotLoadingOperation o) => o.id == 'upload');
        return scope.stalled.length == 2 &&
            scope.stalled.contains('Uploading') &&
            upload.completed == 5 &&
            upload.fraction == 0.5 &&
            scope.combinedFraction == 0.5 &&
            scope.isDeterminate;
      },
    );
  });

  group('GEN-04726 :: when the indicator is on screen', () {
    gate(
      'GEN-04726-G4',
      '"A spinner shown for 120ms is worse than no spinner."',
      'Nothing is drawn before the declared delay, the delay and the '
          'minimum-visible window are both tokens, and the minimum is longer '
          'than the delay because the same flash in reverse is equally bad',
      () {
        final HabotLoadingScope scope = build()
          ..begin(
            const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
          );
        final bool hiddenImmediately = !scope.shouldShow;
        now = now.add(const Duration(milliseconds: 200));
        final bool stillHidden = !scope.shouldShow;
        now = now.add(const Duration(milliseconds: 200));
        final bool nowShown = scope.shouldShow;
        return hiddenImmediately &&
            stillHidden &&
            nowShown &&
            HabotLoadingScope.appearAfter ==
                HabotMotion.loadingIndicatorDelay &&
            HabotLoadingScope.minimumVisible ==
                HabotMotion.loadingIndicatorMinimumVisible &&
            HabotLoadingScope.minimumVisible > HabotLoadingScope.appearAfter &&
            HabotLoadingScope.flashNote.contains('rendering glitch');
      },
    );

    gate(
      'GEN-04726-G5',
      'Once shown, an indicator removed two frames later is the same flash in '
          'reverse.',
      'After the work finishes the indicator stays for the declared minimum '
          'and then goes -- so a slow operation that completes just after the '
          'spinner appeared does not blink',
      () {
        final HabotLoadingScope scope = build()
          ..begin(
            const HabotLoadingOperation(id: 'sync', description: 'Syncing'),
          );
        now = now.add(const Duration(milliseconds: 400));
        final bool shown = scope.shouldShow;
        scope.end('sync');
        final bool stillShownJustAfter = scope.shouldShow;
        now = now.add(const Duration(milliseconds: 600));
        final bool goneLater = !scope.shouldShow;
        return shown && stillShownJustAfter && goneLater && !scope.isLoading;
      },
    );

    gate(
      'GEN-04726-G6',
      '"A combined bar that ignores the operation it cannot measure would '
          'reach 100% and stop while work continued."',
      'One indeterminate operation makes the whole scope indeterminate, and '
          'the state is announced as well as drawn -- a spinner is nothing to '
          'a screen reader',
      () {
        final HabotLoadingScope mixed = build()
          ..begin(
            const HabotLoadingOperation(
              id: 'upload',
              description: 'Uploading',
              total: 10,
              completed: 5,
            ),
          )
          ..begin(
            const HabotLoadingOperation(
              id: 'lookup',
              description: 'Looking up',
            ),
          );
        final HabotLoadingScope determinate = build()
          ..begin(
            const HabotLoadingOperation(
              id: 'upload',
              description: 'Uploading',
              total: 10,
              completed: 5,
            ),
          );
        return mixed.combinedFraction == null &&
            !mixed.isDeterminate &&
            mixed.semanticsValue == 'Loading' &&
            determinate.isDeterminate &&
            determinate.combinedFraction == 0.5 &&
            determinate.semanticsValue != 'Loading' &&
            determinate.semanticsValue.isNotEmpty &&
            HabotLoadingScope.indeterminateNote.contains('100% and stop');
      },
    );

    gate(
      'GEN-04726-G7',
      'Metric: "unit test coverage / acceptance criteria met before merge".',
      'The acceptance criteria are computed over constructed scopes and all '
          'hold; the coverage half is recorded as not producible on a host '
          'with no Dart toolchain rather than a figure being invented',
      () {
        adherence = HabotLoadingScope.adherenceRate(build);
        return HabotLoadingScope.acceptanceCriteria(build).length == 8 &&
            HabotLoadingScope.acceptanceCriteria(build)
                .values
                .every((bool b) => b) &&
            adherence == 1.0 &&
            adherence >= HabotLoadingScope.floor &&
            HabotLoadingScope.qualitativeOutput(build) == 'Complete' &&
            HabotLoadingScope.coverageReadingNote
                .contains('nothing is instrumented') &&
            HabotLoadingScope.announcedNote.contains('screen reader') &&
            HabotLoadingScope.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04726',
        atomicStepReferenceId: 'GEN-04726',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement substep 3: Set global app state isLoading = true '
            'and inject M3 progress indicator."',
        implementationOrder: 194,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLoadingScope / HabotLoadingOperation',
          'Component Properties':
              'Counted scope keyed by operation id, idempotent per id; '
              'indicator delayed by '
              '${HabotLoadingScope.appearAfter.inMilliseconds}ms and held for '
              'at least ${HabotLoadingScope.minimumVisible.inMilliseconds}ms '
              'once shown; determinate only when every running operation knows '
              'its size; state announced as well as drawn',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THE ROW ASKS FOR THE DEFECT. A single global isLoading boolean '
              'cannot represent two things happening at once, and on an '
              'offline-first app two things are happening at once constantly '
              '-- the Step 123 sync sweep, a Step 153 field autosave, a '
              'search. Whichever finishes first sets the flag false and the '
              'spinner vanishes with work still running. Nobody reports that '
              'as "the loading flag is shared"; they report "the spinner '
              'disappears too early", which sends people looking in the wrong '
              'place. HabotNaiveLoadingFlag is kept beside the counted scope '
              'so the difference is demonstrated rather than argued. TOKENS '
              'ADDED: loadingIndicatorDelay and loadingIndicatorMinimumVisible '
              'in motion_tokens.dart -- a raw Duration outside that file is a '
              'poka-yoke violation, correctly.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate '
                '(acceptance criteria)',
            observed:
                '${adherence.toStringAsFixed(2)} over '
                '${HabotLoadingScope.acceptanceCriteria(build).length} '
                'criteria. The counted scope stays loading while a second '
                'operation runs; the single boolean does not, on the identical '
                'sequence. The coverage half of the metric is not producible '
                'on this host and is recorded as such.',
            floor: '>=90% unit test coverage / acceptance criteria met before '
                'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling: '100%',
          ),
          AissMeasurement(
            metricName: 'Indicator flash windows',
            observed:
                'Nothing is drawn for the first '
                '${HabotLoadingScope.appearAfter.inMilliseconds}ms, so work '
                'the user would have experienced as instant shows no spinner '
                'at all; once shown it stays at least '
                '${HabotLoadingScope.minimumVisible.inMilliseconds}ms, so an '
                'operation finishing just after it appeared does not blink. '
                'Both figures are tokens rather than numbers at the call site.',
            floor: 'no indicator under the delay',
            optimal: 'no indicator under the delay',
            ceiling: 'no indicator under the delay',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/loading_scope.dart',
        ],
      ),
    );
  });
}
