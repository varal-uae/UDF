/// AISS GATE -- Step 187 of 195
/// Global Reference ID:       GEN-02852
/// Atomic Steps Reference ID: GEN-02852
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build native Material 3 Motion theme tokens for SwiftUI."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// **THIS STEP REPORTS PARTIAL.** There is no SwiftUI target in this
/// repository and nothing that could verify one consumed the tokens correctly.
/// Writing a Swift file into a Flutter repo that nothing compiles would pass
/// this gate and mean nothing. What is built is the export -- and the
/// interesting half of it is that durations port and curves do not.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/motion_export.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  group('GEN-02852 :: the export', () {
    gate(
      'GEN-02852-G1',
      'Atomic Step: "Build native Material 3 Motion theme tokens for '
          'SwiftUI." This product is one Flutter codebase.',
      'The requested target and its status are both recorded, so the '
          'substitution is visible rather than a Swift file appearing in a '
          'Flutter repository where nothing would compile it',
      () =>
          HabotMotionTokenExport.requestedTarget == 'SwiftUI' &&
          HabotMotionTokenExport.targetStatus
              .contains('No SwiftUI target exists') &&
          HabotMotionTokenExport.swiftUiSubstitution
              .contains('would pass this gate') &&
          HabotMotionTokenExport.columnNote.contains('EMPTY'),
    );

    gate(
      'GEN-02852-G2',
      '"A second platform that retypes 300ms is a second platform that will '
          'drift by 50ms within a release and nobody will be able to say '
          'when."',
      'Every exported duration is read from the motion token file rather than '
          'written again, so the export cannot disagree with the Flutter build '
          'it was derived from',
      () {
        final Map<String, int> byName = <String, int>{
          for (final HabotMotionExport e in HabotMotionTokenExport.all)
            e.name: e.durationMs,
        };
        return byName['stepperTransition'] ==
                HabotMotion.stepperTransition.inMilliseconds &&
            byName['sheet'] == HabotMotion.sheetEnter.inMilliseconds &&
            byName['sharedAxisIncoming'] ==
                HabotMotion.sharedAxis.inMilliseconds &&
            byName['sharedAxisOutgoing'] ==
                HabotMotion.sharedAxis.inMilliseconds &&
            byName['reducedMotion'] == 0 &&
            HabotMotionTokenExport.exportIsTheValueNote
                .contains('single declaration site');
      },
    );

    gate(
      'GEN-02852-G3',
      '"What all three CAN express is a cubic Bezier with four control '
          'points, so that is the portable form."',
      'Curves are exported as control points with a CSS spelling that SwiftUI '
          'timingCurve and Flutter Cubic both accept, rather than as a Flutter '
          'name no other platform has',
      () {
        final HabotMotionExport sheet = HabotMotionTokenExport.all
            .firstWhere((HabotMotionExport e) => e.name == 'sheet');
        return sheet.isPortable &&
            sheet.bezier!.points.length == 4 &&
            sheet.bezier!.cssForm.startsWith('cubic-bezier(') &&
            sheet.bezier!.cssForm.contains('0.400') &&
            sheet.curveName == 'fastOutSlowIn' &&
            HabotMotionTokenExport.curves.length == 8 &&
            HabotMotionTokenExport.curvesDoNotPortNote
                .contains('invisible in isolation');
      },
    );

    gate(
      'GEN-02852-G4',
      '"A curve that cannot be expressed that way is named as unportable '
          'rather than silently approximated."',
      'The emphasised MD3 easing is declared unportable with the reason -- it '
          'is a two-segment curve and a single cubic cannot express it -- and '
          'every unportable entry carries an explanation rather than a null',
      () {
        final HabotMotionExport stepper = HabotMotionTokenExport.all
            .firstWhere(
                (HabotMotionExport e) => e.name == 'stepperTransition');
        return !stepper.isPortable &&
            stepper.bezier == null &&
            stepper.unportableReason!.contains('TWO-SEGMENT') &&
            stepper.unportableReason!.contains('keyframe') &&
            HabotMotionTokenExport.unportable.length == 1 &&
            HabotMotionTokenExport.portable.length == 4 &&
            HabotMotionTokenExport.everyUnportableExplained &&
            HabotMotionTokenExport.curves['stepperEnter'] == null &&
            HabotMotionTokenExport.unportableCurves.length == 1;
      },
    );

    gate(
      'GEN-02852-G5',
      'An export nothing can read is not an export.',
      'The whole set serialises to a platform-neutral structure carrying the '
          'schema version, the source file, and for each token its duration, '
          'its Flutter curve name for traceability and its portable form',
      () {
        final Map<String, Object?> json = HabotMotionTokenExport.toJson();
        final List<Object?> tokens = json['tokens']! as List<Object?>;
        final Map<String, Object?> first =
            tokens.first! as Map<String, Object?>;
        return json['schema_version'] == '1.0.0' &&
            (json['source']! as String).endsWith('motion_tokens.dart') &&
            tokens.length == HabotMotionTokenExport.all.length &&
            first.containsKey('duration_ms') &&
            first.containsKey('curve_flutter') &&
            first.containsKey('curve_bezier') &&
            first.containsKey('curve_css') &&
            first.containsKey('unportable_reason');
      },
    );
  });

  group('GEN-02852 :: the metric, reported short', () {
    gate(
      'GEN-02852-G6',
      'Metric: Task Completion Status -- floor 0.8, optimal 1.',
      'Four of six checks hold, giving 0.667 -- below the row\'s own floor -- '
          'and the two that do not are named: there is no target to consume '
          'the export and nothing to verify it against',
      () {
        completion = HabotMotionTokenExport.completionStatus;
        return HabotMotionTokenExport.checks.length == 6 &&
            completion > 0.66 &&
            completion < 0.67 &&
            completion < HabotMotionTokenExport.floor &&
            HabotMotionTokenExport.qualitativeOutput == 'Partial' &&
            HabotMotionTokenExport.checks[
                    'a SwiftUI target exists to consume the export'] ==
                false &&
            HabotMotionTokenExport.checks[
                    'the export is verified against a second platform\'s '
                    'rendering'] ==
                false;
      },
    );

    gate(
      'GEN-02852-G7',
      '"Two platforms agreeing on 300ms is checkable; two platforms agreeing '
          'on what a curve LOOKS like needs both of them running."',
      'The outstanding work is named with why it cannot be done here rather '
          'than left as a gap, and the distinction between the two kinds of '
          'verification is part of the record',
      () =>
          HabotMotionTokenExport.outstanding.length == 2 &&
          HabotMotionTokenExport.outstanding.first
              .contains('nothing compiles') &&
          HabotMotionTokenExport.outstanding.last
              .contains('needs both of them running'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02852',
        atomicStepReferenceId: 'GEN-02852',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Build native Material 3 Motion theme tokens for SwiftUI."',
        implementationOrder: 187,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotMotionTokenExport / HabotCubicBezier',
          'Component Properties':
              '${HabotMotionTokenExport.all.length} exported tokens '
              '(${HabotMotionTokenExport.portable.length} with portable cubic '
              'Bezier curves, ${HabotMotionTokenExport.unportable.length} '
              'named unportable with a reason); schema version '
              '${HabotMotionTokenExport.schemaVersion}; durations read from '
              'motion_tokens.dart rather than restated',
          'Completion Status': 'Partial -- deliberately, see the note',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: SwiftUI is Apple\'s declarative UI '
              'framework and this product is one Flutter codebase with no '
              'SwiftUI target, no Xcode project to consume Swift motion '
              'tokens, and nothing that could verify consumption. Writing a '
              'Swift file nothing compiles would pass this gate and mean '
              'nothing. WHAT IS BUILT: the platform-neutral export. Durations '
              'port trivially; curves do not -- Flutter names '
              'easeInOutCubicEmphasized, SwiftUI has no such name, CSS has a '
              'third vocabulary -- so curves travel as cubic Bezier control '
              'points. The one curve that cannot be written as a single cubic '
              '(MD3 emphasised easing, a two-segment shape) is named as '
              'unportable rather than approximated: an approximated easing '
              'curve is obvious side by side and invisible in isolation.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                '${completion.toStringAsFixed(3)} -- 4 of '
                '${HabotMotionTokenExport.checks.length} checks. BELOW the '
                'row\'s floor of 0.8. The two that fail are a SwiftUI target '
                'to consume the export and verification against a second '
                'platform\'s rendering; neither exists and neither can be '
                'produced here.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Motion tokens exported in a portable form',
            observed:
                '${HabotMotionTokenExport.portable.length} of '
                '${HabotMotionTokenExport.all.length} carry cubic Bezier '
                'control points readable by SwiftUI timingCurve, CSS and '
                'Flutter alike. The remaining one is the MD3 emphasised '
                'easing, declared unportable with the reason and the shape a '
                'consumer would need instead.',
            floor: 'every portable curve exported as control points',
            optimal: 'every portable curve exported as control points',
            ceiling: 'every portable curve exported as control points',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/motion_export.dart',
        ],
      ),
    );
  });
}
