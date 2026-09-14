/// AISS GATE -- Step 190 of 195
/// Global Reference ID:       GEN-04913
/// Atomic Steps Reference ID: GEN-04913
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Success Green
///               color tokens applied on valid signature lock."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// THERE IS NO SUCCESS ROLE IN MATERIAL DESIGN 3. Reaching for Colors.green or
/// inventing a hex would both be unaudited literals the guard blocks -- so an
/// audited role carries it and the missing role is requested through the Step
/// 177 brand-extension mechanism. And "signature lock" makes the false
/// positive the expensive direction.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/feedback/success_state_color.dart';
import 'package:udf_setup/design_system/forms/validation_state_color.dart';
import 'package:udf_setup/design_system/tokens/m3_naming.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-04913 :: the role that does not exist', () {
    gate(
      'GEN-04913-G1',
      'Atomic Step: "M3 Success Green color tokens". MD3 specifies primary, '
          'secondary, tertiary and error -- that is the whole semantic set.',
      'The substitution is recorded: the requested role is named, an existing '
          'AUDITED role carries it, and the surfaces that paint it are '
          'declared with their text pairs rather than a green being chosen '
          'somewhere',
      () async =>
          HabotSuccessStateColor.requestedRole.contains('M3 Success Green') &&
          HabotSuccessStateColor.carrierRole == 'tertiary' &&
          HabotSuccessStateColor.carrierOnRole == 'onTertiary' &&
          HabotSuccessStateColor.carrierToken == 'md.sys.color.tertiary' &&
          HabotSuccessStateColor.carrierOnToken ==
              'md.sys.color.on-tertiary' &&
          HabotM3Naming.isConformant(HabotSuccessStateColor.carrierToken) &&
          HabotSuccessStateColor.successRoles['containerText'] ==
              'onTertiaryContainer' &&
          HabotSuccessStateColor.noSuccessRoleNote
              .contains('the guard blocks, correctly'),
    );

    gate(
      'GEN-04913-G2',
      '"tertiary carries it today because tertiary happens to be unused in '
          'this product, which is a coincidence rather than a design."',
      'The dedicated role set is requested as a brand extension with reasons, '
          'and what is outstanding is named -- adding the roles means adding '
          'colours, which means the Step 4 audit and a palette that has been '
          'PROVISIONAL since Step 1',
      () async =>
          HabotSuccessStateColor.requestedExtension.length == 4 &&
          HabotSuccessStateColor.requestedExtension.containsKey('success') &&
          HabotSuccessStateColor.requestedExtension.containsKey('onSuccess') &&
          HabotSuccessStateColor.requestedExtension['success']!
              .contains('coincidence rather than a design') &&
          HabotSuccessStateColor.outstanding.length == 1 &&
          HabotSuccessStateColor.outstanding.single.contains('PROVISIONAL'),
    );

    gate(
      'GEN-04913-G3',
      '"Red-green deficiency is the most common colour vision deficiency '
          'there is. To those users the locked tick and the Step 189 error '
          'border are the same colour."',
      'The success glyph differs from the error glyph in SHAPE rather than '
          'only in hue, and the state carries a semantics announcement so it '
          'reaches a user who sees no colour at all',
      () async =>
          HabotSuccessStateColor.shapeDistinguishesFromError &&
          HabotSuccessStateColor.iconShape == 'check' &&
          HabotSuccessStateColor.errorIconShape == 'exclamation' &&
          HabotSuccessStateColor.carriers.length > 1 &&
          HabotSuccessStateColor.carriers
              .contains(HabotStateCarrier.semantics) &&
          HabotSuccessStateColor.carriers.contains(HabotStateCarrier.icon) &&
          HabotSuccessStateColor.greenAloneNote
              .contains('least load-bearing'),
    );
  });

  group('GEN-04913 :: the expensive direction', () {
    gate(
      'GEN-04913-G4',
      '"A missing success indicator is a user who checks again. A success '
          'indicator over a write that has not committed is a user who walks '
          'away from an unsigned document."',
      'Only a committed outcome may be painted as success: queued locally and '
          'in flight are both refused, and the failed state is refused too',
      () async =>
          HabotSuccessStateColor.mayShowSuccess(
            HabotCommitConfidence.committed,
          ) &&
          !HabotSuccessStateColor.mayShowSuccess(
            HabotCommitConfidence.queuedLocally,
          ) &&
          !HabotSuccessStateColor.mayShowSuccess(
            HabotCommitConfidence.inFlight,
          ) &&
          !HabotSuccessStateColor.mayShowSuccess(
            HabotCommitConfidence.failed,
          ) &&
          HabotCommitConfidence.values.length == 4 &&
          HabotSuccessStateColor.falsePositiveNote
              .contains('queued, not signed'),
    );

    gate(
      'GEN-04913-G5',
      'Step 117: "an entry sitting in the outbox is queued, not signed."',
      'Confidence is read from the state the Step 117 queue actually holds '
          'rather than from a flag somebody set -- a freshly enqueued entry '
          'reads as queued locally, and painting success over it is refused',
      () async {
        final HabotOutbox outbox = HabotOutbox(store: HabotMemoryStore());
        final HabotOutboxEntry entry = await outbox.enqueue(
          id: 'signature-1',
          kind: 'signature-lock',
          payload: <String, Object?>{'document': 'doc-1'},
        );
        final HabotCommitConfidence confidence =
            HabotSuccessStateColor.confidenceOf(entry);
        return entry.state == HabotOutboxState.pending &&
            confidence == HabotCommitConfidence.queuedLocally &&
            !HabotSuccessStateColor.mayShowSuccess(confidence) &&
            HabotSuccessStateColor.confidenceOf(
                  entry.copyWith(state: HabotOutboxState.sent),
                ) ==
                HabotCommitConfidence.committed &&
            HabotSuccessStateColor.confidenceOf(
                  entry.copyWith(state: HabotOutboxState.dead),
                ) ==
                HabotCommitConfidence.failed;
      },
    );

    gate(
      'GEN-04913-G6',
      '"Not success, and not nothing."',
      'While the signature is queued the user is told what that means, in the '
          'same terms the Step 125 offline chip already uses, rather than '
          'being shown an absence',
      () async =>
          HabotSuccessStateColor.pendingDisclosure.contains('Queued') &&
          HabotSuccessStateColor.pendingDisclosure
              .contains('saved on this device') &&
          HabotSuccessStateColor.pendingDisclosure
              .contains('when the connection returns'),
    );

    gate(
      'GEN-04913-G7',
      'Metric: UI Styling / Transition Compliance -- <=100ms, Pass / Fail.',
      'Success may ease in where an error may not -- it is confirmation rather '
          'than an alert -- and every compliance condition holds inside the '
          'row\'s budget',
      () async =>
          HabotSuccessStateColor.enterTransition >
              HabotValidationStateColor.enterTransition &&
          HabotSuccessStateColor.withinBudget(
            HabotSuccessStateColor.enterTransition,
          ) &&
          HabotSuccessStateColor.withinBudget(
            HabotSuccessStateColor.exitTransition,
          ) &&
          !HabotSuccessStateColor.withinBudget(
            const Duration(milliseconds: 101),
          ) &&
          HabotSuccessStateColor.isCompliant &&
          HabotSuccessStateColor.complianceChecks.length == 8 &&
          HabotSuccessStateColor.complianceChecks.values.every((bool b) => b) &&
          HabotSuccessStateColor.qualitativeOutput == 'Pass' &&
          HabotSuccessStateColor.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04913',
        atomicStepReferenceId: 'GEN-04913',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement the mobile UI styling requirement: M3 Success '
            'Green color tokens applied on valid signature lock."',
        implementationOrder: 190,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSuccessStateColor',
          'Component Properties':
              'Carrier role ${HabotSuccessStateColor.carrierRole} '
              '(${HabotSuccessStateColor.carrierToken}); '
              '${HabotSuccessStateColor.successRoles.length} success surface '
              'roles; ${HabotCommitConfidence.values.length} commit confidence '
              'levels of which one may be painted as success; '
              '${HabotSuccessStateColor.requestedExtension.length} brand '
              'extension roles requested',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: Material Design 3 has no success role. '
              '"M3 Success Green" names something the specification does not '
              'contain. Colors.green and an invented hex are both unaudited '
              'literals the poka-yoke guard blocks, correctly; so the audited '
              'tertiary role carries the state and a dedicated success / '
              'onSuccess / successContainer / onSuccessContainer set is '
              'requested through the Step 177 brand-extension mechanism. '
              'OUTSTANDING: adding those roles means adding colours, which '
              'means the Step 4 audit and brand sign-off -- and the palette '
              'has been PROVISIONAL since Step 1. ADDED BEYOND THE ROW: '
              'success is driven by the COMMITTED outcome, never the '
              'optimistic local one, because a success indicator over an '
              'unsigned document is a user who walks away from it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Styling / Transition Compliance',
            observed:
                'Enter '
                '${HabotSuccessStateColor.enterTransition.inMilliseconds}ms, '
                'exit '
                '${HabotSuccessStateColor.exitTransition.inMilliseconds}ms, '
                'both inside the 100ms budget. Unlike the Step 189 error '
                'state, success may ease in: it is confirmation rather than an '
                'alert, and an immediate snap to a confirmed state is what '
                'makes people unsure whether they caused it. All '
                '${HabotSuccessStateColor.complianceChecks.length} conditions '
                'hold.',
            floor: '<=100ms transition duration; visual QA pass on target '
                'devices',
            optimal: '<=100ms transition, 100% visual QA pass',
            ceiling: '>100ms transitions read as sluggish; >0 visual QA '
                'defects',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Success painted over an uncommitted write',
            observed:
                '0 of 3 non-committed confidence levels may be painted as '
                'success. Confidence is read from the Step 117 outbox state '
                'rather than from a flag: a freshly enqueued signature reads '
                'as queuedLocally and is refused, and the user is told it is '
                'queued rather than shown nothing.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/success_state_color.dart',
        ],
      ),
    );
  });
}
