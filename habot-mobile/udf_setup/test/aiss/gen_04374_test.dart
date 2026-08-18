/// AISS GATE -- Step 69 of 80
/// Global Reference ID:       GEN-04374
/// Atomic Steps Reference ID: GEN-04374-A01
/// Setup Step (Action):       "Build an atomic InAppBanner notification bar
///                             component."
/// Metric: Push Notification Delivery Rate -- Floor 0.95, Optimal 0.99,
///         Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string.
///
/// METRIC NOTE, RECORDED: a banner cannot influence whether the push service
/// delivered anything. What it owns is the LAST LEG -- once a message reaches
/// the app, does it reach the screen? That is measured; the sheet metric is
/// recorded as not produced.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/notifications/in_app_banner.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

HabotBannerMessage _msg(
  String id,
  HabotNotificationKind kind, {
  String title = 'Product news',
  String body = 'A new dashboard filter is available.',
  VoidCallback? onAction,
}) => HabotBannerMessage(
  id: id,
  kind: kind,
  title: title,
  body: body,
  actionLabel: onAction == null ? null : 'Open',
  onAction: onAction,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double reachRate = 0;

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

  Widget host(HabotBannerController controller) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(body: HabotInAppBanner(controller: controller)),
  );

  group('GEN-04374-A01 :: the banner policy', () {
    gate(
      'GEN-04374-G1',
      'Setup Step (Action): "Build an ATOMIC InAppBanner notification bar '
          'component." Atomic means one bar, not a stack of them.',
      'One banner shows at a time; a second is queued rather than stacked, and '
          'a higher-priority arrival displaces the current one instead of '
          'waiting behind it -- the displaced message is requeued, not lost',
      () {
        final HabotBannerController c = HabotBannerController();
        c.present(_msg('info', HabotNotificationKind.informational));
        c.present(_msg('crit', HabotNotificationKind.critical));
        final bool displaced = c.current?.id == 'crit' && c.pendingCount == 1;
        c.dismiss('crit');
        final bool restored = c.current?.id == 'info';
        reachRate = c.screenDeliveryRate;
        return displaced &&
            restored &&
            c.offeredCount == 2 &&
            c.shownCount == 2 &&
            reachRate == 1.0;
      },
    );

    gate(
      'GEN-04374-G2',
      'Setup Step (Action) read with GEN-03437 (Step 48): the shell already '
          'has a banner slot, and connectivity was there first.',
      'Connectivity outranks every notification kind, so an offline banner is '
          'never pushed aside by news the user cannot act on',
      () {
        for (final HabotNotificationKind kind
            in HabotNotificationKind.values) {
          if (HabotBannerPolicy.connectivityPrecedence >=
              HabotBannerPolicy.precedenceOf(kind)) {
            return false;
          }
        }
        return HabotBannerPolicy.precedenceOf(
                  HabotNotificationKind.critical,
                ) <
                HabotBannerPolicy.precedenceOf(
                  HabotNotificationKind.informational,
                ) &&
            HabotBannerPolicy.winner(
                  HabotNotificationKind.informational,
                  HabotNotificationKind.critical,
                ) ==
                HabotNotificationKind.critical;
      },
    );

    gate(
      'GEN-04374-G3',
      'A banner demanding a decision that vanishes while the user is reading '
          'it is worse than one that never appeared.',
      'Informational and failure banners auto-dismiss on the existing snackbar '
          'ladder; dispatch, approval and critical ones stay until acted on',
      () =>
          HabotBannerPolicy.autoDismisses(
            HabotNotificationKind.informational,
          ) &&
          HabotBannerPolicy.autoDismisses(HabotNotificationKind.failure) &&
          !HabotBannerPolicy.autoDismisses(HabotNotificationKind.approval) &&
          !HabotBannerPolicy.autoDismisses(HabotNotificationKind.dispatch) &&
          !HabotBannerPolicy.autoDismisses(HabotNotificationKind.critical),
    );

    gate(
      'GEN-04374-G4',
      'WCAG 2.1 SC 1.4.1 through GEN-01275 (Step 28): a banner whose meaning '
          'is carried only by its colour has no meaning in greyscale.',
      'Every kind maps to a status role from the Step 28 vocabulary, which '
          'brings an icon and a label with it rather than a colour alone',
      () {
        final Set<HabotStatusRole> roles = HabotNotificationKind.values
            .map(HabotBannerPolicy.roleFor)
            .toSet();
        return roles.length >= 3 &&
            HabotBannerPolicy.roleFor(HabotNotificationKind.critical) ==
                HabotStatusRole.error &&
            HabotBannerPolicy.roleFor(HabotNotificationKind.approval) ==
                HabotStatusRole.warning;
      },
    );
  });

  group('GEN-04374-A01 :: rendered', () {
    testWidgets('[GEN-04374-G5] the banner renders its title, body and one '
        'action, announces itself, and dismisses', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotBannerController controller = HabotBannerController();
      addTearDown(controller.dispose);
      int actioned = 0;

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(controller));
      expect(find.byKey(HabotInAppBanner.bannerKey), findsNothing);

      final HabotBannerMessage message = _msg(
        'n1',
        HabotNotificationKind.approval,
        onAction: () => actioned++,
      );
      controller.present(message);
      await tester.pump();

      expect(find.byKey(HabotInAppBanner.bannerKey), findsOneWidget);
      expect(find.text('Product news'), findsOneWidget);
      expect(find.bySemanticsLabel(message.semanticsLabel), findsOneWidget);

      await tester.tap(find.byKey(HabotInAppBanner.actionKey));
      await tester.pump();
      expect(actioned, 1);

      await tester.tap(find.byKey(HabotInAppBanner.dismissKey));
      await tester.pump();
      expect(find.byKey(HabotInAppBanner.bannerKey), findsNothing);
      expect(tester.takeException(), isNull);
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-04374-G5',
          requirementSource:
              'Setup Step (Action): "Build an atomic InAppBanner notification '
              'bar component." + TTMCS-005 accessibility floor.',
          description:
              'The banner appears only when a message is present, renders '
              'title, body and a single action, announces itself as a live '
              'region, and dismisses on demand',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-04374-G6] an approval banner does not disappear on its '
        'own, and the dismiss control is a real touch target', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotBannerController controller = HabotBannerController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(controller));
      controller.present(_msg('a', HabotNotificationKind.approval));
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));

      expect(
        find.byKey(HabotInAppBanner.bannerKey),
        findsOneWidget,
        reason: 'a decision-demanding banner waits for the decision',
      );
      final Size dismiss =
          tester.getSize(find.byKey(HabotInAppBanner.dismissKey));
      expect(dismiss.height, greaterThanOrEqualTo(HabotSpacing.xxxl - 1));
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-04374-G6',
          requirementSource:
              'TTMAC-011 (Step 10): 48dp minimum touch target, applied to the '
              'control inside a banner like any other.',
          description:
              'An approval banner is still on screen thirty seconds later, and '
              'its dismiss control clears the shared touch-target floor',
          passed: true,
          detail:
              'dismiss control ${dismiss.width.toStringAsFixed(0)}x'
              '${dismiss.height.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04374',
        atomicStepReferenceId: 'GEN-04374-A01',
        setupStepAction:
            'Build an atomic InAppBanner notification bar component.',
        implementationOrder: 69,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotInAppBanner / HabotBannerController',
          'Component Properties':
              'one at a time by precedence; connectivity outranks all '
              'notification kinds; informational and failure auto-dismiss',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are identical on '
              'this row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Screen delivery (the last leg, which a banner owns)',
            observed:
                '${(reachRate * 100).toStringAsFixed(0)}% of messages offered '
                'to the banner reached the screen; a displaced message is '
                'requeued rather than dropped',
            floor: 'every offered message reaches the screen or the queue',
            optimal: 'as floor',
            ceiling: 'as floor',
          ),
          const AissMeasurement(
            metricName: 'Push Notification Delivery Rate (the sheet metric)',
            observed:
                'NOT PRODUCED -- a banner cannot influence whether the push '
                'service delivered anything. No number is asserted in its '
                'place.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '0.999',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/in_app_banner.dart',
        ],
      ),
    );
  });
}
