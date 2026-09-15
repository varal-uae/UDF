/// AISS GATE -- Step 268 of 275
/// Global Reference ID:       GEN-01595
/// Atomic Steps Reference ID: GEN-01595
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Test that PII masking rules intercept personal contact
///               strings."
/// Metric: In-App Message Delivery Latency -- Floor "<3s", Optimal "<500ms",
///         Ceiling "<5s". Good/Average/Poor.
///
/// THIS STEP REPORTS POOR. THE EXISTING SCRUBBER INTERCEPTS THREE OF ELEVEN
/// PERSONAL CONTACT STRINGS, AND TWO OF THOSE THREE ARE CAUGHT BY ACCIDENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/pii_intercept_audit.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rate = 0;

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

  group('GEN-01595 :: the measurement', () {
    gate(
      'GEN-01595-G1',
      'Atomic Step: "Test that PII masking rules intercept".',
      'Fifteen samples are put through the scrubber that actually ships -- '
          'eleven personal contact strings and four controls -- rather than a '
          'set chosen to make the filter look good',
      () =>
          HabotPiiInterceptAudit.corpus.length == 15 &&
          HabotPiiInterceptAudit.personalSamples.length == 11 &&
          HabotPiiInterceptAudit.controls.length == 4 &&
          HabotPiiInterceptAudit.corpus.every(
            (HabotContactSample s) => s.why.length > 40,
          ),
    );

    gate(
      'GEN-01595-G2',
      'A test that passes tells you nothing you did not assume.',
      'The measured intercept rate is three of eleven, and it is measured '
          'against the existing rule set rather than against the proposal '
          'this step also contains',
      () {
        rate = HabotPiiInterceptAudit.existingInterceptRate;
        return (rate - 3 / 11).abs() < 1e-9 &&
            HabotPiiInterceptAudit.interceptedByExistingSet.length == 3 &&
            HabotPiiInterceptAudit.missedByExistingSet.length == 8;
      },
    );

    gate(
      'GEN-01595-G3',
      'Coverage that happens by accident is not coverage.',
      'Two of the three interceptions are collateral from a rule written for '
          'something else, so the rate that is actually intended is one in '
          'eleven',
      () =>
          HabotPiiInterceptAudit.caughtOnlyByTheHexAccident.length == 2 &&
          HabotPiiInterceptAudit.mostOfTheCoverageIsAccidental &&
          HabotPiiInterceptAudit.accidentalCoverageNote.isNotEmpty,
    );

    gate(
      'GEN-01595-G4',
      'A filter that redacts everything passes the wrong test.',
      'The four controls -- strings that look like contact details and are '
          'not -- survive the existing rules untouched, so the rate above is '
          'not bought with false positives',
      () =>
          HabotPiiInterceptAudit.theExistingSetRedactsNoControls &&
          HabotPiiInterceptAudit.controlsNote.isNotEmpty,
    );
  });

  group('GEN-01595 :: the proposal, and its ceiling', () {
    gate(
      'GEN-01595-G5',
      'Naming a gap without saying what would close it is half a finding.',
      'Four rules are proposed and measured on the same corpus, reaching nine '
          'of eleven, and they are measured rather than asserted',
      () =>
          HabotPiiInterceptAudit.proposedRules.length == 4 &&
          HabotPiiInterceptAudit.interceptedByProposedSet.length == 9 &&
          HabotPiiInterceptAudit.proposedInterceptRate >
              HabotPiiInterceptAudit.existingInterceptRate,
    );

    gate(
      'GEN-01595-G6',
      'The proposal must not be bought with false positives either.',
      'The proposed rules leave all four controls untouched, which is the '
          'property that makes them worth adopting rather than merely '
          'broader',
      () => HabotPiiInterceptAudit.theProposalRedactsNoControls,
    );

    gate(
      'GEN-01595-G7',
      'The ceiling is not one, and saying so is the honest part.',
      'The two still missed are a personal name and a street address, neither '
          'of which any pattern can recognise -- so a 100% target on this row '
          'is unreachable by the method the row names',
      () =>
          HabotPiiInterceptAudit.stillMissed.length == 2 &&
          HabotPiiInterceptAudit.theCeilingIsNotOne &&
          HabotPiiInterceptAudit.ceilingNote.isNotEmpty,
    );

    gate(
      'GEN-01595-G8',
      'The proposal is not merged into the shipping filter.',
      'The rules are proposed and measured here rather than edited into the '
          'gated file of an earlier step, and the reason is recorded',
      () => HabotPiiInterceptAudit.notMergedNote.isNotEmpty,
    );

    gate(
      'GEN-01595-G9',
      'Metric: In-App Message Delivery Latency -- a different subject.',
      'The metric belongs to another row and is recorded as such; the step '
          'reports Poor against a target of 1, which is what the measurement '
          'actually supports, and all eleven declared checks hold',
      () =>
          HabotPiiInterceptAudit.metricMismatchNote.isNotEmpty &&
          HabotPiiInterceptAudit.target == 1 &&
          HabotPiiInterceptAudit.qualitativeOutput == 'Poor' &&
          HabotPiiInterceptAudit.checks.length == 11 &&
          HabotPiiInterceptAudit.checks.values.every((bool b) => b) &&
          HabotPiiInterceptAudit.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String existing =
        HabotPiiInterceptAudit.existingInterceptRate.toStringAsFixed(3);
    final String proposed =
        HabotPiiInterceptAudit.proposedInterceptRate.toStringAsFixed(3);
    final String caught =
        '${HabotPiiInterceptAudit.interceptedByExistingSet.length}';
    final String personal =
        '${HabotPiiInterceptAudit.personalSamples.length}';
    final String accident =
        '${HabotPiiInterceptAudit.caughtOnlyByTheHexAccident.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01595',
        atomicStepReferenceId: 'GEN-01595',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'metric belongs to a different subject. Atomic Step: "Test that '
            'PII masking rules intercept personal contact strings."',
        implementationOrder: 268,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotPiiInterceptAudit / HabotContactSample / '
                  'HabotProposedRule',
          'Component Properties':
              '${HabotPiiInterceptAudit.corpus.length} samples ($personal '
              'personal, ${HabotPiiInterceptAudit.controls.length} controls) '
              'measured against the shipping scrubber and against '
              '${HabotPiiInterceptAudit.proposedRules.length} proposed '
              'rules; $caught intercepted today of which $accident by '
              'collateral from a rule written for something else',
          'Completion Status': 'Derived from gate outcomes -- step reports '
              'Poor on a measured rate of $existing',
          'Data Quality Note':
              'FINDING: ${HabotPiiInterceptAudit.accidentalCoverageNote} '
              'CEILING: ${HabotPiiInterceptAudit.ceilingNote} '
              'NOT MERGED: ${HabotPiiInterceptAudit.notMergedNote} '
              'METRIC: ${HabotPiiInterceptAudit.metricMismatchNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Personal contact strings intercepted (existing set)',
            observed:
                '$caught of $personal ($existing). $accident of the $caught '
                'are caught by a rule written for something else, so the '
                'deliberate rate is one in $personal.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Personal contact strings intercepted (proposed set)',
            observed:
                '${HabotPiiInterceptAudit.interceptedByProposedSet.length} of '
                '$personal ($proposed), with no control redacted. The two '
                'still missed are a personal name and a street address, which '
                'no pattern recognises -- the ceiling here is not one.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'In-App Message Delivery Latency',
            observed:
                'NOT THIS ROW. The metric cell belongs to a messaging '
                'subject with an XMPP/WebSocket citation, while the Atomic '
                'Step is a test of PII masking. Recorded rather than '
                'answered with a latency nobody measured.',
            floor: '<3s',
            optimal: '<500ms',
            ceiling: '<5s',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/pii_intercept_audit.dart',
        ],
      ),
    );
  });
}
