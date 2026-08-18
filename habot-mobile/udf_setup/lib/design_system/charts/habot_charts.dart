/// `@habot/charts/mobile-spend` -- the chart package boundary.
///
/// AISS: GEN-01330-A01 -- "Package chart components into
/// @habot/charts/mobile-spend."
///
/// This app is a single Flutter module, so there is no separate pub package to
/// publish. What the sheet asks for is a BOUNDARY: one public surface for
/// charts, so a screen imports charts from one place and cannot reach inside
/// them to re-decide a stroke weight or an axis range. This file is that
/// surface, and the mapping is recorded rather than assumed:
///
///   @habot/charts/mobile-spend  ->  lib/design_system/charts/
///
/// The rule the gates enforce: nothing outside `lib/design_system/charts/` may
/// import a chart implementation file directly. Screens import this barrel.
/// That is what makes the package a package rather than a folder.
library;

export 'chart_geometry.dart'
    show
        HabotChartAxis,
        HabotChartGeometry,
        HabotChartGrid,
        HabotChartPoint,
        HabotChartRatio,
        HabotChartSeries,
        HabotChartSpec,
        HabotChartStroke;
export 'chart_interaction.dart' show HabotChartReading, HabotInteractiveChart;
export 'sparkline.dart' show HabotSparkline;
export 'trend_chart.dart' show HabotTrendChart;

/// The package manifest, as data.
///
/// The sheet's Data Collected column for this step is
/// "@habot/charts/mobile-spend", which is the package identity. Holding it
/// here means the evidence log can report what the package actually contains
/// instead of quoting the name back.
class HabotChartsPackage {
  const HabotChartsPackage._();

  /// The name the sheet gives.
  static const String name = '@habot/charts/mobile-spend';

  /// Where it lives in this codebase.
  static const String path = 'lib/design_system/charts';

  /// The public surface. Anything not on this list is internal to the package,
  /// and the gate fails if a file outside the package imports one.
  static const List<String> publicTypes = <String>[
    'HabotChartAxis',
    'HabotChartGeometry',
    'HabotChartGrid',
    'HabotChartPoint',
    'HabotChartRatio',
    'HabotChartReading',
    'HabotChartSeries',
    'HabotChartSpec',
    'HabotChartStroke',
    'HabotInteractiveChart',
    'HabotSparkline',
    'HabotTrendChart',
  ];

  /// The implementation files behind the barrel.
  static const List<String> implementationFiles = <String>[
    'chart_geometry.dart',
    'chart_interaction.dart',
    'sparkline.dart',
    'trend_chart.dart',
  ];
}
