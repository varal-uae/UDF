import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// MUFCE-020-A01 — Document crop sheet.
// MD3 modal bottom sheet for trimming image documents before ingestion.
// Uses dart:ui only — no external crop package required.

/// Normalized crop region (0.0–1.0 relative to image dimensions).
class CropRegion {
  const CropRegion({
    this.left = 0.05,
    this.top = 0.05,
    this.width = 0.9,
    this.height = 0.9,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  CropRegion copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    return CropRegion(
      left:   left   ?? this.left,
      top:    top    ?? this.top,
      width:  width  ?? this.width,
      height: height ?? this.height,
    );
  }
}

abstract class DocumentCropSheet {
  /// Opens crop UI. Returns path to cropped PNG temp file, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String imagePath,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _DocumentCropSheetBody(imagePath: imagePath),
    );
  }

  /// Crops [sourcePath] to [region] and writes PNG to a temp file.
  static Future<String?> applyCrop({
    required String sourcePath,
    required CropRegion region,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final srcLeft   = (region.left * image.width).round();
    final srcTop    = (region.top * image.height).round();
    final srcWidth  = (region.width * image.width).round().clamp(1, image.width);
    final srcHeight = (region.height * image.height).round().clamp(1, image.height);

    final recorder = ui.PictureRecorder();
    final canvas   = Canvas(recorder);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        srcLeft.toDouble(),
        srcTop.toDouble(),
        srcWidth.toDouble(),
        srcHeight.toDouble(),
      ),
      Rect.fromLTWH(0, 0, srcWidth.toDouble(), srcHeight.toDouble()),
      Paint(),
    );

    final picture  = recorder.endRecording();
    final cropped  = await picture.toImage(srcWidth, srcHeight);
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final outPath =
        '${Directory.systemTemp.path}/habot_crop_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
    return outPath;
  }
}

class _DocumentCropSheetBody extends StatefulWidget {
  const _DocumentCropSheetBody({required this.imagePath});

  final String imagePath;

  @override
  State<_DocumentCropSheetBody> createState() => _DocumentCropSheetBodyState();
}

class _DocumentCropSheetBodyState extends State<_DocumentCropSheetBody> {
  CropRegion _region = const CropRegion();
  bool _isSaving = false;

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    try {
      final out = await DocumentCropSheet.applyCrop(
        sourcePath: widget.imagePath,
        region: _region,
      );
      if (mounted) Navigator.of(context).pop(out);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Crop document',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the crop area, then apply.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _CropOverlayPainter(
                          region: _region,
                          borderColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text('Crop tightness', style: theme.textTheme.labelMedium),
            Slider(
              value: _region.width,
              min: 0.4,
              max: 1.0,
              onChanged: (v) {
                final inset = (1 - v) / 2;
                setState(() {
                  _region = CropRegion(
                    left: inset,
                    top: inset,
                    width: v,
                    height: v,
                  );
                });
              },
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _confirm,
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Apply crop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({required this.region, required this.borderColor});

  final CropRegion region;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTWH(
      region.left * size.width,
      region.top * size.height,
      region.width * size.width,
      region.height * size.height,
    );

    final dimPaint = Paint()..color = Colors.black.withOpacity(0.45);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(cropRect),
      ),
      dimPaint,
    );

    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, border);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.region != region || old.borderColor != borderColor;
}
