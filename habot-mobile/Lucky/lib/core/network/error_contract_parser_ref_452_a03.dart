// REF-452-A03 — HTTP 422 UI Error Contract Parser.
// Parses 422 validation error responses into structured field-level errors, strips sensitive backend traces, and provides Material 3 compliant inline error mapping.

import 'dart:convert';

/// Represents a single field-level validation error parsed from an HTTP 422 response.
class FieldValidationError {
  final String fieldName;
  final String message;

  const FieldValidationError({
    required this.fieldName,
    required this.message,
  });

  @override
  String toString() => 'FieldValidationError(field: $fieldName, message: $message)';
}

/// Result of parsing an HTTP 422 error contract.
class Http422ErrorContract {
  final List<FieldValidationError> fieldErrors;
  final String? globalMessage;

  const Http422ErrorContract({
    required this.fieldErrors,
    this.globalMessage,
  });

  bool get hasErrors => fieldErrors.isNotEmpty;

  /// Returns the first error message for a specific field, or null if none exists.
  String? errorForField(String fieldName) {
    for (final error in fieldErrors) {
      if (error.fieldName == fieldName) {
        return error.message;
      }
    }
    return null;
  }

  /// Returns all error messages for a specific field.
  List<String> errorsForField(String fieldName) {
    return fieldErrors
        .where((e) => e.fieldName == fieldName)
        .map((e) => e.message)
        .toList();
  }
}

/// Service responsible for initializing and executing HTTP 422 Error Contract parsing.
/// Strips database stack traces and infrastructure parameters to protect backend structures.
class ErrorContractParserService {
  ErrorContractParserService._internal();
  static final ErrorContractParserService _instance = ErrorContractParserService._internal();
  factory ErrorContractParserService() => _instance;

  bool _isInitialized = false;
  int _initTimeMs = 0;

  /// Initializes the parser service. Tracks initialization time against optimal targets.
  /// Floor Boundary: 20ms, Optimal Target: 5ms, Ceiling Boundary: 1ms.
  void initialize() {
    if (_isInitialized) return;
    final stopwatch = Stopwatch()..start();
    
    // Perform any pre-computation or configuration loading here
    _isInitialized = true;
    
    stopwatch.stop();
    _initTimeMs = stopwatch.elapsedMilliseconds;
  }

  /// Returns the service initialization time in milliseconds.
  int get initTimeMs => _initTimeMs;

  /// Evaluates if the initialization meets the qualitative Pass/Fail metric.
  /// Pass if under floor boundary (20ms).
  String get initMetricStatus => _initTimeMs <= 20 ? 'Pass' : 'Fail';

  /// Parses raw HTTP 422 response body into a sanitized [Http422ErrorContract].
  /// Automatically strips stack traces, internal paths, and infrastructure data.
  Http422ErrorContract parse(String responseBody) {
    if (!_isInitialized) {
      initialize();
    }

    try {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        return const Http422ErrorContract(
          fieldErrors: [],
          globalMessage: 'Invalid error format received.',
        );
      }

      final sanitizedData = _sanitizePayload(decoded);
      final List<FieldValidationError> errors = [];
      String? globalMessage;

      // Standard Laravel/Node 422 structure: { "message": "...", "errors": { "field": ["msg"] } }
      if (sanitizedData.containsKey('errors') && sanitizedData['errors'] is Map) {
        final Map<String, dynamic> errorsMap = sanitizedData['errors'] as Map<String, dynamic>;
        errorsMap.forEach((key, value) {
          if (value is List) {
            for (final msg in value) {
              if (msg is String) {
                errors.add(FieldValidationError(
                  fieldName: key,
                  message: _sanitizeMessage(msg),
                ));
              }
            }
          } else if (value is String) {
            errors.add(FieldValidationError(
              fieldName: key,
              message: _sanitizeMessage(value),
            ));
          }
        });
      }

      // Fallback for flat list structure: [{ "field": "name", "message": "required" }]
      if (errors.isEmpty && sanitizedData.containsKey('data') && sanitizedData['data'] is List) {
        final List<dynamic> dataList = sanitizedData['data'] as List<dynamic>;
        for (final item in dataList) {
          if (item is Map<String, dynamic> && item.containsKey('field') && item.containsKey('message')) {
            errors.add(FieldValidationError(
              fieldName: item['field'].toString(),
              message: _sanitizeMessage(item['message'].toString()),
            ));
          }
        }
      }

      if (sanitizedData.containsKey('message') && sanitizedData['message'] is String) {
        globalMessage = _sanitizeMessage(sanitizedData['message'] as String);
      }

      return Http422ErrorContract(
        fieldErrors: errors,
        globalMessage: globalMessage,
      );
    } catch (_) {
      // Poka-Yoke: Prevent JSON parsing crashes from leaking to UI
      return const Http422ErrorContract(
        fieldErrors: [],
        globalMessage: 'Unable to process validation response.',
      );
    }
  }

  /// Strips database stack traces, file paths, and infrastructure parameters.
  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> sanitized = {};
    final blockedKeys = {'stack_trace', 'stackTrace', 'trace', 'exception', 'file', 'line', 'sql', 'query', 'debug'};

    payload.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (blockedKeys.contains(lowerKey)) {
        return; // Wipe database stack traces to protect infrastructure parameters
      }
      if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizePayload(value);
      } else if (value is List) {
        sanitized[key] = value.map((e) => e is Map<String, dynamic> ? _sanitizePayload(e) : e).toList();
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Sanitizes individual error messages to remove internal references.
  String _sanitizeMessage(String message) {
    // Remove potential file paths or internal class names
    String sanitized = message.replaceAll(RegExp(r'[A-Za-z]:\\[\w\\.-]+'), '');
    sanitized = sanitized.replaceAll(RegExp(r'(\/([\w.-]+)+\.\w+)'), '');
    sanitized = sanitized.trim();
    return sanitized.isEmpty ? 'Validation failed.' : sanitized;
  }
}

// --- MOCK DATA FOR LOCAL TESTING & DEVELOPMENT ---

/// Mock HTTP 422 response simulating a standard REST API validation failure.
const String mockHttp422Response = '''
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email must be a valid email address."
    ],
    "password": [
      "The password must be at least 8 characters.",
      "The password must contain at least one uppercase letter."
    ],
    "phone": [
      "The phone format is invalid."
    ]
  },
  "stack_trace": "at com.app.controllers.UserController.store(UserController.java:42)",
  "debug": { "db_query": "SELECT * FROM users WHERE email='test'" }
}
''';

/// Mock HTTP 422 response simulating a flat array structure.
const String mockHttp422FlatResponse = '''
{
  "message": "Validation Error",
  "data": [
    { "field": "username", "message": "Username is already taken." },
    { "field": "age", "message": "Age must be a positive integer." }
  ],
  "exception": "App\\Exceptions\\ValidationException"
}
''';

/// Utility to demonstrate the parser usage with mock data.
void runErrorContractParserDemo() {
  final parser = ErrorContractParserService();
  parser.initialize();

  print('--- ErrorContractParserService Demo ---');
  print('Init Time: \${parser.initTimeMs}ms | Status: \${parser.initMetricStatus}');

  final contract1 = parser.parse(mockHttp422Response);
  print('\nParsed Standard Response:');
  print('Global Message: \${contract1.globalMessage}');
  print('Email Error: \${contract1.errorForField('email')}');
  print('Password Errors: \${contract1.errorsForField('password')}');
  print('Total Field Errors: \${contract1.fieldErrors.length}');

  final contract2 = parser.parse(mockHttp422FlatResponse);
  print('\nParsed Flat Response:');
  print('Username Error: \${contract2.errorForField('username')}');
  print('Total Field Errors: \${contract2.fieldErrors.length}');
}
