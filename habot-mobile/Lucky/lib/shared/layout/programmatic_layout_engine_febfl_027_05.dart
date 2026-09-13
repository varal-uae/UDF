// FEBFL-027-05 — Programmatic Layout Mapping Engine.
// Ingests backend JSON layout instructions to parse and dynamically assemble responsive screens with grid dimensions, spacing rules, and alignment settings according to Material 3 design tokens.

import 'dart:convert';
import 'package:flutter/material.dart';

/// Supported layout types for backend programmatic rendering.
enum ProgrammaticLayoutType {
  column,
  row,
  grid,
  stack,
  wrap,
}

/// Validation state for parsed layout instructions.
enum LayoutValidationStatus {
  valid,
  warning,
  invalidFallback,
}

/// Completion and evaluation tiers based on Design System adherence.
enum AdherenceEvaluationTier {
  good,
  average,
  poor,
}

/// Immutable spacing rules adhering to Material Design 3 spacing tokens.
@immutable
class LayoutSpacingRules {
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double itemSpacing;
  final double runSpacing;

  const LayoutSpacingRules({
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.itemSpacing = 12.0,
    this.runSpacing = 12.0,
  });

  factory LayoutSpacingRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LayoutSpacingRules();

    double parseToken(dynamic val, double fallback) {
      if (val is num) return val.toDouble();
      if (val is String) {
        // Map standard design token indirection variables
        switch (val.toLowerCase()) {
          case 'none':
            return 0.0;
          case 'compact':
          case 'xs':
            return 4.0;
          case 'sm':
            return 8.0;
          case 'md':
          case 'medium':
            return 16.0;
          case 'lg':
          case 'large':
            return 24.0;
          case 'xl':
            return 32.0;
        }
      }
      return fallback;
    }

    final pTop = parseToken(json['paddingTop'] ?? json['padding'], 16.0);
    final pBottom = parseToken(json['paddingBottom'] ?? json['padding'], 16.0);
    final pLeft = parseToken(json['paddingLeft'] ?? json['padding'], 16.0);
    final pRight = parseToken(json['paddingRight'] ?? json['padding'], 16.0);

    return LayoutSpacingRules(
      padding: EdgeInsets.only(
        top: pTop,
        bottom: pBottom,
        left: pLeft,
        right: pRight,
      ),
      itemSpacing: parseToken(json['itemSpacing'], 12.0),
      runSpacing: parseToken(json['runSpacing'], 12.0),
    );
  }
}

/// Grid dimension specifications for multi-device responsive tracks.
@immutable
class LayoutGridDimensions {
  final int crossAxisCount;
  final double childAspectRatio;
  final double maxCrossAxisExtent;
  final bool autoResponsiveTracks;

  const LayoutGridDimensions({
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.maxCrossAxisExtent = 320.0,
    this.autoResponsiveTracks = true,
  });

  factory LayoutGridDimensions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LayoutGridDimensions();
    return LayoutGridDimensions(
      crossAxisCount: (json['crossAxisCount'] as num?)?.toInt() ?? 2,
      childAspectRatio:
          (json['childAspectRatio'] as num?)?.toDouble() ?? 1.0,
      maxCrossAxisExtent:
          (json['maxCrossAxisExtent'] as num?)?.toDouble() ?? 320.0,
      autoResponsiveTracks:
          (json['autoResponsiveTracks'] as bool?) ?? true,
    );
  }
}

/// Alignment settings parsed from backend JSON instruction.
@immutable
class LayoutAlignmentSettings {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment wrapAlignment;

  const LayoutAlignmentSettings({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapAlignment = WrapAlignment.start,
  });

  factory LayoutAlignmentSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LayoutAlignmentSettings();

    MainAxisAlignment parseMainAxis(String? val) {
      switch (val?.toLowerCase()) {
        case 'center':
          return MainAxisAlignment.center;
        case 'end':
        case 'bottom':
        case 'right':
          return MainAxisAlignment.end;
        case 'spacebetween':
          return MainAxisAlignment.spaceBetween;
        case 'spacearound':
          return MainAxisAlignment.spaceAround;
        case 'spaceevenly':
          return MainAxisAlignment.spaceEvenly;
        default:
          return MainAxisAlignment.start;
      }
    }

    CrossAxisAlignment parseCrossAxis(String? val) {
      switch (val?.toLowerCase()) {
        case 'start':
        case 'top':
        case 'left':
          return CrossAxisAlignment.start;
        case 'end':
        case 'bottom':
        case 'right':
          return CrossAxisAlignment.end;
        case 'stretch':
          return CrossAxisAlignment.stretch;
        default:
          return CrossAxisAlignment.center;
      }
    }

    WrapAlignment parseWrapAlign(String? val) {
      switch (val?.toLowerCase()) {
        case 'center':
          return WrapAlignment.center;
        case 'end':
          return WrapAlignment.end;
        case 'spacebetween':
          return WrapAlignment.spaceBetween;
        default:
          return WrapAlignment.start;
      }
    }

    return LayoutAlignmentSettings(
      mainAxisAlignment: parseMainAxis(json['mainAxis'] as String?),
      crossAxisAlignment: parseCrossAxis(json['crossAxis'] as String?),
      wrapAlignment: parseWrapAlign(json['wrapAlign'] as String?),
    );
  }
}

/// Parsed representation of backend dynamic layout instruction.
class ProgrammaticLayoutInstruction {
  final String layoutId;
  final ProgrammaticLayoutType layoutType;
  final LayoutGridDimensions gridDimensions;
  final LayoutSpacingRules spacingRules;
  final LayoutAlignmentSettings alignmentSettings;
  final List<Map<String, dynamic>> rawChildren;
  final LayoutValidationStatus validationStatus;
  final double adherenceRate;
  final AdherenceEvaluationTier completionStatus;
  final DateTime actionTimestamp;
  final String? sessionId;

  ProgrammaticLayoutInstruction({
    required this.layoutId,
    required this.layoutType,
    required this.gridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.rawChildren,
    required this.validationStatus,
    required this.adherenceRate,
    required this.completionStatus,
    required this.actionTimestamp,
    this.sessionId,
  });

  Map<String, dynamic> toTelemetryPayload() {
    return {
      'layout_id': layoutId,
      'layout_type': layoutType.name,
      'grid_dimensions': {
        'cross_axis_count': gridDimensions.crossAxisCount,
        'child_aspect_ratio': gridDimensions.childAspectRatio,
      },
      'spacing_rules': {
        'item_spacing': spacingRules.itemSpacing,
        'run_spacing': spacingRules.runSpacing,
      },
      'alignment_settings': {
        'main_axis': alignmentSettings.mainAxisAlignment.name,
        'cross_axis': alignmentSettings.crossAxisAlignment.name,
      },
      'validation_status': validationStatus.name,
      'adherence_rate': adherenceRate,
      'completion_status': completionStatus == AdherenceEvaluationTier.good
          ? 'Good (100%)'
          : (completionStatus == AdherenceEvaluationTier.average
              ? 'Average'
              : 'Poor'),
      'action_timestamp': actionTimestamp.toIso8601String(),
      'session_id': sessionId ?? 'anonymous',
    };
  }
}

/// Core Parser for backend programmatic layout mapping.
class LayoutInstructionParser {
  static ProgrammaticLayoutInstruction parse({
    required dynamic source,
    String? sessionId,
  }) {
    final DateTime timestamp = DateTime.now();
    Map<String, dynamic> json;

    if (source is String) {
      try {
        json = jsonDecode(source) as Map<String, dynamic>;
      } catch (_) {
        json = <String, dynamic>{};
      }
    } else if (source is Map<String, dynamic>) {
      json = source;
    } else {
      json = <String, dynamic>{};
    }

    double calculatedScore = 1.0;
    LayoutValidationStatus validationStatus = LayoutValidationStatus.valid;

    final rawType = json['layoutType'] as String?;
    ProgrammaticLayoutType layoutType;
    switch (rawType?.toLowerCase()) {
      case 'row':
        layoutType = ProgrammaticLayoutType.row;
        break;
      case 'grid':
        layoutType = ProgrammaticLayoutType.grid;
        break;
      case 'stack':
        layoutType = ProgrammaticLayoutType.stack;
        break;
      case 'wrap':
        layoutType = ProgrammaticLayoutType.wrap;
        break;
      case 'column':
      default:
        layoutType = ProgrammaticLayoutType.column;
        if (rawType == null) {
          calculatedScore -= 0.05;
          validationStatus = LayoutValidationStatus.warning;
        }
    }

    final gridData = json['gridDimensions'] as Map<String, dynamic>?;
    final spacingData = json['spacingRules'] as Map<String, dynamic>?;
    final alignData = json['alignmentSettings'] as Map<String, dynamic>?;
    final childrenList = (json['children'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    if (gridData == null && layoutType == ProgrammaticLayoutType.grid) {
      calculatedScore -= 0.1;
      validationStatus = LayoutValidationStatus.invalidFallback;
    }

    final gridDimensions = LayoutGridDimensions.fromJson(gridData);
    final spacingRules = LayoutSpacingRules.fromJson(spacingData);
    final alignmentSettings = LayoutAlignmentSettings.fromJson(alignData);

    AdherenceEvaluationTier tier;
    if (calculatedScore >= 0.95) {
      tier = AdherenceEvaluationTier.good;
    } else if (calculatedScore >= 0.85) {
      tier = AdherenceEvaluationTier.average;
    } else {
      tier = AdherenceEvaluationTier.poor;
    }

    return ProgrammaticLayoutInstruction(
      layoutId: json['layoutId'] as String? ?? 'gen_${timestamp.millisecondsSinceEpoch}',
      layoutType: layoutType,
      gridDimensions: gridDimensions,
      spacingRules: spacingRules,
      alignmentSettings: alignmentSettings,
      rawChildren: childrenList,
      validationStatus: validationStatus,
      adherenceRate: calculatedScore,
      completionStatus: tier,
      actionTimestamp: timestamp,
      sessionId: sessionId,
    );
  }
}

/// Programmatic Dynamic Layout Renderer.
class ProgrammaticLayoutRenderer extends StatelessWidget {
  final ProgrammaticLayoutInstruction instruction;
  final Widget Function(BuildContext context, Map<String, dynamic> childJson)
      childBuilder;
  final void Function(Map<String, dynamic> telemetry)? onTelemetryEmitted;

  const ProgrammaticLayoutRenderer({
    super.key,
    required this.instruction,
    required this.childBuilder,
    this.onTelemetryEmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (onTelemetryEmitted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTelemetryEmitted!(instruction.toTelemetryPayload());
      });
    }

    final widgets = instruction.rawChildren.map((e) => childBuilder(context, e)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget layoutWidget;

        switch (instruction.layoutType) {
          case ProgrammaticLayoutType.row:
            layoutWidget = Row(
              mainAxisAlignment: instruction.alignmentSettings.mainAxisAlignment,
              crossAxisAlignment: instruction.alignmentSettings.crossAxisAlignment,
              children: _interleaveSpacing(
                widgets,
                SizedBox(width: instruction.spacingRules.itemSpacing),
              ),
            );
            break;
          case ProgrammaticLayoutType.grid:
            final crossAxisCount = instruction.gridDimensions.autoResponsiveTracks
                ? (constraints.maxWidth ~/ instruction.gridDimensions.maxCrossAxisExtent)
                    .clamp(1, 6)
                : instruction.gridDimensions.crossAxisCount;

            layoutWidget = GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widgets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: instruction.gridDimensions.childAspectRatio,
                crossAxisSpacing: instruction.spacingRules.itemSpacing,
                mainAxisSpacing: instruction.spacingRules.runSpacing,
              ),
              itemBuilder: (ctx, index) => widgets[index],
            );
            break;
          case ProgrammaticLayoutType.wrap:
            layoutWidget = Wrap(
              spacing: instruction.spacingRules.itemSpacing,
              runSpacing: instruction.spacingRules.runSpacing,
              alignment: instruction.alignmentSettings.wrapAlignment,
              children: widgets,
            );
            break;
          case ProgrammaticLayoutType.stack:
            layoutWidget = Stack(
              alignment: Alignment.topLeft,
              children: widgets,
            );
            break;
          case ProgrammaticLayoutType.column:
          default:
            layoutWidget = Column(
              mainAxisAlignment: instruction.alignmentSettings.mainAxisAlignment,
              crossAxisAlignment: instruction.alignmentSettings.crossAxisAlignment,
              children: _interleaveSpacing(
                widgets,
                SizedBox(height: instruction.spacingRules.itemSpacing),
              ),
            );
        }

        return Container(
          padding: instruction.spacingRules.padding,
          margin: instruction.spacingRules.margin,
          child: layoutWidget,
        );
      },
    );
  }

  List<Widget> _interleaveSpacing(List<Widget> items, Widget spacer) {
    if (items.isEmpty) return [];
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
}
