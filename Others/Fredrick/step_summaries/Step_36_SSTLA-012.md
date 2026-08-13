# Step 36 of 50 - SSTLA-012

**Atomic Step Reference ID:** `SSTLA-012-A01`  
**Original S. No in the master sheet:** 13776  
**Assigned to:** Fredrick  
**Estimated time:** 5 Hours.  
**Derived status:** **Complete**

> Defining the structural assembly blueprint for the mobile split-screen (Contextual Mirror) layout to present evidence and action panels on small screens.

---

## What was delivered

The Contextual Mirror blueprint: the spec every split-screen container in the app reads. Two pane roles, three arrangements, three split ratios (35/50/65) with a documented cycle order, and a layout validation status that names the tabbed fallback rather than hiding it. All five of the sheet's Data Collected fields -- layout type, grid dimensions, spacing rules, alignment settings and validation status -- come out of one `toDataRecord()`, so the record cannot drift from the layout it describes.

### Artefacts

- `lib/design_system/shell/contextual_mirror.dart`
- `test/aiss/sstla_012_test.dart` - the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `SSTLA-012-G1` | Data Collected by System: "Layout Type; Layout Grid Dimensions; Spacing Rules; Alignment Settings; Layout Validation Status." | A blueprint reading produces all five atomic fields the step names, each populated from the layout rather than restated by hand | Active |
| `SSTLA-012-G2` | User Interaction / Flow Impact: "Double-tapping panel bars snaps views between split ratios instantly." | The ratios are distinct stops and the double-tap cycle visits all three and returns -- so the gesture can never strand the operator on a ratio they cannot leave | Active |
| `SSTLA-012-G3` | Mobile App First Implication: "Maximizes the available layout space by adapting container boxes to compact touch displays." + SSTLA-010 Mobile-First row: compact viewports stack vertically. | The arrangement is a function of the window class the grid tokens already define -- stacked below 600dp, side by side above it -- and not a value any caller can pass in | Active |
| `SSTLA-012-G4` | Expected Output: "Measures of Completion: Mobile views adjust cleanly when rotated, maintaining target sizes across panels." | Every device in the matrix produces a usable layout in BOTH orientations at every ratio, and no pane in a mirror is ever smaller than the minimum extent -- where it would be, the blueprint changes arrangement rather than shrinking the pane | Active |
| `SSTLA-012-G5` | Why This Matters: "Clunky split-screen layouts cause constant scrolling, increasing processing errors." | No viewport ever yields a mirror with a pane below the minimum extent: the smallest device in landscape falls back to tabs, which is recorded as a fallback rather than reported as valid | Active |
| `SSTLA-012-G6` | Poka-Yoke: "Code linters block views that do not extend the master layout wrapper." + Self-Chasing: "Missing layout hooks stop compilation, keeping bad code out of testing builds." | No file under lib/ builds a bare Scaffold: the master wrapper is the only one, and the guard fails the build if a second appears | Active |
| `SSTLA-012-G7` | User Interaction / Flow Impact: "Double-tapping panel bars snaps views between split ratios instantly." + Expected Output: "Unified layout container component files." | Both panes render together on a tablet viewport, and a double-tap on the panel bar moves the split to the next stop on the same frame | Active |

## Metric result

| | |
|---|---|
| **Metric** | Requirement & Asset Discovery Coverage (%) — detailed functional requirements for the mobile |
| **Floor** | 0.9 |
| **Optimal** | 1.0 |
| **Ceiling** | 1.0 |
| **Observed** | 1.0 -- every named requirement gated: five data fields, the double-tap cycle, the window-class rule, rotation across all 9 matrix devices, the minimum pane extent and the master-wrapper linter. 8 of 9 devices mirror in both orientations; the iPhone SE in landscape falls back to tabs, recorded rather than hidden |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> Unified layout container component files.
  Measures of Completion: Mobile views adjust cleanly when rotated, maintaining target sizes across panels.

## Completion Measure (from the sheet)

> None

## Mistake-proofing, as implemented

> Code linters block views that do not extend the master layout wrapper.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Documented fallback, recorded rather than hidden:** an iPhone SE in landscape is 568x320dp. Two panes at the 160dp minimum plus padding and a divider do not fit, so the arrangement resolves to `tabbed` with status `tabbedFallback`. 8 of the 9 matrix devices mirror in both orientations; the ninth is reported, not rounded up.

---

*Generated from the master sheet and `test/aiss/sstla_012_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
