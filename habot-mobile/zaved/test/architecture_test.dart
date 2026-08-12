import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Universal SRC Architecture Blocker (Poka-Yoke)', () {
    /// Map of banned local imports to their mandatory Universal SRC equivalents
    const Map<String, String> bannedImportsMap = {
      'custom_button.dart': 'universal_src/buttons/src_button.dart',
      'status_badge.dart': 'universal_src/badges/src_badge.dart',
      'error_toast.dart': 'universal_src/toasts/src_toast.dart',
    };

    test('lib/ui/ files must not contain banned local imports', () {
      final uiDir = Directory('lib/ui');

      if (!uiDir.existsSync()) {
        fail('The directory "lib/ui" does not exist.');
      }

      final dartFiles = uiDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      final violations = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();

        bannedImportsMap.forEach((bannedImport, requiredSrc) {
          if (content.contains(bannedImport)) {
            violations.add(
              'File: ${file.path}\n'
              '   Banned Import Found: "$bannedImport"\n'
              '   Required Universal SRC: "$requiredSrc"',
            );
          }
        });
      }

      if (violations.isNotEmpty) {
        fail(
          'ARCHITECTURAL BLOCKER: Banned local imports detected in lib/ui/!\n'
          'To enforce component reuse and reduce binary size, developers MUST use Universal SRC registry components.\n\n'
          'Violations found:\n'
          '${violations.join('\n\n')}\n\n'
          'Action Required: Remove local imports and replace them with their respective Universal SRC equivalents.',
        );
      }
    });
  });
}
