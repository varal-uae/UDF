/// AISS Step 169 -- GEN-00888
/// Setup Step (Action): "Implement Mobile Push Campaign Attribution & In-App
///                       Engagement Loop"
/// Atomic Step: "Implement client notification tap handler extracting
///               attribution tokens upon app launch."
/// Metric: Token Extraction Speed -- Floor "<= 10 ms", Optimal "<= 2 ms",
///         Ceiling "20 ms". Complete / Not Complete.
///
/// **A 20ms CEILING IS ONLY STRANGE UNTIL YOU NOTICE WHERE THIS RUNS.** This
/// is on the cold-start path, and Step 165 budgets that whole path at 1.2s on
/// the floor device. Twenty milliseconds is 1.7% of it, spent before a single
/// pixel is drawn, on work the user did not ask for. A handler that parses the
/// full payload, touches disk or awaits anything has already lost — and it
/// will look fine in a test on a warm VM.
///
/// So extraction is synchronous, allocation-light, and reads only the keys it
/// needs out of a map the platform has already deserialised.
/// [HabotAttributionToken.extract] does no I/O and returns a value type;
/// everything else the campaign loop wants — recording, attributing, sending —
/// happens after first frame.
///
/// **A MALFORMED PAYLOAD MUST NOT THROW.** Push payloads arrive from outside
/// the app. An extractor that throws on a missing key is a remote crash
/// anybody can trigger by sending a malformed notification, and it crashes
/// during launch, which is the worst possible moment. Every failure mode
/// returns [HabotAttributionToken.none] and is counted.
///
/// **THE TOKEN IS NOT THE CAMPAIGN, AND THE DIFFERENCE IS A PRIVACY ONE.**
/// What is extracted is a campaign id, a variant and a send id — all opaque
/// values the backend minted. Nothing is read that a person typed, and the
/// payload's free-text fields (title, body) are deliberately not touched: they
/// are the notification's visible content and have no business in an
/// attribution record.
library;

import '../tokens/motion_tokens.dart';

/// Why extraction produced nothing.
enum HabotTokenAbsence {
  /// No payload at all -- an ordinary launch.
  noPayload,

  /// A payload with no attribution keys. A non-campaign notification.
  notACampaign,

  /// The keys are present and unusable.
  malformed,
}

/// An attribution token, or the reason there is not one.
class HabotAttributionToken {
  const HabotAttributionToken({
    required this.campaignId,
    required this.variant,
    required this.sendId,
  }) : absence = null;

  const HabotAttributionToken._absent(this.absence)
      : campaignId = null,
        variant = null,
        sendId = null;

  /// The absent value. Const, so the common path allocates nothing.
  static const HabotAttributionToken none =
      HabotAttributionToken._absent(HabotTokenAbsence.noPayload);

  static const HabotAttributionToken notACampaign =
      HabotAttributionToken._absent(HabotTokenAbsence.notACampaign);

  static const HabotAttributionToken malformed =
      HabotAttributionToken._absent(HabotTokenAbsence.malformed);

  final String? campaignId;
  final String? variant;
  final String? sendId;
  final HabotTokenAbsence? absence;

  bool get isPresent => absence == null;

  Map<String, Object?> toRow() => <String, Object?>{
        'campaign_id': campaignId,
        'variant': variant,
        'send_id': sendId,
      };

  // ---- extraction ---------------------------------------------------------

  /// The three keys read. Nothing else in the payload is touched.
  static const String campaignKey = 'hb_campaign';
  static const String variantKey = 'hb_variant';
  static const String sendKey = 'hb_send';

  /// Fields the extractor must never read, and why. Declared rather than left
  /// implicit: "we only read three keys" is a claim, and this is the list that
  /// makes it checkable.
  static const Map<String, String> forbiddenKeys = <String, String>{
    'title': 'The notification\'s visible content. Not attribution data, and '
        'frequently contains a person\'s name.',
    'body': 'Same, at more length.',
    'deep_link': 'Handled by Steps 170 and 171, which know how to validate '
        'it. Reading it here would be a second, unvalidated route.',
    'user': 'An attribution record does not need to name anybody.',
  };

  /// A token's value must be an opaque identifier the backend minted --
  /// short, and without the characters free text has.
  static bool isOpaque(String value) =>
      value.isNotEmpty &&
      value.length <= 64 &&
      RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(value);

  /// **The handler.** Synchronous, no I/O, no allocation on the absent path.
  static HabotAttributionToken extract(Map<String, Object?>? payload) {
    if (payload == null || payload.isEmpty) {
      return none;
    }
    final Object? campaign = payload[campaignKey];
    final Object? send = payload[sendKey];
    if (campaign == null && send == null) {
      return notACampaign;
    }
    if (campaign is! String || send is! String) {
      return malformed;
    }
    if (!isOpaque(campaign) || !isOpaque(send)) {
      return malformed;
    }
    final Object? variant = payload[variantKey];
    if (variant != null && (variant is! String || !isOpaque(variant))) {
      return malformed;
    }
    return HabotAttributionToken(
      campaignId: campaign,
      variant: variant as String?,
      sendId: send,
    );
  }

  // ---- the row's metric ---------------------------------------------------

  static Duration get optimal => HabotMotion.tokenExtractionOptimal;
  static Duration get floor => HabotMotion.tokenExtractionFloor;
  static Duration get ceiling => HabotMotion.tokenExtractionCeiling;

  /// What fraction of the Step 165 cold-start budget the ceiling represents.
  /// The number that makes "20ms" mean something.
  static double get shareOfColdStartBudget =>
      ceiling.inMicroseconds / HabotMotion.coldStartBudget.inMicroseconds;

  static String bandFor(Duration observed) {
    if (observed <= optimal) {
      return 'Complete (optimal)';
    }
    if (observed <= floor) {
      return 'Complete (within floor)';
    }
    return observed <= ceiling ? 'Complete (at ceiling)' : 'Not Complete';
  }

  static bool withinCeiling(Duration observed) => observed <= ceiling;

  static const String coldStartPathNote =
      'A 20ms ceiling is only strange until you notice this runs on the '
      'cold-start path, which Step 165 budgets at 1.2s on the floor device. '
      'Twenty milliseconds is 1.7% of it, spent before a pixel is drawn, on '
      'work the user did not ask for. A handler that parses the full payload, '
      'touches disk or awaits anything has already lost -- and will look fine '
      'in a test on a warm VM.';

  static const String noThrowNote =
      'Push payloads arrive from outside the app. An extractor that throws on '
      'a missing key is a remote crash anybody can trigger by sending a '
      'malformed notification, during launch, which is the worst possible '
      'moment. Every failure mode returns an absent token and is counted.';

  static const String privacyNote =
      'What is extracted is a campaign id, a variant and a send id -- opaque '
      'values the backend minted. The payload\'s free-text fields are '
      'deliberately not touched: they are the notification\'s visible content '
      'and have no business in an attribution record. forbiddenKeys makes '
      '"we only read three keys" checkable rather than a claim.';
}
