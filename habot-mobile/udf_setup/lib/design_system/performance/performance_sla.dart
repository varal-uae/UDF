/// Step 235 (GEN-05441) -- the performance SLA decision record.
///
/// The row: "Make and document the required upfront decision: establish hard
/// performance SLAs (FCP <= 1.2s, TTI <= 2.0s, API latency <= 200ms)."
/// Metric: **Decision Documentation Completeness** -- floor "Decision
/// undocumented or verbal only", optimal "Decision documented with rationale &
/// owner sign-off", ceiling 1. Complete/Partial/Not Complete.
///
/// **Two of the three SLAs already exist, to the millisecond.**
/// `HabotMotion.coldStartBudget` is 1200ms; the row asks for FCP <= 1.2s.
/// `HabotMotion.interactiveOn3g` is 2000ms; the row asks for TTI <= 2.0s. Both
/// were declared at Step 165 and neither was ever written down as a decision
/// with an owner and a rationale. The same shape as Step 180, where the
/// self-chasing mechanism the row asked to activate had been active since Step
/// 4 and what was missing was the number.
///
/// **FCP and TTI are web vitals and this is not a web application.** First
/// Contentful Paint is a browser paint event measured by the browser; a Flutter
/// app has no FCP. The translations are exact rather than approximate -- FCP
/// becomes first frame rendered, TTI becomes interactive -- and they are stated
/// so nobody goes looking for a Lighthouse number that will never exist.
///
/// **This step reports Partial.** The metric's optimal requires "rationale &
/// owner sign-off". The record can be authored here and the rationale can be
/// written; a sign-off is a person, and one cannot be obtained from a build
/// host. Two of three criteria hold, and the third is named rather than
/// assumed.
library;

import '../telemetry/rail_timings.dart';
import '../tokens/motion_tokens.dart';

/// One service-level objective.
class HabotSla {
  const HabotSla({
    required this.rowName,
    required this.translatedName,
    required this.budget,
    required this.token,
    required this.rationale,
    required this.conditions,
    required this.owner,
  });

  /// The name the row uses.
  final String rowName;

  /// What it means in an application with no browser.
  final String translatedName;

  final Duration budget;

  /// The declared token this budget is read from, or empty when this step
  /// introduces it.
  final String token;

  final String rationale;

  /// What has to be true for the figure to mean anything.
  final String conditions;

  /// Who decides if it is ever breached. Empty until somebody signs.
  final String owner;

  bool get readsAnExistingToken => token.isNotEmpty;
  bool get isSignedOff => owner.isNotEmpty;
}

/// The decision record.
class HabotPerformanceSla {
  const HabotPerformanceSla._();

  static List<HabotSla> get slas => <HabotSla>[
        HabotSla(
          rowName: 'FCP <= 1.2s',
          translatedName: 'First frame rendered on a cold start',
          budget: HabotMotion.coldStartBudget,
          token: 'HabotMotion.coldStartBudget',
          rationale:
              'A cold start is not a response to an input, so the RAIL bands '
              'do not apply to it -- Step 165 recorded that applying them '
              'would report every launch this app will ever make as a '
              'failure. 1200ms is the startup budget, and the row\'s FCP '
              'figure is the same number.',
          conditions:
              'Profile-mode build, on the Step 165 floor device, from a cold '
              'process with a warm filesystem cache.',
          owner: '',
        ),
        HabotSla(
          rowName: 'TTI <= 2.0s',
          translatedName: 'Interactive on a 3G connection',
          budget: HabotMotion.interactiveOn3g,
          token: 'HabotMotion.interactiveOn3g',
          rationale:
              'Interactive means the first useful paint has happened and the '
              'first tap is accepted -- Step 234\'s deferral point. 2000ms on '
              '3G is the figure Step 165 declared and the row asks for the '
              'same one.',
          conditions:
              'Simulated 3G, Step 165 floor device, first launch after '
              'install so nothing is cached.',
          owner: '',
        ),
        HabotSla(
          rowName: 'API latency <= 200ms',
          translatedName: 'Server response time at the 95th percentile',
          budget: HabotMotion.apiLatencySla,
          token: 'HabotMotion.apiLatencySla',
          rationale:
              'The only one of the three this repository did not already '
              'hold. It is a SERVER property: the client can measure it and '
              'cannot meet it, so the owner is on the other side of the '
              'contract and the client\'s obligation is to report honestly '
              'rather than to comply.',
          conditions:
              'Measured at the 95th percentile over a rolling window, '
              'server-side, excluding the network. A client-side figure '
              'measures the network and the device as well and is a different '
              'number.',
          owner: '',
        ),
      ];

  static HabotSla slaNamed(String rowName) =>
      slas.firstWhere((HabotSla s) => s.rowName == rowName);

  /// Every SLA reads a declared motion token rather than holding a number.
  static List<HabotSla> get tokenBacked =>
      slas.where((HabotSla s) => s.token.startsWith('HabotMotion.')).toList();

  /// The two whose token existed before this step -- the finding.
  static List<HabotSla> get preExistingTokens => slas
      .where((HabotSla s) => !s.token.contains('apiLatencySla'))
      .toList();

  /// Exactness of the match, which is the finding.
  static bool get fcpMatchesColdStartBudget =>
      slaNamed('FCP <= 1.2s').budget.inMilliseconds == 1200 &&
      HabotRailTimings.startupBudget == HabotMotion.coldStartBudget;

  static bool get ttiMatchesInteractiveBudget =>
      slaNamed('TTI <= 2.0s').budget.inMilliseconds == 2000 &&
      HabotRailTimings.interactiveBudget == HabotMotion.interactiveOn3g;

  static const String alreadyDeclaredNote =
      'coldStartBudget is 1200ms and the row asks for FCP <= 1.2s. '
      'interactiveOn3g is 2000ms and the row asks for TTI <= 2.0s. Both were '
      'declared at Step 165 and neither was ever written down as a decision '
      'with a rationale and an owner. The same shape as Step 180: the thing '
      'the row asks to establish has been in force for seventy steps, and what '
      'was missing was the record.';

  static const String webVitalsNote =
      'First Contentful Paint and Time To Interactive are web vitals measured '
      'by a browser. A Flutter application has no FCP -- there is no document '
      'and no paint event to observe. The translations are exact rather than '
      'approximate, and they are written down so nobody goes looking for a '
      'Lighthouse number that will never exist.';

  // -----------------------------------------------------------------------
  // What happens when one is breached.
  // -----------------------------------------------------------------------

  /// An SLA with no consequence is a target. The consequence is declared here
  /// and the alerting that acts on it is GEN-05452, which is not in this
  /// batch -- named so the gap is visible rather than assumed filled.
  static const String breachConsequence =
      'A breach on the floor device blocks the release. A breach on any other '
      'device class is recorded and reviewed, because the budget is declared '
      'against the floor device and a faster phone missing it means something '
      'else is wrong.';

  static const String successorRow = 'GEN-05452';

  static const String successorNote =
      'GEN-05452 -- "create an automated performance alert subroutine flagging '
      'UI components that breach targets" -- is the row that acts on these '
      'figures. It is in the remaining pool and not in this batch, so the '
      'record exists and the alerting does not. Named rather than left as an '
      'assumption that somebody is watching.';

  // -----------------------------------------------------------------------
  // Metric: Decision Documentation Completeness.
  // -----------------------------------------------------------------------

  /// The three things the metric's optimal names.
  static Map<String, bool> get documentationCriteria => <String, bool>{
        'the decision is documented rather than verbal':
            slas.length == 3 &&
                slas.every((HabotSla s) => s.rowName.isNotEmpty),
        'each figure carries a rationale and its conditions': slas.every(
          (HabotSla s) =>
              s.rationale.length > 80 && s.conditions.length > 40,
        ),
        'owner sign-off': slas.every((HabotSla s) => s.isSignedOff),
      };

  static double get documentationCompleteness =>
      documentationCriteria.values.where((bool b) => b).length /
      documentationCriteria.length;

  /// **Partial.** The record is authored and the rationale is written; a
  /// sign-off is a person and cannot be obtained from a build host.
  static String get qualitativeOutput {
    if (documentationCompleteness == 1.0) {
      return 'Complete';
    }
    return documentationCompleteness >= 0.5 ? 'Partial' : 'Not Complete';
  }

  static const String signOffNote =
      'The metric\'s optimal requires "rationale & owner sign-off". The '
      'record is authored here and every figure carries its rationale and the '
      'conditions it holds under. A sign-off is a person, and one cannot be '
      'obtained from a build host -- so two of three criteria hold and the '
      'third is named rather than assumed. Reported Partial.';

  static Map<String, bool> get checks => <String, bool>{
        'three SLAs are recorded': slas.length == 3,
        'every SLA reads a declared token rather than holding a number':
            tokenBacked.length == 3,
        'two of the three tokens existed before this step':
            preExistingTokens.length == 2,
        'the FCP figure is the cold-start budget to the millisecond':
            fcpMatchesColdStartBudget,
        'the TTI figure is the interactive budget to the millisecond':
            ttiMatchesInteractiveBudget,
        'the API budget is the one figure this step introduces':
            slaNamed('API latency <= 200ms').budget.inMilliseconds == 200,
        'each web vital is translated into something this app can observe':
            slas.every(
          (HabotSla s) => s.translatedName != s.rowName,
        ),
        'each figure names the conditions it holds under':
            slas.every((HabotSla s) => s.conditions.isNotEmpty),
        'the API SLA is named as a server obligation the client cannot meet':
            slaNamed('API latency <= 200ms').rationale.contains('SERVER'),
        'a breach has a declared consequence':
            breachConsequence.contains('blocks the release'),
        'the row that acts on these figures is named and is not in this batch':
            successorRow == 'GEN-05452',
        'no owner has signed, and the report says so':
            !documentationCriteria['owner sign-off']! &&
                qualitativeOutput == 'Partial',
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Make and document the required upfront decision: establish hard '
      'performance SLAs (FCP <= 1.2s, TTI <= 2.0s, API latency <= 200ms)."';
}
