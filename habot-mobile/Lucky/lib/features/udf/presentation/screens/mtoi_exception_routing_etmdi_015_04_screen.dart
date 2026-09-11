// ETMDI-015-04 — MTOI Exception Routing Wizard for UDF.
// Implements a single-purpose, mobile-first multi-step wizard that captures, validates, masks, and serializes MTOI exception payloads with Material 3 and WCAG 2.1 AA-aligned touch targets.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MtoiExceptionPayload {
  const MtoiExceptionPayload({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionEventTimestamp,
    required this.userSessionId,
  });

  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final DateTime actionEventTimestamp;
  final String userSessionId;

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'completionStatus': completionStatus,
        'actionEventTimestamp': actionEventTimestamp.toIso8601String(),
        'userSessionId': userSessionId,
      };
}

class MtoiExceptionRoutingEtmdi01504Screen extends StatefulWidget {
  const MtoiExceptionRoutingEtmdi01504Screen({super.key, this.onSubmitted});

  final ValueChanged<String>? onSubmitted;

  @override
  State<MtoiExceptionRoutingEtmdi01504Screen> createState() =>
      _MtoiExceptionRoutingEtmdi01504ScreenState();
}

class _MtoiExceptionRoutingEtmdi01504ScreenState
    extends State<MtoiExceptionRoutingEtmdi01504Screen> {
  static const _totalSteps = 3;

  final _formKeys = List<GlobalKey<FormState>>.generate(
    _totalSteps,
    (_) => GlobalKey<FormState>(),
  );

  final _stepExecutionIdController = TextEditingController();
  final _executionTimestampController = TextEditingController();
  final _stepOutcomeController = TextEditingController();
  final _userIdController = TextEditingController();
  final _userSessionIdController = TextEditingController();

  int _currentStep = 0;
  String? _executionStatus;
  String? _completionStatus;

  @override
  void dispose() {
    _stepExecutionIdController.dispose();
    _executionTimestampController.dispose();
    _stepOutcomeController.dispose();
    _userIdController.dispose();
    _userSessionIdController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    return _formKeys[_currentStep].currentState?.validate() ?? false;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submit() async {
    final allValid = _formKeys.every(
      (key) => key.currentState?.validate() ?? false,
    );
    if (!allValid) return;

    final payload = MtoiExceptionPayload(
      stepExecutionId: _stepExecutionIdController.text.trim().toUpperCase(),
      executionStatus: _executionStatus!,
      executionTimestamp: DateTime.parse(_executionTimestampController.text.trim()),
      stepOutcome: _stepOutcomeController.text.trim(),
      userId: _userIdController.text.trim(),
      completionStatus: _completionStatus!,
      actionEventTimestamp: DateTime.now(),
      userSessionId: _userSessionIdController.text.trim(),
    );

    final serialized = jsonEncode(payload.toJson());
    widget.onSubmitted?.call(serialized);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MTOI exception serialized'),
        content: SingleChildScrollView(
          child: SelectableText(serialized),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTOI Exception Routing'),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of $_totalSteps',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Wizard progress',
                    value: '${(progress * 100).round()} percent',
                    child: LinearProgressIndicator(value: progress),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildIdentityStep(theme),
                  _buildTimingStep(theme),
                  _buildReviewStep(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          _currentStep == _totalSteps - 1 ? _submit : _next,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(
                        _currentStep == _totalSteps - 1 ? 'Submit' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityStep(ThemeData theme) {
    return Form(
      key: _formKeys[0],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Exception identity', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Semantics(
            textField: true,
            label: 'Step Execution ID, 12 character masked identifier',
            child: TextFormField(
              controller: _stepExecutionIdController,
              decoration: const InputDecoration(
                labelText: 'Step Execution ID',
                hintText: 'ETMDI-015-04',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.visiblePassword,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                LengthLimitingTextInputFormatter(12),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) => newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  ),
                ),
              ],
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Step Execution ID is required';
                if (text.length < 8) return 'Use at least 8 characters';
                if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(text)) {
                  return 'Use uppercase letters, numbers, and hyphen only';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _executionStatus,
            decoration: const InputDecoration(
              labelText: 'Execution Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
              DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In progress')),
              DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved')),
              DropdownMenuItem(value: 'ESCALATED', child: Text('Escalated')),
              DropdownMenuItem(value: 'FAILED', child: Text('Failed')),
            ],
            onChanged: (value) => setState(() => _executionStatus = value),
            validator: (value) =>
                value == null ? 'Execution Status is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingStep(ThemeData theme) {
    return Form(
      key: _formKeys[1],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Timing and outcome', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Semantics(
            textField: true,
            label: 'Execution Timestamp, ISO 8601 format',
            child: TextFormField(
              controller: _executionTimestampController,
              decoration: const InputDecoration(
                labelText: 'Execution Timestamp',
                hintText: '2026-09-11T14:30',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9T:-]')),
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Execution Timestamp is required';
                final parsed = DateTime.tryParse(text);
                if (parsed == null) return 'Use ISO 8601, e.g. 2026-09-11T14:30';
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _stepOutcomeController,
            decoration: const InputDecoration(
              labelText: 'Step Outcome',
              hintText: 'Describe the exception routing outcome',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            inputFormatters: [
              LengthLimitingTextInputFormatter(240),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Step Outcome is required';
              if (text.length < 10) return 'Provide at least 10 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _completionStatus,
            decoration: const InputDecoration(
              labelText: 'Completion Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Good', child: Text('Good')),
              DropdownMenuItem(value: 'Average', child: Text('Average')),
              DropdownMenuItem(value: 'Poor', child: Text('Poor')),
            ],
            onChanged: (value) => setState(() => _completionStatus = value),
            validator: (value) =>
                value == null ? 'Completion Status is required' : null,
          ),
          const SizedBox(height: 8),
          Text(
            'Target: Good (<=15 min). SLA: 95% resolved within 30 minutes.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Form(
      key: _formKeys[2],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('User context and review', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'User ID is required';
              if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(text)) {
                return 'Use letters and numbers only';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _userSessionIdController,
            decoration: const InputDecoration(
              labelText: 'User / Session ID',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              LengthLimitingTextInputFormatter(32),
            ],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'User / Session ID is required';
              if (text.length < 6) return 'Use at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review summary', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _summaryRow('Step Execution ID', _stepExecutionIdController.text),
                  _summaryRow('Execution Status', _executionStatus ?? ''),
                  _summaryRow('Execution Timestamp', _executionTimestampController.text),
                  _summaryRow('Step Outcome', _stepOutcomeController.text),
                  _summaryRow('User ID', _userIdController.text),
                  _summaryRow('Completion Status', _completionStatus ?? ''),
                  _summaryRow('User / Session ID', _userSessionIdController.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
        ],
      ),
    );
  }
}
