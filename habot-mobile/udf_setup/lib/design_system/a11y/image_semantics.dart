/// AISS Step 100 -- GEN-02764
/// "Write alt text for all informational images and set alt to empty string
///  for decorative images."
/// WCAG 2.2 SC 1.1.1 Non-text Content (Level A).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE HALF PEOPLE SKIP is the second one. Alt text on informational images is
/// well known. Empty alt on DECORATIVE images is what separates a usable
/// screen reader experience from an unusable one: a divider, a background
/// flourish and a spacer each announced as "image" turn a five-element screen
/// into a fifteen-element screen, and a screen reader that is exhausting to
/// use is a screen reader that gets switched off.
///
/// HOW THIS IS ENFORCED. Not by asking. There are exactly two ways to put a
/// picture on screen in this design system after this step:
///
///   [HabotImage]           -- informational. `alt` is required and cannot be
///                             blank; the constructor asserts it.
///   [HabotDecorativeImage] -- decorative. Takes no alt at all and excludes
///                             itself from semantics.
///
/// A raw `Image(` anywhere under `lib/` is a build failure, added to the
/// poka-yoke guard by Step 97. That is what makes this a rule rather than a
/// convention: the wrong thing does not compile past the guard, so it cannot
/// be forgotten.
library;

import 'package:flutter/widgets.dart';

/// Why an image is on the screen. There is no third answer, and forcing the
/// choice at the call site is the whole mechanism.
enum HabotImagePurpose {
  /// Carries information not available in the surrounding text.
  informational,

  /// Carries none. A divider, a texture, a flourish.
  decorative,
}

/// The rules alt text is held to, as data rather than as advice.
class HabotAltText {
  const HabotAltText._();

  /// A screen reader already says "image". Alt text that also says "image of"
  /// makes the announcement "image, image of a signed form".
  static const List<String> redundantPrefixes = <String>[
    'image of',
    'picture of',
    'photo of',
    'graphic of',
    'icon of',
    'an image',
    'a picture',
  ];

  /// Long enough to mean something.
  static const int minLength = 3;

  /// Long enough to be a sentence someone will sit through. Beyond this the
  /// content belongs in the page, not in an announcement.
  static const int maxLength = 140;

  /// Whether [alt] is usable as an informational alternative.
  static bool isUsable(String alt) => defectIn(alt) == null;

  /// The first thing wrong with [alt], or null if nothing is.
  static String? defectIn(String alt) {
    final String trimmed = alt.trim();
    if (trimmed.length < minLength) {
      return 'empty or too short: an informational image must describe what '
          'it shows. If it shows nothing, it is decorative -- use '
          'HabotDecorativeImage.';
    }
    if (trimmed.length > maxLength) {
      return 'longer than $maxLength characters: a screen reader reads this '
          'in full with no way to skim. Put the detail in the page.';
    }
    final String lower = trimmed.toLowerCase();
    for (final String p in redundantPrefixes) {
      if (lower.startsWith(p)) {
        return 'starts with "$p": the reader already announces that this is '
            'an image.';
      }
    }
    if (RegExp(r'\.(png|jpe?g|gif|svg|webp)$', caseSensitive: false)
        .hasMatch(trimmed)) {
      return 'looks like a file name rather than a description.';
    }
    return null;
  }
}

/// An image that carries information. Alt text is required and validated.
class HabotImage extends StatelessWidget {
  HabotImage({
    required this.image,
    required this.alt,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    super.key,
  }) {
    // Not a lint and not a review comment: a bad alt does not construct.
    final String? defect = HabotAltText.defectIn(alt);
    if (defect != null) {
      throw ArgumentError.value(alt, 'alt', defect);
    }
  }

  final ImageProvider<Object> image;

  /// What the image tells the reader. Not what file it is.
  final String alt;

  final double? width;
  final double? height;
  final BoxFit fit;

  HabotImagePurpose get purpose => HabotImagePurpose.informational;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: alt,
      child: ExcludeSemantics(
        child: Image(
          image: image,
          width: width,
          height: height,
          fit: fit,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

/// An image that carries no information. Announced as nothing at all.
///
/// There is no `alt` parameter here, which is deliberate: the empty string is
/// not a value someone passes, it is the consequence of choosing this widget.
class HabotDecorativeImage extends StatelessWidget {
  const HabotDecorativeImage({
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final ImageProvider<Object> image;
  final double? width;
  final double? height;
  final BoxFit fit;

  HabotImagePurpose get purpose => HabotImagePurpose.decorative;

  @override
  Widget build(BuildContext context) {
    // ExcludeSemantics is the empty-alt equivalent: the node is not in the
    // tree at all, so there is nothing for the reader to skip past.
    return ExcludeSemantics(
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        excludeFromSemantics: true,
      ),
    );
  }
}
