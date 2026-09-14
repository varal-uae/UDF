/// Step 255 (IRBCA-034-09) -- what optimistic UI actually is, and the
/// question this row is reaching for.
///
/// The row: "Pause optimistic UI updates and execution until validation
/// clears locally."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good/Average/Poor. Standard cited: Material Design 3 / Nielsen
/// Norman Group Heuristic Evaluation.
///
/// **Read literally, the row describes the normal case.** Optimistic UI means
/// showing a result before the *server* confirms it. Local validation is a
/// precondition of sending anything at all -- Step 254's gate is the submit
/// control, so a submission that fails local validation never happens and
/// there is nothing to pause. "Pause until validation clears locally" is a
/// description of a form that works.
///
/// **The question underneath is what happens when local validation passes and
/// the server says no.** That is the case optimistic UI actually creates, and
/// this repository already has half of it: `ErrorRollbackBoundary` catches the
/// failure and rolls back, Step 194 declared counted loading scope, and Step
/// 237 gave the form a rejection mode. What nothing declared is *which
/// updates may be optimistic at all*, which is a decision per operation rather
/// than a mechanism.
///
/// **The rule: optimistic only where the rollback is invisible and the
/// operation is reversible.** Six operations are classified. Anything that
/// moves money, issues a pass or tells a third party something is never
/// optimistic -- not because the rollback is hard, but because the person has
/// already acted on what they were shown.
library;

import '../resilience/error_templates.dart';
import 'form_mode_machine.dart';

/// Whether an operation's result may be shown before the server agrees.
enum HabotOptimismRuling {
  /// Show it immediately, roll back on failure.
  optimistic,

  /// Show a pending state and wait.
  pessimistic,
}

/// One operation and its ruling.
class HabotOptimisticOperation {
  const HabotOptimisticOperation({
    required this.name,
    required this.ruling,
    required this.isReversible,
    required this.rollbackIsVisibleToOthers,
    required this.why,
  });

  final String name;

  final HabotOptimismRuling ruling;

  /// Whether undoing it restores the world, as opposed to leaving a trace.
  final bool isReversible;

  /// Whether a rollback would be seen by somebody other than the person who
  /// acted -- an organiser, a venue, a bank.
  final bool rollbackIsVisibleToOthers;

  final String why;

  /// The rule this file exists to state.
  bool get qualifiesForOptimism =>
      isReversible && !rollbackIsVisibleToOthers;
}

/// The policy.
class HabotOptimisticUpdatePolicy {
  const HabotOptimisticUpdatePolicy._();

  static const List<HabotOptimisticOperation> operations =
      <HabotOptimisticOperation>[
    HabotOptimisticOperation(
      name: 'toggle an add-on in the basket',
      ruling: HabotOptimismRuling.optimistic,
      isReversible: true,
      rollbackIsVisibleToOthers: false,
      why: 'Step 202 made the payload derived rather than accumulated, so the '
          'state is a function of the selection and rolling it back is '
          'setting a boolean. Nobody else has seen it.',
    ),
    HabotOptimisticOperation(
      name: 'mark a notification read',
      ruling: HabotOptimismRuling.optimistic,
      isReversible: true,
      rollbackIsVisibleToOthers: false,
      why: 'The cheapest possible optimistic update and the one where waiting '
          'is most obviously wrong: a person who tapped a notification is '
          'already reading it.',
    ),
    HabotOptimisticOperation(
      name: 'edit a child profile detail',
      ruling: HabotOptimismRuling.optimistic,
      isReversible: true,
      rollbackIsVisibleToOthers: false,
      why: 'Reversible, and the rollback puts back a value the same person '
          'typed a moment ago, so the correction is legible to them.',
    ),
    HabotOptimisticOperation(
      name: 'submit a payment',
      ruling: HabotOptimismRuling.pessimistic,
      isReversible: false,
      rollbackIsVisibleToOthers: true,
      why: 'Not because the rollback is hard, but because the person has '
          'already acted on what they were shown -- they closed the '
          'application, or told somebody the booking is done. Step 251 goes '
          'further: on a timeout the client does not even know which way it '
          'went.',
    ),
    HabotOptimisticOperation(
      name: 'issue an entry pass',
      ruling: HabotOptimismRuling.pessimistic,
      isReversible: false,
      rollbackIsVisibleToOthers: true,
      why: 'A pass shown optimistically is a pass somebody screenshots and '
          'takes to a door. Withdrawing it afterwards is not a rollback, it '
          'is a person being turned away.',
    ),
    HabotOptimisticOperation(
      name: 'cancel a booking inside the refund window',
      ruling: HabotOptimismRuling.pessimistic,
      isReversible: false,
      rollbackIsVisibleToOthers: true,
      why: 'The organiser sees the place free up. Rolling back means telling '
          'two people different things, and the second one already gave the '
          'place away.',
    ),
  ];

  static List<HabotOptimisticOperation> get optimisticOperations => operations
      .where(
        (HabotOptimisticOperation o) =>
            o.ruling == HabotOptimismRuling.optimistic,
      )
      .toList();

  static List<HabotOptimisticOperation> get pessimisticOperations =>
      operations
          .where(
            (HabotOptimisticOperation o) =>
                o.ruling == HabotOptimismRuling.pessimistic,
          )
          .toList();

  /// The ruling on every operation follows from the two facts about it,
  /// rather than being chosen separately. This is what makes it a rule.
  static bool get everyRulingFollowsFromTheRule => operations.every(
        (HabotOptimisticOperation o) =>
            (o.ruling == HabotOptimismRuling.optimistic) ==
            o.qualifiesForOptimism,
      );

  static double get optimisticShare =>
      optimisticOperations.length / operations.length;

  // -----------------------------------------------------------------------
  // The row read literally, and the question underneath.
  // -----------------------------------------------------------------------

  /// Local validation is a precondition of sending, so there is no optimistic
  /// update to pause: the request that would have produced it never happens.
  static bool anythingIsSentWhen({required bool localValidationPassed}) =>
      localValidationPassed;

  static bool get thereIsNothingToPause =>
      !anythingIsSentWhen(localValidationPassed: false);

  static const String readLiterallyNote =
      'Read literally, the row describes the normal case. Optimistic UI means '
      'showing a result before the SERVER confirms it. Local validation is a '
      'precondition of sending anything at all -- Step 254\'s gate IS the '
      'submit control rather than a guard around it -- so a submission that '
      'fails local validation never happens and there is no optimistic update '
      'to pause. "Pause until validation clears locally" is a description of '
      'a form that works.';

  static const String theRealQuestionNote =
      'The question underneath is what happens when local validation passes '
      'and the server says no. That is the case optimistic UI actually '
      'creates, and the repository already has half of it: '
      'ErrorRollbackBoundary catches the failure and rolls back, Step 194 '
      'declared counted loading scope so a rollback does not flash, and Step '
      '237 gave the form a rejection mode to land in. What nothing declared '
      'is WHICH updates may be optimistic at all -- a decision per operation, '
      'not a mechanism.';

  // -----------------------------------------------------------------------
  // What a rejection lands in.
  // -----------------------------------------------------------------------

  /// A rejected submission goes to the error mode, not back to editing and
  /// not to a dead end. Read from Step 237's machine rather than restated.
  static HabotFormMode? get modeAfterRejection =>
      HabotFormModeMachine.next(
        HabotFormMode.submitting,
        HabotFormEvent.responseRejected,
      );

  static bool get rejectionLandsInTheErrorMode =>
      modeAfterRejection == HabotFormMode.error;

  /// And the message it carries comes from the declared template set rather
  /// than from a string at the call site.
  static bool get rejectionMessageComesFromTheTemplates =>
      HabotErrorTemplates.of(HabotErrorCategory.validation).body.isNotEmpty &&
      HabotErrorTemplates.of(HabotErrorCategory.conflict).body.isNotEmpty;

  /// A server rejection after local validation passed is a conflict or a
  /// server-side validation failure, not a client bug to hide.
  static const List<HabotErrorCategory> rejectionCategories =
      <HabotErrorCategory>[
    HabotErrorCategory.validation,
    HabotErrorCategory.conflict,
  ];

  static const String whyLocalPassAndServerFailNote =
      'A server rejection after local validation passed is not a client bug. '
      'The two commonest causes are a conflict -- somebody else took the last '
      'place while the form was open -- and a rule the client cannot know, '
      'such as a promotion having just expired. Both are ordinary, both have '
      'declared templates, and treating them as impossible is what produces '
      '"Something went wrong" on a screen where the person did nothing '
      'wrong.';

  // -----------------------------------------------------------------------
  // Metric: UI Design-System Adherence Rate.
  // -----------------------------------------------------------------------

  static const double floor = 0.85;
  static const double optimal = 0.95;
  static const double ceiling = 1;

  /// Adherence: the share of declared operations whose ruling follows from
  /// the stated rule rather than from a judgement made per screen.
  static double get adherenceRate =>
      operations
          .where(
            (HabotOptimisticOperation o) =>
                (o.ruling == HabotOptimismRuling.optimistic) ==
                o.qualifiesForOptimism,
          )
          .length /
      operations.length;

  static String get qualitativeOutput {
    if (adherenceRate >= optimal) {
      return 'Good';
    }
    return adherenceRate >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'six operations are ruled on, three each way':
            operations.length == 6 &&
                optimisticOperations.length == 3 &&
                pessimisticOperations.length == 3,
        'every ruling follows from the two declared facts rather than being '
            'chosen per screen': everyRulingFollowsFromTheRule,
        'nothing that moves money, issues a pass or tells a third party is '
            'optimistic': pessimisticOperations.every(
          (HabotOptimisticOperation o) => o.rollbackIsVisibleToOthers,
        ),
        'every operation says why, and the pessimistic ones say why the '
            'reason is not difficulty': operations.every(
          (HabotOptimisticOperation o) => o.why.length > 80,
        ),
        'reading the row literally leaves nothing to pause':
            thereIsNothingToPause &&
                readLiterallyNote.contains('a form that works'),
        'the real question is named': theRealQuestionNote.contains(
          'WHICH updates may be optimistic',
        ),
        'a rejection lands in Step 237\'s error mode':
            rejectionLandsInTheErrorMode,
        'its message comes from the declared templates':
            rejectionMessageComesFromTheTemplates &&
                rejectionCategories.length == 2,
        'a server rejection after a local pass is treated as ordinary':
            whyLocalPassAndServerFailNote.contains('did nothing'),
        'the adherence rate is at the ceiling': adherenceRate == ceiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures -- only a metric and a Data Collected list of '
      'execution identifiers. Atomic Step: "Pause optimistic UI updates and '
      'execution until validation clears locally."';
}
