// CSIVW-002-A04 — Profile Field Constraint Configuration & Responsive Demo Booking Calendar.
// Provides inline numeric range validation with semantic red warnings, Material DatePicker selection,
// one-tap time slot confirmation, and responsive grid calendars for mobile-first UX.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Csivw002A04ProfileConstraintCalendar extends StatefulWidget {
  const Csivw002A04ProfileConstraintCalendar({super.key});

  @override
  State<Csivw002A04ProfileConstraintCalendar> createState() =>
      _Csivw002A04ProfileConstraintCalendarState();
}

class _Csivw002A04ProfileConstraintCalendarState
    extends State<Csivw002A04ProfileConstraintCalendar> {
  final _formKey = GlobalKey<FormState>();
  final _numericController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  final List<String> _timeSlots = const [
    '09:00',
    '10:30',
    '12:00',
    '13:30',
    '15:00',
    '16:30',
  ];
  final double _min = 10;
  final double _max = 100;

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(useMaterial3: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _confirmSlot() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a date and time slot.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demo booked for ${_selectedDate!.toLocal().toString().split(' ').first} at $_selectedTime.',
        ),
      ),
    );
  }

  String? _validateNumeric(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < _min || parsed > _max) {
      return 'Value must be between ${_min.toStringAsFixed(0)} and ${_max.toStringAsFixed(0)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profile Field Constraint', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numericController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Numeric profile field',
              helperText:
                  'Allowed range: ${_min.toStringAsFixed(0)}–${_max.toStringAsFixed(0)}',
              border: const OutlineInputBorder(),
            ),
            validator: _validateNumeric,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 24),
          Text('Demo Booking', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                _selectedDate == null
                    ? 'Select demo date'
                    : 'Date: ${_selectedDate!.toLocal().toString().split(' ').first}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedDate != null) ...[
            Text('Available time slots', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 600
                    ? 4
                    : constraints.maxWidth > 360
                        ? 3
                        : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _timeSlots.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, index) {
                    final slot = _timeSlots[index];
                    final selected = slot == _selectedTime;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedTime = slot),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _confirmSlot,
              icon: const Icon(Icons.check),
              label: const Text('Confirm 1-tap time slot'),
            ),
          ],
        ],
      ),
    );
  }
}
