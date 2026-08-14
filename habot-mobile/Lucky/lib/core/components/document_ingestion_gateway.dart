import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../telemetry/upload_audit_telemetry.dart';
import '../utils/validated_form.dart';
import 'document_crop_sheet.dart';
import '../education/field_help_content.dart';
import 'field_help_popup.dart';
import 'ingestion_rules.dart';

// MUFCE-020-A01 — Unified Document Ingestion & Cropping UI.
//
// Absolute entry point for 100% of file uploads across the app.
//   - Touch-friendly upload zone (48dp minimum targets)
//   - Extension + MIME + size validation at first touch
//   - Filename sanitization (illegal chars stripped)
//   - Optional image crop sheet
//   - Mandatory category selection (Poka-Yoke)
//   - Thumbnail preview pill on valid reception
//   - Non-disruptive error snackbar on rejection
//   - BigQuery audit telemetry stub on success/rejection

// ── Ingested document model ───────────────────────────────────────────────────

class IngestedDocument {
  const IngestedDocument({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.extension,
    required this.mimeType,
    required this.category,
    this.wasCropped = false,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String extension;
  final String mimeType;
  final DocumentCategory category;
  final bool wasCropped;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1048576) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / 1048576).toStringAsFixed(1)} MB';
  }

  bool get isImage => IngestionRules.isImageExtension(extension);
}

// ── Gateway widget ────────────────────────────────────────────────────────────

class DocumentIngestionGateway extends StatefulWidget {
  const DocumentIngestionGateway({
    super.key,
    this.fieldKey,
    this.registry,
    this.label = 'Upload document',
    this.hint,
    this.maxFileSizeMB = 10,
    this.requireCategory = true,
    this.enableCrop = true,
    this.required = true,
    this.onDocumentIngested,
    this.onDocumentRemoved,
    this.sessionId,
    this.userId,
  });

  /// Optional — registers with ValidatedFieldRegistry when set.
  final String? fieldKey;
  final ValidatedFieldRegistry? registry;

  final String label;
  final String? hint;
  final double maxFileSizeMB;
  final bool requireCategory;
  final bool enableCrop;
  final bool required;

  final ValueChanged<IngestedDocument>? onDocumentIngested;
  final VoidCallback? onDocumentRemoved;

  final String? sessionId;
  final String? userId;

  @override
  State<DocumentIngestionGateway> createState() =>
      _DocumentIngestionGatewayState();
}

class _DocumentIngestionGatewayState extends State<DocumentIngestionGateway> {
  IngestedDocument? _document;
  DocumentCategory? _selectedCategory;
  bool _isPicking = false;

  ValidatedFieldRegistry? get _registry =>
      widget.registry ??
      (widget.fieldKey != null ? ValidatedForm.registryOf(context) : null);

  int get _maxBytes => (widget.maxFileSizeMB * 1048576).toInt();

  @override
  void initState() {
    super.initState();
    if (widget.fieldKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registry?.register(widget.fieldKey!, required: widget.required);
        _syncRegistryValidity();
      });
    }
  }

  @override
  void dispose() {
    if (widget.fieldKey != null) {
      _registry?.unregister(widget.fieldKey!);
    }
    super.dispose();
  }

  void _syncRegistryValidity() {
    if (widget.fieldKey == null) return;
    final valid = _document != null &&
        (!widget.requireCategory || _selectedCategory != null);
    _registry?.setValidity(widget.fieldKey!, isValid: valid);
  }

  void _showError(String message, {String? fileName}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onError, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );

    if (fileName != null) {
      UploadAuditTelemetry.dispatchRejection(
        fileName: fileName,
        reason: message,
        sessionId: widget.sessionId,
      );
    }
  }

  Future<void> _openSourcePicker() async {
    if (_isPicking) return;

    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => const _SourcePickerSheet(),
    );

    if (source == null) return;

    switch (source) {
      case _PickSource.gallery:
        await _pickFiles(fromGallery: true);
      case _PickSource.files:
        await _pickFiles(fromGallery: false);
      case _PickSource.camera:
        await _pickFromCamera();
    }
  }

  Future<void> _pickFromCamera() async {
    // Uses gallery image pick as portable fallback when image_picker unavailable.
    // Wire ImagePicker(source: ImageSource.camera) when image_picker is in pubspec.
    await _pickFiles(fromGallery: true);
  }

  Future<void> _pickFiles({required bool fromGallery}) async {
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: fromGallery ? FileType.image : FileType.custom,
        allowedExtensions: fromGallery ? null : IngestionRules.allowedExtensions.toList(),
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      await _processPickedFile(
        name: file.name,
        path: file.path,
        sizeBytes: file.size,
        reportedMime: _mimeFromExtension(file.extension),
      );
    } catch (_) {
      _showError('Could not open file picker. Please try again.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _processPickedFile({
    required String name,
    required String? path,
    required int sizeBytes,
    String? reportedMime,
  }) async {
    if (path == null || path.isEmpty) {
      _showError('Could not read file path.', fileName: name);
      return;
    }

    final validation = IngestionRules.validate(
      fileName: name,
      sizeBytes: sizeBytes,
      reportedMime: reportedMime,
      maxSizeBytes: _maxBytes,
    );

    if (!validation.isValid) {
      _showError(validation.errorMessage!, fileName: name);
      return;
    }

    var finalPath = path;
    var wasCropped = false;

    if (widget.enableCrop &&
        IngestionRules.isImageExtension(validation.extension!)) {
      final cropped = await DocumentCropSheet.show(context, imagePath: path);
      if (cropped == null) return; // user cancelled crop
      finalPath = cropped;
      wasCropped = true;
      final croppedSize = await File(finalPath).length();
      final revalidation = IngestionRules.validate(
        fileName: validation.sanitizedName!,
        sizeBytes: croppedSize,
        reportedMime: 'image/png',
        maxSizeBytes: _maxBytes,
      );
      if (!revalidation.isValid) {
        _showError(revalidation.errorMessage!, fileName: name);
        return;
      }
    }

    if (widget.requireCategory && _selectedCategory == null) {
      _showError('Select a document category before uploading.');
      return;
    }

    final category = _selectedCategory ?? DocumentCategory.other;
    final doc = IngestedDocument(
      name: validation.sanitizedName!,
      path: finalPath,
      sizeBytes: wasCropped
          ? await File(finalPath).length()
          : sizeBytes,
      extension: wasCropped ? 'png' : validation.extension!,
      mimeType: wasCropped ? 'image/png' : validation.mimeType!,
      category: category,
      wasCropped: wasCropped,
    );

    setState(() => _document = doc);
    _syncRegistryValidity();
    widget.onDocumentIngested?.call(doc);

    await UploadAuditTelemetry.dispatch(
      fileName: doc.name,
      extension: doc.extension,
      mimeType: doc.mimeType,
      sizeBytes: doc.sizeBytes,
      category: doc.category.label,
      sessionId: widget.sessionId,
      userId: widget.userId,
    );
  }

  Future<void> _recropCurrent() async {
    final current = _document;
    if (current == null || !current.isImage) return;

    final cropped = await DocumentCropSheet.show(
      context,
      imagePath: current.path,
    );
    if (cropped == null || !mounted) return;

    final croppedSize = await File(cropped).length();
    setState(() {
      _document = IngestedDocument(
        name: current.name,
        path: cropped,
        sizeBytes: croppedSize,
        extension: 'png',
        mimeType: 'image/png',
        category: current.category,
        wasCropped: true,
      );
    });
  }

  void _removeDocument() {
    setState(() {
      _document = null;
    });
    _syncRegistryValidity();
    widget.onDocumentRemoved?.call();
  }

  String? _mimeFromExtension(String? ext) {
    if (ext == null) return null;
    return IngestionRules.mimeByExtension[ext.toLowerCase()]?.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDoc = _document != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.required ? '${widget.label} *' : widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        if (widget.requireCategory) ...[
          AdvancedFieldLabel(
            fieldLabel: 'Document category',
            required: true,
            help: FieldHelpCatalog.documentCategory,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<DocumentCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: DocumentCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) {
              setState(() => _selectedCategory = v);
              _syncRegistryValidity();
            },
          ),
          const SizedBox(height: 12),
        ],

        if (!hasDoc)
          _IngestionDropZone(
            hint: widget.hint ??
                'Tap to upload · ${IngestionRules.allowedExtensions.join(', ')} · max ${widget.maxFileSizeMB.toStringAsFixed(0)} MB',
            isPicking: _isPicking,
            onTap: _isPicking ? null : _openSourcePicker,
          ),

        if (hasDoc) ...[
          _ThumbnailPreviewPill(
            document: _document!,
            onRemove: _removeDocument,
          ),
          if (widget.enableCrop && _document!.isImage) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _recropCurrent(),
              icon: const Icon(Icons.crop_rounded, size: 18),
              label: const Text('Re-crop'),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Drop zone ─────────────────────────────────────────────────────────────────

class _IngestionDropZone extends StatelessWidget {
  const _IngestionDropZone({
    required this.hint,
    required this.isPicking,
    required this.onTap,
  });

  final String hint;
  final bool isPicking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Upload document drop zone',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerLowest,
          ),
          child: isPicking
              ? Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload',
                      style: theme.textTheme.titleSmall?.copyWith(
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
      ),
    );
  }
}

// ── Thumbnail preview pill ────────────────────────────────────────────────────

class _ThumbnailPreviewPill extends StatelessWidget {
  const _ThumbnailPreviewPill({
    required this.document,
    required this.onRemove,
  });

  final IngestedDocument document;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _PreviewThumb(document: document),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${document.category.label} · ${document.sizeLabel}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer
                        .withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Remove',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  const _PreviewThumb({required this.document});

  final IngestedDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (document.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(document.path),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconThumb(theme),
        ),
      );
    }

    return _iconThumb(theme);
  }

  Widget _iconThumb(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        document.extension == 'pdf'
            ? Icons.picture_as_pdf_rounded
            : Icons.insert_drive_file_rounded,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

// ── Source picker ─────────────────────────────────────────────────────────────

enum _PickSource { gallery, files, camera }

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose source',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Select photo',
              onTap: () => Navigator.pop(context, _PickSource.gallery),
            ),
            _SourceTile(
              icon: Icons.folder_open_outlined,
              label: 'Open files',
              onTap: () => Navigator.pop(context, _PickSource.files),
            ),
            _SourceTile(
              icon: Icons.photo_camera_outlined,
              label: 'Pick photo',
              onTap: () => Navigator.pop(context, _PickSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      minVerticalPadding: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
