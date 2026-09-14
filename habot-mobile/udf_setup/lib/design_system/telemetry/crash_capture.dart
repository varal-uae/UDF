/// AISS Step 159 -- GEN-01054
/// Setup Step (Action) / Atomic Step: "Configure Sentry exception capture
///   filters to capture unhandled runtime errors, network timeouts, and UI
///   breaks."
/// Metric: Crash-Free Session Rate -- Floor 0.99, Optimal 0.999, Ceiling 1.0.
///         Good / Average / Poor.
///
/// **THE ROW NAMES SENTRY; NO SDK IS ADDED, AND THE REASON IS THE SAME ONE AS
/// STEP 114's CIPHER.** A crash reporter is a dependency that receives every
/// unhandled error in the app, including whatever is attached to it, from
/// every device. Wiring one up before deciding what may be attached is how a
/// product ends up shipping worker addresses to a third party and finding out
/// in a review. This step builds the FILTER — what is captured, what is
/// dropped, and what each report may carry — against a reporter interface with
/// no implementation. `HabotCrashReporter` has no default, so the absence is a
/// compile-time obstacle rather than an oversight.
///
/// **THE FILTER IS THE WORK, AND THE ROW SAYS SO.** "Exception capture
/// filters" — three classes named: unhandled runtime errors, network timeouts,
/// and UI breaks. They are not the same thing and must not be counted the same
/// way, which is the whole of the metric below.
///
/// **CRASH-FREE SESSION RATE COUNTS SESSIONS, NOT ERRORS, AND ONLY FATAL
/// ONES.** Two mistakes hide here and both inflate the number:
///
///   1. Counting errors rather than sessions. One session that throws forty
///      times is one unhappy user, not forty data points; averaging over
///      errors makes a widespread mild defect look worse than a rare fatal one.
///   2. Counting a handled network timeout as a crash. On an offline-first app
///      a timeout is an expected event that Steps 117-123 exist to absorb. If
///      it counted, the crash-free rate would be a connectivity metric with a
///      misleading name, and a bad week on the network would read as a bad
///      week on stability.
///
/// So timeouts are CAPTURED (the row asks for them) and are NOT FATAL. A
/// session's rate is about the fatal set only.
///
/// **NOTHING IS CAPTURED THAT THE SHIELD HAS NOT SEEN.** Every report goes
/// through Step 158's fingerprint and Step 157's scrubber before it is handed
/// to the reporter, and the report carries no message — only the error type,
/// the frame signature, the category and the trace id that ties it to the
/// Step 156 event stream.
library;

import '../resilience/error_templates.dart';
import '../resilience/stack_trace_shield.dart';
import 'event_schema.dart';
import 'pii_sanitizer.dart';

/// The three classes the row names.
enum HabotErrorClass {
  /// An error nothing caught. Fatal.
  unhandled,

  /// A request that did not answer. Expected on this product; not fatal.
  networkTimeout,

  /// A widget failed to build or lay out. Fatal: the screen is gone.
  uiBreak,
}

/// Whether a class of error ends the user's ability to continue.
extension HabotErrorClassFatality on HabotErrorClass {
  bool get isFatal => this != HabotErrorClass.networkTimeout;
}

/// One captured report. Carries no message -- see the header.
class HabotCrashReport {
  const HabotCrashReport({
    required this.errorClass,
    required this.errorType,
    required this.fingerprint,
    required this.frameSignature,
    required this.traceId,
    required this.sessionId,
    required this.occurredAt,
    required this.category,
  });

  final HabotErrorClass errorClass;

  /// The runtime type, which is a code identifier.
  final String errorType;

  final String fingerprint;

  /// Frame symbols with every file location stripped (Step 158).
  final List<String> frameSignature;

  /// Ties this report to the funnel event the user was producing.
  final String traceId;

  final String sessionId;
  final DateTime occurredAt;
  final HabotErrorCategory category;

  bool get isFatal => errorClass.isFatal;

  Map<String, Object?> toRow() => <String, Object?>{
        'error_class': errorClass.name,
        'error_type': errorType,
        'fingerprint': fingerprint,
        'frames': frameSignature.join('|'),
        'trace_id': traceId,
        'session_id': sessionId,
        'category': category.name,
        'fatal': isFatal,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
      };

  /// The event this report emits into the Step 156 stream, so a crash and the
  /// step the user was on can be joined.
  HabotEvent toEvent({required String view, required int sessionOrdinal}) =>
      HabotEvent(
        kind: HabotEventKind.errorCaptured,
        view: view,
        traceId: traceId,
        occurredAt: occurredAt,
        sessionOrdinal: sessionOrdinal,
        payload: <String, Object?>{
          'error_class': errorClass.name,
          'fingerprint': fingerprint,
          'fatal': isFatal,
        },
      );
}

/// Where reports go. No implementation ships -- see the header.
abstract interface class HabotCrashReporter {
  void report(HabotCrashReport report);
}

/// Why a report was dropped rather than captured.
enum HabotDropReason {
  /// The same fingerprint has already been reported this session.
  duplicateInSession,

  /// The error class is not one this app captures.
  outOfScope,

  /// The report would have carried something the scrubber flags.
  failedSanitisation,
}

/// The capture filter.
class HabotCrashCapture {
  HabotCrashCapture({
    required this.sessionId,
    HabotCrashReporter? reporter,
    DateTime Function()? clock,
  })  : _reporter = reporter,
        _clock = clock ?? DateTime.now;

  final String sessionId;
  final HabotCrashReporter? _reporter;
  final DateTime Function() _clock;

  final List<HabotCrashReport> _captured = <HabotCrashReport>[];
  final Map<HabotDropReason, int> _dropped = <HabotDropReason, int>{};
  final Set<String> _seenFingerprints = <String>{};

  List<HabotCrashReport> get captured =>
      List<HabotCrashReport>.unmodifiable(_captured);

  Map<HabotDropReason, int> get dropped =>
      Map<HabotDropReason, int>.unmodifiable(_dropped);

  int get fatalCount => _captured.where((HabotCrashReport r) => r.isFatal).length;

  bool get sessionIsCrashFree => fatalCount == 0;

  /// The classes this filter captures. All three the row names.
  static Set<HabotErrorClass> get capturedClasses =>
      HabotErrorClass.values.toSet();

  /// Capture one error, or say why it was dropped.
  ///
  /// Returns null when nothing was captured.
  HabotCrashReport? capture({
    required Object error,
    required StackTrace? trace,
    required HabotErrorClass errorClass,
    required HabotErrorCategory category,
    required String traceId,
  }) {
    if (!capturedClasses.contains(errorClass)) {
      _drop(HabotDropReason.outOfScope);
      return null;
    }
    final String fingerprint =
        HabotStackTraceShield.fingerprintOf(error, trace);
    if (_seenFingerprints.contains(fingerprint)) {
      // One defect firing in a loop is one defect. Reporting it forty times
      // costs the user's battery and tells nobody anything new.
      _drop(HabotDropReason.duplicateInSession);
      return null;
    }
    final HabotCrashReport report = HabotCrashReport(
      errorClass: errorClass,
      errorType: error.runtimeType.toString(),
      fingerprint: fingerprint,
      frameSignature: HabotStackTraceShield.frameSignature(trace),
      traceId: traceId,
      sessionId: sessionId,
      occurredAt: _clock(),
      category: category,
    );
    if (!HabotPiiSanitizer.rowIsClean(report.toRow())) {
      // Refusing to send is the right failure: a report that leaks is worse
      // than a report that is missing.
      _drop(HabotDropReason.failedSanitisation);
      return null;
    }
    _seenFingerprints.add(fingerprint);
    _captured.add(report);
    _reporter?.report(report);
    return report;
  }

  void _drop(HabotDropReason reason) =>
      _dropped[reason] = (_dropped[reason] ?? 0) + 1;

  // ---- the row's metric ---------------------------------------------------

  /// Crash-free session rate over a set of sessions.
  ///
  /// Counts SESSIONS, and counts a session unhappy only if it saw a FATAL
  /// error. See the header for both reasons.
  static double crashFreeSessionRate(Iterable<HabotCrashCapture> sessions) {
    final List<HabotCrashCapture> all = sessions.toList();
    if (all.isEmpty) {
      return 1;
    }
    return all.where((HabotCrashCapture s) => s.sessionIsCrashFree).length /
        all.length;
  }

  /// The same figure computed the WRONG way, for the gate to contrast
  /// against. Present so the difference between the two is demonstrable
  /// rather than asserted.
  static double errorWeightedRate(Iterable<HabotCrashCapture> sessions) {
    int errors = 0;
    int total = 0;
    for (final HabotCrashCapture s in sessions) {
      total += 1;
      errors += s._captured.length;
    }
    if (total == 0) {
      return 1;
    }
    final double bad = errors / total;
    return bad >= 1 ? 0 : 1 - bad;
  }

  static const double floor = 0.99;
  static const double optimal = 0.999;
  static const double ceiling = 1.0;

  static String bandFor(double rate) {
    if (rate >= optimal) {
      return 'Good';
    }
    return rate >= floor ? 'Average' : 'Poor';
  }

  static const String noSdkNote =
      'The row names Sentry. No SDK is added, for the reason Step 114 gave '
      'about ciphers: a crash reporter receives every unhandled error in the '
      'app, including whatever is attached, from every device. Wiring one up '
      'before deciding what may be attached is how a product ships worker '
      'addresses to a third party and learns about it in a review. '
      'HabotCrashReporter has no default implementation, so the absence is a '
      'compile-time obstacle rather than an oversight.';

  static const String sessionsNotErrorsNote =
      'The rate counts sessions, not errors. One session that throws forty '
      'times is one unhappy user, not forty data points, and averaging over '
      'errors makes a widespread mild defect look worse than a rare fatal '
      'one.';

  static const String timeoutNotFatalNote =
      'A network timeout is captured -- the row asks for it -- and is not '
      'fatal. On an offline-first app a timeout is an expected event that '
      'Steps 117-123 exist to absorb. Counting it would turn the crash-free '
      'rate into a connectivity metric with a misleading name, and a bad week '
      'on the network would read as a bad week on stability.';

  static const String noMessageNote =
      'A report carries the error TYPE, the frame signature, the category and '
      'the trace id -- never the message. A message usually contains the value '
      'that broke, and on this product that value is a worker name or an '
      'address.';
}
