/// AISS GATE -- Step 56 of 65
/// Global Reference ID:       GEN-01330
/// Atomic Steps Reference ID: GEN-01330-A01
/// Setup Step (Action):       "Package chart components into
///                             @habot/charts/mobile-spend."
/// Metric: Budget Visualization Data Accuracy -- Floor 0.98, Optimal 0.999,
///         Ceiling 1.0.
///
/// One of the few GEN-* metrics in this batch that fits its step. A chart that
/// draws a point somewhere other than where its value is has an accuracy
/// problem, and because the renderer is a vector path built from
/// [HabotChartGeometry], that accuracy is arithmetic rather than a screenshot.
/// G4 measures it directly: every point, every ratio, every matrix width.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/charts/habot_charts.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

HabotChartSeries _series() => HabotChartSeries.fromSparse(
  label: 'mobile spend',
  sparse: const <int, double>{
    0: 1200, 1: 1310, 2: 1180, 3: 1420, 4: 1505, 5: 1490,
  },
  length: 6,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int pointsChecked = 0;
  int pointsAccurate = 0;
  double worstErrorDp = 0;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('GEN-01330-A01 :: the package boundary', () {
    gate(
      'GEN-01330-G1',
      'Setup Step (Action): "PACKAGE chart components into '
          '@habot/charts/mobile-spend."',
      'The package identity from the sheet is recorded in code and mapped to a '
          'real path, and the manifest lists both the public surface and the '
          'implementation files behind it -- so "packaged" is a checkable '
          'claim rather than a folder someone named optimistically',
      () =>
          HabotChartsPackage.name == '@habot/charts/mobile-spend' &&
          HabotChartsPackage.path == 'lib/design_system/charts' &&
          HabotChartsPackage.publicTypes.length >= 10 &&
          HabotChartsPackage.implementationFiles.length == 4 &&
          Directory(HabotChartsPackage.path).existsSync(),
    );

    gate(
      'GEN-01330-G2',
      'Setup Step (Action) -- a package whose internals are reachable from '
          'outside is a folder, not a package.',
      'Every implementation file the manifest names exists, and no file '
          'outside the package imports one of them directly: callers go '
          'through the barrel',
      () {
        for (final String file in HabotChartsPackage.implementationFiles) {
          if (!File('${HabotChartsPackage.path}/$file').existsSync()) {
            return false;
          }
        }
        for (final File file in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((File f) => f.path.endsWith('.dart'))) {
          if (file.path.contains('design_system/charts/')) {
            continue;
          }
          final String code = file.readAsStringSync();
          for (final String impl in HabotChartsPackage.implementationFiles) {
            if (code.contains("charts/$impl'")) {
              return false;
            }
          }
        }
        return true;
      },
    );

    gate(
      'GEN-01330-G3',
      'Setup Step (Action) -- the barrel is only a boundary if it actually '
          'exposes what callers need.',
      'Every type the manifest calls public is exported by the barrel, so the '
          'manifest and the export list cannot drift apart',
      () {
        final String barrel = File(
          '${HabotChartsPackage.path}/habot_charts.dart',
        ).readAsStringSync();
        for (final String type in HabotChartsPackage.publicTypes) {
          if (!barrel.contains(type)) {
            return false;
          }
        }
        return true;
      },
    );
  });

  group('GEN-01330-A01 :: measured accuracy', () {
    gate(
      'GEN-01330-G4',
      'Metric: Budget Visualization Data Accuracy -- Floor 0.98, Optimal '
          '0.999, Ceiling 1.0.',
      'Every plotted point sits where its value says it should: the y offset '
          'recovered from the geometry matches the value re-derived from the '
          'axis range, across every matrix width and every ratio',
      () {
        final HabotChartSeries series = _series();
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final double width in <double>[device.widthDp, device.heightDp]) {
            for (final HabotChartRatio ratio in HabotChartRatio.values) {
              final HabotChartGeometry g = HabotChartSpec.resolve(
                width: width,
                series: series,
                ratio: ratio,
              );
              for (final HabotChartPoint point in series.points) {
                pointsChecked++;
                final ({double dx, double dy}) o =
                    g.offsetFor(point, series.points.length);
                // Invert the projection: a y offset back to a value.
                final double recovered =
                    g.axisMin + (1 - (o.dy / g.plotHeight)) * g.axisSpan;
                final double errorDp =
                    ((recovered - point.value).abs() / g.axisSpan) *
                        g.plotHeight;
                if (errorDp > worstErrorDp) {
                  worstErrorDp = errorDp;
                }
                if (errorDp < 0.5) {
                  pointsAccurate++;
                }
              }
            }
          }
        }
        return pointsChecked > 0 &&
            (pointsAccurate / pointsChecked) >= 0.999 &&
            worstErrorDp < 0.5;
      },
    );

    gate(
      'GEN-01330-G5',
      'Metric -- an accuracy measure that cannot fail is not a measure.',
      'A deliberately wrong projection is detected: shifting one point by a '
          'tenth of the axis span produces an error the same check reports as '
          'inaccurate',
      () {
        final HabotChartSeries series = _series();
        final HabotChartGeometry g =
            HabotChartSpec.resolve(width: 360, series: series);
        final HabotChartPoint point = series.points.first;
        final ({double dx, double dy}) o =
            g.offsetFor(point, series.points.length);
        final double wrongDy = o.dy + (g.plotHeight * 0.1);
        final double recovered =
            g.axisMin + (1 - (wrongDy / g.plotHeight)) * g.axisSpan;
        final double errorDp =
            ((recovered - point.value).abs() / g.axisSpan) * g.plotHeight;
        return errorDp >= 0.5;
      },
    );
  });

  group('GEN-01330-A01 :: rendered', () {
    testWidgets('[GEN-01330-G6] the packaged chart renders from the barrel '
        'alone, at every matrix width, without exception', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.reset);
      for (final HabotDeviceProfile device in HabotDevices.all) {
        tester.view.physicalSize = Size(device.widthDp, device.heightDp);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(body: HabotTrendChart(series: _series())),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(HabotTrendChart.chartKey),
          findsOneWidget,
          reason: 'chart missing at ${device.name}',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'exception at ${device.name}',
        );
      }

      gates.add(
        AissGate(
          id: 'GEN-01330-G6',
          requirementSource:
              'Setup Step (Action): "Package chart components into '
              '@habot/charts/mobile-spend." A package that only works on one '
              'screen size is not packaged.',
          description:
              'The trend chart, imported through the barrel, renders on all '
              '${HabotDevices.all.length} matrix devices with no layout '
              'exception',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01330-G7] a sparkline is a configuration of the same '
        'rules, not a second implementation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(body: HabotSparkline(series: _series())),
        ),
      );
      await tester.pumpAndSettle();

      final Size rendered =
          tester.getSize(find.byKey(HabotSparkline.sparklineKey));
      final HabotChartGeometry expected = HabotChartSpec.resolve(
        width: HabotSparkline.defaultWidth,
        series: _series(),
        ratio: HabotChartRatio.sparkline,
      );
      expect(rendered.width, expected.width);
      expect(rendered.height, expected.height);
      expect(
        expected.subdivisions,
        0,
        reason: 'a sparkline drops the grid rather than shrinking it',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-01330-G7',
          requirementSource:
              'Setup Step (Action) read with LSAV-025 (Step 51): the sparkline '
              'ratio is one of the three locked stops, so the narrowest chart '
              'in the set obeys the same geometry as the widest.',
          description:
              'The rendered sparkline matches the geometry the shared spec '
              'resolves for it, with no grid subdivisions',
          passed: true,
          detail:
              'rendered ${rendered.width.toStringAsFixed(0)}x'
              '${rendered.height.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    final double accuracy =
        pointsChecked == 0 ? 0 : pointsAccurate / pointsChecked;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01330',
        atomicStepReferenceId: 'GEN-01330-A01',
        setupStepAction:
            'Package chart components into @habot/charts/mobile-spend.',
        implementationOrder: 56,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          '@habot/charts/mobile-spend':
              'mapped to ${HabotChartsPackage.path}; '
              '${HabotChartsPackage.publicTypes.length} public types, '
              '${HabotChartsPackage.implementationFiles.length} '
              'implementation files behind the barrel',
          'Component Name': 'HabotTrendChart / HabotSparkline',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Budget Visualization Data Accuracy',
            observed:
                '${accuracy.toStringAsFixed(4)} -- $pointsAccurate of '
                '$pointsChecked plotted points recover their own value from '
                'the geometry within half a device pixel (9 devices x 2 '
                'orientations x 3 ratios x 6 points). Worst error '
                '${worstErrorDp.toStringAsFixed(4)}dp.',
            floor: '0.98',
            optimal: '0.999',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/habot_charts.dart',
          'lib/design_system/charts/trend_chart.dart',
          'lib/design_system/charts/sparkline.dart',
        ],
      ),
    );
  });
}
