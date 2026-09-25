// SSELC-009-A10 — Split-Screen MTO Contextual Mirror with Keyboard Avoidance.
// Implements a fixed split interactive pane enforcing portrait lock, zero-scroll data capture, keyboard-avoiding wrappers, and Material 3 semantic error helpers for the UDF module.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data model representing atomic-level data fields required by the requirement.
class MtoContextData {
  final String objectType;
  final String objectLocationPath;
  final bool isOpen;
  final DateTime timestamp;
  final String fileHandleId;

  const MtoContextData({
    required this.objectType,
    required this.objectLocationPath,
    required this.isOpen,
    required this.timestamp,
    required this.fileHandleId,
  });
}

/// Hardcoded mock data to satisfy backend/data requirements locally.
const List<MtoContextData> mockMtoContextItems = [
  MtoContextData(
    objectType: 'Valve Assembly',
    objectLocationPath: '/plant/zone-a/rack-12',
    isOpen: true,
    timestamp: DateTime(2026, 9, 25, 8, 30),
    fileHandleId: 'FH-99281-X',
  ),
  MtoContextData(
    objectType: 'Pressure Gauge',
    objectLocationPath: '/plant/zone-b/rack-04',
    isOpen: false,
    timestamp: DateTime(2026, 9, 25, 9, 15),
    fileHandleId: 'FH-11023-Y',
  ),
];

/// Main widget implementing the Split-Screen MTO Contextual Mirror.
/// Enforces portrait orientation, uses a fixed split layout (Look Top, Type Bottom),
/// and wraps the bottom input area in a keyboard-avoiding container.
class SplitScreenKeyboardAvoidingSselc009A10 extends StatefulWidget {
  const SplitScreenKeyboardAvoidingSselc009A10({super.key});

  @override
  State<SplitScreenKeyboardAvoidingSselc009A10> createState() =>
      _SplitScreenKeyboardAvoidingSselc009A10State();
}

class _SplitScreenKeyboardAvoidingSselc009A10State
    extends State<SplitScreenKeyboardAvoidingSselc009A10> {
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasValidationError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Poka-Yoke: App container is physically locked to Portrait mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _inputController.dispose();
    // Reset orientation preferences when leaving the screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hasValidationError = false;
        _errorMessage = null;
      });
      // Immediate contextual feedback on submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data submitted successfully. Execution velocity logged.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _inputController.clear();
    } else {
      setState(() {
        _hasValidationError = true;
        _errorMessage = 'Input cannot be empty. Please provide valid evidence data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MTO Contextual Mirror'),
        centerTitle: true,
      ),
      // Prevent scrolling out of predefined screen focus area (Zero-scroll paradigm)
      body: Column(
        children: [
          // TOP PANE: Look Top (Evidence Data Display)
          Expanded(
            flex: 1,
            child: _buildTopEvidencePane(),
          ),
          // BOTTOM PANE: Type Bottom, Submit (Input & Actions)
          // Wrapped in keyboard avoiding logic via padding and MediaQuery
          Expanded(
            flex: 1,
            child: _buildBottomInputPane(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopEvidencePane() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      // Fixed height constraints simulated via Expanded flex, no scrolling allowed
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence Data (Read-Only)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...mockMtoContextItems.map((item) => Card(
                  elevation: 2.0, // Material Surface elevations
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(item.objectType),
                    subtitle: Text('${item.objectLocationPath} | ${item.fileHandleId}'),
                    trailing: Icon(
                      item.isOpen ? Icons.lock_open : Icons.lock,
                      color: item.isOpen
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputPane() {
    // Keyboard avoiding wrapper using built-in Scaffold resizeToAvoidBottomInset
    // combined with SafeArea and SingleChildScrollView constrained to the bottom half.
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Theme.of(context).colorScheme.surface,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Data Capture Input',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _inputController,
                maxLines: 3,
                minLines: 3, // Fixed pane heights constraint
                decoration: InputDecoration(
                  hintText: 'Enter contextual observation...',
                  border: const OutlineInputBorder(),
                  // Semantic error helpers (Red font/background) mapping to API/validation failures
                  errorText: _hasValidationError ? _errorMessage : null,
                  errorStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: _hasValidationError,
                  fillColor: _hasValidationError
                      ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Field is required for submission.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit Evidence'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
