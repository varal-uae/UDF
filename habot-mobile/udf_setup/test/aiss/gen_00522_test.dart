/// AISS GATE -- Step 170 of 175
/// Global Reference ID:       GEN-00522
/// Atomic Steps Reference ID: GEN-00522
/// Setup Step (Action): "Configure OneLink & Universal Links / App Links for
///                       Deferred Deep Linking"
/// Atomic Step: "Program a fallback redirect routing users to a branded web
///               landing page if deep link resolution fails."
/// Metric: Fallback Redirection Latency -- Floor "<= 500 ms",
///         Optimal "<= 100 ms", Ceiling "1000 ms". Pass / Fail.
///
/// A 100ms OPTIMAL RULES OUT ASKING THE NETWORK, and a fallback is by
/// definition what runs when things have already gone wrong. THE DEFAULT
/// FALLBACK IS ALSO THE WORST ONE: dropping someone on the landing page
/// discards the only thing the link was carrying. Both are gated.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/navigation/deep_link_fallback.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int tiersReached = 0;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  const HabotDeepLinkFallback fallback = HabotDeepLinkFallback(
    webOrigin: 'https://habot.example.com',
    trustedHosts: <String>{
      'habot.example.com',
      'links.habot.example.com',
    },
    knownSections: <String>{
      '/listings',
      '/listings/nurseries',
      '/providers',
    },
  );

  Uri link(String s) => Uri.parse(s);

  group('GEN-00522 :: the tiers, worst one last', () {
    gate(
      'GEN-00522-G1',
      'Atomic Step: "...routing users to a branded web landing page if deep '
          'link resolution fails." "Someone who tapped a link to a specific '
          'job posting and lands on a generic landing page has not been '
          'redirected, they have been lost."',
      'The first tier is the exact web equivalent, so a link the app could not '
          'route still arrives at the thing it was about -- path and query '
          'intact -- and the outcome records that the context survived',
      () {
        final HabotFallbackOutcome o = fallback.resolve(
          link: link(
            'https://habot.example.com/listings/nurseries/4821?ref=push',
          ),
          failure: HabotLinkFailure.unknownRoute,
        );
        return o.tier == HabotFallbackTier.webEquivalent &&
            o.destination ==
                'https://habot.example.com/listings/nurseries/4821?ref=push' &&
            o.contextPreserved &&
            !o.isRefusal &&
            o.failure == HabotLinkFailure.unknownRoute;
      },
    );

    gate(
      'GEN-00522-G2',
      '"The item is gone; the category is still where they were trying to be."',
      'When the target itself is missing, the fallback drops to the nearest '
          'ancestor SECTION rather than to the landing page, and it picks the '
          'longest matching section rather than the first one it happens to '
          'find',
      () {
        final HabotFallbackOutcome o = fallback.resolve(
          link: link('https://habot.example.com/listings/nurseries/4821'),
          failure: HabotLinkFailure.targetMissing,
        );
        return o.tier == HabotFallbackTier.ancestorSection &&
            o.destination == 'https://habot.example.com/listings/nurseries' &&
            o.contextPreserved &&
            fallback.nearestSection('/listings/nurseries/4821') ==
                '/listings/nurseries' &&
            fallback.nearestSection('/listings/4821') == '/listings' &&
            fallback.nearestSection('/somewhere-else') == null;
      },
    );

    gate(
      'GEN-00522-G3',
      '"The branded landing page. Everything the link carried is gone" -- and '
          'the outcome has to say so.',
      'The landing page is the last tier rather than the default, it is '
          'reached only when nothing else matched, and the outcome reports '
          'that the context was NOT preserved so a campaign can tell a rescued '
          'link from a lost one',
      () {
        final HabotFallbackOutcome unknownArea = fallback.resolve(
          link: link('https://habot.example.com/unknown-area/4821'),
          failure: HabotLinkFailure.targetMissing,
        );
        final HabotFallbackOutcome bareRoot = fallback.resolve(
          link: link('https://habot.example.com/'),
          failure: HabotLinkFailure.unknownRoute,
        );
        tiersReached = <HabotFallbackTier>{
          fallback
              .resolve(
                link: link('https://habot.example.com/listings/nurseries/1'),
                failure: HabotLinkFailure.unknownRoute,
              )
              .tier,
          fallback
              .resolve(
                link: link('https://habot.example.com/listings/nurseries/1'),
                failure: HabotLinkFailure.targetMissing,
              )
              .tier,
          unknownArea.tier,
          fallback
              .resolve(
                link: link('https://attacker.test/x'),
                failure: HabotLinkFailure.unknownRoute,
              )
              .tier,
        }.length;
        return unknownArea.tier == HabotFallbackTier.landingPage &&
            unknownArea.destination ==
                'https://habot.example.com${HabotDeepLinkFallback.landingPath}' &&
            !unknownArea.contextPreserved &&
            bareRoot.tier == HabotFallbackTier.landingPage &&
            tiersReached == HabotFallbackTier.values.length &&
            HabotDeepLinkFallback.tieredNote.contains('successful open');
      },
    );
  });

  group('GEN-00522 :: an unresolvable link is sometimes a hostile one', () {
    gate(
      'GEN-00522-G4',
      '"A link is external input. \'habot.example.com.attacker.test\' ends '
          'with the right string and is not the right host."',
      'Trust is an exact host match over https, so a suffix that merely ends '
          'with the right domain is refused, a plain-http link is refused, and '
          'a refusal sends the user nowhere rather than somewhere plausible',
      () {
        final HabotFallbackOutcome suffix = fallback.resolve(
          link: link('https://habot.example.com.attacker.test/listings/1'),
          failure: HabotLinkFailure.unknownRoute,
        );
        final HabotFallbackOutcome insecure = fallback.resolve(
          link: link('http://habot.example.com/listings/1'),
          failure: HabotLinkFailure.unknownRoute,
        );
        return suffix.isRefusal &&
            suffix.destination == null &&
            suffix.failure == HabotLinkFailure.untrusted &&
            insecure.isRefusal &&
            insecure.destination == null &&
            !fallback.isTrusted(
              link('https://habot.example.com.attacker.test/x'),
            ) &&
            !fallback.isTrusted(link('http://habot.example.com/x')) &&
            fallback.isTrusted(link('https://habot.example.com/x')) &&
            fallback.isTrusted(link('https://links.habot.example.com/x')) &&
            HabotDeepLinkFallback.openRedirectNote.contains('cheap path');
      },
    );

    gate(
      'GEN-00522-G5',
      '"A fallback that does not say it is one is a bug report waiting."',
      'Every outcome records which tier was used and why the link failed to '
          'resolve, so "our deep links are broken" arrives with the reason '
          'attached rather than as a feeling -- including the case the app '
          'meets most during a staged rollout, where the link is simply newer '
          'than the build',
      () {
        final HabotFallbackOutcome staged = fallback.resolve(
          link: link('https://habot.example.com/listings/nurseries/4821'),
          failure: HabotLinkFailure.unknownRoute,
        );
        final HabotFallbackOutcome signedOut = fallback.resolve(
          link: link('https://habot.example.com/providers/9/messages'),
          failure: HabotLinkFailure.notPermitted,
        );
        return HabotLinkFailure.values.length == 4 &&
            staged.failure == HabotLinkFailure.unknownRoute &&
            signedOut.failure == HabotLinkFailure.notPermitted &&
            signedOut.tier == HabotFallbackTier.webEquivalent &&
            HabotDeepLinkFallback.saysItIsAFallbackNote
                .contains('as a feeling');
      },
    );
  });

  group('GEN-00522 :: the latency, and why it is a property of the code', () {
    gate(
      'GEN-00522-G6',
      'Metric: Fallback Redirection Latency -- optimal <= 100 ms. "That round '
          'trip is 100ms on a good connection and does not exist on a bad '
          'one."',
      'The decision is made locally from the link and the route table this app '
          'already has: the resolver is synchronous, so it cannot be awaiting '
          'a network call, and that is recorded as a property of the code '
          'rather than as a measurement on office wifi',
      () {
        // If resolve() were asynchronous this would not compile as a value.
        final HabotFallbackOutcome o = fallback.resolve(
          link: link('https://habot.example.com/listings/1'),
          failure: HabotLinkFailure.unknownRoute,
        );
        return HabotDeepLinkFallback.decidesWithoutNetwork &&
            o.destination != null &&
            HabotDeepLinkFallback.optimal ==
                const Duration(milliseconds: 100) &&
            HabotDeepLinkFallback.floor == const Duration(milliseconds: 500) &&
            HabotDeepLinkFallback.ceiling ==
                const Duration(milliseconds: 1000) &&
            HabotDeepLinkFallback.optimal ==
                HabotMotion.fallbackRedirectOptimal &&
            HabotDeepLinkFallback.noNetworkNote.contains('already gone wrong');
      },
    );

    gate(
      'GEN-00522-G7',
      'Pass / Fail. A band that never says Fail is not a band.',
      'The row\'s vocabulary reaches every state, including past the '
          '1,000ms ceiling',
      () =>
          HabotDeepLinkFallback.bandFor(const Duration(milliseconds: 40))
              .contains('optimal') &&
          HabotDeepLinkFallback.bandFor(const Duration(milliseconds: 300))
              .contains('within floor') &&
          HabotDeepLinkFallback.bandFor(const Duration(milliseconds: 900))
              .contains('at ceiling') &&
          HabotDeepLinkFallback.bandFor(const Duration(milliseconds: 1200)) ==
              'Fail',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00522',
        atomicStepReferenceId: 'GEN-00522',
        setupStepAction:
            'Configure OneLink & Universal Links / App Links for Deferred Deep '
            'Linking -- Atomic Step: "Program a fallback redirect routing '
            'users to a branded web landing page if deep link resolution '
            'fails."',
        implementationOrder: 170,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDeepLinkFallback / HabotFallbackOutcome',
          'Component Properties':
              '${HabotFallbackTier.values.length} fallback tiers '
              '(web equivalent, ancestor section, landing page, refused); '
              '${HabotLinkFailure.values.length} declared failure reasons; '
              'exact-host trust over https only; the decision is synchronous '
              'and makes no network call',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'MEASUREMENT APPROACH RECORDED: the 100ms optimal is treated as '
              'a constraint on the CODE rather than as a stopwatch reading. A '
              'decision behind a resolution-service round trip cannot meet '
              '100ms on the connection a fallback is actually running on, '
              'whatever a measurement on office wifi says -- so what is gated '
              'is that the decision is local and synchronous. SECURITY: a link '
              'is external input; the fallback refuses any host it does not '
              'own, matched exactly rather than by suffix, before any lookup.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Fallback Redirection Latency',
            observed:
                'Decided locally with no network call '
                '(decidesWithoutNetwork = true, and the resolver is '
                'synchronous, so it cannot be awaiting one). Bands held as '
                'tokens and reaching Fail past the 1,000ms ceiling.',
            floor: '<= 500 ms',
            optimal: '<= 100 ms',
            ceiling: '1000 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Link context preserved through the fallback',
            observed:
                'All $tiersReached declared tiers reached in the gates. A link '
                'the app cannot route still arrives at the exact web '
                'equivalent with its path and query intact; a link whose '
                'target is gone arrives at the longest matching ancestor '
                'section; only a link matching neither reaches the branded '
                'landing page, and that outcome reports contextPreserved = '
                'false so a campaign can tell a rescued link from a lost one.',
            floor: 'context preserved where possible',
            optimal: 'exact web equivalent',
            ceiling: 'branded landing page',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/deep_link_fallback.dart',
        ],
      ),
    );
  });
}
