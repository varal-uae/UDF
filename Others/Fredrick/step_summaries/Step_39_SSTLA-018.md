# Step 39 of 50 - SSTLA-018

**Atomic Step Reference ID:** `SSTLA-018-A01`  
**Original S. No in the master sheet:** 2105  
**Assigned to:** Fredrick  
**Estimated time:** 16 Hours.  
**Derived status:** **Complete**

> Formulating the responsive layout rules to organize parent command sections on 5.5-inch mobile viewports.

---

## What was delivered

The 5.5-inch reference viewport, pinned in both units -- 1080x1920 physical at DPR 3 is 360x640dp -- plus the thumb band as a stated fraction and the command-section locking rule. A section declares what it depends on; the grid derives whether it may be touched. There is no flag a caller can pass to open a section early.

### Artefacts

- `lib/design_system/shell/dashboard_grid.dart`
- `test/aiss/sstla_018_test.dart` - the gates for this step

## Requirement -> gate mapping

**6 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `SSTLA-018-G1` | Setup Step Description: "Identify target 5.5-inch mobile viewport dimensions and resolution constraints (e.g., 1080x1920 pixels at 16:9)." | The reference viewport is pinned in both units: 1080x1920 physical at a pixel ratio of 3 is 360x640dp, and the 16:9 aspect is stated rather than implied | Active |
| `SSTLA-018-G2` | Mobile App First Implication: "Screen elements must collapse into VERTICAL LAYOUT STACKS to eliminate horizontal scroll glitches." + GEN-00022: "single-column or 2x2 grid on mobile." | The reference viewport gets one column; two only once the screen is no longer compact -- there is no three-column dashboard on a phone, because the third column is where horizontal scrolling comes from | Active |
| `SSTLA-018-G3` | Flow Impact: "Navigation bars sit comfortably within standard thumb interaction spaces." | The thumb band is a stated fraction of the viewport, and a control anchored to the bottom edge of the reference device falls inside it while one at the top does not | Active |
| `SSTLA-018-G4` | Poka-Yoke: "Selection items lock automatically if required preceding details stay empty." | Locking is derived from declared prerequisites, and completing one unlocks exactly the next -- no caller can pass a flag to open a section early | Active |
| `SSTLA-018-G5` | Mobile App First Implication: "Screen elements must collapse into vertical layout stacks to eliminate horizontal scroll glitches." Measured on the reference device the step names. | At 1080x1920 / DPR 3 the command sections render as a single column with no layout exception | Active |
| `SSTLA-018-G6` | Poka-Yoke: "Selection items lock automatically if required preceding details stay empty." | An unlocked section reports its tap and a locked one swallows it, while announcing why it is locked | Active |

## Metric result

| | |
|---|---|
| **Metric** | Requirement & Asset Discovery Coverage (%) — target 5.5-inch mobile viewport dimensions and resolution |
| **Floor** | 0.9 |
| **Optimal** | 1.0 |
| **Ceiling** | 1.0 |
| **Observed** | 1.0 -- the reference viewport pinned in physical and logical units, the stacking rule at every breakpoint, the thumb band as a stated fraction, and locking enforced by derivation rather than by a flag |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> Mobile Dashboard Grid Spec.

## Completion Measure (from the sheet)

> None

## Mistake-proofing, as implemented

> Selection items lock automatically if required preceding details stay empty.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/sstla_018_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
