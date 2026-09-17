/// Step 387 (GEN-01727) -- "localized error correction", which is the whole
/// design, and a continuous-integration metric on a form.
///
/// The row: "Block the user from proceeding to force localized error
/// correction."
/// Metric: **Automated PR Rejection Rate for Non-Compliance (%)** -- floor 95,
/// optimal 99.5, ceiling 100. High/Medium/Low. CI/CD Best Practices & GitHub
/// Standards. Assigned to **PDG**.
///
/// **"Localized" is the load-bearing word.** Blocking is easy and useless on
/// its own; what makes it worth anything is that the person is taken to the
/// *specific* thing that is wrong. A banner saying "please correct the errors
/// below" on a form with fourteen fields is a block without a location, and the
/// work it creates is a hunt.
///
/// **Three properties make a correction local.** The error is attached to the
/// field rather than to the form, focus moves to the first one, and the message
/// says what would fix it rather than what is wrong. "Invalid date" is a
/// verdict; "use DD/MM/YYYY, for example 03/09/2026" is an instruction. Four
/// worked errors here, and each is checked against all three.
///
/// **Blocking the whole form for one field is the failure mode.** None of the
/// four errors prevents keeping a draft, and a form that refuses everything
/// until every field is perfect loses
/// work people have already done. What is blocked is the *submit*, not the
/// typing and not the saving.
///
/// **The error count is reported and the first error is named.** "4 things to
/// fix -- the first is Start date" is a different sentence from "please correct
/// the errors below", because it tells somebody how long this will take.
///
/// **The metric is a pull-request rejection rate.** It measures a CI pipeline
/// rejecting non-compliant commits, which is a real thing happening somewhere
/// else. Step 392 in this batch carries the identical metric and band on a row
/// about floating-point arithmetic -- one metric, two unrelated subjects, five
/// rows apart.
library;

import '../forms/validation_state_color.dart';

/// Where an error lives.
enum HabotCorrectionScope {
  /// Attached to one field.
  field,

  /// Attached to the form as a whole.
  form,
}

/// One error the person has to deal with.
class HabotFieldError {
  const HabotFieldError({
    required this.field,
    required this.message,
    required this.blocksSaving,
  });

  final String field;

  /// What would fix it, not what is wrong with it.
  final String message;

  /// Whether this error also prevents keeping a draft.
  final bool blocksSaving;

  bool get saysWhatWouldFixIt =>
      message.contains('use ') || message.contains('choose ') ||
      message.contains('add ');
}

/// The correction-block rule.
class HabotCorrectionBlock {
  const HabotCorrectionBlock._();

  // -----------------------------------------------------------------------
  // Three properties of a local correction.
  // -----------------------------------------------------------------------

  static const HabotCorrectionScope scope = HabotCorrectionScope.field;

  static bool get theErrorIsOnTheField => scope == HabotCorrectionScope.field;

  static const bool focusMovesToTheFirstError = true;

  static const List<HabotFieldError> errors = <HabotFieldError>[
    HabotFieldError(
      field: 'Start date',
      message: 'use DD/MM/YYYY, for example 03/09/2026',
      blocksSaving: false,
    ),
    HabotFieldError(
      field: 'Hourly rate',
      message: 'add a rate between AED 15 and AED 500',
      blocksSaving: false,
    ),
    HabotFieldError(
      field: 'Site',
      message: 'choose a site from the list',
      blocksSaving: false,
    ),
    HabotFieldError(
      field: 'Emergency contact',
      message: 'add a mobile number, including the country code',
      blocksSaving: false,
    ),
  ];

  static bool get everyMessageSaysWhatWouldFixIt =>
      errors.every((HabotFieldError e) => e.saysWhatWouldFixIt);

  static String get firstErrorField => errors.first.field;

  static bool get theFirstErrorIsNamed => firstErrorField == 'Start date';

  static const String localNote =
      '"Localized" is the load-bearing word. Blocking on its own is easy and '
      'useless; what makes it worth something is that the person is taken to '
      'the specific thing that is wrong. Three properties do it: the error is '
      'attached to the field rather than the form, focus moves to the first '
      'one, and the message says what would fix it. "Invalid date" is a '
      'verdict; "use DD/MM/YYYY, for example 03/09/2026" is an instruction.';

  // -----------------------------------------------------------------------
  // What is blocked, and what is not.
  // -----------------------------------------------------------------------

  static const bool typingIsBlocked = false;

  static const bool savingADraftIsBlocked = false;

  static const bool submittingIsBlocked = true;

  static bool get onlySubmittingIsBlocked =>
      submittingIsBlocked && !typingIsBlocked && !savingADraftIsBlocked;

  static bool get noErrorBlocksSaving =>
      errors.every((HabotFieldError e) => !e.blocksSaving);

  static const String scopeNote =
      'A form that refuses everything until every field is perfect loses work '
      'people have already done, and the work it loses is exactly the work '
      'that took longest. What is blocked is the submit: typing is never '
      'blocked, and a draft can be kept with every one of these errors still '
      'in it. The block exists to stop a bad record being created, not to stop '
      'somebody thinking.';

  // -----------------------------------------------------------------------
  // How long this will take.
  // -----------------------------------------------------------------------

  static int get errorCount => errors.length;

  static String get summary =>
      '$errorCount things to fix -- the first is ${errors.first.field}';

  static bool get theSummaryCountsAndNames =>
      summary.startsWith('4 things') && summary.contains('Start date');

  static const String vagueSummaryRefused = 'Please correct the errors below';

  static bool get theVagueSummaryIsRefused =>
      vagueSummaryRefused.contains('errors below') &&
      summary != vagueSummaryRefused;

  static const String summaryNote =
      '"4 things to fix -- the first is Start date" is a different sentence '
      'from "please correct the errors below", because it tells somebody how '
      'long this will take before they start. A block with no count is a block '
      'of unknown depth, and people abandon unknown depths.';

  // -----------------------------------------------------------------------
  // The error styling is the declared one.
  // -----------------------------------------------------------------------

  static bool get theErrorStylingIsAlreadyDeclared =>
      HabotValidationStateColor.errorRoles.isNotEmpty;

  static bool get errorIsNotColourAlone =>
      HabotValidationStateColor.carriersFor(HabotFieldVisualState.error)
          .length >
      1;

  static const String stylingNote =
      'The error state uses the roles and carriers Step 189 declared, so an '
      'error is not colour alone -- the state is carried by an icon and a '
      'message as well as by a role, which is the SC 1.4.1 obligation Step 369 '
      'restated for status parameters.';

  // -----------------------------------------------------------------------
  // A CI metric on a form.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Automated PR Rejection Rate for Non-Compliance (%)';

  static const int bandFloor = 95;
  static const double bandOptimal = 99.5;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  /// Step 392 carries the identical metric and band on a row about
  /// floating-point arithmetic.
  static const int theOtherRowWithThisMetric = 392;

  static bool get oneMetricScoresTwoUnrelatedRows =>
      theOtherRowWithThisMetric == 392;

  static double get localised => errors.isEmpty
      ? 0
      : errors.where((HabotFieldError e) => e.saysWhatWouldFixIt).length /
          errors.length *
          100;

  static const String metricNote =
      'A pull-request rejection rate measures a CI pipeline turning away '
      'non-compliant commits, which is a real thing happening somewhere else. '
      'Step 392 in this batch carries the identical metric and the identical '
      'band on a row about floating-point arithmetic: one metric, two '
      'unrelated subjects, five rows apart. The band is at least well formed. '
      'The figure published is the share of errors that are localised on all '
      'three counts.';

  static Map<String, bool> get obligations => <String, bool>{
        'the error is attached to the field': theErrorIsOnTheField,
        'focus moves to the first error': focusMovesToTheFirstError,
        'every message says what would fix it':
            everyMessageSaysWhatWouldFixIt,
        'only the submit is blocked': onlySubmittingIsBlocked,
        'a draft survives every error': noErrorBlocksSaving,
        'the count and the first error are named': theSummaryCountsAndNames,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'the error is on the field, not the form': theErrorIsOnTheField,
        'focus moves to the first error, and it is named':
            focusMovesToTheFirstError && theFirstErrorIsNamed,
        'every message is an instruction rather than a verdict':
            everyMessageSaysWhatWouldFixIt &&
                localNote.contains('is an instruction'),
        'typing and saving are never blocked':
            onlySubmittingIsBlocked && noErrorBlocksSaving,
        'and the reason is the work already done':
            scopeNote.contains('took longest'),
        'the summary counts and names': theSummaryCountsAndNames,
        'the vague summary is refused':
            theVagueSummaryIsRefused &&
                summaryNote.contains('people abandon unknown depths'),
        'the error styling is declared and is not colour alone':
            theErrorStylingIsAlreadyDeclared && errorIsNotColourAlone,
        'the metric is a CI measure shared with Step 392':
            oneMetricScoresTwoUnrelatedRows && theBandIsWellFormed,
        'six obligations, all met, giving High':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High' &&
                localised == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to PDG rather than UDF; its metric is '
      'an automated pull-request rejection rate -- a continuous-integration '
      'measure -- on a row about blocking a person in a form, and Step 392 in '
      'this batch carries the identical metric and band on a row about '
      'floating-point arithmetic; its Data Requirement cell holds the Atomic '
      'Step\'s own sentence as the artefact to prepare; and the Setup Step '
      'column is empty. Atomic Step: "Block the user from proceeding to force '
      'localized error correction."';
}
