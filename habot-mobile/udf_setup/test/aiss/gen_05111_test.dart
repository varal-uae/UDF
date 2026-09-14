/// AISS GATE -- Step 191 of 195
/// Global Reference ID:       GEN-05111
/// Atomic Steps Reference ID: GEN-05111
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Surface
///               Container color tokens for background navigation shell."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// "SURFACE CONTAINER" IS A LADDER OF FIVE RUNGS, NOT A COLOUR. And measuring
/// the shell's own pairs found a hole in the Step 4 audit: onSurfaceVariant on
/// surfaceContainer is what every navigation label in the product renders as,
/// and it is gated nowhere.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/a11y/contrast_audit.dart';
import 'package:udf_setup/design_system/shell/surface_container_shell.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/elevation_tokens.dart';
import 'package:udf_setup/design_system/tokens/m3_naming.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double navLabelLight = 0;
  double navLabelDark = 0;

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

  group('GEN-05111 :: the rung, not the colour', () {
    gate(
      'GEN-05111-G1',
      'Atomic Step: "M3 Surface Container color tokens for background '
          'navigation shell." MD3 specifies five container rungs.',
      'The navigation shell is assigned a specific rung rather than "a surface '
          'container", the ladder is declared as an ordering because the '
          'ordering is the meaning, and the rung converts to a conformant MD3 '
          'token name',
      () =>
          HabotSurfaceContainerShell.ladder.length == 5 &&
          HabotSurfaceContainerShell.navigationShell.rung ==
              'surfaceContainer' &&
          HabotSurfaceContainerShell.rungIndex('surfaceContainer') == 2 &&
          HabotSurfaceContainerShell.rungIndex('surfaceContainerLowest') == 0 &&
          HabotSurfaceContainerShell.rungIndex('surfaceContainerHighest') ==
              4 &&
          HabotM3Naming.isConformant(
            HabotSurfaceContainerShell.navigationShell.rungToken,
          ) &&
          HabotSurfaceContainerShell.navigationShell.rungToken ==
              'md.sys.color.surface-container' &&
          HabotSurfaceContainerShell.ladderNotColourNote
              .contains('decided differently on each one'),
    );

    gate(
      'GEN-05111-G2',
      '"Put the shell on surfaceContainerHigh and it floats above the content '
          'it frames; put it on the lowest and the content appears to sit on '
          'top of the navigation."',
      'Every shell surface declares its rung, and the depth ordering between '
          'them is consistent: a sheet sits below the navigation shell, which '
          'sits below a dialog',
      () =>
          HabotSurfaceContainerShell.surfaces.length == 5 &&
          HabotSurfaceContainerShell.ladderIsConsistent &&
          HabotSurfaceContainerShell.surfaces.every(
            (HabotShellSurface s) =>
                HabotSurfaceContainerShell.ladder.contains(s.rung) &&
                s.contentRole.isNotEmpty &&
                s.rationale.length > 40,
          ) &&
          HabotSurfaceContainerShell.byName('bottomSheet').rung ==
              'surfaceContainerLow' &&
          HabotSurfaceContainerShell.byName('dialog').rung ==
              'surfaceContainerHigh' &&
          // The rail and the bar share a rung: the same surface in a different
          // orientation should not look like a different product on a tablet.
          HabotSurfaceContainerShell.byName('navigationRail').rung ==
              HabotSurfaceContainerShell.byName('navigationBar').rung,
    );

    gate(
      'GEN-05111-G3',
      '"MD3 expresses depth in dark schemes as surface tint rather than as '
          'shadow." A shell whose rung and elevation disagree renders at one '
          'depth and casts the shadow of another.',
      'Each surface declares an elevation level alongside its rung, and the '
          'two move together across the whole set',
      () =>
          HabotSurfaceContainerShell.elevationAgreesWithRung &&
          HabotSurfaceContainerShell.byName('bottomSheet').elevation ==
              HabotElevationLevel.level1 &&
          HabotSurfaceContainerShell.navigationShell.elevation ==
              HabotElevationLevel.level2 &&
          HabotSurfaceContainerShell.byName('dialog').elevation ==
              HabotElevationLevel.level3 &&
          HabotSurfaceContainerShell.darkElevationNote
              .contains('darkSurfaceLadder'),
    );
  });

  group('GEN-05111 :: the hole in the audit', () {
    gate(
      'GEN-05111-G4',
      'The Step 4 contrast audit gates onSurface against every container rung, '
          'and onSurfaceVariant only against plain surface.',
      'The shell renders a pair the existing audit does not cover, and it is '
          'exactly one: onSurfaceVariant on surfaceContainer -- what every '
          'navigation label in the product is drawn as',
      () {
        final Set<String> covered = <String>{
          for (final AuditPair p in <AuditPair>[
            ...ContrastAudit.textPairs,
            ...ContrastAudit.nonTextPairs,
          ])
            '${p.foreground}/${p.background}',
        };
        return HabotSurfaceContainerShell.missingAuditPairs.length == 1 &&
            HabotSurfaceContainerShell.missingAuditPairs.single ==
                'onSurfaceVariant/surfaceContainer' &&
            !covered.contains('onSurfaceVariant/surfaceContainer') &&
            covered.contains('onSurfaceVariant/surface') &&
            covered.contains('onSurface/surfaceContainer') &&
            HabotSurfaceContainerShell.auditGapNote
                .contains('audited nowhere');
      },
    );

    gate(
      'GEN-05111-G5',
      'A gap in a gate is worth measuring before it is worth worrying about.',
      'The previously unaudited navigation-label pair is measured in both '
          'schemes and clears the AAA threshold in each -- so the gap was a '
          'hole in the gate rather than a defect in the palette, which is the '
          'honest finding and a different piece of work',
      () {
        final List<ContrastResult> light =
            HabotSurfaceContainerShell.auditShellPairs(
          'light',
          HabotColors.light,
        );
        final List<ContrastResult> dark =
            HabotSurfaceContainerShell.auditShellPairs(
          'dark',
          HabotColors.dark,
        );
        final ContrastResult lightNav = light.firstWhere(
          (ContrastResult r) =>
              r.foregroundName.endsWith('onSurfaceVariant') &&
              r.backgroundName.endsWith('surfaceContainer'),
        );
        final ContrastResult darkNav = dark.firstWhere(
          (ContrastResult r) =>
              r.foregroundName.endsWith('onSurfaceVariant') &&
              r.backgroundName.endsWith('surfaceContainer'),
        );
        navLabelLight = lightNav.ratio;
        navLabelDark = darkNav.ratio;
        return HabotSurfaceContainerShell.shellFailures().isEmpty &&
            lightNav.passes &&
            darkNav.passes &&
            lightNav.grade == ContrastGrade.aaa &&
            darkNav.grade == ContrastGrade.aaa &&
            navLabelLight > 8 &&
            navLabelDark > 9 &&
            light.length == HabotSurfaceContainerShell.surfaces.length;
      },
    );

    gate(
      'GEN-05111-G6',
      '"That gate is what every earlier step\'s evidence rests on."',
      'The gap is RAISED for the Step 4 pair set rather than quietly added to '
          'it, with the measurement attached so whoever changes that gate is '
          'not doing it blind',
      () =>
          HabotSurfaceContainerShell.auditGapRaised.length == 1 &&
          HabotSurfaceContainerShell.auditGapRaised.single
              .contains('rendered by the shell') &&
          HabotSurfaceContainerShell.auditGapRaised.single
              .contains('belongs in the Step 4 pair set') &&
          HabotSurfaceContainerShell.auditGapNote
              .contains('rather than quietly added to it'),
    );

    gate(
      'GEN-05111-G7',
      'Metric: UI Styling / Transition Compliance -- <=100ms, Pass / Fail.',
      'The shell background does not animate at all -- a theme change is not a '
          'transition the user is watching a single element through -- and '
          'every compliance condition holds',
      () =>
          HabotSurfaceContainerShell.transition == Duration.zero &&
          HabotSurfaceContainerShell.withinBudget(
            HabotSurfaceContainerShell.transition,
          ) &&
          !HabotSurfaceContainerShell.withinBudget(
            const Duration(milliseconds: 101),
          ) &&
          HabotSurfaceContainerShell.isCompliant &&
          HabotSurfaceContainerShell.complianceChecks.length == 7 &&
          HabotSurfaceContainerShell.complianceChecks.values
              .every((bool b) => b) &&
          HabotSurfaceContainerShell.qualitativeOutput == 'Pass' &&
          HabotSurfaceContainerShell.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05111',
        atomicStepReferenceId: 'GEN-05111',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement the mobile UI styling requirement: M3 Surface '
            'Container color tokens for background navigation shell."',
        implementationOrder: 191,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSurfaceContainerShell / HabotShellSurface',
          'Component Properties':
              '${HabotSurfaceContainerShell.surfaces.length} shell surfaces '
              'assigned rungs on the ${HabotSurfaceContainerShell.ladder.length}'
              '-rung MD3 container ladder, each with an elevation level and '
              'the role its content takes; navigation shell on '
              '${HabotSurfaceContainerShell.navigationShell.rung}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: "surface container" is a ladder of five rungs '
              'encoding depth, so assigning "a surface container token" '
              'without saying which rung is the same as not assigning one -- '
              'and neither the too-high nor the too-low choice looks broken on '
              'its own screen, which is why it gets decided differently on '
              'each. AUDIT GAP FOUND AND RAISED: the Step 4 audit gates '
              'onSurface against every container rung but onSurfaceVariant '
              'only against plain surface. Navigation labels are '
              'onSurfaceVariant on surfaceContainer -- the pair every '
              'navigation label in the product uses, audited nowhere. Measured '
              'here: it clears AAA in both schemes, so the gap was a hole in '
              'the gate rather than a defect in the palette. It is raised for '
              'the Step 4 pair set rather than added here, because that gate '
              'is what every earlier step\'s evidence rests on.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Styling / Transition Compliance',
            observed:
                'The shell background does not animate: a theme change is not '
                'a transition the user is watching a single element through. '
                'All ${HabotSurfaceContainerShell.complianceChecks.length} '
                'conditions hold, including the depth ordering between shell '
                'surfaces and the agreement between each surface\'s rung and '
                'its declared elevation level.',
            floor: '<=100ms transition duration; visual QA pass on target '
                'devices',
            optimal: '<=100ms transition, 100% visual QA pass',
            ceiling: '>100ms transitions read as sluggish; >0 visual QA '
                'defects',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Navigation label contrast (previously unaudited)',
            observed:
                '${navLabelLight.toStringAsFixed(2)}:1 in the light scheme and '
                '${navLabelDark.toStringAsFixed(2)}:1 in the dark, both AAA '
                'against a 4.5:1 text floor. This is onSurfaceVariant on '
                'surfaceContainer, which no pair in ContrastAudit covers and '
                'which every navigation label in the product renders as.',
            floor: '4.5:1',
            optimal: '7.0:1',
            ceiling: 'N/A',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/surface_container_shell.dart',
        ],
      ),
    );
  });
}
