-- GEN-00652 — Alert rule: warn if unallocated attribution totals exist.
-- Metric: Alert Rule Coverage · Pass/Fail (PASS = 0 unallocated).
SELECT COUNT(*) AS unallocated
FROM `analytics.attribution`
WHERE channel IS NULL OR channel = 'unallocated';
