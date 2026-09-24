// GEN-02215 — UDD Field Mapping Status Card.
// Displays UI-to-UDD field mappings with M3 ElevatedCard, status chips, polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum UddMappingStatus { pass, fail }

class UddFieldMapping {
  final String uiField;
  final String uddDataType;
  final UddMappingStatus status;

  const UddFieldMapping({
    required this.uiField,
    required this.uddDataType,
    required this.status,
  });
}

class _MockUddRepository {
  static const List<UddFieldMapping> mockMappings = [
    UddFieldMapping(uiField: 'username_input', uddDataType: 'String(64)', status: UddMappingStatus.pass),
    UddFieldMapping(uiField: 'email_address', uddDataType: 'EmailFormat', status: UddMappingStatus.pass),
    UddFieldMapping(uiField: 'age_selector', uddDataType: 'Integer32', status: UddMappingStatus.pass),
    UddFieldMapping(uiField: 'is_active_toggle', uddDataType: 'Boolean', status: UddMappingStatus.fail),
    UddFieldMapping(uiField: 'created_at_label', uddDataType: 'ISO8601DateTime', status: UddMappingStatus.pass),
  ];

  Future<List<UddFieldMapping>> fetchMappings() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return mockMappings;
  }
}

class UddFieldMappingCardGen02215 extends StatefulWidget {
  const UddFieldMappingCardGen02215({super.key});

  @override
  State<UddFieldMappingCardGen02215> createState() => _UddFieldMappingCardGen02215State();
}

class _UddFieldMappingCardGen02215State extends State<UddFieldMappingCardGen02215> {
  final _repo = _MockUddRepository();
  List<UddFieldMapping> _mappings = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _repo.fetchMappings();
    if (!mounted) return;
    setState(() {
      _mappings = data;
      _isLoading = false;
    });
  }

  double get _processExecutionAccuracy {
    if (_mappings.isEmpty) return 0.0;
    final passed = _mappings.where((m) => m.status == UddMappingStatus.pass).length;
    return passed / _mappings.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = _processExecutionAccuracy;
    final isPassing = accuracy >= 0.90;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(theme, accuracy, isPassing),
                const SizedBox(height: 16),
                Text(
                  'UI to UDD Field Mappings',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: isMobile ? 3.5 : 4.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _mappings.length,
                        itemBuilder: (context, index) => _buildMappingItem(theme, _mappings[index]),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ThemeData theme, double accuracy, bool isPassing) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Process Execution Accuracy', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${(accuracy * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isPassing ? theme.colorScheme.primary : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISO/IEC 25010 Standard | Floor: 90%',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Chip(
              avatar: Icon(
                isPassing ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: isPassing ? theme.colorScheme.primary : theme.colorScheme.error,
              ),
              label: Text(isPassing ? 'Pass' : 'Fail'),
              backgroundColor: isPassing
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: isPassing ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingItem(ThemeData theme, UddFieldMapping mapping) {
    final isPass = mapping.status == UddMappingStatus.pass;
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drill-down for ${mapping.uiField}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  isPass ? Icons.link : Icons.link_off,
                  color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mapping.uiField, style: theme.textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(mapping.uddDataType, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(isPass ? 'Mapped' : 'Orphaned'),
                backgroundColor: isPass ? theme.colorScheme.secondaryContainer : theme.colorScheme.errorContainer,
                labelStyle: TextStyle(
                  color: isPass ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onErrorContainer,
                  fontSize: 12,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}