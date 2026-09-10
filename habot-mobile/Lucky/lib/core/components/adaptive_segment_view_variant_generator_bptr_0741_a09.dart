// BPTR-0741-A09 — Adaptive Segment View Variant Generator.
// Provides swappable Material 3 layout variants driven by segment data, with grid, spacing, alignment, validation, and touch-safe controls.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DynamicLayoutType { standard, compact, expanded }

enum LayoutValidationStatus { valid, invalid, pending }

@immutable
class LayoutGridDimensions {
  const LayoutGridDimensions({required this.columns, required this.gutter, required this.margin});
  final int columns;
  final double gutter;
  final double margin;
  LayoutGridDimensions copyWith({int? columns, double? gutter, double? margin}) => LayoutGridDimensions(
    columns: columns ?? this.columns,
    gutter: gutter ?? this.gutter,
    margin: margin ?? this.margin,
  );
}

@immutable
class SpacingRules {
  const SpacingRules({required this.xs, required this.sm, required this.md, required this.lg});
  final double xs;
  final double sm;
  final double md;
  final double lg;
  SpacingRules copyWith({double? xs, double? sm, double? md, double? lg}) => SpacingRules(
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
  );
}

@immutable
class AlignmentSettings {
  const AlignmentSettings({required this.alignment, required this.crossAxisAlignment});
  final Alignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  AlignmentSettings copyWith({Alignment? alignment, CrossAxisAlignment? crossAxisAlignment}) => AlignmentSettings(
    alignment: alignment ?? this.alignment,
    crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
  );
}

@immutable
class SegmentProfile {
  const SegmentProfile({required this.segmentKey, required this.layoutType, this.locale, this.registrationStage});
  final String segmentKey;
  final DynamicLayoutType layoutType;
  final String? locale;
  final String? registrationStage;
}

@immutable
class LayoutVariantConfig {
  const LayoutVariantConfig({
    required this.layoutType,
    required this.grid,
    required this.spacing,
    required this.alignment,
    required this.validationStatus,
    this.swappableCopy = const <String, String>{},
  });
  final DynamicLayoutType layoutType;
  final LayoutGridDimensions grid;
  final SpacingRules spacing;
  final AlignmentSettings alignment;
  final LayoutValidationStatus validationStatus;
  final Map<String, String> swappableCopy;
  LayoutVariantConfig copyWith({
    DynamicLayoutType? layoutType,
    LayoutGridDimensions? grid,
    SpacingRules? spacing,
    AlignmentSettings? alignment,
    LayoutValidationStatus? validationStatus,
    Map<String, String>? swappableCopy,
  }) => LayoutVariantConfig(
    layoutType: layoutType ?? this.layoutType,
    grid: grid ?? this.grid,
    spacing: spacing ?? this.spacing,
    alignment: alignment ?? this.alignment,
    validationStatus: validationStatus ?? this.validationStatus,
    swappableCopy: swappableCopy ?? this.swappableCopy,
  );
}

class AdaptiveSegmentViewVariantController extends ChangeNotifier {
  AdaptiveSegmentViewVariantController({LayoutVariantConfig? initialConfig})
      : _config = initialConfig ?? _defaultConfig();

  LayoutVariantConfig _config;
  LayoutVariantConfig get config => _config;

  void applySegment(SegmentProfile profile) {
    final next = switch (profile.layoutType) {
      DynamicLayoutType.compact => _config.copyWith(
          layoutType: DynamicLayoutType.compact,
          grid: const LayoutGridDimensions(columns: 2, gutter: 12, margin: 16),
          spacing: const SpacingRules(xs: 4, sm: 8, md: 12, lg: 16),
          validationStatus: LayoutValidationStatus.pending,
        ),
      DynamicLayoutType.expanded => _config.copyWith(
          layoutType: DynamicLayoutType.expanded,
          grid: const LayoutGridDimensions(columns: 4, gutter: 16, margin: 24),
          spacing: const SpacingRules(xs: 6, sm: 12, md: 16, lg: 24),
          validationStatus: LayoutValidationStatus.pending,
        ),
      DynamicLayoutType.standard => _config.copyWith(
          layoutType: DynamicLayoutType.standard,
          grid: const LayoutGridDimensions(columns: 3, gutter: 16, margin: 20),
          spacing: const SpacingRules(xs: 4, sm: 8, md: 16, lg: 24),
          validationStatus: LayoutValidationStatus.pending,
        ),
    };
    _config = next.copyWith(swappableCopy: <String, String>{..._config.swappableCopy, 'segmentKey': profile.segmentKey});
    notifyListeners();
  }

  void markValidated(LayoutValidationStatus status) {
    _config = _config.copyWith(validationStatus: status);
    notifyListeners();
  }

  static LayoutVariantConfig _defaultConfig() => const LayoutVariantConfig(
        layoutType: DynamicLayoutType.standard,
        grid: LayoutGridDimensions(columns: 3, gutter: 16, margin: 20),
        spacing: SpacingRules(xs: 4, sm: 8, md: 16, lg: 24),
        alignment: AlignmentSettings(alignment: Alignment.centerLeft, crossAxisAlignment: CrossAxisAlignment.start),
        validationStatus: LayoutValidationStatus.pending,
      );
}

class AdaptiveSegmentViewVariantGenerator extends StatefulWidget {
  const AdaptiveSegmentViewVariantGenerator({
    super.key,
    required this.segment,
    this.controller,
    this.variants,
    this.fallbackBuilder,
  });

  final SegmentProfile segment;
  final AdaptiveSegmentViewVariantController? controller;
  final Map<DynamicLayoutType, Widget>? variants;
  final Widget Function(BuildContext context, LayoutVariantConfig config)? fallbackBuilder;

  @override
  State<AdaptiveSegmentViewVariantGenerator> createState() => _AdaptiveSegmentViewVariantGeneratorState();
}

class _AdaptiveSegmentViewVariantGeneratorState extends State<AdaptiveSegmentViewVariantGenerator> {
  late AdaptiveSegmentViewVariantController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AdaptiveSegmentViewVariantController();
    _ownsController = widget.controller == null;
    _controller.applySegment(widget.segment);
  }

  @override
  void didUpdateWidget(covariant AdaptiveSegmentViewVariantGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segment != widget.segment) {
      _controller.applySegment(widget.segment);
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final config = _controller.config;
        final variant = widget.variants?[config.layoutType] ??
            widget.fallbackBuilder?.call(context, config) ??
            _defaultVariant(context, config);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(key: ValueKey(config.layoutType), child: variant),
        );
      },
    );
  }

  Widget _defaultVariant(BuildContext context, LayoutVariantConfig config) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth - (config.grid.margin * 2);
          final cellWidth = maxWidth <= 0
              ? 0.0
              : (maxWidth - (config.grid.gutter * (config.grid.columns - 1))) / config.grid.columns;
          return SingleChildScrollView(
            padding: EdgeInsets.all(config.spacing.md),
            child: Align(
              alignment: config.alignment.alignment,
              child: Column(
                crossAxisAlignment: config.alignment.crossAxisAlignment,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      config.swappableCopy['title'] ?? 'Adaptive layout preview',
                      style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  SizedBox(height: config.spacing.sm),
                  Text(
                    config.swappableCopy['subtitle'] ?? 'Swappable component variants update without a full app update.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  SizedBox(height: config.spacing.md),
                  _StatusChip(status: config.validationStatus, spacing: config.spacing),
                  SizedBox(height: config.spacing.md),
                  TextField(
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Segment-aware input',
                      contentPadding: EdgeInsets.all(config.spacing.md),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: config.spacing.md),
                  Wrap(
                    spacing: config.spacing.sm,
                    runSpacing: config.spacing.sm,
                    children: List<Widget>.generate(config.grid.columns, (index) {
                      return ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: cellWidth.clamp(120.0, 240.0).toDouble()),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: EdgeInsets.all(config.spacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Cell ${index + 1}', style: theme.textTheme.labelLarge),
                                SizedBox(height: config.spacing.xs),
                                Text('Grid ${config.grid.columns} col', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: config.spacing.lg),
                  FilledButton.icon(
                    onPressed: () => _controller.markValidated(LayoutValidationStatus.valid),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Validate layout'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.symmetric(horizontal: config.spacing.md, vertical: config.spacing.sm),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.spacing});
  final LayoutValidationStatus status;
  final SpacingRules spacing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      LayoutValidationStatus.valid => ('Validated', scheme.primary),
      LayoutValidationStatus.invalid => ('Invalid', scheme.error),
      LayoutValidationStatus.pending => ('Pending validation', scheme.tertiary),
    };
    return Semantics(
      label: 'Layout validation status: $label',
      child: Chip(
        label: Text(label),
        avatar: Icon(Icons.rule, color: color, size: 18),
        padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      ),
    );
  }
}
