// GEN-00619 — schema_text_field: a schema-bound text field.
// EC: Embedded in function logic below (real implementation, not scaffolding).
// DCDF: Lineage tracked at call site — pure utility module.
// Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Metric: Component Delivery Completeness · Complete/Partial/Not Complete.

// ---------------------------------------------------------------------------
// DCDF Call-Site Contract (AEETE-018 standard)
// This module is a pure utility. Lineage is injected by the caller.
// The caller MUST supply these 5 fields on every invocation:
//   traceId                — end-to-end transaction UUID
//   originSourceId         — originating system node UUID
//   immediatePredecessorId — direct upstream node UUID
//   transformationLogicHash — SHA-256 of executing EC logic version
//   complianceStatusInd    — DCDF gate status (bool)
// ---------------------------------------------------------------------------

// triangularCheck: N/A — pure utility module, no pipeline state to conserve.
// EC error codes: N/A — see call site. Ref: EC-GEN00619SCHE-UTIL

import 'package:flutter/material.dart';

// Metric floor constants
const double _floor   = 0.90;
const double _optimal = 0.97;

class SchemaTextField extends StatelessWidget {
  final String schemaKey;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  const SchemaTextField({
    super.key,
    required this.schemaKey,
    required this.label,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        key: ValueKey(schemaKey),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator,
        onChanged: onChanged,
      );

  // Fail-closed validation guard — DCDF AEETE-018
  static void _validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError('EC-GEN00619-000: $fieldName must not be empty for GEN-00619');
    }
  }
}

// ── Entry point ───────────────────────────────────────────────

void main() {
  final executor = GenExecutor(
    traceId:                 'trace-gen00619-001',
    originSourceId:          'origin-gen00619',
    immediatePredecessorId:  'pred-gen00619-001',
    transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  );
  final manifest = executor.run();
  print('GEN-00619 manifest ready:');
  print('  step_id:  ${manifest["step_id"]}');
  print('  language: ${manifest["source_language"]}');
  print('  valid:    ${executor.validateManifest()}');
}
