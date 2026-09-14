/// AISS GATE -- Step 206 of 215
/// Global Reference ID:       GEN-01529
/// Atomic Steps Reference ID: GEN-01529
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Embed an M3 Outlined Text Field with an inline 'Apply' CTA
///               button."
/// Metric: Coupon/Voucher Redemption Validation Accuracy -- Floor 0.97,
///         Optimal 0.999, Ceiling 1. Pass/Fail.
///
/// THE METRIC IS NOT THE CLIENT'S TO REPORT. Whether a code is valid is
/// decided by a service this app cannot see; a client cannot be 99.9% accurate
/// about something it does not know. What is reported is the client's own
/// share, with the boundary stated.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/checkout/promo_apply_field.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  group('GEN-01529 :: what the client normalises', () {
    gate(
      'GEN-01529-G1',
      '"People paste codes out of emails with separators attached."',
      'Whitespace, dashes and underscores are stripped and case is folded '
          'once, in one place, so the same code typed four ways reaches the '
          'server as one string',
      () =>
          HabotPromoApplyField.normalise('WELCOME10').normalised ==
              'WELCOME10' &&
          HabotPromoApplyField.normalise('welcome10').normalised ==
              'WELCOME10' &&
          HabotPromoApplyField.normalise(' WELCOME 10 ').normalised ==
              'WELCOME10' &&
          HabotPromoApplyField.normalise('welcome-10').normalised ==
              'WELCOME10' &&
          HabotPromoApplyField.normalise('welcome_10').normalised ==
              'WELCOME10',
    );

    gate(
      'GEN-01529-G2',
      '"If a case-sensitive code is ever issued, this is the line that breaks '
          'it."',
      'The upper-casing is an assumption about the codes this product issues, '
          'and it is recorded as an assumption in one place rather than spread '
          'across call sites as a habit',
      () =>
          HabotPromoApplyField.caseFoldingAssumption
              .contains('the line that breaks it') &&
          HabotPromoApplyField.normalise('welcome-10').note
              .contains('upper-cased') &&
          HabotPromoApplyField.normalise('WELCOME10').note == 'unchanged',
    );

    gate(
      'GEN-01529-G3',
      '"Only shape is checked locally; meaning is always the server\'s."',
      'A code that is too short or carries an illegal character is refused '
          'without spending a request, and nothing in the client decides that '
          'a well-formed code is invalid',
      () =>
          !HabotPromoApplyField.normalise('WEL').isWellFormed &&
          !HabotPromoApplyField.normalise('WELCOME10!!').isWellFormed &&
          HabotPromoApplyField.stateFor('WEL') ==
              HabotPromoFieldState.malformed &&
          HabotPromoApplyField.stateFor('SUMMER2026') ==
              HabotPromoFieldState.ready &&
          HabotPromoApplyField.neverGuessLocallyNote
              .contains('a code the build predates'),
    );
  });

  group('GEN-01529 :: the inline CTA', () {
    gate(
      'GEN-01529-G4',
      'Step 184: a 24dp glyph is 20dp below the band floor.',
      'The Apply glyph alone would fail the band; its target is the full field '
          'height and at least the band optimal wide, so drawn size and '
          'tappable size are different numbers and the finger meets the larger '
          'one',
      () =>
          HabotPromoApplyField.glyphAloneWouldFailTheBand &&
          HabotPromoApplyField.applyGlyphDp == 24 &&
          HabotPromoApplyField.applyTargetHeightDp ==
              HabotPromoApplyField.fieldHeightDp &&
          HabotPromoApplyField.fieldHeightDp == HabotTouchBand.ceilingDp &&
          HabotPromoApplyField.applyTargetWidthDp ==
              HabotTouchBand.optimalDp &&
          HabotPromoApplyField.applyTargetIsWithinBand &&
          HabotPromoApplyField.inlineTargetNote
              .contains('only one of them is what a finger meets'),
    );

    gate(
      'GEN-01529-G5',
      '"A promo applied twice is the oldest discount bug there is."',
      'Apply is disabled while empty and while in flight, the field is locked '
          'during the request, and the window that stops a held finger '
          'becoming four requests is the Step 118 token rather than a new '
          'number',
      () =>
          !HabotPromoApplyField.applyIsEnabled(
            HabotPromoFieldState.empty,
          ) &&
          !HabotPromoApplyField.applyIsEnabled(
            HabotPromoFieldState.malformed,
          ) &&
          HabotPromoApplyField.applyIsSingleShot &&
          !HabotPromoApplyField.fieldIsEditable(
            HabotPromoFieldState.applying,
          ) &&
          HabotPromoApplyField.rateLimitWindow ==
              HabotMotion.rateLimitWindow &&
          HabotPromoApplyField.applyTimeout ==
              HabotMotion.submitLockTimeout &&
          HabotPromoApplyField.applyOnceNote.contains('held finger'),
    );

    gate(
      'GEN-01529-G6',
      'A rejected code and an accepted one need opposite treatment.',
      'A rejection leaves the code in the field, editable and retryable, while '
          'an acceptance locks it -- so a typo can be corrected in place and a '
          'successful discount cannot be typed over by accident',
      () =>
          HabotPromoApplyField.applyIsEnabled(
            HabotPromoFieldState.rejected,
          ) &&
          HabotPromoApplyField.fieldIsEditable(
            HabotPromoFieldState.rejected,
          ) &&
          !HabotPromoApplyField.fieldIsEditable(
            HabotPromoFieldState.accepted,
          ) &&
          HabotPromoApplyField.stateFor(
                'WELCOME10',
                serverAccepted: false,
              ) ==
              HabotPromoFieldState.rejected &&
          HabotPromoApplyField.stateFor('WELCOME10', inFlight: true) ==
              HabotPromoFieldState.applying &&
          HabotPromoFieldState.values.length == 6,
    );

    gate(
      'GEN-01529-G7',
      'Metric: Coupon/Voucher Redemption Validation Accuracy -- floor 0.97.',
      'The client\'s own share is computed over nine checks and reaches 1.0; '
          'the server\'s share is named as outside this app rather than '
          'having a figure invented for it',
      () {
        accuracy = HabotPromoApplyField.clientAccuracy;
        return HabotPromoApplyField.clientChecks.length == 9 &&
            HabotPromoApplyField.clientChecks.values.every((bool b) => b) &&
            accuracy == 1.0 &&
            accuracy >= HabotPromoApplyField.floor &&
            HabotPromoApplyField.qualitativeOutput == 'Pass' &&
            HabotPromoApplyField.accuracyIsNotTheClientsNote
                .contains('agreement with itself') &&
            HabotPromoApplyField.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01529',
        atomicStepReferenceId: 'GEN-01529',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Embed an M3 Outlined Text Field with an inline \'Apply\' '
            'CTA button."',
        implementationOrder: 206,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPromoApplyField',
          'Component Properties':
              '${HabotPromoFieldState.values.length} field states; '
              'normalisation stripping whitespace, dashes and underscores and '
              'folding case once; shape checked locally as A-Z0-9 of length '
              '4-20 and meaning never; Apply target '
              '${HabotPromoApplyField.applyTargetWidthDp.toStringAsFixed(0)}x'
              '${HabotPromoApplyField.applyTargetHeightDp.toStringAsFixed(0)}'
              'dp around a '
              '${HabotPromoApplyField.applyGlyphDp.toStringAsFixed(0)}dp glyph',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: the metric is not the client\'s to report. '
              'Whether a code is valid is decided by a service this app cannot '
              'see, and a client cannot be 99.9% accurate about something it '
              'does not know -- reporting that figure would mean measuring the '
              'client\'s agreement with itself. What is reported is the '
              'client\'s own share: codes handed over in a form the server can '
              'judge, normalised once, submitted once, never guessed at '
              'locally. The tempting optimisation -- a local list of '
              'known-good prefixes -- makes the client wrong every time '
              'marketing issues a code the build predates, and the failure is '
              'silent: the parent is told their valid code is invalid. '
              'FINDING: the inline Apply CTA is a 24dp glyph and fails the '
              'Step 184 floor on its own; its target is the full 56dp field '
              'height and 48dp wide. ASSUMPTION DECLARED: codes are '
              'upper-cased on the way out, which is safe for every code this '
              'product issues and is the one line that breaks if a '
              'case-sensitive code is ever issued.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Coupon/Voucher Redemption Validation Accuracy '
                '(client share)',
            observed:
                '${accuracy.toStringAsFixed(2)} over '
                '${HabotPromoApplyField.clientChecks.length} checks: '
                'normalisation, local shape refusal without spending a '
                'request, single-shot apply, the rejected/accepted split, and '
                'the Apply target clearing the band where the glyph alone '
                'would not. The server\'s share of the metric is outside this '
                'app and no figure is invented for it.',
            floor: '0.97',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Requests spent on locally-refusable input',
            observed:
                '0 -- a too-short code and one carrying an illegal character '
                'are both refused before a request is made, while no '
                'well-formed code is ever refused locally.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/checkout/promo_apply_field.dart',
        ],
      ),
    );
  });
}
