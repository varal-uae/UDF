# GEN-00564 — Verify 0 orphan nodes in analytics.lineage_graph (initial test dataset)
Metric: Orphan Node Count · Pass/Fail

**Operational / verification step — not a source file.** Recorded for traceability.

## Action
Run the lineage orphan scan (see sql/GEN-00708) on the initial test dataset. PASS only if it returns 0 rows.
