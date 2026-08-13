# Step 32 of 35 — CPNCA-006

**Atomic Step Reference ID:** `CPNCA-006-A01`  
**Original S. No in the master sheet:** 2468  
**Assigned to:** Fredrick  
**Estimated time:** 12 Hours  
**Derived status:** **Complete**

> Build a standardized list virtualization and dynamic data chunking component for data tables Operationalizing System Architecture Design].

---

## What was delivered

List virtualisation with chunked fetching: batches of 20, prefetch inside a documented threshold, duplicate-fetch suppression, a structural placeholder row at the seam and a terminal empty state. At 10,000 records the materialised row count stays flat.

### Artefacts

- `lib/design_system/layout/virtualized_list.dart`
- `lib/design_system/tokens/surface_tokens.dart`
- `test/aiss/cpnca_006_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `CPNCA-006-G1` | 4 Substeps #2: "Implement data partitioning hooks that fetch record batches (e.g., 20 items per request) RATHER THAN LOADING ENTIRE DATASETS AT ONCE." | Two loads fetch exactly two batches of the token chunk size, at the right offsets, out of a 10,000-record source | Active |
| `CPNCA-006-G2` | 4 Substeps #2 -- partitioning only holds if a fast scroll cannot stack overlapping fetches for the same offset. | Three concurrent load requests result in exactly one call to the source | Active |
| `CPNCA-006-G3` | 4 Substeps #1: "Author a container component that calculates visible viewport boundaries using real-time scroll tracking." | The next chunk is requested only when the viewport reaches within the prefetch threshold of the loaded window, and never once the source is exhausted | Active |
| `CPNCA-006-G4` | Decision to be Made Before Setup Step: "Choose between using infinite scrolling mechanics or clear 'Load More' action flags based on data accessibility needs." | The decision is recorded in the source, and both modes are reachable from one component rather than two | Active |
| `CPNCA-006-G5` | Completion Measures: "Loading a test collection of 10,000 items preserves a consistent, low DOM element count during continuous scrolling." + 4 Substeps #4: "Verify element counts remain stable during continuous scrolling." | Across twelve continuous drags of a 10,000-record list the materialised row count stays under the documented ceiling and the dataset is never fully resident | Active |
| `CPNCA-006-G6` | 4 Substeps #3: "Create structural placeholder rows for records still loading." | While a chunk is in flight the seam shows a placeholder row of the same height, which is replaced by the records when they arrive | Active |
| `CPNCA-006-G7` | Setup Step (Action): "...for data tables." A table with no rows still has to say something. + GEN-01297, consumed. | An exhausted source produces the empty state after exactly one fetch, with no retry loop | Active |

## Metric result

| | |
|---|---|
| **Metric** | Requirements / Discovery Coverage (%) |
| **Floor** | 90% of relevant items identified |
| **Optimal** | 98% of relevant items identified |
| **Ceiling** | 100% of relevant items identified |
| **Observed** | 100% -- all four substeps and the 10,000-item completion measure gated; materialised rows stay under the documented ceiling |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> Virtualized scrolling component suite live and running across core list views.

## Completion Measure (from the sheet)

> Loading a test collection of 10,000 items preserves a consistent, low DOM element count during continuous scrolling.

## Decisions and open items

**Decision recorded:** *'infinite scrolling mechanics or clear Load More action flags'* -> infinite scroll with a visible loading row at the seam, plus an explicit Load-more mode behind a flag. Infinite is right for a task queue someone works down; manual is right for a table someone is auditing, where an automatic fetch moves the ground under them. One component, one flag -- not two components.

---

*Generated from the master sheet and `test/aiss/cpnca_006_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
