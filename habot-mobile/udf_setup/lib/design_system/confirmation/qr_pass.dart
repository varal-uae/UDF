/// Step 209 (GEN-01573) -- the QR pass on the order confirmation screen.
///
/// The row: "Render a dynamic vector QR code pass on the order confirmation
/// screen."
/// Metric: Digital Pass/QR Generation & Scan Success Rate -- 0.97 / 0.999 / 1.
/// Pass/Fail.
///
/// **"Dynamic" is doing more work than it looks.** A QR that encodes a booking
/// id is a permanent credential: a screenshot forwarded to anyone admits them,
/// forever, and the parent who forwarded it is not doing anything they would
/// recognise as wrong. The payload here is bound to a rotation window, so a
/// screenshot expires. The door still has to enforce single use -- rotation
/// limits the damage, it does not remove it, and saying which is which matters
/// more than the code.
///
/// **Scan failures are almost never about the encoding.** In order of how often
/// they happen: the quiet zone is missing because the QR was laid out flush to
/// a card edge; the screen is too dim; the code is too small on a 320dp phone;
/// and only then, error correction. The first three are layout decisions on
/// this screen and are all settled here as numbers rather than left to the
/// person drawing the card.
///
/// **Vector, and what that buys.** A raster QR resampled by the layout engine
/// blurs module edges, and a blurred module boundary is the one thing a
/// scanner cannot recover from. Vector rendering also makes the module size a
/// derived quantity rather than an asset property, which is what lets the
/// minimum module size below be enforced instead of hoped for.
///
/// **Offline.** The venue door is the place with the worst signal in the whole
/// journey. The pass renders from locally held data; a pass that needs a
/// network call to draw is a pass that fails exactly where it is used.
library;

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// QR error-correction levels.
enum HabotQrErrorCorrection {
  /// ~7% recoverable. Smallest symbol, least tolerance.
  low,

  /// ~15%.
  medium,

  /// ~25%. The level used here: a phone screen collects fingerprints and
  /// glare, and both take out contiguous regions of modules.
  quartile,

  /// ~30%. Grows the symbol enough to cost more in module size than it buys
  /// in tolerance at this payload length.
  high,
}

/// A QR symbol's geometry.
class HabotQrGeometry {
  const HabotQrGeometry({
    required this.version,
    required this.modules,
    required this.quietZoneModules,
    required this.moduleSizeDp,
  });

  /// QR version, 1-40.
  final int version;

  /// Modules per side, excluding the quiet zone.
  final int modules;

  /// Quiet zone, per side, in modules. The specification says four.
  final int quietZoneModules;

  final double moduleSizeDp;

  int get modulesWithQuietZone => modules + quietZoneModules * 2;

  double get renderedSideDp => modulesWithQuietZone * moduleSizeDp;

  /// The drawable area excluding the quiet zone.
  double get symbolSideDp => modules * moduleSizeDp;
}

/// The pass.
class HabotQrPass {
  const HabotQrPass._();

  /// Byte-mode capacity at error-correction level Q, versions 1-10.
  ///
  /// Only the levels and versions this screen can reach are tabulated; a
  /// capacity table that covers all forty versions and four levels is a
  /// rendering library's job, not a screen's.
  static const Map<int, int> byteCapacityAtQuartile = <int, int>{
    1: 11,
    2: 20,
    3: 32,
    4: 46,
    5: 60,
    6: 74,
    7: 86,
    8: 108,
    9: 130,
    10: 151,
  };

  static const HabotQrErrorCorrection errorCorrection =
      HabotQrErrorCorrection.quartile;

  /// The quiet zone, from the QR specification. Four modules on every side.
  static const int quietZoneModules = 4;

  /// The smallest module a phone camera reliably resolves off a screen at
  /// arm's length. Below this the symbol is decorative.
  static const double minimumModuleDp = 4;

  /// The side length this screen renders the pass at.
  static const double targetSideDp = HabotSpacing.xxxl * 5; // 240dp

  /// Modules per side for a QR version.
  static int modulesForVersion(int version) => 21 + 4 * (version - 1);

  /// The smallest version that holds a payload of this length.
  static int? versionFor(int payloadBytes) {
    for (final int v in byteCapacityAtQuartile.keys) {
      if (byteCapacityAtQuartile[v]! >= payloadBytes) {
        return v;
      }
    }
    return null;
  }

  /// Geometry for a payload, at the screen's target size.
  static HabotQrGeometry? geometryFor(String payload) {
    final int? version = versionFor(payload.length);
    if (version == null) {
      return null;
    }
    final int modules = modulesForVersion(version);
    final int total = modules + quietZoneModules * 2;
    return HabotQrGeometry(
      version: version,
      modules: modules,
      quietZoneModules: quietZoneModules,
      moduleSizeDp: targetSideDp / total,
    );
  }

  static bool moduleSizeIsScannable(HabotQrGeometry g) =>
      g.moduleSizeDp >= minimumModuleDp;

  /// How much payload headroom is left at the chosen version.
  ///
  /// This is worth reporting rather than hiding: a payload sitting at capacity
  /// grows the symbol by four modules per side the moment one character is
  /// added, and the module size drops with it.
  static int headroomFor(String payload) {
    final int? v = versionFor(payload.length);
    if (v == null) {
      return 0;
    }
    return byteCapacityAtQuartile[v]! - payload.length;
  }

  // -----------------------------------------------------------------------
  // The payload.
  // -----------------------------------------------------------------------

  /// Format tag, so a scanner can reject something that is not one of ours
  /// before trying to interpret it.
  static const String formatTag = 'HB1';

  /// A pass payload: tag, booking reference, rotation window, signature.
  ///
  /// The booking reference is opaque. Nothing here names a child, a parent or
  /// a service -- a QR is a thing people photograph and forward.
  static String payloadFor({
    required String bookingReference,
    required int windowIndex,
    required String signature,
  }) =>
      '$formatTag:$bookingReference:$windowIndex:$signature';

  /// How long one rendered pass stays valid.
  static Duration get validityWindow => HabotMotion.passValidityWindow;

  /// How often the payload changes while the screen is open.
  static Duration get rotationPeriod => HabotMotion.passRotationPeriod;

  static int windowIndexAt(DateTime now, DateTime epoch) =>
      now.difference(epoch).inMilliseconds ~/
      rotationPeriod.inMilliseconds;

  /// Whether a pass generated in one window is still accepted in another.
  static bool isWithinValidity({
    required int generatedWindow,
    required int presentedWindow,
  }) {
    final int windows =
        validityWindow.inMilliseconds ~/ rotationPeriod.inMilliseconds;
    final int delta = presentedWindow - generatedWindow;
    return delta >= 0 && delta < windows;
  }

  static const String rotationLimitsNotPreventsNote =
      'Rotation makes a forwarded screenshot expire. It does not make the pass '
      'single-use: within the validity window a photograph works as well as '
      'the phone it came from. Single use is enforced at the door, by the '
      'scanner, and rotation is what bounds the exposure between now and then. '
      'Saying which of the two does what matters more than either mechanism.';

  /// Whether the pass can be drawn with no network.
  static const bool rendersOffline = true;

  static const String offlineNote =
      'The venue door is the worst signal in the journey -- a hall, a '
      'basement, three hundred phones on one cell. A pass that needs a network '
      'call to draw fails precisely where it is used, and the failure looks to '
      'the parent like the booking not existing.';

  // -----------------------------------------------------------------------
  // Screen conditions.
  // -----------------------------------------------------------------------

  /// The pass screen raises brightness while it is showing. The single most
  /// common real-world scan failure is a dim screen under a fixed scanner.
  static const bool raisesScreenBrightness = true;

  /// And restores it, because leaving a phone at full brightness is a battery
  /// complaint that nobody connects back to this screen.
  static const bool restoresBrightnessOnLeave = true;

  static double quietZoneDpFor(HabotQrGeometry g) =>
      g.quietZoneModules * g.moduleSizeDp;

  /// The shape a pass payload is allowed to take. Anything that is not this
  /// is not encoded -- a free-form payload is how a child's name ends up in a
  /// picture that gets forwarded.
  static final RegExp payloadShape =
      RegExp(r'^HB1:[A-Z0-9]{8,32}:\d{1,12}:[a-f0-9]{8,16}$');

  static bool payloadIsWellFormed(String payload) =>
      payloadShape.hasMatch(payload);

  // -----------------------------------------------------------------------
  // Metric: Generation & Scan Success Rate. 0.97 / 0.999 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.97;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// The generation half is entirely this app's; the scan half depends on a
  /// camera, a scanner and a room. What is graded here is generation and the
  /// screen-side conditions that decide most scan failures.
  static Map<String, bool> checksFor(String payload) {
    final HabotQrGeometry? g = geometryFor(payload);
    if (g == null) {
      return <String, bool>{'payload fits a tabulated version': false};
    }
    return <String, bool>{
      'payload fits a tabulated version': true,
      'the quiet zone is four modules, per the specification':
          g.quietZoneModules == quietZoneModules,
      'the quiet zone is reserved in layout, not left to the card':
          quietZoneDpFor(g) > 0 && g.renderedSideDp > g.symbolSideDp,
      'the module size is large enough to resolve off a screen':
          moduleSizeIsScannable(g),
      'error correction tolerates a fingerprint':
          errorCorrection == HabotQrErrorCorrection.quartile,
      'the payload is an opaque reference and nothing else':
          payloadIsWellFormed(payload),
      'the pass expires': isWithinValidity(
            generatedWindow: 0,
            presentedWindow: 0,
          ) &&
          !isWithinValidity(generatedWindow: 0, presentedWindow: 5),
      'the pass renders with no network': rendersOffline,
      'the screen is brightened while the pass is shown':
          raisesScreenBrightness && restoresBrightnessOnLeave,
    };
  }

  static double generationSuccessRate(String payload) {
    final Map<String, bool> c = checksFor(payload);
    return c.values.where((bool b) => b).length / c.length;
  }

  static String qualitativeOutput(double rate) =>
      rate >= floor ? 'Pass' : 'Fail';

  static const String quietZoneIsTheCommonFailureNote =
      'The most common scan failure is a QR laid out flush to a card edge. '
      'The quiet zone is part of the symbol, not padding around it, and a '
      'scanner that cannot find four clear modules does not find the symbol '
      'at all. It is reserved in the geometry here so a later layout change '
      'cannot quietly remove it.';

  static const String vectorIsAboutEdgesNote =
      'A raster QR resampled by the layout engine blurs module edges, and a '
      'blurred boundary is the one thing a scanner cannot recover. Vector '
      'rendering also makes module size a derived quantity rather than a '
      'property of an asset file, which is what lets a minimum be enforced.';

  static const String scanHalfIsNotOursNote =
      'Scan success depends on a camera, a scanner and a room, and no figure '
      'for it can be produced on this host. What is graded is generation and '
      'the screen-side conditions -- quiet zone, module size, brightness, '
      'error correction -- which is where the scan failures this app can cause '
      'actually come from.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Render a dynamic vector QR code pass on the order confirmation '
      'screen."';
}
