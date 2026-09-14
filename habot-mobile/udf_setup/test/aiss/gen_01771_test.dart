/// AISS GATE -- Step 223 of 235
/// Global Reference ID:       GEN-01771
/// Atomic Steps Reference ID: GEN-01771
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Enforce a strict portrait orientation lock on the layout."
/// Metric: Step Completion Rate (%) -- Floor 90, Optimal 99, Ceiling 100.
///         Complete/Partial/Not Complete.
///
/// REPORTS NOT COMPLETE. The lock is applied nowhere, because applying it
/// fails WCAG 2.1 SC 1.3.4, makes the app unusable on a mounted device, and
/// makes the expanded layouts three other rows in this same batch build
/// unreachable on a tablet. A step that reported Complete here would be
/// recording a conformance failure as a success.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/orientation_policy.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';
import 'package:udf_setup/design_system/layout/window_size_class.dart';

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

  void deferredGate(String id, String source, String description, String why) {
    test('[$id] (DEFERRED) $description', () {
      gates.add(
        AissGate(
          id: id,
          requirementSource: source,
          description: description,
          passed: false,
          deferred: true,
          detail: why,
        ),
      );
      expect(why.isNotEmpty, isTrue);
    });
  }

  group('GEN-01771 :: why the lock is not applied', () {
    gate(
      'GEN-01771-G1',
      'WCAG 2.1 SC 1.3.4 Orientation (AA): "content does not restrict its view '
          'and operation to a single display orientation ... unless a specific '
          'display orientation is essential."',
      'The criterion is cited with its text and its level, and the refusal '
          'rests on the criterion\'s own test -- whether the orientation is '
          'essential -- rather than on a preference',
      () =>
          HabotOrientationPolicy.wcagCriterion.contains('1.3.4') &&
          HabotOrientationPolicy.wcagCriterion.contains('AA') &&
          HabotOrientationPolicy.wcagText.contains('essential') &&
          HabotOrientationPolicy.refusalReasons.first.contains('1.3.4'),
    );

    gate(
      'GEN-01771-G2',
      '"A device fixed in a wheelchair, bed or vehicle mount cannot rotate."',
      'The second reason is about a person rather than a specification: a lock '
          'makes the app unusable for someone whose device is in a fixed '
          'mount, and changes nothing for anyone else',
      () =>
          HabotOrientationPolicy.refusalReasons.length == 4 &&
          HabotOrientationPolicy.refusalReasons[1].contains('wheelchair') &&
          HabotOrientationPolicy.refusalReasons[1]
              .contains('changes nothing for anyone else'),
    );

    gate(
      'GEN-01771-G3',
      'Steps 218, 219 and 221 in this same batch build expanded-class '
          'layouts.',
      'A tablet is Medium in portrait and Expanded in landscape, so a portrait '
          'lock makes those layouts unreachable on the hardware they were '
          'built for -- demonstrated on the iPad Mini\'s own two widths rather '
          'than argued',
      () =>
          HabotOrientationPolicy.lockWouldHideExpandedLayouts(
            portraitWidthDp: 744,
            landscapeWidthDp: 1133,
          ) &&
          HabotWindowSizeClass.classOf(744) ==
              HabotMd3WindowClass.medium &&
          HabotWindowSizeClass.classOf(1133) ==
              HabotMd3WindowClass.expanded &&
          HabotPaneSplit.presentationFor(HabotPaneRelation.supporting, 1133) ==
              HabotPanePresentation.sideBySide,
    );

    gate(
      'GEN-01771-G4',
      '"Both platforms let a user force rotation from system settings."',
      'A lock is a request the platform may refuse, so it does not even '
          'deliver the determinism that would be its only argument -- which is '
          'the fourth reason and the one that makes the other three not merely '
          'principled',
      () =>
          HabotOrientationPolicy.platformHonoursUserRotationOverride &&
          HabotOrientationPolicy.refusalReasons[3].contains('determinism'),
    );
  });

  group('GEN-01771 :: what is built instead', () {
    gate(
      'GEN-01771-G5',
      '"Never restrict an orientation" is as unexamined as "lock '
          'everything".',
      'Two screens with a legitimate orientation opinion are named, both as '
          'preferences rather than locks, and each argues essentiality in '
          'WCAG\'s own terms',
      () =>
          HabotOrientationPolicy.exceptions.length == 2 &&
          HabotOrientationPolicy.everyExceptionIsAPreference &&
          HabotOrientationPolicy.everyExceptionArguesEssentiality &&
          HabotOrientationPolicy.lockedScreens.isEmpty &&
          HabotOrientationPolicy.exceptions.first.screen ==
              'signature capture' &&
          HabotOrientationPolicy.exceptions.first.orientation == 'landscape' &&
          HabotOrientationPolicy.neverLockAnythingIsAlsoUnexaminedNote
              .contains('preference and a lock'),
    );

    gate(
      'GEN-01771-G6',
      'A policy that is a comment is a policy somebody changes without '
          'noticing.',
      'The default rule is a declared value and "no screen locks" is a '
          'constant, so introducing a lock means changing a declaration rather '
          'than adding a line to a manifest',
      () =>
          HabotOrientationPolicy.defaultRule == HabotOrientationRule.free &&
          !HabotOrientationPolicy.anyScreenLocks &&
          HabotOrientationRule.values.length == 3 &&
          HabotOrientationRule.values.contains(HabotOrientationRule.locked),
    );

    gate(
      'GEN-01771-G7',
      'Metric: Step Completion Rate (%) -- floor 90, optimal 99. '
          'Complete/Partial/Not Complete.',
      'Six of the seven checks hold, giving 85.7 -- below the floor -- and the '
          'one that does not is the row\'s own instruction. Reported NOT '
          'COMPLETE rather than rounded into a Partial, because the gap is the '
          'requirement itself',
      () {
        completion = HabotOrientationPolicy.completionRate;
        return HabotOrientationPolicy.completionChecks.length == 7 &&
            HabotOrientationPolicy.completionChecks.values
                    .where((bool b) => b)
                    .length ==
                6 &&
            !HabotOrientationPolicy.completionChecks[
                'a strict portrait orientation lock is enforced']! &&
            (completion - 600 / 7).abs() < 1e-9 &&
            completion < HabotOrientationPolicy.floor &&
            HabotOrientationPolicy.qualitativeOutput == 'Not Complete' &&
            HabotOrientationPolicy.declinedNote
                .contains('recording a conformance failure as a success') &&
            HabotOrientationPolicy.columnNote.contains('EMPTY');
      },
    );

    deferredGate(
      'GEN-01771-G8',
      'Atomic Step: "Enforce a strict portrait orientation lock on the '
          'layout."',
      'A global portrait orientation lock is applied',
      'DECLINED RATHER THAN OUTSTANDING. Applying the lock fails WCAG 2.1 SC '
          '1.3.4 Orientation at Level AA; makes the app unusable for someone '
          'whose device is in a fixed wheelchair, bed or vehicle mount, and '
          'changes nothing for anyone else; makes the expanded-class layouts '
          'built at Steps 218, 219 and 221 unreachable on a tablet, which is '
          'demonstrated on the iPad Mini\'s 744dp portrait and 1133dp '
          'landscape widths; and does not deliver determinism anyway, because '
          'both platforms honour a user\'s forced-rotation setting over the '
          'app\'s preference. If the row is genuinely required, it needs an '
          'essentiality argument in WCAG\'s own terms, and booking a session '
          'for a child does not have one.',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01771',
        atomicStepReferenceId: 'GEN-01771',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Enforce a strict portrait orientation lock on the layout."',
        implementationOrder: 223,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotOrientationPolicy',
          'Component Properties':
              'Default rule free everywhere; '
              '${HabotOrientationPolicy.exceptions.length} screens with a '
              'declared orientation PREFERENCE and '
              '${HabotOrientationPolicy.lockedScreens.length} with a lock; '
              '${HabotOrientationPolicy.refusalReasons.length} recorded '
              'reasons for the refusal; WCAG criterion cited with its text',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'REPORTS NOT COMPLETE, AND THE LOCK IS APPLIED NOWHERE. Four '
              'reasons. (1) WCAG 2.1 SC 1.3.4 Orientation, Level AA: content '
              'must not restrict operation to a single orientation unless that '
              'orientation is essential, and booking a session for a child is '
              'not essential-orientation. (2) A device fixed in a wheelchair, '
              'bed or vehicle mount is in one orientation permanently and '
              'frequently landscape; a portrait lock makes the app unusable '
              'for that person and changes nothing for anyone else. (3) It '
              'contradicts three rows in this same batch -- Steps 218, 219 and '
              '221 build expanded-class layouts, and a tablet is Medium in '
              'portrait and Expanded in landscape, so a portrait lock makes '
              'them unreachable on the hardware they were built for. '
              'Demonstrated on the iPad Mini at 744dp and 1133dp. (4) Both '
              'platforms honour a user\'s forced-rotation setting over the '
              'app\'s preference, so the lock does not deliver the '
              'determinism that would be its only argument. WHAT IS BUILT: the '
              'policy, the citation, and two screens where an orientation '
              'PREFERENCE is legitimate -- a signature capture and the QR pass '
              '-- because "never restrict anything" is as unexamined as "lock '
              'everything". ONE DEFERRED GATE, marked declined rather than '
              'outstanding.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '${completion.toStringAsFixed(1)} -- six of seven checks. The '
                'one that fails is the row\'s own instruction, and meeting it '
                'would fail an accessibility criterion this product is '
                'audited against. Below the floor of 90 and reported NOT '
                'COMPLETE rather than rounded into a Partial.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Screens with an orientation lock',
            observed:
                '0 of the whole product. Two screens declare a PREFERENCE -- '
                'landscape for signature capture, portrait for the QR pass -- '
                'each with an essentiality argument in WCAG\'s own terms, and '
                'a preference is a hint the system may ignore and the user may '
                'override.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/orientation_policy.dart',
        ],
      ),
    );
  });
}
