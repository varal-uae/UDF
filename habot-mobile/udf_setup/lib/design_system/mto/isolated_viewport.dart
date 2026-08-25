/// AISS: MCIIM-008-A01 -- "Building Isolated Visual Viewports for Broken Byt
/// Context Isolation."
/// Setup Step Description: "Render the final isolated viewport to ensure NO
/// UNRELATED FILE DETAILS are visible to the user."
/// Data Requirement: "Allocate EXACTLY 50% of the viewport height to the
/// snippet image viewer, using the rest for the input box. | Use clean,
/// neutral container borders to frame the reference snippet image."
/// Metric: Millisecond Precision Accuracy (ms) -- Optimal 50.0, Ceiling 100.0.
///
/// CONTAMINATED ROW, RECORDED: eleven columns describe an API gateway and
/// Cloud Run ingress layer -- Decision Before ("What runtime timeout
/// configuration protects resource connections during high traffic load?"),
/// Why This Matters ("Eliminates point-to-point service dependencies"),
/// Expected Output ("API Gateway Configuration Blueprint and Dynamic Routing
/// Flow Maps"), Completion Measures ("API gateway lookups dynamically redirect
/// incoming requests"), Flow Impact, Dashboard Implication, What Must Be
/// Standardized, Atomic Reusability, Common Library, GCP Alignment and the
/// four Material Design columns about progress lines and error boundaries.
/// None are gated. Two columns are specific and usable, and they are what this
/// file implements: the Description and the 50%-height allocation.
///
/// METRIC MISMATCH, RECORDED: "Millisecond Precision Accuracy" against the W3C
/// High Resolution Time standard is a clock measure on a rendering step. It is
/// reported as NOT PRODUCED. Step 93 builds the clock this row's metric would
/// belong to, and measures its drift there.
///
/// AISS: GEN-00112-A01 -- "Test visual isolation on mobile devices to ensure
/// FULL READABILITY WITHOUT MANUAL PANNING."
/// Metric: Test Case Pass Rate -- Floor ">= 95% pass rate before release
/// gate", Optimal "100% pass rate on defined test suite".
///
/// A TEST STEP WITH A TEST METRIC, which is rare enough in this sheet to be
/// worth using literally: [HabotReadabilityAudit] IS the defined test suite,
/// it runs over the Step 5 device matrix in both orientations, and the pass
/// rate it returns is the number the metric asks for.
///
/// THE 50% IS THE STEP 36 BALANCED RATIO, NOT A NEW NUMBER. `HabotSplitRatio`
/// already declares an even split at 0.50 and Steps 36-38 already gated it, so
/// this file reads that enum and a gate asserts the equality. If the Contextual
/// Mirror ever changes what "balanced" means, this fails rather than quietly
/// disagreeing with the rest of the app.
library;

import 'package:flutter/material.dart';

import '../layout/device_profiles.dart';
import '../shell/contextual_mirror.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'byt_isolation.dart';
import 'isolation_geometry.dart';

/// Builds the image for a crop. Injected so the gates can render the viewport
/// without a network: a widget test cannot load an image over HTTP, and a
/// viewport that silently rendered nothing in tests would prove nothing.
typedef HabotSnippetImageBuilder =
    Widget Function(BuildContext context, HabotByt byt);

/// The isolated viewport: one crop, framed, with nothing else inside it.
class HabotIsolatedViewport extends StatelessWidget {
  const HabotIsolatedViewport({
    required this.byt,
    this.imageBuilder,
    super.key,
  });

  final HabotByt byt;

  /// Null uses the production builder, which loads the cropped snippet.
  final HabotSnippetImageBuilder? imageBuilder;

  static const Key viewportKey = Key('habot.mto.viewport');
  static const Key frameKey = Key('habot.mto.viewport.frame');

  /// "Allocate exactly 50% of the viewport height to the snippet image
  /// viewer" -- and this IS the Step 36 balanced ratio, not a second 0.5.
  static double get evidenceShare => HabotSplitRatio.balanced.evidenceShare;

  /// "Use clean, neutral container borders to frame the reference snippet."
  static const double frameRadius = HabotShape.xs;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final HabotSnippetImageBuilder builder = imageBuilder ?? _networkSnippet;
    return Semantics(
      key: viewportKey,
      label: byt.semanticsLabel,
      image: true,
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(HabotCropPadding.framePadding),
        child: DecoratedBox(
          key: frameKey,
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(frameRadius),
          ),
          // "CSS overflow: hidden" -- a spilled edge is surrounding context,
          // so the frame clips rather than letting the snippet bleed.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(frameRadius),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: builder(context, byt),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _networkSnippet(BuildContext context, HabotByt byt) =>
      Image.network(
        byt.snippet.toString(),
        width: byt.box.width,
        height: byt.box.height,
        fit: BoxFit.contain,
      );
}

/// One readability case: one device, one orientation.
@immutable
class HabotReadabilityCase {
  const HabotReadabilityCase({
    required this.device,
    required this.landscape,
    required this.passed,
    required this.detail,
  });

  final String device;
  final bool landscape;
  final bool passed;
  final String detail;

  @override
  String toString() =>
      '$device ${landscape ? 'landscape' : 'portrait'}: '
      '${passed ? 'pass' : 'FAIL - $detail'}';
}

/// GEN-00112: the defined test suite behind the Test Case Pass Rate.
///
/// A case passes when the crop is fully visible inside the evidence pane at a
/// legible scale -- no clipping, no pinching, and no horizontal overflow that
/// would make the worker pan the image to read it.
class HabotReadabilityAudit {
  const HabotReadabilityAudit._();

  /// Floor Boundary: ">= 95% pass rate before release gate."
  static const double passRateFloor = 0.95;

  /// Optimal Target: "100% pass rate on defined test suite."
  static const double passRateOptimal = 1.0;

  /// Runs [box] over every device in the Step 5 matrix, both orientations.
  static List<HabotReadabilityCase> run({
    required HabotBoundingBox box,
    List<HabotDeviceProfile>? devices,
  }) {
    final List<HabotDeviceProfile> matrix = devices ?? HabotDevices.all;
    final List<HabotReadabilityCase> cases = <HabotReadabilityCase>[];
    for (final HabotDeviceProfile device in matrix) {
      for (final bool landscape in <bool>[false, true]) {
        final double width = landscape ? device.heightDp : device.widthDp;
        final double height = landscape ? device.widthDp : device.heightDp;
        final Size pane = Size(width, height * HabotIsolatedViewport.evidenceShare);
        final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
          box: box,
          paneSize: pane,
          viewportWidth: width,
        );
        final bool fitsWidth = layout.width <= pane.width + 0.5;
        final bool legible = layout.scale >= HabotCropPadding.minLegibleScale;
        final bool passed = !layout.clipped && fitsWidth && legible;
        cases.add(
          HabotReadabilityCase(
            device: device.name,
            landscape: landscape,
            passed: passed,
            detail: passed
                ? 'no panning required at '
                      '${layout.scale.toStringAsFixed(2)}x'
                : <String>[
                    if (layout.clipped) 'clipped',
                    if (!fitsWidth) 'wider than the pane',
                    if (!legible)
                      'scale ${layout.scale.toStringAsFixed(2)} below floor',
                  ].join(', '),
          ),
        );
      }
    }
    return cases;
  }

  static double passRateOf(List<HabotReadabilityCase> cases) => cases.isEmpty
      ? 1
      : cases.where((HabotReadabilityCase c) => c.passed).length / cases.length;

  static List<HabotReadabilityCase> failuresIn(
    List<HabotReadabilityCase> cases,
  ) => cases.where((HabotReadabilityCase c) => !c.passed).toList();
}

/// The evidence pane and the action pane, in the ratio MCIIM-008 names.
///
/// Deliberately a layout helper rather than a screen: Step 87 puts it inside
/// the Contextual Mirror, and Step 91 fills the action half. Keeping the split
/// arithmetic here means the 50% appears once.
class HabotEvidenceSplit {
  const HabotEvidenceSplit._();

  static double evidenceHeightFor(double viewportHeight) =>
      viewportHeight * HabotIsolatedViewport.evidenceShare;

  static double actionHeightFor(double viewportHeight) =>
      viewportHeight - evidenceHeightFor(viewportHeight);

  /// The gap between the two panes, from the spacing scale.
  static const double paneGap = HabotSpacing.xs;
}
