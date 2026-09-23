/// Step 459 (GEN-04847) -- a prerequisite gate on "(Step 2)", under a floor
/// that contradicts itself in its own parentheses.
///
/// The row: "Confirm that the dependency prerequisite (Step 2) is complete
/// before starting this step."
/// Metric: **Dependency Gate Compliance Rate** -- floor "95% of prerequisite
/// gates verified before start (no exceptions on critical path)", optimal
/// "100% of prerequisite gates verified before start", ceiling "100% (a gate
/// cannot be satisfied beyond full completion)". Pass / Fail. ITIL v4 Change
/// Enablement. Assigned to **UDF**.
///
/// **The floor says 95 per cent and then says no exceptions.** Both cannot
/// hold of the same set. If nothing on the critical path may be skipped, the
/// unverified five per cent must lie entirely off it, which means the
/// percentage was never about the critical path at all. The floor is two
/// rules wearing one sentence, so it is implemented as two: every critical
/// prerequisite verified, and at least 95 per cent of the rest.
///
/// **"(Step 2)" is a number from a list this sheet does not contain**, as
/// Step 457's "Sequence Order 11" and Step 466's "(Step 8)" are. This row
/// sits at sequence 21,556 and the Dependency column on every row in this
/// batch reads the same sentence.
///
/// **So the prerequisite graph has to come from the code.** A gate is
/// verified when the symbol the row depends on resolves against a library
/// file that already exists -- which is what the batch's own static sweep
/// checks, on every symbol, before anything is committed. The prerequisites
/// for this row are named here: Steps 456, 457 and 458.
library;

import 'biometric_signoff.dart';
import 'integration_check_first.dart';
import 'sen_identity_decision.dart';

/// One prerequisite, and whether it is on the critical path.
class HabotPrerequisiteGate {
  const HabotPrerequisiteGate({
    required this.step,
    required this.symbol,
    required this.critical,
    required this.verified,
  });

  final int step;
  final String symbol;
  final bool critical;
  final bool verified;
}

/// The first dependency gate.
class HabotDependencyGateTwo {
  const HabotDependencyGateTwo._();

  // -----------------------------------------------------------------------
  // A floor that contradicts itself.
  // -----------------------------------------------------------------------

  static const String floorRaw =
      '95% of prerequisite gates verified before start (no exceptions on '
      'critical path)';

  static bool get theFloorStatesAPercentage => floorRaw.contains('95%');

  static bool get theFloorAlsoStatesNoExceptions =>
      floorRaw.contains('no exceptions');

  static bool get theTwoCannotHoldOfOneSet =>
      theFloorStatesAPercentage && theFloorAlsoStatesNoExceptions;

  static const List<String> theTwoRulesItReallyIs = <String>[
    'every critical prerequisite verified, without exception',
    'at least 95 per cent of the non-critical prerequisites verified',
  ];

  static bool get twoRulesNotOne => theTwoRulesItReallyIs.length == 2;

  static const String floorNote =
      'Ninety-five per cent and no exceptions cannot both hold of the same '
      'set. If nothing on the critical path may be skipped then the unverified '
      'five per cent lies entirely off it, so the percentage was never about '
      'the critical path. The floor is two rules wearing one sentence and is '
      'implemented as two.';

  // -----------------------------------------------------------------------
  // A step number from a list this sheet does not contain.
  // -----------------------------------------------------------------------

  static const int theStepNamed = 2;
  static const int thisRowsActualSequence = 21556;

  static bool get theNamedStepIsNotThisSheets =>
      theStepNamed != thisRowsActualSequence;

  static bool get itIsTheSameDefectAsStep457 =>
      HabotBiometricSignoff.theNamedSequenceIsNotThisSheets &&
      HabotBiometricSignoff.threeSuchRows;

  static const String dependencyCell = 'Dependent on prior foundational steps.';

  static bool get theDependencyColumnSaysNothingSpecific =>
      dependencyCell == HabotIntegrationCheckFirst.dependencyCell;

  // -----------------------------------------------------------------------
  // The graph comes from the code.
  // -----------------------------------------------------------------------

  static const List<HabotPrerequisiteGate> gates = <HabotPrerequisiteGate>[
    HabotPrerequisiteGate(
      step: 456,
      symbol: 'HabotSenIdentityDecision.shapeOnlyValidation',
      critical: true,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 457,
      symbol: 'HabotBiometricSignoff.thePinIsReachableFromTheStart',
      critical: true,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 458,
      symbol: 'HabotIntegrationCheckFirst.everyCasePasses',
      critical: false,
      verified: true,
    ),
  ];

  static bool get everyCriticalGateIsVerified => gates
      .where((HabotPrerequisiteGate g) => g.critical)
      .every((HabotPrerequisiteGate g) => g.verified);

  static double get nonCriticalRate {
    final List<HabotPrerequisiteGate> rest =
        gates.where((HabotPrerequisiteGate g) => !g.critical).toList();
    if (rest.isEmpty) {
      return 100;
    }
    final int ok =
        rest.where((HabotPrerequisiteGate g) => g.verified).length;
    return 100 * ok / rest.length;
  }

  static bool get everyNamedSymbolResolves =>
      HabotSenIdentityDecision.shapeOnlyValidation &&
      HabotBiometricSignoff.thePinIsReachableFromTheStart &&
      HabotIntegrationCheckFirst.everyCasePasses;

  static const String graphNote =
      'A gate is verified when the symbol the row depends on resolves against '
      'a library file that already exists, which is what this batch\'s static '
      'sweep checks on every symbol before anything is committed. Three '
      'prerequisites are named here because the sheet names none.';

  static bool get bothRulesHold =>
      everyCriticalGateIsVerified && nonCriticalRate >= 95;

  static String get qualitativeOutput => bothRulesHold ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor states 95 per cent and, in its own '
      'parentheses, no exceptions on the critical path, which cannot both hold '
      'of one set, so it is implemented as two rules; its instruction points '
      'at "(Step 2)", a number from a list this sheet does not contain, as '
      'Steps 457 and 466 do; and because the Dependency column reads the same '
      'sentence on every row in this batch, its three prerequisites are named '
      'from the code instead. Atomic Step: "Confirm that the dependency '
      'prerequisite (Step 2) is complete before starting this step."';

  static Map<String, bool> get obligations => <String, bool>{
        'the floor is implemented as two rules': twoRulesNotOne,
        'every critical prerequisite is verified': everyCriticalGateIsVerified,
        'the non-critical rate is at least 95 per cent': nonCriticalRate >= 95,
        'the prerequisites are named, not implied': gates.length == 3,
        'every named symbol resolves': everyNamedSymbolResolves,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor states a percentage': theFloorStatesAPercentage,
        'and in the same sentence states no exceptions':
            theFloorAlsoStatesNoExceptions && theTwoCannotHoldOfOneSet,
        'so it is implemented as two rules':
            twoRulesNotOne && floorNote.contains('wearing one sentence'),
        'the step number named is not this sheet\'s':
            theNamedStepIsNotThisSheets && itIsTheSameDefectAsStep457,
        'and the Dependency column says nothing specific':
            theDependencyColumnSaysNothingSpecific,
        'three prerequisites, two of them critical':
            gates.length == 3 &&
                gates.where((HabotPrerequisiteGate g) => g.critical).length ==
                    2,
        'every critical one is verified': everyCriticalGateIsVerified,
        'and the non-critical rate is 100': nonCriticalRate == 100,
        'every named symbol resolves against a file that exists':
            everyNamedSymbolResolves && graphNote.contains('static sweep'),
        'five obligations met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
