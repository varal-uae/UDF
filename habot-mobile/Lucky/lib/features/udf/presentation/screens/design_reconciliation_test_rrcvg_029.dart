// RRCVG-029 — Design Reconciliation Test Screen with Task Identification Input.
// Implements three task ID inputs, validation with red error highlighting, blocked progression until valid, and mock reconciliation execution.

import 'package:flutter/material.dart';

// --- Mock Data & Models ---

class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome,
        'User ID': userId,
        'Completion Status': completionStatus,
      };
}

class MockReconciliationRepository {
  static Future<StepExecutionRecord> executeDesignReconciliationTest({
    required List<String> taskIds,
    required String userId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return StepExecutionRecord(
      stepExecutionId: 'EXEC-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: 'Completed',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'Pass',
      userId: userId,
      completionStatus: 'Pass/Fail',
    );
  }
}

// --- Validators ---

class TaskIdValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task identification is required.';
    }
    if (!RegExp(r'^[A-Za-z0-9\-]{3,}$').hasMatch(value.trim())) {
      return 'Invalid task identification format.';
    }
    return null;
  }
}

// --- UI Implementation ---

class DesignReconciliationTestScreen extends StatefulWidget {
  const DesignReconciliationTestScreen({super.key});

  @override
  State<DesignReconciliationTestScreen> createState() => _DesignReconciliationTestScreenState();
}

class _DesignReconciliationTestScreenState extends State<DesignReconciliationTestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _taskId1Controller = TextEditingController();
  final TextEditingController _taskId2Controller = TextEditingController();
  final TextEditingController _taskId3Controller = TextEditingController();

  bool _isExecuting = false;
  StepExecutionRecord? _lastResult;

  // AISS Rule: Permanently disable the "Release to Tech" button if the score != 0.
  int _reconciliationScore = 0; // Mock score

  @override
  void dispose() {
    _taskId1Controller.dispose();
    _taskId2Controller.dispose();
    _taskId3Controller.dispose();
    super.dispose();
  }

  bool get _areAllTasksValid {
    return TaskIdValidator.validate(_taskId1Controller.text) == null &&
        TaskIdValidator.validate(_taskId2Controller.text) == null &&
        TaskIdValidator.validate(_taskId3Controller.text) == null;
  }

  Future<void> _executeTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isExecuting = true;
    });

    try {
      final result = await MockReconciliationRepository.executeDesignReconciliationTest(
        taskIds: [
          _taskId1Controller.text.trim(),
          _taskId2Controller.text.trim(),
          _taskId3Controller.text.trim(),
        ],
        userId: 'MOCK_USER_REGIONAL_MGR_01',
      );

      setState(() {
        _lastResult = result;
        _reconciliationScore = result.stepOutcome == 'Pass' ? 0 : 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isExecuting = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Reconciliation Test'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter exactly three task identifications:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taskId1Controller,
                decoration: _buildInputDecoration('Task Identification 1'),
                validator: TaskIdValidator.validate,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taskId2Controller,
                decoration: _buildInputDecoration('Task Identification 2'),
                validator: TaskIdValidator.validate,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taskId3Controller,
                decoration: _buildInputDecoration('Task Identification 3'),
                validator: TaskIdValidator.validate,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: (_areAllTasksValid && !_isExecuting) ? _executeTest : null,
                icon: _isExecuting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isExecuting ? 'Verifying...' : 'Execute Verification Queries'),
              ),
              const SizedBox(height: 24),
              if (_lastResult != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Execution ID: ${_lastResult!.stepExecutionId}'),
                        Text('Status: ${_lastResult!.executionStatus}'),
                        Text('Outcome: ${_lastResult!.stepOutcome}'),
                        Text('Timestamp: ${_lastResult!.executionTimestamp.toIso8601String()}'),
                        Text('User ID: ${_lastResult!.userId}'),
                        const Divider(),
                        Text(
                          'Qualitative Output: ${_lastResult!.completionStatus}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _lastResult!.stepOutcome == 'Pass' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _reconciliationScore == 0 && _lastResult != null ? () {} : null,
                child: const Text('Release to Tech'),
              ),
              if (_reconciliationScore != 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Release to Tech is disabled because reconciliation score != 0.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
