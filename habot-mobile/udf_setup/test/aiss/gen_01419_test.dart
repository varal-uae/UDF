/// AISS GATE -- Step 197 of 215
/// Global Reference ID:       GEN-01419
/// Atomic Steps Reference ID: GEN-01419
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure suppression logic to automatically bypass the FRE
///               carousel for returning authenticated users."
/// Metric: First-Run Experience Completion Rate -- Floor 0.7, Optimal 0.9,
///         Ceiling 1. Good/Average/Poor.
///
/// THE PERSON THE ROW NAMES IS THE PERSON STEP 196's FLAG CANNOT SEE. A
/// returning authenticated user on a fresh install has no device state. The
/// suppression is keyed on the account; the flag is the fast path for someone
/// with no account to ask.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/onboarding/fre_completion_flag.dart';
import 'package:udf_setup/design_system/onboarding/fre_suppression.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double suppression = 0;

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

  HabotFreSuppression rule({int version = 1}) => HabotFreSuppression(
        flag: HabotFreFlag(
          store: HabotMemoryStore(),
          carouselVersion: version,
        ),
      );

  HabotFreState settled({int version = 1}) => HabotFreState(
        outcome: HabotFreOutcome.completed,
        furthestSlide: 3,
        slideCount: 4,
        carouselVersion: version,
        recordedAt: DateTime.utc(2026, 1, 1),
      );

  group('GEN-01419 :: the user the row names', () {
    gate(
      'GEN-01419-G1',
      'Atomic Step: "bypass the FRE carousel for RETURNING AUTHENTICATED '
          'users."',
      'A returning user whose account has been onboarded is suppressed even '
          'with no local state at all -- and a device-flag-only '
          'implementation, given the same user, would show them the carousel',
      () {
        final HabotFreSuppression r = rule();
        final HabotFreVerdict v = r.returningOnFreshInstall;
        return v.decision == HabotFreDecision.suppressedByAccount &&
            !v.showsCarousel &&
            r.deviceOnlyWouldShowForReturningUser &&
            HabotFreSuppression.accountNotDeviceNote
                .contains('cannot see');
      },
    );

    gate(
      'GEN-01419-G2',
      '"A sign-up that stopped before the carousel finished."',
      'A returning account that has never completed onboarding is shown the '
          'carousel rather than suppressed -- "returning" is not the same '
          'property as "onboarded", and conflating them loses the people who '
          'most need it',
      () {
        final HabotFreVerdict v = rule().decide(
          posture: HabotAuthPosture.returning,
          localState: null,
        );
        return v.showsCarousel &&
            v.decision == HabotFreDecision.show &&
            v.reason.contains('never completed onboarding');
      },
    );

    gate(
      'GEN-01419-G3',
      '"The restoring posture is neither signed in nor signed out, and it is '
          'the state a cold start spends its first frames in."',
      'A session still restoring defers rather than guessing, so a returning '
          'user does not see the carousel flash before the session resolves -- '
          'and deferring is a distinct decision, not a disguised "show"',
      () {
        final HabotFreVerdict v = rule().decide(
          posture: HabotAuthPosture.restoring,
          localState: null,
        );
        return v.decision == HabotFreDecision.deferred &&
            !v.showsCarousel &&
            HabotFreDecision.values.length == 4 &&
            HabotFreSuppression.restoringNote.contains('flash');
      },
    );
  });

  group('GEN-01419 :: the decision is total', () {
    gate(
      'GEN-01419-G4',
      '"A chain of ifs with no final else shows the carousel to whoever falls '
          'off the end."',
      'Every combination of posture, account state and local state -- forty of '
          'them, enumerated rather than sampled -- produces a named decision '
          'carrying a reason',
      () {
        final HabotFreSuppression r = rule();
        return r.allInputs.length == 40 &&
            r.isTotal &&
            r.allInputs.every((
              (HabotAuthPosture, bool, HabotFreState?) i,
            ) {
              final HabotFreVerdict v = r.decide(
                posture: i.$1,
                localState: i.$3,
                accountHasCompletedOnboarding: i.$2,
              );
              return v.reason.isNotEmpty;
            }) &&
            HabotFreSuppression.totalityNote.contains('checked');
      },
    );

    gate(
      'GEN-01419-G5',
      '"Seeing it a second time is an annoyance; never seeing it is a user '
          'who never learned what the app does."',
      'When nothing suppresses, the carousel is shown rather than hidden -- '
          'an anonymous user with no settled state, and a new account, both '
          'see it',
      () {
        final HabotFreSuppression r = rule();
        return r
                .decide(
                  posture: HabotAuthPosture.anonymous,
                  localState: null,
                )
                .showsCarousel &&
            r
                .decide(
                  posture: HabotAuthPosture.newAccount,
                  localState: null,
                )
                .showsCarousel &&
            HabotFreSuppression.defaultIsToShowNote
                .contains('never entered the denominator');
      },
    );

    gate(
      'GEN-01419-G6',
      'Step 196 owns the device flag; this step owns the order the two are '
          'consulted in.',
      'The device flag answers only where there is no account to ask: an '
          'anonymous user with a settled flag is suppressed by device, and the '
          'same flag against a different carousel version does not suppress',
      () {
        final HabotFreSuppression r = rule();
        final HabotFreSuppression v2 = rule(version: 2);
        return r
                .decide(
                  posture: HabotAuthPosture.anonymous,
                  localState: settled(),
                )
                .decision ==
                HabotFreDecision.suppressedByDevice &&
            v2
                .decide(
                  posture: HabotAuthPosture.anonymous,
                  localState: settled(),
                )
                .showsCarousel;
      },
    );

    gate(
      'GEN-01419-G7',
      'Metric: First-Run Experience Completion Rate -- floor 0.7, optimal 0.9.',
      'The share of enumerated inputs that resolve without showing the '
          'carousel is 0.575, which is a property of this rule rather than of '
          'the population -- the completion rate itself needs real installs '
          'and is recorded as not producible on this host',
      () {
        suppression = rule().suppressionRate;
        return suppression == 0.575 &&
            suppression > 0 &&
            suppression < 1 &&
            HabotFreSuppression.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01419',
        atomicStepReferenceId: 'GEN-01419',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Configure suppression logic to automatically bypass the '
            'FRE carousel for returning authenticated users."',
        implementationOrder: 197,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFreSuppression / HabotFreVerdict',
          'Component Properties':
              '${HabotAuthPosture.values.length} auth postures x 2 account '
              'states x 5 local states = 40 enumerated inputs, each resolving '
              'to one of ${HabotFreDecision.values.length} named decisions '
              'with a plain-language reason; account state consulted before '
              'the device flag; unresolved posture defers rather than guesses',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the person the row names is the person Step 196\'s '
              'flag cannot see. A returning authenticated user on a fresh '
              'install has no device state, so a device-flag-only suppression '
              'shows the carousel to exactly the user the row exempts. The '
              'suppression is keyed on the account; the flag answers only '
              'where there is no account to ask. SECOND FINDING: "returning" '
              'and "onboarded" are different properties, and a returning '
              'account that never finished the carousel is shown it rather '
              'than suppressed. THIRD: the restoring posture is neither '
              'signed in nor signed out and is where a cold start spends its '
              'first frames; treated as anonymous it produces a carousel '
              'flash, so it defers. The decision is total over all forty '
              'inputs and the default, where nothing matches, is to SHOW -- '
              'seeing it twice is an annoyance, never seeing it is invisible '
              'because the install never entered the denominator.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'First-Run Experience Completion Rate '
                '(suppression correctness)',
            observed:
                'The completion rate needs real installs and is not producible '
                'on this host. What is measured is the rule: 40 of 40 inputs '
                'resolve to a named decision with a reason, and the case the '
                'row is about -- returning, onboarded, no local state -- '
                'suppresses where a device-flag-only implementation would not.',
            floor: '0.7',
            optimal: '0.9',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Suppression rate over enumerated inputs',
            observed:
                '${suppression.toStringAsFixed(3)} -- 23 of 40 inputs resolve '
                'without showing the carousel. A property of the rule, not of '
                'any population; reported so a later change that suppresses '
                'more or less is visible as a number.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/onboarding/fre_suppression.dart',
        ],
      ),
    );
  });
}
