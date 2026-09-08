/// AISS GATE -- Step 153 of 155
/// Global Reference ID:       GEN-02588
/// Atomic Steps Reference ID: GEN-02588
/// Setup Step (Action) / Atomic Step: "Configure the forms to auto-save
///   granularly per field, preventing complete data loss if the user drops off
///   (Self-Chasing)."
/// Metric: API Response Latency (ms) -- Floor 0.0, Optimal 100-300,
///         Ceiling 500.0. Good / Average / Poor.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/forms/field_autosave.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int lost = -1;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late Map<String, String> localWrites;

  HabotFieldAutosave autosave({Set<String> failing = const <String>{}}) =>
      HabotFieldAutosave(
        outbox: outbox,
        formId: 'referral-1',
        writeLocal: (String field, String value) async {
          if (failing.contains(field)) {
            throw StateError('disk full');
          }
          localWrites[field] = value;
        },
      );

  setUp(() {
    store = HabotMemoryStore();
    outbox = HabotOutbox(store: store);
    localWrites = <String, String>{};
  });

  group('GEN-02588 :: what survives a drop-off', () {
    gate(
      'GEN-02588-G1',
      'An autosave that posts each field and keeps nothing locally loses '
          'everything the moment the network does -- which is the same moment '
          'a user is most likely to give up and close the app.',
      'A field is written LOCALLY first and queued second, so the value is '
          'durable before any request exists, and both halves are recorded on '
          'the outcome',
      () async {
        final HabotFieldAutosave a = autosave()..hold('childName', 'Amara');
        final HabotSaveOutcome out =
            await a.save('childName', trigger: HabotSaveTrigger.blur);
        return out.persistedLocally &&
            out.queued &&
            out.isSaved &&
            out.error == null &&
            localWrites['childName'] == 'Amara' &&
            (await outbox.pendingCount) == 1 &&
            HabotFieldAutosave.localFirstNote.contains(
              'before any request exists',
            );
      },
    );

    gate(
      'GEN-02588-G2',
      'THE FAILURE MODE AUTOSAVE USUALLY HAS: the write fails, the UI clears '
          'its dirty flag anyway, and the answer exists nowhere.',
      'A failed save leaves the value in the draft and the field marked '
          'unsaved, carries the error, and does NOT queue anything -- so '
          '"saved" is a fact rather than an assumption',
      () async {
        final HabotFieldAutosave a =
            autosave(failing: <String>{'notes'})
              ..hold('childName', 'Amara')
              ..hold('notes', 'needs a hearing assessment');
        await a.save('childName', trigger: HabotSaveTrigger.blur);
        final HabotSaveOutcome bad =
            await a.save('notes', trigger: HabotSaveTrigger.blur);
        lost = a.fieldsLost;
        return !bad.persistedLocally &&
            !bad.queued &&
            bad.error is StateError &&
            a.unsavedFields.single == 'notes' &&
            a.draft['notes'] == 'needs a hearing assessment' &&
            a.restore()['notes'] == 'needs a hearing assessment' &&
            (await outbox.pendingCount) == 1;
      },
    );

    gate(
      'GEN-02588-G3',
      '"Self-Chasing": the point of saving per field is that a user who drops '
          'off gets their answers back.',
      'Everything held is returned by restore, including a field whose save '
          'failed, so the form reopens with the work still in it',
      () async {
        final HabotFieldAutosave a = autosave()
          ..hold('childName', 'Amara')
          ..hold('dateOfBirth', '2018-04-11');
        await a.saveStep(<String>['childName', 'dateOfBirth']);
        final Map<String, String> restored = a.restore();
        return restored.length == 2 &&
            restored['childName'] == 'Amara' &&
            restored['dateOfBirth'] == '2018-04-11' &&
            a.unsavedFields.isEmpty &&
            a.outcomes.every(
              (HabotSaveOutcome o) =>
                  o.trigger == HabotSaveTrigger.stepAdvance,
            ) &&
            (await outbox.pendingCount) == 2;
      },
    );
  });

  group('GEN-02588 :: granular means per field', () {
    gate(
      'GEN-02588-G4',
      'The Step 117 outbox keeps the FIRST entry for a given id -- right for '
          'an idempotent mutation, wrong for a field whose latest value is the '
          'true one. A user correcting a typo would have their first attempt '
          'delivered and the correction dropped.',
      'Each save of a field carries its own revision and names the entry it '
          'supersedes, so the latest value wins by a number rather than by '
          'arrival order',
      () async {
        final HabotFieldAutosave a = autosave()..hold('childName', 'Amra');
        await a.save('childName', trigger: HabotSaveTrigger.typingPause);
        a.hold('childName', 'Amara');
        await a.save('childName', trigger: HabotSaveTrigger.blur);
        final List<HabotOutboxEntry> queued = await outbox.pending();
        final HabotOutboxEntry second = queued.firstWhere(
          (HabotOutboxEntry e) => e.payload['field_revision'] == 2,
        );
        final HabotOutboxEntry first = queued.firstWhere(
          (HabotOutboxEntry e) => e.payload['field_revision'] == 1,
        );
        return queued.length == 2 &&
            a.revisionOf('childName') == 2 &&
            second.id == a.queueIdFor('childName', 2) &&
            second.payload['value'] == 'Amara' &&
            second.payload['supersedes'] == a.queueIdFor('childName', 1) &&
            first.payload['value'] == 'Amra' &&
            first.payload['supersedes'] == null &&
            HabotFieldAutosave.revisionNote.contains(
              'the correction dropped',
            );
      },
    );

    gate(
      'GEN-02588-G5',
      'Saving on every keystroke would put a hundred writes behind one answer; '
          'saving only on submit is not autosave.',
      'A field is saved when it settles, the three triggers are declared, and '
          'the typing pause reuses the Step 33 debounce rather than declaring '
          'a second idea of "typing has stopped"',
      () async =>
          HabotSaveTrigger.values.length == 3 &&
          HabotFieldAutosave.typingPause == HabotMotion.searchDebounce &&
          HabotFieldAutosave.typingPause ==
              const Duration(milliseconds: 300) &&
          HabotFieldAutosave.outboxKind == 'form_field_autosave',
    );

    gate(
      'GEN-02588-G6',
      'Metric: Floor 0.0, Optimal 100-300ms, Ceiling 500ms. Read as at Step '
          '147: splitting a form turns one write into N, and this is the '
          'budget for one of them.',
      'The bands come from tokens rather than literals, every save is inside '
          'the ceiling, and the band is reported for the SLOWEST save rather '
          'than the mean -- a mean hides the one step that made someone wait',
      () async {
        final HabotFieldAutosave a = autosave()
          ..hold('childName', 'Amara')
          ..hold('dateOfBirth', '2018-04-11');
        await a.saveStep(<String>['childName', 'dateOfBirth']);
        return HabotFieldAutosave.optimalMin ==
                HabotMotion.formStepCommitOptimalMin &&
            HabotFieldAutosave.ceiling ==
                HabotMotion.formStepCommitCeiling &&
            a.withinCeilingRate == 1.0 &&
            a.slowestSave <= HabotFieldAutosave.ceiling &&
            a.band == 'Good' &&
            a.fieldsLost == 0;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02588',
        atomicStepReferenceId: 'GEN-02588',
        setupStepAction:
            'Configure the forms to auto-save granularly per field, preventing '
            'complete data loss if the user drops off (Self-Chasing).',
        implementationOrder: 153,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFieldAutosave',
          'Component Properties':
              '${HabotSaveTrigger.values.length} save triggers (blur, step '
              'advance, typing pause at '
              '${HabotMotion.searchDebounce.inMilliseconds}ms); local write '
              'first, queue second; per-field revisions with a supersedes link',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The Step 117 outbox first-wins dedupe is '
              'deliberately not relied on here; the reason is in '
              'HabotFieldAutosave.revisionNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'API Response Latency (ms), per field save',
            observed:
                'Every save inside the '
                '${HabotMotion.formStepCommitCeiling.inMilliseconds}ms ceiling '
                'against an in-memory store, reported for the slowest save '
                'rather than the mean because a mean hides the one step that '
                'made someone wait. A production figure needs a real backend; '
                'what is gated here is the budget and the band logic.',
            floor: '0.0',
            optimal: '100-300',
            ceiling: '500.0',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Fields lost when a save fails',
            observed:
                '0 values lost. A failed write leaves the value in the draft '
                'and the field named in unsavedFields -- $lost of them in the '
                'failure case -- rather than clearing a dirty flag and leaving '
                'the answer nowhere. That is the failure mode autosave usually '
                'has, and it is the one this row exists to prevent.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/field_autosave.dart',
        ],
      ),
    );
  });
}
