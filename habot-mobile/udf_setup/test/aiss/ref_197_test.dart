/// AISS GATE -- Step 19 of 20
/// Global Reference ID:      REF-197
/// Atomic Steps Reference ID: REF-197-A01
/// Setup Step (Action):      "Developing the Safe Error-Handling UI Rollback
///                            Handler"
///
/// Completion Measures: "Confirm through testing that simulated server crashes
/// result in clean, friendly alerts rather than system code traces."
/// Metric: Template Definition -- Floor / Optimal / Ceiling all "Complete".
/// There is no partial credit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/resilience/error_rollback_boundary.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/resilience/log_scrubber.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

/// A realistic server trace, of the kind that must never reach a user.
const String _rawServerTrace =
    'HttpException: 500 Internal Server Error at '
    'https://api.habot.internal/v2/transactions?token=abc123def456ghi789 '
    '(10.4.2.117:8443) in package:habot_server/handlers/transaction.dart '
    '#0 TransactionHandler.commit (/srv/habot/lib/handlers/transaction.dart:214) '
    'SELECT * FROM ledger WHERE account_id = 99 '
    'contact ops@habot.internal';

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

  group('REF-197-A01 :: safe error-handling rollback handler', () {
    gate(
      'REF-197-G1',
      'Setup Step Description AND Decision Before Setup Step (the sheet lists '
          'both): "Define standardized user-facing error text templates for '
          'common system validation rejections." + Metric: Template Definition '
          '= Complete (no partial credit).',
      'Every failure category has a template, each with a title, a body and a '
          'retry label -- an unmapped failure is impossible',
      () {
        if (!HabotErrorTemplates.isComplete) {
          return false;
        }
        for (final HabotErrorCategory category in HabotErrorCategory.values) {
          final HabotErrorTemplate t = HabotErrorTemplates.of(category);
          if (t.title.isEmpty || t.body.isEmpty || t.retryLabel.isEmpty) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'REF-197-G2',
      'Mobile-First UX Decision: "Ensure error text displays do not use '
          'technical code terms, keeping descriptions simple and clear."',
      'No template contains any word from the forbidden-jargon list',
      () {
        for (final HabotErrorTemplate t in HabotErrorTemplates.all) {
          final String text = '${t.title} ${t.body}'.toLowerCase();
          for (final String jargon in HabotErrorTemplates.forbiddenJargon) {
            if (text.contains(jargon)) {
              return false;
            }
          }
        }
        return true;
      },
    );

    gate(
      'REF-197-G3',
      '4 Substeps #2: "Configure error log scrubbers to remove sensitive '
          'backend code path variables from user-facing logs." + Poka-Yoke: '
          '"Catch-all code structures strip out server-specific error language '
          'automatically before messages reach the UI layer."',
      'A realistic server trace is scrubbed of paths, URLs, IPs, tokens, stack '
          'frames, SQL and emails -- and the scrubber reports itself clean after',
      () {
        final String scrubbed = HabotLogScrubber.scrub(_rawServerTrace);
        const List<String> mustNotSurvive = <String>[
          'api.habot.internal',
          'abc123def456ghi789',
          '10.4.2.117',
          'package:habot_server',
          '/srv/habot/lib/handlers/transaction.dart',
          'SELECT * FROM ledger',
          'ops@habot.internal',
        ];
        for (final String secret in mustNotSurvive) {
          if (scrubbed.contains(secret)) {
            return false;
          }
        }
        // The scrubber must be idempotent -- a second pass finds nothing new.
        if (!HabotLogScrubber.isClean(scrubbed)) {
          return false;
        }
        // And it must report which rules fired, without echoing the values.
        final List<String> fired = HabotLogScrubber.firedRules(_rawServerTrace);
        return fired.contains('url') &&
            fired.contains('ip') &&
            fired.contains('email') &&
            fired.contains('sql');
      },
    );

    gate(
      'REF-197-G4',
      '4 Substeps #3: "Wire up UI state controllers to fall back to generic, '
          'helpful confirmation notes when processing anomalies occur."',
      'Classification maps real failure shapes to the right template, and an '
          'unrecognised error still lands on a human sentence',
      () {
        HabotErrorCategory c(Object e) => HabotFailureClassifier.classify(e);
        return c(
                  const SocketLikeError('SocketException: Failed host lookup'),
                ) ==
                HabotErrorCategory.offline &&
            c(const TimeoutException('after 30s')) ==
                HabotErrorCategory.timeout &&
            c(const SocketLikeError('HTTP 401 Unauthorized')) ==
                HabotErrorCategory.unauthenticated &&
            c(const SocketLikeError('HTTP 403 Forbidden')) ==
                HabotErrorCategory.forbidden &&
            c(const SocketLikeError('HTTP 404 not found')) ==
                HabotErrorCategory.notFound &&
            c(const SocketLikeError('409 conflict: version mismatch')) ==
                HabotErrorCategory.conflict &&
            c(const SocketLikeError('HTTP 500 server error')) ==
                HabotErrorCategory.serverFailure &&
            c(const FormatException('bad')) == HabotErrorCategory.validation &&
            // Anything unrecognised still resolves to a template.
            c(const SocketLikeError('quantum flux')) ==
                HabotErrorCategory.unknown &&
            HabotErrorTemplates.of(HabotErrorCategory.unknown).body.isNotEmpty;
      },
    );

    gate(
      'REF-197-G5',
      'Mobile-First UI Decision: "Include an explicit, easy-to-tap retry button '
          'within error notification areas."',
      'Every retryable category offers a retry label, and the categories where '
          'retrying cannot help do not pretend it will',
      () =>
          HabotErrorTemplates.of(HabotErrorCategory.offline).retryable &&
          HabotErrorTemplates.of(HabotErrorCategory.timeout).retryable &&
          HabotErrorTemplates.of(HabotErrorCategory.serverFailure).retryable &&
          !HabotErrorTemplates.of(HabotErrorCategory.forbidden).retryable &&
          !HabotErrorTemplates.of(HabotErrorCategory.validation).retryable &&
          !HabotErrorTemplates.of(HabotErrorCategory.conflict).retryable,
    );
  });

  group('REF-197-A01 :: completion measure -- simulated server crash', () {
    testWidgets('[REF-197-G6] a simulated crash produces a friendly panel, '
        'never a code trace, and rolls the form back', (
      WidgetTester tester,
    ) async {
      FormBaseline? restored;
      const FormBaseline baseline = <String, String>{
        'amount': '100.00',
        'ref': 'INV-2026-0001',
      };

      final GlobalKey<ErrorRollbackBoundaryState> key =
          GlobalKey<ErrorRollbackBoundaryState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: ErrorRollbackBoundary(
              key: key,
              baseline: baseline,
              onRollback: (FormBaseline b) => restored = b,
              child: const Center(child: Text('transaction form')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.reportFailure(const SocketLikeError(_rawServerTrace));
      await tester.pumpAndSettle();

      // Substep 4: the form was rolled back to its verified baseline.
      expect(restored, baseline);

      // The user sees the template, not the trace.
      expect(find.text('Something went wrong on our side'), findsOneWidget);
      expect(find.textContaining('SELECT'), findsNothing);
      expect(find.textContaining('10.4.2.117'), findsNothing);
      expect(find.textContaining('package:'), findsNothing);
      expect(find.textContaining('#0'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
      expect(
        find.text('Your previous entries have been restored.'),
        findsOneWidget,
      );

      // The diagnostic that WAS kept is scrubbed.
      final HandledFailure handled = key.currentState!.handled.single;
      expect(handled.rolledBack, isTrue);
      expect(handled.scrubbedDiagnostic, isNot(contains('10.4.2.117')));
      expect(handled.scrubbedDiagnostic, isNot(contains('ops@habot.internal')));
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'REF-197-G6',
          requirementSource:
              'Completion Measures: "Confirm through testing that simulated '
              'server crashes result in clean, friendly alerts rather than '
              'system code traces." + 4 Substeps #4: "reset input sections back '
              'to verified local baseline states upon transaction failure."',
          description:
              'A 500 with a full stack trace surfaces as the plain-language '
              'template with a retry control, the form is restored to baseline, '
              'and no path, IP, SQL or frame appears anywhere on screen',
          passed: true,
        ),
      );
    });

    testWidgets('[REF-197-G7] the boundary wraps an arbitrary data-aware '
        'component, not just forms', (WidgetTester tester) async {
      final GlobalKey<ErrorRollbackBoundaryState> key =
          GlobalKey<ErrorRollbackBoundaryState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: ErrorRollbackBoundary(
              key: key,
              child: ListView(children: const <Widget>[Text('a'), Text('b')]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No baseline supplied: it must still classify and present, just without
      // claiming a rollback happened.
      key.currentState!.reportFailure(
        const SocketLikeError('SocketException: Failed host lookup'),
      );
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
      expect(
        find.text('Your previous entries have been restored.'),
        findsNothing,
        reason: 'Never claim a rollback that did not happen',
      );
      expect(key.currentState!.handled.single.rolledBack, isFalse);

      gates.add(
        const AissGate(
          id: 'REF-197-G7',
          requirementSource:
              'Atomic Reusability: "Ensure the error handling boundary can wrap '
              'any data-aware component layout."',
          description:
              'The boundary wraps a plain ListView and, with no baseline, '
              'presents the template without claiming a rollback occurred',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'REF-197',
        atomicStepReferenceId: 'REF-197-A01',
        setupStepAction:
            'Developing the Safe Error-Handling UI Rollback Handler',
        implementationOrder: 19,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Template Name': 'Habot user-facing error templates',
          'Template Version': HabotErrorTemplates.version,
          'Template Type': 'Failure-category -> plain-language message map',
          'Template Configuration':
              '${HabotErrorCategory.values.length} categories, '
              '${HabotErrorTemplates.all.where((HabotErrorTemplate t) => t.retryable).length} retryable',
          'Definition Name': 'HabotLogScrubber rule set',
          'Definition Parameters':
              '${HabotLogScrubber.rules.length} redaction rules '
              '(path, uri, url, ip, email, frame, hex, secret, sql)',
          'Definition Type': 'Regex redaction pipeline',
          'Validation Status': 'Validated -- idempotent on its own output',
          'Definition ID': 'REF-197-A01/log-scrubber',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Template Definition',
            observed:
                'Complete -- 9 of 9 failure categories have a jargon-free '
                'template with a retry decision',
            floor: 'Complete',
            optimal: 'Complete',
            ceiling: 'Complete',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/error_templates.dart',
          'lib/design_system/resilience/log_scrubber.dart',
          'lib/design_system/resilience/error_rollback_boundary.dart',
        ],
      ),
    );
  });
}

/// Stand-in for a server/network error, so the classifier can be exercised
/// without a real socket.
class SocketLikeError implements Exception {
  const SocketLikeError(this.message);
  final String message;
  @override
  String toString() => message;
}
