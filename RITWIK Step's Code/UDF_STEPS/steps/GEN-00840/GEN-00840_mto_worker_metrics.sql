-- GEN-00840 — Performance table audit.mto_worker_metrics.
-- Metric: Table Creation Status · Complete/Not Complete.
CREATE TABLE IF NOT EXISTS `audit.mto_worker_metrics` (
  worker_id STRING NOT NULL,
  recorded_at TIMESTAMP NOT NULL,
  latency_ms FLOAT64,
  throughput_rps FLOAT64,
  error_count INT64
) PARTITION BY DATE(recorded_at);
