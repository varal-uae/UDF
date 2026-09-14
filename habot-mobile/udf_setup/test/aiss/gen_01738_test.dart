/// AISS GATE -- Step 158 of 175
/// Global Reference ID:       GEN-01738
/// Atomic Steps Reference ID: GEN-01738
/// Setup Step (Action) / Atomic Step: "Validate that stack traces are
///   successfully hidden from the end user."
/// Metric: Stack Trace Exposure Incidents -- Floor 0.0, Optimal 0.0,
///         Ceiling 0.0. Zero Incidents / Minor Incidents / Critical Incidents.
///
/// A METRIC OF ZERO AT EVERY BOUND CANNOT BE MET BY TESTING THE SCREENS
/// SOMEBODY REMEMBERED, so these gates check the shape of the route rather than
/// a list of screens: that the only thing a screen can obtain is a closed map
/// of three strings, that none of them survives the trace detector, and that
/// the detector is not vacuous.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/resilience/log_scrubber.dart';
import 'package:udf_setup/design_system/resilience/stack_trace_shield.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int incidents = -1;
  int unshieldedIncidents = -1;

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

  /// A defect in the form gate.
  StackTrace traceA() => StackTrace.fromString(
        '#0      HabotFormGate.submit '
        '(package:udf_setup/design_system/forms/form_gate.dart:88:12)\n'
        '#1      HabotWizard.advance '
        '(package:udf_setup/design_system/wizard/wizard.dart:142:7)',
      );

  /// The SAME defect after an unrelated edit moved both lines.
  StackTrace traceAMoved() => StackTrace.fromString(
        '#0      HabotFormGate.submit '
        '(package:udf_setup/design_system/forms/form_gate.dart:91:12)\n'
        '#1      HabotWizard.advance '
        '(package:udf_setup/design_system/wizard/wizard.dart:150:7)',
      );

  /// A DIFFERENT defect that happens to sit at the same depth and the same
  /// line and column numbers.
  StackTrace traceB() => StackTrace.fromString(
        '#0      HabotOutbox.enqueue '
        '(package:udf_setup/design_system/data/outbox.dart:88:12)\n'
        '#1      HabotSyncLoop.tick '
        '(package:udf_setup/design_system/data/sync_loop.dart:142:7)',
      );

  group('GEN-01738 :: the only route to a screen', () {
    gate(
      'GEN-01738-G1',
      'Metric: Stack Trace Exposure Incidents -- 0.0 at floor, optimal and '
          'ceiling alike.',
      'Everything a shielded error offers a screen is a closed map of three '
          'strings, and not one of them trips the trace detector -- so the '
          'incident count over a rendered error is zero',
      () {
        final HabotUserFacingError e = HabotStackTraceShield.shield(
          error: StateError('submission failed for Amara Okafor'),
          trace: traceA(),
          category: HabotErrorCategory.validation,
        );
        final List<String> displayed =
            HabotStackTraceShield.displayedValuesOf(e);
        incidents = HabotStackTraceShield.exposureIncidents(displayed);
        return e.displayFields.keys.toSet().length == 3 &&
            e.displayFields.containsKey('title') &&
            e.displayFields.containsKey('body') &&
            e.displayFields.containsKey('reference') &&
            incidents == HabotStackTraceShield.optimal &&
            incidents == HabotStackTraceShield.ceiling &&
            HabotStackTraceShield.severityFor(incidents) == 'Zero Incidents' &&
            e.traceReference == 'ERR-31BFE6' &&
            // The exception's own message does not reach the screen either.
            !displayed.any((String v) => v.contains('Amara')) &&
            !displayed.any((String v) => v.contains('StateError'));
      },
    );

    gate(
      'GEN-01738-G2',
      'UI decision (Step 68): "the user gets the declared template, not a '
          'message."',
      'The screen text is the Step 68 template for the category rather than '
          'anything derived from the error, and the reference the user can '
          'read out is a short opaque code',
      () {
        final HabotUserFacingError e = HabotStackTraceShield.shield(
          error: TimeoutException(),
          trace: traceA(),
          category: HabotErrorCategory.timeout,
        );
        final HabotErrorTemplate expected =
            HabotErrorTemplates.of(HabotErrorCategory.timeout);
        return e.title == expected.title &&
            e.body == expected.body &&
            e.retryable == expected.retryable &&
            e.traceReference.startsWith('ERR-') &&
            e.traceReference.length == 10 &&
            e.traceReference ==
                e.traceReference.toUpperCase() &&
            HabotStackTraceShield.typeNotTestNote.contains('next month');
      },
    );

    gate(
      'GEN-01738-G3',
      'A detector that never fires would make every incident count zero and '
          'the metric meaningless.',
      'The trace detector fires on real trace text -- frame markers, package '
          'and dart URIs, a .dart:line:col location and an "at" frame -- and '
          'stays quiet on the plain sentences the templates are made of',
      () {
        unshieldedIncidents = HabotStackTraceShield.exposureIncidents(
          <String>[
            '#0      HabotFormGate.submit (form_gate.dart:88:12)',
            'package:udf_setup/design_system/forms/form_gate.dart',
            'Something went wrong. Try again in a moment.',
          ],
        );
        return HabotStackTraceShield.looksLikeTrace(traceA().toString()) &&
            HabotStackTraceShield.looksLikeTrace('dart:async/future.dart') &&
            HabotStackTraceShield.looksLikeTrace('  at HabotOutbox.enqueue') &&
            !HabotStackTraceShield.looksLikeTrace(
              HabotErrorTemplates.of(HabotErrorCategory.offline).body,
            ) &&
            unshieldedIncidents == 2 &&
            unshieldedIncidents > HabotStackTraceShield.ceiling &&
            HabotStackTraceShield.severityFor(unshieldedIncidents) ==
                'Minor Incidents' &&
            HabotStackTraceShield.severityFor(3) == 'Critical Incidents';
      },
    );
  });

  group('GEN-01738 :: the fingerprint, and the trap it avoids', () {
    gate(
      'GEN-01738-G4',
      '"Symbols are code identifiers and carry no user data. Locations do: a '
          'path names the developer\'s machine."',
      'The frame signature keeps the frame symbols and drops every file '
          'location, so it survives an unrelated edit that moved the lines and '
          'still separates two different defects',
      () {
        final List<String> a = HabotStackTraceShield.frameSignature(traceA());
        final List<String> moved =
            HabotStackTraceShield.frameSignature(traceAMoved());
        final List<String> b = HabotStackTraceShield.frameSignature(traceB());
        return a.length == 2 &&
            a.first == 'HabotFormGate.submit' &&
            a.every((String f) => !f.contains('.dart')) &&
            a.every((String f) => !f.contains('package:')) &&
            a.join('|') == moved.join('|') &&
            a.join('|') != b.join('|') &&
            HabotStackTraceShield.frameSignature(null).isEmpty;
      },
    );

    gate(
      'GEN-01738-G5',
      '"Scrubbing the trace first is the other trap, and it fails in both '
          'directions at once."',
      'A fingerprint built from the SCRUBBED trace would collide -- two '
          'unrelated defects at the same line numbers scrub to the identical '
          'string -- and would also drift when an unrelated edit moved a line; '
          'the frame signature does neither, which is demonstrated rather than '
          'asserted',
      () {
        final String scrubbedA =
            HabotLogScrubber.scrub(traceA().toString());
        final String scrubbedB =
            HabotLogScrubber.scrub(traceB().toString());
        final String scrubbedMoved =
            HabotLogScrubber.scrub(traceAMoved().toString());

        // The trap, shown from both ends.
        final bool wouldCollide = scrubbedA == scrubbedB;
        final bool wouldDrift = scrubbedA != scrubbedMoved;

        // What the shield actually does.
        final String fpA = HabotStackTraceShield.fingerprintOf(
          StateError('x'),
          traceA(),
        );
        final String fpB = HabotStackTraceShield.fingerprintOf(
          StateError('x'),
          traceB(),
        );
        final String fpMoved = HabotStackTraceShield.fingerprintOf(
          StateError('x'),
          traceAMoved(),
        );

        return wouldCollide &&
            wouldDrift &&
            scrubbedA.contains('88:12') &&
            !scrubbedA.contains('HabotFormGate') &&
            fpA != fpB &&
            fpA == fpMoved &&
            fpA.length == 8 &&
            HabotStackTraceShield.fingerprintNote
                .contains('both directions');
      },
    );

    gate(
      'GEN-01738-G6',
      '"A message frequently contains the value that broke, which must not '
          'travel, and which would also give every occurrence a different '
          'fingerprint."',
      'Two occurrences of one defect carrying different messages share a '
          'fingerprint, so the grouping the report exists for survives the '
          'thing that varies most',
      () {
        final String first = HabotStackTraceShield.fingerprintOf(
          StateError('no record for 07700 900123'),
          traceA(),
        );
        final String second = HabotStackTraceShield.fingerprintOf(
          StateError('no record for 07700 900456'),
          traceA(),
        );
        final String otherType = HabotStackTraceShield.fingerprintOf(
          ArgumentError('no record'),
          traceA(),
        );
        return first == second && first != otherType;
      },
    );
  });

  group('GEN-01738 :: the diagnostic route, and what it does not promise', () {
    gate(
      'GEN-01738-G7',
      '"A shield that makes debugging harder gets bypassed within a week."',
      'The developer route carries the fingerprint, the error type and the '
          'frame symbols with every file location and every path scrubbed out '
          '-- and it is still trace-SHAPED, so the incident counter would '
          'catch it the moment somebody routed it to a screen',
      () {
        final String d = HabotStackTraceShield.diagnostic(
          error: StateError('failed at /Users/fred/dev/udf/lib/x.dart'),
          trace: traceA(),
        );
        return d.contains('HabotFormGate.submit') &&
            d.contains('StateError') &&
            d.contains('31bfe6d2') &&
            !d.contains('package:') &&
            !d.contains('88:12') &&
            !d.contains('/Users/fred') &&
            d.contains(HabotLogScrubber.redaction) &&
            d.contains('  at ') &&
            // Deliberate: the diagnostic reads as a trace, so routing it to a
            // display path is an incident the counter sees rather than a leak
            // that looks like ordinary text.
            HabotStackTraceShield.looksLikeTrace(d) &&
            HabotStackTraceShield.exposureIncidents(<String>[d]) == 1 &&
            HabotStackTraceShield.diagnosticRouteNote.contains('bypassed');
      },
    );

    gate(
      'GEN-01738-G8',
      'Honest reporting: the scrubber matches structured identifiers, not '
          'names. A name is indistinguishable from any other two words.',
      'The limit is recorded rather than glossed: a diagnostic line built from '
          'a message can still contain a person\'s name, which is why this is '
          'a local developer route and why the Step 159 report carries no '
          'message at all',
      () {
        final String d = HabotStackTraceShield.diagnostic(
          error: StateError('no referral found for Amara Okafor'),
          trace: traceA(),
        );
        return d.contains('Amara Okafor') &&
            HabotStackTraceShield.diagnosticLimitNote.contains('no message') &&
            HabotStackTraceShield.diagnosticLimitNote
                .contains('developer route') &&
            // ...and the screen, which is what this row is about, does not.
            !HabotStackTraceShield.displayedValuesOf(
              HabotStackTraceShield.shield(
                error: StateError('no referral found for Amara Okafor'),
                trace: traceA(),
                category: HabotErrorCategory.notFound,
              ),
            ).any((String v) => v.contains('Amara'));
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01738',
        atomicStepReferenceId: 'GEN-01738',
        setupStepAction:
            'Validate that stack traces are successfully hidden from the end '
            'user.',
        implementationOrder: 158,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotStackTraceShield / HabotUserFacingError',
          'Component Properties':
              '${HabotStackTraceShield.traceMarkers.length} trace markers; '
              '${HabotStackTraceShield.signatureFrames} frames kept in a '
              'signature; a shielded error offers a screen exactly 3 strings '
              '(title, body, reference) and no route to the exception object',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The exposure count is zero over a shielded '
              'error and is shown rising to $unshieldedIncidents over values '
              'that were not shielded, so the metric is a measurement rather '
              'than a constant. LIMIT RECORDED: diagnostic() is scrubbed but '
              'the scrubber matches structured identifiers, not names, so a '
              'diagnostic line can still carry one -- it is a local developer '
              'route and the Step 159 report carries no message at all.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Stack Trace Exposure Incidents',
            observed:
                '$incidents across every field a shielded error offers a '
                'screen. The same counter reports $unshieldedIncidents on a '
                'set of values that bypassed the shield, which is what makes '
                'the zero meaningful.',
            floor: '0.0',
            optimal: '0.0',
            ceiling: '0.0',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Fingerprint stability and separation',
            observed:
                'One defect keeps one fingerprint across a message change and '
                'an unrelated edit that moved both its lines; two different '
                'defects at identical line numbers keep different '
                'fingerprints. The scrubbed-trace implementation collides on '
                'the second case and drifts on the first, and both are '
                'demonstrated in gate G5 rather than asserted.',
            floor: 'stable across message and line changes',
            optimal: 'stable across message and line changes',
            ceiling: 'stable across message and line changes',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/stack_trace_shield.dart',
        ],
      ),
    );
  });
}

/// A local exception type, so the gate does not depend on dart:async's.
class TimeoutException implements Exception {
  const TimeoutException();

  @override
  String toString() => 'TimeoutException';
}
