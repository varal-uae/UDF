// CTTEE-024 — Grievance Resolution 30-Minute SLA Action Card.
// Features a persistent countdown timer, 25-minute escalation alert, and high-contrast breach styling.

import 'dart:async';
import 'package:flutter/material.dart';

class GrievanceSlaCard extends StatefulWidget {
  const GrievanceSlaCard({
    super.key,
    required this.grievanceId,
    required this.title,
    required this.createdAt,
    required this.onEscalate,
    this.slaDuration = const Duration(minutes: 30),
  });

  final String grievanceId;
  final String title;
  final DateTime createdAt;
  final VoidCallback onEscalate;
  final Duration slaDuration;

  @override
  State<GrievanceSlaCard> createState() => _GrievanceSlaCardState();
}

class _GrievanceSlaCardState extends State<GrievanceSlaCard> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final deadline = widget.createdAt.add(widget.slaDuration);
    final diff = deadline.difference(DateTime.now());
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBreached = _remaining == Duration.zero;
    final isNearBreach = !isBreached && _remaining.inMinutes <= 5; // Under 5 minutes left (25 min mark reached)

    final minutesStr = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secondsStr = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Card(
      color: isBreached ? cs.errorContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBreached ? cs.error : (isNearBreach ? cs.tertiary : cs.outlineVariant),
          width: isBreached || isNearBreach ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grievance #${widget.grievanceId}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isBreached ? cs.onErrorContainer : cs.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
                // High contrast timer badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBreached ? cs.error : (isNearBreach ? cs.tertiaryContainer : cs.primaryContainer),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: isBreached ? cs.onError : (isNearBreach ? cs.onTertiaryContainer : cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBreached ? 'SLA BREACHED' : '$minutesStr:$secondsStr',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isBreached ? cs.onError : (isNearBreach ? cs.onTertiaryContainer : cs.onPrimaryContainer),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isBreached ? cs.onErrorContainer : cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.onEscalate,
              icon: const Icon(Icons.flash_on, size: 18),
              label: Text(isBreached ? 'Immediate Escalation Required' : 'Action Grievance'),
              style: FilledButton.styleFrom(
                backgroundColor: isBreached ? cs.error : null,
                foregroundColor: isBreached ? cs.onError : null,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
