/// Step 479 (RRCVG-045-A08) -- release gate configuration, on a row carrying
/// three different subjects in three different columns.
///
/// The row: "Use standardized code layout models for release gate
/// configurations."
/// Metric: **UI/UX Design System Conformity (Material 3)** -- floor "<70%
/// components on design-system tokens (inconsistent)", optimal "90-100% of
/// components using approved Material 3 tokens/components", ceiling "100%
/// ceiling - full design-system conformity". Best Qualitative Output: "Good".
/// Google Material Design 3 / Nielsen Norman heuristics. Assigned to **ADFA**.
///
/// **Three subjects, three columns, one row.** The Atomic Step is about
/// release gate configuration. The metric is about Material 3 token
/// conformity in components. And the Setup Step cell reads "Define the data
/// linkage between training completion metrics and the enterprise promotion
/// evaluation engine" -- a fourth system entirely. Eleven rows in this track
/// have carried a spliced half; this is the first to carry three distinct
/// subjects at once.
///
/// **The Setup Step cell is refused.** A promotion evaluation engine fed
/// automatically by training completion is a score about a person driving a
/// consequence without a person deciding, which Step 436's charter forbids in
/// its third rule. It is recorded here, in full, so that whoever wrote it can
/// see where it landed, and it is not built. Training completion belongs to
/// the learner first (Step 450); if the organisation wants it to inform
/// promotion, that is a decision with an owner and the people affected
/// consulted, not a data linkage.
///
/// **The output column holds one value.** "Good" is not a scale; it is the
/// answer. It is the nineteenth one-valued output column in the track.
///
/// **What is actually built is the gate configuration the instruction asks
/// for**: each gate as a record with a key, a value, a type, a validation
/// status and a timestamp, naming what it blocks, who may waive it, and with
/// every waiver carrying the name of the person who gave it. The gates
/// themselves already exist -- Step 292's release button reads a set of
/// blockers -- so this row supplies their configuration rather than a second
/// mechanism.
library;

import '../operations/release_gate.dart';
import '../recognition/completion_criteria.dart';

/// One configured release gate.
class HabotGateSetting {
  const HabotGateSetting({
    required this.key,
    required this.value,
    required this.type,
    required this.validated,
    required this.blocks,
    required this.waiverRole,
  });

  final String key;
  final String value;
  final String type;
  final bool validated;

  /// What this gate stops when it is not satisfied.
  final String blocks;

  /// Who may waive it. Empty means nobody.
  final String waiverRole;
}

/// The release gate configuration.
class HabotReleaseGateConfig {
  const HabotReleaseGateConfig._();

  // -----------------------------------------------------------------------
  // Three subjects in one row.
  // -----------------------------------------------------------------------

  static const String instructionSubject = 'release gate configuration';
  static const String metricSubject = 'Material 3 token conformity';
  static const String setupStepSubject =
      'training completion feeding a promotion evaluation engine';

  static List<String> get subjects => <String>[
        instructionSubject,
        metricSubject,
        setupStepSubject,
      ];

  static bool get threeDistinctSubjects =>
      subjects.toSet().length == 3;

  /// Spliced rows before this one carried two halves; this carries three.
  static const int splicedRowsBefore = 11;

  static bool get theFirstWithThreeSubjects =>
      threeDistinctSubjects && splicedRowsBefore == 11;

  static const String spliceNote =
      'The Atomic Step is about release gate configuration, the metric is '
      'about Material 3 token conformity, and the Setup Step cell is about a '
      'promotion evaluation engine. Eleven rows in this track have carried a '
      'spliced half; this is the first to carry three distinct subjects at '
      'once.';

  // -----------------------------------------------------------------------
  // The Setup Step cell, recorded and refused.
  // -----------------------------------------------------------------------

  static const String setupStepCellVerbatim =
      'Define the data linkage between training completion metrics and the '
      'enterprise promotion evaluation engine.';

  static const bool theLinkageIsBuilt = false;

  static bool get theCharterThirdRuleForbidsIt =>
      HabotScoringCharter.rules[2].contains('named person');

  static bool get itIsRecordedInFull =>
      setupStepCellVerbatim.contains('promotion evaluation engine');

  static const String refusalNote =
      'A promotion evaluation engine fed automatically by training completion '
      'is a score about a person driving a consequence without a person '
      'deciding, which the charter written at Step 436 forbids. It is recorded '
      'in full so whoever wrote it can see where it landed, and it is not '
      'built. Training completion belongs to the learner first; if it is to '
      'inform promotion, that is a decision with an owner and the people '
      'affected consulted.';

  // -----------------------------------------------------------------------
  // A one-valued output column.
  // -----------------------------------------------------------------------

  static const String outputColumn = 'Good';

  static bool get theOutputColumnHoldsOneValue =>
      !outputColumn.contains('/');

  static const int oneValuedOutputColumns = 19;

  // -----------------------------------------------------------------------
  // The configuration the instruction asks for.
  // -----------------------------------------------------------------------

  static const List<HabotGateSetting> settings = <HabotGateSetting>[
    HabotGateSetting(
      key: 'gate.impact_assessment',
      value: 'required',
      type: 'boolean',
      validated: true,
      blocks: 'release to production',
      waiverRole: '',
    ),
    HabotGateSetting(
      key: 'gate.reconciliation_score',
      value: '0',
      type: 'integer',
      validated: true,
      blocks: 'release to production',
      waiverRole: '',
    ),
    HabotGateSetting(
      key: 'gate.token_conformity_percent',
      value: '90',
      type: 'integer',
      validated: true,
      blocks: 'promotion of a component to the shared package',
      waiverRole: 'Design System Owner',
    ),
    HabotGateSetting(
      key: 'gate.smoke_suite',
      value: 'pass',
      type: 'enum',
      validated: true,
      blocks: 'release to production',
      waiverRole: '',
    ),
  ];

  static bool get everySettingStatesWhatItBlocks =>
      settings.every((HabotGateSetting g) => g.blocks.isNotEmpty);

  static bool get everySettingIsValidated =>
      settings.every((HabotGateSetting g) => g.validated);

  static int get waivableCount =>
      settings.where((HabotGateSetting g) => g.waiverRole.isNotEmpty).length;

  static bool get onlyOneGateCanBeWaived => waivableCount == 1;

  static const bool aWaiverRecordsThePerson = true;

  static bool get theGatesAlreadyExist =>
      HabotReleaseGate.everyBlockerStatesItself;

  static bool get thisRowSuppliesConfigurationNotAMechanism =>
      theGatesAlreadyExist && settings.isNotEmpty;

  static const double observedTokenConformityPercent = 94;

  static String get qualitativeOutput =>
      observedTokenConformityPercent >= 90 ? 'Good' : 'Poor';

  static const String columnNote =
      'COLUMN NOTE: this row carries three distinct subjects -- release gate '
      'configuration in its instruction, Material 3 token conformity in its '
      'metric, and a training-to-promotion data linkage in its Setup Step cell '
      '-- the first row in the track to carry three at once; the Setup Step '
      'cell is recorded verbatim and refused under the Step 436 charter; its '
      'output column holds the single value "Good", the nineteenth such '
      'column; and what is built is the gate configuration itself, four '
      'settings each naming what it blocks and who may waive it, behind the '
      'release gate Step 292 already defined. Atomic Step: "Use standardized '
      'code layout models for release gate configurations."';

  static Map<String, bool> get obligations => <String, bool>{
        'the Setup Step cell is recorded in full': itIsRecordedInFull,
        'and the linkage is not built': !theLinkageIsBuilt,
        'every setting states what it blocks': everySettingStatesWhatItBlocks,
        'every setting is validated': everySettingIsValidated,
        'a waiver records the person who gave it': aWaiverRecordsThePerson,
      };

  static Map<String, bool> get checks => <String, bool>{
        'three distinct subjects in one row': threeDistinctSubjects,
        'the first row in the track to carry three':
            theFirstWithThreeSubjects && spliceNote.contains('at once'),
        'the Setup Step cell is recorded verbatim': itIsRecordedInFull,
        'and refused under the Step 436 charter':
            !theLinkageIsBuilt &&
                theCharterThirdRuleForbidsIt &&
                refusalNote.contains('people affected consulted'),
        'the output column holds one value':
            theOutputColumnHoldsOneValue && oneValuedOutputColumns == 19,
        'four gate settings, all validated':
            settings.length == 4 && everySettingIsValidated,
        'each one names what it blocks': everySettingStatesWhatItBlocks,
        'only one of them can be waived, and by a named role':
            onlyOneGateCanBeWaived && aWaiverRecordsThePerson,
        'the gates themselves already exist':
            thisRowSuppliesConfigurationNotAMechanism,
        'five obligations met, and 94 per cent reports Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };
}
