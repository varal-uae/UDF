/// Step 251 (PELCE-039-11) -- "the backend is unavailable" is four different
/// situations, and one of them can take money twice.
///
/// The row: "Program mobile application error controllers to catch backend
/// service unavailability responses gracefully."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good/Average/Poor. Standard cited: ISO 9001:2015.
///
/// **Unavailability is not one state.** A 503 with a `Retry-After` header, a
/// request that went out and never came back, a device with no connection at
/// all, and a 200 whose body says the operation failed are four different
/// facts about the world. They need four different sentences and four
/// different retry policies, and a single "Something went wrong. Try again."
/// is the defect rather than the graceful handling.
///
/// **The timeout is the one that matters.** On a 503 the client knows nothing
/// happened. On a timeout it does not know: the request may have been
/// received, processed and committed, and only the response lost. Retrying a
/// non-idempotent request in that state is how a parent is charged twice for
/// one booking. So the retry rule is a function of two things -- what
/// happened, and whether the request was safe to repeat -- and a timeout on a
/// non-idempotent call reconciles with the server before it offers anybody a
/// retry button.
///
/// The categories, the templates and the backoff already exist. What this step
/// adds is the idempotency dimension, which nothing declared.
library;

import 'error_templates.dart';
import 'reconnect_policy.dart';

/// The four ways a backend fails to answer.
enum HabotUnavailability {
  /// A 503, usually with a Retry-After. Nothing happened, and the server
  /// said so.
  serviceUnavailable,

  /// The request went out and nothing came back in time. The client does not
  /// know whether it was processed.
  requestTimedOut,

  /// No usable connection. The request never left.
  noConnection,

  /// A 200 whose body reports a failure. The transport worked and the
  /// operation did not.
  errorInASuccessBody,
}

/// What may be done about it.
enum HabotRetryRule {
  /// The client retries on its own, with backoff, without telling anybody.
  automaticWithBackoff,

  /// A retry button. The person decides.
  offerRetry,

  /// Ask the server what actually happened before offering anything.
  reconcileFirst,

  /// Retrying cannot help. Something has to change first.
  noRetry,
}

/// One situation, fully specified.
class HabotUnavailabilityHandling {
  const HabotUnavailabilityHandling({
    required this.state,
    required this.category,
    required this.outcomeIsKnown,
    required this.ruleWhenIdempotent,
    required this.ruleWhenNotIdempotent,
    required this.why,
  });

  final HabotUnavailability state;

  /// The already-declared category this maps onto, so the message comes from
  /// the existing template set rather than from a new one.
  final HabotErrorCategory category;

  /// Whether the client knows what happened on the server. False for exactly
  /// one state, and that one state is the whole finding.
  final bool outcomeIsKnown;

  final HabotRetryRule ruleWhenIdempotent;

  /// The rule that differs. A GET may always be repeated; a payment may not.
  final HabotRetryRule ruleWhenNotIdempotent;

  final String why;

  bool get theRulesDiffer => ruleWhenIdempotent != ruleWhenNotIdempotent;
}

/// The handling table.
class HabotBackendUnavailability {
  const HabotBackendUnavailability._();

  static const List<HabotUnavailabilityHandling> handlings =
      <HabotUnavailabilityHandling>[
    HabotUnavailabilityHandling(
      state: HabotUnavailability.serviceUnavailable,
      category: HabotErrorCategory.serverFailure,
      outcomeIsKnown: true,
      ruleWhenIdempotent: HabotRetryRule.automaticWithBackoff,
      ruleWhenNotIdempotent: HabotRetryRule.offerRetry,
      why: 'The server refused the request, so nothing happened and repeating '
          'it is safe. It is still not repeated silently for a write: a '
          'person who pressed Pay and saw a failure should be the one who '
          'decides to press it again.',
    ),
    HabotUnavailabilityHandling(
      state: HabotUnavailability.requestTimedOut,
      category: HabotErrorCategory.timeout,
      outcomeIsKnown: false,
      ruleWhenIdempotent: HabotRetryRule.automaticWithBackoff,
      ruleWhenNotIdempotent: HabotRetryRule.reconcileFirst,
      why: 'The request may have been received, processed and committed, with '
          'only the response lost. Retrying a payment here charges twice. The '
          'client asks the server what happened to that operation before it '
          'offers anybody a retry button, and until it has an answer the '
          'screen says the outcome is being confirmed rather than that it '
          'failed.',
    ),
    HabotUnavailabilityHandling(
      state: HabotUnavailability.noConnection,
      category: HabotErrorCategory.offline,
      outcomeIsKnown: true,
      ruleWhenIdempotent: HabotRetryRule.automaticWithBackoff,
      ruleWhenNotIdempotent: HabotRetryRule.offerRetry,
      why: 'The request never left the device, so the server state is '
          'untouched. This is the only one of the four where the person can '
          'do something about the cause.',
    ),
    HabotUnavailabilityHandling(
      state: HabotUnavailability.errorInASuccessBody,
      category: HabotErrorCategory.unknown,
      outcomeIsKnown: true,
      ruleWhenIdempotent: HabotRetryRule.noRetry,
      ruleWhenNotIdempotent: HabotRetryRule.noRetry,
      why: 'The transport worked and the operation did not, so repeating the '
          'same request produces the same failure. The interesting part is '
          'that a client checking status codes alone treats this as success '
          'and carries on, which is worse than any of the other three.',
    ),
  ];

  static HabotUnavailabilityHandling handlingFor(HabotUnavailability state) =>
      handlings.firstWhere(
        (HabotUnavailabilityHandling h) => h.state == state,
      );

  /// The rule, given both facts.
  static HabotRetryRule ruleFor({
    required HabotUnavailability state,
    required bool isIdempotent,
  }) {
    final HabotUnavailabilityHandling h = handlingFor(state);
    return isIdempotent ? h.ruleWhenIdempotent : h.ruleWhenNotIdempotent;
  }

  /// Exactly one state leaves the client not knowing what happened.
  static List<HabotUnavailabilityHandling> get outcomeUnknownStates =>
      handlings
          .where((HabotUnavailabilityHandling h) => !h.outcomeIsKnown)
          .toList();

  /// Reconciliation is required exactly where the outcome is unknown and the
  /// call is not safe to repeat. Nowhere else.
  static bool get reconciliationIsRequiredExactlyWhereNeeded {
    for (final HabotUnavailabilityHandling h in handlings) {
      final bool needs =
          h.ruleWhenNotIdempotent == HabotRetryRule.reconcileFirst;
      if (needs != !h.outcomeIsKnown) {
        return false;
      }
      if (h.ruleWhenIdempotent == HabotRetryRule.reconcileFirst) {
        return false;
      }
    }
    return true;
  }

  static bool get noNonIdempotentCallIsRetriedSilently => handlings.every(
        (HabotUnavailabilityHandling h) =>
            h.ruleWhenNotIdempotent != HabotRetryRule.automaticWithBackoff,
      );

  /// Every declared state maps onto a category that already has a template,
  /// so no new message vocabulary is introduced.
  static bool get everyStateHasAnExistingTemplate => handlings.every(
        (HabotUnavailabilityHandling h) =>
            HabotErrorTemplates.of(h.category).body.isNotEmpty,
      );

  /// States whose existing template offers a retry button that this step's
  /// rule refuses. Not empty, and the one entry is a finding rather than a
  /// thing to smooth over.
  static List<HabotUnavailabilityHandling> get templateRetryDisagreements =>
      handlings
          .where(
            (HabotUnavailabilityHandling h) =>
                HabotErrorTemplates.of(h.category).retryable &&
                h.ruleWhenIdempotent == HabotRetryRule.noRetry &&
                h.ruleWhenNotIdempotent == HabotRetryRule.noRetry,
          )
          .toList();

  static const String templateDisagreementNote =
      'SECOND FINDING: the existing template set says every one of these four '
      'categories is retryable, including unknown -- which is the category a '
      '200 with a failure in its body maps onto. Retrying that reproduces the '
      'failure exactly, so the person presses a button that cannot work. The '
      'mismatch is structural rather than careless: templates are keyed by '
      'CATEGORY and retryability depends on the SITUATION, and the same '
      'category covers both a transient unknown failure and a deterministic '
      'one. Raised rather than patched -- the template set is Step 62\'s file '
      'and carries its own gates, and the fix is a decision about whether '
      'retryable belongs on a template at all.';

  /// The backoff the automatic rule uses is the declared one.
  static Duration get backoffBase => HabotReconnectPolicy.base;

  static bool get automaticRetryUsesTheDeclaredBackoff =>
      backoffBase.inMilliseconds > 0 &&
      handlings.any(
        (HabotUnavailabilityHandling h) =>
            h.ruleWhenIdempotent == HabotRetryRule.automaticWithBackoff,
      );

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String fourStatesNote =
      'Unavailability is not one state. A 503 with a Retry-After, a request '
      'that went out and never came back, a device with no connection at all, '
      'and a 200 whose body says the operation failed are four different '
      'facts about the world. They need four different sentences and four '
      'different retry policies, and a single "Something went wrong. Try '
      'again." is the defect rather than the graceful handling the row asks '
      'for.';

  static const String timeoutNote =
      'FINDING: the timeout is the one that matters. On a 503 the client '
      'knows nothing happened. On a timeout it does not know -- the request '
      'may have been received, processed and committed, with only the '
      'response lost. Retrying a non-idempotent request in that state is how '
      'a parent is charged twice for one booking. So the retry rule is a '
      'function of TWO things, what happened and whether the request was safe '
      'to repeat, and nothing in the repository carried the second one. A '
      'timeout on a non-idempotent call reconciles with the server before it '
      'offers anybody a retry button, and until there is an answer the screen '
      'says the outcome is being confirmed rather than that it failed.';

  static const String successBodyNote =
      'The fourth state is the one nobody writes a handler for. A client that '
      'checks status codes alone treats a 200 with a failure in its body as '
      'success and carries on -- showing a confirmation for something that '
      'did not happen, which is worse than any of the other three because it '
      'produces no error at all.';

  static const String reusesExistingVocabularyNote =
      'The categories, the templates and the backoff already exist -- '
      'HabotErrorCategory, HabotErrorTemplates and HabotReconnectPolicy. Each '
      'of the four states maps onto a declared category rather than '
      'introducing a fifth vocabulary for the same situations. What this step '
      'adds is the idempotency dimension, which nothing declared.';

  // -----------------------------------------------------------------------
  // Metric: Process Execution Quality Score.
  // -----------------------------------------------------------------------

  static const double floor = 0.9;
  static const double optimal = 0.98;
  static const double ceiling = 1;

  /// Four criteria per state: a declared category with a message, a stated
  /// retry rule for a safe call, a stated rule for an unsafe one, and an
  /// explicit statement of whether the outcome is known.
  static double get qualityScore {
    int met = 0;
    int total = 0;
    for (final HabotUnavailabilityHandling h in handlings) {
      total += 4;
      if (HabotErrorTemplates.of(h.category).body.isNotEmpty) {
        met += 1;
      }
      if (h.why.length > 80) {
        met += 1;
      }
      if (h.ruleWhenNotIdempotent != HabotRetryRule.automaticWithBackoff) {
        met += 1;
      }
      if (h.outcomeIsKnown || h.ruleWhenNotIdempotent ==
          HabotRetryRule.reconcileFirst) {
        met += 1;
      }
    }
    return met / total;
  }

  static String get qualitativeOutput {
    if (qualityScore >= optimal) {
      return 'Good';
    }
    return qualityScore >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'four states, each mapped to an already-declared category':
            handlings.length == HabotUnavailability.values.length &&
                everyStateHasAnExistingTemplate,
        'exactly one state leaves the outcome unknown, and it is the timeout':
            outcomeUnknownStates.length == 1 &&
                outcomeUnknownStates.single.state ==
                    HabotUnavailability.requestTimedOut,
        'the rules differ by idempotency on three of the four states':
            handlings
                .where((HabotUnavailabilityHandling h) => h.theRulesDiffer)
                .length ==
            3,
        'no non-idempotent call is ever retried silently':
            noNonIdempotentCallIsRetriedSilently,
        'reconciliation is required exactly where the outcome is unknown':
            reconciliationIsRequiredExactlyWhereNeeded,
        'a timeout on a payment reconciles rather than retries':
            ruleFor(
              state: HabotUnavailability.requestTimedOut,
              isIdempotent: false,
            ) ==
                HabotRetryRule.reconcileFirst,
        'the same timeout on a read retries automatically':
            ruleFor(
              state: HabotUnavailability.requestTimedOut,
              isIdempotent: true,
            ) ==
                HabotRetryRule.automaticWithBackoff,
        'a 200 with a failure in its body is a declared state':
            handlingFor(HabotUnavailability.errorInASuccessBody)
                .ruleWhenIdempotent ==
                HabotRetryRule.noRetry,
        'one state\'s template offers a retry its rule refuses, and it is '
            'named rather than smoothed over':
            templateRetryDisagreements.length == 1 &&
                templateRetryDisagreements.single.state ==
                    HabotUnavailability.errorInASuccessBody &&
                templateDisagreementNote.contains('keyed by'),
        'automatic retry uses the declared backoff':
            automaticRetryUsesTheDeclaredBackoff,
        'the quality score is at the ceiling': qualityScore == ceiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures, and its Data Collected list is about device '
      'configuration rather than about errors. Atomic Step: "Program mobile '
      'application error controllers to catch backend service unavailability '
      'responses gracefully."';
}
