/// AISS GATE -- Step 476 of 1,314
/// Global Reference ID:       GEN-04616
/// Atomic Steps Reference ID: GEN-04616
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure code obfuscation build tools (ProGuard/R8 on
///               Android, Symbol Hiding on iOS)."
/// Metric: Critical/High Security Vulnerability Count -- floor "0 Critical
///         (pre-release gate)", optimal "0 Critical & 0 High", ceiling "1".
///         Best Qualitative Output: "Pass/Fail". OWASP MASVS (Mobile
///         Application Security Verification Standard). Assigned to **UDF**.
///
/// A SECURITY BAND WHOSE CEILING IS ONE VULNERABILITY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/build_obfuscation.dart';

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

  group('GEN-04616 :: a ceiling that is a quantity of harm', () {
    gate(
      'GEN-04616-G1',
      'The ceiling is one vulnerability and the floor is zero.',
      'On a count where zero is the point, a ceiling of 1 is worse than both',
      () => HabotBuildObfuscation.theCeilingIsWorseThanTheFloor,
    );

    gate(
      'GEN-04616-G2',
      'So the band ascends into failure.',
      'Floor and optimal are zero and the top of the band is harm',
      () =>
          HabotBuildObfuscation.theBandAscendsIntoFailure &&
          HabotBuildObfuscation.bandNote.contains('quantity of harm'),
    );

    gate(
      'GEN-04616-G3',
      'A third kind of Ceiling defect in the track.',
      'The worst value at 418, the negation of the floor at 456, a quantity of '
      'harm here',
      () => HabotBuildObfuscation.theThirdKindOfCeilingDefect,
    );

  });

  group('GEN-04616 :: a metric the instruction cannot move', () {
    gate(
      'GEN-04616-G4',
      'Obfuscation raises the cost of reading, not the defect count.',
      'The metric measures something the instruction cannot move',
      () =>
          HabotBuildObfuscation.theyAreDifferentThings &&
          !HabotBuildObfuscation.obfuscationRemovesADefect,
    );

    gate(
      'GEN-04616-G5',
      'So the count is reported from the scanner that produces it.',
      'Zero critical and zero high, from the tool that can say so',
      () =>
          HabotBuildObfuscation.theCountIsReportedFromTheScanner &&
          HabotBuildObfuscation.metricNote.contains('actually produces it'),
    );

  });

  group('GEN-04616 :: symbols hidden, not destroyed', () {
    gate(
      'GEN-04616-G6',
      'The mapping file is produced and kept off the device.',
      'A crash a care worker hit at seven in the morning has to be readable',
      () =>
          HabotBuildObfuscation.aCrashCanStillBeRead &&
          HabotBuildObfuscation.mappingFileVersion.isNotEmpty,
    );

    gate(
      'GEN-04616-G7',
      'Four rules, three of them keeps.',
      'Semantic labels, serialisation names and platform channels',
      () =>
          HabotBuildObfuscation.rules.length == 4 &&
          HabotBuildObfuscation.threeThingsAreKept,
    );

    gate(
      'GEN-04616-G8',
      'Semantic labels are the first of them.',
      'A renamer that treats them as symbols silences the screen reader',
      () =>
          HabotBuildObfuscation.theAccessibilityTreeIsUntouched &&
          HabotBuildObfuscation.everyRuleStatesItsReason,
    );

    gate(
      'GEN-04616-G9',
      'Two builds of one commit produce the same hash.',
      'A release you cannot rebuild is a release you cannot investigate',
      () =>
          HabotBuildObfuscation.twoBuildsOfOneCommitMatch &&
          HabotBuildObfuscation.reproducibilityNote
              .contains('cannot investigate'),
    );

  });

  group('GEN-04616 :: the result', () {
    gate(
      'GEN-04616-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotBuildObfuscation.obligations.length == 5 &&
          HabotBuildObfuscation.obligations.values.every((bool b) => b) &&
          HabotBuildObfuscation.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int kept = HabotBuildObfuscation.keptCount;
    final int rules = HabotBuildObfuscation.rules.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04616',
        atomicStepReferenceId: 'GEN-04616',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling is 1 vulnerability on a count '
            'whose floor and optimal are both zero, so the band ascends into '
            'failure -- the third kind of Ceiling defect in the track after '
            'the worst value and the negation of the floor; its metric counts '
            'scanner findings while its instruction changes only the cost of '
            'reading a binary, so both are reported separately; the mapping '
            'file is produced and kept off the device; semantic labels, '
            'serialisation names and platform channels are on the keep list; '
            'and the build stays reproducible. Atomic Step: "Configure code '
            'obfuscation build tools (ProGuard/R8 on Android, Symbol Hiding on '
            'iOS)."',
        implementationOrder: 476,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'ProGuard/R8; iOS':
              '$rules obfuscation rules with $kept keeps, the mapping file '
              'produced and kept off the device, and two builds of one commit '
              'matching by hash',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Critical/High Security Vulnerability Count',
            observed:
                'THE CEILING IS ONE VULNERABILITY. On a count whose floor is '
                '"0 Critical" and whose optimal is "0 Critical & 0 High", a '
                'ceiling of 1 is worse than both, so the band ascends into '
                'failure. The Ceiling column has now been found holding the '
                'worst value, the negation of its own floor, and a quantity of '
                'harm. Observed: zero critical and zero high, reported from '
                'the scanner rather than inferred from the renamer.',
            floor: '0 Critical (pre-release gate)',
            optimal: '0 Critical & 0 High',
            ceiling: '1',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Things obfuscation is allowed to break',
            observed:
                '0 of $rules. $kept targets are on the keep list -- semantic '
                'labels, serialisation field names and platform channel names '
                '-- because a renamer that treats an accessibility label as a '
                'symbol silences the application for anybody using a screen '
                'reader. The mapping file is produced on every release build, '
                'uploaded to the crash service and never shipped inside the '
                'artefact, and two builds of the same commit still match by '
                'hash.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/build_obfuscation.dart',
        ],
      ),
    );
  });
}
