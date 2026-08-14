import 'dart:developer' as developer;

// MUFCE-020-A01 — Upload audit telemetry dispatcher.
// Fires metadata to Pub/Sub → BigQuery on every successful ingestion event.
// Replace [_sendToPubSub] when backend provides the endpoint.

class UploadAuditTelemetry {
  UploadAuditTelemetry._();

  static Future<void> dispatch({
    required String fileName,
    required String extension,
    required String mimeType,
    required int sizeBytes,
    required String category,
    String? sessionId,
    String? userId,
  }) async {
    final payload = {
      'timestamp':   DateTime.now().toUtc().toIso8601String(),
      'event':       'document_ingestion_success',
      'file_name':   fileName,
      'extension':   extension,
      'mime_type':   mimeType,
      'size_bytes':  sizeBytes,
      'category':    category,
      'session_id':  sessionId,
      'user_id':     userId,
      'platform':    'mobile',
      'source':      'DocumentIngestionGateway',
    };

    developer.log(
      '[UploadAudit] ${payload['file_name']} (${payload['size_bytes']} bytes)',
      name: 'MUFCE-020',
    );

    await _sendToPubSub(payload);
  }

  static Future<void> dispatchRejection({
    required String fileName,
    required String reason,
    String? sessionId,
  }) async {
    final payload = {
      'timestamp':  DateTime.now().toUtc().toIso8601String(),
      'event':      'document_ingestion_rejected',
      'file_name':  fileName,
      'reason':     reason,
      'session_id': sessionId,
      'platform':   'mobile',
      'source':     'DocumentIngestionGateway',
    };

    developer.log(
      '[UploadAudit] REJECTED $fileName — $reason',
      name: 'MUFCE-020',
    );

    await _sendToPubSub(payload);
  }

  /// TODO: Replace with Pub/Sub HTTP client when backend is ready.
  static Future<void> _sendToPubSub(Map<String, dynamic> payload) async {
    // await http.post(
    //   Uri.parse('<PUBSUB_UPLOAD_AUDIT_ENDPOINT>'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'messages': [{'data': base64Encode(utf8.encode(jsonEncode(payload)))}]}),
    // );
  }
}
