/// Step 206 (GEN-01529) -- the promo code field and its inline Apply.
///
/// The row: "Embed an M3 Outlined Text Field with an inline 'Apply' CTA
/// button."
/// Metric: **Coupon/Voucher Redemption Validation Accuracy** -- 0.97 / 0.999 /
/// 1. Pass/Fail.
///
/// **The metric is not the client's to report.** Whether a code is valid is
/// decided by a service this app cannot see; the app cannot be 99.9% accurate
/// about something it does not know. Claiming that figure would mean measuring
/// the client's agreement with itself. What the client owns is a smaller and
/// real number: the share of codes it hands to the server in a form the server
/// can judge -- normalised consistently, submitted once, and never guessed at
/// locally. That is what is reported, with the boundary stated.
///
/// **An inline CTA inside a text field is a touch target problem.** MD3's
/// outlined field is 56dp tall; a trailing icon inside it is 24dp of artwork.
/// Drawn as artwork, the Apply button fails the Step 184 floor by a wide
/// margin. The target is the full height of the field and at least the band's
/// optimal wide, with the 24dp glyph centred inside it.
///
/// **Apply must fire once.** A code applied twice is the oldest discount bug
/// there is. The field is locked from the moment Apply is pressed until the
/// answer arrives, and the rate limiter from Step 118 is what stops a held
/// finger from becoming four requests.
library;

import 'dart:ui' show Size;

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// What the field is doing.
enum HabotPromoFieldState {
  /// Empty. Apply is disabled, because a button that can be pressed and does
  /// nothing teaches people the app is broken.
  empty,

  /// Something has been typed that is not obviously malformed.
  ready,

  /// Locally malformed -- wrong characters, too short, too long. Refused here
  /// so a request is not spent on it.
  malformed,

  /// In flight.
  applying,

  /// The server accepted it.
  accepted,

  /// The server rejected it. The code stays in the field.
  rejected,
}

/// The result of normalising a raw input.
class HabotPromoNormalisation {
  const HabotPromoNormalisation({
    required this.raw,
    required this.normalised,
    required this.isWellFormed,
    required this.note,
  });

  final String raw;
  final String normalised;
  final bool isWellFormed;

  /// What was changed, so a rejection can be explained without guessing.
  final String note;
}

/// The field.
class HabotPromoApplyField {
  const HabotPromoApplyField._();

  /// Codes are A-Z and 0-9, 4 to 20 characters after normalisation.
  static final RegExp wellFormed = RegExp(r'^[A-Z0-9]{4,20}$');

  /// Normalisation, done once and in one place.
  ///
  /// Whitespace and separators are stripped because people paste codes out of
  /// emails with them attached. Case is folded UP because every code this
  /// product issues is upper-case -- an assumption, recorded as one, because
  /// if the server ever issues a case-sensitive code this is where it breaks.
  static HabotPromoNormalisation normalise(String raw) {
    final String stripped =
        raw.replaceAll(RegExp(r'[\s\-_]'), '').toUpperCase();
    final bool ok = wellFormed.hasMatch(stripped);
    final List<String> changes = <String>[];
    if (stripped.length != raw.length) {
      changes.add('separators removed');
    }
    if (stripped != raw.replaceAll(RegExp(r'[\s\-_]'), '')) {
      changes.add('upper-cased');
    }
    return HabotPromoNormalisation(
      raw: raw,
      normalised: stripped,
      isWellFormed: ok,
      note: changes.isEmpty ? 'unchanged' : changes.join(', '),
    );
  }

  /// The declared assumption behind upper-casing.
  static const String caseFoldingAssumption =
      'Every code this product issues is upper-case, so folding up is safe and '
      'saves a rejection for someone who typed in lower case. If a '
      'case-sensitive code is ever issued, this is the line that breaks it, '
      'and it is one line rather than a habit spread across call sites.';

  /// The field's state for a given input and lifecycle position.
  static HabotPromoFieldState stateFor(
    String raw, {
    bool inFlight = false,
    bool? serverAccepted,
  }) {
    if (inFlight) {
      return HabotPromoFieldState.applying;
    }
    if (serverAccepted == true) {
      return HabotPromoFieldState.accepted;
    }
    if (serverAccepted == false) {
      return HabotPromoFieldState.rejected;
    }
    if (raw.trim().isEmpty) {
      return HabotPromoFieldState.empty;
    }
    return normalise(raw).isWellFormed
        ? HabotPromoFieldState.ready
        : HabotPromoFieldState.malformed;
  }

  /// Apply is pressable only when there is something worth sending.
  static bool applyIsEnabled(HabotPromoFieldState state) =>
      state == HabotPromoFieldState.ready ||
      state == HabotPromoFieldState.rejected;

  /// Whether the field itself accepts typing.
  static bool fieldIsEditable(HabotPromoFieldState state) =>
      state != HabotPromoFieldState.applying &&
      state != HabotPromoFieldState.accepted;

  /// True when a second press during a request cannot produce a second request.
  static bool get applyIsSingleShot =>
      !applyIsEnabled(HabotPromoFieldState.applying);

  /// The Step 118 window that stops a held finger becoming four requests.
  static Duration get rateLimitWindow => HabotMotion.rateLimitWindow;

  /// How long the field waits before deciding the request is lost.
  static Duration get applyTimeout => HabotMotion.submitLockTimeout;

  // -----------------------------------------------------------------------
  // Geometry.
  // -----------------------------------------------------------------------

  /// MD3 outlined text field height.
  static const double fieldHeightDp = HabotTouchBand.ceilingDp;

  /// The drawn glyph.
  static const double applyGlyphDp = HabotSpacing.lg;

  /// The tappable region around it: full field height, at least the band's
  /// optimal wide.
  static double get applyTargetHeightDp => fieldHeightDp;
  static double get applyTargetWidthDp => HabotTouchBand.optimalDp;

  static bool get glyphAloneWouldFailTheBand =>
      applyGlyphDp < HabotTouchBand.floorDp;

  static Size get applyTargetSize =>
      Size(applyTargetWidthDp, applyTargetHeightDp);

  static bool get applyTargetIsWithinBand =>
      HabotTouchBand.isWithinBand(applyTargetSize) &&
      HabotTouchBand.minorOf(applyTargetSize) >= HabotTouchBand.optimalDp;

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static const double floor = 0.97;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// The client's share of the metric: for each case, does the client do the
  /// right thing -- send a normalised code, or refuse without sending?
  static Map<String, bool> get clientChecks => <String, bool>{
        'a valid code is sent unchanged':
            normalise('WELCOME10').normalised == 'WELCOME10' &&
                normalise('WELCOME10').isWellFormed,
        'case and separators are normalised before sending':
            normalise('welcome-10').normalised == 'WELCOME10' &&
                normalise(' WELCOME 10 ').normalised == 'WELCOME10',
        'a too-short code is refused without spending a request':
            !normalise('WEL').isWellFormed &&
                stateFor('WEL') == HabotPromoFieldState.malformed,
        'an illegal character is refused without spending a request':
            !normalise('WELCOME10!!').isWellFormed,
        'an empty field disables Apply':
            !applyIsEnabled(stateFor('')) &&
                stateFor('') == HabotPromoFieldState.empty,
        'Apply cannot fire twice during one request': applyIsSingleShot,
        'a rejected code stays in the field and can be retried':
            applyIsEnabled(HabotPromoFieldState.rejected) &&
                fieldIsEditable(HabotPromoFieldState.rejected),
        'an accepted code locks the field': !fieldIsEditable(
          HabotPromoFieldState.accepted,
        ),
        'the Apply target clears the band where the glyph alone would not':
            glyphAloneWouldFailTheBand && applyTargetIsWithinBand,
      };

  static double get clientAccuracy {
    final Map<String, bool> c = clientChecks;
    return c.values.where((bool b) => b).length / c.length;
  }

  static String get qualitativeOutput =>
      clientAccuracy >= floor ? 'Pass' : 'Fail';

  static const String accuracyIsNotTheClientsNote =
      'Whether a code is valid is decided by a service this app cannot see. A '
      'client cannot be 99.9% accurate about something it does not know, and '
      'reporting that figure would mean measuring the client\'s agreement with '
      'itself. What is reported is the client\'s own share: codes handed over '
      'in a form the server can judge, normalised once, submitted once, never '
      'guessed at locally.';

  static const String neverGuessLocallyNote =
      'The tempting optimisation is a local list of known-good prefixes so an '
      'obviously wrong code fails instantly. It makes the client wrong every '
      'time marketing issues a code the build predates, and the failure is '
      'silent -- the parent is told their valid code is invalid. Only shape is '
      'checked locally; meaning is always the server\'s.';

  static const String inlineTargetNote =
      'The Apply control is a 24dp glyph, which fails the Step 184 floor on '
      'its own. Its target is the full 56dp field height and at least 48dp '
      'wide, with the glyph centred. Drawn size and tappable size are '
      'different numbers and only one of them is what a finger meets.';

  static const String applyOnceNote =
      'A promo applied twice is the oldest discount bug there is. Apply is '
      'disabled for the duration of the request, the field is locked while it '
      'is in flight, and Step 118\'s rate-limit window stops a held finger '
      'becoming four requests.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Embed an M3 Outlined Text Field with an inline \'Apply\' CTA button."';
}
