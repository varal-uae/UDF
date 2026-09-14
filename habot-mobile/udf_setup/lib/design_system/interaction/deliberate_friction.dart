/// Step 248 (HC-CMP-0054) -- friction on purpose, and the two devices this
/// row asks for that are refused.
///
/// The row: "Configure the glaring red badge and disrupted sort order to
/// create visual friction."
/// Metric: **UI Hesitation/Friction Detection Threshold** -- floor ">3 sec
/// dwell", optimal ">5 sec dwell", ceiling ">10 sec dwell". High/Medium/Low.
/// Standard cited: Nielsen Norman Group response-time heuristics.
///
/// **This step reports Partial.** One of the three things the row asks for is
/// built; two are refused with reasons.
///
/// **Refused: disrupting the sort order.** A list's order is a promise. Change
/// it to make somebody slow down and they can no longer trust any order in the
/// application, and the cost does not land evenly: a person who navigates by
/// position -- with a screen reader, with switch control, or from memory --
/// pays more than the person the friction was aimed at. The row asks for
/// confusion and calls it friction. They are not the same thing: friction is a
/// pause a person understands, confusion is a pause they do not.
///
/// **Refused as specified: a glaring red badge.** A badge that is red and
/// nothing else conveys its meaning by hue alone, which fails WCAG 2.1 SC
/// 1.4.1, and this repository already settled the rule -- the error state
/// carries colour, icon, text and a semantic announcement together. Reinstated
/// as a multi-cue warning that happens to be red. The word refused here is
/// about "glaring" and "and nothing else", not about the colour.
///
/// **Built: a deliberate pause before an irreversible action.** This is the
/// legitimate reading, and the metric fits it exactly. Optimising for a dwell
/// of more than five seconds is optimising for confusion *unless* the pause is
/// the point -- and before an action that cannot be undone, it is. Step 224
/// already established that a destructive confirmation stays a dialog at every
/// window class; the pause attaches there.
library;

import '../forms/validation_state_color.dart';
import '../tokens/motion_tokens.dart';

/// A way of making somebody slow down.
enum HabotFrictionDevice {
  /// A warning carrying every cue the error state carries.
  multiCueWarning,

  /// A confirmation step before an action that cannot be undone.
  confirmationPause,

  /// Re-ordering a list so the person has to look for the thing again.
  sortOrderDisruption,

  /// Colour and nothing else.
  colourOnlyBadge,

  /// A progress indicator slowed on purpose.
  fakeProgress,
}

/// A device, and whether this application will use it.
class HabotFrictionRuling {
  const HabotFrictionRuling({
    required this.device,
    required this.permitted,
    required this.scope,
    required this.reason,
  });

  final HabotFrictionDevice device;

  final bool permitted;

  /// Where it may be used. Empty when it may not be used anywhere.
  final String scope;

  final String reason;
}

/// How long somebody stayed on a surface before acting.
enum HabotFrictionBand { low, medium, high }

/// The rulings, the pause, and the dwell band.
class HabotDeliberateFriction {
  const HabotDeliberateFriction._();

  static const List<HabotFrictionRuling> rulings = <HabotFrictionRuling>[
    HabotFrictionRuling(
      device: HabotFrictionDevice.confirmationPause,
      permitted: true,
      scope: 'actions that cannot be undone: cancelling a booking inside the '
          'refund window, deleting a child profile, submitting a dispute',
      reason: 'A pause before an irreversible action is a safeguard, and it '
          'is the one place where a dwell of more than five seconds is a '
          'good number rather than a symptom. The person is deciding, which '
          'is what the surface exists for.',
    ),
    HabotFrictionRuling(
      device: HabotFrictionDevice.multiCueWarning,
      permitted: true,
      scope: 'the same surfaces, alongside the pause',
      reason: 'Colour, icon, text and a semantic announcement together, which '
          'is what the error state already carries. Red is fine; red ALONE '
          'is the thing that is not.',
    ),
    HabotFrictionRuling(
      device: HabotFrictionDevice.sortOrderDisruption,
      permitted: false,
      scope: '',
      reason: 'A list\'s order is a promise. Change it to make somebody slow '
          'down and they can no longer trust any order in the application, '
          'and the cost does not land evenly -- a person navigating by '
          'position, with a screen reader or switch control or from memory, '
          'pays more than the person the friction was aimed at. The row asks '
          'for confusion and calls it friction. Friction is a pause a person '
          'understands; confusion is a pause they do not.',
    ),
    HabotFrictionRuling(
      device: HabotFrictionDevice.colourOnlyBadge,
      permitted: false,
      scope: '',
      reason: 'A badge that is red and nothing else conveys its meaning by '
          'hue alone, which fails WCAG 2.1 SC 1.4.1 Use of Color. The '
          'repository already settled this: the error state carries four '
          'cues, not one. Refused as specified and reinstated as a multi-cue '
          'warning.',
    ),
    HabotFrictionRuling(
      device: HabotFrictionDevice.fakeProgress,
      permitted: false,
      scope: '',
      reason: 'A progress indicator slowed on purpose lies about system '
          'state. Step 249 is asked for one in as many words and refuses it '
          'there too; it is listed here so the two refusals are one ruling '
          'rather than two opinions.',
    ),
  ];

  static HabotFrictionRuling rulingFor(HabotFrictionDevice device) =>
      rulings.firstWhere((HabotFrictionRuling r) => r.device == device);

  static List<HabotFrictionRuling> get permittedDevices =>
      rulings.where((HabotFrictionRuling r) => r.permitted).toList();

  static List<HabotFrictionRuling> get refusedDevices =>
      rulings.where((HabotFrictionRuling r) => !r.permitted).toList();

  /// Every refusal names a reason long enough to be an argument.
  static bool get everyRefusalIsArgued => refusedDevices.every(
        (HabotFrictionRuling r) => r.reason.length > 120 && r.scope.isEmpty,
      );

  /// Every permitted device names where it may be used.
  static bool get everyPermissionIsScoped => permittedDevices.every(
        (HabotFrictionRuling r) => r.scope.isNotEmpty,
      );

  // -----------------------------------------------------------------------
  // The multi-cue requirement, read from the existing declaration.
  // -----------------------------------------------------------------------

  /// The cues a warning must carry. Read from the error state rather than
  /// restated, so the two cannot drift apart.
  static Set<HabotStateCarrier> get requiredCues =>
      HabotValidationStateColor.carriersFor(HabotFieldVisualState.error);

  static bool get aWarningCarriesMoreThanColour =>
      requiredCues.length > 1 &&
      requiredCues.contains(HabotStateCarrier.colour) &&
      requiredCues.contains(HabotStateCarrier.icon) &&
      requiredCues.contains(HabotStateCarrier.text) &&
      requiredCues.contains(HabotStateCarrier.semantics);

  static bool get theRowsBadgeWouldCarryOne =>
      !rulingFor(HabotFrictionDevice.colourOnlyBadge).permitted;

  // -----------------------------------------------------------------------
  // Where a pause is permitted.
  // -----------------------------------------------------------------------

  /// Whether this surface may carry a deliberate pause.
  static bool pauseIsPermittedFor({required bool actionIsIrreversible}) =>
      actionIsIrreversible;

  /// A commercial outcome is not a reason to slow somebody down. Stated as a
  /// rule because it is the use the row's wording invites.
  static const String commercialFrictionNote =
      'Friction that exists to change what somebody buys is not a safeguard, '
      'and no surface in this application carries it. The permitted scope is '
      'actions that cannot be undone; an action a person can reverse does not '
      'need a pause, and an action that costs the business money but not the '
      'person is not a reason for one.';

  static bool get noPermittedScopeIsCommercial => permittedDevices.every(
        (HabotFrictionRuling r) =>
            !r.scope.contains('upsell') &&
            !r.scope.contains('add-on') &&
            !r.scope.contains('checkout'),
      );

  // -----------------------------------------------------------------------
  // The metric, which is a dwell measurement.
  // -----------------------------------------------------------------------

  static Duration get dwellFloor => HabotMotion.frictionDwellFloor;
  static Duration get dwellOptimal => HabotMotion.frictionDwellOptimal;
  static Duration get dwellCeiling => HabotMotion.frictionDwellCeiling;

  /// The row's own band, applied only to a surface where a pause is the
  /// point. Elsewhere a long dwell is a symptom and this band would grade it
  /// as a success.
  static HabotFrictionBand bandFor(Duration dwell) {
    if (dwell > dwellOptimal) {
      return HabotFrictionBand.high;
    }
    if (dwell > dwellFloor) {
      return HabotFrictionBand.medium;
    }
    return HabotFrictionBand.low;
  }

  static bool get bandIsMonotone =>
      bandFor(dwellFloor) == HabotFrictionBand.low &&
      bandFor(dwellOptimal) == HabotFrictionBand.medium &&
      bandFor(dwellCeiling) == HabotFrictionBand.high;

  /// Above the ceiling the person is not deciding, they are stuck. The row
  /// gives no name for that, so it is named here rather than reported as an
  /// even better result.
  static bool dwellIsStuckRatherThanDeciding(Duration dwell) =>
      dwell > dwellCeiling;

  static const String ceilingIsNotBetterNote =
      'The row\'s band runs floor ">3 sec", optimal ">5 sec", ceiling ">10 '
      'sec", so read literally a longer dwell is always a better result and '
      'the best possible outcome is a person who never acts at all. Past the '
      'ceiling they are not deciding, they are stuck -- so that case is named '
      'rather than graded, and a dwell above ten seconds on a confirmation '
      'is reported as a surface to look at rather than as a success.';

  static const String metricAppliesOnlyHereNote =
      'Optimising for a dwell of more than five seconds is optimising for '
      'confusion UNLESS the pause is the point, and before an action that '
      'cannot be undone it is. The band is applied to the confirmation '
      'surface and refused as a target anywhere else: on a booking screen the '
      'same five seconds means the person cannot find what they came for.';

  // -----------------------------------------------------------------------
  // Metric and report.
  // -----------------------------------------------------------------------

  /// One of the row's three asks is built; two are refused.
  static const int devicesTheRowAsksFor = 3;

  static int get devicesDelivered => 1;

  static double get deliveryRate => devicesDelivered / devicesTheRowAsksFor;

  /// **Partial.** The legitimate reading is implemented and measured; the two
  /// devices that would have to harm somebody to work are refused, with the
  /// argument written down rather than left as an omission.
  static String get qualitativeOutput =>
      refusedDevices.length == 3 && permittedDevices.length == 2
          ? 'Partial'
          : 'Not Complete';

  static const String partialNote =
      'Reported Partial. The row asks for three things: a glaring red badge, '
      'a disrupted sort order, and friction. The third is built, scoped to '
      'actions that cannot be undone, and measured on the row\'s own dwell '
      'band. The first is refused as specified and reinstated with four cues '
      'instead of one. The second is refused outright. A Complete here would '
      'mean a list that reorders itself to confuse people, and no metric is '
      'worth that.';

  static Map<String, bool> get checks => <String, bool>{
        'five friction devices are ruled on': rulings.length == 5,
        'two are permitted and three are refused':
            permittedDevices.length == 2 && refusedDevices.length == 3,
        'every refusal is argued and scoped to nowhere': everyRefusalIsArgued,
        'every permission names where it applies': everyPermissionIsScoped,
        'the required cues are read from the existing error state, not '
            'restated': aWarningCarriesMoreThanColour &&
            requiredCues.length == 4,
        'the colour-only badge the row names is the one that is refused':
            theRowsBadgeWouldCarryOne,
        'a pause is permitted only where the action cannot be undone':
            pauseIsPermittedFor(actionIsIrreversible: true) &&
                !pauseIsPermittedFor(actionIsIrreversible: false),
        'no permitted scope is a commercial one': noPermittedScopeIsCommercial,
        'the dwell band is monotone over the declared tokens': bandIsMonotone,
        'past the ceiling is named as stuck rather than graded as better':
            dwellIsStuckRatherThanDeciding(dwellCeiling * 2) &&
                ceilingIsNotBetterNote.contains('rather than as a success'),
        'the step reports Partial and says which of the three was built':
            qualitativeOutput == 'Partial' &&
                (deliveryRate - 1 / 3).abs() < 1e-9,
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures -- only a metric and a Data Collected list whose '
      'entries are about configuration changes rather than about friction. '
      'Atomic Step: "Configure the glaring red badge and disrupted sort order '
      'to create visual friction."';
}
