/// AISS: MCIIM-021-A01 -- "Enforce Visual Isolation (Byt-Level Cropping)."
/// Setup Step Description: "Access the Micro Task Outsourcing (MTO) API layout
/// configuration file."
/// 4 Substeps: "1) Define bounding box coordinates. 2) Crop source document.
///              3) Serve cropped image only. 4) Remove surrounding context."
/// Poka-Yoke: "Backend physically crops the image; the mobile UI CANNOT FETCH
///             OR REQUEST the full document URL."
/// Completion Measure: "Worker cannot see the whole document on their mobile
///                      device UNDER ANY CIRCUMSTANCE."
/// Metric: Human-in-the-Loop Task Turnaround & Consensus Accuracy --
///         Floor 90% inter-worker agreement, Optimal 95-99%, Ceiling 100%.
///
/// AISS: MCIIM-009-09-A01 -- "Define MTO Viewport Crop Padding."
/// Setup Step Description: "Write dynamic layout scaling constraints to manage
/// variable browser window frames."
/// Data Requirement: "Image scales to remain legible without zooming. | Fluid
/// image containers max-width: 100%. | Total focus on atomic task. | CSS
/// overflow: hidden."
/// Metric: Schema Constraint Compliance Rate -- Floor 0.98, Optimal 1.0.
///
/// THE ANCHOR OF THE BATCH. This is the only fully coherent row in it, and its
/// completion measure is the kind you can fail a build on: "worker cannot see
/// the whole document on their mobile device under any circumstance." Every
/// layout decision in Steps 82-95 is downstream of that sentence, which is why
/// it is implemented first and as a TYPE rather than as a rule people follow.
///
/// HOW THE POKA-YOKE IS ENFORCED. The sheet says the mobile UI cannot fetch or
/// request the full document URL. In a design system that cannot be a code
/// review comment, so [HabotByt] has no field, no getter, no constructor
/// parameter and no factory through which a source-document URL could travel.
/// The only asset it carries is one the backend has already cropped, and
/// [HabotCropContract] rejects anything that is not demonstrably a crop. A
/// caller holding a full document URL has nowhere to put it.
///
/// ON THE METRIC (MCIIM-021): inter-worker consensus is a crowd-labour outcome
/// measured across people doing the same task twice. No widget test produces
/// it, and none is invented here -- it is recorded as NOT PRODUCED, and what
/// this suite CAN observe (the isolation the metric depends on) is measured
/// instead. The sheet's own Self-Chasing column makes that link explicit: "if
/// cropping is bad, workers will fail the 15-minute timer because they cannot
/// read the image."
library;

import 'package:flutter/foundation.dart';

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Substep 1: "Define bounding box coordinates."
///
/// Coordinates are in the SOURCE DOCUMENT's own pixel space. They are not
/// screen coordinates and never become them here -- Step 83 does that
/// translation, deliberately in a different file, because a box that knows
/// about screens is a box that can be nudged to reveal a little more.
@immutable
class HabotBoundingBox {
  const HabotBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  /// The page this box was cut from. Kept as DIMENSIONS, not as a locator:
  /// knowing the page is 2480x3508 tells the layout how to scale; it does not
  /// tell anyone how to fetch it.
  final double sourceWidth;
  final double sourceHeight;

  double get right => left + width;
  double get bottom => top + height;

  /// True when the box is a real rectangle that lies inside its source.
  bool get isValid =>
      width > 0 &&
      height > 0 &&
      left >= 0 &&
      top >= 0 &&
      sourceWidth > 0 &&
      sourceHeight > 0 &&
      right <= sourceWidth &&
      bottom <= sourceHeight;

  double get aspectRatio => height == 0 ? 0 : width / height;

  /// The share of the source page this box exposes. The completion measure in
  /// one number: a worker seeing the whole document would read 1.0.
  double get exposedFraction {
    final double sourceArea = sourceWidth * sourceHeight;
    if (sourceArea <= 0) {
      return 0;
    }
    return (width * height) / sourceArea;
  }

  /// A box that covers effectively the whole page is not a crop. The threshold
  /// is deliberately generous -- this catches "cropping" that removed a margin
  /// and called it isolation.
  bool get exposesWholeDocument => exposedFraction >= wholeDocumentFraction;

  static const double wholeDocumentFraction = 0.90;

  @override
  bool operator ==(Object other) =>
      other is HabotBoundingBox &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height &&
      other.sourceWidth == sourceWidth &&
      other.sourceHeight == sourceHeight;

  @override
  int get hashCode =>
      Object.hash(left, top, width, height, sourceWidth, sourceHeight);

  @override
  String toString() =>
      'HabotBoundingBox(${left.toStringAsFixed(0)},'
      '${top.toStringAsFixed(0)} '
      '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)} '
      'of ${sourceWidth.toStringAsFixed(0)}x'
      '${sourceHeight.toStringAsFixed(0)})';
}

/// Why a delivered asset was refused.
enum HabotCropRefusal {
  /// The box does not describe a rectangle inside its source.
  invalidBox,

  /// The box exposes effectively the whole page -- a crop in name only.
  wholeDocument,

  /// The asset is not a crop: it carries no crop signature, or one that
  /// disagrees with the box.
  uncroppedAsset,

  /// The asset points at a document rather than an image snippet.
  sourceDocument,
}

/// Substeps 2 and 3: "Crop source document" / "Serve cropped image ONLY."
///
/// The client does not crop. It refuses to display anything the backend has
/// not already cropped, which is a different and much stronger guarantee: a
/// client-side crop is a full document that happens to be partly covered, and
/// the file is still on the device.
class HabotCropContract {
  const HabotCropContract._();

  /// A cropped asset carries the box it was cut to, stamped by the service
  /// that cut it. The client checks the stamp against the box it was told to
  /// render, so a crop for a different region is refused rather than shown.
  static const String cropParam = 'crop';

  /// Path segment the cropping service writes its output under.
  static const String cropSegment = 'crops';

  /// Extensions a page image can have. A PDF or DOCX arriving here is the
  /// source document, not a snippet.
  static const Set<String> snippetExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
  };

  static const Set<String> documentExtensions = <String>{
    '.pdf',
    '.doc',
    '.docx',
    '.tif',
    '.tiff',
  };

  /// The crop stamp for [box], in the form the service writes it.
  static String signatureFor(HabotBoundingBox box) =>
      '${box.left.round()},${box.top.round()},'
      '${box.width.round()},${box.height.round()}';

  /// Null when the asset is an acceptable crop of [box]; otherwise the reason
  /// it was refused.
  static HabotCropRefusal? refuse(Uri asset, HabotBoundingBox box) {
    if (!box.isValid) {
      return HabotCropRefusal.invalidBox;
    }
    if (box.exposesWholeDocument) {
      return HabotCropRefusal.wholeDocument;
    }
    final String path = asset.path.toLowerCase();
    for (final String extension in documentExtensions) {
      if (path.endsWith(extension)) {
        return HabotCropRefusal.sourceDocument;
      }
    }
    final bool looksLikeSnippet = snippetExtensions.any(path.endsWith);
    final bool underCropSegment = asset.pathSegments.contains(cropSegment);
    final String? stamp = asset.queryParameters[cropParam];
    if (!looksLikeSnippet || !underCropSegment || stamp == null) {
      return HabotCropRefusal.uncroppedAsset;
    }
    if (stamp != signatureFor(box)) {
      return HabotCropRefusal.uncroppedAsset;
    }
    return null;
  }
}

/// One atomic unit of work: a crop, and the question asked about it.
///
/// THE POKA-YOKE IS THE SHAPE OF THIS CLASS. There is no `documentUrl`, no
/// `sourceUri`, no `pageAsset` and no `withFullContext()`. The only way to
/// build one is [HabotByt.fromDelivery], which refuses anything that is not
/// already a crop. That is what "the mobile UI cannot fetch or request the
/// full document URL" looks like when it is executable rather than promised.
@immutable
class HabotByt {
  const HabotByt._({
    required this.id,
    required this.box,
    required this.snippet,
    required this.prompt,
    required this.expectedFormat,
  });

  /// Null when the delivery was refused; [refusalFor] says why.
  ///
  /// Returning null rather than throwing is deliberate: a refused crop is an
  /// operational event that belongs in a queue and a counter (Step 90), not an
  /// exception thrown at a worker holding a phone.
  static HabotByt? fromDelivery({
    required String id,
    required HabotBoundingBox box,
    required Uri snippet,
    required String prompt,
    required String expectedFormat,
  }) {
    if (id.isEmpty || prompt.isEmpty) {
      return null;
    }
    if (HabotCropContract.refuse(snippet, box) != null) {
      return null;
    }
    return HabotByt._(
      id: id,
      box: box,
      snippet: snippet,
      prompt: prompt,
      expectedFormat: expectedFormat,
    );
  }

  /// Why a delivery would be refused, for the caller that needs to record it.
  static HabotCropRefusal? refusalFor({
    required HabotBoundingBox box,
    required Uri snippet,
  }) => HabotCropContract.refuse(snippet, box);

  final String id;
  final HabotBoundingBox box;

  /// The ONLY asset reference this type carries.
  final Uri snippet;

  /// The one question. UX Translation: "Minimalist UI showing one cropped
  /// image and one specific input."
  final String prompt;

  /// What the answer should look like -- e.g. 'digits only', 'YYYY-MM-DD'.
  final String expectedFormat;

  /// The share of the source document this task exposes. Read by the
  /// isolation audit and reported in the evidence.
  double get exposedFraction => box.exposedFraction;

  String get semanticsLabel =>
      'Task $id. $prompt. Cropped evidence only; the source document is not '
      'available on this device.';
}

/// Substep 4: "Remove surrounding context", measured.
///
/// The completion measure names a state of the world ("worker cannot see the
/// whole document"), so this turns it into a number that can be asserted and
/// reported: the share of delivered tasks whose evidence is a genuine crop and
/// whose surrounding context is absent.
class HabotIsolationAudit {
  const HabotIsolationAudit._();

  /// A delivery is isolated when it produced a [HabotByt] at all -- which by
  /// construction means a valid box, a real crop, and no route back to the
  /// page it came from.
  static bool isIsolated(HabotByt? byt) => byt != null;

  /// Isolation compliance over a set of deliveries: 1.0 when every one of them
  /// was either isolated or refused, and nothing partially-isolated reached a
  /// screen. There is no middle value by design -- a task is either a crop or
  /// it is not shown.
  static double complianceOf(Iterable<HabotByt?> deliveries) {
    final List<HabotByt?> all = deliveries.toList();
    if (all.isEmpty) {
      return 1;
    }
    final int isolated = all.where(isIsolated).length;
    return isolated / all.length;
  }

  /// The worst exposure in a set -- the single largest share of a source page
  /// any one task revealed. The completion measure is that this stays well
  /// under [HabotBoundingBox.wholeDocumentFraction].
  static double worstExposure(Iterable<HabotByt> tasks) {
    double worst = 0;
    for (final HabotByt task in tasks) {
      if (task.exposedFraction > worst) {
        worst = task.exposedFraction;
      }
    }
    return worst;
  }
}

/// MCIIM-009-09: the four layout constraints the Data Requirement names.
///
/// Named as an enum rather than checked inline so the compliance rate the
/// metric asks for is a count over a closed set, not a percentage of whatever
/// the author remembered to check.
enum HabotCropConstraint {
  /// "Image scales to remain legible without zooming."
  legibleWithoutZoom,

  /// "Fluid image containers max-width: 100%."
  fluidMaxWidth,

  /// "Total focus on atomic task." -- the crop occupies the pane it was given,
  /// with nothing else competing inside it.
  totalFocus,

  /// "CSS overflow: hidden." -- nothing of the snippet spills outside its
  /// frame, because a spilled edge is surrounding context.
  overflowHidden,
}

/// The padding and scaling rules that make a crop readable in a pane.
///
/// TRANSLATION, RECORDED: the Data Requirement is written in CSS. In Flutter
/// "max-width: 100%" is a fluid width bounded by the pane, and "overflow:
/// hidden" is a clipped container. Stated rather than quietly performed.
class HabotCropPadding {
  const HabotCropPadding._();

  /// Breathing room between the crop and its frame. From the spacing scale --
  /// this is the only padding a task screen has, so it is not a free choice.
  static const double framePadding = HabotSpacing.xs;

  /// The crop is laid out inside the grid's own margins, so a snippet and a
  /// paragraph on the same screen start at the same x.
  static const double outerMargin = HabotGrid.outerMargin;

  /// Below this the crop is too small to read without pinching, which is the
  /// failure the Self-Chasing column describes ("workers will fail the
  /// 15-minute timer because they cannot read the image").
  ///
  /// Expressed as a scale factor against the crop's own pixel size: a 600px
  /// wide region rendered into 300dp is 0.5, which is legible for document
  /// text at typical capture resolutions; below a third it is not.
  static const double minLegibleScale = 1 / 3;

  /// The share of the source page a crop may expose before it stops being a
  /// crop. Same constant the box itself uses -- one number, one place.
  static const double maxExposedFraction =
      HabotBoundingBox.wholeDocumentFraction;

  /// Evaluates every named constraint for a crop about to be rendered into
  /// [paneWidth] x [paneHeight].
  static Map<HabotCropConstraint, bool> evaluate({
    required HabotBoundingBox box,
    required double paneWidth,
    required double paneHeight,
    required double renderedWidth,
    required double renderedHeight,
  }) {
    final double scale = box.width == 0 ? 0 : renderedWidth / box.width;
    return <HabotCropConstraint, bool>{
      HabotCropConstraint.legibleWithoutZoom: scale >= minLegibleScale,
      // Fluid: fills the pane it was given, and never exceeds it.
      HabotCropConstraint.fluidMaxWidth:
          renderedWidth <= paneWidth + _epsilon &&
          renderedWidth >= paneWidth - _epsilon,
      HabotCropConstraint.totalFocus: box.exposedFraction < maxExposedFraction,
      HabotCropConstraint.overflowHidden:
          renderedHeight <= paneHeight + _epsilon,
    };
  }

  /// Metric: Schema Constraint Compliance Rate. The share of the four named
  /// constraints that hold, averaged over however many layouts were checked.
  static double complianceRate(Iterable<Map<HabotCropConstraint, bool>> runs) {
    final List<Map<HabotCropConstraint, bool>> all = runs.toList();
    if (all.isEmpty) {
      return 1;
    }
    int satisfied = 0;
    int total = 0;
    for (final Map<HabotCropConstraint, bool> run in all) {
      for (final bool value in run.values) {
        total++;
        if (value) {
          satisfied++;
        }
      }
    }
    return total == 0 ? 1 : satisfied / total;
  }

  /// Floor / Optimal from the metric row.
  static const double complianceFloor = 0.98;
  static const double complianceOptimal = 1.0;

  static const double _epsilon = 0.5;
}
