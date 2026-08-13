/// Utility for strict database identifier linter validation (_ID suffix enforcement).
class DbIdentifierLinter {
  /// Checks if a primary key or database field name ends strictly with upper case `_ID`.
  static DbLinterValidationResult validateIdentifier(String fieldKey) {
    final trimmed = fieldKey.trim();
    if (trimmed.isEmpty) {
      return const DbLinterValidationResult(
        isValid: false,
        fieldKey: '',
        message: 'Identifier field key cannot be empty.',
      );
    }

    final isValid = trimmed.endsWith('_ID');
    final suggestedFix = isValid
        ? trimmed
        : '${trimmed.replaceAll(RegExp(r'(_pk|_id|_key|id|pk)$', caseSensitive: false), '')}_ID';

    return DbLinterValidationResult(
      isValid: isValid,
      fieldKey: trimmed,
      suggestedFix: suggestedFix.toUpperCase(),
      message: isValid
          ? 'Valid DB Identifier: Terminates in uppercase _ID'
          : 'LINT ERROR (LINT_ERR_SUFFIX_ID): Key "$trimmed" must terminate in uppercase "_ID". Suggested: "$suggestedFix"',
    );
  }
}

class DbLinterValidationResult {
  final bool isValid;
  final String fieldKey;
  final String suggestedFix;
  final String message;

  const DbLinterValidationResult({
    required this.isValid,
    required this.fieldKey,
    this.suggestedFix = '',
    required this.message,
  });
}
