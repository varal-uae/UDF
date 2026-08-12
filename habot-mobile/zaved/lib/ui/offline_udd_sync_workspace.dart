import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Model representing a UDD Schema Rule from API JSON payload.
class UddSchemaRule {
  const UddSchemaRule({
    required this.id,
    required this.title,
    required this.status,
    required this.severity,
    required this.description,
  });

  factory UddSchemaRule.fromJson(Map<String, dynamic> json) {
    return UddSchemaRule(
      id: json['id'] as String? ?? 'UDD-000',
      title: json['title'] as String? ?? 'Unknown Rule',
      status: json['status'] as String? ?? 'Inactive',
      severity: json['severity'] as String? ?? 'Low',
      description: json['description'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String status;
  final String severity;
  final String description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'severity': severity,
        'description': description,
      };
}

/// Log item for Poka-Yoke Error Queueing.
class SyncErrorLog {
  SyncErrorLog({
    required this.timestamp,
    required this.errorMessage,
    required this.attemptCount,
  });

  final DateTime timestamp;
  final String errorMessage;
  final int attemptCount;
}

/// Simulated Local Storage & Cache Repository (Shared Preferences / Hive equivalent).
class UddLocalCacheRepository {
  // In-memory persistent cache backing
  static String? _storedJson;
  static DateTime? _lastSyncedTime;

  /// Default fallback rulebook guaranteeing 100% offline operational success.
  static final Map<String, dynamic> _fallbackDefaultSchema = {
    'version': '2.4.0-OFFLINE-FALLBACK',
    'lastSynced': DateTime.now().toIso8601String(),
    'rules': [
      {
        'id': 'UDD-101',
        'title': 'Perimeter Schema Validation Gate',
        'status': 'Active (Cached)',
        'severity': 'High',
        'description': 'Offline cached rule: Enforces perimeter schema validation on incoming JSON payloads.',
      },
      {
        'id': 'UDD-102',
        'title': 'Rate Limit Enforcer',
        'status': 'Active (Cached)',
        'severity': 'Medium',
        'description': 'Offline cached rule: Throttles rapid API requests beyond 100 req/min.',
      },
      {
        'id': 'UDD-103',
        'title': 'Payload Size Guardrail',
        'status': 'Active (Cached)',
        'severity': 'Critical',
        'description': 'Offline cached rule: Rejects payloads exceeding 10MB threshold with HTTP 413.',
      },
    ],
  };

  /// Save raw JSON to local cache.
  static Future<void> saveToCache(String jsonPayload) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate IO write
    _storedJson = jsonPayload;
    _lastSyncedTime = DateTime.now();
  }

  /// Load cached JSON or fallback rulebook.
  static Future<Map<String, dynamic>> loadFromCache() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate IO read
    if (_storedJson != null && _storedJson!.isNotEmpty) {
      return jsonDecode(_storedJson!) as Map<String, dynamic>;
    }
    // Return fallback rulebook if local storage is fresh
    return _fallbackDefaultSchema;
  }

  static DateTime? get lastSyncedTime => _lastSyncedTime;
}

/// Initial launch screen component implementing Offline-First UDD API Sync.
class OfflineUddSyncWorkspace extends StatefulWidget {
  const OfflineUddSyncWorkspace({super.key});

  @override
  State<OfflineUddSyncWorkspace> createState() => _OfflineUddSyncWorkspaceState();
}

class _OfflineUddSyncWorkspaceState extends State<OfflineUddSyncWorkspace>
    with SingleTickerProviderStateMixin {
  // Requirement 2: Non-Blocking Skeleton UI state variable
  bool _isSyncing = true;
  bool _isOfflineMode = false;

  // Active loaded schema rules & metadata
  List<UddSchemaRule> _schemaRules = [];
  String _schemaVersion = 'Unknown';
  String _dataSourceOrigin = 'Initializing...';

  // Requirement 4: Error Queueing (Poka-Yoke)
  final List<SyncErrorLog> _errorRetryQueue = [];
  int _syncAttemptCounter = 0;

  // Shimmer Animation Controller for custom non-blocking skeleton loader
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Requirement 1: Call syncUddSchema() during initState
    syncUddSchema();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  /// Requirement 1: Background Fetch & Cache Logic with Poka-Yoke error queue fallback
  Future<void> syncUddSchema() async {
    setState(() {
      _isSyncing = true;
      _syncAttemptCounter++;
    });

    try {
      // Simulate network request delay (2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      // Simulate network disconnection or server error if offline toggle is enabled
      if (_isOfflineMode) {
        throw TimeoutException('API Gateway unreachable: 504 Gateway Timeout (Network Offline)');
      }

      // Simulated remote API JSON response payload
      final remoteJsonResponse = jsonEncode({
        'version': '3.1.0-LIVE-SYNC',
        'lastSynced': DateTime.now().toIso8601String(),
        'rules': [
          {
            'id': 'UDD-301',
            'title': 'Dynamic JWT Perimeter Gate',
            'status': 'Live',
            'severity': 'Critical',
            'description': 'Live API rule: Validates perimeter OAuth2 tokens against API Gateway keys.',
          },
          {
            'id': 'UDD-302',
            'title': 'Payload Entropy Inspector',
            'status': 'Live',
            'severity': 'High',
            'description': 'Live API rule: Analyzes incoming binary streams for payload anomaly signatures.',
          },
          {
            'id': 'UDD-303',
            'title': 'Asynchronous Event Buffer',
            'status': 'Live',
            'severity': 'Medium',
            'description': 'Live API rule: Buffers high-throughput telemetry events during server spikes.',
          },
          {
            'id': 'UDD-304',
            'title': 'Strict Zero-Trust CORS Filter',
            'status': 'Live',
            'severity': 'High',
            'description': 'Live API rule: Enforces strict domain perimeter origin headers.',
          },
        ],
      });

      // Parse JSON payload
      final decodedData = jsonDecode(remoteJsonResponse) as Map<String, dynamic>;

      // Requirement 1: Cache JSON locally upon successful fetch
      await UddLocalCacheRepository.saveToCache(remoteJsonResponse);

      if (!mounted) return;

      _applySchemaData(decodedData, origin: 'Live API Gateway (Cached to Disk)');
    } catch (error) {
      // Requirement 4: Catch error gracefully without crashing & queue in retry log
      final errorLog = SyncErrorLog(
        timestamp: DateTime.now(),
        errorMessage: error.toString(),
        attemptCount: _syncAttemptCounter,
      );
      _errorRetryQueue.add(errorLog);

      // Requirement 1 & 4: Fall back immediately to local cached JSON rulebook
      final cachedData = await UddLocalCacheRepository.loadFromCache();

      if (!mounted) return;

      _applySchemaData(
        cachedData,
        origin: 'Offline Local Cache (100% Operational Fallback)',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _applySchemaData(Map<String, dynamic> data, {required String origin}) {
    final rulesList = (data['rules'] as List<dynamic>?)
            ?.map((e) => UddSchemaRule.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    setState(() {
      _schemaRules = rulesList;
      _schemaVersion = data['version'] as String? ?? '1.0.0';
      _dataSourceOrigin = origin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First UDD Sync'),
        actions: [
          IconButton(
            tooltip: 'Trigger Re-Sync',
            icon: const Icon(Icons.sync),
            onPressed: _isSyncing ? null : syncUddSchema,
          ),
        ],
        // Requirement 3: Sync Indicator at top of screen / AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: _buildSyncHeaderIndicator(colorScheme),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Control Header
                    _buildStatusHeaderCard(colorScheme),
                    const SizedBox(height: 16.0),

                    Text(
                      'Active UDD Rulebook Rules',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Requirement 2: Non-Blocking Skeleton UI vs Rendered Content
                    if (_isSyncing)
                      _buildSkeletonList(colorScheme)
                    else
                      _buildRulebookList(colorScheme),

                    const SizedBox(height: 24.0),

                    // Requirement 4: Error Queueing Log Card (Poka-Yoke Diagnostics)
                    if (_errorRetryQueue.isNotEmpty) ...[
                      _buildErrorQueueCard(colorScheme),
                      const SizedBox(height: 16.0),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Requirement 3: Sync Indicator - Linear progress indicator and tiny "Syncing..." badge
  Widget _buildSyncHeaderIndicator(ColorScheme colorScheme) {
    if (!_isSyncing) {
      return Container(
        height: 24.0,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHigh,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 14.0, color: colorScheme.primary),
            const SizedBox(width: 6.0),
            Text(
              'Schema Synced & Cached locally',
              style: TextStyle(fontSize: 11.0, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          minHeight: 3.0,
          backgroundColor: colorScheme.surfaceContainerHigh,
          color: colorScheme.primary,
        ),
        Container(
          height: 21.0,
          color: colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10.0,
                height: 10.0,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Syncing UDD Schema in background...',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeaderCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_sync_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Schema Version: $_schemaVersion',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Data Origin: $_dataSourceOrigin',
              style: TextStyle(
                fontSize: 13.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24.0),
            Row(
              children: [
                Text(
                  'Simulate Offline/Network Error:',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isOfflineMode,
                  onChanged: (val) {
                    setState(() {
                      _isOfflineMode = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Requirement 2: Custom Non-Blocking Skeleton UI using Shimmer animation
  Widget _buildSkeletonList(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double opacity = 0.3 + (_shimmerController.value * 0.5);

        return Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: opacity),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 50.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    width: double.infinity,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 200.0,
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRulebookList(ColorScheme colorScheme) {
    return Column(
      children: _schemaRules.map((rule) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      rule.id,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      rule.title,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      rule.severity,
                      style: TextStyle(
                        fontSize: 11.0,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                rule.description,
                style: TextStyle(
                  fontSize: 13.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Requirement 4: Poka-Yoke Error Queue Log View
  Widget _buildErrorQueueCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Poka-Yoke Error Queue (${_errorRetryQueue.length} Logged)',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Network failures were intercepted gracefully. The application instantly fell back to the local cached UDD rulebook without crashing.',
              style: TextStyle(
                fontSize: 12.0,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12.0),
            ..._errorRetryQueue.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    '• Attempt #${log.attemptCount}: ${log.errorMessage}',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
