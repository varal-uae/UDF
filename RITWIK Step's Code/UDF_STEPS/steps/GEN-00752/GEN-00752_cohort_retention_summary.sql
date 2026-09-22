-- GEN-00752 — analytics.cohort_retention_summary.
-- Metric: Summary Table Freshness · Complete/Not Complete.
CREATE TABLE IF NOT EXISTS `analytics.cohort_retention_summary` (
  cohort_date DATE NOT NULL,
  day_offset INT64 NOT NULL,
  users INT64,
  retained INT64,
  retention_rate FLOAT64
) PARTITION BY cohort_date;
