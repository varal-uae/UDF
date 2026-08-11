/// Shared harness for the AISS gates.
///
/// `flutter test` runs each test file in its own isolate, so there is no shared
/// in-memory state between gate files. Each file therefore writes its own
/// evidence record to `build/aiss/<atomic-step-id>.json`; `tool/verify_aiss.sh`
/// merges them into `build/aiss/evidence.json` after the run.
///
/// The point of writing files at all: every run leaves a durable, diffable
/// artefact showing which gates ran and what they concluded, rather than a
/// terminal buffer that scrolls away.
library;

import 'dart:convert';
import 'dart:io';

import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';

class AissReporter {
  AissReporter._();

  static const String outputDirectory = 'build/aiss';

  /// Record and immediately persist. Call from `tearDownAll`.
  static void record(AissEvidence evidence) {
    final String json = const JsonEncoder.withIndent(
      '  ',
    ).convert(evidence.toJson());

    // Always echo, so the evidence is visible even where the filesystem is
    // read-only (some CI sandboxes).
    stdout
      ..writeln('--- AISS EVIDENCE ${evidence.atomicStepReferenceId} '
          '(${evidence.outcome.label}, '
          '${evidence.gates.length - evidence.failedGates.length}'
          '/${evidence.gates.length} gates passed, '
          '${evidence.deferredGates.length} deferred, '
          '${evidence.brokenGates.length} broken) ---')
      ..writeln(json);

    try {
      final Directory dir = Directory(outputDirectory);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      File(
        '$outputDirectory/${evidence.atomicStepReferenceId}.json',
      ).writeAsStringSync(json);
    } on FileSystemException catch (e) {
      stderr.writeln('AISS: could not write evidence file ($e)');
    }
  }
}
