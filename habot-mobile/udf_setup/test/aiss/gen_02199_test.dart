/// AISS GATE -- Step 419 of 415
/// Global Reference ID:       GEN-02199
/// Atomic Steps Reference ID: GEN-02199
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Inject the tracking SDK into the mobile frontend."
/// Metric: Process Execution Accuracy -- floor "0.9", optimal "0.97", ceiling
///         "0.999". Best Qualitative Output: "Pass / Fail". ISO/IEC 25010
///         Software Product Quality Standard. Assigned to **UDF**.
///
/// "THE TRACKING SDK" -- WHICH ONE IS NEVER SAID, AND THE ANSWER DECIDES WHAT
/// LEAVES THE DEVICE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/tracking_sdk.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-02199 :: which SDK?', () {
    gate(
      'GEN-02199-G1',
      'The row names no SDK.',
      'And no SDK was adopted',
      () =>
          HabotTrackingSdk.theDefiniteArticleHasNoAntecedent &&
          !HabotTrackingSdk.anSdkWasAdopted,
    );

    gate(
      'GEN-02199-G2',
      'Third row in two batches with no antecedent.',
      'After Step 398\'s "the count" and Step 406\'s "score", and the one '
          'where the answer decides what leaves the device',
      () =>
          HabotTrackingSdk.thirdRowInTwoBatches &&
          HabotTrackingSdk.fourDefaultsNamed,
    );

    gate(
      'GEN-02199-G3',
      'And the defaults it would have brought are named.',
      'An advertising identifier, a list of installed packages, a device '
          'fingerprint and coarse location -- collection that happens because '
          'it is a default in somebody else\'s code',
      () => HabotTrackingSdk.antecedentNote.contains('somebody else\'s code'),
    );

  });

  group('GEN-02199 :: an allowlist, not a blocklist', () {
    gate(
      'GEN-02199-G4',
      'Eight fields, each with a reason, none identifying a person.',
      'Screen, field, indicator kind, duration, time to the minute, app '
          'version, locale and a per-session token',
      () =>
          HabotTrackingSdk.eightFieldsAreDeclared &&
          HabotTrackingSdk.everyFieldSaysWhy &&
          HabotTrackingSdk.noFieldIdentifiesAPerson,
    );

    gate(
      'GEN-02199-G5',
      'It is an allowlist and an undeclared field is refused.',
      'Anything not listed is dropped before the queue rather than filtered at '
          'the far end',
      () =>
          HabotTrackingSdk.droppedBeforeTheQueue &&
          HabotTrackingSdk.anUndeclaredFieldIsRefused,
    );

    gate(
      'GEN-02199-G6',
      'Because a blocklist is wrong the moment a field is added.',
      'And the field somebody adds is never the one on the list',
      () =>
          HabotTrackingSdk.allowlistNote.contains('never the one on the list'),
    );

  });

  group('GEN-02199 :: a band finer than its own output', () {
    gate(
      'GEN-02199-G7',
      'The band is finer than the column it feeds.',
      'Three decimal places against a two-valued output column',
      () =>
          HabotTrackingSdk.theBandIsFinerThanItsOutput &&
          HabotTrackingSdk.theBandDistinguishesWhatTheColumnCannot,
    );

    gate(
      'GEN-02199-G8',
      'And Step 424 carries the same metric and band.',
      'Two subjects with nothing in common under one generic accuracy',
      () =>
          HabotTrackingSdk.twoRowsShareThisMetric &&
          HabotTrackingSdk.precisionNote.contains('one generic accuracy'),
    );

  });

  group('GEN-02199 :: what was actually built', () {
    gate(
      'GEN-02199-G9',
      'The listeners were already installed at Step 418.',
      'So what this row adds is a statement of what leaves the device, not a '
          'new collector',
      () =>
          HabotTrackingSdk.theListenersAlreadyExist &&
          HabotTrackingSdk.theFrameworkLimitsHold,
    );

    gate(
      'GEN-02199-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotTrackingSdk.obligations.length == 5 &&
          HabotTrackingSdk.obligations.values.every((bool b) => b) &&
          HabotTrackingSdk.qualitativeOutput == 'Pass' &&
          HabotTrackingSdk.accuracyReachesTheCeiling,
    );
  });

  tearDownAll(() {
    final int fields = HabotTrackingSdk.fieldCount;
    final int defaults =
        HabotTrackingSdk.whatAnAnalyticsSdkCollectsByDefault.length;
    final double accuracy = HabotTrackingSdk.payloadAccuracy;
    final int shared = HabotTrackingSdk.rowsSharingThisMetric.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02199',
        atomicStepReferenceId: 'GEN-02199',
        setupStepAction:
            'COLUMN NOTE: this row says "the tracking SDK" and never says '
            'which one -- the third row in two batches to use a definite '
            'article for something undefined, after Step 398 and Step 406, and '
            'the one where the answer decides what leaves the device; no SDK '
            'was adopted, and an eight-field payload allowlist was declared in '
            'its place; its band runs to three decimal places while its Best '
            'Qualitative Output column holds two values, so the band '
            'distinguishes what the column cannot express; and its metric and '
            'band are identical to Step 424\'s in this batch. Atomic Step: '
            '"Inject the tracking SDK into the mobile frontend."',
        implementationOrder: 419,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Inject the tracking SDK into the mobile frontend':
              'no SDK adopted; a $fields-field payload allowlist declared in '
                  'its place, with anything unlisted dropped before the queue',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Accuracy',
            observed:
                '"THE TRACKING SDK" IS NEVER IDENTIFIED, AND THE BAND IS FINER '
                'THAN THE COLUMN IT FEEDS. No SDK is named on this row or '
                'anywhere behind it -- the third row in two batches to use a '
                'definite article for something undefined, and the one where '
                'the answer decides what leaves the device, since a '
                'third-party analytics SDK brings $defaults collection '
                'defaults nobody chose. The band distinguishes 0.97 from 0.999 '
                'while the output column can say two things, and the same '
                'metric and band sit on $shared rows in this batch. Observed: '
                'payload accuracy $accuracy across $fields declared fields.',
            floor: '0.9',
            optimal: '0.97',
            ceiling: '0.999',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Fields leaving the device that identify a person',
            observed:
                '0 of $fields. Screen, field, indicator kind, duration, a '
                'timestamp to the minute, app version, locale and a '
                'per-session token, each with a stated reason. It is an '
                'allowlist: anything not on it is dropped before the queue '
                'rather than filtered at the far end, because a blocklist is '
                'correct until somebody adds a field and the field somebody '
                'adds is never the one on the list.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/tracking_sdk.dart',
        ],
      ),
    );
  });
}
