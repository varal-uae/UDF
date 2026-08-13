/// AISS GATE -- Step 25 of 35
/// Global Reference ID:       GEN-01363
/// Atomic Steps Reference ID: GEN-01363-A01
/// Setup Step (Action):       "Bind the client UI error boundaries to trigger
///                             M3 error Snackbars upon caught exceptions."
/// Metric: Crash-Free Session Rate -- Floor 0.99, Optimal 0.999, Ceiling 1.0.
///
/// ON THE METRIC: a crash-free session rate is a production reading; no test
/// suite can produce one. What the suite CAN establish is the mechanism behind
/// it -- that a caught exception reaches the user as a plain-language,
/// scrubbed snackbar instead of an unhandled error. That is what the gates
/// below assert, and the measurement records exactly that distinction rather
/// than reporting a number this batch did not measure.
///
/// Deferral policy note: no gate here is deferred, because this step's
/// Completion Measure is the GEN-* boilerplate rather than a field number. The
/// project defers gates against unmeasurable COMPLETION MEASURES (as
/// TTMAC-014 did), not against aspirational metric names.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/error_snackbar.dart';
import 'package:udf_setup/design_system/resilience/error_rollback_boundary.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

/// The kind of thing a real boundary catches.
const String _rawTrace =
    'HttpException: 500 Internal Server Error at '
    'https://api.habot.internal/v2/batches?token=abc123def456ghi789 '
    '(10.4.2.117:8443) in package:habot_server/handlers/batch.dart '
    '#0 BatchHandler.release (/srv/habot/lib/handlers/batch.dart:88) '
    'SELECT * FROM batches WHERE id = 7';

class _ServerFailure implements Exception {
  const _ServerFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-01363-A01 :: error boundary bound to M3 snackbars', () {
    gate(
      'GEN-01363-G1',
      'Setup Step (Action): "Bind the client UI error boundaries to trigger M3 '
          'error Snackbars UPON CAUGHT EXCEPTIONS."',
      'A caught exception is classified into a template before it can be '
          'shown, and the message the user sees is the wording of the '
          'template, never the wording of the exception',
      () {
        final HandledFailure failure = HabotFailureClassifier.handle(
          const _ServerFailure(_rawTrace),
        );
        final String message = HabotErrorSnackbar.messageFor(failure);
        return failure.category == HabotErrorCategory.serverFailure &&
            message.startsWith(failure.template.title) &&
            message.contains(failure.template.body) &&
            !message.contains('HttpException');
      },
    );

    gate(
      'GEN-01363-G2',
      'REF-197 Poka-Yoke, inherited: "Catch-all code structures strip out '
          'server-specific error language automatically before messages reach '
          'the UI layer."',
      'The snackbar message survives the presentability check: nothing the '
          'scrubber redacts and no jargon from the banned list',
      () {
        for (final HabotErrorCategory category in HabotErrorCategory.values) {
          final HandledFailure failure = HandledFailure(
            category: category,
            template: HabotErrorTemplates.of(category),
            scrubbedDiagnostic: '',
            rolledBack: false,
          );
          if (!HabotErrorSnackbar.isPresentable(
            HabotErrorSnackbar.messageFor(failure),
          )) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'GEN-01363-G3',
      'Setup Step (Action) -- an error snackbar with no way forward is an '
          'announcement, not a recovery path. REF-197 already decided which '
          'categories can be retried.',
      'The retry action appears for every retryable category and for none of '
          'the others, and the duration lengthens when a decision is required',
      () {
        for (final HabotErrorCategory category in HabotErrorCategory.values) {
          final HandledFailure failure = HandledFailure(
            category: category,
            template: HabotErrorTemplates.of(category),
            scrubbedDiagnostic: '',
            rolledBack: false,
          );
          final Duration duration = HabotErrorSnackbar.durationFor(failure);
          final bool retryable = failure.template.retryable;
          if (retryable && duration != HabotMotion.snackbarDisplayWithAction) {
            return false;
          }
          if (!retryable && duration != HabotMotion.snackbarDisplay) {
            return false;
          }
        }
        return HabotMotion.snackbarDisplayWithAction >
            HabotMotion.snackbarDisplay;
      },
    );

    gate(
      'GEN-01363-G4',
      'Setup Step (Action): "...M3 error Snackbars." MD3 caps a snackbar at two '
          'lines; longer content belongs in a panel.',
      'The line cap is a token and the error colour pair clears the WCAG text '
          'floor in both schemes, so the snackbar inherits the audited contrast '
          'rather than asserting a new one',
      () {
        final double light = Contrast.ratio(
          HabotColors.light.onErrorContainer,
          HabotColors.light.errorContainer,
        );
        final double dark = Contrast.ratio(
          HabotColors.dark.onErrorContainer,
          HabotColors.dark.errorContainer,
        );
        return HabotFeedback.snackbarMaxLines == 2 &&
            light >= WcagThresholds.textFloor &&
            dark >= WcagThresholds.textFloor;
      },
    );
  });

  group('GEN-01363-A01 :: rendered snackbar', () {
    testWidgets('[GEN-01363-G5] a boundary that catches a 500 with a full '
        'stack trace surfaces a plain-language snackbar with a retry action '
        'and no trace anywhere on screen', (WidgetTester tester) async {
      final GlobalKey<SnackbarErrorBoundaryState> key =
          GlobalKey<SnackbarErrorBoundaryState>();
      int retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SnackbarErrorBoundary(
              key: key,
              onRetry: () => retries++,
              child: const Center(child: Text('batch list')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.reportFailure(const _ServerFailure(_rawTrace));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Something went wrong on our side'),
        findsOneWidget,
      );
      expect(find.textContaining('SELECT'), findsNothing);
      expect(find.textContaining('10.4.2.117'), findsNothing);
      expect(find.textContaining('package:'), findsNothing);
      expect(find.textContaining('#0'), findsNothing);
      expect(find.textContaining('api.habot.internal'), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(retries, 1);
      expect(
        key.currentState!.surfaced.single.category,
        HabotErrorCategory.serverFailure,
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-01363-G5',
          requirementSource:
              'Setup Step (Action): "Bind the client UI error boundaries to '
              'trigger M3 error Snackbars upon caught exceptions."',
          description:
              'A caught 500 with URL, IP, package path, stack frame and SQL '
              'reaches the user as the template sentence with a working retry, '
              'and none of those fragments appear on screen',
          passed: true,
        ),
      );
    });

    testWidgets(
      '[GEN-01363-G6] the snackbar paints the audited error-container '
      'pair and offers no retry where retrying cannot help',
      (WidgetTester tester) async {
        final GlobalKey<SnackbarErrorBoundaryState> key =
            GlobalKey<SnackbarErrorBoundaryState>();
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: SnackbarErrorBoundary(
                key: key,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        key.currentState!.reportFailure(const FormatException('bad field'));
        await tester.pumpAndSettle();

        final SnackBar bar = tester.widget<SnackBar>(find.byType(SnackBar));
        final BuildContext context = tester.element(find.byType(SnackBar));
        final ColorScheme scheme = Theme.of(context).colorScheme;

        expect(bar.backgroundColor, scheme.errorContainer);
        expect(bar.behavior, SnackBarBehavior.floating);
        expect(bar.duration, HabotMotion.snackbarDisplay);
        expect(
          bar.action,
          isNull,
          reason: 'A validation failure is not fixed by trying again',
        );

        gates.add(
          const AissGate(
            id: 'GEN-01363-G6',
            requirementSource:
                'Setup Step (Action): "...M3 error Snackbars." + REF-197 Mobile-'
                'First UI Decision: "Include an explicit, easy-to-tap retry '
                'button within error notification areas" -- where retrying is a '
                'real option.',
            description:
                'The rendered snackbar uses the audited error-container colour '
                'and omits the retry control for a validation failure',
            passed: true,
          ),
        );
      },
    );

    testWidgets('[GEN-01363-G7] a second failure replaces the first rather than '
        'queueing behind it', (WidgetTester tester) async {
      final GlobalKey<SnackbarErrorBoundaryState> key =
          GlobalKey<SnackbarErrorBoundaryState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SnackbarErrorBoundary(
              key: key,
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!
        ..reportFailure(
          const _ServerFailure('SocketException: Failed host lookup'),
        )
        ..reportFailure(const _ServerFailure('HTTP 500 server error'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No connection'), findsNothing);
      expect(key.currentState!.surfaced.length, 2);

      gates.add(
        const AissGate(
          id: 'GEN-01363-G7',
          requirementSource:
              'Setup Step (Action) -- "upon caught exceptions", plural. A burst '
              'of failures must not become a queue of stale snackbars the user '
              'has to dismiss one at a time.',
          description:
              'The most recent failure is the one on screen, and both are still '
              'recorded for diagnostics',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01363',
        atomicStepReferenceId: 'GEN-01363-A01',
        setupStepAction:
            'Bind the client UI error boundaries to trigger M3 error Snackbars '
            'upon caught exceptions.',
        implementationOrder: 25,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotErrorSnackbar / SnackbarErrorBoundary',
          'Component Type': 'MD3 snackbar bound to the REF-197 error boundary',
          'State Definitions':
              '${HabotErrorCategory.values.length} failure categories, '
              '${HabotErrorTemplates.all.where((HabotErrorTemplate t) => t.retryable).length} retryable',
          'Completion Status': 'Derived from gate outcomes',
          'Metric note':
              'Crash-Free Session Rate is a production reading. The suite '
              'verifies the mechanism, not the field value.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Crash-Free Session Rate',
            observed:
                'Not measurable in-suite (production KPI). Verified instead: '
                'every caught exception resolves to a scrubbed, jargon-free '
                'template with a correct retry decision, and no raw trace '
                'reaches the screen.',
            floor: '0.99',
            optimal: '0.999',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/error_snackbar.dart',
          'lib/design_system/resilience/error_rollback_boundary.dart',
        ],
      ),
    );
  });
}
