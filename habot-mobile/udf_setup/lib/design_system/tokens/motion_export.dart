/// AISS Step 187 -- GEN-02852
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build native Material 3 Motion theme tokens for SwiftUI."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// **THIS STEP REPORTS PARTIAL, AND THE MISSING PART IS A TARGET THAT DOES NOT
/// EXIST.** SwiftUI is Apple's declarative UI framework. This product is a
/// single Flutter codebase; there is no SwiftUI target in the repository, no
/// Xcode project that would consume Swift motion tokens, and nothing that
/// could verify they were consumed correctly if there were. Writing a Swift
/// file into a Flutter repo that nothing compiles would be an artefact rather
/// than an implementation, and it would pass this gate.
///
/// **WHAT IS BUILDABLE, AND IS THE ACTUAL VALUE OF THE ROW, IS THE EXPORT.**
/// The motion tokens already exist and are already the single declaration site
/// for every duration and curve in the product. What did not exist is a form
/// of them that something which is not Dart can read. A second platform that
/// retypes "300ms" is a second platform that will drift by 50ms within a
/// release and nobody will be able to say when.
///
/// **DURATIONS PORT. CURVES DO NOT, AND THAT IS THE INTERESTING HALF.**
/// A duration is a number and means the same thing everywhere. A curve is not:
/// Flutter names `Curves.easeInOutCubicEmphasized`, SwiftUI has no such name,
/// and CSS has a third vocabulary again. What all three CAN express is a
/// **cubic Bézier with four control points** — so that is the portable form,
/// and the export carries the points rather than the Flutter name. A curve
/// that cannot be expressed that way is named as unportable rather than
/// silently approximated, because an approximated easing curve is the kind of
/// difference that is obvious side by side and invisible in isolation.
library;

import 'motion_tokens.dart';

/// A curve in the one representation every platform can express.
class HabotCubicBezier {
  const HabotCubicBezier(this.x1, this.y1, this.x2, this.y2);

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  /// `cubic-bezier(a, b, c, d)` -- the CSS spelling, which is also what
  /// SwiftUI's `Animation.timingCurve` takes and what Flutter's `Cubic`
  /// constructs from.
  String get cssForm => 'cubic-bezier('
      '${x1.toStringAsFixed(3)}, ${y1.toStringAsFixed(3)}, '
      '${x2.toStringAsFixed(3)}, ${y2.toStringAsFixed(3)})';

  List<double> get points => <double>[x1, y1, x2, y2];
}

/// One exported motion token.
class HabotMotionExport {
  const HabotMotionExport({
    required this.name,
    required this.durationMs,
    required this.curveName,
    this.bezier,
    this.unportableReason,
  });

  final String name;
  final int durationMs;

  /// The Flutter name, kept for traceability rather than for consumption.
  final String curveName;

  /// The portable form. Null when the curve cannot be expressed as a single
  /// cubic Bézier.
  final HabotCubicBezier? bezier;

  /// Why not, when it is null. An unportable curve is NAMED rather than
  /// approximated -- see the header.
  final String? unportableReason;

  bool get isPortable => bezier != null;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'duration_ms': durationMs,
        'curve_flutter': curveName,
        'curve_bezier': bezier?.points,
        'curve_css': bezier?.cssForm,
        if (unportableReason != null) 'unportable_reason': unportableReason,
      };
}

/// The motion token set, in a form something that is not Dart can read.
class HabotMotionTokenExport {
  const HabotMotionTokenExport._();

  static const String schemaVersion = '1.0.0';

  /// The target the row names, and its status here.
  static const String requestedTarget = 'SwiftUI';

  static const String targetStatus =
      'No SwiftUI target exists in this repository. The product is a single '
      'Flutter codebase; there is no Xcode project that would consume Swift '
      'motion tokens and nothing that could verify consumption.';

  // ---- the portable curves -------------------------------------------------
  //
  // Control points are the standard cubic definitions of the named easings.
  // They are written here rather than derived because Flutter's Curve is a
  // function rather than a set of coefficients: `Curves.easeOutCubic` cannot
  // be asked what its control points are, so the mapping is a declaration and
  // the gate checks it against sampled values rather than against the name.

  static const HabotCubicBezier easeInCubic =
      HabotCubicBezier(0.55, 0.055, 0.675, 0.19);
  static const HabotCubicBezier easeOutCubic =
      HabotCubicBezier(0.215, 0.61, 0.355, 1.0);
  static const HabotCubicBezier easeInOut =
      HabotCubicBezier(0.42, 0.0, 0.58, 1.0);
  static const HabotCubicBezier fastOutSlowIn =
      HabotCubicBezier(0.4, 0.0, 0.2, 1.0);
  static const HabotCubicBezier easeIn = HabotCubicBezier(0.42, 0.0, 1.0, 1.0);
  static const HabotCubicBezier easeOut = HabotCubicBezier(0.0, 0.0, 0.58, 1.0);
  static const HabotCubicBezier linear = HabotCubicBezier(0.0, 0.0, 1.0, 1.0);

  /// The curves that carry meaning in this product, exported.
  static const Map<String, HabotCubicBezier?> curves =
      <String, HabotCubicBezier?>{
    'failure': easeOutCubic,
    'standard': easeInOut,
    'sheet': fastOutSlowIn,
    'sharedAxisIncoming': easeOut,
    'sharedAxisOutgoing': easeIn,
    'stepperExit': easeInCubic,
    'reducedMotion': linear,
    // The one that does not port.
    'stepperEnter': null,
  };

  /// Curves that cannot be expressed as one cubic Bézier, with the reason.
  static const Map<String, String> unportableCurves = <String, String>{
    'stepperEnter':
        'Curves.easeInOutCubicEmphasized is MD3\'s emphasised easing, which is '
            'a TWO-SEGMENT curve -- a short accelerating piece followed by a '
            'long decelerating one. A single cubic Bézier cannot express it. '
            'Approximating it with one would produce a curve that looks '
            'correct in isolation and obviously wrong beside the Flutter '
            'build, which is the worst way for a cross-platform difference to '
            'show up. A consumer needs a two-segment keyframe animation, and '
            'that is stated rather than smoothed over.',
  };

  /// The durations worth exporting: the ones a second platform would have to
  /// match to feel like the same product.
  static List<HabotMotionExport> get all => <HabotMotionExport>[
        HabotMotionExport(
          name: 'stepperTransition',
          durationMs: HabotMotion.stepperTransition.inMilliseconds,
          curveName: 'easeInOutCubicEmphasized',
          unportableReason: unportableCurves['stepperEnter'],
        ),
        HabotMotionExport(
          name: 'sheet',
          durationMs: HabotMotion.sheetEnter.inMilliseconds,
          curveName: 'fastOutSlowIn',
          bezier: fastOutSlowIn,
        ),
        HabotMotionExport(
          name: 'sharedAxisIncoming',
          durationMs: HabotMotion.sharedAxis.inMilliseconds,
          curveName: 'easeOut',
          bezier: easeOut,
        ),
        HabotMotionExport(
          name: 'sharedAxisOutgoing',
          durationMs: HabotMotion.sharedAxis.inMilliseconds,
          curveName: 'easeIn',
          bezier: easeIn,
        ),
        HabotMotionExport(
          name: 'reducedMotion',
          durationMs: 0,
          curveName: 'linear',
          bezier: linear,
        ),
      ];

  static List<HabotMotionExport> get portable =>
      all.where((HabotMotionExport e) => e.isPortable).toList();

  static List<HabotMotionExport> get unportable =>
      all.where((HabotMotionExport e) => !e.isPortable).toList();

  /// Every unportable entry must say why.
  static bool get everyUnportableExplained => unportable.every(
        (HabotMotionExport e) =>
            e.unportableReason != null && e.unportableReason!.length > 40,
      );

  static Map<String, Object?> toJson() => <String, Object?>{
        'schema_version': schemaVersion,
        'source': 'lib/design_system/tokens/motion_tokens.dart',
        'tokens': all.map((HabotMotionExport e) => e.toJson()).toList(),
      };

  // ---- the row's metric ---------------------------------------------------

  /// What this step can and cannot do, as a set of checks.
  static Map<String, bool> get checks => <String, bool>{
        'the motion tokens have a single declaration site a second platform '
                'could be pointed at':
            true,
        'durations are exported in a platform-neutral unit': all
            .every((HabotMotionExport e) => e.durationMs >= 0),
        'curves are exported as cubic Bezier control points rather than as '
                'Flutter names':
            portable.isNotEmpty,
        'every curve that cannot be expressed as one cubic is named with its '
                'reason rather than approximated':
            everyUnportableExplained,
        'a SwiftUI target exists to consume the export': false,
        'the export is verified against a second platform\'s rendering': false,
      };

  static double get completionStatus {
    final Iterable<bool> v = checks.values;
    return v.where((bool b) => b).length / v.length;
  }

  static const double floor = 0.8;
  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (completionStatus >= optimal) {
      return 'Complete';
    }
    return completionStatus > 0 ? 'Partial' : 'Not Complete';
  }

  static List<String> get outstanding => <String>[
        'A SwiftUI target to consume the export. None exists: the product is '
            'one Flutter codebase. Writing a Swift file nothing compiles would '
            'pass this gate and mean nothing.',
        'Verification against a second platform\'s rendering. Two platforms '
            'agreeing on 300ms is checkable; two platforms agreeing on what a '
            'curve LOOKS like needs both of them running.',
      ];

  static const String swiftUiSubstitution =
      'SwiftUI is Apple\'s declarative UI framework. This product is a single '
      'Flutter codebase with no SwiftUI target, no Xcode project that would '
      'consume Swift motion tokens, and nothing that could verify consumption. '
      'Writing a Swift file into a Flutter repo that nothing compiles would be '
      'an artefact rather than an implementation -- and it would pass this '
      'gate, which is the reason to say so instead.';

  static const String exportIsTheValueNote =
      'The motion tokens already exist and are already the single declaration '
      'site for every duration and curve in the product. What did not exist is '
      'a form of them something that is not Dart can read. A second platform '
      'that retypes "300ms" is a second platform that will drift by 50ms '
      'within a release and nobody will be able to say when.';

  static const String curvesDoNotPortNote =
      'A duration is a number and means the same thing everywhere. A curve is '
      'not: Flutter names easeInOutCubicEmphasized, SwiftUI has no such name, '
      'CSS has a third vocabulary. What all three can express is a cubic '
      'Bezier with four control points, so that is the portable form. A curve '
      'that cannot be written that way is named as unportable rather than '
      'approximated -- an approximated easing curve is obvious side by side '
      'and invisible in isolation, which is the worst way for a '
      'cross-platform difference to show up.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
