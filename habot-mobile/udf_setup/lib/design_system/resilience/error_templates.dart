/// AISS: REF-197-A01 -- "Define standardized user-facing error text templates
/// for common system validation rejections."
///
/// This is both the step's Setup Step Description AND its
/// "Decision to be Made Before Setup Step" -- the sheet lists the same sentence
/// in both columns, which is the sheet's way of saying the templates must exist
/// before any handler is written. So they are here, as data, first.
///
/// Metric: "Template Definition" -- Floor / Optimal / Ceiling are all
/// "Complete". There is no partial credit: either every category has a
/// template or the step is not done. Gated by REF-197-G1.
///
/// UX decision applied throughout: "Ensure error text displays do not use
/// technical code terms, keeping descriptions simple and clear."
library;

/// The failure categories a transactional UI has to be able to explain.
enum HabotErrorCategory {
  /// The submitted values were rejected by validation.
  validation,

  /// The device has no usable connection.
  offline,

  /// The request went out but nothing came back in time.
  timeout,

  /// The server refused because the session is no longer valid.
  unauthenticated,

  /// The server refused because this user may not do this.
  forbidden,

  /// The thing being edited no longer exists.
  notFound,

  /// Someone else changed the record first.
  conflict,

  /// The server failed while processing.
  serverFailure,

  /// Anything unclassified. Never omitted -- an unmapped failure must still
  /// produce a human sentence, not a stack trace.
  unknown,
}

/// One user-facing template.
class HabotErrorTemplate {
  const HabotErrorTemplate({
    required this.category,
    required this.title,
    required this.body,
    required this.retryable,
    required this.retryLabel,
  });

  final HabotErrorCategory category;

  /// Short, plain, no jargon.
  final String title;

  /// One or two sentences telling the user what actually happened and what to
  /// do about it. Never contains a code, a class name or a file path.
  final String body;

  /// UI decision: "Include an explicit, easy-to-tap retry button within error
  /// notification areas." Only offered where retrying can plausibly work.
  final bool retryable;
  final String retryLabel;
}

class HabotErrorTemplates {
  const HabotErrorTemplates._();

  static const String version = '1.0.0';

  static const Map<HabotErrorCategory, HabotErrorTemplate> _templates =
      <HabotErrorCategory, HabotErrorTemplate>{
        HabotErrorCategory.validation: HabotErrorTemplate(
          category: HabotErrorCategory.validation,
          title: 'Check the highlighted fields',
          body:
              'Some details need correcting before this can be saved. The '
              'fields that need attention are marked below.',
          retryable: false,
          retryLabel: 'Review',
        ),
        HabotErrorCategory.offline: HabotErrorTemplate(
          category: HabotErrorCategory.offline,
          title: 'No connection',
          body:
              'Your device is offline, so nothing was sent. Your entries have '
              'been kept. Reconnect and try again.',
          retryable: true,
          retryLabel: 'Try again',
        ),
        HabotErrorCategory.timeout: HabotErrorTemplate(
          category: HabotErrorCategory.timeout,
          title: 'That took too long',
          body:
              'We did not get a reply in time, so nothing was saved. Your '
              'entries have been kept.',
          retryable: true,
          retryLabel: 'Try again',
        ),
        HabotErrorCategory.unauthenticated: HabotErrorTemplate(
          category: HabotErrorCategory.unauthenticated,
          title: 'Please sign in again',
          body:
              'Your session has ended. Sign in again and your entries will '
              'still be here.',
          retryable: false,
          retryLabel: 'Sign in',
        ),
        HabotErrorCategory.forbidden: HabotErrorTemplate(
          category: HabotErrorCategory.forbidden,
          title: 'You do not have access to this',
          body:
              'Your account is not permitted to make this change. Ask an '
              'administrator if you think this is wrong.',
          retryable: false,
          retryLabel: 'Go back',
        ),
        HabotErrorCategory.notFound: HabotErrorTemplate(
          category: HabotErrorCategory.notFound,
          title: 'This item is no longer available',
          body:
              'It may have been removed since you opened it. Go back and '
              'refresh the list.',
          retryable: false,
          retryLabel: 'Go back',
        ),
        HabotErrorCategory.conflict: HabotErrorTemplate(
          category: HabotErrorCategory.conflict,
          title: 'Someone else changed this first',
          body:
              'To avoid overwriting their work, nothing was saved. Reopen the '
              'item to see the current version.',
          retryable: false,
          retryLabel: 'Reload',
        ),
        HabotErrorCategory.serverFailure: HabotErrorTemplate(
          category: HabotErrorCategory.serverFailure,
          title: 'Something went wrong on our side',
          body:
              'This was not caused by anything you did, and nothing was saved. '
              'Your entries have been kept.',
          retryable: true,
          retryLabel: 'Try again',
        ),
        HabotErrorCategory.unknown: HabotErrorTemplate(
          category: HabotErrorCategory.unknown,
          title: 'Something went wrong',
          body:
              'We could not complete that. Nothing was saved and your entries '
              'have been kept.',
          retryable: true,
          retryLabel: 'Try again',
        ),
      };

  static HabotErrorTemplate of(HabotErrorCategory category) =>
      _templates[category] ?? _templates[HabotErrorCategory.unknown]!;

  static Iterable<HabotErrorTemplate> get all => _templates.values;

  /// The metric is pass/fail on completeness, so this is the gate.
  static bool get isComplete =>
      _templates.length == HabotErrorCategory.values.length;

  /// Words that must never appear in a user-facing string. Checked by
  /// REF-197-G2 across every template.
  static const List<String> forbiddenJargon = <String>[
    'null',
    'undefined',
    'exception',
    'stack',
    'trace',
    'nullptr',
    'segfault',
    'http',
    'socket',
    'timeout ms',
    'errno',
    'sql',
    'query failed',
    '.dart',
    '.js',
    'at line',
  ];
}
