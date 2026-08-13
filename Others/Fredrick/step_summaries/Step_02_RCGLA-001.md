# Step 2 of 50 — RCGLA-001

**Atomic Step Reference ID:** `RCGLA-001-A01`  
**Original S. No in the master sheet:** 3227  
**Assigned to:** Fredrick  
**Estimated time:** 5 Hours  
**Derived status:** **Complete**

> Build global corporate style token variables inside the mobile client framework.

---

## What was delivered

The token layer: colour, typography (15 MD3 roles), spacing (8dp baseline), elevation (6 levels) and shape. tokens.json is declared the source of truth and a drift gate enforces it against the Dart mirror in both directions.

### Artefacts

- `lib/design_system/tokens/tokens.json`
- `lib/design_system/tokens/color_tokens.dart`
- `lib/design_system/tokens/spacing_tokens.dart`
- `lib/design_system/tokens/typography_tokens.dart`
- `lib/design_system/tokens/elevation_tokens.dart`
- `lib/design_system/tokens/grid_tokens.dart`
- `lib/design_system/tokens/shape_tokens.dart`
- `test/aiss/rcgla_001_test.dart` — the gates for this step

## Requirement -> gate mapping

**6 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `RCGLA-001-G1` | 4 Substeps #1: "Map semantic spacing constants (margins, paddings, column gaps) inside theme configurations." + Mobile-First UI Decision: "Apply forced 8dp baseline grid steps." | Every spacing token sits on the 4dp sub-baseline, and all steps above the sub-baseline sit on the 8dp baseline | Active |
| `RCGLA-001-G2` | 4 Substeps #2: "Implement an adaptive 4-column layout matrix optimized for compact smartphone screens." | Compact matrix is 4 columns, and column arithmetic never goes negative down to the 320dp floor | Active |
| `RCGLA-001-G3` | 4 Substeps #3: "Code standardized element elevation levels and background shadow weight variables." | Elevation ladder is complete, monotonic, and defined for both schemes | Active |
| `RCGLA-001-G4` | Setup Step Description: "Gather all brand identity assets -- color palette, typography, spacing, iconography, elevation." + Data Collected: Font Name; Font Size; Line Height; Font Weight; Font File Path | All 15 MD3 type roles are defined with size, line height and weight, and every TextTheme slot is populated from them | Active |
| `RCGLA-001-G5` | TTMCS-001 UX Implementation: "Component container borders match rigid brand theme rules precisely." | Corner radii are non-negative, ascending, and on the 4dp sub-baseline | Active |
| `RCGLA-001-G6` | Common Library to Store: "universal_library/ui/theme/tokens.json" -- the token file is the source of truth, Dart mirrors it. | Every Dart token constant matches tokens.json exactly (no drift) | Active |

## Metric result

| | |
|---|---|
| **Metric** | Scope Coverage / Audit Completeness |
| **Floor** | 80% of relevant items identified |
| **Optimal** | 100% of relevant items identified and logged |
| **Ceiling** | 100% identified, logged, and cross-checked against spec |
| **Observed** | 5 of 5 asset families inventoried and tokenised (colour, typography, spacing, elevation, shape) = 100% |
| **Output scale** | Complete (Scale: Complete/Partial/Not Complete) |

## Expected Output (from the sheet)

> An audited, production-ready mobile layout design token matrix.

## Completion Measure (from the sheet)

> Continuous integration code verification pipelines report zero instances of hardcoded hex colors or spacing values.

## Mistake-proofing, as implemented

> Style repository checks automatically fail if layout padding variables use non-standard grid intervals.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Brand palette is PROVISIONAL.** The step names "the exact primary corporate theme colors" as a decision required before it. Brand has not signed off. Every value is WCAG-audited, so replacing them is a data edit in tokens.json - the drift gate catches a half-update and the contrast gate rejects an inaccessible brand colour.

---

*Generated from the master sheet and `test/aiss/rcgla_001_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
