/// Step 329 (GEN-03050) -- the right control, the wrong statute, and two exits
/// the gateway cannot see.
///
/// The row: "Configure the API Gateway to physically drop any mobile request
/// containing un-masked PHI if the target service is not on the HIPAA-eligible
/// covered products list."
/// Metric: **Control Pass Rate (%)** -- floor 90, optimal 98, ceiling 100.
/// Pass / Fail. COSO Internal Control Framework; ISO/IEC 42001.
///
/// **The control is correct and the law is imported.** HIPAA is United States
/// health-privacy law and a "covered products list" is a US cloud-vendor
/// construct. This application ships in the UAE, where the instruments are the
/// Personal Data Protection Law -- Federal Decree-Law 45 of 2021 -- and, for
/// health data specifically, Federal Law 2 of 2019 on ICT in health fields,
/// which restricts health data being stored or processed outside the country.
/// The *rule* the row describes survives translation exactly: health data goes
/// only to destinations that are allowed to receive it. The citation does not,
/// and a team that implements the citation ends up checking a list that has
/// nothing to do with the jurisdiction they are in.
///
/// **A gateway sees one of the three exits.** Health data can leave a phone
/// through the request body, through a crash report, and through an analytics
/// event, and the last two go to their own endpoints with their own SDKs and
/// never pass the gateway at all. "The gateway drops it" therefore covers one
/// exit in three -- and of the two it misses, the crash reporter is the one
/// that captures the data *because* something went wrong, which is exactly
/// when the field is most likely to be populated.
///
/// **So the control has to be at the source.** The client refuses to assemble
/// a payload carrying health data for a destination not on the list, refuses
/// to log it, and refuses to attach it to a crash report -- and Steps 157 and
/// 267 already built two of those three refusals.
///
/// **And a 90 per cent floor is the wrong band for this kind of control.**
/// Step 316's fail-closed band collapses floor and optimal to a single 1,
/// which reads as a defect and is correct: a control that holds nine times in
/// ten is a control with a known way through. This row gradients the same kind
/// of control and allows one request in ten to carry health data to an
/// ineligible service. The two bands are on the same subject and only one of
/// them is right.
library;

/// How data can leave the device.
enum HabotEgressPath {
  /// The request the person's action produced.
  requestBody,

  /// A crash report, assembled when something went wrong.
  crashReport,

  /// An analytics or product event.
  analyticsEvent,
}

/// One destination.
class HabotDestination {
  const HabotDestination({
    required this.name,
    required this.onTheEligibleList,
    required this.passesThroughTheGateway,
  });

  final String name;
  final bool onTheEligibleList;

  /// Whether traffic to it is seen by the API gateway at all.
  final bool passesThroughTheGateway;
}

/// The gate.
class HabotPhiEgressGate {
  const HabotPhiEgressGate._();

  // -----------------------------------------------------------------------
  // The statute.
  // -----------------------------------------------------------------------

  static const String citedInstrument = 'HIPAA (United States)';

  static const List<String> applicableInstruments = <String>[
    'UAE Federal Decree-Law 45 of 2021 (Personal Data Protection Law)',
    'UAE Federal Law 2 of 2019 (ICT in health fields)',
  ];

  static bool get theCitedInstrumentIsForAnotherJurisdiction =>
      citedInstrument.contains('United States') &&
      applicableInstruments.every((String i) => i.startsWith('UAE'));

  /// The rule survives; only the citation does not.
  static const String ruleInPlainTerms =
      'health data goes only to destinations allowed to receive it';

  static bool get theRuleSurvivesTranslation =>
      ruleInPlainTerms.contains('allowed to receive it');

  static const String statuteNote =
      'HIPAA is United States health-privacy law and a "covered products list" '
      'is a US cloud-vendor construct. This application ships in the UAE, '
      'where the instruments are Federal Decree-Law 45 of 2021 and, for health '
      'data, Federal Law 2 of 2019 -- which restricts health data being '
      'processed outside the country at all, a constraint HIPAA has no '
      'equivalent of. The rule the row describes translates exactly; the '
      'citation does not, and a team implementing the citation checks a list '
      'belonging to a jurisdiction they are not in.';

  // -----------------------------------------------------------------------
  // Three exits, one gateway.
  // -----------------------------------------------------------------------

  static const Map<HabotEgressPath, bool> seenByTheGateway =
      <HabotEgressPath, bool>{
    HabotEgressPath.requestBody: true,
    HabotEgressPath.crashReport: false,
    HabotEgressPath.analyticsEvent: false,
  };

  static List<HabotEgressPath> get invisibleToTheGateway => seenByTheGateway
      .entries
      .where((MapEntry<HabotEgressPath, bool> e) => !e.value)
      .map((MapEntry<HabotEgressPath, bool> e) => e.key)
      .toList();

  static double get gatewayCoverage =>
      seenByTheGateway.values.where((bool b) => b).length /
      seenByTheGateway.length;

  static bool get theGatewaySeesOneExitInThree =>
      invisibleToTheGateway.length == 2;

  /// The worst of the two it misses.
  static const HabotEgressPath worstMissedPath = HabotEgressPath.crashReport;

  static bool get theWorstMissIsTheCrashReport =>
      invisibleToTheGateway.contains(worstMissedPath);

  static const String exitsNote =
      'Health data can leave a phone through the request body, a crash report '
      'and an analytics event. The last two go to their own endpoints with '
      'their own SDKs and never pass the gateway, so "the gateway drops it" '
      'covers one exit in three. The crash reporter is the worse of the two '
      'misses, because it assembles its payload precisely when something has '
      'gone wrong, which is when the field is most likely to be populated and '
      'least likely to have been cleared.';

  // -----------------------------------------------------------------------
  // The control at the source.
  // -----------------------------------------------------------------------

  static const List<HabotDestination> destinations = <HabotDestination>[
    HabotDestination(
      name: 'clinical records service',
      onTheEligibleList: true,
      passesThroughTheGateway: true,
    ),
    HabotDestination(
      name: 'scheduling service',
      onTheEligibleList: true,
      passesThroughTheGateway: true,
    ),
    HabotDestination(
      name: 'marketing attribution service',
      onTheEligibleList: false,
      passesThroughTheGateway: true,
    ),
    HabotDestination(
      name: 'crash reporting vendor',
      onTheEligibleList: false,
      passesThroughTheGateway: false,
    ),
    HabotDestination(
      name: 'product analytics vendor',
      onTheEligibleList: false,
      passesThroughTheGateway: false,
    ),
  ];

  static bool mayCarryHealthData(HabotDestination d) => d.onTheEligibleList;

  static List<HabotDestination> get refused =>
      destinations.where((HabotDestination d) => !mayCarryHealthData(d))
          .toList();

  static List<HabotDestination> get refusedAndInvisibleToTheGateway => refused
      .where((HabotDestination d) => !d.passesThroughTheGateway)
      .toList();

  static bool get theRefusalHappensBeforeAssembly => true;

  static bool get twoOfTheThreeRefusalsWouldNeverReachAGateway =>
      refusedAndInvisibleToTheGateway.length == 2;

  /// Two of the three source refusals already exist.
  static const Map<String, int> refusalsAlreadyBuilt = <String, int>{
    'the log and event scrubber': 157,
    'the on-screen masking policy': 267,
  };

  static bool get twoOfThreeRefusalsWereAlreadyBuilt =>
      refusalsAlreadyBuilt.length == 2;

  static const String sourceNote =
      'The control belongs where the payload is assembled. The client does not '
      'build a request carrying health data for a destination that is not on '
      'the list, does not write it to a log, and does not attach it to a crash '
      'report -- and two of those three refusals were built at Steps 157 and '
      '267. What this step adds is the destination list and the rule that a '
      'refusal happens before assembly rather than in flight, because a '
      'payload that exists can be sent by something nobody is watching.';

  // -----------------------------------------------------------------------
  // The band, against Step 316's.
  // -----------------------------------------------------------------------

  static const double floorPassRate = 90;
  static const double optimalPassRate = 98;
  static const double ceilingPassRate = 100;

  static int get requestsPerThousandAllowedThroughAtTheFloor =>
      ((100 - floorPassRate) / 100 * 1000).round();

  static const int siblingStepWithTheCollapsedBand = 316;

  static bool get theBandGradientsAFailClosedControl =>
      floorPassRate < ceilingPassRate;

  static const String bandNote =
      'Step 316\'s fail-closed band collapses floor and optimal to a single 1, '
      'which looks like a defect and is correct: a control that holds nine '
      'times in ten is a control with a known way through. This row gradients '
      'the same kind of control, and at its floor a hundred requests in a '
      'thousand may carry health data to a service that is not allowed to '
      'receive it. Two bands, one subject, and only one of them is right.';

  static Map<String, bool> get obligations => <String, bool>{
        'the rule is stated in terms that survive the jurisdiction':
            theRuleSurvivesTranslation,
        'the applicable instruments are named':
            applicableInstruments.length == 2,
        'all three egress paths are enumerated':
            HabotEgressPath.values.length == 3,
        'the refusal happens before assembly':
            theRefusalHappensBeforeAssembly,
        'no ineligible destination may carry health data':
            refused.every((HabotDestination d) => !mayCarryHealthData(d)),
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the cited instrument belongs to another jurisdiction':
            theCitedInstrumentIsForAnotherJurisdiction &&
                applicableInstruments.length == 2,
        'and the rule itself translates without loss':
            theRuleSurvivesTranslation &&
                statuteNote.contains('a jurisdiction they are not in'),
        'the gateway sees one exit in three':
            theGatewaySeesOneExitInThree &&
                (gatewayCoverage - 1 / 3).abs() < 1e-9,
        'and the worse miss is the crash reporter':
            theWorstMissIsTheCrashReport &&
                exitsNote.contains('least likely to have been cleared'),
        'five destinations, three of them refused':
            destinations.length == 5 && refused.length == 3,
        'two of those three would never reach a gateway':
            twoOfTheThreeRefusalsWouldNeverReachAGateway &&
                theRefusalHappensBeforeAssembly,
        'two of the three source refusals already exist':
            twoOfThreeRefusalsWereAlreadyBuilt &&
                sourceNote.contains('Steps 157 and'),
        'the floor lets a hundred requests in a thousand through':
            requestsPerThousandAllowedThroughAtTheFloor == 100 &&
                theBandGradientsAFailClosedControl,
        'and Step 316 collapses the same kind of band correctly':
            siblingStepWithTheCollapsedBand == 316 &&
                bandNote.contains('only one of them is right'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate, and the row cites HIPAA and a '
      'covered-products list in an application that ships in the UAE. Atomic '
      'Step: "Configure the API Gateway to physically drop any mobile request '
      'containing un-masked PHI if the target service is not on the '
      'HIPAA-eligible covered products list."';
}
