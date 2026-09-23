import 'package:flutter/material.dart';

/// Unique styling tokens for Ops Intelligence & Bottleneck Console.
abstract final class OpsBottleneckTokens {
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status badges
  static const Color statusCritical = Color(0xFFDC2626);
  static const Color statusCriticalBg = Color(0xFFFEE2E2);

  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusWarningBg = Color(0xFFFEF3C7);

  static const Color statusHealthy = Color(0xFF16A34A);
  static const Color statusHealthyBg = Color(0xFFDCFCE7);

  static const Color statusDegraded = Color(0xFF9333EA);
  static const Color statusDegradedBg = Color(0xFFF3E8FF);
}

/// Bottleneck incident item model.
class BottleneckIncident {
  final String serviceName;
  final String queueDepth;
  final String p99Latency;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String incidentId;
  bool isResolved;

  BottleneckIncident({
    required this.serviceName,
    required this.queueDepth,
    required this.p99Latency,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.incidentId,
    this.isResolved = false,
  });
}

/// Ops Intelligence & Bottleneck Console using M3 Data Tables and Status Badges.
class OpsBottleneckConsoleTable extends StatefulWidget {
  final void Function(BottleneckIncident incident)? onMitigateIncident;

  const OpsBottleneckConsoleTable({
    super.key,
    this.onMitigateIncident,
  });

  @override
  State<OpsBottleneckConsoleTable> createState() => _OpsBottleneckConsoleTableState();
}

class _OpsBottleneckConsoleTableState extends State<OpsBottleneckConsoleTable> {
  String _selectedFilter = 'All';

  late List<BottleneckIncident> _incidents;

  @override
  void initState() {
    super.initState();
    _incidents = [
      BottleneckIncident(
        serviceName: 'Auth Token Service',
        queueDepth: '4,820 pkts',
        p99Latency: '1,420 ms',
        status: 'CRITICAL',
        statusColor: OpsBottleneckTokens.statusCritical,
        statusBg: OpsBottleneckTokens.statusCriticalBg,
        incidentId: 'INC-9021',
      ),
      BottleneckIncident(
        serviceName: 'Payment Gateway Broker',
        queueDepth: '1,210 pkts',
        p99Latency: '780 ms',
        status: 'WARNING',
        statusColor: OpsBottleneckTokens.statusWarning,
        statusBg: OpsBottleneckTokens.statusWarningBg,
        incidentId: 'INC-9022',
      ),
      BottleneckIncident(
        serviceName: 'Location Geo-Locator',
        queueDepth: '2,940 pkts',
        p99Latency: '940 ms',
        status: 'DEGRADED',
        statusColor: OpsBottleneckTokens.statusDegraded,
        statusBg: OpsBottleneckTokens.statusDegradedBg,
        incidentId: 'INC-9023',
      ),
      BottleneckIncident(
        serviceName: 'Invoice PDF Generator',
        queueDepth: '140 pkts',
        p99Latency: '65 ms',
        status: 'HEALTHY',
        statusColor: OpsBottleneckTokens.statusHealthy,
        statusBg: OpsBottleneckTokens.statusHealthyBg,
        incidentId: 'INC-9024',
      ),
    ];
  }

  List<BottleneckIncident> get _filteredIncidents {
    if (_selectedFilter == 'All') return _incidents;
    return _incidents.where((i) => i.status == _selectedFilter).toList();
  }

  void _mitigate(BottleneckIncident incident) {
    setState(() {
      incident.isResolved = true;
    });
    widget.onMitigateIncident?.call(incident);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mitigation initiated for ${incident.serviceName} (${incident.incidentId})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: OpsBottleneckTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: OpsBottleneckTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpsBottleneckTokens.accentIndigo.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.table_view_rounded,
                  color: OpsBottleneckTokens.accentIndigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ops Bottleneck Console',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: OpsBottleneckTokens.textDark,
                      ),
                    ),
                    Text(
                      'ITIL v4 Problem Management & M3 Status Badges',
                      style: TextStyle(
                        fontSize: 12,
                        color: OpsBottleneckTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OpsBottleneckTokens.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpsBottleneckTokens.borderLight),
                ),
                child: const Text(
                  'ITIL v4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: OpsBottleneckTokens.accentIndigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'CRITICAL', 'WARNING', 'DEGRADED', 'HEALTHY'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: OpsBottleneckTokens.accentIndigo.withAlpha(30),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? OpsBottleneckTokens.accentIndigo
                          : OpsBottleneckTokens.textDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // M3 Data Table Container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: OpsBottleneckTokens.borderLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(OpsBottleneckTokens.backgroundLight),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: OpsBottleneckTokens.textDark,
                    fontSize: 12,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 12,
                    color: OpsBottleneckTokens.textDark,
                  ),
                  horizontalMargin: 12,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('P99 Latency')),
                    DataColumn(label: Text('Queue Depth')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _filteredIncidents.map((incident) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Icon(
                                incident.isResolved
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.warning_amber_rounded,
                                size: 16,
                                color: incident.isResolved
                                    ? OpsBottleneckTokens.statusHealthy
                                    : incident.statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                incident.serviceName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(incident.p99Latency)),
                        DataCell(Text(incident.queueDepth)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: incident.isResolved
                                  ? OpsBottleneckTokens.statusHealthyBg
                                  : incident.statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              incident.isResolved ? 'MITIGATED' : incident.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: incident.isResolved
                                    ? OpsBottleneckTokens.statusHealthy
                                    : incident.statusColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: incident.isResolved ? null : () => _mitigate(incident),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OpsBottleneckTokens.accentIndigo,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              disabledForegroundColor: const Color(0xFF94A3B8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(60, 32),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            child: Text(incident.isResolved ? 'Resolved' : 'Reroute'),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Footer ITIL Resolution Summary
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OpsBottleneckTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: OpsBottleneckTokens.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'SLA MTTR Target: < 5 min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: OpsBottleneckTokens.textDark,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final i in _incidents) {
                        i.isResolved = false;
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Reset Console', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: OpsBottleneckConsoleTable(),
          ),
        ),
      ),
    ),
  );
}
