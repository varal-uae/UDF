/// AISS Step 170 -- GEN-00522
/// Setup Step (Action): "Configure OneLink & Universal Links / App Links for
///                       Deferred Deep Linking"
/// Atomic Step: "Program a fallback redirect routing users to a branded web
///               landing page if deep link resolution fails."
/// Metric: Fallback Redirection Latency -- Floor "<= 500 ms",
///         Optimal "<= 100 ms", Ceiling "1000 ms". Pass / Fail.
///
/// **A 100ms OPTIMAL RULES OUT ASKING THE NETWORK.** A resolution service
/// round trip is 100ms on a good connection and does not exist on a bad one --
/// and a fallback is, by definition, what runs when things have already gone
/// wrong. So the decision is made locally from the link itself: the route
/// table this app already has, plus the link's own shape. Nothing is fetched.
///
/// **THE DEFAULT FALLBACK IS THE WORST ONE.** Dropping someone on the home
/// page discards the only thing the link was carrying: where they were trying
/// to go. Someone who tapped a link to a specific job posting and lands on a
/// generic landing page has not been redirected, they have been lost, and the
/// campaign that sent them cannot tell the difference from a successful open.
/// So the fallback preserves as much of the link as it can, in this order:
/// the exact web equivalent, the nearest ancestor section, and only then the
/// branded landing page.
///
/// **A FALLBACK THAT DOES NOT SAY IT IS ONE IS A BUG REPORT WAITING.** The
/// outcome records which tier was used and why the link did not resolve, so
/// "our deep links are broken" arrives with the reason attached.
///
/// **AN UNRESOLVABLE LINK IS SOMETIMES A HOSTILE ONE.** A link is external
/// input. The fallback refuses to redirect to a host it does not own, which is
/// the open-redirect defect, and it refuses on the cheap path rather than
/// after a lookup.
library;

import '../tokens/motion_tokens.dart';

/// Why the deep link did not resolve.
enum HabotLinkFailure {
  /// The path matches no route this build knows. Common during a staged
  /// rollout: the link is newer than the app.
  unknownRoute,

  /// The route exists but the target does not -- a deleted posting.
  targetMissing,

  /// The route requires a signed-in user. Step 171 handles the ones worth
  /// preserving; this is the rest.
  notPermitted,

  /// The link is malformed, or points somewhere this app does not own.
  untrusted,
}

/// Which tier of fallback was used.
enum HabotFallbackTier {
  /// The exact web equivalent of the link. Nothing is lost.
  webEquivalent,

  /// The nearest ancestor section -- the category rather than the item.
  ancestorSection,

  /// The branded landing page. Everything the link carried is gone.
  landingPage,

  /// Nothing was done, because the link was not ours.
  refused,
}

/// The result of a fallback decision.
class HabotFallbackOutcome {
  const HabotFallbackOutcome({
    required this.tier,
    required this.destination,
    required this.failure,
    required this.contextPreserved,
  });

  final HabotFallbackTier tier;

  /// Where the user is being sent. Null when refused.
  final String? destination;

  final HabotLinkFailure failure;

  /// Whether the destination still carries what the link was about.
  final bool contextPreserved;

  bool get isRefusal => tier == HabotFallbackTier.refused;
}

/// Decides where a failed deep link goes.
class HabotDeepLinkFallback {
  const HabotDeepLinkFallback({
    required this.webOrigin,
    required this.trustedHosts,
    required this.knownSections,
  });

  /// The branded site this app has a web equivalent on.
  final String webOrigin;

  /// Hosts whose links this app will act on at all. An exact set, not a
  /// suffix match: `habot.example.com.attacker.test` ends with the right
  /// string and is not the right host.
  final Set<String> trustedHosts;

  /// Path prefixes that exist on the web site, longest first is not assumed
  /// -- the matcher sorts.
  final Set<String> knownSections;

  static const String landingPath = '/app';

  /// Decide. Synchronous and local -- see the header.
  HabotFallbackOutcome resolve({
    required Uri link,
    required HabotLinkFailure failure,
  }) {
    if (!isTrusted(link)) {
      return const HabotFallbackOutcome(
        tier: HabotFallbackTier.refused,
        destination: null,
        failure: HabotLinkFailure.untrusted,
        contextPreserved: false,
      );
    }
    final String path = link.path.isEmpty ? '/' : link.path;

    // Tier 1: the same path on the web. The link's context survives whole.
    if (path != '/' && failure != HabotLinkFailure.targetMissing) {
      return HabotFallbackOutcome(
        tier: HabotFallbackTier.webEquivalent,
        destination: '$webOrigin$path${_query(link)}',
        failure: failure,
        contextPreserved: true,
      );
    }

    // Tier 2: the nearest section that exists. The item is gone; the category
    // is still where they were trying to be.
    final String? section = nearestSection(path);
    if (section != null) {
      return HabotFallbackOutcome(
        tier: HabotFallbackTier.ancestorSection,
        destination: '$webOrigin$section',
        failure: failure,
        contextPreserved: true,
      );
    }

    // Tier 3: the branded landing page. Everything is lost, and the outcome
    // says so.
    return HabotFallbackOutcome(
      tier: HabotFallbackTier.landingPage,
      destination: '$webOrigin$landingPath',
      failure: failure,
      contextPreserved: false,
    );
  }

  /// Exact host match, and https only.
  bool isTrusted(Uri link) =>
      link.scheme == 'https' && trustedHosts.contains(link.host);

  /// The longest declared section that is an ancestor of [path].
  String? nearestSection(String path) {
    final List<String> candidates = knownSections
        .where((String s) => path == s || path.startsWith('$s/'))
        .toList()
      ..sort((String a, String b) => b.length.compareTo(a.length));
    return candidates.isEmpty ? null : candidates.first;
  }

  static String _query(Uri link) =>
      link.query.isEmpty ? '' : '?${link.query}';

  // ---- the row's metric ---------------------------------------------------

  static Duration get optimal => HabotMotion.fallbackRedirectOptimal;
  static Duration get floor => HabotMotion.fallbackRedirectFloor;
  static Duration get ceiling => HabotMotion.fallbackRedirectCeiling;

  /// Whether the decision path can meet the optimal at all.
  ///
  /// A property of the CODE rather than of a timing: a decision behind a
  /// network call cannot be made in 100ms on the connection a fallback is
  /// running on, whatever a measurement on office wifi says.
  static const bool decidesWithoutNetwork = true;

  static String bandFor(Duration observed) {
    if (observed <= optimal) {
      return 'Pass (optimal)';
    }
    if (observed <= floor) {
      return 'Pass (within floor)';
    }
    return observed <= ceiling ? 'Pass (at ceiling)' : 'Fail';
  }

  static const String noNetworkNote =
      'A 100ms optimal rules out asking a resolution service: that round trip '
      'is 100ms on a good connection and does not exist on a bad one -- and a '
      'fallback is by definition what runs when things have already gone '
      'wrong. The decision is made locally from the link and the route table '
      'this app already has.';

  static const String tieredNote =
      'Dropping someone on the home page discards the only thing the link was '
      'carrying. Someone who tapped through to a specific posting and lands on '
      'a generic page has not been redirected, they have been lost -- and the '
      'campaign cannot tell that apart from a successful open. The fallback '
      'preserves the exact web equivalent, then the nearest ancestor section, '
      'and only then the landing page.';

  static const String openRedirectNote =
      'A link is external input. The fallback refuses any host it does not '
      'own, matched exactly rather than by suffix: '
      '"habot.example.com.attacker.test" ends with the right string and is not '
      'the right host. The refusal happens on the cheap path, before any '
      'lookup.';

  static const String saysItIsAFallbackNote =
      'The outcome records which tier was used and why the link failed, so '
      '"our deep links are broken" arrives with the reason attached rather '
      'than as a feeling.';
}
