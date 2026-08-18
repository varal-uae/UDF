/// AISS GATE -- Step 75 of 80
/// Global Reference ID:       GEN-02455
/// Atomic Steps Reference ID: GEN-02455
/// Setup Step (Action):       "Step 23: Develop the Universal Notification
///                             Center"
/// Setup Step Description:    "Determine which notifications require permanent
///                             storage versus ephemeral display."
/// Metric: UI Compliance Rate (%) -- Floor 0.95, Optimal 1.0, Ceiling 1.0.
/// Standard: "Material Design 3, WCAG 2.2 AA, W3C Web Standards".
///
/// A GENERATED ROW, RECORDED. This is one of the GEN-* rows whose prose is
/// assembled from a template: Why This Matters reads "Determine which
/// notifications require permanent storage versus ephemeral display. is a
/// critical implementation step", Expected Output reads "Fully configured and
/// validated implementation of: [the same sentence]", and the substeps are the
/// generic "1. Plan and scope this step. 2. Implement the core configuration.
/// 3. Test and validate in staging. 4. Document and commit to runbook."
/// Completion Measures ("100% CI/CD pass rate. All validation checks passing.
/// Documentation committed to runbook.") is a project-tracking statement, not
/// a property of a notification centre, and is not gated as one.
///
/// WHAT SURVIVES THE TEMPLATE IS THE DESCRIPTION, and it is a good one:
/// permanent storage versus ephemeral display is a classification decision,
/// and getting it wrong in either direction is a real failure -- a centre full
/// of expired dispatch offers, or an approval request that vanished before
/// anyone answered it. So the classification IS the step, and G1 gates the
/// recorded decision kind by kind.
///
/// ON THE METRIC: "UI Compliance Rate (%)" at a 0.95 floor is one of the few
/// GEN-* metrics in this batch that can be read honestly. The compliance
/// measured is whether every notification offered to the centre was handled
/// according to the classification -- stored when persisted, declined when
/// ephemeral, never silently lost. That is countable, and G3 counts it.
/// It is NOT a claim about M3 or WCAG conformance, which is what the row's
/// Standard column names; that reading is recorded as not produced here,
/// because this step builds a store and not a screen.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/notification_center.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';

import 'aiss_reporter.dart';

/// A fixed clock, so ordering is a fact rather than a race.
class _Clock {
  _Clock(this._now);
  DateTime _now;
  DateTime call() {
    _now = _now.add(const Duration(seconds: 1));
    return _now;
  }
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredCompliance = -1;
  int measuredStored = -1;
  int measuredDeclined = -1;

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

  HabotNotificationCenter freshCentre() => HabotNotificationCenter(
    clock: _Clock(DateTime(2026, 8, 14, 9)).call,
  );

  group('GEN-02455 :: the classification', () {
    gate(
      'GEN-02455-G1',
      'Setup Step Description: "Determine which notifications require PERMANENT '
          'STORAGE versus EPHEMERAL DISPLAY."',
      'Every notification kind resolves to exactly one retention, the decision '
          'is recorded kind by kind, and it is derived from the kind rather '
          'than passed in -- so two callers cannot disagree about whether the '
          'same event is worth keeping',
      () {
        const Map<HabotNotificationKind, HabotRetention> recorded =
            <HabotNotificationKind, HabotRetention>{
              // Expires in 60 seconds (Step 66). A kept offer is a dead offer.
              HabotNotificationKind.dispatch: HabotRetention.ephemeral,
              // The user watched it fail; the failure itself is logged.
              HabotNotificationKind.failure: HabotRetention.ephemeral,
              // Outstanding until answered.
              HabotNotificationKind.approval: HabotRetention.persisted,
              // A fact about the system, not a moment.
              HabotNotificationKind.critical: HabotRetention.persisted,
              // What a notification centre is for.
              HabotNotificationKind.informational: HabotRetention.persisted,
            };
        if (recorded.length != HabotNotificationKind.values.length) {
          return false;
        }
        for (final HabotNotificationKind kind
            in HabotNotificationKind.values) {
          if (HabotRetentionPolicy.forKind(kind) != recorded[kind]) {
            return false;
          }
          if (HabotRetentionPolicy.isPersisted(kind) !=
              (recorded[kind] == HabotRetention.persisted)) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'GEN-02455-G2',
      'Setup Step Description, the other half: an EPHEMERAL notification must '
          'not enter the centre, and a PERSISTED one must.',
      'Six notifications offered across the five kinds: the three persisted '
          'kinds are stored, the two ephemeral ones are declined, and a repeat '
          'of an id already held is not stored twice',
      () {
        final HabotNotificationCenter centre = freshCentre();
        addTearDown(centre.dispose);
        const List<HabotNotificationKind> offered = <HabotNotificationKind>[
          HabotNotificationKind.dispatch,
          HabotNotificationKind.informational,
          HabotNotificationKind.approval,
          HabotNotificationKind.failure,
          HabotNotificationKind.critical,
          HabotNotificationKind.informational,
        ];
        int stored = 0;
        for (int i = 0; i < offered.length; i++) {
          final bool kept = centre.receive(
            id: 'n$i',
            kind: offered[i],
            title: 'title $i',
            body: 'body $i',
            route: '/overview',
          );
          if (kept) {
            stored++;
          }
        }
        // The same id again: handled, not stored twice.
        final bool duplicate = centre.receive(
          id: 'n2',
          kind: HabotNotificationKind.approval,
          title: 'title 2',
          body: 'body 2',
          route: '/overview',
        );
        measuredStored = stored;
        measuredDeclined = offered.length - stored;
        return stored == 4 &&
            measuredDeclined == 2 &&
            !duplicate &&
            centre.storedCount == 4 &&
            centre.unreadCount == 4;
      },
    );
  });

  group('GEN-02455 :: the centre', () {
    gate(
      'GEN-02455-G3',
      'Metric: UI Compliance Rate (%) -- Floor 0.95, Optimal 1.0.',
      'Compliance is computed as handled-over-offered, where declining an '
          'ephemeral notification counts as handled -- so the number measures '
          'whether anything was silently lost, which is the only failure the '
          'centre can hide',
      () {
        final HabotNotificationCenter centre = freshCentre();
        addTearDown(centre.dispose);
        for (final HabotNotificationKind kind in HabotNotificationKind.values) {
          centre.receive(
            id: 'k-${kind.name}',
            kind: kind,
            title: kind.name,
            body: 'body',
            route: '/overview',
          );
        }
        measuredCompliance = centre.complianceRate;
        return centre.receivedCount == HabotNotificationKind.values.length &&
            measuredCompliance == 1.0 &&
            measuredCompliance >= 0.95;
      },
    );

    gate(
      'GEN-02455-G4',
      'Setup Step (Action): a notification CENTRE -- a place where an unread '
          'item waits. Read against the capacity the store must have to be one.',
      'Read and archived entries are evicted first under capacity pressure, an '
          'unread entry is never dropped to make room while a read one exists, '
          'and any unread eviction that does happen is counted rather than '
          'hidden',
      () {
        final HabotNotificationCenter centre = freshCentre();
        addTearDown(centre.dispose);
        for (int i = 0; i < HabotRetentionPolicy.capacity; i++) {
          centre.receive(
            id: 'e$i',
            kind: HabotNotificationKind.informational,
            title: 'title $i',
            body: 'body $i',
            route: '/overview',
          );
        }
        // Read one in the middle; it is the one that should go.
        centre.markRead('e100');
        centre.receive(
          id: 'new',
          kind: HabotNotificationKind.informational,
          title: 'newest',
          body: 'body',
          route: '/overview',
        );
        final bool readOneEvicted = !centre.entries.any(
          (HabotNotificationEntry e) => e.id == 'e100',
        );
        final bool oldestUnreadKept = centre.entries.any(
          (HabotNotificationEntry e) => e.id == 'e0',
        );
        return readOneEvicted &&
            oldestUnreadKept &&
            centre.evictedUnreadCount == 0 &&
            centre.storedCount == HabotRetentionPolicy.capacity &&
            centre.entries.first.id == 'new';
      },
    );

    gate(
      'GEN-02455-G5',
      'Setup Step Description, the consequence: an entry that has been read is '
          'not the same as one that has not, and the centre must be able to '
          'say which.',
      'Marking read, archiving and mark-all-read each change exactly what they '
          'name: an archived entry leaves the list without leaving the store, '
          'and the unread count follows',
      () {
        final HabotNotificationCenter centre = freshCentre();
        addTearDown(centre.dispose);
        for (int i = 0; i < 3; i++) {
          centre.receive(
            id: 'a$i',
            kind: HabotNotificationKind.approval,
            title: 'approval $i',
            body: 'body $i',
            route: '/tasks',
          );
        }
        if (centre.unreadCount != 3) {
          return false;
        }
        centre.markRead('a0');
        if (centre.unreadCount != 2 || centre.entries.length != 3) {
          return false;
        }
        centre.archive('a1');
        if (centre.entries.length != 2 ||
            centre.archived.length != 1 ||
            centre.storedCount != 3) {
          return false;
        }
        centre.markAllRead();
        return centre.unreadCount == 0 && centre.entries.length == 2;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02455',
        atomicStepReferenceId: 'GEN-02455-A01',
        setupStepAction: 'Step 23: Develop the Universal Notification Center',
        implementationOrder: 75,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Determine which notifications require permanent storage versus '
                  'ephemeral display':
              'RECORDED DECISION -- ephemeral: dispatch, failure. persisted: '
              'approval, critical, informational. Derived from the kind, so '
              'the answer is the same at every call site.',
          'Component Name': 'HabotNotificationCenter / HabotRetentionPolicy',
          'Capacity':
              '${HabotRetentionPolicy.capacity} entries; read and archived '
              'entries evicted first, unread evictions counted',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Why This Matters, Expected Output and the four '
              'substeps are template prose built from the Setup Step '
              'Description. Completion Measures ("100% CI/CD pass rate ... '
              'documentation committed to runbook") is project tracking, not a '
              'property of this step, and is not gated. The Setup Step '
              'Description itself is specific and is what the five gates are '
              'drawn from. METRIC SCOPE RECORDED: "UI Compliance Rate" is read '
              'as classification compliance, which is countable here; the '
              'Standard column ("Material Design 3, WCAG 2.2 AA, W3C Web '
              'Standards") describes a screen, and this step builds a store.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Compliance Rate (%)',
            observed: measuredCompliance < 0
                ? 'not measured'
                : '${measuredCompliance.toStringAsFixed(3)} -- every '
                      'notification offered was handled according to the '
                      'classification, none silently lost. Separately, of six '
                      'offered across the five kinds, $measuredStored were '
                      'stored and $measuredDeclined correctly declined.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/notification_center.dart',
        ],
      ),
    );
  });
}
