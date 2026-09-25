// RTVMA-009 — Inline Mobile Variance UI Auditor.
// Provides a Material 3 calendar-style date picker with inline numeric feedback, instant variance calculation (A-B != 0 abort), and secure connection trust indicators.

import 'package:flutter/material.dart';

/// Mock data representing source-to-target element mapping validation status.
class _MockMappingData {
  final String sourceElementId;
  final String targetElementId;
  final String mappingRule;
  final String mappingStatus;
  final bool mappingValidation;

  const _MockMappingData({
    required this.sourceElementId,
    required this.targetElementId,
    required this.mappingRule,
    required this.mappingStatus,
    required this.mappingValidation,
  });
}

const List<_MockMappingData> _mockMappings = [
  _MockMappingData(
    sourceElementId: 'SRC-001',
    targetElementId: 'TGT-001',
    mappingRule: 'EXACT_MATCH',
    mappingStatus: 'Complete',
    mappingValidation: true,
  ),
  _MockMappingData(
    sourceElementId: 'SRC-002',
    targetElementId: 'TGT-002',
    mappingRule: 'NUMERIC_DELTA',
    mappingStatus: 'Partial',
    mappingValidation: false,
  ),
];

class VarianceUiAuditorRtvma009 extends StatefulWidget {
  const VarianceUiAuditorRtvma009({super.key});

  @override
  State<VarianceUiAuditorRtvma009> createState() => _VarianceUiAuditorRtvma009State();
}

class _VarianceUiAuditorRtvma009State extends State<VarianceUiAuditorRtvma009> {
  final TextEditingController _inputAController = TextEditingController();
  final TextEditingController _inputBController = TextEditingController();
  DateTime? _selectedDate;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _isSecureConnection = true; // Mock TLS 1.3 secure state

  @override
  void dispose() {
    _inputAController.dispose();
    _inputBController.dispose();
    super.dispose();
  }

  void _evaluateVariance() {
    final double? a = double.tryParse(_inputAController.text);
    final double? b = double.tryParse(_inputBController.text);

    if (a == null || b == null) {
      setState(() {
        _feedbackMessage = 'Enter valid numeric values.';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    final double variance = a - b;

    setState(() {
      if (variance != 0) {
        // Instantly abort submission if A-B != 0
        _feedbackMessage = 'Variance detected: $variance. Submission aborted.';
        _feedbackColor = Colors.red;
      } else {
        _feedbackMessage = 'Variance is 0. Assured financial trust.';
        _feedbackColor = Colors.green;
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Immediate calculation feedback as dates are tapped
        _evaluateVariance();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inline Mobile Variance UI Auditor'),
        actions: [
          // Secure lock icons/trusted connections UX Translation
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _isSecureConnection ? Icons.lock : Icons.lock_open,
              color: _isSecureConnection ? Colors.green : Colors.red,
              semanticLabel: _isSecureConnection ? 'Secure Connection (TLS 1.3)' : 'Insecure Connection',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar & Numeric Input',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Calendar widget with inline numeric feedback
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _inputAController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value A (Source)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.looks_one),
                      ),
                      onChanged: (_) => _evaluateVariance(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inputBController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value B (Target)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.looks_two),
                      ),
                      onChanged: (_) => _evaluateVariance(),
                    ),
                    const SizedBox(height: 16),
                    // Immediate calculation feedback container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _feedbackColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _feedbackColor),
                      ),
                      child: Text(
                        _feedbackMessage.isEmpty ? 'Awaiting input...' : _feedbackMessage,
                        style: TextStyle(color: _feedbackColor, fontWeight: FontWeight.w500),
                        semanticsLabel: 'Calculation Feedback',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mapping Validation Status',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Transparent self-service UX for mappings
            ..._mockMappings.map((mapping) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  mapping.mappingValidation ? Icons.check_circle : Icons.error,
                  color: mapping.mappingValidation ? Colors.green : Colors.red,
                ),
                title: Text('${mapping.sourceElementId} → ${mapping.targetElementId}'),
                subtitle: Text('Rule: ${mapping.mappingRule} | Status: ${mapping.mappingStatus}'),
                trailing: Chip(
                  label: Text(mapping.mappingValidation ? 'Valid' : 'Invalid'),
                  backgroundColor: mapping.mappingValidation
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}