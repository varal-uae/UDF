/// AISS GATE -- Step 87 of 95
/// Global Reference ID:       SSELC-016
/// Atomic Steps Reference ID: SSELC-016-A01
/// Setup Step (Action):       "Design the Universal Split-Screen Byt Isolation
///                             Interface"
/// Setup Step Description:    "Design adaptive grid templates displaying
///                             EVIDENCE WINDOWS ABOVE INPUT FIELDS on compact
///                             views."
/// Data Requirement:          "Stack visual layout components vertically when
///                             viewport boundaries shift BELOW 600DP metrics."
/// Metric: Design System Token Adoption Rate -- Floor 0.85, Optimal 0.97,
///         Ceiling 1.0.
///
/// CONTAMINATED ROW, RECORDED: ten columns describe signed-URL generation for
/// cloud storage -- Why This Matters ("Persistent or long-lived asset
/// hyperlinks invite link interception attacks"), What Must Be Standardized
/// ("Hardcode a maximum 10-minute validity boundary directly into secure link
/// generator settings"), Expected Output ("A confirmed cloud storage signature
/// configuration contract"), Completion Measures ("Security simulation checks
/// verify links block file downloading requests"), Poka-Yoke ("Link generation
/// operations fail automatically if incoming configuration files omit unique
/// trace ID strings"), Self-Chasing, UX Translation, Dashboard Implication,
/// Atomic Reusability and Common Library. None are gated.
///
/// The Setup Step and its Description ARE the requirement, and they describe
/// the Contextual Mirror from Steps 36-38 exactly. So this step configures
/// `HabotSplitView` -- and G1 proves there is still only one split container
/// under `lib/`, the same shape of proof the last batch used for the snackbar.
///
/// ON THE METRIC: Design System Token Adoption Rate is measurable, and the
/// instrument already exists -- LSAV-027 (Step 53) built the audit. It is run
/// here over the MTO layer's own files rather than widening Step 53's number.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/widget_token_audit.dart';
import 'package:udf_setup/design_system/mto/task_chassis.dart';
import 'package:udf_setup/design_system/shell/contextual_mirror.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  HabotTokenAuditResult? audit;

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

  group('SSELC-016-A01 :: one split container', () {
    test('[SSELC-016-G1] the MTO layer configures the existing split view '
        'rather than adding a second one', () {
      final RegExp splitClass = RegExp(r'class\s+(\w*Split\w*)\s+extends\s+(\w+)');
      final List<String> containers = <String>[];
      for (final File file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))) {
        for (final RegExpMatch match in splitClass.allMatches(
          file.readAsStringSync(),
        )) {
          final String name = match.group(1)!;
          final String base = match.group(2)!;
          if (name.endsWith('State') || base == 'State') {
            continue;
          }
          containers.add('${file.path}: $name');
        }
      }
      expect(
        containers.length,
        1,
        reason:
            'a second split container would be a second set of pane rules. '
            'Found: ${containers.join(", ")}',
      );
      expect(containers.single, contains('adaptive_panes.dart'));

      final String chassis = File(
        'lib/design_system/mto/task_chassis.dart',
      ).readAsStringSync();
      expect(
        chassis.contains('HabotSplitView('),
        isTrue,
        reason: 'the chassis must consume the Step 37 container',
      );

      gates.add(
        AissGate(
          id: 'SSELC-016-G1',
          requirementSource:
              'Setup Step (Action): "Design the UNIVERSAL Split-Screen Byt '
              'Isolation Interface" -- read against GEN-03270 (Step 37), '
              'which already built the split container and gated it on 18 '
              'viewports.',
          description:
              'Exactly one split container class exists under lib/, and the '
              'task chassis configures it -- so the evidence/action geometry '
              'is decided in one place for the whole app',
          passed: true,
          detail: 'sole container: ${containers.single}',
        ),
      );
    });

    gate(
      'SSELC-016-G2',
      'Data Requirement: "Stack visual layout components vertically when '
          'viewport boundaries shift BELOW 600DP metrics."',
      'The stacking threshold IS the Step 7 medium breakpoint rather than a '
          'second 600, and the arrangement below it is a vertical stack while '
          'a wider window is side by side',
      () =>
          HabotTaskChassis.stackBelow == HabotGrid.breakpointMedium &&
          HabotTaskChassis.stackBelow == 600 &&
          HabotTaskChassis.stacksAt(360) &&
          HabotTaskChassis.stacksAt(599) &&
          !HabotTaskChassis.stacksAt(600) &&
          HabotTaskChassis.arrangementFor(840) ==
              HabotMirrorArrangement.sideBySide,
    );

    gate(
      'SSELC-016-G3',
      'Setup Step Description: "displaying EVIDENCE WINDOWS ABOVE INPUT '
          'FIELDS on compact views." The order is the requirement -- an input '
          'above the evidence it is about would be a different screen.',
      'In the stacked arrangement the evidence pane leads, which is the same '
          'pane order the Step 36 blueprint declares, so the two cannot '
          'disagree',
      () {
        final HabotMirrorLayout layout = ContextualMirrorSpec.resolve(
          width: 360,
          height: 800,
        );
        return layout.arrangement == HabotMirrorArrangement.stacked &&
            HabotPaneRole.values.first == HabotPaneRole.evidence &&
            layout.evidenceExtent > 0 &&
            layout.actionExtent > 0;
      },
    );

    test('[SSELC-016-G4] design-token adoption in the MTO layer, measured',
        () {
      audit = HabotWidgetTokenAudit.run(
        directories: <String>['lib/design_system/mto'],
      );
      final HabotTokenAuditResult result = audit!;
      expect(
        result.adherence,
        greaterThanOrEqualTo(HabotWidgetTokenAudit.floorAdherence),
        reason: 'floor 0.70 in the audit, 0.85 in this row',
      );
      expect(
        result.adherence,
        greaterThanOrEqualTo(0.97),
        reason: 'the row asks for 0.97 as its optimal',
      );
      expect(
        result.offenders,
        isEmpty,
        reason: 'any literal found is named: ${result.offenders.join(", ")}',
      );

      gates.add(
        AissGate(
          id: 'SSELC-016-G4',
          requirementSource:
              'Metric: Design System Token Adoption Rate -- Floor 0.85, '
              'Optimal 0.97, Ceiling 1.0. Instrument reused from LSAV-027 '
              '(Step 53).',
          description:
              'Every styled property in the MTO layer is measured against the '
              'token sources, and any literal that is not token-sourced is '
              'named rather than counted silently',
          passed: true,
          detail:
              '${result.tokenSourced} of ${result.styledProperties} styled '
              'properties token-sourced '
              '(${(result.adherence * 100).toStringAsFixed(1)}%)',
        ),
      );
    });
  });

  tearDownAll(() {
    final HabotTokenAuditResult? result = audit;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SSELC-016',
        atomicStepReferenceId: 'SSELC-016-A01',
        setupStepAction: 'Design the Universal Split-Screen Byt Isolation '
            'Interface',
        implementationOrder: 87,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Template Name': 'HabotTaskChassis',
          'Template Version':
              'a configuration of HabotSplitView (Step 37), not a second '
              'container',
          'Template Type':
              'evidence above action when stacked; side by side at '
              '${HabotGrid.breakpointMedium.toStringAsFixed(0)}dp and above',
          'Template Configuration':
              'no header, footer or floating action parameter exists on the '
              'chassis -- see GEN-00610 (Step 88)',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED ROW -- ten columns describe signed cloud-storage '
              'URLs (Expected Output "a confirmed cloud storage signature '
              'configuration contract", Poka-Yoke about trace ID strings, '
              'What Must Be Standardized about a 10-minute link validity). '
              'Not gated. The Setup Step and its Description are coherent and '
              'describe the Contextual Mirror from Steps 36-38, which is what '
              'this step configures.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Design System Token Adoption Rate',
            observed: result == null
                ? 'not measured'
                : '${result.adherence.toStringAsFixed(4)} -- '
                      '${result.tokenSourced} of ${result.styledProperties} '
                      'styled properties in lib/design_system/mto came from a '
                      'token, with ${result.offenders.length} literals found. '
                      'Measured with the LSAV-027 instrument over this '
                      'layer\'s own files, so Step 53\'s number is unchanged.',
            floor: '0.85',
            optimal: '0.97',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_chassis.dart',
        ],
      ),
    );
  });
}
