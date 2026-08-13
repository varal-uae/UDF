# Step 10 of 50 — TTMAC-011

**Atomic Step Reference ID:** `TTMAC-011-A01`  
**Original S. No in the master sheet:** 3095  
**Assigned to:** Fredrick  
**Estimated time:** 6 Hours.  
**Derived status:** **Complete**

> Touch-Target Optimization Framework Setup (48×48 dp Minimum Interaction Nodes).

---

## What was delivered

The touch-target framework: 48x48dp minimum enforced by a constructor assert, transparent expansion around small icons, 8dp safety margin between neighbours, long-press for detail.

### Artefacts

- `lib/design_system/interaction/touch_target.dart`
- `test/aiss/ttmac_011_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `TTMAC-011-G1` | 4 Substeps #1: "Define absolute minimum touch-target boundaries (>= 48 x 48 dp) for compact layout elements." | The 48dp floor is defined once, and the compliance predicate rejects anything under it | Active |
| `TTMAC-011-G2` | 4 Substeps #3: "Configure button element grid bounds to preserve an 8 dp safety spacing margin." | Safety margin is 8dp and the separation predicate rejects tighter gaps | Active |
| `TTMAC-011-G3` | Poka-Yoke: "The compile engine throws a validation error if any touch target layout bounds map below 48 dp constraints." | HabotTouchTarget carries a constructor assert that rejects a sub-48dp minSize before anything renders | Active |
| `TTMAC-011-G4` | What Standardized Must Be Done: "Adherence to core interactive component parameters." + Completion Measures: 100% of interactive elements >= 48dp. | No file under lib/ builds a raw IconButton or GestureDetector outside the sanctioned interaction module | Active |
| `TTMAC-011-G5` | Completion Measures: "100% of deployed interactive elements maintain physical tap boundaries >= 48 x 48 dp." | Every touch target rendered by the app at 320 / 393 / 1024dp measures at least 48dp on its shortest side | Active |
| `TTMAC-011-G6` | 4 Substeps #3: "preserve an 8 dp safety spacing margin." | HabotTouchRow renders adjacent targets with a measured gap of at least 8dp | Active |
| `TTMAC-011-G7` | 4 Substeps #2: "Inject transparent target expansion boxes around micro-icons or selector ticks." + #4: "Map long-press interaction paths to reveal detailed tooltips." | A 12dp icon renders at 12dp but is wrapped in a >=48dp tap area, and long-press surfaces the detail tooltip | Active |

## Metric result

| | |
|---|---|
| **Metric** | Environment / Asset Access Readiness |
| **Floor** | Located on first attempt |
| **Optimal** | Path version-controlled & documented |
| **Ceiling** | N/A (one-time setup) |
| **Observed** | all rendered targets measured >= 48dp across 3 device profiles |
| **Output scale** | Complete / Partial / Not Complete |

## Expected Output (from the sheet)

> Native touch target component configuration library files.

## Completion Measure (from the sheet)

> 100% of deployed interactive elements maintain physical tap boundaries $\ge 48 \times 48\text{ dp}$.

## Mistake-proofing, as implemented

> The compile engine throws an validation error if any touch target layout bounds map below $48\text{ dp}$ constraints.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Hit-box expansion accepted.** Small icons keep their visual size and gain a transparent 48dp target rather than growing to 48dp of ink.

---

*Generated from the master sheet and `test/aiss/ttmac_011_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
