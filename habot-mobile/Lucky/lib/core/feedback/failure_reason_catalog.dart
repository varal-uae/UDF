// IS27-FEBFL-024-AS01-A01 — Operational failure reason catalog.
// Authorized category descriptors for platform breakdown metrics.
// Product/UX Writer can extend labels; keys stay stable for analytics.

enum FailureReason {
  slowPerformance('slow_performance', 'Slow loading or response'),
  wrongData('wrong_data', 'Incorrect or missing data'),
  appCrash('app_crash', 'App crashed or froze'),
  confusingUI('confusing_ui', 'Hard to find what I needed'),
  loginIssue('login_issue', 'Sign-in or permission problem'),
  notificationIssue('notification_issue', 'Alerts or notifications issue'),
  billingIssue('billing_issue', 'Billing or payment problem'),
  other('other', 'Other operational issue');

  const FailureReason(this.key, this.label);

  final String key;
  final String label;
}

/// Score threshold — diagnostic form appears when rating <= this value.
const int lowRatingThreshold = 3;

abstract class FailureReasonCatalog {
  static const all = FailureReason.values;

  static FailureReason? byKey(String key) {
    for (final r in all) {
      if (r.key == key) return r;
    }
    return null;
  }
}

/// Submitted low-rating diagnostic payload.
class RatingDiagnosticPayload {
  const RatingDiagnosticPayload({
    required this.score,
    required this.reasons,
    required this.details,
    required this.timestamp,
  });

  final int score;
  final List<FailureReason> reasons;
  final String details;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'score':     score,
        'reasons':   reasons.map((r) => r.key).toList(),
        'details':   details,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}
