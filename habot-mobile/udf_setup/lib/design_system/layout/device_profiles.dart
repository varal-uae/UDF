/// AISS: SSTLA-004-A01 -- "Collate cross-device screen resolution metrics for
/// target mobile, tablet, and desktop viewports."
///
/// Dart mirror of `lib/design_system/tokens/device_matrix.json`. The mirror is
/// enforced by `SSTLA-004-G5`, so the JSON stays the single approved artefact
/// (the step's Expected Output names an "Approved JSON Token File") while the
/// widget tests get compile-time constants to iterate over.
library;

import 'dart:ui' show Size;

enum HabotDeviceType { phone, tablet, desktop }

/// Carries exactly the atomic data fields SSTLA-004 names:
/// Mobile Platform; OS Version; Device Type; Screen Dimensions;
/// Mobile Configuration.
class HabotDeviceProfile {
  const HabotDeviceProfile({
    required this.name,
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.widthDp,
    required this.heightDp,
    required this.devicePixelRatio,
    required this.mobileConfiguration,
  });

  final String name;
  final String mobilePlatform;
  final String osVersion;
  final HabotDeviceType deviceType;
  final double widthDp;
  final double heightDp;
  final double devicePixelRatio;
  final String mobileConfiguration;

  Size get logicalSize => Size(widthDp, heightDp);

  @override
  String toString() => '$name (${widthDp.toStringAsFixed(0)}dp)';
}

class HabotDevices {
  const HabotDevices._();

  static const HabotDeviceProfile iphoneSe = HabotDeviceProfile(
    name: 'iPhone SE (2nd/3rd gen)',
    mobilePlatform: 'iOS',
    osVersion: 'iOS 15+',
    deviceType: HabotDeviceType.phone,
    widthDp: 320,
    heightDp: 568,
    devicePixelRatio: 2.0,
    mobileConfiguration: 'compact / 4-column / narrowest supported',
  );

  static const HabotDeviceProfile smallAndroid = HabotDeviceProfile(
    name: 'Galaxy S8 / small Android',
    mobilePlatform: 'Android',
    osVersion: 'Android 9+',
    deviceType: HabotDeviceType.phone,
    widthDp: 360,
    heightDp: 740,
    devicePixelRatio: 3.0,
    mobileConfiguration: 'compact / 4-column / RCGLA-032 test width',
  );

  static const HabotDeviceProfile iphone13Mini = HabotDeviceProfile(
    name: 'iPhone 13 mini',
    mobilePlatform: 'iOS',
    osVersion: 'iOS 16+',
    deviceType: HabotDeviceType.phone,
    widthDp: 375,
    heightDp: 812,
    devicePixelRatio: 3.0,
    mobileConfiguration: 'compact / 4-column / RCGLA-032 test width',
  );

  static const HabotDeviceProfile pixel5 = HabotDeviceProfile(
    name: 'Pixel 5',
    mobilePlatform: 'Android',
    osVersion: 'Android 11+',
    deviceType: HabotDeviceType.phone,
    widthDp: 393,
    heightDp: 851,
    devicePixelRatio: 2.75,
    mobileConfiguration: 'compact / 4-column',
  );

  static const HabotDeviceProfile iphone14Pro = HabotDeviceProfile(
    name: 'iPhone 14 Pro',
    mobilePlatform: 'iOS',
    osVersion: 'iOS 16+',
    deviceType: HabotDeviceType.phone,
    widthDp: 393,
    heightDp: 852,
    devicePixelRatio: 3.0,
    mobileConfiguration: 'compact / 4-column / dynamic island safe area',
  );

  static const HabotDeviceProfile largeAndroid = HabotDeviceProfile(
    name: 'Pixel 7 Pro / large Android',
    mobilePlatform: 'Android',
    osVersion: 'Android 13+',
    deviceType: HabotDeviceType.phone,
    widthDp: 412,
    heightDp: 892,
    devicePixelRatio: 3.5,
    mobileConfiguration: 'compact / 4-column / RCGLA-032 test width',
  );

  static const HabotDeviceProfile ipadMini = HabotDeviceProfile(
    name: 'iPad Mini (portrait)',
    mobilePlatform: 'iPadOS',
    osVersion: 'iPadOS 16+',
    deviceType: HabotDeviceType.tablet,
    widthDp: 744,
    heightDp: 1133,
    devicePixelRatio: 2.0,
    mobileConfiguration:
        'medium / 8-column / navigation still collapsed (below 768dp)',
  );

  static const HabotDeviceProfile ipadPro = HabotDeviceProfile(
    name: 'iPad Pro 12.9 (portrait)',
    mobilePlatform: 'iPadOS',
    osVersion: 'iPadOS 16+',
    deviceType: HabotDeviceType.tablet,
    widthDp: 1024,
    heightDp: 1366,
    devicePixelRatio: 2.0,
    mobileConfiguration: 'expanded / 12-column / navigation expanded',
  );

  static const HabotDeviceProfile desktopWeb = HabotDeviceProfile(
    name: 'Desktop web (baseline)',
    mobilePlatform: 'Web',
    osVersion: 'evergreen Chrome/Safari/Firefox',
    deviceType: HabotDeviceType.desktop,
    widthDp: 1280,
    heightDp: 800,
    devicePixelRatio: 1.0,
    mobileConfiguration:
        'expanded / 12-column / content capped at 840dp reading width',
  );

  /// The approved target matrix. Every layout gate iterates over this list, so
  /// adding a device here automatically widens test coverage.
  static const List<HabotDeviceProfile> all = <HabotDeviceProfile>[
    iphoneSe,
    smallAndroid,
    iphone13Mini,
    pixel5,
    iphone14Pro,
    largeAndroid,
    ipadMini,
    ipadPro,
    desktopWeb,
  ];

  /// The compact resolutions RCGLA-032 substep 4 names explicitly.
  static const List<double> rcgla032TestWidths = <double>[360, 375, 412];

  static List<HabotDeviceProfile> ofType(HabotDeviceType type) =>
      all.where((HabotDeviceProfile d) => d.deviceType == type).toList();
}
