/// Step 223 (GEN-01771) -- the portrait orientation lock. **Not Complete.**
///
/// The row: "Enforce a strict portrait orientation lock on the layout."
/// Metric: Step Completion Rate (%) -- 90 / 99 / 100.
/// Complete/Partial/Not Complete.
///
/// **This step reports Not Complete, and the lock is applied nowhere.** Four
/// reasons, in the order they matter:
///
/// 1. **WCAG 2.1 SC 1.3.4 Orientation, Level AA.** Content must not restrict
///    its view and operation to a single display orientation unless a specific
///    orientation is essential. Booking a session for a child is not
///    essential-orientation; a piano keyboard is. A global portrait lock is a
///    conformance failure on a criterion this product is already audited
///    against.
///
/// 2. **It breaks the app for one group and helps nobody.** A device fixed in a
///    wheelchair mount, a bed mount or a vehicle cradle is in one orientation
///    permanently, and it is frequently landscape. A portrait lock does not
///    make that person's experience worse in the way a bad layout does; it
///    makes the app unusable, and only for them.
///
/// 3. **It contradicts three rows in this same batch.** Steps 218, 219 and 221
///    declare expanded-class behaviour -- side-by-side panes on a tablet. A
///    tablet held in portrait is often Medium and in landscape is Expanded, so
///    locking portrait makes the layouts those three steps build unreachable on
///    the hardware they were built for.
///
/// 4. **A lock is a request, not a guarantee.** Both platforms let a user force
///    rotation from system settings, and both honour that over the app's
///    preference. So the lock does not even deliver the determinism that would
///    be its only argument.
///
/// What IS built: the policy object, the citation, and the short list of
/// screens where an orientation *preference* is legitimate -- because "never
/// lock anything" is as unexamined as "lock everything", and a signature
/// capture really does want landscape.
library;

import 'window_size_class.dart';

/// What an orientation rule can be.
enum HabotOrientationRule {
  /// Both orientations are supported. The default, everywhere.
  free,

  /// The screen asks for an orientation but works in either. A hint to the
  /// system, not a restriction on the user.
  preferred,

  /// The screen refuses to render in the other orientation. Used nowhere.
  locked,
}

/// One screen with an orientation opinion.
class HabotOrientationException {
  const HabotOrientationException({
    required this.screen,
    required this.rule,
    required this.orientation,
    required this.essentialityArgument,
  });

  final String screen;
  final HabotOrientationRule rule;

  /// 'portrait' or 'landscape'.
  final String orientation;

  /// WCAG 1.3.4's own test: is this orientation *essential*? The argument is
  /// written down so it can be disagreed with.
  final String essentialityArgument;
}

/// The policy.
class HabotOrientationPolicy {
  const HabotOrientationPolicy._();

  /// The rule everywhere the exception list does not name.
  static const HabotOrientationRule defaultRule = HabotOrientationRule.free;

  /// No screen in this product locks. Stated as a value so a future lock has
  /// to change a declared constant rather than add a line to a manifest.
  static const bool anyScreenLocks = false;

  static const String wcagCriterion = 'WCAG 2.1 SC 1.3.4 Orientation (AA)';

  static const String wcagText =
      'Content does not restrict its view and operation to a single display '
      'orientation, such as portrait or landscape, unless a specific display '
      'orientation is essential.';

  /// Screens that prefer an orientation without restricting one.
  static const List<HabotOrientationException> exceptions =
      <HabotOrientationException>[
    HabotOrientationException(
      screen: 'signature capture',
      rule: HabotOrientationRule.preferred,
      orientation: 'landscape',
      essentialityArgument:
          'A signature drawn in a 320dp-wide box is a different signature from '
          'the one on the paper form. Landscape is preferred and portrait '
          'still works -- the box is narrower and the signature is accepted.',
    ),
    HabotOrientationException(
      screen: 'QR pass presentation',
      rule: HabotOrientationRule.preferred,
      orientation: 'portrait',
      essentialityArgument:
          'The pass is held up to a fixed scanner, which is mounted for a '
          'phone held upright. A preference, because a wheelchair-mounted '
          'device cannot rotate and the pass must still render.',
    ),
  ];

  static List<HabotOrientationException> get lockedScreens => exceptions
      .where(
        (HabotOrientationException e) =>
            e.rule == HabotOrientationRule.locked,
      )
      .toList();

  static bool get everyExceptionIsAPreference => lockedScreens.isEmpty;

  static bool get everyExceptionArguesEssentiality => exceptions.every(
        (HabotOrientationException e) =>
            e.essentialityArgument.length > 60,
      );

  // -----------------------------------------------------------------------
  // Why a lock is not delivered.
  // -----------------------------------------------------------------------

  /// Whether a locked layout would make the expanded-class behaviour built at
  /// Steps 218, 219 and 221 unreachable on a tablet.
  ///
  /// An iPad Mini is 744dp in portrait and 1133dp in landscape: Medium and
  /// Expanded. Lock portrait and the expanded layouts never run on it.
  static bool lockWouldHideExpandedLayouts({
    required double portraitWidthDp,
    required double landscapeWidthDp,
  }) =>
      HabotWindowSizeClass.classOf(portraitWidthDp) !=
      HabotWindowSizeClass.classOf(landscapeWidthDp);

  static const bool platformHonoursUserRotationOverride = true;

  static const List<String> refusalReasons = <String>[
    'WCAG 2.1 SC 1.3.4 Orientation (AA): a global lock restricts operation to '
        'one orientation, and booking a session is not essential-orientation.',
    'A device fixed in a wheelchair, bed or vehicle mount cannot rotate. A '
        'portrait lock makes the app unusable for that person and changes '
        'nothing for anyone else.',
    'Steps 218, 219 and 221 build expanded-class layouts. A tablet is Medium '
        'in portrait and Expanded in landscape, so a portrait lock makes those '
        'layouts unreachable on the hardware they were built for.',
    'Both platforms let a user force rotation from system settings and honour '
        'that over the app\'s preference, so the lock does not deliver the '
        'determinism that would be its only argument.',
  ];

  // -----------------------------------------------------------------------
  // Metric: Step Completion Rate (%). 90 / 99 / 100.
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 99;
  static const double ceiling = 100;

  /// What the row asks for, against what is delivered. The first entry is
  /// false on purpose: the row's own instruction is the one thing not done.
  static Map<String, bool> get completionChecks => <String, bool>{
        'a strict portrait orientation lock is enforced': anyScreenLocks,
        'the refusal is argued rather than asserted':
            refusalReasons.length == 4,
        'the WCAG criterion is cited with its text':
            wcagCriterion.contains('1.3.4') && wcagText.contains('essential'),
        'screens with a legitimate orientation opinion are named':
            exceptions.length == 2,
        'every one of them is a preference, not a lock':
            everyExceptionIsAPreference,
        'every one of them argues essentiality in WCAG\'s own terms':
            everyExceptionArguesEssentiality,
        'the contradiction with Steps 218, 219 and 221 is demonstrated':
            lockWouldHideExpandedLayouts(
          portraitWidthDp: 744,
          landscapeWidthDp: 1133,
        ),
      };

  static double get completionRate =>
      completionChecks.values.where((bool b) => b).length /
      completionChecks.length *
      100;

  /// **Not Complete**, and correctly so: the row's own instruction is the
  /// single unmet check, and meeting it would fail an accessibility criterion
  /// this product is audited against.
  static String get qualitativeOutput {
    if (!anyScreenLocks) {
      return 'Not Complete';
    }
    final double r = completionRate;
    if (r >= optimal) {
      return 'Complete';
    }
    return r >= floor ? 'Partial' : 'Not Complete';
  }

  static const String declinedNote =
      'Reported Not Complete because the row\'s instruction is not carried '
      'out. It is not carried out because doing so fails WCAG 2.1 SC 1.3.4, '
      'makes the app unusable on a mounted device, and makes the expanded '
      'layouts three other rows in this same batch build unreachable on a '
      'tablet. A step that reported Complete here would be recording a '
      'conformance failure as a success.';

  static const String neverLockAnythingIsAlsoUnexaminedNote =
      '"Never restrict an orientation" is as unexamined as "lock everything". '
      'A signature drawn in a 320dp box is not the signature on the paper '
      'form, so landscape is PREFERRED there -- a hint the system may ignore '
      'and the user may override, which is the difference between a '
      'preference and a lock.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Enforce a strict portrait orientation lock on the layout."';
}
