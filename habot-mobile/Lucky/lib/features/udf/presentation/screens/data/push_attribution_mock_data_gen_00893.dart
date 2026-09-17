// GEN-00893 — Mock Data: Short realistic samples for push attribution cards and KPI rendering.

import '../models/push_attribution_event_gen_00893.dart';

/// Provides deterministic mock events for the engineering console preview.
class PushAttributionMockData {
  const PushAttributionMockData._();

  /// Sample dispatched conversion events used to seed the read-only M3 KPI cards.
  static List<PushAttributionEvent> sampleEvents() {
    final DateTime base = DateTime.utc(2024, 6, 12, 9, 0, 0);
    return <PushAttributionEvent>[
      PushAttributionEvent(
        eventId: 'evt_8f31a2',
        sessionId: 'sess_1042',
        campaignId: 'camp_summer_push',
        traceId: 'trc_a91f0c',
        eventTimestamp: base,
        channel: PushEngagementChannel.push,
        latencyMs: 12,
        completionStatus: CompletionStatus.pass,
      ),
      PushAttributionEvent(
        eventId: 'evt_2c77b4',
        sessionId: 'sess_2087',
        campaignId: 'camp_loyalty_re',
        traceId: 'trc_b02d1e',
        eventTimestamp: base.add(const Duration(minutes: 4)),
        channel: PushEngagementChannel.deepLink,
        latencyMs: 38,
        completionStatus: CompletionStatus.pass,
      ),
      PushAttributionEvent(
        eventId: 'evt_51ad09',
        sessionId: 'sess_3311',
        campaignId: 'camp_cart_recovery',
        traceId: 'trc_c77aa3',
        eventTimestamp: base.add(const Duration(minutes: 11)),
        channel: PushEngagementChannel.inApp,
        latencyMs: 84,
        completionStatus: CompletionStatus.fail,
      ),
    ];
  }
}
