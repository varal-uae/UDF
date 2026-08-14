// MUFCE-020-A01 — Master ingestion whitelist & validation rules.
// Single source of truth for allowed extensions, MIME types, and filename rules.

/// Document category — user must select before file registers (Poka-Yoke).
enum DocumentCategory {
  taxProof('Tax proof'),
  identity('Identity document'),
  receipt('Receipt'),
  contract('Contract'),
  other('Other');

  const DocumentCategory(this.label);
  final String label;
}

/// Result of client-side ingestion validation.
class IngestionValidationResult {
  const IngestionValidationResult.valid({
    required this.sanitizedName,
    required this.extension,
    required this.mimeType,
  })  : isValid = true,
        errorMessage = null;

  const IngestionValidationResult.invalid(this.errorMessage)
      : isValid = false,
        sanitizedName = null,
        extension = null,
        mimeType = null;

  final bool isValid;
  final String? errorMessage;
  final String? sanitizedName;
  final String? extension;
  final String? mimeType;
}

/// Formal extension whitelist + MIME map — master rules repository.
abstract class IngestionRules {
  /// Allowed extensions (lowercase, no dot).
  static const allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
  };

  /// Extension → expected MIME types.
  static const mimeByExtension = {
    'pdf':  {'application/pdf'},
    'jpg':  {'image/jpeg'},
    'jpeg': {'image/jpeg'},
    'png':  {'image/png'},
    'webp': {'image/webp'},
    'heic': {'image/heic', 'image/heif'},
  };

  /// Default max file size — 10 MB.
  static const defaultMaxSizeBytes = 10 * 1024 * 1024;

  /// Characters stripped from filenames — secures naming taxonomy.
  static final illegalChars = RegExp(r'[\\/:*?"<>|\x00-\x1f]');

  /// Validates extension, optional MIME, size, and sanitizes filename.
  static IngestionValidationResult validate({
    required String fileName,
    required int sizeBytes,
    String? reportedMime,
    int maxSizeBytes = defaultMaxSizeBytes,
  }) {
    if (sizeBytes <= 0) {
      return const IngestionValidationResult.invalid('File is empty');
    }

    if (sizeBytes > maxSizeBytes) {
      final mb = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(0);
      return IngestionValidationResult.invalid('File exceeds $mb MB limit');
    }

    final ext = _extractExtension(fileName);
    if (ext.isEmpty) {
      return const IngestionValidationResult.invalid(
        'File has no extension — upload rejected',
      );
    }

    if (!allowedExtensions.contains(ext)) {
      return IngestionValidationResult.invalid(
        'Unsupported file type .$ext — allowed: ${allowedExtensions.join(', ')}',
      );
    }

    final expectedMimes = mimeByExtension[ext];
    if (reportedMime != null &&
        expectedMimes != null &&
        !expectedMimes.contains(reportedMime.toLowerCase())) {
      return IngestionValidationResult.invalid(
        'MIME type mismatch — expected ${expectedMimes.first}, got $reportedMime',
      );
    }

    final sanitized = sanitizeFileName(fileName);
    if (sanitized.isEmpty) {
      return const IngestionValidationResult.invalid(
        'Filename contains only invalid characters',
      );
    }

    return IngestionValidationResult.valid(
      sanitizedName: sanitized,
      extension: ext,
      mimeType: reportedMime ?? expectedMimes?.first ?? 'application/octet-stream',
    );
  }

  /// Strips illegal path characters and collapses whitespace.
  static String sanitizeFileName(String name) {
    var base = name.split(RegExp(r'[/\\]')).last;
    base = base.replaceAll(illegalChars, '_');
    base = base.replaceAll(RegExp(r'\s+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    return base.trim();
  }

  static String _extractExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  static bool isImageExtension(String ext) =>
      {'jpg', 'jpeg', 'png', 'webp', 'heic'}.contains(ext.toLowerCase());
}
