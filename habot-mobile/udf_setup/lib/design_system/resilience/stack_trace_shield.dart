/// AISS Step 158 -- GEN-01738
/// Setup Step (Action) / Atomic Step: "Validate that stack traces are
///   successfully hidden from the end user."
/// Metric: Stack Trace Exposure Incidents -- Floor 0.0, Optimal 0.0,
///         Ceiling 0.0. Zero Incidents / Minor Incidents / Critical Incidents.
///
/// **A METRIC OF ZERO AT EVERY BOUND, WHICH MEANS THE CHECK MUST BE A TYPE
/// RATHER THAN A TEST.** A test can show that the five screens someone
/// remembered do not leak a trace. It cannot show that the sixth one, written
/// next month, does not. So the shield is the only route from an error object
/// to something a screen can display, and Step 159's capture path is the only
/// route to a report — which means a screen that wants to show an error has to
/// go through here.
///
/// **WHAT A LEAKED TRACE ACTUALLY COSTS.** It is usually filed as cosmetic. It
/// is not: a Dart stack trace carries package paths, the developer's directory
/// layout, and frequently the values passed to the failing call. On this
/// product those values are worker names, addresses and phone numbers. The
/// Step 157 scrubber exists because of that, and the shield runs it on
/// everything before it goes anywhere — screen, log or report.
///
/// **"ZERO INCIDENTS" IS ALSO ABOUT THE DIAGNOSTIC ROUTE.** The reason traces
/// leak is that someone needed to debug something and the only way to see the
/// error was to print it. [HabotStackTraceShield.diagnostic] is that route: a
/// scrubbed message and the frame SYMBOLS with every file location stripped,
/// which is enough to debug with. A shield that makes debugging harder gets
/// bypassed within a week.
///
/// **WHAT `diagnostic` STILL DOES NOT GUARANTEE, STATED PLAINLY.** The Step 157
/// scrubber matches structured identifiers — emails, URLs, paths, IPs, tokens.
/// It does not match a person's name, because a name is indistinguishable from
/// any other two words. So a diagnostic line built from an exception message
/// can still carry one. That is why this is a DEVELOPER route to a local
/// console and never a field on a report: Step 159 sends the error type, the
/// frame signature and the fingerprint, and no message at all.
///
/// **THE USER GETS THE STEP 68 TEMPLATE, NOT A MESSAGE.** Every error surfaces
/// as one of the declared `HabotErrorTemplate` categories — plain language,
/// no jargon, a retry where retrying helps. The fingerprint is what goes to
/// the report; the template is what goes on the screen; they never swap.
library;

import '../resilience/error_templates.dart';
import '../resilience/log_scrubber.dart';

/// What a screen is allowed to receive about an error.
class HabotUserFacingError {
  const HabotUserFacingError({
    required this.category,
    required this.template,
    required this.fingerprint,
    required this.traceReference,
  });

  final HabotErrorCategory category;
  final HabotErrorTemplate template;

  /// Groups this defect across sessions in the report. Not shown to the user;
  /// carried so support can ask for it and find the report.
  final String fingerprint;

  /// A short reference the user CAN read out. Not the trace, and not derived
  /// from anything in it that identifies them.
  final String traceReference;

  String get title => template.title;
  String get body => template.body;
  bool get retryable => template.retryable;

  /// Everything a screen may render. Deliberately a closed map: a screen that
  /// wants the exception object cannot get it from here.
  Map<String, String> get displayFields => <String, String>{
        'title': title,
        'body': body,
        'reference': traceReference,
      };
}

/// The only route from an error to a screen.
class HabotStackTraceShield {
  const HabotStackTraceShield._();

  /// Markers that mean a string is, or contains, a stack trace. Used to prove
  /// the shield's output is clean, and to detect a leak in a value some other
  /// code is about to display.
  static final List<RegExp> traceMarkers = <RegExp>[
    RegExp(r'#\d+\s+\S+'),
    RegExp(r'\bpackage:[\w./\-]+'),
    RegExp(r'\bdart:[\w./\-]+'),
    RegExp(r'\(.*\.dart:\d+:\d+\)'),
    RegExp(r'^\s*at\s+\S+', multiLine: true),
  ];

  /// True when [value] shows any sign of a stack trace.
  static bool looksLikeTrace(String value) =>
      traceMarkers.any((RegExp r) => r.hasMatch(value));

  /// Turn an error into the only thing a screen may see.
  static HabotUserFacingError shield({
    required Object error,
    required StackTrace? trace,
    required HabotErrorCategory category,
  }) =>
      HabotUserFacingError(
        category: category,
        template: HabotErrorTemplates.of(category),
        fingerprint: fingerprintOf(error, trace),
        traceReference: referenceOf(error, trace),
      );

  /// How many frames the signature and the diagnostic keep. Enough to tell
  /// two defects apart; short enough that a deep framework stack does not
  /// make every occurrence unique.
  static const int signatureFrames = 8;

  /// The frame SYMBOLS of a trace, with every file location removed.
  ///
  /// Symbols are code identifiers -- function and class names -- and carry no
  /// user data. Locations do: a path names the developer's machine, and the
  /// parenthesised part is where a value usually ends up.
  ///
  /// **The obvious implementation is wrong in both directions at once.**
  /// Scrubbing the trace first and fingerprinting the result leaves exactly the
  /// wrong residue: the frame, uri and path rules eat every symbol and every
  /// file name, and what survives is the redaction markers and the `line:col`
  /// numbers. So two unrelated defects that happen to sit at the same depth and
  /// the same line numbers get the SAME fingerprint, and one defect gets a NEW
  /// fingerprint every time an unrelated edit moves its line. A fingerprint
  /// built that way both collides and drifts, which is worse than not grouping
  /// at all because the grouping looks like it is working.
  static List<String> frameSignature(StackTrace? trace) {
    if (trace == null) {
      return const <String>[];
    }
    final RegExp frame = RegExp(r'^#\d+\s+([^(]+)');
    final List<String> out = <String>[];
    for (final String line in trace.toString().split('\n')) {
      final RegExpMatch? m = frame.firstMatch(line.trim());
      if (m == null) {
        continue;
      }
      out.add(m.group(1)!.trim());
      if (out.length == signatureFrames) {
        break;
      }
    }
    return out;
  }

  /// A stable grouping id for one defect.
  ///
  /// Built from the frame SIGNATURE and the error's runtime type, never from
  /// its message: a message frequently contains the value that broke, which
  /// must not travel, and which would also give every occurrence a different
  /// fingerprint and defeat the grouping.
  static String fingerprintOf(Object error, StackTrace? trace) {
    final String seed =
        '${error.runtimeType}|${frameSignature(trace).join('|')}';
    const int prime = 16777619;
    int hash = 2166136261;
    for (final int c in seed.codeUnits) {
      hash = (hash ^ c) & 0xFFFFFFFF;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// The short reference a user can read out to support.
  static String referenceOf(Object error, StackTrace? trace) =>
      'ERR-${fingerprintOf(error, trace).substring(0, 6).toUpperCase()}';

  /// The diagnostic route. Scrubbed, so the convenient thing and the safe
  /// thing are the same thing -- see the header.
  static String diagnostic({
    required Object error,
    required StackTrace? trace,
  }) {
    final String scrubbedError = HabotLogScrubber.scrub(error.toString());
    final List<String> frames = frameSignature(trace);
    return '[${fingerprintOf(error, trace)}] '
        '${error.runtimeType}: $scrubbedError\n'
        '${frames.map((String f) => '  at $f').join('\n')}';
  }

  // ---- the row's metric ---------------------------------------------------

  /// Exposure incidents in a set of values that are about to be displayed.
  ///
  /// Counts a value that still shows a trace marker after the shield has run.
  /// Zero at floor, optimal and ceiling alike.
  static int exposureIncidents(Iterable<String> displayedValues) =>
      displayedValues.where(looksLikeTrace).length;

  /// The row's qualitative vocabulary.
  static String severityFor(int incidents) {
    if (incidents == 0) {
      return 'Zero Incidents';
    }
    return incidents <= 2 ? 'Minor Incidents' : 'Critical Incidents';
  }

  /// Every field a shielded error offers a screen, for the gate to inspect.
  static List<String> displayedValuesOf(HabotUserFacingError e) =>
      e.displayFields.values.toList();

  static const int floor = 0;
  static const int optimal = 0;
  static const int ceiling = 0;

  static const String costNote =
      'A leaked trace is usually filed as cosmetic. It is not: a Dart trace '
      'carries package paths, the developer\'s directory layout and often the '
      'values passed to the failing call. On this product those values are '
      'worker names, addresses and phone numbers.';

  static const String typeNotTestNote =
      'A metric of zero at every bound cannot be met by testing the screens '
      'someone remembered -- that says nothing about the one written next '
      'month. The shield is the only route from an error object to something '
      'a screen can display, so a new screen has to come through it.';

  static const String diagnosticRouteNote =
      'Traces leak because someone needed to debug something and printing the '
      'error was the only way to see it. diagnostic() is that route and is '
      'scrubbed, so the convenient thing and the safe thing are the same '
      'thing. A shield that makes debugging harder is bypassed within a week.';

  static const String diagnosticLimitNote =
      'The scrubber matches structured identifiers -- emails, URLs, paths, '
      'IPs, tokens. It does not match a person\'s name, because a name is '
      'indistinguishable from any other two words. A diagnostic line built '
      'from an exception message can therefore still carry one. That is why '
      'this is a developer route to a local console and never a field on a '
      'report: Step 159 sends the error type, the frame signature and the '
      'fingerprint, and no message at all.';

  static const String fingerprintNote =
      'The fingerprint is built from the frame symbols and the error type, '
      'never from the message and never from the scrubbed trace. A message '
      'usually contains the value that broke -- which must not travel, and '
      'which would give every occurrence a different fingerprint. Scrubbing '
      'the trace first is the other trap, and it fails in both directions at '
      'once: the frame, uri and path rules eat every symbol and file name, and '
      'what survives is the redaction markers and the line:col numbers. Two '
      'unrelated defects at the same depth and the same line numbers collide, '
      'and one defect gets a new fingerprint every time an unrelated edit '
      'moves its line.';
}
