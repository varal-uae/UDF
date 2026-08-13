/// AISS: GEN-00632-A01 -- "Deploy Mobile UX Friction Logs (Hesitation
/// Tracking)."
/// Setup Step Description: "Define the FrictionTracker widget wrapper class."
///
/// The wrapper half of the telemetry pair. UFHT-032 (Step 34) records the raw
/// interactions; this turns them into a friction report a human can act on,
/// and puts the recording in the widget tree so a screen is instrumented by
/// being wrapped rather than by every control remembering to report.
///
/// Together these two close the gate TTMAC-014 deferred. What they give you is
/// the instrument, not the field reading: the rate below is computed from the
/// sessions that exist, and the production number needs a release. That
/// distinction is recorded in the evidence rather than glossed over.
library;

import 'package:flutter/widgets.dart';

import '../resilience/log_scrubber.dart';
import 'hesitation_tracker.dart';

/// A friction reading for one screen.
class FrictionReport {
  const FrictionReport({
    required this.screenName,
    required this.taps,
    required this.doubleTapCorrections,
    required this.corrections,
    required this.hesitations,
    required this.events,
  });

  final String screenName;
  final int taps;
  final int doubleTapCorrections;
  final int corrections;
  final int hesitations;
  final int events;

  /// TTMAC-014's completion measure: "double-tap corrections below 1%".
  double get doubleTapCorrectionRate =>
      taps == 0 ? 0 : (doubleTapCorrections / taps) * 100;

  double get correctionRate => taps == 0 ? 0 : (corrections / taps) * 100;

  double get hesitationRate => events == 0 ? 0 : (hesitations / events) * 100;

  /// Scrubbed on the way out, so a screen name that ever contains a path or an
  /// identifier cannot leak through the log.
  Map<String, Object?> toJson() => <String, Object?>{
    'screen': HabotLogScrubber.scrub(screenName),
    'taps': taps,
    'double_tap_corrections': doubleTapCorrections,
    'double_tap_correction_rate_pct': doubleTapCorrectionRate,
    'corrections': corrections,
    'correction_rate_pct': correctionRate,
    'hesitations': hesitations,
    'hesitation_rate_pct': hesitationRate,
    'events': events,
  };
}

/// Wraps a screen and records the friction inside it.
///
/// Taps are captured with a [Listener] on the way down, so the wrapper sees
/// every pointer that reaches the subtree without competing with the gestures
/// underneath it -- instrumentation that swallowed a tap would be worse than
/// no instrumentation at all.
class FrictionTracker extends StatefulWidget {
  const FrictionTracker({
    required this.screenName,
    required this.child,
    this.tracker,
    super.key,
  });

  final String screenName;
  final Widget child;

  /// Injectable for the gates; defaults to the app-wide engine.
  final HabotHesitationTracker? tracker;

  /// Finds the enclosing tracker, if a subtree wants to report explicitly.
  static FrictionTrackerState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<FrictionTrackerState>();

  @override
  State<FrictionTracker> createState() => FrictionTrackerState();
}

class FrictionTrackerState extends State<FrictionTracker> {
  HabotHesitationTracker get tracker =>
      widget.tracker ?? HabotHesitationTracker.instance;

  /// The reading for this screen, right now.
  FrictionReport get report => FrictionReport(
    screenName: widget.screenName,
    taps: tracker.tapCount,
    doubleTapCorrections: tracker.countOf(
      HabotInteractionKind.doubleTapCorrection,
    ),
    corrections: tracker.countOf(HabotInteractionKind.correction),
    hesitations: tracker.events
        .where((HabotInteractionEvent e) => e.isHesitation)
        .length,
    events: tracker.events.length,
  );

  /// Records a tap on a named target. Returns true when it completed a
  /// double-tap correction.
  bool recordTap(String target) => tracker.recordTap(target);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) =>
          recordTap('${widget.screenName}/pointer'),
      child: widget.child,
    );
  }
}
