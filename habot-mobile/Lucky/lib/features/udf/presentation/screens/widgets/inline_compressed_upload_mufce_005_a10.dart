// MUFCE-005-A10 — Inline Document Upload Preview Component with Client-Side Compression.
// Provides a mobile-first, swipeable thumbnail row for image uploads, enforcing <100KB compression and Poka-Yoke validation before network transmission.

import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Mock data representing upload build metadata as required by the specification.
class UploadBuildMetadata {
  final String buildStatus;
  final DateTime buildTimestamp;
  final String buildArtifactsPath;
  final String buildLogs;
  final Duration buildDuration;

  const UploadBuildMetadata({
    required this.buildStatus,
    required this.buildTimestamp,
    required this.buildArtifactsPath,
    required this.buildLogs,
    required this.buildDuration,
  });
}

/// Represents a single file item in the upload queue.
class UploadFileItem {
  final String id;
  final String fileName;
  final String extension;
  final Uint8List? compressedBytes;
  final UploadBuildMetadata metadata;
  final bool hasError;
  final String? errorMessage;

  const UploadFileItem({
    required this.id,
    required this.fileName,
    required this.extension,
    this.compressedBytes,
    required this.metadata,
    this.hasError = false,
    this.errorMessage,
  });
}

/// Poka-Yoke validation utility to screen files at the root node.
class UploadInterceptor {
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic'
  ];

  /// Instantly rejects non-image extensions before initializing transmission lines.
  static bool isAllowed(String extension) {
    return _allowedExtensions.contains(extension.toLowerCase().replaceAll('.', ''));
  }
}

/// Mock repository simulating client-side asset processing optimization.
class MockAssetProcessor {
  /// Simulates compressing raw high-resolution photos locally down to <100KB configurations.
  Future<UploadFileItem> processAndCompress(String fileName, String extension) async {
    // Simulate processing time under 500ms as per requirement metrics
    await Future.delayed(const Duration(milliseconds: 350));

    if (!UploadInterceptor.isAllowed(extension)) {
      return UploadFileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        extension: extension,
        metadata: const UploadBuildMetadata(
          buildStatus: 'Failed',
          buildTimestamp: null,
          buildArtifactsPath: '',
          buildLogs: 'Rejected by Poka-Yoke interceptor.',
          buildDuration: Duration.zero,
        ),
        hasError: true,
        errorMessage: 'Invalid file type. Only images are allowed.',
      );
    }

    // Generate mock compressed bytes (<100KB)
    final mockCompressedBytes = Uint8List(90 * 1024); 

    return UploadFileItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      extension: extension,
      compressedBytes: mockCompressedBytes,
      metadata: UploadBuildMetadata(
        buildStatus: 'Complete',
        buildTimestamp: DateTime.now(),
        buildArtifactsPath: '/mock/artifacts/$fileName',
        buildLogs: 'Compressed successfully to ${mockCompressedBytes.lengthInBytes} bytes.',
        buildDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

/// Main reusable component: InlineCompressedUploadModule
class InlineCompressedUploadModule extends StatefulWidget {
  final List<UploadFileItem> initialItems;
  final ValueChanged<UploadFileItem>? onFileProcessed;

  const InlineCompressedUploadModule({
    super.key,
    this.initialItems = const [],
    this.onFileProcessed,
  });

  @override
  State<InlineCompressedUploadModule> createState() => _InlineCompressedUploadModuleState();
}

class _InlineCompressedUploadModuleState extends State<InlineCompressedUploadModule> {
  late List<UploadFileItem> _items;
  final MockAssetProcessor _processor = MockAssetProcessor();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  Future<void> _simulateCaptureAndUpload() async {
    // Mock capturing an image
    final mockFileName = 'camera_capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final mockExtension = 'jpg';

    final processedItem = await _processor.processAndCompress(mockFileName, mockExtension);
    
    setState(() {
      _items.add(processedItem);
    });

    if (processedItem.hasError) {
      // Failed payload deliveries trigger immediate local error notices
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(processedItem.errorMessage ?? 'Upload failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      widget.onFileProcessed?.call(processedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document Uploads',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Position toggle switches/buttons along container right margins uniformly
              Switch(
                value: true,
                onChanged: (_) {},
                activeTrackColor: colorScheme.primary.withOpacity(0.5),
                activeColor: colorScheme.primary,
              ),
            ],
          ),
        ),
        // Limit thumbnail card layouts to a single swipeable row on compact mobile devices
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _items.length + 1, // +1 for the add button
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _buildAddButton(theme);
              }
              return _buildThumbnailCard(_items[index], theme, colorScheme);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return InkWell(
      onTap: _simulateCaptureAndUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          // Apply crisp, low-intensity outline borders to separate file containers from backend canvas layers
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.0, // Strict thickness rules for comfortable element presence
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: theme.colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildThumbnailCard(UploadFileItem item, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.hasError ? colorScheme.error : colorScheme.outlineVariant,
          width: 1.0,
        ),
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.compressedBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              // In production, use Image.memory(item.compressedBytes!)
              child: Center(
                child: Icon(Icons.image, color: colorScheme.primary, size: 40),
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0, // Route background progress indicators tightly to primary system color token definitions
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          if (item.hasError)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 20,
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                color: colorScheme.scrim.withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Text(
                item.metadata.buildStatus,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
