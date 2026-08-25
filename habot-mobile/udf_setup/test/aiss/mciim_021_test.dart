/// AISS GATE -- Step 81 of 95
/// Global Reference ID:       MCIIM-021
/// Atomic Steps Reference ID: MCIIM-021-A01
/// Setup Step (Action):       "Enforce Visual Isolation (Byt-Level Cropping)."
/// Setup Step Description:    "Access the Micro Task Outsourcing (MTO) API
///                             layout configuration file."
/// 4 Substeps:                "1) Define bounding box coordinates. 2) Crop
///                             source document. 3) Serve cropped image only.
///                             4) Remove surrounding context."
/// Poka-Yoke:                 "Backend physically crops the image; the mobile
///                             UI cannot fetch or request the full document
///                             URL."
/// Completion Measure:        "Worker cannot see the whole document on their
///                             mobile device under any circumstance."
/// Metric: Human-in-the-Loop Task Turnaround & Consensus Accuracy --
///         Floor 90% inter-worker agreement, Optimal 95-99%, Ceiling 100%.
///
/// THE ANCHOR ROW OF THE BATCH, and the only fully coherent one in it: four
/// real substeps, a real poka-yoke, and a completion measure written as a
/// state of the world rather than as a checkbox. Every gate below comes from
/// one of those columns.
///
/// METRIC NOT PRODUCED, RECORDED: inter-worker consensus is a crowd-labour
/// measure -- the same task given to two people, and how often they agree. No
/// widget test produces it and no number is invented here. What IS measured is
/// the isolation the metric depends on, which the sheet's own Self-Chasing
/// column ties together: "if cropping is bad, workers will fail the 15-minute
/// timer because they cannot read the image."
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

Uri _crop(HabotBoundingBox box) => Uri.parse(
  'https://assets.habot.internal/crops/byt-1.png'
  '?crop=${HabotCropContract.signatureFor(box)}',
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredExposure = -1;

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

  group('MCIIM-021-A01 :: the four substeps', () {
    gate(
      'MCIIM-021-G1',
      'Substep 1: "Define bounding box coordinates." Completion Measure: '
          '"Worker cannot see the WHOLE DOCUMENT on their mobile device under '
          'any circumstance."',
      'A box knows the page it was cut from as dimensions, validates that it '
          'lies inside it, and reports the share of the page it exposes -- so '
          'the completion measure is a number rather than an intention',
      () {
        measuredExposure = _box.exposedFraction;
        const HabotBoundingBox outside = HabotBoundingBox(
          left: 2400,
          top: 240,
          width: 640,
          height: 180,
          sourceWidth: 2480,
          sourceHeight: 3508,
        );
        const HabotBoundingBox wholePage = HabotBoundingBox(
          left: 0,
          top: 0,
          width: 2480,
          height: 3508,
          sourceWidth: 2480,
          sourceHeight: 3508,
        );
        return _box.isValid &&
            !outside.isValid &&
            measuredExposure < HabotBoundingBox.wholeDocumentFraction &&
            !_box.exposesWholeDocument &&
            wholePage.exposesWholeDocument &&
            (_box.aspectRatio - (640 / 180)).abs() < 0.0001;
      },
    );

    gate(
      'MCIIM-021-G2',
      'Substeps 2 and 3: "Crop source document" / "Serve CROPPED IMAGE ONLY." '
          'Poka-Yoke: "Backend physically crops the image; the mobile UI '
          'cannot fetch or request the full document URL."',
      'Five deliveries are judged: a stamped crop is accepted, a crop stamped '
          'for a different region is refused, an asset outside the crop path '
          'is refused, an unstamped one is refused, and a PDF is refused as a '
          'source document',
      () {
        final String signature = HabotCropContract.signatureFor(_box);
        return HabotCropContract.refuse(_crop(_box), _box) == null &&
            HabotCropContract.refuse(
                  Uri.parse(
                    'https://assets.habot.internal/crops/byt-1.png'
                    '?crop=0,0,10,10',
                  ),
                  _box,
                ) ==
                HabotCropRefusal.uncroppedAsset &&
            HabotCropContract.refuse(
                  Uri.parse(
                    'https://assets.habot.internal/assets/byt-1.png'
                    '?crop=$signature',
                  ),
                  _box,
                ) ==
                HabotCropRefusal.uncroppedAsset &&
            HabotCropContract.refuse(
                  Uri.parse('https://assets.habot.internal/crops/byt-1.png'),
                  _box,
                ) ==
                HabotCropRefusal.uncroppedAsset &&
            HabotCropContract.refuse(
                  Uri.parse(
                    'https://assets.habot.internal/crops/invoice.pdf'
                    '?crop=$signature',
                  ),
                  _box,
                ) ==
                HabotCropRefusal.sourceDocument;
      },
    );

    test('[MCIIM-021-G3] there is no field, parameter or accessor through '
        'which a full document URL could travel', () {
      final String source = File(
        'lib/design_system/mto/byt_isolation.dart',
      ).readAsStringSync();
      final String taskSource = File(
        'lib/design_system/mto/task_payload.dart',
      ).readAsStringSync();

      // The poka-yoke is the shape of the type, so the check is on the type.
      for (final String forbidden in <String>[
        'documentUrl',
        'sourceUri',
        'sourceUrl',
        'fullDocument',
        'pageAsset',
      ]) {
        expect(
          source.contains(forbidden),
          isFalse,
          reason: 'byt_isolation.dart must not carry $forbidden',
        );
        expect(
          taskSource.contains(forbidden),
          isFalse,
          reason: 'task_payload.dart must not carry $forbidden',
        );
      }
      // And only one construction path exists.
      expect(
        RegExp(r'HabotByt\._\(').allMatches(source).length,
        2,
        reason:
            'one private constructor declaration and one call to it, inside '
            'fromDelivery -- any third occurrence is a second way in',
      );

      gates.add(
        const AissGate(
          id: 'MCIIM-021-G3',
          requirementSource:
              'Poka-Yoke: "the mobile UI CANNOT FETCH OR REQUEST the full '
              'document URL."',
          description:
              'A source scan proves the isolation types carry no document '
              'locator under any of its usual names, and that the only way to '
              'build a task is the factory that refuses uncropped assets',
          passed: true,
          detail: 'byt_isolation.dart + task_payload.dart scanned',
        ),
      );
    });

    gate(
      'MCIIM-021-G4',
      'Substep 4: "Remove surrounding context." Completion Measure: the '
          'worker cannot see the whole document UNDER ANY CIRCUMSTANCE.',
      'A refused delivery produces no task at all rather than a partly '
          'isolated one, and the isolation compliance over a mixed batch is '
          'the share that became real crops -- so "under any circumstance" is '
          'countable',
      () {
        final HabotByt? good = HabotByt.fromDelivery(
          id: 'byt-1',
          box: _box,
          snippet: _crop(_box),
          prompt: 'Read the invoice total',
          expectedFormat: 'digits and a decimal point',
        );
        final HabotByt? uncropped = HabotByt.fromDelivery(
          id: 'byt-2',
          box: _box,
          snippet: Uri.parse('https://assets.habot.internal/full/invoice.png'),
          prompt: 'Read the invoice total',
          expectedFormat: 'digits',
        );
        final HabotByt? noPrompt = HabotByt.fromDelivery(
          id: 'byt-3',
          box: _box,
          snippet: _crop(_box),
          prompt: '',
          expectedFormat: 'digits',
        );
        return good != null &&
            uncropped == null &&
            noPrompt == null &&
            HabotIsolationAudit.isIsolated(good) &&
            !HabotIsolationAudit.isIsolated(uncropped) &&
            HabotIsolationAudit.complianceOf(<HabotByt?>[
                  good,
                  uncropped,
                  noPrompt,
                ]) ==
                1 / 3 &&
            HabotIsolationAudit.worstExposure(<HabotByt>[good]) ==
                _box.exposedFraction;
      },
    );

    gate(
      'MCIIM-021-G5',
      'UX Translation: "Minimalist UI showing ONE cropped image and ONE '
          'specific input." Mobile App First: "serving only a cropped '
          'lightweight image snippet rather than a heavy 5MB PDF."',
      'A task carries exactly one snippet, one prompt and one expected format, '
          'and says so to a screen reader without offering a route to the page '
          'it came from',
      () {
        final HabotByt task = HabotByt.fromDelivery(
          id: 'byt-1',
          box: _box,
          snippet: _crop(_box),
          prompt: 'Read the invoice total',
          expectedFormat: 'digits and a decimal point',
        )!;
        return task.snippet.pathSegments.contains(
              HabotCropContract.cropSegment,
            ) &&
            task.prompt.isNotEmpty &&
            task.expectedFormat.isNotEmpty &&
            task.semanticsLabel.contains('Cropped evidence only') &&
            task.semanticsLabel.contains('not available on this device');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MCIIM-021',
        atomicStepReferenceId: 'MCIIM-021-A01',
        setupStepAction: 'Enforce Visual Isolation (Byt-Level Cropping).',
        implementationOrder: 81,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Key': 'crop signature (left,top,width,height)',
          'Configuration Value': HabotCropContract.signatureFor(_box),
          'Configuration Type':
              'crop contract -- the client refuses any asset the cropping '
              'service has not stamped for this exact box',
          'Validation Status': 'Derived from gate outcomes',
          'Configuration Timestamp': 'carried by the delivery, not by the type',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'The most coherent row in this batch: four real substeps, a real '
              'poka-yoke and a completion measure that can fail a build. '
              'METRIC NOT PRODUCED -- inter-worker consensus accuracy is a '
              'crowd-labour measure across people, not a property of a client. '
              'No number invented. DEPENDENCY COLUMNS DISAGREE: the prose '
              'Dependencies cell reads "HC-INF-0134" while Dependency Count is '
              '0 and the machine column reads "No Dependency"; selection used '
              'the machine columns, as in every batch.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Human-in-the-Loop Task Turnaround & Consensus Accuracy',
            observed:
                'NOT PRODUCED -- consensus accuracy is measured by giving the '
                'same task to several people and comparing their answers. No '
                'suite observes that. What was measured instead: the isolation '
                'it depends on, including the exposure below.',
            floor: '90% inter-worker agreement',
            optimal: '95-99% inter-worker agreement',
            ceiling: '100% (cannot exceed)',
          ),
          AissMeasurement(
            metricName:
                'Source-page exposure (this step\'s own, not from the sheet)',
            observed: measuredExposure < 0
                ? 'not measured'
                : '${(measuredExposure * 100).toStringAsFixed(2)}% of the '
                      'source page exposed by the gated crop -- a 640x180 '
                      'region of a 2480x3508 page. The whole-document '
                      'threshold is 90%.',
            floor: 'below 90% of the page',
            optimal: 'the smallest region that answers the question',
            ceiling: 'no sheet band',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/byt_isolation.dart',
        ],
      ),
    );
  });
}
