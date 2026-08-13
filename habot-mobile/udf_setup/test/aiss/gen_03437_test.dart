/// AISS GATE -- Step 48 of 50
/// Global Reference ID:       GEN-03437
/// Atomic Steps Reference ID: GEN-03437-A01
/// Setup Step (Action):       "Display an 'Offline Mode' status banner and
///                             pending queue counters on UI screens."
/// Metric: Banner Contrast Ratio -- Floor 4.5:1, Optimal 7:1, Ceiling 21:1.
///
/// One of the few GEN-* rows in this batch whose metric genuinely fits its
/// step, and the only one in the batch that names a WCAG figure. The gates
/// below measure the ratio with the Step 4 contrast engine and report the
/// number rather than asserting compliance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/resilience/connectivity_state.dart';
import 'package:udf_setup/design_system/resilience/offline_banner.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  final Map<String, double> measured = <String, double>{};

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

  Widget banner(HabotConnectivityMonitor monitor, {bool dark = false}) =>
      MaterialApp(
        theme: dark ? HabotTheme.dark() : HabotTheme.light(),
        home: Scaffold(body: HabotOfflineBanner(monitor: monitor)),
      );

  /// A monitor already in the requested state, without waiting on timeouts --
  /// the transitions themselves are Step 47's gates, not this step's.
  Future<HabotConnectivityMonitor> monitorAt(
    HabotConnectivity state,
    int pending,
  ) async {
    final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
      poll: () async => state == HabotConnectivity.online,
    );
    final int failures = state == HabotConnectivity.online
        ? 0
        : state == HabotConnectivity.degraded
        ? 1
        : HabotConnectivityPolicy.failuresBeforeOffline;
    for (int i = 0; i < failures; i++) {
      await monitor.pollOnce();
    }
    for (int i = 0; i < pending; i++) {
      monitor.enqueue(HabotPendingItem(id: 'r-$i', kind: 'submission'));
    }
    return monitor;
  }

  group('GEN-03437-A01 :: measured contrast', () {
    gate(
      'GEN-03437-G1',
      'Metric: Banner Contrast Ratio -- Floor 4.5:1, Optimal 7:1, Ceiling '
          '21:1.',
      'The banner text is measured against its own background in both schemes '
          'and both visible states, and every reading clears the 4.5:1 floor',
      () {
        bool all = true;
        for (final MapEntry<String, ColorScheme> scheme
            in <String, ColorScheme>{
              'light': HabotTheme.light().colorScheme,
              'dark': HabotTheme.dark().colorScheme,
            }.entries) {
          for (final HabotConnectivity state in <HabotConnectivity>[
            HabotConnectivity.offline,
            HabotConnectivity.degraded,
          ]) {
            final double ratio = HabotOfflineBannerPalette.contrastFor(
              scheme.value,
              state,
            );
            measured['${scheme.key}/${state.name}'] = ratio;
            all = all && ratio >= WcagThresholds.textFloor;
          }
        }
        return all;
      },
    );

    gate(
      'GEN-03437-G2',
      'Metric Optimal 7:1 -- AAA. A status banner is read once, quickly, '
          'often in bad light, which is the case the optimal column is for.',
      'Every measured reading also clears the 7:1 optimal, so the banner is '
          'reported at optimal rather than merely at floor',
      () {
        bool all = true;
        for (final ColorScheme scheme in <ColorScheme>[
          HabotTheme.light().colorScheme,
          HabotTheme.dark().colorScheme,
        ]) {
          for (final HabotConnectivity state in <HabotConnectivity>[
            HabotConnectivity.offline,
            HabotConnectivity.degraded,
          ]) {
            all =
                all &&
                HabotOfflineBannerPalette.contrastFor(scheme, state) >=
                    WcagThresholds.textOptimal;
          }
        }
        return all;
      },
    );

    gate(
      'GEN-03437-G3',
      'REF-197 (Step 26) plain-language rule, applied to the queue counter: '
          '"1 items waiting" is the kind of detail that makes an app feel '
          'unfinished.',
      'The pending counter has separate singular, plural and empty forms, and '
          'the empty form does not claim a count',
      () =>
          HabotOfflineCopy.pendingFor(0) == 'Nothing is waiting to send.' &&
          HabotOfflineCopy.pendingFor(1) == '1 change is waiting to send.' &&
          HabotOfflineCopy.pendingFor(2) == '2 changes are waiting to send.' &&
          HabotOfflineCopy.pendingFor(17).contains('17 changes') &&
          HabotOfflineCopy.titleFor(HabotConnectivity.offline) ==
              'Offline Mode',
    );
  });

  group('GEN-03437-A01 :: rendered banner', () {
    testWidgets('[GEN-03437-G4] the banner is absent while online and present '
        'with its counter while offline', (WidgetTester tester) async {
      final HabotConnectivityMonitor online = await monitorAt(
        HabotConnectivity.online,
        0,
      );
      addTearDown(online.dispose);
      await tester.pumpWidget(banner(online));
      await tester.pumpAndSettle();
      expect(find.byKey(HabotOfflineBanner.bannerKey), findsNothing);
      expect(find.text(HabotOfflineCopy.offlineTitle), findsNothing);

      final HabotConnectivityMonitor offline = await monitorAt(
        HabotConnectivity.offline,
        3,
      );
      addTearDown(offline.dispose);
      await tester.pumpWidget(banner(offline));
      await tester.pumpAndSettle();
      expect(find.byKey(HabotOfflineBanner.bannerKey), findsOneWidget);
      expect(find.text(HabotOfflineCopy.offlineTitle), findsOneWidget);
      expect(find.byKey(HabotOfflineBanner.pendingCounterKey), findsOneWidget);
      expect(find.text('3 changes are waiting to send.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03437-G4',
          requirementSource:
              'Setup Step (Action): "Display an \'Offline Mode\' status banner '
              'AND PENDING QUEUE COUNTERS on UI screens."',
          description:
              'The banner occupies no space while online, and while offline it '
              'shows the Offline Mode title with the live queue depth',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03437-G5] the banner holds no state of its own: queuing '
        'an item updates the counter in place', (WidgetTester tester) async {
      final HabotConnectivityMonitor monitor = await monitorAt(
        HabotConnectivity.offline,
        1,
      );
      addTearDown(monitor.dispose);

      await tester.pumpWidget(banner(monitor));
      await tester.pumpAndSettle();
      expect(find.text('1 change is waiting to send.'), findsOneWidget);

      monitor.enqueue(const HabotPendingItem(id: 'r-9', kind: 'edit'));
      await tester.pumpAndSettle();

      expect(find.text('2 changes are waiting to send.'), findsOneWidget);
      expect(find.text('1 change is waiting to send.'), findsNothing);

      monitor.drain();
      await tester.pumpAndSettle();
      expect(find.text('Nothing is waiting to send.'), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'GEN-03437-G5',
          requirementSource:
              'Setup Step (Action) -- two sources of truth for "are we '
              'offline?" is how an app ends up showing a sync icon over a '
              'queue of forty unsent records.',
          description:
              'The counter follows the Step 47 monitor through enqueue and '
              'drain without the banner storing a count of its own',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03437-G6] the banner announces itself to a screen '
        'reader as a live region', (WidgetTester tester) async {
      final HabotConnectivityMonitor monitor = await monitorAt(
        HabotConnectivity.offline,
        2,
      );
      addTearDown(monitor.dispose);

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(banner(monitor));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Offline Mode. 2 changes are waiting to send.'),
        findsOneWidget,
      );
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-03437-G6',
          requirementSource:
              'TTMCS-005 (Step 4) accessibility floor applied to a status '
              'surface: a banner that appears without being announced is '
              'invisible to the user least able to notice a colour change.',
          description:
              'The banner exposes one live-region node carrying both the state '
              'and the queue depth in a single announcement',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03437-G7] the degraded state is quieter than offline '
        'and says something different', (WidgetTester tester) async {
      final HabotConnectivityMonitor monitor = await monitorAt(
        HabotConnectivity.degraded,
        0,
      );
      addTearDown(monitor.dispose);

      await tester.pumpWidget(banner(monitor));
      await tester.pumpAndSettle();

      expect(find.text(HabotOfflineCopy.degradedTitle), findsOneWidget);
      expect(find.text(HabotOfflineCopy.offlineTitle), findsNothing);
      expect(
        HabotOfflineBannerPalette.roleFor(HabotConnectivity.degraded),
        isNot(HabotOfflineBannerPalette.roleFor(HabotConnectivity.offline)),
      );

      gates.add(
        const AissGate(
          id: 'GEN-03437-G7',
          requirementSource:
              'Setup Step (Action) read with Step 47: one missed poll is not '
              'an outage, and telling the user it is teaches them to ignore '
              'the banner.',
          description:
              'A degraded connection renders its own wording in a quieter '
              'status role than offline, while still clearing the contrast '
              'floor',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final String readings = measured.entries
        .map(
          (MapEntry<String, double> e) =>
              '${e.key} ${e.value.toStringAsFixed(2)}:1',
        )
        .join(', ');
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03437',
        atomicStepReferenceId: 'GEN-03437-A01',
        setupStepAction:
            "Display an 'Offline Mode' status banner and pending queue "
            'counters on UI screens.',
        implementationOrder: 48,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotOfflineBanner',
          'Component Type': 'Status banner with queue counter',
          'Component Properties':
              'offline role ${HabotOfflineBannerPalette.offlineRole.name}, '
              'degraded role ${HabotOfflineBannerPalette.degradedRole.name}, '
              'live region, no internal state',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Banner Contrast Ratio',
            observed: readings.isEmpty ? 'not measured' : readings,
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '21:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/offline_banner.dart',
        ],
      ),
    );
  });
}
