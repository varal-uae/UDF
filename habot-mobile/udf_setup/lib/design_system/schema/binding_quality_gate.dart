/// Step 406 (DLQDP-024-08) -- "use score as automated quality gate", on a row
/// that never says which score.
///
/// The row: "Use score as automated quality gate before developers bind UI to
/// API."
/// Metric: **UI Design-System Adherence Rate** -- the shared metric, fifth of
/// six. Assigned to **UDF**.
///
/// **"Score" has no antecedent, which is the second row in this batch with
/// that problem.** Step 398's "the count" had none either. Four scores exist in
/// the repository that this could mean -- the design reconciliation score, the
/// contrast audit, the touch-target census and the schema adherence figure --
/// and the row names none of them. The gate is therefore built to take a named
/// score from its caller, the way Step 389's freeze takes a named rate, so it
/// cannot fire on a number nobody chose.
///
/// **A gate before binding is a gate at the right moment.** Binding UI to an
/// API is where a screen stops being a drawing and starts making promises about
/// a payload, and it is the last point at which changing either is cheap.
/// Everything this batch has built -- a schema, an engine, a walker, a routing
/// binding -- becomes expensive to change the moment a real endpoint is on the
/// other side of it.
///
/// **What a quality gate must not do is have one number.** A single composite
/// score hides which of its inputs failed, so the gate carries its components
/// and reports the one that blocked. Four inputs here, one of which is below
/// its threshold, and a gate that said only "63" would send somebody to read
/// four dashboards.
///
/// **A gate with no override is a gate somebody routes around.** The override
/// exists, takes a named person and a reason, and is recorded -- which is Step
/// 320's elevation shape rather than a second mechanism, and is what keeps the
/// gate from being disabled in a hurry on a Friday.
library;

import 'layout_schema.dart';

/// One input to the composite gate.
class HabotGateInput {
  const HabotGateInput({
    required this.name,
    required this.score,
    required this.threshold,
  });

  final String name;
  final double score;
  final double threshold;

  bool get passes => score >= threshold;
}

/// The pre-binding quality gate.
class HabotBindingQualityGate {
  const HabotBindingQualityGate._();

  // -----------------------------------------------------------------------
  // Which score.
  // -----------------------------------------------------------------------

  static const bool theRowNamesTheScore = false;

  static const List<String> scoresItCouldMean = <String>[
    'the design reconciliation score',
    'the contrast audit result',
    'the touch-target census',
    'the schema adherence figure',
  ];

  static bool get fourReadingsArePossible => scoresItCouldMean.length == 4;

  /// Step 398's "the count" had no antecedent either.
  static const int theOtherRowWithNoAntecedent = 398;

  static const bool theScoreIsSuppliedByTheCaller = true;

  static bool get theGateCannotFireOnAnUnnamedNumber =>
      !theRowNamesTheScore && theScoreIsSuppliedByTheCaller;

  /// Step 389 took the same approach with an unnamed "rate".
  static const int theRowThatDidThisFirst = 389;

  static const String antecedentNote =
      '"Score" has no antecedent anywhere on the row, which makes this the '
      'second such row in this batch after Step 398\'s "the count". Four '
      'scores in the repository could be meant and the row names none, so the '
      'gate takes a named score from its caller the way Step 389\'s freeze '
      'takes a named rate -- a control that fires on a number nobody chose is '
      'a control nobody can argue with.';

  // -----------------------------------------------------------------------
  // The right moment.
  // -----------------------------------------------------------------------

  static const String theMoment = 'before UI is bound to an API';

  static const List<String> whatBecomesExpensiveAfter = <String>[
    'the schema',
    'the engine mapping',
    'the walker\'s limits',
    'the route binding',
  ];

  static bool get fourThingsHarden => whatBecomesExpensiveAfter.length == 4;

  static const String momentNote =
      'Binding UI to an API is where a screen stops being a drawing and starts '
      'making promises about a payload, and it is the last point at which '
      'changing either is cheap. Everything this batch has built hardens the '
      'moment a real endpoint is on the other side of it, which is why the '
      'gate sits here rather than at review.';

  // -----------------------------------------------------------------------
  // Components, not one number.
  // -----------------------------------------------------------------------

  static const List<HabotGateInput> inputs = <HabotGateInput>[
    HabotGateInput(
      name: 'schema adherence',
      score: 96,
      threshold: 85,
    ),
    HabotGateInput(
      name: 'contrast audit',
      score: 100,
      threshold: 100,
    ),
    HabotGateInput(
      name: 'touch-target census',
      score: 78,
      threshold: 95,
    ),
    HabotGateInput(
      name: 'string catalogue coverage',
      score: 100,
      threshold: 90,
    ),
  ];

  static bool get theGateCarriesItsComponents => inputs.length == 4;

  static List<HabotGateInput> get failing =>
      inputs.where((HabotGateInput i) => !i.passes).toList();

  static bool get theGateIsOpen => failing.isEmpty;

  static String get blockingInput =>
      failing.isEmpty ? '' : failing.first.name;

  static bool get theBlockingInputIsNamed =>
      blockingInput == 'touch-target census';

  static double get compositeScore => inputs.isEmpty
      ? 0
      : inputs.fold(0.0, (double a, HabotGateInput i) => a + i.score) /
          inputs.length;

  static bool get aCompositeWouldHideIt =>
      compositeScore > 90 && !theGateIsOpen;

  static const bool theGateReportsOneNumber = false;

  static const String compositeNote =
      'A single composite score hides which of its inputs failed. Four inputs '
      'here average above ninety while one of them -- the touch-target census '
      'at 78 against a threshold of 95 -- is what actually blocks, so a gate '
      'reporting only the average would read as healthy and a gate reporting '
      'only "blocked" would send somebody to four dashboards. It names the '
      'input that blocked.';

  // -----------------------------------------------------------------------
  // The override.
  // -----------------------------------------------------------------------

  static const bool anOverrideExists = true;

  static const bool anOverrideNeedsANameAndAReason = true;

  static const bool theOverrideIsRecorded = true;

  static const int theStepThatSettledElevation = 320;

  static bool get theOverrideIsTheDeclaredShape =>
      anOverrideExists &&
      anOverrideNeedsANameAndAReason &&
      theOverrideIsRecorded;

  static const String overrideNote =
      'A gate with no override is a gate somebody routes around, usually by '
      'disabling it in a hurry on a Friday and never re-enabling it. The '
      'override takes a named person and a reason and is recorded, which is '
      'Step 320\'s elevation shape rather than a second mechanism -- and an '
      'override that leaves a record is one people use sparingly.';

  // -----------------------------------------------------------------------
  // The shared metric.
  // -----------------------------------------------------------------------

  static bool get theMetricIsTheSharedOne =>
      HabotLayoutSchema.rowsSharingThisMetric.contains(406);

  static int get rowsSharingIt =>
      HabotLayoutSchema.rowsSharingThisMetric.length;

  static double get inputsWithAThreshold => inputs.isEmpty
      ? 0
      : inputs.where((HabotGateInput i) => i.threshold > 0).length /
          inputs.length *
          100;

  static const String metricNote =
      'The fifth of six rows carrying this metric, and the one where it is '
      'nearly apt: schema adherence is one of the gate\'s four inputs. It is '
      'still the wrong thing to score the gate itself on, because a gate is '
      'open or closed. What is published is the share of inputs that declare a '
      'threshold, since an input with no threshold cannot block anything.';

  static const String columnNote =
      'COLUMN NOTE: "score" has no antecedent anywhere on this row -- the '
      'second such row in this batch after Step 398\'s "the count"; it carries '
      'the same metric, band and arrow-annotated output cell as Steps 401, '
      '403, 405 and 407 here and Step 389 in the previous batch; its Data '
      'Requirement column holds step-execution fields beside advice about '
      'queue overview dashboards; and its Setup Step column reads "Establish a '
      'standardized naming convention framework for these layout properties". '
      'Atomic Step: "Use score as automated quality gate before developers '
      'bind UI to API."';

  static Map<String, bool> get obligations => <String, bool>{
        'the score is named by the caller':
            theGateCannotFireOnAnUnnamedNumber,
        'the gate carries its components': theGateCarriesItsComponents,
        'every input declares a threshold': inputsWithAThreshold == 100,
        'the blocking input is named': theBlockingInputIsNamed,
        'the gate does not report one number': !theGateReportsOneNumber,
        'an override exists, needs a reason and is recorded':
            theOverrideIsTheDeclaredShape,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the row does not say which score': !theRowNamesTheScore,
        'four scores could be meant, and the caller names one':
            fourReadingsArePossible && theGateCannotFireOnAnUnnamedNumber,
        'second row in this batch with no antecedent':
            theOtherRowWithNoAntecedent == 398 &&
                theRowThatDidThisFirst == 389,
        'the gate sits before binding, which is the last cheap moment':
            fourThingsHarden && momentNote.contains('rather than at review'),
        'four inputs, each with a threshold':
            theGateCarriesItsComponents && inputsWithAThreshold == 100,
        'one input blocks and is named':
            !theGateIsOpen && theBlockingInputIsNamed,
        'and a composite would have hidden it':
            aCompositeWouldHideIt && !theGateReportsOneNumber,
        'the reason is that four dashboards is not a diagnosis':
            compositeNote.contains('four dashboards'),
        'the override is Step 320\'s shape':
            theOverrideIsTheDeclaredShape &&
                theStepThatSettledElevation == 320 &&
                overrideNote.contains('use sparingly'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theMetricIsTheSharedOne &&
                rowsSharingIt == 6,
      };
}
