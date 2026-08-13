# Step 6 of 35 — RCGLA-012

**Atomic Step Reference ID:** `RCGLA-012-A01`  
**Original S. No in the master sheet:** 345  
**Assigned to:** Fredrick  
**Estimated time:** 4 Hours.  
**Derived status:** **Partial** — 2 gate(s) deferred

> RCGLA-012 - Initialize Atomic Grid System & Mobile Viewport Constraints

---

## What was delivered

The atomic grid: xs/sm breakpoints, the web viewport meta tag, MobileGridContainer (a pure widget with a 20-line build budget), and a lint ceiling on hardcoded wrapper widths.

### Artefacts

- `lib/design_system/layout/mobile_grid_container.dart`
- `lib/design_system/tokens/grid_tokens.dart`
- `web/index.html`
- `test/aiss/rcgla_012_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `RCGLA-012-G1` | 4 Substeps #1: "Define layout breakpoints in the common library configuration (xs: 0px, sm: 600px)." | xs and sm breakpoints are defined at exactly 0 and 600 and drive the window-class resolver | Active |
| `RCGLA-012-G2` | 4 Substeps #2: "Configure HTML Meta viewport tags to disallow user-scalable zooming." | Viewport meta tag pins width and initial scale; the user-scalable=no clause is DEFERRED because it fails WCAG 2.1 SC 1.4.4 and contradicts TTMCS-004/005. Awaiting Fredrick decision. | **DEFERRED** |
| `RCGLA-012-G3` | 4 Substeps #3: "Build a pure MobileGridContainer component restricted to 20 lines." | MobileGridContainer.build is 20 executable lines or fewer, and the widget is pure (no Theme, MediaQuery or state) | Active |
| `RCGLA-012-G4` | 4 Substeps #4: "Implement automated build-time linting to flag hardcoded pixel values." + Poka-Yoke: "break compilation if outer layout wrappers contain hardcoded fixed pixel widths over 360px." | The pixel-width ceiling is defined and no layout file declares a hardcoded wrapper width above it | Active |
| `RCGLA-012-G5` | UX Translation: "standard 16px fluid outer margins and a continuous 8px vertical rhythm alignment." | Outer margin is 16dp and the vertical rhythm is 8dp | Active |
| `RCGLA-012-G6` | Completion Measures: "Zero instances of horizontal scrollbars across simulated iPhone SE, 14 Pro, and Pixel devices." | App and MobileGridContainer render inside the viewport at 320, 393 and 393dp with zero overflow exceptions | Active |
| `RCGLA-012-G7` | Completion Measures: "Cumulative Layout Shift (CLS) scores tracking strictly under 0.05." | CLS is a browser metric; needs a Lighthouse run in CI against the web build. NOT measured by this suite. | **DEFERRED** |

## Metric result

| | |
|---|---|
| **Metric** | Asset/Resource Location & Access Confirmation |
| **Floor** | 0.8 |
| **Optimal** | 0.95 |
| **Ceiling** | 1.0 |
| **Observed** | 1.0 - grid config reachable from one documented location |
| **Output scale** | Pass/Fail |

## Expected Output (from the sheet)

> Pure MobileGridContainer component codebase along with its semantic English Code specification sheet.

## Completion Measure (from the sheet)

> Zero instances of horizontal scrollbars across simulated iPhone SE, 14 Pro, and Pixel devices. Cumulative Layout Shift (CLS) scores tracking strictly under 0.05.

## Mistake-proofing, as implemented

> Build validation rules directly into the Webpack/Vite pipeline that immediately break compilation tasks if outer layout wrappers contain hardcoded fixed pixel widths over 360px.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Zoom lock deferred - needs your call.** Substep 2 asks for `user-scalable=no`. That fails WCAG 2.1 SC 1.4.4, contradicts the AA/AAA posture Steps 3-4 established, and is ignored by modern iOS Safari and Android Chrome anyway. Shipped `width=device-width, initial-scale=1.0` instead. One-line override documented in web/index.html.

**CLS deferred.** A browser metric; needs a Lighthouse CI run.

---

*Generated from the master sheet and `test/aiss/rcgla_012_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
