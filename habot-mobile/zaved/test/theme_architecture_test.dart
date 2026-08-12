import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DCYN Binary Semantic Color Gate (Architecture Test)', () {
    final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');
    final materialColorsRegex = RegExp(r'\bColors\.[a-zA-Z0-9_]+');

    test('All files in lib/ui/ must strictly use theme indirection and no raw hex or material colors', () {
      final uiDir = Directory('lib/ui');

      if (!uiDir.existsSync()) {
        fail('Directory "lib/ui" does not exist.');
      }

      final dartFiles = uiDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      final violations = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();

        final hexMatches = hexColorRegex.allMatches(content);
        for (final match in hexMatches) {
          violations.add(
            '   - ${file.path}: Found raw hex color "${match.group(0)}"',
          );
        }

        final materialMatches = materialColorsRegex.allMatches(content);
        for (final match in materialMatches) {
          violations.add(
            '   - ${file.path}: Found standard Material color "${match.group(0)}"',
          );
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'ARCHITECTURAL BLOCKER TRIGGERED!\n'
          'Raw style choices are disabled. You must use the SemanticStatusColors theme extension.\n\n'
          'Violations detected:\n'
          '${violations.join('\n')}\n',
        );
      }
    });
  });
}
