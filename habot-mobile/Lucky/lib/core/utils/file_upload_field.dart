import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'validated_form.dart';

// GEN-03242 — File Upload Field with Proof Submission Gating.
// Spec: Poka-Yoke Submission Control — form cannot submit without uploaded proof.
//
// Integrates with ValidatedFieldRegistry (Step 15):
//   - Registers itself as a required field on mount
//   - Reports isValid = false until a file is attached
//   - Reports isValid = true the moment a file is picked
//   - Removing the file sets isValid = false — re-locks submit
//
// Supported file types: PDF, images (JPG/PNG/WEBP), DOCX — configurable.
// Max file size enforced client-side before any upload attempt.

// ── Allowed file type presets ─────────────────────────────────────────────────

enum ProofFileType {
  /// PDF only — tax documents, statements
  pdf,

  /// Images — receipts, photos of physical documents
  images,

  /// PDF + images — most common for proof submission
  pdfAndImages,

  /// Any file — no restriction
  any,
}

extension ProofFileTypeX on ProofFileType {
  List<String>? get extensions {
    switch (this) {
      case ProofFileType.pdf:          return ['pdf'];
      case ProofFileType.images:       return ['jpg', 'jpeg', 'png', 'webp'];
      case ProofFileType.pdfAndImages: return ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
      case ProofFileType.any:          return null;
    }
  }

  FileType get fileType {
    switch (this) {
      case ProofFileType.images:       return FileType.image;
      case ProofFileType.pdf:
      case ProofFileType.pdfAndImages:
      case ProofFileType.any:          return FileType.custom;
    }
  }

  String get label {
    switch (this) {
      case ProofFileType.pdf:          return 'PDF';
      case ProofFileType.images:       return 'JPG, PNG';
      case ProofFileType.pdfAndImages: return 'PDF, JPG, PNG';
      case ProofFileType.any:          return 'Any file';
    }
  }
}

// ── Uploaded file model ───────────────────────────────────────────────────────

class UploadedFile {
  const UploadedFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.extension,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String extension;

  String get sizeLabel {
    if (sizeBytes < 1024)       return '$sizeBytes B';
    if (sizeBytes < 1048576)    return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / 1048576).toStringAsFixed(1)} MB';
  }
}

// ── FileUploadField widget ────────────────────────────────────────────────────

class FileUploadField extends StatefulWidget {
  const FileUploadField({
    super.key,
    required this.fieldKey,
    this.registry,
    this.label = 'Upload proof document',
    this.hint,
    this.allowedType = ProofFileType.pdfAndImages,
    this.maxFileSizeMB = 10,
    this.allowMultiple = false,
    this.required = true,
    this.onFileSelected,
    this.onFileRemoved,
  });

  /// Key used in ValidatedFieldRegistry — must be unique within the form.
  final String fieldKey;

  /// Registry from ValidatedForm.registryOf(context) or passed explicitly.
  final ValidatedFieldRegistry? registry;

  final String label;
  final String? hint;
  final ProofFileType allowedType;

  /// Maximum file size in MB. Default 10MB.
  final double maxFileSizeMB;

  final bool allowMultiple;
  final bool required;

  final ValueChanged<List<UploadedFile>>? onFileSelected;
  final VoidCallback? onFileRemoved;

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  final List<UploadedFile> _files = [];
  String? _error;
  bool _isPicking = false;

  ValidatedFieldRegistry? get _registry =>
      widget.registry ?? ValidatedForm.registryOf(context);

  @override
  void initState() {
    super.initState();
    // Register as required field — starts invalid (no file)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registry?.register(widget.fieldKey, required: widget.required);
      _registry?.setValidity(widget.fieldKey, isValid: false);
    });
  }

  @override
  void dispose() {
    _registry?.unregister(widget.fieldKey);
    super.dispose();
  }

  // ── File picking ────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() { _isPicking = true; _error = null; });

    try {
      final result = await FilePicker.platform.pickFiles(
        type:          widget.allowedType.fileType,
        allowedExtensions: widget.allowedType.fileType == FileType.custom
            ? widget.allowedType.extensions
            : null,
        allowMultiple: widget.allowMultiple,
        withData:      false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = <UploadedFile>[];
      String? sizeError;

      for (final f in result.files) {
        final sizeBytes = f.size;
        final maxBytes  = (widget.maxFileSizeMB * 1048576).toInt();

        if (sizeBytes > maxBytes) {
          sizeError = '${f.name} exceeds ${widget.maxFileSizeMB.toStringAsFixed(0)} MB limit';
          continue;
        }

        picked.add(UploadedFile(
          name:      f.name,
          path:      f.path ?? '',
          sizeBytes: sizeBytes,
          extension: f.extension ?? '',
        ));
      }

      if (sizeError != null) {
        setState(() => _error = sizeError);
      }

      if (picked.isNotEmpty) {
        setState(() {
          if (widget.allowMultiple) {
            _files.addAll(picked);
          } else {
            _files
              ..clear()
              ..addAll(picked);
          }
        });

        // Poka-Yoke: report valid only when at least one file is present
        _registry?.setValidity(widget.fieldKey, isValid: true);
        widget.onFileSelected?.call(List.unmodifiable(_files));
      }
    } catch (e) {
      setState(() => _error = 'Could not open file picker. Please try again.');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));

    // Re-lock submit if no files remain
    final hasFiles = _files.isNotEmpty;
    _registry?.setValidity(widget.fieldKey, isValid: hasFiles);

    if (!hasFiles) widget.onFileRemoved?.call();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final hasFiles = _files.isNotEmpty;
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.required ? '${widget.label} *' : widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Drop zone / pick button
        if (!hasFiles || widget.allowMultiple)
          _PickZone(
            hint:      widget.hint ?? 'Tap to select · ${widget.allowedType.label} · max ${widget.maxFileSizeMB.toStringAsFixed(0)} MB',
            isPicking: _isPicking,
            hasError:  hasError,
            onTap:     _isPicking ? null : _pickFile,
          ),

        // Selected files list
        if (hasFiles) ...[
          const SizedBox(height: 8),
          ...List.generate(_files.length, (i) => _FileChip(
            file:     _files[i],
            onRemove: () => _removeFile(i),
          )),
        ],

        // Error message
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 14,
                  color: theme.colorScheme.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _error!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Pick zone ─────────────────────────────────────────────────────────────────

class _PickZone extends StatelessWidget {
  const _PickZone({
    required this.hint,
    required this.isPicking,
    required this.hasError,
    required this.onTap,
  });

  final String hint;
  final bool isPicking;
  final bool hasError;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError
                ? theme.colorScheme.error
                : theme.colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerLowest,
        ),
        child: isPicking
            ? Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: theme.colorScheme.primary),
                ),
              )
            : Column(
                children: [
                  Icon(Icons.upload_file_rounded,
                      size: 32, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── File chip (attached file row) ─────────────────────────────────────────────

class _FileChip extends StatelessWidget {
  const _FileChip({required this.file, required this.onRemove});

  final UploadedFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_iconForExtension(file.extension),
              size: 20, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(file.sizeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer
                          .withOpacity(0.7),
                    )),
              ],
            ),
          ),
          // Remove button — 48dp touch target
          IconButton(
            icon:        const Icon(Icons.close_rounded, size: 18),
            tooltip:     'Remove file',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            color:       theme.colorScheme.onSecondaryContainer,
            onPressed:   onRemove,
          ),
        ],
      ),
    );
  }

  IconData _iconForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':              return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':             return Icons.image_rounded;
      case 'doc':
      case 'docx':             return Icons.description_rounded;
      default:                 return Icons.insert_drive_file_rounded;
    }
  }
}
