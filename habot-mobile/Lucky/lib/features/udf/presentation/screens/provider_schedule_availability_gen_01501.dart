// GEN-01501 — Provider Schedule Availability Screen.
// Fetches and displays real-time provider schedule availability from the slot reservation API using mock data, M3 Elevated Cards, status chips, background polling (30s), and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum SlotHealth { good, average, poor }

class MockSlotAvailability {
  final String traceId;
  final String providerName;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final double conflictRate;
  final SlotHealth health;

  const MockSlotAvailability({
    required this.traceId,
    required this.providerName,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.conflictRate,
    required this.health,
  });
}

class MockSlotReservationRepository {
  Future<List<MockSlotAvailability>> fetchScheduleAvailability() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final now = DateTime.now();
    return [
      MockSlotAvailability(
        traceId: 'TRC-001-${now.millisecondsSinceEpoch}',
        providerName: 'Dr. Sarah Johnson',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 1, minutes: 30)),
        isAvailable: true,
        conflictRate: 0.0,
        health: SlotHealth.good,
      ),
      MockSlotAvailability(
        traceId: 'TRC-002-${now.millisecondsSinceEpoch}',
        providerName: 'Dr. Ahmed Al Maktoum',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 2, minutes: 45)),
        isAvailable: false,
        conflictRate: 1.5,
        health: SlotHealth.average,
      ),
      MockSlotAvailability(
        traceId: 'TRC-003-${now.millisecondsSinceEpoch}',
        providerName: 'Dr. Emily Chen',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 3, minutes: 30)),
        isAvailable: true,
        conflictRate: 0.2,
        health: SlotHealth.good,
      ),
      MockSlotAvailability(
        traceId: 'TRC-004-${now.millisecondsSinceEpoch}',
        providerName: 'Dr. Fatima Hassan',
        startTime: now.add(const Duration(hours: 4)),
        endTime: now.add(const Duration(hours: 5)),
        isAvailable: false,
        conflictRate: 3.1,
        health: SlotHealth.poor,
      ),
    ];
  }
}

class ProviderScheduleAvailabilityScreen extends StatefulWidget {
  const ProviderScheduleAvailabilityScreen({super.key});

  @override
  State<ProviderScheduleAvailabilityScreen> createState() => _ProviderScheduleAvailabilityScreenState();
}

class _ProviderScheduleAvailabilityScreenState extends State<ProviderScheduleAvailabilityScreen> {
  final MockSlotReservationRepository _repository = MockSlotReservationRepository();
  List<MockSlotAvailability> _slots = [];
  bool _isLoading = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchScheduleAvailability();
      if (mounted) {
        setState(() {
          _slots = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch schedule: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _healthColor(SlotHealth health, ThemeData theme) {
    switch (health) {
      case SlotHealth.good:
        return theme.colorScheme.primary;
      case SlotHealth.average:
        return theme.colorScheme.tertiary;
      case SlotHealth.poor:
        return theme.colorScheme.error;
    }
  }

  String _healthLabel(SlotHealth health) {
    switch (health) {
      case SlotHealth.good:
        return 'Good';
      case SlotHealth.average:
        return 'Average';
      case SlotHealth.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;
    final crossAxisCount = isDesktop ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Schedule Availability'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchData,
              tooltip: 'Manual Sync',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        edgeOffset: 0,
        child: _slots.isEmpty && !_isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No schedule data available. Pull to refresh.')),
                ],
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: isDesktop ? 2.5 : 2.0,
                ),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  return _buildSlotCard(slot, theme);
                },
              ),
      ),
    );
  }

  Widget _buildSlotCard(MockSlotAvailability slot, ThemeData theme) {
    final timeFormat = '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')} - ${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => _buildConfigBottomSheet(slot, theme),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      slot.providerName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _healthLabel(slot.health),
                      style: TextStyle(color: _healthColor(slot.health, theme), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: _healthColor(slot.health, theme).withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                timeFormat,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    slot.isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: slot.isAvailable ? theme.colorScheme.primary : theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    slot.isAvailable ? 'Available' : 'Booked / Conflict',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: slot.isAvailable ? theme.colorScheme.primary : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Conflict Rate: ${slot.conflictRate.toStringAsFixed(2)}%',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              Text(
                'Trace: ${slot.traceId}',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigBottomSheet(MockSlotAvailability slot, ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slot Configuration', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Provider: ${slot.providerName}', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Trace ID: ${slot.traceId}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Health Status: ${_healthLabel(slot.health)}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Configuration saved for ${slot.providerName}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Confirm Selection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
