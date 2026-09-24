// GEN-02306 — Mobile Attendance Geofencing Capture Permission Card.
// Integrates mobile OS location permission requests into the app flow using M3 Elevated Cards, Status Chips, and responsive single/multi-column layouts.

import 'package:flutter/material.dart';

enum LocationValidationStatus { high, medium, low }

class GeofencingPermissionCardGen02306 extends StatefulWidget {
  const GeofencingPermissionCardGen02306({super.key});

  @override
  State<GeofencingPermissionCardGen02306> createState() => _GeofencingPermissionCardGen02306State();
}

class _GeofencingPermissionCardGen02306State extends State<GeofencingPermissionCardGen02306> {
  bool _permissionGranted = false;
  bool _isPolling = false;
  double _validationAccuracy = 0.95;
  LocationValidationStatus _status = LocationValidationStatus.medium;

  // Mock data representing ISO/IEC 27001 & Privacy by Design compliance metrics
  final Map<String, dynamic> _mockTelemetryData = {
    'event_date': '2026-09-24',
    'trace_id': 'GEN-02306-TRACE-001',
    'completion_status': 'Medium',
    'action_timestamp': DateTime.now().toIso8601String(),
    'session_id': 'MOCK_SESSION_12345',
    'metric_name': 'Location Validation Accuracy (%)',
    'floor_boundary': 0.95,
    'optimal_target': 0.995,
    'ceiling_boundary': 1.0,
  };

  @override
  void initState() {
    super.initState();
    _startBackgroundPolling();
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  void _startBackgroundPolling() {
    _isPolling = true;
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isPolling) {
        _refreshMockData();
        _startBackgroundPolling();
      }
    });
  }

  void _refreshMockData() {
    setState(() {
      _validationAccuracy = 0.97 + (DateTime.now().millisecond / 100000.0);
      _updateStatus();
    });
  }

  void _updateStatus() {
    if (_validationAccuracy >= 0.995) {
      _status = LocationValidationStatus.high;
    } else if (_validationAccuracy >= 0.95) {
      _status = LocationValidationStatus.medium;
    } else {
      _status = LocationValidationStatus.low;
    }
    _mockTelemetryData['completion_status'] = _status.name.capitalize();
    _mockTelemetryData['action_timestamp'] = DateTime.now().toIso8601String();
  }

  Future<void> _requestLocationPermission() async {
    // Simulate OS location permission request integration
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() {
      _permissionGranted = true;
      _validationAccuracy = 0.998;
      _updateStatus();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission granted successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _refreshMockData();
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_status) {
      case LocationValidationStatus.high:
        return colorScheme.primary;
      case LocationValidationStatus.medium:
        return colorScheme.tertiary;
      case LocationValidationStatus.low:
        return colorScheme.error;
    }
  }

  String _getStatusLabel() {
    switch (_status) {
      case LocationValidationStatus.high:
        return 'High';
      case LocationValidationStatus.medium:
        return 'Medium';
      case LocationValidationStatus.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: isMobile ? _buildSingleColumnLayout(context) : _buildMultiColumnLayout(context),
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMainElevatedCard(context),
        const SizedBox(height: 16),
        _buildKpiCard(context),
        const SizedBox(height: 16),
        _buildActionSheetTrigger(context),
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildMainElevatedCard(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildActionSheetTrigger(context)),
      ],
    );
  }

  Widget _buildMainElevatedCard(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Step 5: Geofencing Capture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    _getStatusLabel(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  backgroundColor: _getStatusColor(context).withOpacity(0.2),
                  side: BorderSide(color: _getStatusColor(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Integrate mobile OS location permission requests into the app flow.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _permissionGranted ? null : _requestLocationPermission,
                icon: const Icon(Icons.location_on, size: 24),
                label: Text(_permissionGranted ? 'Permission Granted' : 'Request Location Permission'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Validation Accuracy',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_validationAccuracy * 100).toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(context),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _validationAccuracy.clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Floor Threshold: 95% | Target: 99.5%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSheetTrigger(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showConfigurationBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Engineering Console', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('View telemetry & configuration', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Telemetry Configuration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._mockTelemetryData.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.replaceAll('_', ' ').capitalize(), style: const TextStyle(fontSize: 13)),
                    Flexible(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

extension _StringCapitalizeExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}