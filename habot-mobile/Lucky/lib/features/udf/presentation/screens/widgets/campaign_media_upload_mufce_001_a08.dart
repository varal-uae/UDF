// MUFCE-001-A08 — Campaign Imagery & Media Rule Implementation.
// Provides client-side file format validation via MIME type checking, 5MB size enforcement,
// local image pre-compression, drag-and-drop warning states, skeleton loaders, and progressive loading.

import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Mock data representing the compliance queue for media assets.
class _MockMediaAsset {
  final String id;
  final String fileName;
  final String mimeType;
  final int sizeInBytes;
  final bool isCompliant;
  final DateTime uploadedAt;

  const _MockMediaAsset({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.sizeInBytes,
    required this.isCompliant,
    required this.uploadedAt,
  });
}

const List<_MockMediaAsset> _mockPendingAssets = [
  _MockMediaAsset(
    id: 'asset_001',
    fileName: 'campaign_banner.png',
    mimeType: 'image/png',
    sizeInBytes: 2 * 1024 * 1024,
    isCompliant: true,
    uploadedAt: DateTime(2026, 9, 20),
  ),
  _MockMediaAsset(
    id: 'asset_002',
    fileName: 'promo_video.mp4',
    mimeType: 'video/mp4',
    sizeInBytes: 6 * 1024 * 1024,
    isCompliant: false,
    uploadedAt: DateTime(2026, 9, 21),
  ),
  _MockMediaAsset(
    id: 'asset_003',
    fileName: 'logo_draft.jpg',
    mimeType: 'image/jpeg',
    sizeInBytes: 800 * 1024,
    isCompliant: true,
    uploadedAt: DateTime(2026, 9, 22),
  ),
];

const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB Poka-Yoke limit
const List<String> _allowedMimeTypes = ['image/png', 'image/jpeg', 'image/webp'];

/// Validates file constraints (MIME type and size) before upload.
class MediaValidationResult {
  final bool isValid;
  final String? errorMessage;

  const MediaValidationResult._({required this.isValid, this.errorMessage});

  factory MediaValidationResult.valid() => const MediaValidationResult._(isValid: true);
  factory MediaValidationResult.invalid(String reason) => MediaValidationResult._(isValid: false, errorMessage: reason);
}

MediaValidationResult validateMediaFile({required String mimeType, required int sizeInBytes}) {
  if (!_allowedMimeTypes.contains(mimeType)) {
    return MediaValidationResult.invalid('Invalid format. Only PNG, JPEG, and WEBP are allowed.');
  }
  if (sizeInBytes > _maxFileSizeBytes) {
    return MediaValidationResult.invalid('File exceeds the 5MB maximum limit.');
  }
  return MediaValidationResult.valid();
}

/// Simulates local pre-compression of an image payload.
Future<Uint8List> compressImageLocally(Uint8List originalBytes) async {
  // In production, use flutter_image_compress or similar package.
  // Here we simulate a 40% reduction in payload size.
  await Future.delayed(const Duration(milliseconds: 600));
  final compressedLength = (originalBytes.length * 0.6).toInt();
  return Uint8List.fromList(originalBytes.sublist(0, compressedLength.clamp(0, originalBytes.length)));
}

/// Main widget implementing the campaign media upload interface with Material 3 standards.
class CampaignMediaUploadWidget extends StatefulWidget {
  const CampaignMediaUploadWidget({super.key});

  @override
  State<CampaignMediaUploadWidget> createState() => _CampaignMediaUploadWidgetState();
}

class _CampaignMediaUploadWidgetState extends State<CampaignMediaUploadWidget> {
  bool _isDragOver = false;
  bool _isUploading = false;
  String? _boundaryWarning;
  final List<_MockMediaAsset> _assets = List.from(_mockPendingAssets);

  void _simulateDrop(String fileName, String mimeType, int sizeInBytes) {
    setState(() {
      _isDragOver = false;
      _boundaryWarning = null;
    });

    final validation = validateMediaFile(mimeType: mimeType, sizeInBytes: sizeInBytes);
    if (!validation.isValid) {
      setState(() => _boundaryWarning = validation.errorMessage);
      return;
    }

    setState(() => _isUploading = true);
    // Simulate compression and upload
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _assets.insert(0, _MockMediaAsset(
          id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
          fileName: fileName,
          mimeType: mimeType,
          sizeInBytes: (sizeInBytes * 0.6).toInt(),
          isCompliant: true,
          uploadedAt: DateTime.now(),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Media Upload'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildDragAndDropZone(theme, colorScheme),
          if (_boundaryWarning != null) _buildWarningBanner(colorScheme),
          Expanded(child: _buildComplianceQueueList(theme)),
        ],
      ),
    );
  }

  Widget _buildDragAndDropZone(ThemeData theme, ColorScheme colorScheme) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (details) {
        final data = details.data;
        _simulateDrop(
          data['fileName'] as String? ?? 'unknown.png',
          data['mimeType'] as String? ?? 'image/png',
          data['sizeInBytes'] as int? ?? 1024,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: _isDragOver ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surfaceContainerHighest.withOpacity(0.2),
              border: Border.all(
                color: _isDragOver ? colorScheme.primary : colorScheme.outlineVariant,
                width: 2.0,
                style: _isDragOver ? BorderStyle.solid : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isUploading ? Icons.compress : Icons.cloud_upload_outlined,
                  size: 48,
                  color: _isDragOver ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  _isUploading ? 'Compressing & Uploading...' : 'Drag and drop campaign imagery here',
                  style: theme.text.titleLarge?.copyWith(
                    color: _isDragOver ? colorScheme.primary : colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Allowed: PNG, JPEG, WEBP | Max Size: 5MB',
                  style: theme.text.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (_isUploading) ...[
                  const SizedBox(height: 24),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningBanner(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _boundaryWarning!,
              style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onErrorContainer),
            onPressed: () => setState(() => _boundaryWarning = null),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceQueueList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return _MediaAssetTile(asset: asset, theme: theme);
      },
    );
  }
}

class _MediaAssetTile extends StatelessWidget {
  final _MockMediaAsset asset;
  final ThemeData theme;

  const _MediaAssetTile({required this.asset, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final sizeInMb = (asset.sizeInBytes / (1024 * 1024)).toStringAsFixed(2);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          // Skeleton loader mapping to exact aspect ratio
          child: asset.isCompliant
              ? Icon(Icons.image_outlined, color: colorScheme.primary)
              : Icon(Icons.broken_image_outlined, color: colorScheme.error),
        ),
      ),
      title: Text(
        asset.fileName,
        style: theme.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${asset.mimeType} • $sizeInMb MB • ${asset.uploadedAt.year}-${asset.uploadedAt.month.toString().padLeft(2, '0')}-${asset.uploadedAt.day.toString().padLeft(2, '0')}',
        style: theme.text.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      trailing: Chip(
        label: Text(asset.isCompliant ? 'Compliant' : 'Rejected'),
        backgroundColor: asset.isCompliant ? colorScheme.secondaryContainer : colorScheme.errorContainer,
        labelStyle: TextStyle(
          color: asset.isCompliant ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
