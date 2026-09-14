/// AISS GATE -- Step 157 of 175
/// Global Reference ID:       GEN-00809
/// Atomic Steps Reference ID: GEN-00809
/// Setup Step (Action): "Deploy Automated PII Anonymization & Hashing Pipeline
///                       for Mobile Data"
/// Atomic Step: "Create pii_sanitizer.py."
/// Metric: Syntax Validity -- Floor 100%, Optimal 100%,
///         Ceiling "N/A (100% target)". Complete / Not Complete.
///
/// "SYNTAX VALIDITY" FOR A PYTHON FILE MEANS "IT PARSES", which is true of
/// every file anyone ever committed. The failure worth catching is a rule that
/// is syntactically perfect and matches nothing, so the metric is read as rule
/// validity: every rule must fire on a value it has to redact AND stay quiet on
/// one it must leave alone. G3 shows the second half doing real work.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/log_scrubber.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/pii_sanitizer.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double ruleValidity = 0;
  double overBroadValidity = 1;

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

  /// The same check the module runs, under a supplied "does this rule fire?"
  /// predicate -- so the metric can be exercised falling without editing the
  /// declared rule set.
  double validityUnder(bool Function(String label, String value) fires) {
    int broken = 0;
    for (final HabotSanitizerCase c in HabotPiiSanitizer.cases) {
      if (!fires(c.label, c.shouldRedact)) {
        broken++;
      }
      if (fires(c.label, c.shouldNotRedact)) {
        broken++;
      }
    }
    final int total = HabotPiiSanitizer.cases.length;
    final int ok = total - (broken > total ? total : broken);
    return ok / total;
  }

  group('GEN-00809 :: the substitution, recorded', () {
    gate(
      'GEN-00809-G1',
      'Atomic Step: "Create pii_sanitizer.py." This is a Flutter client.',
      'The named artefact and the side of the boundary it belongs to are both '
          'recorded in the code rather than the file being quietly renamed, '
          'and what the client builds instead is stated: deciding what leaves '
          'the device, not cleaning what arrives',
      () =>
          HabotPiiSanitizer.namedArtefact == 'pii_sanitizer.py' &&
          HabotPiiSanitizer.pipelineSide.contains('ingestion') &&
          HabotPiiSanitizer.pythonSubstitution.contains('crash report') &&
          HabotPiiSanitizer.reusesScrubberNote.contains('HabotLogScrubber'),
    );

    gate(
      'GEN-00809-G2',
      '"It extends the same rules rather than declaring a second set that '
          'would drift from the first."',
      'Every declared case names a rule that actually exists in the live '
          'scrubber, so a case for a deleted rule is reported as a failure '
          'rather than silently skipped',
      () {
        final Set<String> live =
            HabotLogScrubber.rules.map((ScrubRule r) => r.label).toSet();
        return HabotPiiSanitizer.cases.isNotEmpty &&
            HabotPiiSanitizer.cases.every(
              (HabotSanitizerCase c) => live.contains(c.label),
            );
      },
    );
  });

  group('GEN-00809 :: the metric, read as something that can fail', () {
    gate(
      'GEN-00809-G3',
      'Metric: Syntax Validity -- floor 100%, optimal 100%.',
      'Every declared rule fires on a value it must redact and stays quiet on '
          'a value it must leave alone; the validity figure is 1.0 and there '
          'are no rule failures',
      () {
        ruleValidity = HabotPiiSanitizer.ruleValidity;
        return HabotPiiSanitizer.ruleFailures().isEmpty &&
            ruleValidity == 1.0 &&
            ruleValidity >= HabotPiiSanitizer.floor &&
            HabotPiiSanitizer.qualitativeOutput == 'Complete';
      },
    );

    gate(
      'GEN-00809-G4',
      '"A redaction pattern with a wrong character class is not a syntax '
          'error, it is a silent data leak that every test still passes." '
          'A rule written as .* would score perfectly on the positives.',
      'The negative half of each case is what does the work: under a predicate '
          'that matches everything, the same computation reports every rule '
          'broken and the validity falls to 0.0',
      () {
        overBroadValidity = validityUnder((String _, String __) => true);
        final double liveValidity = validityUnder(
          (String label, String value) =>
              HabotLogScrubber.firedRules(value).contains(label),
        );
        return overBroadValidity == 0.0 &&
            overBroadValidity < HabotPiiSanitizer.floor &&
            liveValidity == 1.0 &&
            validityUnder((String _, String __) => false) == 0.0;
      },
    );

    gate(
      'GEN-00809-G5',
      '"A sanitiser on the device decides what leaves." The rules have to '
          'catch the things that actually turn up in this product\'s logs.',
      'An email address, a bearer token, an IP address, a URL and a long hex '
          'blob are each redacted out of an event payload, and the finding '
          'names the field and the rule without repeating the value',
      () {
        final Map<String, Object?> dirty = <String, Object?>{
          'event_name': 'errorCaptured',
          'trace_id': 'trace-a',
          'note': 'contact worker@example.com for details',
          'header': 'Authorization: Bearer zzqqwwxxyyvvuuttssrr',
        };
        final List<String> findings = HabotPiiSanitizer.findingsFor(dirty);
        final Map<String, Object?> scrubbed =
            HabotPiiSanitizer.scrubRow(dirty);
        return !HabotPiiSanitizer.rowIsClean(dirty) &&
            findings.any((String f) => f.startsWith('note: email')) &&
            findings.any((String f) => f.startsWith('header: secret')) &&
            findings.every((String f) => !f.contains('worker@example.com')) &&
            !(scrubbed['note']! as String).contains('worker@example.com') &&
            HabotPiiSanitizer.rowIsClean(scrubbed);
      },
    );

    gate(
      'GEN-00809-G6',
      '"Redacting trace_id would break every join the schema exists to '
          'enable, and event_date is a date."',
      'The Step 156 envelope fields are structural and pass through '
          'untouched, while a payload field of the same content does not -- '
          'which is what makes the exemption a rule rather than an oversight',
      () {
        final Map<String, Object?> row = <String, Object?>{
          'trace_id': 'a1b2c3d4e5f60718',
          'event_date': '2026-08-24',
          'session_ordinal': 4,
          'copy_of_trace': 'a1b2c3d4e5f60718',
        };
        final Map<String, Object?> out = HabotPiiSanitizer.scrubRow(row);
        return HabotPiiSanitizer.structuralFields
                .containsAll(HabotEventSchema.envelope) &&
            out['trace_id'] == 'a1b2c3d4e5f60718' &&
            out['event_date'] == '2026-08-24' &&
            out['session_ordinal'] == 4 &&
            out['copy_of_trace'] == HabotLogScrubber.redaction;
      },
    );
  });

  group('GEN-00809 :: the hashing half', () {
    gate(
      'GEN-00809-G7',
      'Setup Step (Action): "...Anonymization & HASHING Pipeline". '
          '"A hash is not anonymisation, and the salt is why."',
      'The same value under two install salts produces two different ids, and '
          'under one salt it is stable -- so the id groups repeats without '
          'being a public hash that a dictionary would reverse',
      () {
        const String value = 'worker@example.com';
        final String a = HabotPiiSanitizer.opaqueId(
          value,
          installSalt: 'install-a',
        );
        final String b = HabotPiiSanitizer.opaqueId(
          value,
          installSalt: 'install-b',
        );
        return HabotPiiSanitizer.saltSeparatesInstalls(
              value,
              'install-a',
              'install-b',
            ) &&
            a != b &&
            a ==
                HabotPiiSanitizer.opaqueId(value, installSalt: 'install-a') &&
            !a.contains('@') &&
            !a.contains('example') &&
            HabotPiiSanitizer.saltNote.contains('domain is small');
      },
    );

    gate(
      'GEN-00809-G8',
      'The scrubber\'s hex rule redacts any bare run of sixteen or more hex '
          'characters, which is exactly what a bare hash looks like.',
      'An emitted id carries the declared prefix and survives the sanitiser '
          'intact, so this module does not flag its own output and the Step '
          '161 stream does not drop every event carrying a query_hash',
      () {
        final String id = HabotPiiSanitizer.opaqueId(
          'rain jacket size 4',
          installSalt: 'install-a',
        );
        final String bare = id.substring(
          HabotPiiSanitizer.opaqueIdPrefix.length,
        );
        return HabotPiiSanitizer.isOpaqueId(id) &&
            id.startsWith(HabotPiiSanitizer.opaqueIdPrefix) &&
            id.length ==
                HabotPiiSanitizer.opaqueIdPrefix.length +
                    HabotPiiSanitizer.opaqueIdLength &&
            HabotLogScrubber.isClean(id) &&
            // The same digits without the prefix are redacted, which is the
            // rule doing its job and the reason the prefix exists.
            !HabotLogScrubber.isClean(bare) &&
            HabotLogScrubber.firedRules(bare).contains('hex') &&
            HabotPiiSanitizer.rowIsClean(<String, Object?>{'query_hash': id}) &&
            !HabotEventSchema.looksLikeFreeText(id) &&
            HabotPiiSanitizer.prefixNote.contains('rowIsClean');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00809',
        atomicStepReferenceId: 'GEN-00809',
        setupStepAction:
            'Deploy Automated PII Anonymization & Hashing Pipeline for Mobile '
            'Data -- Atomic Step: "Create pii_sanitizer.py."',
        implementationOrder: 157,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPiiSanitizer',
          'Component Properties':
              '${HabotPiiSanitizer.cases.length} declared rule cases over '
              '${HabotLogScrubber.rules.length} live scrubber rules; '
              '${HabotPiiSanitizer.structuralFields.length} structural fields '
              'exempt from redaction; opaque ids are '
              '"${HabotPiiSanitizer.opaqueIdPrefix}" + '
              '${HabotPiiSanitizer.opaqueIdLength} hex characters under a '
              'per-install salt',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: the row names pii_sanitizer.py, which '
              'belongs to the ingestion pipeline -- the same side of the '
              'boundary as the BigQuery writes at Steps 132, 145 and 161. What '
              'is built here is the earlier half: what leaves the device at '
              'all. The metric "Syntax Validity" is read as rule validity, '
              'because a rule that parses and matches nothing is the failure '
              'that a parse check cannot see.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Syntax Validity (read as rule validity)',
            observed:
                '${(ruleValidity * 100).toStringAsFixed(0)}% -- every declared '
                'rule fires on a value it must redact and stays quiet on one '
                'it must leave alone. The same computation falls to '
                '${(overBroadValidity * 100).toStringAsFixed(0)}% under a rule '
                'that matches everything, which is the failure an "it parses" '
                'check would report as passing.',
            floor: '100%',
            optimal: '100%',
            ceiling: 'N/A (100% target)',
          ),
          AissMeasurement(
            metricName: 'Structural fields preserved through sanitisation',
            observed:
                '${HabotPiiSanitizer.structuralFields.length} of '
                '${HabotPiiSanitizer.structuralFields.length}. trace_id and '
                'event_date pass through untouched while a payload field '
                'holding the same characters is redacted, so every join the '
                'Step 156 schema exists to enable survives.',
            floor: 'all envelope fields',
            optimal: 'all envelope fields',
            ceiling: 'all envelope fields',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/pii_sanitizer.dart',
        ],
      ),
    );
  });
}
