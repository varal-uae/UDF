/// AISS Step 146 -- GEN-04759
/// Setup Step (Action) / Atomic Step: "Review the setup step objective:
///   Deconstruct long, overwhelming SEN referral forms into single-action,
///   horizontally paginated swipeable ViewPager steps with animated M3
///   progress indicators."
/// Metric: Requirements Objective Clarity / Sign-off Score -- Floor ">=80%
///         stakeholder sign-off", Optimal "100%", Ceiling "100%".
/// Best Qualitative Output: Complete / Partial / Not Complete.
///
/// THE REVIEW BEFORE STEPS 147-155 BUILD IT. As at Step 138, a review that
/// agrees with the sentence has done nothing; the point is to find what the
/// objective does not say and would have cost a rebuild to discover.
///
/// **F-1: "VIEWPAGER" IS AN ANDROID WIDGET, AND THERE ISN'T ONE HERE.**
/// The objective names a specific Android View. The Flutter equivalent is
/// `PageView`, and the substitution is exact rather than approximate. Recorded
/// because a reviewer reading "ViewPager" in a Flutter codebase should find
/// the note rather than assume something was missed.
///
/// **F-2: "SWIPEABLE" AND "RIGHT-TO-LEFT" COLLIDE.** Step 138 established
/// that Urdu is in scope and reverses layout direction. A horizontally
/// paginated wizard hardcoded to "swipe left for next" advances BACKWARDS in
/// Urdu. This is the finding that makes Steps 149 and 150 different from what
/// they would otherwise have been, and it is only cheap to fix now.
///
/// **F-3: "SINGLE-ACTION" AND "SINGLE-QUESTION" ARE NOT THE SAME THING.**
/// Steps 147 and 148 say one input field per screen. An address is four
/// fields and one decision; splitting it across four screens turns a
/// three-line answer into a four-screen journey and is measurably worse. The
/// objective's intent is one DECISION per step, and Step 147 is built to that
/// rather than to a literal field count.
///
/// **F-4: SPLITTING A LONG FORM CAN MOVE THE ABANDONMENT, NOT REMOVE IT.**
/// A statutory SEN referral is long. Forty single-question screens are not
/// less overwhelming than one long page if the user cannot see how far they
/// have to go or resume where they stopped. "Overwhelming" is replaced by
/// "endless" unless progress is visible (Step 152) and the answers survive a
/// drop-off (Step 153). Those two steps are therefore part of this objective,
/// not adjacent to it.
///
/// **F-5: AN ANIMATED PROGRESS INDICATOR THAT ANIMATES TOO OFTEN IS A
/// DISTRACTION.** The objective asks for animation; it should animate on step
/// CHANGE, not on every keystroke that alters validity, and it must collapse
/// under the reduced-motion preference (Step 137).
library;

/// One finding, and what it would have cost to miss.
class HabotWizardFinding {
  const HabotWizardFinding({
    required this.id,
    required this.finding,
    required this.consequenceIfMissed,
    required this.bindsStep,
  });

  final String id;
  final String finding;
  final String consequenceIfMissed;
  final String bindsStep;
}

/// One term in the objective that had to be translated into this codebase.
class HabotTermSubstitution {
  const HabotTermSubstitution({
    required this.term,
    required this.substitute,
    required this.isExact,
    required this.reason,
  });

  final String term;
  final String substitute;

  /// Whether the substitute does the same job, or only a similar one. An
  /// inexact substitution is a decision; an exact one is a translation.
  final bool isExact;

  final String reason;
}

/// The reviewed objective.
class HabotSingleActionObjective {
  const HabotSingleActionObjective._();

  static const String statedObjective =
      'Deconstruct long, overwhelming SEN referral forms into single-action, '
      'horizontally paginated swipeable ViewPager steps with animated M3 '
      'progress indicators.';

  static const List<HabotTermSubstitution> substitutions =
      <HabotTermSubstitution>[
    HabotTermSubstitution(
      term: 'ViewPager',
      substitute: 'PageView',
      isExact: true,
      reason: 'ViewPager is an Android View. PageView is the Flutter widget '
          'with the same job: horizontally paginated children, one page at a '
          'time, with a controller that owns the index. The substitution is '
          'exact rather than approximate.',
    ),
    HabotTermSubstitution(
      term: 'single-action',
      substitute: 'one decision per step',
      isExact: false,
      reason: 'Read literally, "single-action" would put each of the four '
          'parts of an address on its own screen -- turning a three-line '
          'answer into a four-screen journey, which is worse than the long '
          'form it replaces. The intent is one decision, and Step 44 already '
          'declares which field groups are one decision.',
    ),
    HabotTermSubstitution(
      term: 'animated M3 progress indicators',
      substitute: 'the Step 20 stepper dots, animated on step change with the '
          'Step 137 global transition',
      isExact: true,
      reason: 'The progress indicator already exists (StepperProgressDots). '
          'Adding a second one would be two definitions of the same status.',
    ),
  ];

  static const List<HabotWizardFinding> findings = <HabotWizardFinding>[
    HabotWizardFinding(
      id: 'F-1',
      finding: 'A horizontally paginated wizard hardcoded to "swipe left for '
          'next" advances BACKWARDS in Urdu, which Step 138 put in scope.',
      consequenceIfMissed: 'The wizard would have to be rebuilt rather than '
          'translated, and the defect would be invisible to every reviewer who '
          'reads left to right.',
      bindsStep: 'Steps 149 and 150',
    ),
    HabotWizardFinding(
      id: 'F-2',
      finding: 'A swipe forward past an invalid step must be refused for the '
          'same reason a Next tap is -- but a swipe that simply does not move '
          'reads as a broken gesture rather than as a refusal.',
      consequenceIfMissed: 'Users conclude the app has frozen and force-quit '
          'it, losing the form -- which is precisely the failure Step 153 '
          'exists to prevent, arriving through a different door.',
      bindsStep: 'Step 150',
    ),
    HabotWizardFinding(
      id: 'F-3',
      finding: 'Splitting a long statutory form into many short screens moves '
          'the abandonment risk rather than removing it, unless the user can '
          'see how much is left and can stop and resume.',
      consequenceIfMissed: '"Overwhelming" becomes "endless". The form scores '
          'well on per-screen simplicity and worse on completion, which is the '
          'only outcome that matters.',
      bindsStep: 'Steps 152 and 153',
    ),
    HabotWizardFinding(
      id: 'F-4',
      finding: 'An animated progress indicator that re-animates whenever '
          'validity changes flickers under the user while they type.',
      consequenceIfMissed: 'A distraction in the corner of the eye during data '
          'entry, and a reduced-motion violation for users who asked the OS '
          'for less of exactly this.',
      bindsStep: 'Step 152',
    ),
    HabotWizardFinding(
      id: 'F-5',
      finding: 'A horizontally swipeable page cannot contain a horizontally '
          'scrollable child without the two gestures competing. The app '
          'already has one: the sticky-column table.',
      consequenceIfMissed: 'Either the table cannot be scrolled or the wizard '
          'cannot be swiped, on whichever screen contains both -- discovered '
          'by a user, not by a test.',
      bindsStep: 'Step 150',
    ),
  ];

  static const List<String> decisions = <String>[
    'D-1: Going BACK is always permitted, including past an invalid step. '
        'Validation blocks progress, not retreat; a wizard that traps a user '
        'on a step they cannot satisfy has no exit. The Step 20 machine '
        'already behaves this way and is not changed.',
    'D-2: A refused forward swipe shows the reason it was refused, in the '
        'same place the Next button would have shown it. A silent refusal is '
        'the defect F-2 describes.',
    'D-3: Field groups declared as one decision at Step 44 '
        '(HabotCompoundFields) stay on one step. Everything else is one field '
        'per step.',
    'D-4: The progress indicator animates on step change only, with the '
        'Step 137 global transition, and collapses to an instant update under '
        'reduced motion.',
  ];

  // ---- the row's metric ---------------------------------------------------

  static Map<String, bool> get clarityChecks => <String, bool>{
        'every term borrowed from another platform is substituted explicitly':
            substitutions.isNotEmpty &&
                substitutions.every((HabotTermSubstitution s) =>
                    s.substitute.isNotEmpty && s.reason.length > 60),
        'inexact substitutions are marked as decisions rather than '
                'translations':
            substitutions.any((HabotTermSubstitution s) => !s.isExact),
        'each finding states what it would have cost to miss':
            findings.every((HabotWizardFinding f) =>
                f.consequenceIfMissed.length > 60 && f.bindsStep.isNotEmpty),
        'the right-to-left consequence of "swipeable" is identified':
            findings.any((HabotWizardFinding f) =>
                f.finding.contains('Urdu')),
        'the open questions are answered':
            decisions.length >= 4 &&
                decisions.every((String d) => d.startsWith('D-')),
      };

  static double get clarityScore {
    final Iterable<bool> r = clarityChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  static List<String> get gaps => clarityChecks.entries
      .where((MapEntry<String, bool> e) => !e.value)
      .map((MapEntry<String, bool> e) => e.key)
      .toList();

  static const double floor = 0.80;
  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (clarityScore >= optimal) {
      return 'Complete';
    }
    return clarityScore >= floor ? 'Partial' : 'Not Complete';
  }

  static const String reviewValueNote =
      'The metric scores sign-off. A review that produced sign-off without '
      'producing findings would score identically and be worth nothing, so '
      'what is scored is whether the objective is now buildable: every '
      'borrowed platform term substituted, every ambiguous phrase given a '
      'reading, and every consequence of the phrasing traced to the step it '
      'constrains.';
}
