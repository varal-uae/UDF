/// AISS GATE -- Step 182 of 195
/// Global Reference ID:       GEN-00599
/// Atomic Steps Reference ID: GEN-00599
/// Setup Step (Action): "Create a token rule enforcer middleware or
///                       interceptor for the mobile API gateway."
/// Atomic Step: "Bind font family Inter to Body typography tokens
///               (normal 400)."
/// Metric: Body Font Alignment -- Floor "Inter 400", Optimal "Inter 400",
///         Ceiling "Inter 400". Complete / Not Complete.
///
/// **THIS STEP REPORTS NOT COMPLETE.** The row asks for Inter; the body tokens
/// are bound to Roboto, declared at Step 3 as the platform-bundled Material
/// type face. Changing the family name without vendoring the font does not
/// produce Inter -- it produces a per-device platform fallback, and silently
/// invalidates every text-fit measurement this project has taken.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/body_font_binding.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

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

  group('GEN-00599 :: the conflict, recorded rather than resolved quietly', () {
    gate(
      'GEN-00599-G1',
      'Atomic Step: "Bind font family INTER to Body typography tokens." '
          'Step 3 bound them to Roboto and recorded it as platform-bundled.',
      'Both families are declared with what shipping each would require, so '
          'the conflict is visible in the code rather than resolved by editing '
          'one string and moving on',
      () =>
          HabotBodyFont.requested.name == 'Inter' &&
          HabotBodyFont.bound.name == 'Roboto' &&
          HabotBodyFont.bound.name == HabotTypography.fontName &&
          !HabotBodyFont.familyMatches &&
          HabotBodyFont.requested.isPlatformBundled == false &&
          HabotBodyFont.bound.isPlatformBundled &&
          HabotBodyFont.conflictNote.contains('direct conflict'),
    );

    gate(
      'GEN-00599-G2',
      '"Inter is not a platform font on Android or iOS. Setting the family '
          'name without shipping the files does not produce Inter."',
      'A family is only bindable when its glyphs will actually be present: '
          'the requested family is unavailable because nothing is vendored, '
          'and the bound one is available because the platform ships it',
      () =>
          !HabotBodyFont.canBind &&
          !HabotBodyFont.requested.isAvailable &&
          HabotBodyFont.requested.assetPath == null &&
          HabotBodyFont.bound.isAvailable &&
          HabotBodyFont.silentFallbackNote
              .contains('varies by device') &&
          HabotBodyFont.silentFallbackNote.contains('nothing would fail'),
    );

    gate(
      'GEN-00599-G3',
      '"Every one of those is a claim about how wide a string is in a specific '
          'type face."',
      'The measurements a family swap would invalidate are named with the '
          'steps that took them, so the cost of the swap is a list rather than '
          'a feeling',
      () =>
          HabotBodyFont.preconditions.length == 4 &&
          HabotBodyFont.preconditions.first.contains('pubspec.yaml') &&
          HabotBodyFont.preconditions.any((String p) => p.contains('102')) &&
          HabotBodyFont.preconditions.any((String p) => p.contains('144')) &&
          HabotBodyFont.preconditions.any((String p) => p.contains('167')) &&
          HabotBodyFont.invalidatedMeasurementsNote
              .contains('without failing anything'),
    );

    gate(
      'GEN-00599-G4',
      'The row says BODY. "A row about one part of the scale is not a licence '
          'to restyle the whole of it."',
      'Exactly the three body roles are in scope, all three already carry the '
          'weight the row specifies, and the twelve roles a family change '
          'would also move are named as outside this row',
      () =>
          HabotBodyFont.bodyTokens.length == 3 &&
          HabotBodyFont.bodyTokens
              .every((HabotTypeToken t) => t.name.startsWith('body')) &&
          HabotBodyFont.weightMatches &&
          HabotBodyFont.requestedWeight == 400 &&
          HabotBodyFont.rolesOutsideThisRow.length ==
              HabotTypography.all.length - 3 &&
          !HabotBodyFont.rolesOutsideThisRow.contains('bodyLarge') &&
          HabotBodyFont.rolesOutsideThisRow.contains('displayLarge') &&
          HabotBodyFont.scopeNote.contains('half-migrated'),
    );
  });

  group('GEN-00599 :: the metric, reported as it stands', () {
    test(
      '[GEN-00599-G5] DEFERRED -- body tokens are bound to Inter',
      () {
        // What CAN be asserted: the requirement is declared, it is genuinely
        // unmet, and the reason is a precondition rather than an oversight.
        expect(HabotBodyFont.familyMatches, isFalse);
        expect(HabotBodyFont.canBind, isFalse);
        expect(HabotBodyFont.preconditions.length, greaterThan(3));
        gates.add(
          AissGate(
            id: 'GEN-00599-G5',
            requirementSource:
                'Metric: Body Font Alignment -- floor, optimal and ceiling are '
                'all "Inter 400".',
            description:
                'Body typography is bound to the Inter family the row names',
            passed: false,
            deferred: true,
            detail:
                'Nothing is vendored and this build host has no network, so '
                'Inter cannot be shipped from here. Changing the family name '
                'without the asset produces a per-device platform fallback -- '
                'Roboto on Android, San Francisco on iOS, something else on a '
                'manufacturer skin -- while every text-fit measurement taken '
                'against Roboto metrics silently stops being true. Four '
                'preconditions are recorded: vendor the files and declare them '
                'in pubspec.yaml, re-run the Step 102 text-fit audit, re-check '
                'the Step 144 language-label budget, and re-derive the Step '
                '167 frozen-column widths.',
          ),
        );
      },
    );

    gate(
      'GEN-00599-G6',
      'Floor, optimal and ceiling are all the literal string "Inter 400", so '
          'this is a match or it is nothing.',
      'The observed value is reported as it stands and the qualitative output '
          'is Not Complete, rather than a partial credit the row does not '
          'offer',
      () =>
          HabotBodyFont.target == 'Inter 400' &&
          HabotBodyFont.observed == 'Roboto 400' &&
          !HabotBodyFont.isAligned &&
          HabotBodyFont.qualitativeOutput == 'Not Complete',
    );

    gate(
      'GEN-00599-G7',
      'A flat refusal is less useful than a measurement.',
      'The requirement is broken into parts so the report says WHICH half '
          'holds: the weight and the availability of the bound family do, the '
          'family identity and the availability of the requested one do not',
      () {
        final Map<String, bool> parts = HabotBodyFont.requirementParts;
        return parts.length == 4 &&
            parts['body tokens carry weight 400'] == true &&
            parts['body tokens are bound to a family that will actually '
                    'render'] ==
                true &&
            parts['body tokens are bound to Inter'] == false &&
            parts['the requested family is available to bind'] == false &&
            HabotBodyFont.alignmentRate == 0.5;
      },
    );

    gate(
      'GEN-00599-G8',
      'COLUMN NOTE: the Setup Step names an API-gateway middleware; a font '
          'binding is a client-side typography concern.',
      'The mismatch is recorded rather than a gateway interceptor being '
          'invented to satisfy a column',
      () =>
          HabotBodyFont.columnNote.contains('API-gateway middleware') &&
          HabotBodyFont.columnNote.contains('no gateway involvement'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00599',
        atomicStepReferenceId: 'GEN-00599',
        setupStepAction:
            'COLUMN NOTE: the Setup Step names an API-gateway token rule '
            'enforcer; the Atomic Step names a client-side font binding. '
            'Atomic Step: "Bind font family Inter to Body typography tokens '
            '(normal 400)."',
        implementationOrder: 182,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotBodyFont / HabotFontFamily',
          'Component Properties':
              '3 body roles in scope, all at weight '
              '${HabotBodyFont.requestedWeight}; bound family '
              '"${HabotBodyFont.bound.name}" (platform-bundled); requested '
              'family "${HabotBodyFont.requested.name}" (not vendored); '
              '${HabotBodyFont.preconditions.length} preconditions recorded '
              'before a swap would be safe',
          'Completion Status': 'Not Complete -- deliberately, see the note',
          'Data Quality Note':
              'THIS STEP REPORTS NOT COMPLETE. The row asks for Inter; Step 3 '
              'bound the body tokens to Roboto as the platform-bundled '
              'Material type face. Changing the family name without vendoring '
              'the font does not produce Inter -- Flutter falls back to the '
              'platform default, which differs per device -- while Step 102\'s '
              'text-fit audit, Step 138\'s 30% Welsh expansion factor, Step '
              '144\'s 12-character button budget and Step 167\'s frozen-column '
              'widths all silently stop being true. Nothing would fail. The '
              'binding is built with an asset precondition and the swap is not '
              'made; the alternative would look like progress and be a '
              'regression.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Body Font Alignment',
            observed:
                '${HabotBodyFont.observed} against a target of '
                '${HabotBodyFont.target}. The weight half is met; the family '
                'half is not, and cannot be met from this host. Reported as '
                'Not Complete.',
            floor: 'Inter 400',
            optimal: 'Inter 400',
            ceiling: 'Inter 400',
          ),
          AissMeasurement(
            metricName: 'Requirement parts satisfied',
            observed:
                '2 of 4 '
                '(${(HabotBodyFont.alignmentRate * 100).toStringAsFixed(0)}%). '
                'Body tokens carry weight 400 and are bound to a family that '
                'will actually render; they are not bound to Inter, and Inter '
                'is not available to bind. Breaking the requirement down is '
                'what makes this a measurement rather than a flat refusal.',
            floor: '4 of 4',
            optimal: '4 of 4',
            ceiling: '4 of 4',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/body_font_binding.dart',
        ],
      ),
    );
  });
}
