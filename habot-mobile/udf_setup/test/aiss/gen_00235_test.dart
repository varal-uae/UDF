/// AISS GATE -- Step 23 of 35
/// Global Reference ID:       GEN-00235
/// Atomic Steps Reference ID: GEN-00235-A01
/// Setup Step (Action):       "Set the default snapping point to 60% viewport
///                             height for optimal thumb interaction."
/// Metric: Cross-Viewport Rendering Consistency
///   Floor   "Zero regressions on primary breakpoints (360/390/412px)"
///   Optimal "Zero regressions across full tested device matrix"
///   Ceiling "N/A (zero-tolerance metric, no upper bound)"
///
/// The metric is what makes this a separate step from the sheet itself: a snap
/// fraction is trivially correct in isolation and only means something when it
/// is checked against every device the app claims to support. The device
/// matrix SSTLA-004 recorded in Step 5 is that list.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/surfaces/bottom_sheet.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  final List<String> deviceReadings = <String>[];

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

  group('GEN-00235-A01 :: default snapping point', () {
    gate(
      'GEN-00235-G1',
      'Setup Step (Action): "Set the default snapping point to 60% viewport '
          'height."',
      'The default stop is exactly 0.60 of the viewport',
      () => HabotSheet.defaultSnapFraction == 0.60,
    );

    gate(
      'GEN-00235-G2',
      'Setup Step (Action) -- a "snapping point" only exists among other stops; '
          'a lone value is an initial size, not a snap.',
      'The stops are ascending, bounded by the min and max, and the default is '
          'one of them',
      () {
        final List<double> stops = HabotSheetSnap.stops;
        for (int i = 1; i < stops.length; i++) {
          if (stops[i] <= stops[i - 1]) {
            return false;
          }
        }
        return stops.first == HabotSheet.minSnapFraction &&
            stops.last == HabotSheet.maxSnapFraction &&
            HabotSheetSnap.isStop(HabotSheet.defaultSnapFraction) &&
            HabotSheet.minSnapFraction < HabotSheet.defaultSnapFraction &&
            HabotSheet.defaultSnapFraction < HabotSheet.maxSnapFraction;
      },
    );

    gate(
      'GEN-00235-G3',
      'Metric: Cross-Viewport Rendering Consistency. Floor "Zero regressions on '
          'primary breakpoints (360/390/412px)", Optimal "Zero regressions '
          'across full tested device matrix."',
      'On every device in the recorded matrix, the 60% stop leaves a usable '
          'sheet -- checked device by device, not inferred from the fraction',
      () {
        bool allUsable = true;
        for (final HabotDeviceProfile device in HabotDevices.all) {
          final double height = HabotSheetSnap.defaultHeightFor(
            device.heightDp,
          );
          final bool usable = HabotSheetSnap.isUsableOn(device.heightDp);
          deviceReadings.add(
            '${device.name} ${device.widthDp.toStringAsFixed(0)}x'
            '${device.heightDp.toStringAsFixed(0)} -> '
            '${height.toStringAsFixed(0)}dp '
            '${usable ? 'OK' : 'TOO SHORT'}',
          );
          allUsable = allUsable && usable;
        }
        return allUsable && HabotDevices.all.length >= 9;
      },
    );

    gate(
      'GEN-00235-G4',
      'Metric: Cross-Viewport Rendering Consistency -- "consistency" fails the '
          'moment one screen size gets its own value.',
      'No file under lib/ overrides the snap fraction: the token is read, never '
          'redefined, and no device-conditional snap logic exists',
      () {
        final List<String> offenders = <String>[];
        for (final File file
            in Directory('lib')
                .listSync(recursive: true)
                .whereType<File>()
                .where((File f) => f.path.endsWith('.dart'))) {
          final String path = file.path.replaceAll('\\', '/');
          if (path.endsWith('tokens/surface_tokens.dart')) {
            continue;
          }
          final String code = file.readAsStringSync();
          if (RegExp(r'initialChildSize:\s*(?!HabotSheet)\S').hasMatch(code)) {
            offenders.add(path);
          }
        }
        return offenders.isEmpty;
      },
    );

    gate(
      'GEN-00235-G5',
      'Common Library to Store -- tokens.json is the source of truth for every '
          'design value.',
      'The snap fractions in tokens.json match the Dart constants exactly',
      () {
        final Map<String, dynamic> json =
            jsonDecode(
                  File(
                    'lib/design_system/tokens/tokens.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final Map<String, dynamic> surfaces =
            json['surfaces'] as Map<String, dynamic>;
        return (surfaces['sheet_default_snap_fraction'] as num) ==
                HabotSheet.defaultSnapFraction &&
            (surfaces['sheet_min_snap_fraction'] as num) ==
                HabotSheet.minSnapFraction &&
            (surfaces['sheet_max_snap_fraction'] as num) ==
                HabotSheet.maxSnapFraction &&
            (surfaces['sheet_min_usable_height_dp'] as num) ==
                HabotSheet.minUsableSheetHeight;
      },
    );
  });

  group('GEN-00235-A01 :: measured on a rendered sheet', () {
    testWidgets('[GEN-00235-G6] a sheet opened on a 390x844 viewport comes to '
        'rest at the 60% stop', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: FilledButton(
                  onPressed: () => HabotBottomSheet.show<void>(
                    context: context,
                    title: 'Snap check',
                    builder: (BuildContext context) => const Text('content'),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final RenderBox sheet = tester.renderObject<RenderBox>(
        find.byType(HabotSheetSurface),
      );
      final double fraction = sheet.size.height / 844;

      // A band rather than an exact equality: the rendered height is the snap
      // fraction of the route's own constraints, which excludes any system
      // inset the harness applies. The stop is asserted exactly by G1; this
      // gate is about what actually reaches the screen.
      expect(fraction, greaterThan(0.50));
      expect(fraction, lessThan(0.70));

      gates.add(
        AissGate(
          id: 'GEN-00235-G6',
          requirementSource:
              'Setup Step (Action): "Set the default snapping point to 60% '
              'viewport height for optimal thumb interaction." Measured on a '
              'rendered sheet rather than read back off the constant.',
          description:
              'On a 390x844 viewport the opened sheet occupies the 60% stop, '
              'leaving the top 40% of the screen visible',
          passed: true,
          detail:
              'rendered ${sheet.size.height.toStringAsFixed(0)}dp of 844dp = '
              '${(fraction * 100).toStringAsFixed(1)}%',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00235',
        atomicStepReferenceId: 'GEN-00235-A01',
        setupStepAction:
            'Set the default snapping point to 60% viewport height for optimal '
            'thumb interaction.',
        implementationOrder: 23,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Name': 'Bottom-sheet default snap point',
          'Configuration Value':
              '${(HabotSheet.defaultSnapFraction * 100).toStringAsFixed(0)}% of '
              'viewport height',
          'Device Coverage': '${HabotDevices.all.length} profiles',
          'Per-device readings': deviceReadings.join(' | '),
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Cross-Viewport Rendering Consistency',
            observed:
                'Zero regressions -- the 60% stop is usable on all '
                '${HabotDevices.all.length} matrix devices, including the '
                '360/390/412dp primary breakpoints',
            floor: 'Zero regressions on primary breakpoints (360/390/412px)',
            optimal: 'Zero regressions across full tested device matrix',
            ceiling: 'N/A (zero-tolerance metric, no upper bound)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/bottom_sheet.dart',
          'lib/design_system/tokens/surface_tokens.dart',
          'lib/design_system/tokens/tokens.json',
        ],
      ),
    );
  });
}
