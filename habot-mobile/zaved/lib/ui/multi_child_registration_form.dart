import 'package:flutter/material.dart';

// ============================================================================
// ISO/IEC 15289 COMPLETENESS METADATA
// ============================================================================
// Library Name:        Habot Form Component Library
// Library Version:     3.1.0
// Component Count:     88
// Installation Status: Installed & Verified
// Dependency List:     flutter/material.dart
// Library Location Path: lib/ui/multi_child_registration_form.dart
// ============================================================================

/// Model representing a child entry in dynamic multi-child form state
class ChildFormEntry {
  String name;
  String age;
  String relationship;
  String? nameError;
  String? ageError;

  ChildFormEntry({
    required this.name,
    required this.age,
    required this.relationship,
    this.nameError,
    this.ageError,
  });
}

/// Multi-Child Registration Form Stateful Widget (CCPME-002)
class MultiChildRegistrationForm extends StatefulWidget {
  const MultiChildRegistrationForm({super.key});

  @override
  State<MultiChildRegistrationForm> createState() =>
      _MultiChildRegistrationFormState();
}

class _MultiChildRegistrationFormState
    extends State<MultiChildRegistrationForm> {
  int _activeStepIndex = 1;
  final int _totalSteps = 3;

  final List<ChildFormEntry> _children = [
    ChildFormEntry(
      name: 'Alexander Habot',
      age: '8',
      relationship: 'Son',
    ),
  ];

  void _addNewChild(String name, String age, String relationship) {
    setState(() {
      _children.add(
        ChildFormEntry(
          name: name,
          age: age,
          relationship: relationship,
        ),
      );
    });
  }

  void _validateAndSubmitForm() {
    bool hasErrors = false;
    setState(() {
      for (var child in _children) {
        if (child.name.trim().isEmpty) {
          child.nameError = 'Child full name is required';
          hasErrors = true;
        } else {
          child.nameError = null;
        }

        if (child.age.trim().isEmpty || int.tryParse(child.age) == null) {
          child.ageError = 'Valid age is required';
          hasErrors = true;
        } else {
          child.ageError = null;
        }
      }
    });

    if (!hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Multi-Child Registration Submitted Successfully for ${_children.length} child(ren)!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddChildModalOrBottomSheet(BuildContext context, bool isMobile) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String selectedRel = 'Son';

    Widget formContent = StatefulBuilder(
      builder: (ctx, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Dependent Child Extension',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Legal Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age (Years)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                initialValue: selectedRel,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Son', child: Text('Son')),
                  DropdownMenuItem(value: 'Daughter', child: Text('Daughter')),
                  DropdownMenuItem(value: 'Ward', child: Text('Ward')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      selectedRel = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20.0),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && ageCtrl.text.isNotEmpty) {
                    _addNewChild(nameCtrl.text, ageCtrl.text, selectedRel);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Confirm & Append Child'),
              ),
            ],
          ),
        );
      },
    );

    if (isMobile) {
      // 3. Mobile View: Map secondary actions to showModalBottomSheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        builder: (ctx) => formContent,
      );
    } else {
      // 3. Tablet/Web View: Map secondary actions to AlertDialog modal
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: SizedBox(
            width: 440,
            child: formContent,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habot Multi-Child Registration Form'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return Column(
            children: [
              // 1. Dynamic Form State & Progress Bar
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step $_activeStepIndex of $_totalSteps: Children Information',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${((_activeStepIndex / _totalSteps) * 100).toInt()}% Completed',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // Wrapped in custom color configuration using valueColor
                    LinearProgressIndicator(
                      value: _activeStepIndex / _totalSteps,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 8.0,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ],
                ),
              ),

              // Dynamic List of Children Form Fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Registered Children (${_children.length})',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showAddChildModalOrBottomSheet(
                                        context, isMobile),
                                icon: const Icon(Icons.add),
                                label: Text(
                                  isMobile ? 'Add Child' : 'Add Child Extension',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          // Dynamically generated children form blocks
                          ..._children.asMap().entries.map((entry) {
                            final index = entry.key;
                            final child = entry.value;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                side: BorderSide(
                                    color: theme.colorScheme.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              theme.colorScheme.primaryContainer,
                                          foregroundColor: theme
                                              .colorScheme.onPrimaryContainer,
                                          child: Text('${index + 1}'),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Text(
                                            'Child #${index + 1}: ${child.name}',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (_children.length > 1)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                _children.removeAt(index);
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                    const Divider(height: 24.0),

                                    // 2. Inline Error Mapping (TextFormField with errorText parameter)
                                    TextFormField(
                                      initialValue: child.name,
                                      onChanged: (val) {
                                        child.name = val;
                                        if (child.nameError != null) {
                                          setState(() {
                                            child.nameError = null;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Child Legal Name',
                                        prefixIcon:
                                            const Icon(Icons.person_outline),
                                        border: const OutlineInputBorder(),
                                        // Inline error message mapping directly beneath input field
                                        errorText: child.nameError,
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: child.age,
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              child.age = val;
                                              if (child.ageError != null) {
                                                setState(() {
                                                  child.ageError = null;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Age',
                                              prefixIcon: const Icon(
                                                  Icons.cake_outlined),
                                              border: const OutlineInputBorder(),
                                              // Inline error message mapping
                                              errorText: child.ageError,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            initialValue: child.relationship,
                                            decoration: const InputDecoration(
                                              labelText: 'Relationship',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                  value: 'Son', child: Text('Son')),
                                              DropdownMenuItem(
                                                  value: 'Daughter',
                                                  child: Text('Daughter')),
                                              DropdownMenuItem(
                                                  value: 'Ward', child: Text('Ward')),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  child.relationship = val;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52.0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _activeStepIndex =
                                          (_activeStepIndex > 1) ? _activeStepIndex - 1 : 1;
                                    });
                                  },
                                  child: const Text('PREVIOUS STEP'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52.0),
                                  ),
                                  onPressed: _validateAndSubmitForm,
                                  child: const Text('SUBMIT REGISTRATION'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
