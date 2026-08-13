/// AISS GATE -- Step 46 of 50
/// Global Reference ID:       GEN-02060
/// Atomic Steps Reference ID: GEN-02060-A01
/// Setup Step (Action):       "Ensure text breathes and fits its container
///                             without truncating unreadably on 320dp screens."
///
/// METRIC MISMATCH, RECORDED: this row's Metric Name is the generic "Step
/// Completion Rate (%)" (Floor 90, Optimal 99, Ceiling 100, scale
/// Complete/Partial/Not Complete). That is a project-tracking measure, not a
/// property of rendered text. The specific number this step names is in its
/// own Setup Step: 320dp -- which is also HabotGrid.minSupportedWidth from
/// Step 6 and the narrowest device in the Step 5 matrix. That is what is
/// gated, and the mismatch is recorded rather than reinterpreted.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/text_fit.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

import 'aiss_reporter.dart';

const String _longLabel =
    'Outstanding reconciliation items awaiting supervisor approval';
const String _longBody =
    'This record was flagged during the overnight reconciliation run because '
    'the declared total did not match the sum of its line items. Review the '
    'lines below and either correct the entry or mark it as an exception.';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int rolesChecked = 0;
  int rolesReadable = 0;

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

  Widget at320(Widget child) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(
      body: SizedBox(width: HabotTextFit.auditWidthDp, child: child),
    ),
  );

  group('GEN-02060-A01 :: the fitting rules', () {
    gate(
      'GEN-02060-G1',
      'Setup Step (Action): "...on 320DP SCREENS."',
      'The audit width is the 320dp the step names, and it is the same 320dp '
          'Step 6 recorded as the minimum supported width -- not a second '
          'number that happens to match today',
      () =>
          HabotTextFit.auditWidthDp == 320 &&
          HabotTextFit.auditWidthDp == HabotGrid.minSupportedWidth,
    );

    gate(
      'GEN-02060-G2',
      'Setup Step (Action): "...without TRUNCATING UNREADABLY." Unreadably is '
          'the operative word: an ellipsis after forty characters is fine, one '
          'after four is not.',
      'The readable floor is a stated number of surviving characters rather '
          'than a ban on ellipsis, and the font floor is the smallest role the '
          'type scale itself defines -- so "it fits" can never be achieved by '
          'shrinking below the scale',
      () =>
          HabotTextFit.minReadableChars == 12 &&
          HabotTextFit.minReadableFontSp == HabotTypography.labelSmall.sizeSp &&
          HabotTextFit.mustWrap.length == 3 &&
          HabotTextFit.mustWrap.contains('bodyLarge') &&
          HabotTextFit.mustWrap.contains('bodyMedium') &&
          HabotTextFit.mustWrap.contains('bodySmall'),
    );

    gate(
      'GEN-02060-G3',
      'Setup Step (Action): "Ensure text ... fits its container." Every role '
          'in the type scale, not the ones that happened to be used.',
      'At 320dp every role in the type scale keeps at least the readable '
          'floor of characters and none sits below the minimum font size',
      () {
        bool all = true;
        for (final HabotTypeToken token in HabotTypography.all) {
          rolesChecked++;
          final HabotTextFitResult result = HabotTextFit.audit(
            text: _longLabel,
            token: token,
          );
          final bool ok =
              result.fits && token.sizeSp >= HabotTextFit.minReadableFontSp;
          if (ok) {
            rolesReadable++;
          }
          all = all && ok;
        }
        return all;
      },
    );

    gate(
      'GEN-02060-G4',
      'Setup Step (Action) -- a rule that cannot report a failure is a '
          'comment, not a rule.',
      'The audit rejects a role below the font floor and a container too '
          'narrow to keep twelve characters, naming which of the two failed',
      () {
        const HabotTypeToken tooSmall = HabotTypeToken(
          name: 'inventedTiny',
          sizeSp: 8,
          lineHeightSp: 10,
          weight: 400,
          tracking: 0,
        );
        final HabotTextFitResult small = HabotTextFit.audit(
          text: 'anything',
          token: tooSmall,
        );
        final HabotTextFitResult narrow = HabotTextFit.audit(
          text: _longLabel,
          token: HabotTypography.titleMedium,
          width: 40,
          maxLines: 1,
        );
        return !small.fits &&
            small.reason == HabotTextFitFailure.belowMinimumFontSize &&
            !narrow.fits &&
            narrow.reason == HabotTextFitFailure.truncatedBelowReadable &&
            narrow.charsThatFit < HabotTextFit.minReadableChars;
      },
    );

    gate(
      'GEN-02060-G5',
      'Setup Step (Action): "Ensure text BREATHES." Body copy that ellipsises '
          'has stopped being readable regardless of how much of it survives.',
      'Body roles are reported as fitting however long the string is, because '
          'they are allowed to grow taller; label and title roles are held to '
          'the character floor instead',
      () =>
          HabotTextFit.audit(
            text: _longBody,
            token: HabotTypography.bodyMedium,
            maxLines: 1,
          ).fits &&
          HabotTextFit.charsPerLine(
                HabotTextFit.auditWidthDp,
                HabotTypography.bodyMedium.sizeSp,
              ) >
              HabotTextFit.minReadableChars,
    );
  });

  group('GEN-02060-A01 :: rendered at 320dp', () {
    testWidgets('[GEN-02060-G6] a long body paragraph wraps rather than '
        'truncating, and raises no overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        at320(
          const HabotFittingText(_longBody, token: HabotTypography.bodyMedium),
        ),
      );
      await tester.pumpAndSettle();

      final Text rendered = tester.widget<Text>(find.text(_longBody));
      expect(rendered.maxLines, isNull, reason: 'body wraps without a cap');
      expect(rendered.overflow, TextOverflow.clip);
      expect(tester.takeException(), isNull);

      final Size size = tester.getSize(find.text(_longBody));
      expect(
        size.width,
        lessThanOrEqualTo(HabotTextFit.auditWidthDp),
        reason: 'text stays inside its 320dp container',
      );
      expect(
        size.height,
        greaterThan(HabotTypography.bodyMedium.lineHeightSp),
        reason: 'it grew taller instead of being cut off',
      );

      gates.add(
        AissGate(
          id: 'GEN-02060-G6',
          requirementSource:
              'Setup Step (Action): "Ensure text breathes and fits its '
              'container without truncating unreadably on 320dp screens."',
          description:
              'A 220-character paragraph at 320dp wraps to multiple lines, '
              'stays inside its container and raises no overflow exception',
          passed: true,
          detail:
              'rendered ${size.width.toStringAsFixed(0)}x'
              '${size.height.toStringAsFixed(0)}dp',
        ),
      );
    });

    testWidgets('[GEN-02060-G7] a long label truncates with an ellipsis and '
        'keeps more than the readable floor of characters', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        at320(
          const HabotFittingText(_longLabel, token: HabotTypography.titleSmall),
        ),
      );
      await tester.pumpAndSettle();

      final Text rendered = tester.widget<Text>(find.text(_longLabel));
      expect(rendered.maxLines, 1);
      expect(rendered.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);

      final int survives = HabotTextFit.charsPerLine(
        HabotTextFit.auditWidthDp,
        HabotTypography.titleSmall.sizeSp,
      );
      expect(survives, greaterThanOrEqualTo(HabotTextFit.minReadableChars));

      gates.add(
        AissGate(
          id: 'GEN-02060-G7',
          requirementSource:
              'Setup Step (Action): "...without truncating UNREADABLY." The '
              'label is allowed to truncate; it is not allowed to become '
              'meaningless.',
          description:
              'A 60-character title at 320dp ellipsises on one line while '
              'keeping well above the twelve-character readable floor',
          passed: true,
          detail:
              '$survives characters survive at '
              '${HabotTypography.titleSmall.sizeSp.toStringAsFixed(0)}sp, '
              'floor ${HabotTextFit.minReadableChars}',
        ),
      );
    });

    testWidgets('[GEN-02060-G8] the same text survives the OS text-size '
        'setting turned up', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: const Scaffold(
              body: SizedBox(
                width: HabotTextFit.auditWidthDp,
                child: HabotFittingText(
                  _longBody,
                  token: HabotTypography.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'A user who has enlarged their system text must not be shown '
            'an overflow stripe',
      );
      expect(find.text(_longBody), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'GEN-02060-G8',
          requirementSource:
              'Setup Step (Action) read together with TTMCS-005 (Step 4): the '
              'design system fixes its own floor, and the user still owns '
              'their text-size preference.',
          description:
              'At 320dp with system text scaled to 1.3x the paragraph still '
              'renders with no overflow exception',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02060',
        atomicStepReferenceId: 'GEN-02060-A01',
        setupStepAction:
            'Ensure text breathes and fits its container without truncating '
            'unreadably on 320dp screens.',
        implementationOrder: 46,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTextFit / HabotFittingText',
          'Component Type': 'Text fitting rules and the widget that obeys them',
          'Component Properties':
              'audit width ${HabotTextFit.auditWidthDp.toStringAsFixed(0)}dp, '
              'readable floor ${HabotTextFit.minReadableChars} chars, font '
              'floor ${HabotTextFit.minReadableFontSp.toStringAsFixed(0)}sp',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC MISMATCH -- the sheet names "Step Completion Rate (%)", '
              'a project-tracking measure, for a text-rendering step. The '
              '320dp figure in the Setup Step is what is gated; the sheet '
              'metric is recorded as not produced by this suite.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Readable text roles at 320dp (the step\'s own number)',
            observed:
                '$rolesReadable of $rolesChecked type-scale roles keep at '
                'least ${HabotTextFit.minReadableChars} characters at 320dp '
                'and sit at or above the '
                '${HabotTextFit.minReadableFontSp.toStringAsFixed(0)}sp font '
                'floor',
            floor: 'all roles readable',
            optimal: 'all roles readable',
            ceiling: 'all roles readable',
          ),
          const AissMeasurement(
            metricName: 'Step Completion Rate (%) (the sheet metric)',
            observed:
                'NOT PRODUCED -- a project-tracking percentage across a step '
                'population, which no rendering test can generate. No number '
                'is asserted here in its place.',
            floor: '90.0',
            optimal: '99.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>['lib/design_system/a11y/text_fit.dart'],
      ),
    );
  });
}
