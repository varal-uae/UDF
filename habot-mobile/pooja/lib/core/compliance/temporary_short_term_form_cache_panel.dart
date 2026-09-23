import 'dart:async';
import 'package:flutter/material.dart';

/// Row 263: FIEVR-044-A11 (Seq 15721)
/// Action: Save partially compiled form properties safely into temporary short-term caches during loops.
/// Quality Gate: 90% floor, 98% target, 100% ceiling (ISO/DAMA auditable).
class TemporaryShortTermFormCachePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const TemporaryShortTermFormCachePanel({
    super.key,
    this.globalRefId = 'FIEVR-044',
    this.atomicStepRefId = 'FIEVR-044-A11',
    this.sequenceOrder = 15721,
  });

  @override
  State<TemporaryShortTermFormCachePanel> createState() =>
      _TemporaryShortTermFormCachePanelState();
}

class _TemporaryShortTermFormCachePanelState
    extends State<TemporaryShortTermFormCachePanel> {
  final Map<String, dynamic> _shortTermCache = {};
  final List<String> _cacheAuditLog = [];
  final TextEditingController _fieldKeyController =
      TextEditingController(text: 'entity_reg_prop');
  final TextEditingController _fieldValController =
      TextEditingController(text: 'draft_active_val');
  int _cacheWriteCount = 0;
  int _cacheEvictionSeconds = 120;
  Timer? _countdownTimer;
  bool _isAutoSaveLoopActive = false;
  Timer? _loopTimer;

  @override
  void initState() {
    super.initState();
    _populateInitialCache();
    _startCacheTtlTimer();
  }

  void _populateInitialCache() {
    _shortTermCache['tenant_code'] = 'HB-ENT-902';
    _shortTermCache['workflow_step'] = 'STAGE_2_VERIFY';
    _shortTermCache['checksum_nonce'] = '44A11-X8F';
    _cacheAuditLog.add(
        '[INIT] Pre-cached 3 initial properties safely into volatile RAM buffer.');
  }

  void _startCacheTtlTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_cacheEvictionSeconds > 0) {
          _cacheEvictionSeconds--;
        } else {
          _shortTermCache.clear();
          _cacheAuditLog.add(
              '[TTL_EXPIRED] Cache cleared automatically to protect heap memory.');
          _cacheEvictionSeconds = 120;
        }
      });
    });
  }

  void _toggleAutoSaveLoop() {
    setState(() {
      _isAutoSaveLoopActive = !_isAutoSaveLoopActive;
    });
    if (_isAutoSaveLoopActive) {
      _loopTimer?.cancel();
      _loopTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (!mounted) return;
        _commitCurrentDraftToCache();
      });
      _cacheAuditLog.add('[LOOP_START] Autonomous short-term cache sync cycle active (1.5s).');
    } else {
      _loopTimer?.cancel();
      _cacheAuditLog.add('[LOOP_STOP] Autonomous sync loop suspended by user.');
    }
  }

  void _commitCurrentDraftToCache() {
    final key = _fieldKeyController.text.trim();
    final val = _fieldValController.text.trim();
    if (key.isEmpty) return;

    setState(() {
      final nonce = DateTime.now().millisecondsSinceEpoch % 10000;
      _shortTermCache[key] = '$val (t=$nonce)';
      _cacheWriteCount++;
      _cacheAuditLog.insert(
        0,
        '[WRITE #$_cacheWriteCount] Cached property "$key" -> "${_shortTermCache[key]}"',
      );
      if (_cacheAuditLog.length > 25) {
        _cacheAuditLog.removeLast();
      }
    });
  }

  void _flushCache() {
    setState(() {
      _shortTermCache.clear();
      _cacheAuditLog.insert(0, '[PURGE] Voluntary cache purge executed.');
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _loopTimer?.cancel();
    _fieldKeyController.dispose();
    _fieldValController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.memory_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temporary Form Short-Term Cache',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isAutoSaveLoopActive
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAutoSaveLoopActive ? Colors.green : Colors.amber,
                    ),
                  ),
                  child: Text(
                    _isAutoSaveLoopActive ? 'LOOP ACTIVE' : 'MANUAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isAutoSaveLoopActive ? Colors.green[800] : Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Saves partially compiled form properties safely into temporary short-term caches during loops to eliminate user data loss.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fieldKeyController,
                    decoration: InputDecoration(
                      labelText: 'Property Key',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fieldValController,
                    decoration: InputDecoration(
                      labelText: 'Property Value',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _commitCurrentDraftToCache,
                  icon: const Icon(Icons.save_as_rounded, size: 18),
                  label: const Text('Commit to RAM Cache'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _toggleAutoSaveLoop,
                  icon: Icon(
                    _isAutoSaveLoopActive ? Icons.pause_circle_outline : Icons.loop_rounded,
                    size: 18,
                  ),
                  label: Text(_isAutoSaveLoopActive ? 'Pause Auto-Loop' : 'Start Auto-Loop'),
                ),
                OutlinedButton.icon(
                  onPressed: _flushCache,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Purge Cache'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Cache Keys (${_shortTermCache.length} items | writes: $_cacheWriteCount)',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'TTL Eviction in: ${_cacheEvictionSeconds}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  if (_shortTermCache.isEmpty)
                    const Text('Cache is empty.', style: TextStyle(fontStyle: FontStyle.italic))
                  else
                    ..._shortTermCache.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.key_rounded, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                              '${e.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Expanded(
                              child: Text(
                                '${e.value}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cache Execution Stream Logs:',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _cacheAuditLog.length,
                itemBuilder: (context, index) {
                  return Text(
                    _cacheAuditLog[index],
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
            child: TemporaryShortTermFormCachePanel(),
          ),
        ),
      ),
    ),
  );
}
