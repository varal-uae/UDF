/// AISS: ERMWD-031-01-A01 -- "Implement the frontend logic mapping FAILED
/// MOBILE BYT JSON PAYLOADS to the worker UI task cards. (Code the
/// deserialization logic that takes a raw mobile payload from the Pub/Sub DLQ
/// push endpoint and binds the variables precisely.)"
/// Setup Step Description: "Open the MTB API worker interface frontend
/// codebase in the development environment."
/// Metric: Process Adherence / Task Completion Rate -- Floor >= 90%,
///         Optimal 1.0, Ceiling 1.0.
///
/// A THIN ROW (21 of 49 columns), and the one populated data column is about
/// something else: Data Requirement reads "Frontend Technology; Framework
/// Version; Build Configuration; Performance Metrics; Build Output Path" --
/// build-tooling fields on a step whose whole purpose is a UI binding, with
/// four "N/A." entries where the mobile UX configuration should be. Not gated.
/// The Setup Step itself is specific and is what the gates defend.
///
/// WHAT A FAILED PAYLOAD IS. These arrive from a dead-letter queue: they are
/// the tasks that already went wrong once. So the deserialiser's job is not to
/// be optimistic. Every field is checked, every rejection carries a reason, and
/// a payload that cannot be bound produces a RECORDED DEFECT rather than a task
/// card with empty text in it -- a blank card is how a worker ends up guessing,
/// which is the one outcome Step 81's isolation rule exists to prevent.
///
/// The binding is total in one direction: every payload produces either a task
/// or a defect, never nothing. `boundRate` is the metric, and its denominator
/// includes the rejections.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'byt_isolation.dart';

/// Why a payload could not become a task.
///
/// Named `HabotBytDefect` rather than `HabotPayloadDefect` because Step 67
/// already owns that name for notification payloads. Two different payload
/// vocabularies with one name is how the wrong enum gets imported.
enum HabotBytDefect {
  /// The envelope was not JSON, or not a JSON object.
  malformedJson,

  /// A required field is missing or empty.
  missingField,

  /// A field is present but of the wrong type -- a string where a number
  /// belongs, usually.
  wrongType,

  /// The bounding box is not a rectangle inside its source.
  invalidBox,

  /// The asset is not a crop of the box, or is a source document.
  uncroppedAsset,

  /// The same task id arrived twice.
  duplicate,
}

/// One rejection, with enough detail to fix the sender.
@immutable
class HabotPayloadRejection {
  const HabotPayloadRejection({
    required this.id,
    required this.defect,
    required this.detail,
  });

  /// The id if the payload carried a usable one; otherwise '(unknown)'.
  final String id;
  final HabotBytDefect defect;
  final String detail;

  @override
  String toString() => '$id: ${defect.name} -- $detail';
}

/// The result of binding one payload.
@immutable
class HabotBindingResult {
  const HabotBindingResult.bound(this.task) : rejection = null;
  const HabotBindingResult.rejected(this.rejection) : task = null;

  final HabotByt? task;
  final HabotPayloadRejection? rejection;

  bool get isBound => task != null;
}

/// The deserialiser.
///
/// Static and pure: a payload in, a task or a rejection out. Nothing here
/// touches a widget, which is what lets every malformed shape be tested
/// exhaustively instead of through a screen.
class HabotTaskBinder {
  HabotTaskBinder();

  final Set<String> _seen = <String>{};
  final List<HabotPayloadRejection> _rejections = <HabotPayloadRejection>[];
  int _received = 0;
  int _bound = 0;

  List<HabotPayloadRejection> get rejections =>
      List<HabotPayloadRejection>.unmodifiable(_rejections);

  int get receivedCount => _received;
  int get boundCount => _bound;
  int get rejectedCount => _rejections.length;

  /// Metric: Process Adherence / Task Completion Rate. The share of received
  /// payloads that became a task. Rejections stay in the denominator, so the
  /// rate cannot be improved by quietly dropping the difficult ones.
  double get boundRate => _received == 0 ? 1 : _bound / _received;

  /// Every payload is accounted for: bound or rejected, never lost.
  bool get isTotal => _bound + _rejections.length == _received;

  /// Binds a raw JSON envelope, exactly as it arrives from the DLQ push.
  HabotBindingResult bindRaw(String raw) {
    _received++;
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return _reject(
        '(unknown)',
        HabotBytDefect.malformedJson,
        'payload is not valid JSON',
      );
    }
    if (decoded is! Map<String, Object?>) {
      return _reject(
        '(unknown)',
        HabotBytDefect.malformedJson,
        'payload is not a JSON object',
      );
    }
    return _bind(decoded);
  }

  /// Binds an already-decoded envelope.
  HabotBindingResult bind(Map<String, Object?> payload) {
    _received++;
    return _bind(payload);
  }

  HabotBindingResult _bind(Map<String, Object?> payload) {
    final Object? rawId = payload['id'];
    if (rawId is! String || rawId.isEmpty) {
      return _reject(
        '(unknown)',
        HabotBytDefect.missingField,
        'id is missing or empty',
      );
    }
    final String id = rawId;
    if (!_seen.add(id)) {
      return _reject(
        id,
        HabotBytDefect.duplicate,
        'a task with this id has already been bound',
      );
    }

    final Object? prompt = payload['prompt'];
    if (prompt is! String || prompt.isEmpty) {
      return _reject(
        id,
        HabotBytDefect.missingField,
        'prompt is missing or empty -- a task with no question is not a task',
      );
    }
    final Object? format = payload['expectedFormat'];
    if (format is! String || format.isEmpty) {
      return _reject(
        id,
        HabotBytDefect.missingField,
        'expectedFormat is missing',
      );
    }

    final Object? rawBox = payload['box'];
    if (rawBox is! Map<String, Object?>) {
      return _reject(
        id,
        HabotBytDefect.missingField,
        'box is missing',
      );
    }
    final List<String> numericKeys = <String>[
      'left',
      'top',
      'width',
      'height',
      'sourceWidth',
      'sourceHeight',
    ];
    final Map<String, double> values = <String, double>{};
    for (final String key in numericKeys) {
      final Object? value = rawBox[key];
      if (value is num) {
        values[key] = value.toDouble();
        continue;
      }
      return _reject(
        id,
        value == null
            ? HabotBytDefect.missingField
            : HabotBytDefect.wrongType,
        'box.$key is ${value == null ? 'missing' : 'not a number'}',
      );
    }
    final HabotBoundingBox box = HabotBoundingBox(
      left: values['left']!,
      top: values['top']!,
      width: values['width']!,
      height: values['height']!,
      sourceWidth: values['sourceWidth']!,
      sourceHeight: values['sourceHeight']!,
    );

    final Object? rawSnippet = payload['snippet'];
    if (rawSnippet is! String || rawSnippet.isEmpty) {
      return _reject(
        id,
        HabotBytDefect.missingField,
        'snippet is missing',
      );
    }
    final Uri? snippet = Uri.tryParse(rawSnippet);
    if (snippet == null) {
      return _reject(
        id,
        HabotBytDefect.wrongType,
        'snippet is not a URI',
      );
    }

    final HabotCropRefusal? refusal = HabotByt.refusalFor(
      box: box,
      snippet: snippet,
    );
    if (refusal != null) {
      return _reject(
        id,
        refusal == HabotCropRefusal.invalidBox ||
                refusal == HabotCropRefusal.wholeDocument
            ? HabotBytDefect.invalidBox
            : HabotBytDefect.uncroppedAsset,
        'crop refused: ${refusal.name}',
      );
    }

    final HabotByt? task = HabotByt.fromDelivery(
      id: id,
      box: box,
      snippet: snippet,
      prompt: prompt,
      expectedFormat: format,
    );
    if (task == null) {
      // Unreachable in practice -- every refusal is caught above -- but a
      // deserialiser that assumed that would be a deserialiser with a hole.
      return _reject(
        id,
        HabotBytDefect.uncroppedAsset,
        'delivery refused after validation',
      );
    }
    _bound++;
    return HabotBindingResult.bound(task);
  }

  HabotBindingResult _reject(
    String id,
    HabotBytDefect defect,
    String detail,
  ) {
    final HabotPayloadRejection rejection = HabotPayloadRejection(
      id: id,
      defect: defect,
      detail: detail,
    );
    _rejections.add(rejection);
    return HabotBindingResult.rejected(rejection);
  }
}
