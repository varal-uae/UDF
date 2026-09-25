// SCTSS-016-A05 — Dynamic Geo-Location Routing Form Widget.
// Conditionally renders localized compliance fields based on upstream country selection, removing non-applicable fields from the widget tree and highlighting mismatched data when the region changes mid-form.

import 'package:flutter/material.dart';

/// Mock locale-specific compliance field definitions.
/// In production, this would be fetched from a backend or BigQuery event stream.
const Map<String, List<Map<String, dynamic>>> _mockGeoComplianceFields = {
  'AE': [
    {'id': 'emirates_id', 'label': 'Emirates ID Number', 'type': 'text'},
    {'id': 'trade_license', 'label': 'Trade License Number', 'type': 'text'},
  ],
  'US': [
    {'id': 'ssn_last4', 'label': 'Last 4 digits of SSN', 'type': 'number'},
    {'id': 'ein', 'label': 'Employer Identification Number (EIN)', 'type': 'text'},
  ],
  'GB': [
    {'id': 'utr', 'label': 'Unique Taxpayer Reference (UTR)', 'type': 'text'},
    {'id': 'ni_number', 'label': 'National Insurance Number', 'type': 'text'},
  ],
};

/// Data class representing the execution telemetry required by the spec.
class StepExecutionData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

class DynamicGeoLocationForm extends StatefulWidget {
  const DynamicGeoLocationForm({super.key});

  @override
  State<DynamicGeoLocationForm> createState() => _DynamicGeoLocationFormState();
}

class _DynamicGeoLocationFormState extends State<DynamicGeoLocationForm> {
  String? _selectedCountryCode;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _mismatchedFields = {};
  final Set<String> _touchedFieldIds = {};

  final List<String> _supportedCountries = ['AE', 'US', 'GB'];

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCountryChanged(String? newCountryCode) {
    if (newCountryCode == null || newCountryCode == _selectedCountryCode) return;

    setState(() {
      // Self-chasing logic: if changing country mid-form, highlight previously entered mismatched data
      if (_selectedCountryCode != null && _touchedFieldIds.isNotEmpty) {
        final oldFields = _mockGeoComplianceFields[_selectedCountryCode] ?? [];
        for (final field in oldFields) {
          final fieldId = field['id'] as String;
          if (_touchedFieldIds.contains(fieldId) && (_controllers[fieldId]?.text.isNotEmpty ?? false)) {
            _mismatchedFields[fieldId] = true;
          }
        }
      }

      _selectedCountryCode = newCountryCode;

      // Poka-Yoke: Dependent fields remain completely removed from the DOM until parent region is confirmed.
      // We clear controllers for fields not present in the new schema to prevent stale state.
      final newFields = _mockGeoComplianceFields[newCountryCode] ?? [];
      final newFieldIds = newFields.map((e) => e['id'] as String).toSet();
      
      _controllers.removeWhere((key, value) {
        if (!newFieldIds.contains(key)) {
          value.clear();
          _touchedFieldIds.remove(key);
          _mismatchedFields.remove(key);
          return true;
        }
        return false;
      });

      // Log telemetry mock
      _logTelemetry(newCountryCode);
    });
  }

  void _logTelemetry(String countryCode) {
    // Silent parameter extraction / Telemetry logging
    final telemetry = StepExecutionData(
      stepExecutionId: 'SCTSS-016-A05-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: 'SUCCESS',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'ROUTED_TO_$countryCode',
      userId: 'MOCK_USER_001',
    );
    debugPrint('Telemetry: ${telemetry.stepExecutionId} | ${telemetry.stepOutcome}');
  }

  void _clearMismatch(String fieldId) {
    if (_mismatchedFields[fieldId] == true) {
      setState(() {
        _mismatchedFields[fieldId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fields = _selectedCountryCode != null
        ? (_mockGeoComplianceFields[_selectedCountryCode] ?? [])
        : <Map<String, dynamic>>[];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Geo-Location Routing',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your region to view applicable compliance fields.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            decoration: InputDecoration(
              labelText: 'Country / Region',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.public),
            ),
            items: _supportedCountries.map((code) {
              return DropdownMenuItem(value: code, child: Text(code));
            }).toList(),
            onChanged: _onCountryChanged,
          ),
          const SizedBox(height: 32),
          // Conditional rendering: Only builds widgets for the active region.
          // Non-applicable fields are aggressively hidden (removed from tree).
          ...fields.map((fieldDef) {
            final fieldId = fieldDef['id'] as String;
            final label = fieldDef['label'] as String;
            final type = fieldDef['type'] as String;
            final isMismatched = _mismatchedFields[fieldId] == true;

            _controllers.putIfAbsent(fieldId, () => TextEditingController());

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: _controllers[fieldId],
                keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: isMismatched ? 'Region changed. Please update or clear this field.' : null,
                  errorStyle: TextStyle(color: colorScheme.error),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                ),
                onChanged: (value) {
                  _touchedFieldIds.add(fieldId);
                  if (value.isNotEmpty) {
                    _clearMismatch(fieldId);
                  }
                },
              ),
            );
          }),
          if (_selectedCountryCode != null && fields.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No specific compliance fields required for this region.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
