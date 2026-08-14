import 'package:flutter/material.dart';

import 'document_ingestion_gateway.dart';
import '../utils/validated_form.dart';

// GEN-03242 — File Upload Field (legacy wrapper).
// Delegates to DocumentIngestionGateway (MUFCE-020-A01) — the unified entry
// point for all uploads. Kept for backward compatibility with existing forms.

export 'document_ingestion_gateway.dart' show IngestedDocument;

enum ProofFileType {
  pdf,
  images,
  pdfAndImages,
  any,
}

extension ProofFileTypeX on ProofFileType {
  String get label {
    switch (this) {
      case ProofFileType.pdf:          return 'PDF';
      case ProofFileType.images:       return 'JPG, PNG';
      case ProofFileType.pdfAndImages: return 'PDF, JPG, PNG';
      case ProofFileType.any:          return 'Any file';
    }
  }
}

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

  factory UploadedFile.fromIngested(IngestedDocument doc) => UploadedFile(
        name:      doc.name,
        path:      doc.path,
        sizeBytes: doc.sizeBytes,
        extension: doc.extension,
      );
}

/// Thin wrapper around [DocumentIngestionGateway] for proof-submission forms.
class FileUploadField extends StatelessWidget {
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

  final String fieldKey;
  final ValidatedFieldRegistry? registry;
  final String label;
  final String? hint;
  final ProofFileType allowedType;
  final double maxFileSizeMB;
  final bool allowMultiple;
  final bool required;
  final ValueChanged<List<UploadedFile>>? onFileSelected;
  final VoidCallback? onFileRemoved;

  @override
  Widget build(BuildContext context) {
    // allowMultiple not supported by unified gateway — single doc per slot.
    return DocumentIngestionGateway(
      fieldKey:         fieldKey,
      registry:         registry,
      label:            label,
      hint:             hint ?? allowedType.label,
      maxFileSizeMB:    maxFileSizeMB,
      requireCategory:  false,
      enableCrop:       allowedType != ProofFileType.pdf,
      required:         required,
      onDocumentIngested: (doc) {
        onFileSelected?.call([UploadedFile.fromIngested(doc)]);
      },
      onDocumentRemoved: onFileRemoved,
    );
  }
}
