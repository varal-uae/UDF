-- GEN-00509 — Verify attribution logs land in BigQuery analytics.mmp_installs.
-- Metric: BigQuery Ingestion Delay · Pass/Fail.
-- PASS if rows have arrived within the last hour.
SELECT COUNT(*) AS recent_rows
FROM `analytics.mmp_installs`
WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);
