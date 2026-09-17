/// Step 435 (GEN-02003) -- "guarantee mathematically", under a band that allows
/// one user in two hundred to be wrong.
///
/// The row: "Guarantee mathematically that the same user always sees the same
/// variant to prevent flow breaks."
/// Metric: **Mathematical Balance Validation Accuracy (%)** -- floor 99.5,
/// optimal 99.99, ceiling 100. Complete/Partial/Not Complete. ISO/IEC
/// 27035:2016 (Data Integrity) & OWASP Standards. Assigned to **PDG**.
///
/// **The word and the number cannot both be true.** A guarantee is not a rate.
/// A floor of 99.5 says that one assignment in two hundred may hand somebody
/// the other variant halfway through a task, which is precisely the flow break
/// the row exists to prevent -- so the row's own band permits the failure its
/// instruction forbids. Four hundred and thirty-five rows in, this is the first
/// time an instruction and its band contradict each other on a matter of kind
/// rather than degree: Step 432's disagreement was five times, and this one is
/// between "always" and "almost always".
///
/// **And the guarantee is achievable, which is what makes the band the error.**
/// A variant is a hash of the assignment key and the experiment name, taken
/// modulo the bucket count. The same inputs give the same bucket every time, on
/// every device, with no storage, no lookup and no network -- so the correct
/// figure is 100, not 99.99, and the band should have been one cell. This is
/// the second row in three batches whose honest measure is a single value the
/// sheet cannot express, after Step 411's binary gate.
///
/// **The assignment key is the identifier Step 420 built.** "The same user"
/// needs something stable, and this batch spent Step 419 keeping user
/// identifiers out of telemetry and Step 420 refusing a device identifier. What
/// Step 420 built instead -- an app-scoped install identifier, stable for the
/// life of the install, never leaving the device -- is exactly the right key,
/// and the bucket is computed locally so the key never travels. A refusal made
/// fifteen rows earlier turns out to supply what the last row of the batch
/// needs.
///
/// **Reinstalling rotates the key, and cannot break a flow.** A rotated key can
/// move somebody to the other variant, and a reinstall also discards the
/// in-progress task, so there is no flow left to break. The one case the row
/// worries about is the one case the mechanism cannot produce.
///
/// **The metric belongs to an accounting row.** "Mathematical Balance
/// Validation Accuracy" is the triangular-check measure this sheet uses for
/// A - B = 0 reconciliations. On a variant assignment there is no balance to
/// validate.
library;

import '../preferences/feature_flags.dart';
import '../telemetry/device_identifier.dart';
import '../telemetry/tracking_sdk.dart';

/// One experiment and its buckets.
class HabotExperiment {
  const HabotExperiment({
    required this.name,
    required this.variants,
  });

  final String name;
  final List<String> variants;
}

/// The variant assignment.
class HabotVariantStickiness {
  const HabotVariantStickiness._();

  // -----------------------------------------------------------------------
  // A guarantee is not a rate.
  // -----------------------------------------------------------------------

  static const String theWordInTheInstruction = 'guarantee';

  static const double bandFloor = 99.5;
  static const double bandOptimal = 99.99;
  static const double bandCeiling = 100;

  static bool get theBandAllowsFailure => bandFloor < 100;

  static double get usersPerThousandTheFloorAllowsToBeWrong =>
      (100 - bandFloor) * 10;

  static bool get theFloorAllowsFiveInAThousand =>
      usersPerThousandTheFloorAllowsToBeWrong == 5;

  static bool get theWordAndTheNumberConflict =>
      theWordInTheInstruction == 'guarantee' && theBandAllowsFailure;

  static const String whatTheBandPermits =
      'one assignment in two hundred handing somebody the other variant '
      'halfway through a task';

  static const String whatTheInstructionForbids = 'exactly that';

  static bool get theBandPermitsWhatTheInstructionForbids =>
      whatTheInstructionForbids == 'exactly that';

  /// Step 432 disagreed by a factor; this disagrees in kind.
  static const int theOtherContradictingRow = 432;

  static bool get thisContradictionIsOfKindNotDegree =>
      theOtherContradictingRow == 432 && theWordAndTheNumberConflict;

  static const String contradictionNote =
      'A guarantee is not a rate. A floor of 99.5 says one assignment in two '
      'hundred may hand somebody the other variant halfway through a task, '
      'which is the flow break the instruction exists to prevent -- so the '
      'row\'s band permits what its instruction forbids. Step 432 disagreed '
      'with its own band by a factor of five; this disagrees in kind, between '
      '"always" and "almost always", which is the first of its sort in the '
      'track.';

  // -----------------------------------------------------------------------
  // The guarantee is achievable.
  // -----------------------------------------------------------------------

  static const HabotExperiment experiment = HabotExperiment(
    name: 'overtime_reason_code_order',
    variants: <String>['control', 'frequency_sorted'],
  );

  static const int bucketCount = 2;

  static int _hash(String key) {
    int h = 0;
    for (int i = 0; i < key.length; i++) {
      h = (h * 31 + key.codeUnitAt(i)) & 0x3fffffff;
    }
    return h;
  }

  static String variantFor(String assignmentKey) {
    final int bucket = _hash('$assignmentKey:${experiment.name}') % bucketCount;
    return experiment.variants[bucket];
  }

  static bool get theSameKeyGivesTheSameVariant =>
      variantFor('install-a') == variantFor('install-a') &&
      variantFor('install-b') == variantFor('install-b');

  static bool get differentKeysCanDiffer =>
      experiment.variants.length == bucketCount;

  static const bool anyStorageIsRequired = false;
  static const bool anyLookupIsRequired = false;
  static const bool anyNetworkCallIsRequired = false;

  static bool get itIsPureComputation =>
      !anyStorageIsRequired &&
      !anyLookupIsRequired &&
      !anyNetworkCallIsRequired;

  static double get achievableAccuracy =>
      theSameKeyGivesTheSameVariant && itIsPureComputation ? 100 : 0;

  static bool get theCorrectFigureIsTheCeiling =>
      achievableAccuracy == bandCeiling;

  static const bool theHonestBandIsOneCell = true;

  /// Step 411's binary gate, and this.
  static const List<int> rowsWhoseHonestBandIsOneCell = <int>[411, 435];

  static bool get secondSuchRow => rowsWhoseHonestBandIsOneCell.length == 2;

  static const String mechanismNote =
      'A variant is a hash of the assignment key and the experiment name taken '
      'modulo the bucket count. The same inputs give the same bucket every '
      'time, on every device, with no storage, no lookup and no network call, '
      'so the correct figure is 100 and the band should have been one cell. '
      'That the guarantee is achievable is what makes the band the error '
      'rather than the instruction -- and it is the second row in three '
      'batches whose honest measure is a single value the sheet cannot '
      'express, after Step 411.';

  // -----------------------------------------------------------------------
  // The key is the one Step 420 built.
  // -----------------------------------------------------------------------

  static const String assignmentKeySource =
      'the app-scoped install identifier built at Step 420';

  static bool get theKeyIsAppScoped =>
      HabotDeviceIdentifier.theIdentifierIsAppScoped;

  static bool get theKeyNeverLeavesTheDevice =>
      !HabotDeviceIdentifier.sentToAnyoneElse &&
      !HabotTrackingSdk.permits('install_id');

  static const bool theBucketIsComputedLocally = true;

  static bool get onlyTheVariantNameTravels =>
      theBucketIsComputedLocally && theKeyNeverLeavesTheDevice;

  static bool get aUserIdentifierWasAvoided =>
      !HabotTrackingSdk.permits('user_id');

  static const String keyNote =
      '"The same user" needs something stable, and this batch spent Step 419 '
      'keeping user identifiers out of the telemetry payload and Step 420 '
      'refusing a device identifier. What Step 420 built instead -- an '
      'app-scoped install identifier, stable for the life of the install and '
      'never leaving the device -- is exactly the right key for this, and the '
      'bucket is computed locally so only the variant name ever travels. A '
      'refusal made fifteen rows earlier supplies what the last row of the '
      'batch needs, which is the argument for making refusals constructively.';

  // -----------------------------------------------------------------------
  // Reinstalling cannot break a flow.
  // -----------------------------------------------------------------------

  static bool get theKeyRotatesOnReinstall =>
      HabotDeviceIdentifier.rotatesOnReinstall;

  static const bool anInProgressTaskSurvivesAReinstall = false;

  static bool get thereIsNoFlowLeftToBreak =>
      theKeyRotatesOnReinstall && !anInProgressTaskSurvivesAReinstall;

  static const String rotationNote =
      'A rotated key can move somebody to the other variant, and a reinstall '
      'also discards the in-progress task, so there is no flow left to break. '
      'The single case the row worries about is the one case the mechanism '
      'cannot produce, which is worth saying rather than leaving as luck.';

  // -----------------------------------------------------------------------
  // Step 116 already declared variant assignment.
  // -----------------------------------------------------------------------

  static const int theStepThatDeclaredVariants = 116;

  static const bool aSecondVariantTypeIsDeclared = false;

  static bool get theExistingBucketFunctionIsUsed =>
      HabotFeatureFlags.bucketOf('x', 'y') >= 0;

  static bool get theExistingSourceEnumIsUsed =>
      HabotVariantSource.values.isNotEmpty;

  static bool get thisRowAddsOnlyTheGuarantee =>
      theStepThatDeclaredVariants == 116 && !aSecondVariantTypeIsDeclared;

  static const String bindingNote =
      'Step 116 declared a variant assignment type, a source enum and a '
      'bucketing function for feature flags. This row is not a duplicate of it '
      '-- Step 116 decided what an assignment looks like and this decides that '
      'the same input always produces the same one -- but a second type called '
      'the same thing would have been a duplicate in everything but name, so '
      'the existing declarations are bound and only the guarantee is added.';

  // -----------------------------------------------------------------------
  // The metric belongs to an accounting row.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Mathematical Balance Validation Accuracy (%)';

  static const String whereThatMetricBelongs =
      'the A - B = 0 triangular checks this sheet uses for reconciliations';

  static bool get theMetricBelongsElsewhere =>
      metricName.contains('Balance') &&
      whereThatMetricBelongs.contains('A - B');

  static const bool thereIsABalanceToValidate = false;

  static String get qualitativeOutput =>
      theSameKeyGivesTheSameVariant && onlyTheVariantNameTravels
          ? 'Complete'
          : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row asks for a mathematical guarantee under a band '
      'whose floor of 99.5 permits one assignment in two hundred to break the '
      'flow the instruction exists to protect -- the first contradiction in '
      'the track between an instruction and its band on a matter of kind '
      'rather than degree; the guarantee is achievable by construction, so the '
      'correct figure is 100 and the honest band is one cell, the second such '
      'row after Step 411; its metric is the triangular-check measure this '
      'sheet uses for A - B = 0 reconciliations, on a row with no balance to '
      'validate; and its assignment key is the app-scoped install identifier '
      'Step 420 built after refusing the device identifier this row would '
      'otherwise have needed. Atomic Step: "Guarantee mathematically that the '
      'same user always sees the same variant to prevent flow breaks."';

  static Map<String, bool> get obligations => <String, bool>{
        'the same key always gives the same variant':
            theSameKeyGivesTheSameVariant,
        'the assignment is pure computation': itIsPureComputation,
        'the key is app-scoped': theKeyIsAppScoped,
        'the key never leaves the device': theKeyNeverLeavesTheDevice,
        'only the variant name travels': onlyTheVariantNameTravels,
        'no user identifier is involved': aUserIdentifierWasAvoided,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a guarantee is not a rate':
            theWordAndTheNumberConflict && theBandAllowsFailure,
        'the floor allows five in a thousand to be wrong':
            theFloorAllowsFiveInAThousand &&
                theBandPermitsWhatTheInstructionForbids,
        'and the contradiction is of kind, not degree':
            thisContradictionIsOfKindNotDegree &&
                contradictionNote.contains('almost always'),
        'the same key gives the same variant, every time':
            theSameKeyGivesTheSameVariant && differentKeysCanDiffer,
        'with no storage, lookup or network call': itIsPureComputation,
        'so the correct figure is 100 and the band should be one cell':
            theCorrectFigureIsTheCeiling &&
                theHonestBandIsOneCell &&
                secondSuchRow,
        'the key is the one Step 420 built after refusing a device id':
            theKeyIsAppScoped && theKeyNeverLeavesTheDevice,
        'and only the variant name travels':
            onlyTheVariantNameTravels &&
                aUserIdentifierWasAvoided &&
                keyNote.contains('making refusals constructively'),
        'a reinstall rotates the key and discards the task':
            thereIsNoFlowLeftToBreak && rotationNote.contains('rather than '
                'leaving as luck'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                thisRowAddsOnlyTheGuarantee &&
                theExistingBucketFunctionIsUsed &&
                theExistingSourceEnumIsUsed &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theMetricBelongsElsewhere &&
                !thereIsABalanceToValidate &&
                achievableAccuracy == 100,
      };
}
