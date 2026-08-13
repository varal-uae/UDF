# Step 5 of 50 — SSTLA-004

**Atomic Step Reference ID:** `SSTLA-004-A01`  
**Original S. No in the master sheet:** 169  
**Assigned to:** Fredrick  
**Estimated time:** 4 Hours  
**Derived status:** **Complete (objective) - reviewer score pending**

> Define the exact base breakpoint, column count, fluid margin, and gutter widths for the core mobile experience before scaling upward to tablet or desktop views.

---

## What was delivered

The breakpoint decision record: base breakpoint, column count, margin and gutter fixed and written to device_matrix.json alongside a 9-device target matrix. Plus an interactive wireframe overlay so the decision can be seen rather than argued about.

### Artefacts

- `lib/design_system/tokens/device_matrix.json`
- `lib/design_system/layout/device_profiles.dart`
- `lib/design_system/layout/grid_wireframe.dart`
- `test/aiss/sstla_004_test.dart` — the gates for this step

## Requirement -> gate mapping

**8 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `SSTLA-004-G1` | Setup Step (Action): "Define the exact base breakpoint, column count, fluid margin, and gutter widths for the core mobile experience." | All four values are decided, recorded in the JSON, and match the code | Active |
| `SSTLA-004-G2` | Setup Step Description: "Collate cross-device screen resolution metrics for target mobile, tablet, and desktop viewports." | Matrix covers mobile, tablet and desktop, and every device carries all five required atomic data fields | Active |
| `SSTLA-004-G3` | Why This Matters: "preventing viewport overflow bugs ... across varying mobile viewports." + User Interaction: "Prevents accidental visual clipping of primary CTAs on tight displays." | At every device width in the matrix, one grid column is still wide enough to hold a 48dp touch target | Active |
| `SSTLA-004-G4` | CONFLICT RESOLUTION -- RCGLA-012 says "16px ... with an 8px gutter grid system"; RCGLA-032 substep 1 says "16px outer margin and a 16px column gutter". Resolved into two tokens. | Column gutter is 16dp, vertical rhythm is 8dp, and the resolution is documented in the JSON rather than left implicit | Active |
| `SSTLA-004-G5` | Expected Output: "Approved JSON Token File". | Every device in device_matrix.json is mirrored exactly in Dart | Active |
| `SSTLA-004-G6` | Metric: "Task Execution Quality Score (1-5 scale)" -- Floor 3.5, Optimal 4.5, Ceiling 5.0. Standard/Reference: "scored by a reviewer against a defined rubric." | Objective rubric coverage reaches 5.0/5.0 (the reviewer score is a separate human input and is NOT self-awarded here) | Active |
| `SSTLA-004-G7` | Expected Output: "an interactive structural layout wireframe for compact mobile devices." | Wireframe overlay paints the grid at 320dp and passes pointers through to the content beneath | Active |
| `SSTLA-004-G8` | Why This Matters: "Eliminates arbitrary layout configurations across team members." | The on-screen readout is generated from the tokens, so it can never disagree with the decision record | Active |

## Metric result

| | |
|---|---|
| **Metric** | Task Execution Quality Score (1-5 scale) — Collate cross-device screen resolution metrics for target |
| **Floor** | 3.5 |
| **Optimal** | 4.5 |
| **Ceiling** | 5.0 |
| **Observed** | objective rubric 5.0/5.0; REVIEWER SCORE PENDING (human input required) |
| **Output scale** | Good/Average/Poor |

## Expected Output (from the sheet)

> Approved JSON Token File and an interactive structural layout wireframe for compact mobile devices.

## Mistake-proofing, as implemented

> Auto-rejection of any pull request containing hardcoded pixel layout values via rigid Stylelint/ESLint AST parsing checks.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Gutter contradiction resolved.** RCGLA-012 says "16px with an 8px gutter"; RCGLA-032 says "16px outer margin and a 16px column gutter". Split into two tokens: column gutter 16dp (RCGLA-032, named explicitly) and vertical rhythm 8dp (what RCGLA-012's own UX Translation row describes). Recorded in device_matrix.json. **The source sheet should be reconciled.**

**Reviewer score pending.** The metric is a 1-5 quality score "scored by a reviewer". The objective half is 5.0/5.0; a human owes the execution-quality half.

---

*Generated from the master sheet and `test/aiss/sstla_004_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
