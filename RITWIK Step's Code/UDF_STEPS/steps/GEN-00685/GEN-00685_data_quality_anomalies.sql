-- GEN-00685 — Governance log table audit.data_quality_anomalies.
-- Metric: Table Creation Status · Complete/Not Complete.
CREATE TABLE IF NOT EXISTS `audit.data_quality_anomalies` (
  anomaly_id STRING NOT NULL,
  detected_at TIMESTAMP NOT NULL,
  table_ref STRING,
  rule STRING,
  severity STRING,
  details JSON
) PARTITION BY DATE(detected_at);
