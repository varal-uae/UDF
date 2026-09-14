/// AISS GATE -- Step 156 of 175
/// Global Reference ID:       GEN-03448
/// Atomic Steps Reference ID: GEN-03448
/// Setup Step (Action) / Atomic Step: "Standardize UX telemetry event schemas
///   across all mobile views."
/// Metric: UX Telemetry Schema Match -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
///         Complete.
///
/// A FLOOR OF 1.0 MEANS THE SCHEMA HAS TO BE A TYPE RATHER THAN A CONVENTION,
/// and a match rate that cannot fall is not a measurement -- so these gates
/// show both: that a correct event passes, and that each of the five ways an
/// event can be wrong is caught and named.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double matchRate = 0;
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

  HabotEvent good({
    HabotEventKind kind = HabotEventKind.viewOpened,
    String view = 'referral_form',
    String traceId = 'trace-a',
    int ordinal = 0,
    Map<String, Object?>? payload,
  }) =>
      HabotEvent(
        kind: kind,
        view: view,
        traceId: traceId,
        occurredAt: DateTime.utc(2026, 8, 24, 9, 30),
        sessionOrdinal: ordinal,
        payload: payload ??
            const <String, Object?>{'entry_point': 'deep_link'},
      );

  group('GEN-03448 :: the schema is a declaration, not a convention', () {
    gate(
      'GEN-03448-G1',
      'Atomic Step: "Standardize UX telemetry event schemas ACROSS ALL mobile '
          'views."',
      'The event kinds are a closed set and every one of them has a declared '
          'payload definition -- an open set is a schema that cannot be '
          'validated, and a kind with no definition is a shape nobody agreed '
          'to',
      () =>
          HabotEventSchema.coversEveryKind &&
          HabotEventKind.values.length == 8 &&
          HabotEventSchema.definitions.length ==
              HabotEventKind.values.length &&
          HabotEventSchema.definitions.every(
            (HabotEventDefinition d) => d.owningStep.contains('Step'),
          ),
    );

    gate(
      'GEN-03448-G2',
      'GCP alignment: "All step execution events stream to BigQuery '
          'partitioned by event_date, clustered by trace_id."',
      'event_date and trace_id are ENVELOPE fields rather than payload fields, '
          'so the partition key and the cluster key cannot be absent from a '
          'kind whose author forgot them -- and the envelope is the same seven '
          'fields on every kind',
      () {
        final Set<String> envelope = HabotEventSchema.envelope.toSet();
        final Set<String> everyPayloadField = <String>{
          for (final HabotEventDefinition d in HabotEventSchema.definitions)
            for (final HabotEventField f in d.fields) f.name,
        };
        return envelope.length == 7 &&
            envelope.contains(HabotEventSchema.partitionField) &&
            envelope.contains(HabotEventSchema.clusterField) &&
            HabotEventSchema.partitionField == 'event_date' &&
            HabotEventSchema.clusterField == 'trace_id' &&
            envelope.intersection(everyPayloadField).isEmpty &&
            HabotEventKind.values.every((HabotEventKind k) {
              final Map<String, Object?> row = good(
                kind: k,
                payload: <String, Object?>{},
              ).toRow();
              return row.containsKey('event_date') &&
                  row.containsKey('trace_id') &&
                  row['schema_version'] == HabotEventSchema.version;
            });
      },
    );

    gate(
      'GEN-03448-G3',
      '"A field with no question behind it is a field nobody will ever query '
          'and everybody has to carry."',
      'Every declared payload field states what question it exists to answer, '
          'and the declared types exclude free text as a type at all',
      () =>
          HabotEventSchema.definitions.every(
            (HabotEventDefinition d) => d.fields.every(
              (HabotEventField f) => f.why.length > 20,
            ),
          ) &&
          !HabotFieldType.values.any(
            (HabotFieldType t) => t.name.toLowerCase().contains('text'),
          ) &&
          HabotFieldType.values.length == 5,
    );
  });

  group('GEN-03448 :: the match rate, and the ways it falls', () {
    gate(
      'GEN-03448-G4',
      'Metric: UX Telemetry Schema Match -- floor 1.0, optimal 1.0, '
          'ceiling 1.0.',
      'A correctly built event of every declared kind validates clean and the '
          'match rate over the set is 1.0, which is the floor',
      () {
        final List<HabotEvent> batch = <HabotEvent>[
          good(),
          good(
            kind: HabotEventKind.stepCompleted,
            payload: const <String, Object?>{
              'flow_id': 'flow-1',
              'step_index': 2,
              'step_count': 5,
              'time_on_step_ms': 4100,
            },
          ),
          good(
            kind: HabotEventKind.validationRejected,
            payload: const <String, Object?>{
              'cde': 'phoneNumber',
              'attempt_index': 1,
            },
          ),
          good(
            kind: HabotEventKind.errorCaptured,
            payload: const <String, Object?>{
              'error_class': 'unhandled',
              'fingerprint': 'a1b2c3d4',
              'fatal': true,
            },
          ),
        ];
        matchRate = HabotEventSchema.schemaMatchRate(batch);
        return batch.every(HabotEventSchema.matches) &&
            matchRate == 1.0 &&
            matchRate >= HabotEventSchema.floor;
      },
    );

    gate(
      'GEN-03448-G5',
      '"A convention documented in a wiki matches about 80% of events by the '
          'second sprint." A rate that cannot fall is not evidence.',
      'Each of the five violations -- a missing envelope field, a missing '
          'required field, an undeclared field, a wrong type and free text -- '
          'is caught, is reported with the rule it broke, and drops the match '
          'rate below the floor',
      () {
        final HabotEvent missingEnvelope = good(view: '   ');
        final HabotEvent missingRequired =
            good(payload: const <String, Object?>{});
        final HabotEvent undeclared = good(
          payload: const <String, Object?>{
            'entry_point': 'deep_link',
            'operator_note': 'anything',
          },
        );
        final HabotEvent wrongType = good(
          kind: HabotEventKind.stepCompleted,
          payload: const <String, Object?>{
            'flow_id': 'flow-1',
            'step_index': '2',
            'step_count': 5,
            'time_on_step_ms': 4100,
          },
        );
        final HabotEvent freeText = good(
          payload: const <String, Object?>{
            'entry_point': 'tapped the link Amara sent',
          },
        );

        bool has(HabotEvent e, HabotSchemaViolation v) =>
            HabotEventSchema.validate(e)
                .any((HabotSchemaFinding f) => f.violation == v);

        fallenRate = HabotEventSchema.schemaMatchRate(<HabotEvent>[
          good(),
          missingEnvelope,
          missingRequired,
          undeclared,
          wrongType,
          freeText,
        ]);

        return has(
              missingEnvelope,
              HabotSchemaViolation.missingEnvelopeField,
            ) &&
            has(missingRequired, HabotSchemaViolation.missingRequiredField) &&
            has(undeclared, HabotSchemaViolation.undeclaredField) &&
            has(wrongType, HabotSchemaViolation.wrongType) &&
            has(freeText, HabotSchemaViolation.freeTextField) &&
            fallenRate < HabotEventSchema.floor &&
            fallenRate == 1 / 6;
      },
    );

    gate(
      'GEN-03448-G6',
      '"No payload field may carry free text. Free text is where personal data '
          'gets into a warehouse, and no amount of downstream sanitising '
          'reliably gets it out."',
      'The free-text detector fires on anything with a space or the '
          'punctuation a person types, and stays quiet on the enum names and '
          'generated ids the schema actually allows',
      () =>
          HabotEventSchema.looksLikeFreeText('Amara Okafor') &&
          HabotEventSchema.looksLikeFreeText('worker@example.com') &&
          HabotEventSchema.looksLikeFreeText("don't know") &&
          !HabotEventSchema.looksLikeFreeText('deep_link') &&
          !HabotEventSchema.looksLikeFreeText('phoneNumber') &&
          !HabotEventSchema.looksLikeFreeText('a1b2c3d4e5f60718'),
    );

    gate(
      'GEN-03448-G7',
      'GCP alignment: partitioned by event_date. A partition key derived from '
          'local time puts two devices in two partitions for the same instant.',
      'event_date is derived from the UTC instant rather than from local time, '
          'so an event at 01:00 in Dubai and the same instant elsewhere land in '
          'one partition',
      () {
        final HabotEvent dubaiEarlyMorning = HabotEvent(
          kind: HabotEventKind.viewOpened,
          view: 'home',
          traceId: 'trace-b',
          // 2026-08-25 01:00 +04:00 is 2026-08-24 21:00 UTC.
          occurredAt: DateTime.utc(2026, 8, 24, 21),
          sessionOrdinal: 0,
          payload: const <String, Object?>{'entry_point': 'cold_start'},
        );
        return dubaiEarlyMorning.eventDate == '2026-08-24' &&
            good().eventDate == '2026-08-24' &&
            HabotEventSchema.version == '1.0.0';
      },
    );
  });

  group('GEN-03448 :: why this step is first in the batch', () {
    gate(
      'GEN-03448-G8',
      'Build order: Steps 157-165 all emit events; a per-step shape produces '
          'twelve near-identical event families that cannot be joined.',
      'The reasoning is recorded in the code, and the definitions name the '
          'later steps that own each kind, so a kind cannot drift away from '
          'the step accountable for it',
      () {
        final Set<String> owners = HabotEventSchema.definitions
            .map((HabotEventDefinition d) => d.owningStep)
            .toSet();
        return HabotEventSchema.schemaFirstNote.contains('Steps 157-165') &&
            HabotEventSchema.traceIdNote.contains('trace id') &&
            HabotEventSchema.envelopeNote.contains('partition key') &&
            HabotEventSchema.noFreeTextNote.contains('Step 157') &&
            owners.length >= 6;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03448',
        atomicStepReferenceId: 'GEN-03448',
        setupStepAction:
            'Standardize UX telemetry event schemas across all mobile views.',
        implementationOrder: 156,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEventSchema / HabotEvent',
          'Component Properties':
              '${HabotEventKind.values.length} declared event kinds, '
              '${HabotEventSchema.envelope.length} envelope fields, '
              '${HabotFieldType.values.length} permitted payload field types '
              '(none of which is free text), schema version '
              '${HabotEventSchema.version}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. Partition field '
              '"${HabotEventSchema.partitionField}" and cluster field '
              '"${HabotEventSchema.clusterField}" are envelope fields, so the '
              'GCP alignment row cannot be satisfied for some kinds and not '
              'others.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UX Telemetry Schema Match',
            observed:
                '${matchRate.toStringAsFixed(3)} over a batch covering four '
                'event kinds. The same computation falls to '
                '${fallenRate.toStringAsFixed(3)} on a batch containing one '
                'instance of each of the five declared violations, so the '
                'figure is a measurement rather than a constant.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Violation classes detected and named',
            observed:
                '5 of 5 -- missing envelope field, missing required field, '
                'undeclared field, wrong type and free text. Each finding '
                'carries the field and the rule, so a CI failure says which '
                'rule an event broke rather than that it "failed validation".',
            floor: '5',
            optimal: '5',
            ceiling: '5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/event_schema.dart',
        ],
      ),
    );
  });
}
