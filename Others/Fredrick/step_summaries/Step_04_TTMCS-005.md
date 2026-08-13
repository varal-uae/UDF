# Step 4 of 35 — TTMCS-005

**Atomic Step Reference ID:** `TTMCS-005-A01`  
**Original S. No in the master sheet:** 3139  
**Assigned to:** Fredrick  
**Estimated time:** 5 Hrs  
**Derived status:** **Complete**

> TTMCS-005 — Mobile Dark Mode Contrast Enforcement

---

## What was delivered

The dark surface elevation ladder: six rungs derived by compositing the primary tint over the dark neutral at documented alphas. Shadows are suppressed in dark mode so layering is carried by the ladder.

### Artefacts

- `lib/design_system/tokens/elevation_tokens.dart`
- `lib/design_system/theme/habot_theme_extension.dart`
- `lib/design_system/a11y/contrast_audit.dart`
- `build/aiss/contrast_audit.txt`
- `test/aiss/ttmcs_005_test.dart` — the gates for this step

## Requirement -> gate mapping

**8 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `TTMCS-005-G1` | 4 Substeps #1: "Surface elevation tokens." + TTMCS-004 UX Decision: "Utilize structural elevation overlays instead of deep drop shadows to indicate component layering in dark configurations." | Dark ladder is strictly lightening across all 6 levels (layering is readable without any shadow) | Active |
| `TTMCS-005-G2` | Atomic Reusability: "Centralized design token parameters managed by a Theme Provider Component stored in the UI Core Lib." | Committed dark surface literals re-derive exactly from the documented overlay alphas (no hand-edited drift) | Active |
| `TTMCS-005-G3` | Poka-Yoke: "Build validation blocks compilation if color ratios test below a hard 4.5:1 ratio threshold." + Metric Floor 4.5:1. | Body text clears the 4.5:1 floor on every rung of the dark elevation ladder, including level 5 | Active |
| `TTMCS-005-G4` | Metric row: Optimal Target "7:1 (WCAG 2.1 Level AAA target)". | Every rung of the dark ladder also clears the 7:1 AAA optimum | Active |
| `TTMCS-005-G5` | Metric row: Ceiling "No upper bound required -- avoid glare/over-contrast beyond 21:1". | No audited pair exceeds the physical 21:1 maximum | Active |
| `TTMCS-005-G6` | 4 Substeps #3: "Brand color adjustments." | Brand roles are re-toned for dark rather than reused from light | Active |
| `TTMCS-005-G7` | TTMCS-004 UX Decision: elevation overlays "instead of deep drop shadows" in dark configurations. | Dark theme suppresses shadow colour and enables the elevation overlay | Active |
| `TTMCS-005-G8` | Expected Output: "CSS Token Variables" (Flutter equivalent: the typed ThemeExtension carried on ThemeData). | HabotTokens exposes the correct ladder for each brightness | Active |

## Metric result

| | |
|---|---|
| **Metric** | WCAG Colour Contrast Ratio |
| **Floor** | 4.5:1 (WCAG 2.1 Level AA minimum for normal text) |
| **Optimal** | 7:1 (WCAG 2.1 Level AAA target) |
| **Ceiling** | No upper bound required — avoid glare/over-contrast beyond 21:1 |
| **Observed** | worst dark elevation rung 10.71:1; worst audited pair anywhere 6.54:1 |
| **Output scale** | Pass / Fail |

## Expected Output (from the sheet)

> CSS Token Variables

## Mistake-proofing, as implemented

> Build validation blocks compilation if color ratios test below a hard 4.5:1 ratio threshold. Automated validation dashboards chase design leads to remediate non-compliant values.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/ttmcs_005_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
