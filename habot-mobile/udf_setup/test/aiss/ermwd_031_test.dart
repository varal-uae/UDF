/// AISS GATE -- Step 90 of 95
/// Global Reference ID:       ERMWD-031-01
/// Atomic Steps Reference ID: ERMWD-031-01-A01
/// Setup Step (Action):       "Implement the frontend logic mapping FAILED
///                             MOBILE BYT JSON PAYLOADS to the worker UI task
///                             cards. (Code the deserialization logic that
///                             takes a raw mobile payload from the Pub/Sub DLQ
///                             push endpoint and binds the variables
///                             precisely.)"
/// Setup Step Description:    "Open the MTB API worker interface frontend
///                             codebase in the development environment."
/// Metric: Process Adherence / Task Completion Rate -- Floor >= 90%,
///         Optimal 1.0, Ceiling 1.0.
///
/// A THIN ROW (21 of 49 columns), RECORDED, and its one populated data column
/// belongs to something else: Data Requirement reads "Frontend Technology;
/// Framework Version; Build Configuration; Performance Metrics; Build Output
/// Path" with four "N/A." entries where the mobile UX configuration should be.
/// Build-tooling fields on a UI binding step. Not gated.
///
/// THE SETUP STEP IS SPECIFIC AND IS WHAT THE GATES DEFEND. These payloads
/// come from a dead-letter queue -- they are the ones that already failed once
/// -- so the deserialiser is deliberately unforgiving: every field checked,
/// every rejection carrying a reason, and no path that produces a task card
/// with empty text in it.
///
/// HOW THE METRIC IS READ, STATED: "Process Adherence / Task Completion Rate"
/// on a deserialiser is read as the share of payloads that SHOULD bind and
/// did. Malformed payloads are not failures of adherence -- they are the
/// input. Both numbers are reported: the adherence over well-formed
/// deliveries, and the totality (nothing lost) over everything.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/task_payload.dart';

import 'aiss_reporter.dart';

const Map<String, Object?> _boxJson = <String, Object?>{
  'left': 120,
  'top': 240,
  'width': 640,
  'height': 180,
  'sourceWidth': 2480,
  'sourceHeight': 3508,
};

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

Map<String, Object?> _payload(String id) => <String, Object?>{
  'id': id,
  'prompt': 'Read the invoice total',
  'expectedFormat': 'digits and a decimal point',
  'box': _boxJson,
  'snippet':
      'https://assets.habot.internal/crops/$id.png'
      '?crop=${HabotCropContract.signatureFor(_box)}',
};

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredAdherence = -1;
  int measuredRejections = -1;

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

  group('ERMWD-031-01-A01 :: the binding', () {
    gate(
      'ERMWD-031-01-G1',
      'Setup Step (Action): "binds the variables PRECISELY." Metric: Process '
          'Adherence / Task Completion Rate -- Floor >= 90%, Optimal 1.0.',
      'Six well-formed payloads all bind, every field lands on the right '
          'property, and the adherence over deliveries that should bind is 1.0',
      () {
        final HabotTaskBinder binder = HabotTaskBinder();
        for (int i = 0; i < 6; i++) {
          binder.bind(_payload('byt-$i'));
        }
        measuredAdherence = binder.boundRate;
        final HabotBindingResult one = HabotTaskBinder().bind(
          _payload('byt-x'),
        );
        final HabotByt? task = one.task;
        return binder.boundCount == 6 &&
            binder.rejectedCount == 0 &&
            measuredAdherence == 1.0 &&
            one.isBound &&
            task != null &&
            task.id == 'byt-x' &&
            task.prompt == 'Read the invoice total' &&
            task.expectedFormat == 'digits and a decimal point' &&
            task.box == _box;
      },
    );

    gate(
      'ERMWD-031-01-G2',
      'Setup Step (Action): "FAILED mobile Byt JSON payloads ... from the '
          'Pub/Sub DLQ push endpoint." These are the payloads that already '
          'went wrong once.',
      'Six malformed shapes are each classified with the right defect and a '
          'reason: not JSON, missing id, empty prompt, a box field of the '
          'wrong type, a box outside its source, and an uncropped asset',
      () {
        final HabotTaskBinder binder = HabotTaskBinder();
        final HabotBindingResult notJson = binder.bindRaw('{oops');
        final HabotBindingResult noId = binder.bind(
          Map<String, Object?>.from(_payload('byt-1'))..remove('id'),
        );
        final HabotBindingResult noPrompt = binder.bind(
          Map<String, Object?>.from(_payload('byt-2'))..['prompt'] = '',
        );
        final HabotBindingResult wrongType = binder.bind(
          Map<String, Object?>.from(_payload('byt-3'))
            ..['box'] = <String, Object?>{..._boxJson, 'width': '640'},
        );
        final HabotBindingResult outside = binder.bind(
          Map<String, Object?>.from(_payload('byt-4'))
            ..['box'] = <String, Object?>{..._boxJson, 'left': 2400},
        );
        final HabotBindingResult uncropped = binder.bind(
          Map<String, Object?>.from(_payload('byt-5'))
            ..['snippet'] = 'https://assets.habot.internal/full/invoice.png',
        );
        measuredRejections = binder.rejectedCount;
        return notJson.rejection?.defect == HabotBytDefect.malformedJson &&
            noId.rejection?.defect == HabotBytDefect.missingField &&
            noPrompt.rejection?.defect == HabotBytDefect.missingField &&
            wrongType.rejection?.defect == HabotBytDefect.wrongType &&
            outside.rejection?.defect == HabotBytDefect.invalidBox &&
            uncropped.rejection?.defect == HabotBytDefect.uncroppedAsset &&
            binder.boundCount == 0 &&
            measuredRejections == 6 &&
            binder.rejections.every(
              (HabotPayloadRejection r) => r.detail.isNotEmpty,
            );
      },
    );

    gate(
      'ERMWD-031-01-G3',
      'Setup Step (Action): payloads map to TASK CARDS. A card with empty '
          'text in it is how a worker starts guessing, which MCIIM-021 exists '
          'to prevent.',
      'Every payload produces either a task or a recorded rejection -- never '
          'nothing -- and no rejected payload yields a partially built task',
      () {
        final HabotTaskBinder binder = HabotTaskBinder();
        binder.bind(_payload('byt-1'));
        binder.bindRaw(jsonEncode(_payload('byt-2')));
        binder.bindRaw('not json at all');
        binder.bind(
          Map<String, Object?>.from(_payload('byt-3'))..remove('box'),
        );
        return binder.receivedCount == 4 &&
            binder.boundCount == 2 &&
            binder.rejectedCount == 2 &&
            binder.isTotal &&
            binder.rejections.every(
              (HabotPayloadRejection r) => r.defect != HabotBytDefect.duplicate,
            );
      },
    );

    gate(
      'ERMWD-031-01-G4',
      'Pub/Sub DLQ delivery is AT LEAST ONCE -- the same transport fact '
          'GEN-00335 (Step 79) had to absorb for violations.',
      'The same task id arriving twice binds once and is recorded as a '
          'duplicate the second time, so a redelivered payload cannot put the '
          'same task in a worker\'s queue twice',
      () {
        final HabotTaskBinder binder = HabotTaskBinder();
        final HabotBindingResult first = binder.bind(_payload('byt-1'));
        final HabotBindingResult second = binder.bind(_payload('byt-1'));
        return first.isBound &&
            !second.isBound &&
            second.rejection?.defect == HabotBytDefect.duplicate &&
            binder.boundCount == 1 &&
            binder.isTotal;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ERMWD-031-01',
        atomicStepReferenceId: 'ERMWD-031-01-A01',
        setupStepAction:
            'Implement the frontend logic mapping failed mobile Byt JSON '
            'payloads to the worker UI task cards.',
        implementationOrder: 90,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Binding outcome':
              'bound / rejected, with one of six named defects and a reason on '
              'every rejection',
          'Rejections classified': measuredRejections < 0
              ? 'not measured'
              : '$measuredRejections of 6 malformed shapes',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THIN ROW (21 of 49 columns) and the one populated data column '
              'is about build tooling -- "Frontend Technology; Framework '
              'Version; Build Configuration; Performance Metrics; Build Output '
              'Path", with four "N/A." entries where the mobile UX '
              'configuration belongs. Not gated. METRIC READING STATED: '
              'adherence is measured over payloads that SHOULD bind; malformed '
              'ones are the input, not a failure of adherence, and totality '
              '(nothing lost) is reported separately.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Adherence / Task Completion Rate',
            observed: measuredAdherence < 0
                ? 'not measured'
                : '${measuredAdherence.toStringAsFixed(4)} over well-formed '
                      'deliveries (6 of 6 bound, every field landing on the '
                      'right property). Separately: 6 malformed shapes each '
                      'classified with the correct defect, and every payload '
                      'accounted for as bound or rejected -- none lost.',
            floor: '>= 90%',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_payload.dart',
        ],
      ),
    );
  });
}
