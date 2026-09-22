// =============================================================================
// AEETE-030-09 — Responsive Image Protocol (CLS Prevention)
// Atomic Step: Enforce responsive image loading protocols to prevent layout shifts
// Metric:      UI Design-System Adherence Rate · Floor=>=85% · Optimal=>=95%
// Standard:    Material Design 3 / Nielsen Norman Group
// CLS Gate:    cls_score < 0.1 (Google Core Web Vitals — Good)
// Module:      responsive_image_manager.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// =============================================================================

import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums — match DB CHECK constraints
// ---------------------------------------------------------------------------

/// Image asset types — matches asset_type CHECK constraint.
enum ImageAssetType {
  heroBanner,        // hero_banner    · 16:9 · eager
  productCard,       // product_card   · 4:3  · lazy
  profileAvatar,     // profile_avatar · 1:1  · lazy
  listingThumbnail,  // listing_thumbnail · 3:4 · lazy
  iconAsset,         // icon_asset     · 1:1  · eager
}

extension ImageAssetTypeExt on ImageAssetType {
  String get dbValue => switch (this) {
    ImageAssetType.heroBanner       => 'hero_banner',
    ImageAssetType.productCard      => 'product_card',
    ImageAssetType.profileAvatar    => 'profile_avatar',
    ImageAssetType.listingThumbnail => 'listing_thumbnail',
    ImageAssetType.iconAsset        => 'icon_asset',
  };
}

/// MD3 aspect ratios — matches aspect_ratio CHECK constraint.
enum MD3AspectRatio { r16x9, r4x3, r1x1, r3x4 }

extension MD3AspectRatioExt on MD3AspectRatio {
  String get dbValue => switch (this) {
    MD3AspectRatio.r16x9 => '16:9',
    MD3AspectRatio.r4x3  => '4:3',
    MD3AspectRatio.r1x1  => '1:1',
    MD3AspectRatio.r3x4  => '3:4',
  };

  /// Aspect ratio as (width, height) multipliers.
  (double, double) get ratioValues => switch (this) {
    MD3AspectRatio.r16x9 => (16, 9),
    MD3AspectRatio.r4x3  => (4, 3),
    MD3AspectRatio.r1x1  => (1, 1),
    MD3AspectRatio.r3x4  => (3, 4),
  };
}

/// Loading strategy — matches loading_strategy CHECK constraint.
enum ImageLoadingStrategy { eager, lazy }

/// Skeleton placeholder type — matches skeleton_type CHECK constraint.
enum SkeletonType {
  shimmerFull,     // SHIMMER_FULL
  shimmerCard,     // SHIMMER_CARD
  shimmerCircle,   // SHIMMER_CIRCLE
  shimmerPortrait, // SHIMMER_PORTRAIT
  none,            // NONE (icon_asset)
}

// ---------------------------------------------------------------------------
// CLS threshold (Google Core Web Vitals)
// ---------------------------------------------------------------------------

/// Maximum CLS score for Good rating. Gate: cls_score < 0.1.
const double kCLSGoodThreshold = 0.1;

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Compiled protocol rule for one image asset type.
/// Maps to image_rule_registry row. immutable_IND=TRUE once registered.

/// Mandatory DCDF lineage headers — AEETE-018 standard.
/// These fields make this file's outputs traceable backward
/// through the pipeline to their origin source document.
class DcdfLineage {
  final String traceId;                // end-to-end transaction UUID
  final String originSourceId;         // originating system node UUID
  final String immediatePredecessorId; // direct upstream node UUID
  final String transformationLogicHash; // SHA-256 of executing EC logic
  final bool   complianceStatusInd;    // DCDF gate: true = passed

  const DcdfLineage({
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    this.complianceStatusInd = false,
  });

  // Fail-closed validation guard — DCDF AEETE-018
  static void _validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError('EC-AEETE03009-000: $fieldName must not be empty for AEETE-030-09');
    }
  }
}

class ImageProtocolRule {
  final ImageAssetType assetType;
  final MD3AspectRatio aspectRatio;
  final int srcset1xWidth; // srcset_1x_width_PX
  final int srcset2xWidth; // srcset_2x_width_PX
  final int srcset3xWidth; // srcset_3x_width_PX
  final ImageLoadingStrategy loadingStrategy;
  final SkeletonType skeletonType;
  final bool immutable; // immutable_IND

  const ImageProtocolRule({
    required this.assetType,
    required this.aspectRatio,
    required this.srcset1xWidth,
    required this.srcset2xWidth,
    required this.srcset3xWidth,
    required this.loadingStrategy,
    required this.skeletonType,
    this.immutable = true,
  });

  /// EC:3 — Compute pixel height from aspect ratio + width.  // error: EC-AEETE03009-001
  /// Prevents CLS by reserving exact space before image loads.
  int computeHeight(int width) {
    final (w, h) = aspectRatio.ratioValues;
    return (width * h / w).round();
  }

  /// Build srcset string for HTML img element.
  String buildSrcset(String baseUrl) =>
      '$baseUrl@1x.webp ${srcset1xWidth}w, '
      '$baseUrl@2x.webp ${srcset2xWidth}w, '
      '$baseUrl@3x.webp ${srcset3xWidth}w';
}

/// CLS compliance result for one asset at one viewport.
/// Maps to image_application_log row.
class CLSComplianceResult {
  final ImageAssetType assetType;
  final int viewportWidthPx;
  final double clsScore;             // cls_score DECIMAL(5,4)
  final bool clsCompliant;           // cls_compliant_IND: score < 0.1
  final bool dimsReserved;           // dims_reserved_IND
  final bool srcsetApplied;          // srcset_applied_IND
  final bool skeletonRendered;       // skeleton_rendered_IND

  const CLSComplianceResult({
    required this.assetType,
    required this.viewportWidthPx,
    required this.clsScore,
    required this.clsCompliant,
    required this.dimsReserved,
    required this.srcsetApplied,
    required this.skeletonRendered,
  });

  bool get isPass =>
      clsCompliant && dimsReserved && srcsetApplied && skeletonRendered;

  String get applicationResult => isPass ? 'PASS' : 'FAIL';
}

/// Adherence rate result — maps to image_validation_log.
class ImageAdherenceResult {
  final double adherenceRatePct;
  final String adherenceOutput; // Good / Average / Poor
  final int assetsCompliant;
  final bool gatePass; // >= 85%

  const ImageAdherenceResult({
    required this.adherenceRatePct,
    required this.adherenceOutput,
    required this.assetsCompliant,
    required this.gatePass,
  });
}

// ---------------------------------------------------------------------------
// Constants — IMAGE_PROTOCOL_RULES (mirrors responsive_image_manager.py)
// ---------------------------------------------------------------------------

const Map<ImageAssetType, ImageProtocolRule> kImageProtocolRules = {
  ImageAssetType.heroBanner: ImageProtocolRule(
    assetType:       ImageAssetType.heroBanner,
    aspectRatio:     MD3AspectRatio.r16x9,
    srcset1xWidth:   360,
    srcset2xWidth:   720,
    srcset3xWidth:   1080,
    loadingStrategy: ImageLoadingStrategy.eager,
    skeletonType:    SkeletonType.shimmerFull,
  ),
  ImageAssetType.productCard: ImageProtocolRule(
    assetType:       ImageAssetType.productCard,
    aspectRatio:     MD3AspectRatio.r4x3,
    srcset1xWidth:   180,
    srcset2xWidth:   360,
    srcset3xWidth:   540,
    loadingStrategy: ImageLoadingStrategy.lazy,
    skeletonType:    SkeletonType.shimmerCard,
  ),
  ImageAssetType.profileAvatar: ImageProtocolRule(
    assetType:       ImageAssetType.profileAvatar,
    aspectRatio:     MD3AspectRatio.r1x1,
    srcset1xWidth:   48,
    srcset2xWidth:   96,
    srcset3xWidth:   144,
    loadingStrategy: ImageLoadingStrategy.lazy,
    skeletonType:    SkeletonType.shimmerCircle,
  ),
  ImageAssetType.listingThumbnail: ImageProtocolRule(
    assetType:       ImageAssetType.listingThumbnail,
    aspectRatio:     MD3AspectRatio.r3x4,
    srcset1xWidth:   120,
    srcset2xWidth:   240,
    srcset3xWidth:   360,
    loadingStrategy: ImageLoadingStrategy.lazy,
    skeletonType:    SkeletonType.shimmerPortrait,
  ),
  ImageAssetType.iconAsset: ImageProtocolRule(
    assetType:       ImageAssetType.iconAsset,
    aspectRatio:     MD3AspectRatio.r1x1,
    srcset1xWidth:   24,
    srcset2xWidth:   48,
    srcset3xWidth:   72,
    loadingStrategy: ImageLoadingStrategy.eager,
    skeletonType:    SkeletonType.none,
  ),
};

// ---------------------------------------------------------------------------
// AEETE-030-09: Responsive Image Manager
// ---------------------------------------------------------------------------

/// Responsive image protocol manager.
///
/// Mirrors ResponsiveImageManager class from responsive_image_manager.py.
class ResponsiveImageManager {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // -------------------------------------------------------------------------
  // EC:3 — Compile protocol rules for all 5 asset types.  // error: EC-AEETE03009-002
  // -------------------------------------------------------------------------
  List<ImageProtocolRule> compileRules() =>
      kImageProtocolRules.values.toList();

  // -------------------------------------------------------------------------
  // EC:6 — CLS compliance check for one asset at one viewport.  // error: EC-AEETE03009-003
  // 4 IND columns checked: cls / dims / srcset / skeleton
  // -------------------------------------------------------------------------
  CLSComplianceResult checkCLSCompliance({
    required ImageAssetType assetType,
    required int viewportWidthPx,
    required double clsScore,
    required bool dimsReserved,
    required bool srcsetApplied,
    required bool skeletonRendered,
  }) {
    return CLSComplianceResult(
      assetType:       assetType,
      viewportWidthPx: viewportWidthPx,
      clsScore:        clsScore,
      clsCompliant:    clsScore < kCLSGoodThreshold,
      dimsReserved:    dimsReserved,
      srcsetApplied:   srcsetApplied,
      skeletonRendered: skeletonRendered,
    );
  }

  // -------------------------------------------------------------------------
  // EC:7 — UI Design-System Adherence Rate.  // error: EC-AEETE03009-004
  // Asset type is compliant only if ALL its viewports pass.
  // Floor=85% · Optimal=95% · Standard: MD3/NNG
  // -------------------------------------------------------------------------
  ImageAdherenceResult calculateAdherence(
    List<CLSComplianceResult> results,
  ) {
    final byAsset = <ImageAssetType, List<CLSComplianceResult>>{};
    for (final r in results) {
      byAsset.putIfAbsent(r.assetType, () => []).add(r);
    }
    final total     = byAsset.length;
    final compliant = byAsset.values
        .where((checks) => checks.every((c) => c.isPass))
        .length;
    final rate   = total > 0 ? compliant / total * 100 : 0.0;
    final output = rate >= 95 ? 'Good' : rate >= 85 ? 'Average' : 'Poor';
    return ImageAdherenceResult(
      adherenceRatePct: rate,
      adherenceOutput:  output,
      assetsCompliant:  compliant,
      gatePass:         rate >= 85,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: types_compiled == types_validated (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int compiled, int validated) => compiled == validated;
}

// ---------------------------------------------------------------------------
// Flutter widget: MD3-compliant responsive image with CLS prevention
// Mirrors ResponsiveImage.jsx — explicit dims + srcset + skeleton
// ---------------------------------------------------------------------------

class ResponsiveImage extends StatefulWidget {
  final ImageAssetType assetType;
  final String src;       // base image URL (without @1x/@2x suffix)
  final String alt;       // accessible alt text
  final int viewportWidth;

  const ResponsiveImage({
    super.key,
    required this.assetType,
    required this.src,
    required this.alt,
    required this.viewportWidth,
  });

  @override
  State<ResponsiveImage> createState() => _ResponsiveImageState();
}

class _ResponsiveImageState extends State<ResponsiveImage> {
  bool _loaded = false;

  ImageProtocolRule get _rule => kImageProtocolRules[widget.assetType]!;

  // EC:3 — Compute reserved dimensions to prevent CLS.  // error: EC-AEETE03009-005
  int get _width  => min(widget.viewportWidth, _rule.srcset1xWidth);
  int get _height => _rule.computeHeight(_width);

  Widget _buildSkeleton() {
    return switch (_rule.skeletonType) {
      SkeletonType.shimmerFull    => _ShimmerBox(borderRadius: 0),
      SkeletonType.shimmerCard    => _ShimmerBox(borderRadius: 8),
      SkeletonType.shimmerCircle  => _ShimmerBox(borderRadius: _width / 2),
      SkeletonType.shimmerPortrait => _ShimmerBox(borderRadius: 4),
      SkeletonType.none           => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.alt,
      image: true,
      child: SizedBox(
        // EC:5 — Explicit dimensions reserved (prevents layout shift)  // error: EC-AEETE03009-006
        width:  _width.toDouble(),
        height: _height.toDouble(),
        child: Stack(
          children: [
            // EC:5 — Skeleton rendered while image loads  // error: EC-AEETE03009-007
            if (!_loaded) SizedBox.expand(child: _buildSkeleton()),
            Image.network(
              '${widget.src}@1x.webp',
              width:  _width.toDouble(),
              height: _height.toDouble(),
              fit:    BoxFit.cover,
              frameBuilder: (_, child, frame, __) {
                if (frame != null && !_loaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _loaded = true);
                  });
                }
                return _loaded ? child : const SizedBox.shrink();
              },
              errorBuilder: (_, __, ___) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton placeholder.
class _ShimmerBox extends StatelessWidget {
  final double borderRadius;
  const _ShimmerBox({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
