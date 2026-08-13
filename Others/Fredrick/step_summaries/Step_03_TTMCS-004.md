# Step 3 of 35 — TTMCS-004

**Atomic Step Reference ID:** `TTMCS-004-A01`  
**Original S. No in the master sheet:** 1654  
**Assigned to:** Fredrick  
**Estimated time:** 5 Hours.  
**Derived status:** **Complete**

> TTMCS-004 — Configure Atomic Light/Dark Adaptation Tokens

---

## What was delivered

Light and dark schemes as explicit audited tokens, an OS brightness listener, and a theme container that switches modes without rebuilding widgets that do not read it.

### Artefacts

- `lib/design_system/theme/theme_controller.dart`
- `lib/design_system/theme/habot_theme_scope.dart`
- `lib/design_system/a11y/contrast.dart`
- `lib/design_system/a11y/contrast_audit.dart`
- `test/aiss/ttmcs_004_test.dart` — the gates for this step

## Requirement -> gate mapping

**9 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `TTMCS-004-G1` | 4 Substeps #1: "Set up standard Material Design 3 dynamic color tokens using unified root custom properties." | Both schemes define all 28 MD3 semantic roles, and every token is opaque | Active |
| `TTMCS-004-G2` | Why This Matters: "high ambient sunlight demands high-contrast light layouts, low-light night conditions require deep dark interfaces." | Light surface is genuinely light and dark surface genuinely dark | Active |
| `TTMCS-004-G3` | Completion Measures: "Automated verification confirming a minimum 4.5:1 contrast ratio across all dynamic layout color pairs." | Zero contrast failures across every audited pair in both schemes | Active |
| `TTMCS-004-G4` | Mobile-First UI Decision: "Enforce primary text contrast levels checking out above WCAG AA standard mobile parameters." | Primary body text pairs clear the 7:1 AAA optimum, not just the AA floor | Active |
| `TTMCS-004-G5` | Metric row: "Material Design Density Compliance (dp)" -- Floor 4dp, Optimal 6-8dp padding / 32-48dp row height, Ceiling 12dp. | Shipped dense values sit inside the optimal band, never past the ceiling | Active |
| `TTMCS-004-G6` | Substep #4: "Implement explicit accessibility contrast-checking workflows mapping directly to WCAG AA mobile layout rules." | Contrast engine reproduces the WCAG reference values | Active |
| `TTMCS-004-G7` | 4 Substeps #2: "Write an atomic preference hook listening directly to system dark preferences." | Controller tracks OS brightness in system mode and suppresses notifications when a mode is pinned | Active |
| `TTMCS-004-G8` | 4 Substeps #3: "Build a performance-optimized theme container that switches modes cleanly without triggering full component reflows." | Only widgets that depend on HabotThemeScope rebuild on a theme-mode change | Active |
| `TTMCS-004-G9` | User Interaction / Flow Impact: "Users experience an instantaneous, cohesive theme shift that requires zero manually triggered application configurations." | End-to-end theme switch swaps the live ColorScheme to the dark brand tokens | Active |

## Metric result

| | |
|---|---|
| **Metric** | Material Design Density Compliance (dp) |
| **Floor** | 4dp minimum spacing (Material Design accessibility floor) |
| **Optimal** | 6–8dp padding / 32–48dp row height (Material Design dense-table optimum) |
| **Ceiling** | 12dp (maximum density before readability/touch-target risk) |
| **Observed** | dense padding 8dp, row height 40dp - both inside the sheet's own optimal band |
| **Output scale** | Good / Average / Poor |

## Expected Output (from the sheet)

> Extensively documented Material token map matching English Code specifications perfectly.

## Completion Measure (from the sheet)

> Automated verification confirming a minimum 4.5:1 contrast ratio across all dynamic layout color pairs.

## Mistake-proofing, as implemented

> Style builders throw compilation errors if raw, untokenized hex codes find their way into layout sheets.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/ttmcs_004_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
