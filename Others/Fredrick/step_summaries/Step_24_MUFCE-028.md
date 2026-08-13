# Step 24 of 50 — MUFCE-028

**Atomic Step Reference ID:** `MUFCE-028-A01`  
**Original S. No in the master sheet:** 1786  
**Assigned to:** Fredrick  
**Estimated time:** 2 Days  
**Derived status:** **Complete**

> Mandatory removal of all mouse hover tooltips and replacement with touch long-press modal sheets.

---

## What was delivered

Hover, removed. Every tooltip widget and hover callback is gone from lib/ and cannot come back -- two poka-yoke rules fail the build if either reappears. Rich metadata now opens in a bottom drawer through HabotMetadataDisclosure, reachable by long-press on the label or a quick tap on a 48dp trailing icon. The header's overflow menu became a sheet, because the framework's popup menu button always carries a tooltip and gives no way to switch it off.

### Artefacts

- `lib/design_system/surfaces/metadata_disclosure.dart`
- `lib/design_system/interaction/touch_target.dart`
- `lib/design_system/navigation/contextual_header.dart`
- `test/guards/poka_yoke_no_hardcoded_values_test.dart`
- `test/aiss/mufce_028_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `MUFCE-028-G1` | 4 Substeps #1: "Strip all .onHover logic actions from mobile codebase templates." + Setup Step: "Mandatory removal of ALL mouse hover tooltips." | Zero hover callbacks and zero Tooltip widgets exist anywhere under lib/ -- the removal is complete, not partial | Active |
| `MUFCE-028-G2` | Setup Step: "...replacement with touch long-press modal sheets." A removal with no replacement loses the information. | The replacement exists and is the only metadata route: HabotMetadataDisclosure opens the bottom drawer, and it is what the touch target now calls | Active |
| `MUFCE-028-G3` | Metric: Environment / Asset Access Readiness. Floor "Located on first attempt", Optimal "Path version-controlled & documented". | The replacement component sits at one documented, version-controlled path, named in the codebase README | Active |
| `MUFCE-028-G4` | 4 Substeps #2: "Bind formula lookup scripts to explicit touch-and-hold gestures." + #3: "Route rich metadata descriptions to smooth bottom drawer overlays." | Long-press on a touch target opens the metadata drawer carrying the detail text, with no tooltip anywhere in the tree | Active |
| `MUFCE-028-G5` | 4 Substeps #2: "Bind FORMULA LOOKUP scripts to explicit touch-and-hold gestures." + #3: "Route RICH metadata descriptions to smooth bottom drawer overlays." | The drawer presents description, derivation formula and source together -- the full metadata, not a truncated phrase | Active |
| `MUFCE-028-G6` | 4 Substeps #4: "Set up an alternative quick-tap option icon next to dynamic labels." | The trailing disclosure icon is a compliant touch target and a single tap opens the same drawer the long-press does | Active |
| `MUFCE-028-G7` | Setup Step: "Mandatory removal of ALL mouse hover tooltips." + ANSA-012 UX row: "Hide excessive, low-priority shortcut items inside unified trailing overflow menus on tight displays." | The header overflow opens as a bottom drawer and no PopupMenuButton (which the framework always wraps in a Tooltip) remains under lib/ | Active |

## Metric result

| | |
|---|---|
| **Metric** | Environment / Asset Access Readiness |
| **Floor** | Located on first attempt |
| **Optimal** | Path version-controlled & documented |
| **Ceiling** | N/A (one-time setup) |
| **Observed** | Path version-controlled and documented; hover reintroduction blocked by the guard |
| **Output scale** | Complete / Partial / Not Complete |

## Expected Output (from the sheet)

> Asset Loading Optimization Plan.

## Completion Measure (from the sheet)

> Interface payloads scale down properly during limited-bandwidth test cycles.

## Decisions and open items

**Contaminated columns, excluded from gating:** this row's Expected Output reads *'Asset Loading Optimization Plan'* and its Completion Measure is about bandwidth test cycles. Neither belongs to a tooltip step and neither is gated. The Setup Step, the four substeps and the metric are coherent and are what the implementation is measured against.

**Framework consequence:** the header overflow menu had to be rebuilt as a sheet, because Flutter's popup menu button wraps itself in a tooltip unconditionally.

---

*Generated from the master sheet and `test/aiss/mufce_028_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
