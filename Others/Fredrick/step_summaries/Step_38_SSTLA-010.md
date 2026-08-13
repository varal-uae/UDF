# Step 38 of 50 - SSTLA-010

**Atomic Step Reference ID:** `SSTLA-010-A01`  
**Original S. No in the master sheet:** 3161  
**Assigned to:** Fredrick  
**Estimated time:** 8 Hours  
**Derived status:** **Complete**

> Formulate the responsive split-screen grid distributions and layout rules for Micro Task Outsourcing (MTO) panels to maximize readability on small devices.

---

## What was delivered

Pane distribution and the pinned metric strip. Column counts inside a pane are derived from the shared grid rather than declared, so a pane can never claim more columns than the screen has. The metric strip is outside the scroll view by construction: the poka-yoke is not 'remember to pin it', it is that there is no way to put it inside.

### Artefacts

- `lib/design_system/shell/pane_distribution.dart`
- `test/aiss/sstla_010_test.dart` - the gates for this step

## Requirement -> gate mapping

**5 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `SSTLA-010-G1` | Mobile App First Implication: "Replaces wide side-by-side desktop grids with clean, thumb-friendly VERTICAL STACKS tailored for mobile interaction." | A pane on a compact viewport is a single column of full-width rows; two fields per row only once there is room for them | Active |
| `SSTLA-010-G2` | Self-Chasing: "Hardcoding layout values across screens creates broken, overlapping UI elements on smaller devices, instantly stalling qa cycles." | Column counts inside a pane are derived from the shared grid rather than declared: a pane never claims more columns than the screen has, and never fewer than the compact minimum | Active |
| `SSTLA-010-G3` | Setup Step (Action): "...to MAXIMIZE READABILITY." + Why This Matters: "constant pinching and zooming, causing fast operator fatigue." | The readable measure is a stated number rather than a hope, and the pinned strip is capped so it cannot grow into a header | Active |
| `SSTLA-010-G4` | Poka-Yoke: "Key source metrics are pinned immovably at the top of the viewport, keeping important details visible while filling out long fields." | After scrolling 400dp of fields the metric strip has not moved and its values are still on screen | Active |
| `SSTLA-010-G5` | Poka-Yoke -- a strip that grows without limit stops being a pinned detail and becomes a header, which is the scrolling problem this step exists to remove. | Six metrics render as four: the cap is applied by the component, not left to the caller | Active |

## Metric result

| | |
|---|---|
| **Metric** | Requirement & Asset Discovery Coverage (%) — core visual content requirements for Micro Task |
| **Floor** | 0.9 |
| **Optimal** | 1.0 |
| **Ceiling** | 1.0 |
| **Observed** | 1.0 -- the vertical-stack rule, the derived column counts, the readable measure and the pinned-metric poka-yoke are all gated, the last by scrolling a real tree (Completion Measures column empty in the sheet -- recorded) |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> High-fidelity layout templates built for phone and tablet screens.

## Completion Measure (from the sheet)

> None

## Mistake-proofing, as implemented

> Key source metrics are pinned immovably at the top of the viewport, keeping important details visible while filling out long fields.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Empty Completion Measures column, recorded:** this row's Completion Measures cell is blank in the sheet. The gates defend the Setup Step, the Mobile-First row, the poka-yoke and the self-chasing rule, which are all populated. Nothing was invented to fill the gap.

---

*Generated from the master sheet and `test/aiss/sstla_010_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
