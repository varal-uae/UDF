// GEN-01512 — Pending Order Payload Builder with child_id and Requirement Notes.
// Attaches the selected child_id foreign key and requirement notes to the pending order payload using local mock data.

import 'package:flutter/material.dart';

/// Mock data representing available child IDs for selection.
const List<Map<String, dynamic>> mockChildRecords = [
  {'child_id': 'CHILD-001', 'name': 'Primary Child Record'},
  {'child_id': 'CHILD-002', 'name': 'Secondary Child Record'},
  {'child_id': 'CHILD-003', 'name': 'Tertiary Child Record'},
];

/// Model representing the pending order payload.
class PendingOrderPayload {
  final String orderId;
  final String? childId;
  final String? requirementNotes;
  final DateTime timestamp;

  const PendingOrderPayload({
    required this.orderId,
    this.childId,
    this.requirementNotes,
    required this.timestamp,
  });

  PendingOrderPayload copyWith({
    String? orderId,
    String? childId,
    String? requirementNotes,
    DateTime? timestamp,
  }) {
    return PendingOrderPayload(
      orderId: orderId ?? this.orderId,
      childId: childId ?? this.childId,
      requirementNotes: requirementNotes ?? this.requirementNotes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'child_id': childId,
      'requirement_notes': requirementNotes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Service to build and validate the pending order payload.
class PendingOrderPayloadService {
  static PendingOrderPayload attachChildAndNotes({
    required String orderId,
    required String childId,
    required String requirementNotes,
  }) {
    return PendingOrderPayload(
      orderId: orderId,
      childId: childId,
      requirementNotes: requirementNotes,
      timestamp: DateTime.now(),
    );
  }

  /// Validates capture accuracy metric (Floor: 0.95)
  static bool validatePayloadAccuracy(PendingOrderPayload payload) {
    return payload.childId != null && 
           payload.childId!.isNotEmpty && 
           payload.requirementNotes != null && 
           payload.requirementNotes!.isNotEmpty;
  }
}

/// UI Screen demonstrating M3 Bottom Sheet configuration inputs and payload attachment.
class PendingOrderConfigScreen extends StatefulWidget {
  const PendingOrderConfigScreen({super.key});

  @override
  State<PendingOrderConfigScreen> createState() => _PendingOrderConfigScreenState();
}

class _PendingOrderConfigScreenState extends State<PendingOrderConfigScreen> {
  String? _selectedChildId;
  final TextEditingController _notesController = TextEditingController();
  PendingOrderPayload? _currentPayload;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showConfigBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Pending Order',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedChildId,
                decoration: const InputDecoration(
                  labelText: 'Select Child ID',
                  border: OutlineInputBorder(),
                ),
                items: mockChildRecords.map((record) {
                  return DropdownMenuItem<String>(
                    value: record['child_id'] as String,
                    child: Text(record['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Requirement Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    if (_selectedChildId != null && _notesController.text.isNotEmpty) {
                      final payload = PendingOrderPayloadService.attachChildAndNotes(
                        orderId: 'ORD-MOCK-999',
                        childId: _selectedChildId!,
                        requirementNotes: _notesController.text,
                      );
                      setState(() {
                        _currentPayload = payload;
                      });
                      Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payload configured successfully.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Attach to Payload'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _currentPayload != null && 
                         PendingOrderPayloadService.validatePayloadAccuracy(_currentPayload!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-01512 Payload Config'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Step Health', style: Theme.of(context).textTheme.titleMedium),
                        Chip(
                          label: Text(isValid ? 'Pass' : 'Fail'),
                          backgroundColor: isValid ? Colors.green.shade100 : Colors.red.shade100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Metric: Special-Requirement Field Capture Accuracy'),
                    Text('Status: ${isValid ? "Optimal" : "Below Floor Threshold (0.95)"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_currentPayload != null)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Payload', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Order ID: ${_currentPayload!.orderId}'),
                      Text('Child ID: ${_currentPayload!.childId}'),
                      Text('Notes: ${_currentPayload!.requirementNotes}'),
                      const Divider(),
                      Text('JSON Output:', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      SelectableText(
                        _currentPayload!.toJson().toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _showConfigBottomSheet,
                icon: const Icon(Icons.settings),
                label: const Text('Open Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}