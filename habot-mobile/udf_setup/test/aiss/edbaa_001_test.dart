/// AISS GATE -- Step 72 of 80
/// Global Reference ID:       EDBAA-001
/// Atomic Steps Reference ID: EDBAA-001
/// Setup Step (Action):       "Design the 'Liveness Handshake' Failure Toast"
/// Setup Step Description:    "Access the Group Core Systems Monitoring
///                             library to begin the toast blueprint."
///
/// METRIC MISMATCH, RECORDED: the Metric Name is "TLS Protocol Compliance
/// Rate", with bands "100% of connections on TLS 1.2 or higher" / "TLS 1.3" /
/// "TLS 1.3 with hardened cipher suite". A toast cannot move a TLS posture --
/// that is a property of a transport layer this design system never touches.
/// Reported as NOT PRODUCED. No number is asserted in its place.
///
/// CONTAMINATED ROW, RECORDED: ten columns describe a sign-up screen. Decision
/// Before ("End Document (ED) Schema structural baseline approval"), Why This
/// Matters ("Prevents context abandonment at the absolute earliest gateway of
/// the digital funnel"), UX Translation ("Single-column login card containing
/// text fields with inline placeholder indicators"), Flow Impact ("Smooth
/// transition from the Splash screen"), Dashboard Implication ("real-time
/// tracking of sign-up drops"), What Must Be Standardized ("mark mandatory
/// fields with a red asterisk"), Expected Output ("Mobile low-fidelity sign-up
/// wireframe and authentication data-flow chart"), Completion Measures
/// ("Requirements Defined - Logic Documented = 0 checked inside Project
/// Jira"), Domain Expertise ("UX Research & Identity Management Engineer") and
/// Poka-Yoke (a predecessor_id column on uploaded form models). None are gated.
///
/// WHAT IS COHERENT: the Setup Step itself, the Data Collected fields (Metric
/// Name; Metric Value; Monitoring Status; Alert Threshold; Monitoring
/// Timestamp -- monitoring fields, for a monitoring toast), and the
/// Self-Chasing concept the sheet repeats on nearly every row: an automated
/// liveness handshake that watches a step and rolls it back when it misses.
/// This step is what the operator sees when that handshake misses.
///
/// A CONFLICT INSIDE THE COHERENT PART, RECORDED AND RESOLVED IN FAVOUR OF THE
/// EARLIER GATE. The Data Requirement column asks for "bold monospaced
/// typography formatting rules to the deployment hash string" and "Tapping the
/// alert card copies the system trace identifier directly to the clipboard" --
/// i.e. it wants build hashes and trace ids in front of the user. REF-197
/// (Step 19) established the opposite rule and gated it: a diagnostic is
/// scrubbed and logged, never rendered. That rule wins, because a trace
/// identifier on a user's screen is exactly what the scrubber exists to
/// prevent. The diagnostic is still produced and still carries the fact -- it
/// goes to the log, and G3 proves both halves.
///
/// THE CENTRAL GATE IS THE SAME REUSE PROOF AS STEP 71. A "toast" that is not
/// the snackbar the app already has would be a second transient surface with
/// its own position and duration. G1 fails if a second `SnackBar(` is
/// constructed anywhere under `lib/`.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/error_snackbar.dart';
import 'package:udf_setup/design_system/notifications/feedback_banner.dart';
import 'package:udf_setup/design_system/resilience/error_rollback_boundary.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/resilience/log_scrubber.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

List<String> _snackBarConstructions() {
  final RegExp construction = RegExp(r'\bSnackBar\s*\(');
  final RegExp cousins = RegExp(r'\bSnackBar(Action|Behavior|ThemeData|Closed)');
  final List<String> found = <String>[];
  for (final File file in Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))) {
    final List<String> lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final String trimmed = lines[i].trim();
      if (trimmed.startsWith('//')) {
        continue;
      }
      if (construction.hasMatch(lines[i]) && !cousins.hasMatch(lines[i])) {
        found.add('${file.path}:${i + 1}');
      }
    }
  }
  return found;
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  String renderedMessage = '';

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

  group('EDBAA-001 :: the toast is the snackbar', () {
    test('[EDBAA-001-G1] no second transient surface was built for this '
        'failure class', () {
      final List<String> constructions = _snackBarConstructions();
      expect(
        constructions.length,
        1,
        reason:
            'a "toast" beside the snackbar would be a second position, a '
            'second duration and a second dismissal rule. Found: '
            '${constructions.join(", ")}',
      );

      gates.add(
        AissGate(
          id: 'EDBAA-001-G1',
          requirementSource:
              'Setup Step (Action): "Design the \'Liveness Handshake\' Failure '
              'Toast" -- read against GEN-01363 (Step 25) and PNSAD-026 '
              '(Step 70), which already settled where transient feedback sits.',
          description:
              'The liveness toast routes through the one snackbar that exists '
              'under lib/, so this step adds a bound failure source and not a '
              'parallel surface',
          passed: true,
          detail: 'sole construction at ${constructions.single}',
        ),
      );
    });

    gate(
      'EDBAA-001-G2',
      'Self-Chasing (this row and nearly every row in the sheet): "an '
          'automated liveness handshake monitors this step and triggers '
          'rollback on failure."',
      'The two handshake outcomes are distinguished rather than collapsed: a '
          'MISSED handshake is a timeout and is marked rolled back, an '
          'UNHEALTHY report is a server failure and is not -- because the call '
          'completed, so there is nothing to roll back',
      () {
        final HandledFailure missed = HabotFeedbackSources.liveness(
          HabotLivenessFailure.missed,
        );
        final HandledFailure unhealthy = HabotFeedbackSources.liveness(
          HabotLivenessFailure.unhealthy,
        );
        return missed.category == HabotErrorCategory.timeout &&
            missed.rolledBack &&
            unhealthy.category == HabotErrorCategory.serverFailure &&
            !unhealthy.rolledBack &&
            missed.template.retryable &&
            unhealthy.template.retryable;
      },
    );

    gate(
      'EDBAA-001-G3',
      'CONFLICT, RESOLVED: Data Requirement asks for "bold monospaced '
          'typography ... to the deployment hash string" and "Tapping the '
          'alert card copies the SYSTEM TRACE IDENTIFIER directly to the '
          'clipboard". REF-197 (Step 19) rules that a diagnostic is scrubbed '
          'and logged, never rendered.',
      'The diagnostic exists and states what happened, and it is clean enough '
          'to log; the message the operator sees is the template\'s words and '
          'contains none of it -- so the monitoring detail is kept without '
          'being put on a screen',
      () {
        for (final HabotLivenessFailure failure in HabotLivenessFailure.values) {
          final HandledFailure handled = HabotFeedbackSources.liveness(failure);
          final String shown = HabotFeedbackBanner.messageForLiveness(failure);
          if (handled.scrubbedDiagnostic.isEmpty) {
            return false;
          }
          if (!HabotLogScrubber.isClean(handled.scrubbedDiagnostic)) {
            return false;
          }
          if (shown.contains(handled.scrubbedDiagnostic)) {
            return false;
          }
          if (!HabotErrorSnackbar.isPresentable(shown)) {
            return false;
          }
        }
        return true;
      },
    );
  });

  group('EDBAA-001 :: what the operator actually sees', () {
    testWidgets('[EDBAA-001-G4] a missed handshake renders the template, not '
        'the diagnostic', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => HabotFeedbackBanner.showLivenessFailure(
                  context,
                  HabotLivenessFailure.missed,
                  onRetry: () {},
                ),
                child: const Text('handshake'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('handshake'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      renderedMessage = HabotFeedbackBanner.messageForLiveness(
        HabotLivenessFailure.missed,
      );
      expect(find.text(renderedMessage), findsOneWidget);
      expect(
        find.textContaining('handshake did not respond'),
        findsNothing,
        reason: 'the diagnostic is for the log, not the screen',
      );
      // The row wants the alert to survive a careless swipe. The dismissal
      // rule belongs to the shared snackbar, so it is asserted here rather
      // than forked: a retry action means the bar waits for a decision.
      expect(find.byType(SnackBarAction), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'EDBAA-001-G4',
          requirementSource:
              'Data Collected: "Metric Name; Metric Value; Monitoring Status; '
              'Alert Threshold; Monitoring Timestamp" -- monitoring fields for '
              'a monitoring alert; plus Data Requirement: "Utilize vivid '
              'high-contrast color choices to signal structural system '
              'faults."',
          description:
              'The rendered toast carries the template wording exactly, offers '
              'the retry the handshake case needs, and shows no part of the '
              'diagnostic',
          passed: true,
          detail: 'rendered: "$renderedMessage"',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'EDBAA-001',
        atomicStepReferenceId: 'EDBAA-001-A01',
        setupStepAction: 'Design the "Liveness Handshake" Failure Toast',
        implementationOrder: 72,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Metric Name':
              'NOT PRODUCED -- the sheet names "TLS Protocol Compliance Rate", '
              'which no toast can produce',
          'Metric Value': 'NOT PRODUCED -- see above',
          'Monitoring Status':
              'missed -> timeout, rolled back; unhealthy -> server failure, '
              'not rolled back',
          'Alert Threshold':
              'the handshake window itself; this step renders the outcome and '
              'does not own the threshold',
          'Monitoring Timestamp':
              'carried by the caller; the toast holds no clock of its own',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC MISMATCH -- "TLS Protocol Compliance Rate" is a '
              'transport property, recorded as NOT PRODUCED with no substitute '
              'number. CONTAMINATED ROW -- ten columns describe a sign-up '
              'screen and an authentication wireframe (Expected Output '
              '"Mobile low-fidelity sign-up wireframe", Completion Measures '
              'about a Jira checkbox). Not gated. CONFLICT RESOLVED AND '
              'RECORDED -- the Data Requirement asks for a deployment hash and '
              'a tap-to-copy trace identifier in the user-facing alert; '
              'REF-197 forbids diagnostics reaching the user, and that rule '
              'was kept. The diagnostic is produced and logged instead, which '
              'EDBAA-001-G3 proves. ALSO NOT IMPLEMENTED: "Remove basic '
              'gesture dismiss options" -- dismissal belongs to the shared '
              'Step 25 snackbar, and forking it for one failure class would '
              'undo the reuse this step is built on.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'TLS Protocol Compliance Rate',
            observed:
                'NOT PRODUCED -- TLS is negotiated by the transport, not by a '
                'toast. This suite cannot observe a cipher suite, and no '
                'stand-in figure is offered.',
            floor: '100% of connections on TLS 1.2 or higher',
            optimal: '100% of connections on TLS 1.3',
            ceiling:
                '100% of connections on TLS 1.3 with hardened cipher suite '
                '(no legacy fallback)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/feedback_banner.dart',
          'lib/design_system/feedback/error_snackbar.dart',
        ],
      ),
    );
  });
}
