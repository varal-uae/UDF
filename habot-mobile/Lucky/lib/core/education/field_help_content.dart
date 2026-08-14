// AEETE-012-11 — Field help copy catalog.
// User Education Writer can extend entries; keys stay stable for analytics.

class FieldHelpContent {
  const FieldHelpContent({
    required this.fieldKey,
    required this.title,
    required this.body,
    this.example,
  });

  final String fieldKey;
  final String title;
  final String body;
  final String? example;
}

abstract class FieldHelpCatalog {
  static const taxId = FieldHelpContent(
    fieldKey: 'tax_id',
    title: 'Tax identification number',
    body:
        'Enter the official tax ID exactly as it appears on your registration '
        'document. Do not include spaces or dashes unless your form requires them.',
    example: 'Example: 1234567890',
  );

  static const documentCategory = FieldHelpContent(
    fieldKey: 'document_category',
    title: 'Document category',
    body:
        'Select the category that best matches your upload. This routes the '
        'file to the correct review queue and prevents processing delays.',
  );

  static const releaseNotes = FieldHelpContent(
    fieldKey: 'release_notes',
    title: 'Release notes',
    body:
        'Summarize what changed in this release. Include any steps reviewers '
        'must verify before approving the handoff to Tech.',
  );

  static FieldHelpContent? byKey(String key) {
    for (final entry in [taxId, documentCategory, releaseNotes]) {
      if (entry.fieldKey == key) return entry;
    }
    return null;
  }
}
