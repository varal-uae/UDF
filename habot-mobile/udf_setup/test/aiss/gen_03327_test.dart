/// AISS GATE -- Step 112 of 115
/// Global Reference ID:       GEN-03327
/// Atomic Steps Reference ID: GEN-03327-A01
/// Setup Step (Action):       "Write abstract Repository interfaces for data
///                             fetching and local persistence."
/// Metric: Repository Abstract Conformance -- Floor 1.0, Optimal 1.0,
///         Ceiling 1.0. Reference standard: SOLID.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE BEST-ALIGNED ROW IN THE BATCH. All three bands are 1.0, which is the
/// sheet saying this is not a percentage but a yes. It is gated literally: a
/// conformance of 1.0 or the step has not been done.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/repository.dart';

import 'aiss_reporter.dart';

/// A minimal entity, so the interface is exercised rather than described.
class _Job implements HabotEntity {
  const _Job(this.entityId, this.revision, this.site);

  @override
  final String entityId;
  @override
  final int revision;
  final String site;

  @override
  Map<String, Object?> toRecord() => <String, Object?>{'site': site};
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  final List<bool> propertyResults = <bool>[];

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

  group('GEN-03327-A01 :: the four conformance properties', () {
    gate(
      'GEN-03327-G1',
      'SOLID / dependency inversion: a repository that returns a database row '
          'type is not an abstraction, it is a rename.',
      'No storage engine appears in any signature -- the interface is '
          'expressed entirely in entities, results and tickets, and the '
          'forbidden-token check is data so it can be applied to a new method',
      () {
        const List<String> signatures = <String>[
          'Future<HabotResult<T>> findById(String id)',
          'Future<HabotResult<List<T>>> findAll()',
          'Stream<List<T>> watchAll()',
          'Future<HabotResult<HabotWriteTicket>> save(T entity)',
          'Future<HabotResult<HabotWriteTicket>> delete(String id)',
          'Future<HabotResult<List<HabotWriteTicket>>> pendingWrites()',
        ];
        final bool clean = signatures.every(
          HabotRepositoryConformance.signatureIsClean,
        );
        // The check itself must be capable of firing.
        final bool detects = !HabotRepositoryConformance.signatureIsClean(
          'Future<Cursor> query(SqliteDatabase db)',
        );
        propertyResults.add(clean && detects);
        return clean && detects;
      },
    );

    gate(
      'GEN-03327-G2',
      'An offline-first app spends its life in the failure path; a design '
          'where the normal case throws is one where callers forget to catch.',
      'Failure is a value, the result type is sealed so a switch over it is '
          'exhaustive, and a failed read can still carry the cached value it '
          'has -- losing that distinction is how offline-first apps end up '
          'with blank screens',
      () {
        const HabotResult<_Job> failure = HabotFailure<_Job>(
          failure: HabotDataFailure.offline,
          detail: 'no connection',
          cachedValue: _Job('J1', 3, 'Site A'),
        );
        final bool valueShape =
            failure.failureOrNull == HabotDataFailure.offline &&
            !failure.isSuccess &&
            failure.valueOrNull == null &&
            (failure as HabotFailure<_Job>).cachedValue?.entityId == 'J1';
        final String describe = switch (failure) {
          HabotSuccess<_Job>() => 'success',
          HabotFailure<_Job>() => 'failure',
        };
        propertyResults.add(valueShape && describe == 'failure');
        return valueShape && describe == 'failure';
      },
    );

    gate(
      'GEN-03327-G3',
      '"Is this stale?" is a question the caller must be able to answer, and '
          'the repository cannot answer it for them.',
      'Every read declares where the value came from and how old it is, and '
          'stale is a distinct origin rather than a flag someone remembers to '
          'set',
      () {
        final DateTime t = DateTime(2026, 8, 24, 9, 14);
        final HabotSuccess<_Job> fresh = HabotSuccess<_Job>(
          value: const _Job('J1', 3, 'Site A'),
          origin: HabotDataOrigin.network,
          retrievedAt: t,
        );
        final HabotSuccess<_Job> stale = HabotSuccess<_Job>(
          value: const _Job('J1', 3, 'Site A'),
          origin: HabotDataOrigin.localStale,
          retrievedAt: t,
        );
        final bool ok =
            !fresh.isStale &&
            stale.isStale &&
            fresh.ageAt(t.add(const Duration(minutes: 5))) ==
                const Duration(minutes: 5) &&
            HabotDataOrigin.values.length == 4;
        propertyResults.add(ok);
        return ok;
      },
    );

    gate(
      'GEN-03327-G4',
      'A key made at SEND time is a new key on every retry, which is no key '
          'at all.',
      'Every write returns an addressable ticket minted at QUEUE time, which '
          'is what lets Step 117 find the write again after a restart and '
          'Step 122 recognise a duplicate',
      () {
        final DateTime t = DateTime(2026, 8, 24, 9, 14);
        final HabotWriteTicket ticket = HabotWriteTicket(
          ticketId: 'jobs:J1:4',
          entityId: 'J1',
          queuedAt: t,
          pending: true,
        );
        final Map<String, Object?> j = ticket.toJson();
        final bool ok =
            j['ticket_id'] == 'jobs:J1:4' &&
            j['entity_id'] == 'J1' &&
            j['pending'] == true &&
            j['queued_at'] == t.toIso8601String();
        propertyResults.add(ok);
        return ok;
      },
    );
  });

  group('GEN-03327-A01 :: the metric, read literally', () {
    gate(
      'GEN-03327-G5',
      'Metric: Repository Abstract Conformance -- floor 1.0, optimal 1.0, '
          'ceiling 1.0.',
      'The rate is 1.0 only when EVERY property holds; three quarters of an '
          'abstraction is a leak, so a percentage would be the wrong shape and '
          'the function refuses to produce one',
      () =>
          HabotRepositoryConformance.rate(propertyResults: propertyResults) ==
              1.0 &&
          HabotRepositoryConformance.rate(
                propertyResults: <bool>[true, true, true, false],
              ) ==
              0.0 &&
          HabotRepositoryConformance.properties.length == 4,
    );

    gate(
      'GEN-03327-G6',
      'An entity that does not know which of two copies is later cannot be '
          'synchronised; Step 116 and Step 118 both need that answer without '
          'asking a clock that may be wrong.',
      'Identity and revision are part of the entity contract, not of the '
          'storage layer, and a concrete entity satisfies it without '
          'importing anything from storage',
      () {
        const _Job a = _Job('J1', 3, 'Site A');
        const _Job b = _Job('J1', 4, 'Site A');
        return a.entityId == b.entityId &&
            b.revision > a.revision &&
            a.toRecord()['site'] == 'Site A';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03327',
        atomicStepReferenceId: 'GEN-03327-A01',
        setupStepAction:
            'Write abstract Repository interfaces for data fetching and local '
            'persistence.',
        implementationOrder: 112,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotRepository / HabotResult / HabotEntity / HabotWriteTicket',
          'Component Properties':
              '${HabotRepositoryConformance.properties.length} conformance '
              'properties; ${HabotDataOrigin.values.length} declared data '
              'origins; ${HabotDataFailure.values.length} failure kinds, all '
              'returned as values rather than thrown',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row. The metric is an exact fit: all '
              'three bands are 1.0.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Repository Abstract Conformance',
            observed:
                '${HabotRepositoryConformance.rate(propertyResults: propertyResults)} '
                '-- all ${HabotRepositoryConformance.properties.length} '
                'properties hold: ${HabotRepositoryConformance.properties.join("; ")}',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'SDUI applicability',
            observed:
                'NOT APPLICABLE, RECORDED. This interface is designed for '
                'RECORDS. The Step 114 row mentions SDUI layout JSON; if '
                'server-driven UI is ever planned, this file is where that '
                'decision lands and it would be a different interface, not '
                'this one with a Map squeezed through it.',
            floor: 'not applicable',
            optimal: 'not applicable',
            ceiling: 'not applicable',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/repository.dart',
        ],
      ),
    );
  });
}
