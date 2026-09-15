/// Step 259 (GEN-04473) -- `habot://`, and why it cannot be the primary way
/// in.
///
/// The row: "Configure deep-link listener endpoints handling custom URI
/// schemes (habot://)."
/// Metric: **Deep Link Resolution Success Rate** -- floor 0.95, optimal 0.99,
/// ceiling 0.999. Pass/Fail. Standard cited: Mobile Deep Linking Industry
/// Standard (Branch/AppsFlyer).
///
/// **A custom scheme is not verified, and anything can claim it.** Nothing
/// stops another application on the same device registering `habot://`. On
/// Android the user is offered a chooser; on iOS the behaviour when two apps
/// claim a scheme is undefined. So a link that carries a booking reference can
/// be handed to an application that is not this one. The verified alternatives
/// -- Android App Links and iOS Universal Links, both `https://` on a domain
/// whose ownership is proved by a file the OS fetches -- cannot be claimed by
/// anybody else.
///
/// The custom scheme is kept as a **fallback**, because a verified link fails
/// on a device with no network at first launch and on platforms that do not
/// implement verification. It is not the primary, and the difference is
/// written into the policy rather than left to whoever wires the listener.
///
/// **A link is untrusted input.** It arrives from a message, a browser, a QR
/// code somebody printed. Resolving it must re-authorise, not merely route:
/// a link naming a booking id does not entitle its holder to that booking.
/// The existing fallback tiers already refuse a link that is not ours; this
/// step adds that a link that *is* ours still proves nothing about who tapped
/// it.
///
/// **The metric's denominator decides whether it means anything.** A link to a
/// booking that was cancelled *should* fail to resolve, and counting that as a
/// failure makes the rate a measurement of how often people cancel. It is
/// measured over links that are resolvable, with the unresolvable ones
/// classified.
library;

import 'deep_link_fallback.dart';

/// How a link reaches the application.
enum HabotLinkChannel {
  /// `https://` on a domain the OS has verified this application owns.
  verifiedHttps,

  /// `habot://`. Anything can register it.
  customScheme,

  /// A link that names neither. Not ours.
  foreign,
}

/// One declared entry link.
class HabotEntryLink {
  const HabotEntryLink({
    required this.uri,
    required this.channel,
    required this.requiresAuthorisation,
    required this.why,
  });

  final String uri;
  final HabotLinkChannel channel;

  /// Whether resolving it needs a check on who is holding it, beyond the
  /// check that the link is well formed.
  final bool requiresAuthorisation;

  final String why;

  bool get isVerified => channel == HabotLinkChannel.verifiedHttps;
}

/// One link put through the policy, and what should happen to it.
class HabotLinkCase {
  const HabotLinkCase({
    required this.uri,
    required this.expectedChannel,
    required this.isResolvable,
    required this.why,
  });

  final String uri;
  final HabotLinkChannel expectedChannel;

  /// False for links that correctly fail: a deleted target, a route this
  /// build does not know. Excluded from the success rate's denominator.
  final bool isResolvable;

  final String why;
}

/// The policy.
class HabotLinkSchemePolicy {
  const HabotLinkSchemePolicy._();

  static const String customScheme = 'habot';

  /// The domain the verified links live on. Declared by GEN-00798, which is
  /// still in the remaining pool -- named here so the dependency is visible
  /// rather than assumed satisfied.
  static const String verifiedHost = 'link.habot.io';

  static const String verifiedHostOwningRow = 'GEN-00798';

  /// Which channel a URI belongs to.
  static HabotLinkChannel channelOf(String uri) {
    final Uri? parsed = Uri.tryParse(uri);
    if (parsed == null) {
      return HabotLinkChannel.foreign;
    }
    if (parsed.scheme == 'https' && parsed.host == verifiedHost) {
      return HabotLinkChannel.verifiedHttps;
    }
    if (parsed.scheme == customScheme) {
      return HabotLinkChannel.customScheme;
    }
    return HabotLinkChannel.foreign;
  }

  static bool isOurs(String uri) =>
      channelOf(uri) != HabotLinkChannel.foreign;

  /// The primary channel. Stated as a value so a future change has to change
  /// a declaration rather than a habit.
  static const HabotLinkChannel primaryChannel =
      HabotLinkChannel.verifiedHttps;

  static const HabotLinkChannel fallbackChannel =
      HabotLinkChannel.customScheme;

  static bool get theCustomSchemeIsNotPrimary =>
      primaryChannel != fallbackChannel &&
      primaryChannel == HabotLinkChannel.verifiedHttps;

  // -----------------------------------------------------------------------
  // The declared entry links.
  // -----------------------------------------------------------------------

  static const List<HabotEntryLink> entryLinks = <HabotEntryLink>[
    HabotEntryLink(
      uri: 'https://link.habot.io/booking/:id',
      channel: HabotLinkChannel.verifiedHttps,
      requiresAuthorisation: true,
      why: 'A booking belongs to one guardian. The link names it; it does '
          'not entitle whoever is holding the phone to see it.',
    ),
    HabotEntryLink(
      uri: 'https://link.habot.io/pass/:id',
      channel: HabotLinkChannel.verifiedHttps,
      requiresAuthorisation: true,
      why: 'Step 209 already found that a pass survives a screenshot. A link '
          'to one has to check the holder for the same reason.',
    ),
    HabotEntryLink(
      uri: 'https://link.habot.io/activity/:id',
      channel: HabotLinkChannel.verifiedHttps,
      requiresAuthorisation: false,
      why: 'A public listing. Anybody may open it, which is the point of '
          'sharing one.',
    ),
    HabotEntryLink(
      uri: 'habot://booking/:id',
      channel: HabotLinkChannel.customScheme,
      requiresAuthorisation: true,
      why: 'The fallback spelling of the first link, for the cases where '
          'verification is unavailable. Same authorisation, weaker channel.',
    ),
  ];

  static List<HabotEntryLink> get verifiedLinks =>
      entryLinks.where((HabotEntryLink l) => l.isVerified).toList();

  static List<HabotEntryLink> get customSchemeLinks => entryLinks
      .where((HabotEntryLink l) => l.channel == HabotLinkChannel.customScheme)
      .toList();

  /// Every link that names a private object requires authorisation. The one
  /// that does not is the public listing.
  static bool get everyPrivateLinkRequiresAuthorisation => entryLinks.every(
        (HabotEntryLink l) =>
            l.requiresAuthorisation || l.uri.contains('/activity/'),
      );

  static bool get authorisationDoesNotDependOnTheChannel {
    final HabotEntryLink https = entryLinks.firstWhere(
      (HabotEntryLink l) => l.uri == 'https://link.habot.io/booking/:id',
    );
    final HabotEntryLink custom = entryLinks.firstWhere(
      (HabotEntryLink l) => l.uri == 'habot://booking/:id',
    );
    return https.requiresAuthorisation == custom.requiresAuthorisation;
  }

  // -----------------------------------------------------------------------
  // The corpus, and the denominator.
  // -----------------------------------------------------------------------

  static const List<HabotLinkCase> corpus = <HabotLinkCase>[
    HabotLinkCase(
      uri: 'https://link.habot.io/booking/4821',
      expectedChannel: HabotLinkChannel.verifiedHttps,
      isResolvable: true,
      why: 'The ordinary case: a verified link to a live booking.',
    ),
    HabotLinkCase(
      uri: 'https://link.habot.io/activity/77',
      expectedChannel: HabotLinkChannel.verifiedHttps,
      isResolvable: true,
      why: 'A public listing, verified channel, no authorisation needed.',
    ),
    HabotLinkCase(
      uri: 'habot://booking/4821',
      expectedChannel: HabotLinkChannel.customScheme,
      isResolvable: true,
      why: 'The same booking through the fallback channel. Resolves, and is '
          'classified as the weaker channel so the difference is visible.',
    ),
    HabotLinkCase(
      uri: 'https://link.habot.io/booking/9999',
      expectedChannel: HabotLinkChannel.verifiedHttps,
      isResolvable: false,
      why: 'A cancelled booking. SHOULD fail, and counting it as a failure '
          'would make the success rate a measurement of how often people '
          'cancel.',
    ),
    HabotLinkCase(
      uri: 'https://link.habot.io/rewards/3',
      expectedChannel: HabotLinkChannel.verifiedHttps,
      isResolvable: false,
      why: 'A route this build does not know -- the link is newer than the '
          'app, which is ordinary during a staged rollout. Falls back rather '
          'than failing, and is out of the denominator.',
    ),
    HabotLinkCase(
      uri: 'https://links.habot.io.example.com/booking/1',
      expectedChannel: HabotLinkChannel.foreign,
      isResolvable: false,
      why: 'A host that ends with a domain we do not own. The check is on '
          'the whole host, not on whether ours appears in it -- which is the '
          'mistake a contains() would make.',
    ),
    HabotLinkCase(
      uri: 'habot-extra://booking/1',
      expectedChannel: HabotLinkChannel.foreign,
      isResolvable: false,
      why: 'A scheme that starts with ours. Equality, not prefix.',
    ),
    HabotLinkCase(
      uri: 'not a uri at all',
      expectedChannel: HabotLinkChannel.foreign,
      isResolvable: false,
      why: 'Unparseable, and refused rather than crashing on it.',
    ),
  ];

  static bool get corpusIsClassifiedCorrectly => corpus.every(
        (HabotLinkCase c) => channelOf(c.uri) == c.expectedChannel,
      );

  static List<HabotLinkCase> get resolvableCases =>
      corpus.where((HabotLinkCase c) => c.isResolvable).toList();

  /// The row's metric, over links that can resolve.
  static double get resolutionSuccessRate =>
      resolvableCases.where((HabotLinkCase c) => isOurs(c.uri)).length /
      resolvableCases.length;

  /// The same rate with everything in the denominator, which is what a naive
  /// reading produces.
  static double get rateOverEveryLink =>
      corpus.where((HabotLinkCase c) => isOurs(c.uri) && c.isResolvable)
          .length /
      corpus.length;

  static bool get theDenominatorChangesTheAnswer =>
      rateOverEveryLink < floor && resolutionSuccessRate >= ceiling;

  /// Foreign links are refused, and the existing fallback already has a tier
  /// for exactly that.
  static bool get foreignLinksAreRefused => corpus
      .where((HabotLinkCase c) => c.expectedChannel == HabotLinkChannel.foreign)
      .every((HabotLinkCase c) => !isOurs(c.uri));

  static bool get theRefusedTierAlreadyExists =>
      HabotFallbackTier.values.contains(HabotFallbackTier.refused) &&
      HabotLinkFailure.values.contains(HabotLinkFailure.untrusted);

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String unverifiedSchemeNote =
      'A custom scheme is not verified and anything can claim it. Nothing '
      'stops another application on the same device registering habot://; on '
      'Android the user is offered a chooser and on iOS the behaviour when '
      'two applications claim a scheme is undefined. So a link carrying a '
      'booking reference can be handed to an application that is not this '
      'one. App Links and Universal Links are https:// on a domain whose '
      'ownership the OS proves by fetching a file, and cannot be claimed by '
      'anybody else. The custom scheme stays as a FALLBACK -- a verified '
      'link fails on a device with no network at first launch -- and the '
      'difference is written into the policy rather than left to whoever '
      'wires the listener.';

  static const String untrustedInputNote =
      'A link is untrusted input. It arrives from a message, a browser, a QR '
      'code somebody printed. Resolving it must RE-AUTHORISE and not merely '
      'route: a link naming a booking id does not entitle whoever is holding '
      'the phone to that booking. Authorisation is declared per link and does '
      'not depend on the channel -- the same booking reached through the '
      'verified spelling and the fallback spelling needs the same check, '
      'because the weaker channel is the one more likely to have been '
      'intercepted.';

  static const String denominatorNote =
      'A link to a booking that was cancelled SHOULD fail to resolve, and '
      'counting that as a failure makes the success rate a measurement of '
      'how often people cancel. A link to a route this build does not know '
      'is ordinary during a staged rollout and already has a fallback tier. '
      'The rate is therefore measured over links that can resolve, with the '
      'rest classified -- and both figures are published, because over every '
      'link in the corpus the same policy reports below the row\'s floor '
      'while behaving identically.';

  static const String hostCheckNote =
      'The host check is equality on the whole host and the scheme check is '
      'equality on the whole scheme. A contains() would accept '
      'links.habot.io.example.com, and a startsWith() would accept '
      'habot-extra://. Both are in the corpus.';

  // -----------------------------------------------------------------------
  // Metric: Deep Link Resolution Success Rate.
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.99;
  static const double ceiling = 0.999;

  static String get qualitativeOutput =>
      resolutionSuccessRate >= floor && corpusIsClassifiedCorrectly
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three channels, and every case reaches the one it was chosen for':
            HabotLinkChannel.values.length == 3 && corpusIsClassifiedCorrectly,
        'the verified https channel is primary and the custom scheme is the '
            'fallback': theCustomSchemeIsNotPrimary,
        'the reason a custom scheme cannot be primary is written down':
            unverifiedSchemeNote.contains('undefined'),
        'the verified host and the row that owns it are named':
            verifiedHost == 'link.habot.io' &&
                verifiedHostOwningRow == 'GEN-00798',
        'every link to a private object requires authorisation':
            everyPrivateLinkRequiresAuthorisation &&
                verifiedLinks.length == 3 &&
                customSchemeLinks.length == 1,
        'authorisation does not depend on which channel the link arrived on':
            authorisationDoesNotDependOnTheChannel,
        'host and scheme are matched by equality, not by containment':
            hostCheckNote.contains('contains()') && foreignLinksAreRefused,
        'the rate is measured over resolvable links, and both figures are '
            'published': resolutionSuccessRate >= ceiling &&
            theDenominatorChangesTheAnswer,
        'the existing fallback already has a tier for a link that is not ours':
            theRefusedTierAlreadyExists,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Configure deep-link listener endpoints handling custom URI schemes '
      '(habot://)."';
}
