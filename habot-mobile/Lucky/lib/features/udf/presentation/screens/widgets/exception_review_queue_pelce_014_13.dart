// PELCE-014-13 — Exception Routing Review Queue with Material Design 3 Layout.
// Displays parsed validation failure status lists using lightweight interface layouts optimized for narrow mobile screens, featuring high-contrast type variants, clean dividers, and a floating action button for rapid access to target data cards. Includes a 1.5-second pulse animation cycle.

import 'package:flutter/material.dart';

enum LayoutValidationStatus { good, average, poor }

class MockExceptionItem {
  final String id;
  final String fieldName;
  final String errorMessage;
  final LayoutValidationStatus status;
  final DateTime timestamp;

  const MockExceptionItem({
    required this.id,
    required this.fieldName,
    required this.errorMessage,
    required this.status,
    required this.timestamp,
  });
}

const List<MockExceptionItem> _mockExceptions = [
  MockExceptionItem(
    id: 'EXC-001',
    fieldName: 'Layout Grid Dimensions',
    errorMessage: 'Mandatory structural metadata field omitted.',
    status: LayoutValidationStatus.poor,
    timestamp: DateTime(2026, 9, 23, 10, 15),
  ),
  MockExceptionItem(
    id: 'EXC-002',
    fieldName: 'Spacing Rules',
    errorMessage: 'Alignment settings out of bounds.',
    status: LayoutValidationStatus.average,
    timestamp: DateTime(2026, 9, 23, 10, 22),
  ),
  MockExceptionItem(
    id: 'EXC-003',
    fieldName: 'Layout Type',
    errorMessage: 'Invalid configuration payload.',
    status: LayoutValidationStatus.good,
    timestamp: DateTime(2026, 9, 23, 10, 45),
  ),
];

class ExceptionReviewQueuePelce01413 extends StatefulWidget {
  const ExceptionReviewQueuePelce01413({super.key});

  @override
  State<ExceptionReviewQueuePelce01413> createState() => _ExceptionReviewQueuePelce01413State();
}

class _ExceptionReviewQueuePelce01413State extends State<ExceptionReviewQueuePelce01413>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStatusColor(LayoutValidationStatus status, ThemeData theme) {
    switch (status) {
      case LayoutValidationStatus.good:
        return theme.colorScheme.primary;
      case LayoutValidationStatus.average:
        return theme.colorScheme.tertiary;
      case LayoutValidationStatus.poor:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(LayoutValidationStatus status) {
    switch (status) {
      case LayoutValidationStatus.good:
        return 'Good (100%)';
      case LayoutValidationStatus.average:
        return 'Average';
      case LayoutValidationStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Human Review Queue'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _mockExceptions.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 1.0,
          thickness: 1.0,
          indent: 16.0,
          endIndent: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          final MockExceptionItem item = _mockExceptions[index];
          final Color statusColor = _getStatusColor(item.status, theme);

          return ListTile(
            isThreeLine: true,
            leading: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: statusColor,
                    ),
                  ),
                );
              },
            ),
            title: Text(
              item.fieldName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Text(
                  item.errorMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: statusColor, width: 1.0),
                      ),
                      child: Text(
                        _getStatusLabel(item.status),
                        style: textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Poka Yoke: Refuse save if mandatory fields omitted logic would trigger here.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Routing exception ${item.id} to detailed review...')),
              );
            },
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rapid shortcut access triggered.')),
            );
          },
          tooltip: 'Quick Access Data Card',
          child: const Icon(Icons.assignment_turned_in_outlined),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: animation, builder: builder);
  }
}