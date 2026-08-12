import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Model representing a real-time Churn & Satisfaction event.
class ChurnEvent {
  final String eventId;
  final String? predecessorId;
  final DateTime timestamp;
  final String stage;
  final double csatScore;
  final double churnProbability;

  const ChurnEvent({
    required this.eventId,
    this.predecessorId,
    required this.timestamp,
    required this.stage,
    required this.csatScore,
    required this.churnProbability,
  });

  /// Poka-Yoke Ingestion Factory
  /// Strictly checks for [predecessor_id]. If null or empty, throws a [FormatException]
  /// and prevents the data point from rendering on the analytical charts.
  factory ChurnEvent.fromRawJson(Map<String, dynamic> json) {
    final predecessorId = json['predecessor_id'] as String?;
    if (predecessorId == null || predecessorId.trim().isEmpty) {
      const errorMsg =
          'Poka-Yoke Ingestion Error: Event rejected due to missing mandatory predecessor_id parameter.';
      developer.log(
        errorMsg,
        name: 'DataIngestionPipeline',
        level: 1000,
        error: FormatException(errorMsg),
      );
      throw FormatException(errorMsg);
    }

    return ChurnEvent(
      eventId: json['event_id'] as String? ?? 'EVT-0000',
      predecessorId: predecessorId,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      stage: json['stage'] as String? ?? 'Sign-Up',
      csatScore: (json['csat_score'] as num?)?.toDouble() ?? 75.0,
      churnProbability:
          (json['churn_probability'] as num?)?.toDouble() ?? 0.15,
    );
  }
}

/// Custom Sparkline Painter for Mobile Viewport
class SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  SparklinePainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final maxVal = dataPoints.reduce(math.max);
    final minVal = dataPoints.reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height - 8) + 4);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
  }
}

/// Custom Complex Multi-Line Chart Painter for Tablet/Web Viewport
class ComplexAnalyticsChartPainter extends CustomPainter {
  final List<ChurnEvent> events;
  final Color primaryColor;
  final Color errorColor;
  final Color gridColor;

  ComplexAnalyticsChartPainter({
    required this.events,
    required this.primaryColor,
    required this.errorColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    // Draw Grid Lines
    const rows = 4;
    for (int i = 0; i <= rows; i++) {
      final y = (size.height / rows) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (events.isEmpty) return;

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final churnPaint = Paint()
      ..color = errorColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final pathCsat = Path();
    final pathChurn = Path();

    final stepX = size.width / (events.length > 1 ? events.length - 1 : 1);

    for (int i = 0; i < events.length; i++) {
      final x = i * stepX;
      final csatY = size.height - ((events[i].csatScore / 100.0) * size.height);
      final churnY = size.height - (events[i].churnProbability * size.height);

      if (i == 0) {
        pathCsat.moveTo(x, csatY);
        pathChurn.moveTo(x, churnY);
      } else {
        pathCsat.lineTo(x, csatY);
        pathChurn.lineTo(x, churnY);
      }

      // Draw Data Nodes
      canvas.drawCircle(
        Offset(x, csatY),
        4.0,
        Paint()..color = primaryColor,
      );
      canvas.drawCircle(
        Offset(x, churnY),
        4.0,
        Paint()..color = errorColor,
      );
    }

    canvas.drawPath(pathCsat, linePaint);
    canvas.drawPath(pathChurn, churnPaint);
  }

  @override
  bool shouldRepaint(covariant ComplexAnalyticsChartPainter oldDelegate) {
    return oldDelegate.events != events ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Stateful Dashboard Widget with Adaptive Layouts, Pub/Sub Simulation,
/// RestorationMixin state preservation, strict accessibility, and Poka-Yoke validation.
class SatisfactionAnalyticsEngineDashboard extends StatefulWidget {
  final String? restorationId;

  const SatisfactionAnalyticsEngineDashboard({
    super.key,
    this.restorationId = 'satisfaction_analytics_engine_dashboard',
  });

  @override
  State<SatisfactionAnalyticsEngineDashboard> createState() =>
      _SatisfactionAnalyticsEngineDashboardState();
}

class _SatisfactionAnalyticsEngineDashboardState
    extends State<SatisfactionAnalyticsEngineDashboard>
    with RestorationMixin {
  // Restorable Properties for Rotation Immunity
  final RestorableInt _selectedTimeRangeIndex = RestorableInt(0);
  final RestorableString _selectedMetricFilter = RestorableString('all');
  final RestorableBool _simulateInvalidIngestion = RestorableBool(false);

  // Real-Time Pub/Sub Stream Controller Simulation
  late final StreamController<List<ChurnEvent>> _pubSubStreamController;
  Timer? _simulatedPubSubTimer;

  final List<ChurnEvent> _validatedEventBuffer = [];
  int _totalIngestedCount = 0;
  int _pokaYokeRejectedCount = 0;

  final List<String> _timeRangeOptions = const ['7 Days', '30 Days', '90 Days'];

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    _pubSubStreamController = StreamController<List<ChurnEvent>>.broadcast();
    _seedInitialData();
    _startMockPubSubStream();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTimeRangeIndex, 'selected_time_range_index');
    registerForRestoration(_selectedMetricFilter, 'selected_metric_filter');
    registerForRestoration(
        _simulateInvalidIngestion, 'simulate_invalid_ingestion');
  }

  void _seedInitialData() {
    final now = DateTime.now();
    final initialRawData = [
      {
        'event_id': 'EVT-1001',
        'predecessor_id': 'PRED-INIT-01',
        'timestamp': now.subtract(const Duration(minutes: 25)).toIso8601String(),
        'stage': 'Landing Page',
        'csat_score': 88.0,
        'churn_probability': 0.08,
      },
      {
        'event_id': 'EVT-1002',
        'predecessor_id': 'PRED-INIT-02',
        'timestamp': now.subtract(const Duration(minutes: 20)).toIso8601String(),
        'stage': 'Sign-Up Form',
        'csat_score': 74.0,
        'churn_probability': 0.22,
      },
      {
        'event_id': 'EVT-1003',
        'predecessor_id': 'PRED-INIT-03',
        'timestamp': now.subtract(const Duration(minutes: 15)).toIso8601String(),
        'stage': 'Payment Method',
        'csat_score': 65.0,
        'churn_probability': 0.38,
      },
      {
        'event_id': 'EVT-1004',
        'predecessor_id': 'PRED-INIT-04',
        'timestamp': now.subtract(const Duration(minutes: 10)).toIso8601String(),
        'stage': 'Onboarding Tutorial',
        'csat_score': 82.0,
        'churn_probability': 0.12,
      },
      {
        'event_id': 'EVT-1005',
        'predecessor_id': 'PRED-INIT-05',
        'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'stage': 'Dashboard First Load',
        'csat_score': 91.0,
        'churn_probability': 0.05,
      },
    ];

    for (final json in initialRawData) {
      _processRawJsonData(json);
    }
  }

  void _startMockPubSubStream() {
    _simulatedPubSubTimer?.cancel();
    _simulatedPubSubTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _totalIngestedCount++;
      final isInvalid = _simulateInvalidIngestion.value && (_totalIngestedCount % 2 == 0);

      final rawJson = {
        'event_id': 'EVT-${1005 + _totalIngestedCount}',
        // Poka-Yoke Test: Null predecessor_id triggers rejection
        'predecessor_id': isInvalid ? null : 'PRED-LIVE-${1000 + _totalIngestedCount}',
        'timestamp': DateTime.now().toIso8601String(),
        'stage': _getRandomStage(),
        'csat_score': 50.0 + math.Random().nextDouble() * 45.0,
        'churn_probability': 0.05 + math.Random().nextDouble() * 0.45,
      };

      _processRawJsonData(rawJson);
    });
  }

  /// Poka-Yoke Protected Data Ingestion
  void _processRawJsonData(Map<String, dynamic> json) {
    try {
      final event = ChurnEvent.fromRawJson(json);
      _validatedEventBuffer.add(event);
      if (_validatedEventBuffer.length > 20) {
        _validatedEventBuffer.removeAt(0);
      }
      _pubSubStreamController.add(List.from(_validatedEventBuffer));
    } catch (e) {
      setState(() {
        _pokaYokeRejectedCount++;
      });
      // Stream still emits existing buffer without corrupting chart
      _pubSubStreamController.add(List.from(_validatedEventBuffer));
    }
  }

  String _getRandomStage() {
    const stages = [
      'Sign-Up Form',
      'OTP Verification',
      'Profile Setup',
      'Billing Info',
      'Workspace Invite'
    ];
    return stages[math.Random().nextInt(stages.length)];
  }

  @override
  void dispose() {
    _simulatedPubSubTimer?.cancel();
    _pubSubStreamController.close();
    _selectedTimeRangeIndex.dispose();
    _selectedMetricFilter.dispose();
    _simulateInvalidIngestion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satisfaction & Churn Engine'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _simulateInvalidIngestion.value
                  ? Icons.warning_amber_rounded
                  : Icons.shield_outlined,
              color: _simulateInvalidIngestion.value
                  ? theme.colorScheme.error
                  : null,
            ),
            tooltip: 'Toggle Poka-Yoke Null predecessor_id Simulation',
            onPressed: () {
              setState(() {
                _simulateInvalidIngestion.value =
                    !_simulateInvalidIngestion.value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    _simulateInvalidIngestion.value
                        ? 'Simulating corrupt events (Missing predecessor_id).'
                        : 'Simulating valid pub/sub events.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChurnEvent>>(
          stream: _pubSubStreamController.stream,
          initialData: _validatedEventBuffer,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= 600;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Accessible Filter Controls Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildAccessibilityFilterControls(theme),
                      ),
                      const SizedBox(height: 16.0),

                      // Poka-Yoke Enforcement Banner
                      if (_pokaYokeRejectedCount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildPokaYokeBanner(theme),
                        ),
                      if (_pokaYokeRejectedCount > 0)
                        const SizedBox(height: 16.0),

                      // Adaptive Dashboard Content
                      if (isMobile)
                        _buildMobileLayout(theme, events)
                      else
                        _buildTabletWebLayout(theme, events, constraints.maxWidth),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Accessible Filter Controls (Strict minHeight & minWidth: 48.0 via BoxConstraints)
  Widget _buildAccessibilityFilterControls(ThemeData theme) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Time Range Dropdown with minHeight & minWidth: 48.0
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 140.0,
            minHeight: 48.0,
          ),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedTimeRangeIndex.value,
            decoration: InputDecoration(
              labelText: 'Time Range',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            items: List.generate(
              _timeRangeOptions.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(_timeRangeOptions[index]),
              ),
            ),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedTimeRangeIndex.value = val;
                });
              }
            },
          ),
        ),

        // Segment Filter Toggle with minHeight 48.0
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 160.0,
            minHeight: 48.0,
          ),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'all',
                label: Text('All Events'),
                icon: Icon(Icons.analytics),
              ),
              ButtonSegment(
                value: 'churn',
                label: Text('High Risk'),
                icon: Icon(Icons.warning),
              ),
            ],
            selected: {_selectedMetricFilter.value},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedMetricFilter.value = newSelection.first;
              });
            },
          ),
        ),

        // Action Button with BoxConstraints minHeight & minWidth 48.0
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48.0,
            minHeight: 48.0,
          ),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48.0, 48.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onPressed: () {
              setState(() {
                _validatedEventBuffer.clear();
                _seedInitialData();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Stream'),
          ),
        ),
      ],
    );
  }

  Widget _buildPokaYokeBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.gpp_bad, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Poka-Yoke Pipeline Active: Rejected $_pokaYokeRejectedCount data point(s) missing mandatory predecessor_id.',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Layout (maxWidth <= 600): Single Column, 16.0 Horizontal Margins, KPI Cards & Sparklines
  Widget _buildMobileLayout(ThemeData theme, List<ChurnEvent> events) {
    final filteredEvents = _getFilteredEvents(events);
    final avgCsat = filteredEvents.isEmpty
        ? 0.0
        : filteredEvents.map((e) => e.csatScore).reduce((a, b) => a + b) /
            filteredEvents.length;
    final avgChurn = filteredEvents.isEmpty
        ? 0.0
        : filteredEvents.map((e) => e.churnProbability).reduce((a, b) => a + b) /
            filteredEvents.length;

    final csatPoints = filteredEvents.map((e) => e.csatScore).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Summary Card 1: CSAT Score
          _buildKpiSummaryCard(
            theme: theme,
            title: 'Avg CSAT Score',
            value: '${avgCsat.toStringAsFixed(1)} / 100',
            icon: Icons.sentiment_satisfied_alt,
            color: theme.colorScheme.primary,
            sparklineData: csatPoints.isEmpty ? [70, 75, 80] : csatPoints,
          ),
          const SizedBox(height: 16.0),

          // KPI Summary Card 2: Churn Risk %
          _buildKpiSummaryCard(
            theme: theme,
            title: 'Avg Churn Risk',
            value: '${(avgChurn * 100).toStringAsFixed(1)}%',
            icon: Icons.trending_down,
            color: theme.colorScheme.error,
            sparklineData:
                filteredEvents.map((e) => e.churnProbability * 100).toList(),
          ),
          const SizedBox(height: 16.0),

          // Real-Time Events Feed Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Drop Events Feed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          '${events.length} Live',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20.0),
                  ...filteredEvents.take(4).map(
                        (e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_off,
                              size: 20.0,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          title: Text(e.stage),
                          subtitle: Text('predecessor_id: ${e.predecessorId}'),
                          trailing: Text(
                            'CSAT: ${e.csatScore.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet / Web Layout (maxWidth > 600): Multi-Column Grid + Complex Analytics Chart
  Widget _buildTabletWebLayout(
    ThemeData theme,
    List<ChurnEvent> events,
    double maxWidth,
  ) {
    final filteredEvents = _getFilteredEvents(events);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Grid Row of KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiSummaryCard(
                  theme: theme,
                  title: 'CSAT Score Index',
                  value: '84.2 / 100',
                  icon: Icons.analytics,
                  color: theme.colorScheme.primary,
                  sparklineData: const [70, 72, 78, 81, 84, 86],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildKpiSummaryCard(
                  theme: theme,
                  title: 'Sign-Up Drop Rate',
                  value: '14.8%',
                  icon: Icons.trending_down,
                  color: theme.colorScheme.error,
                  sparklineData: const [25, 22, 19, 18, 15, 14],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildKpiSummaryCard(
                  theme: theme,
                  title: 'Active Data Points',
                  value: '${filteredEvents.length} Events',
                  icon: Icons.stream,
                  color: theme.colorScheme.tertiary,
                  sparklineData: const [5, 8, 12, 15, 18, 20],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Main Multi-Column Complex Chart Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Satisfaction vs. Churn Mapping Matrix',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Real-time pub/sub multi-variable correlation chart with Poka-Yoke data validation.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLegendDot(
                            color: theme.colorScheme.primary,
                            label: 'CSAT Score',
                          ),
                          const SizedBox(width: 16.0),
                          _buildLegendDot(
                            color: theme.colorScheme.error,
                            label: 'Churn Risk',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Complex Custom Chart Area
                  SizedBox(
                    height: 260.0,
                    child: CustomPaint(
                      painter: ComplexAnalyticsChartPainter(
                        events: filteredEvents,
                        primaryColor: theme.colorScheme.primary,
                        errorColor: theme.colorScheme.error,
                        gridColor: theme.colorScheme.outline,
                      ),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSummaryCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<double> sparklineData,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 40.0,
              child: CustomPaint(
                painter: SparklinePainter(
                  dataPoints: sparklineData,
                  color: color,
                ),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  List<ChurnEvent> _getFilteredEvents(List<ChurnEvent> events) {
    if (_selectedMetricFilter.value == 'churn') {
      return events.where((e) => e.churnProbability > 0.25).toList();
    }
    return events;
  }
}
