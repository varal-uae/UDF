-- GEN-00708 — Flag missing links / dead-end fields as lineage errors.
-- Metric: Lineage Integrity · Pass/Fail (PASS = 0 rows returned).
SELECT n.node_id
FROM `analytics.lineage_graph` n
LEFT JOIN `analytics.lineage_graph` e ON n.node_id = e.parent_id
WHERE e.parent_id IS NULL AND n.is_terminal = FALSE;
