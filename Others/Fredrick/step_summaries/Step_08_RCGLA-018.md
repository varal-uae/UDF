# Step 8 of 35 — RCGLA-018

**Atomic Step Reference ID:** `RCGLA-018-A01`  
**Original S. No in the master sheet:** 356  
**Assigned to:** Fredrick  
**Estimated time:** 3 Hours.  
**Derived status:** **Complete**

> RCGLA-018 - Universal Master Layout Architecture for React Components

---

## What was delivered

HabotMasterScaffold - the one scaffold every screen uses. Its constructor deliberately exposes no padding, margin, width or alignment parameter, so a screen physically cannot pass spacing in.

### Artefacts

- `lib/design_system/layout/master_scaffold.dart`
- `lib/app.dart`
- `test/aiss/rcgla_018_test.dart` — the gates for this step

## Requirement -> gate mapping

**6 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `RCGLA-018-G1` | 4 Substeps #1: "Build primary scaffold locking metrics." | The scaffold hard-codes its own margins from tokens and wraps every body in the layout boundary | Active |
| `RCGLA-018-G2` | 4 Substeps #2: "Implement configurable child prop targets." | Scaffold exposes exactly the four content slots and nothing else that could carry layout | Active |
| `RCGLA-018-G3` | 4 Substeps #3: "Block flexible padding assignments." + Poka-Yoke: "Custom local padding declarations are programmatically stripped by central package rules." | HabotMasterScaffold constructor exposes NO padding, margin, width or alignment parameter -- a screen physically cannot pass spacing in | Active |
| `RCGLA-018-G4` | Completion Measures: "Code scanning proves 100% of app instances use wrappers." + 4 Substeps #4: "Force tracks to implement central layouts." | Every screen class discovered under lib/ references HabotMasterScaffold | Active |
| `RCGLA-018-G5` | Poka-Yoke: "Custom local padding declarations are programmatically stripped by central package rules." | No screen file declares its own Scaffold -- the master scaffold is the only one | Active |
| `RCGLA-018-G6` | Atomic Reusability: "Layout systems operate as multi-tenant structural shells." + Data Collected: Audit Trail. | Screens register into an inventory at build time and each sits inside exactly one HabotLayoutBoundary | Active |

## Metric result

| | |
|---|---|
| **Metric** | Scope Coverage / Audit Completeness |
| **Floor** | 80% of relevant items identified |
| **Optimal** | 100% of relevant items identified and logged in an inventory register |
| **Ceiling** | 100% identified, logged, and cross-checked against the design/architecture spec |
| **Observed** | 100% of discovered screens use the master wrapper |
| **Output scale** | Complete |

## Expected Output (from the sheet)

> Production global template forcing visual structure metrics.

## Completion Measure (from the sheet)

> Code scanning proves 100% of app instances use wrappers.

## Mistake-proofing, as implemented

> Custom local padding declarations are programmatically stripped by central package rules.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/rcgla_018_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
