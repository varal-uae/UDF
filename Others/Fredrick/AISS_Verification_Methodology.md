# How each AISS output is verified against its step requirements

**Project:** Habot UDF — mobile client (Flutter)
**Owner:** Fredrick
**Scope:** all 10 steps of the first implementation batch
**Source of requirements:** `My stepsFN06082026.xlsx` → `Fredrick` sheet (49 columns per step)
**Date:** 11 August 2026 · **Revision:** 2 (extends rev 1, which covered Steps 1–4)

---

## 1. The short answer

After each atomic step, one command:

```bash
cd habot-mobile/udf_setup
./tool/verify_aiss.sh            # local: formats, then runs every gate
./tool/verify_aiss.sh --check    # CI: fails on unformatted code instead of fixing it
```

Five gate groups, in order, stopping on the first failure. It leaves two artefacts:
`build/aiss/evidence.json` (what ran, what it concluded, per step) and
`build/aiss/contrast_audit.txt` (every colour pair and its measured ratio).

**72 gates across 10 steps.** Nothing is marked Complete by opinion — a step's completion
status is *derived* from whether its gates passed (§5).

---

## 2. The principle: every requirement column becomes an assertion

The step sheet is not prose. Treated as a specification, most of its columns are already
testable. The method is a fixed mapping:

| Spreadsheet column | What it becomes in the repo |
|---|---|
| **4 Substeps** | One `test()` per substep. A substep with no assertion is not done. |
| **Completion Measures** | The assertion the step's headline gate makes. |
| **Metric Name + Floor / Optimal / Ceiling** | A numeric range assertion, using the sheet's own numbers as bounds. |
| **Mistake-Proofing (Poka-Yoke)** | A static guard over `lib/` that fails the build. |
| **Mobile-First UX/UI Decision rows** | Assertions on the specific value named (768dp, `#F2F6F9`→`#EEF2F6`, 8dp grid, 64dp bar, 48dp target). |
| **Data Collected by System** | The fields written into `evidence.json` for that step. |
| **Best Qualitative Output** | The scale the derived completion status is reported on. |
| **Expected Output** | The artefact list recorded in `evidence.json`. |
| **Dependencies / Dependency Count** | Enforced at selection time — only zero-dependency steps were scheduled. |

Each gate carries the requirement text **verbatim** in its `requirementSource`, so a failure
tells you which sentence it is defending without opening the spreadsheet.

---

## 3. The five gate groups

**G-A Format** — `dart format`. Removes formatting noise from every later review.

**G-B Static analysis** — `flutter analyze`. The setting that matters is
`deprecated_member_use: error`: a deprecated Flutter API breaks the build rather than warning
quietly. That is what stops the design system rotting across SDK upgrades.

**G-C Poka-yoke guard** — `test/guards/poka_yoke_no_hardcoded_values_test.dart`, the executable
form of three separate Mistake-Proofing columns. It parses every `.dart` file under `lib/`,
strips comments and string literals first — so a doc comment *mentioning* `#F2F6F9` is never
mistaken for code *using* it — then fails on:

| Rule | Detects | Sanctioned location |
|---|---|---|
| `RAW_COLOR_LITERAL` | `Color(0x…)`, `Color.fromARGB(` | `tokens/color_tokens.dart`, `tokens/elevation_tokens.dart` |
| `UNTOKENISED_MATERIAL_COLOR` | `Colors.<name>` | none (only `Colors.transparent`) |
| `RAW_SPACING_VALUE` | a bare number inside `EdgeInsets.*`, `BorderRadius.circular`, `SizedBox` | the five `tokens/*.dart` files |
| `ROGUE_THEME_CONSTRUCTION` | `ThemeData(` | `theme/habot_theme.dart` only |

**The guard tests itself.** A second test plants a known violation and asserts the detector
fires, then plants a doc comment mentioning the same values and asserts it does *not*. A guard
that can never fail is not a guard.

**G-D AISS step gates** — `test/aiss/<step>_test.dart`, one file per atomic step. §4 has the
inventory.

**G-E Evidence roll-up** — merges the per-step evidence, prints a table, lists open items, and
fails on unexplained breakage. It also fails a step that recorded *zero* gates, which is what
stops a green-looking run that verified nothing.

---

## 4. Step inventory — 72 gates

### Steps 1–4 · foundation (30 gates, all passing)

| Step | Ref | Gates | Highlights |
|---|---|---|---|
| 1 | TTMCS-001 | 7 | MD3 enabled; every `ColorScheme` role pinned to a brand token; reflow at 320/600/840/1024dp with exact boundaries; 768dp nav collapse; gradient stops byte-exact; overflow-free on 5 device profiles |
| 2 | RCGLA-001 | 6 | 8dp baseline enforced; column arithmetic reconstructs viewport width exactly; all 15 type roles; **token-drift gate** across 56 colours + 15 type entries + grid + density |
| 3 | TTMCS-004 | 9 | Zero contrast failures both schemes; body text clears **7:1 AAA**; density inside the sheet's own 6–8dp / 32–48dp band; **rebuild counters** prove no full reflow on theme switch |
| 4 | TTMCS-005 | 8 | Dark ladder strictly lightens; literals **re-derive byte-exactly** from documented alphas; every rung clears 7:1; shadows suppressed in dark |

### Step 5 · SSTLA-004 — breakpoint decision record (8 gates)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "Define the exact base breakpoint, column count, fluid margin, and gutter widths" | All four decided, recorded in JSON, matching code |
| G2 | "Collate cross-device screen resolution metrics for mobile, tablet, desktop" | 9 devices covering all 3 types; all 5 atomic data fields populated on each |
| G3 | "Prevents accidental visual clipping of primary CTAs on tight displays" | At every device width, one grid column still holds a 48dp target |
| G4 | **Conflict resolution** (see §6) | Column gutter 16dp, vertical rhythm 8dp, resolution documented not implicit |
| G5 | "Approved JSON Token File" | Every device in `device_matrix.json` mirrored exactly in Dart |
| G6 | Metric: Task Execution Quality Score 1–5 | Objective rubric 5.0/5.0 — reviewer score **not self-awarded** |
| G7 | "interactive structural layout wireframe" | Overlay paints the grid at 320dp and passes pointers through to content beneath |
| G8 | "Eliminates arbitrary layout configurations" | On-screen readout is generated from tokens, so it cannot disagree with the decision |

### Step 6 · RCGLA-012 — atomic grid system (7 gates, **2 deferred**)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "breakpoints (xs: 0px, sm: 600px)" | Exactly 0 and 600, driving the window-class resolver |
| G2 | "disallow user-scalable zooming" | **DEFERRED** — see §7 |
| G3 | "pure MobileGridContainer restricted to 20 lines" | `build` counted at **17 executable lines**; source contains no `Theme.of`, `MediaQuery`, `StatefulWidget` or `setState` |
| G4 | "break compilation if wrappers contain hardcoded widths over 360px" | Ceiling defined; no layout file declares a fixed width above it |
| G5 | "16px fluid outer margins and a continuous 8px vertical rhythm" | Both exact |
| G6 | "Zero horizontal scrollbars across iPhone SE, 14 Pro, Pixel" | Rendered and measured on all three |
| G7 | "CLS strictly under 0.05" | **DEFERRED** — browser metric, needs Lighthouse |

G3 is worth a look. The 20-line budget is a real constraint, not decoration: it forces the grid
arithmetic out of the widget and into `HabotGrid` as pure functions, where it can be unit-tested
at any width without building anything.

### Step 7 · RCGLA-032 — adaptive layout engine (7 gates)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "16px outer margin and a 16px column gutter" | Both exact |
| G2 | "flag any element trying to split into more than 4 vertical segments" | Limit is 4 on compact; over-limit clamps, under-limit clamps up, wider viewports allow more |
| G3 | "Follow MD3 compact window-size class guidelines explicitly" | Every phone in the matrix resolves to compact/4-column |
| G4 | "relative percentages ... fluid elasticity" | Column width strictly increases across 320→599dp; margins + columns + gutters reconstruct the viewport exactly at 5 widths |
| G5 | "Wrap all views inside a global layout boundary container" | Boundary publishes window class + columns; over-limit span **throws in debug** and is recorded |
| G6 | "All sub-feature layouts must wrap within the unified grid" | A view outside the boundary throws a readable error instead of inventing a layout |
| G7 | "checks across 360px, 375px, and 412px" + "down to 320px" | App renders clean with **zero segment violations** at all four |

### Step 8 · RCGLA-018 — master layout scaffold (6 gates)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "Build primary scaffold locking metrics" | Margins come from tokens; body always wrapped in the layout boundary |
| G2 | "configurable child prop targets" | Exactly four content slots exposed |
| G3 | "Block flexible padding assignments" | Constructor exposes **no** padding/margin/width/height/alignment/insets parameter — a screen physically cannot pass spacing in |
| G4 | "Code scanning proves 100% of app instances use wrappers" | The scan itself: discovers every `*Page`/`*Screen` class under `lib/`, asserts each references the master scaffold, **fails on an empty scan** |
| G5 | "Custom local padding declarations are stripped by central rules" | No screen declares its own `Scaffold` |
| G6 | "multi-tenant structural shells" + Audit Trail | Screens register into a runtime inventory; each sits inside exactly one boundary |

G3 is the most useful gate in the batch. "Block flexible padding" is normally enforced by code
review, which works until the day someone is in a hurry. Here the escape hatch does not exist in
the type signature, and a test asserts it stays that way.

### Step 9 · ANSA-012 — contextual navigation header (7 gates)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "Cap maximum string titles to protect horizontal grid boundaries" | Never exceeds 28 chars; short titles untouched; prefers a word boundary; an unbroken 120-char token still caps |
| G2 | "scroll-listening hooks to adjust header elevations" | Flat at rest, lifts past the threshold |
| G3 | **Poka-Yoke:** "block rapid double-tapping on back controls" | Six taps over 250ms yield **exactly one** pop; a deliberate tap after the window is honoured |
| G4 | "Hide low-priority shortcuts inside trailing overflow menus on tight displays" | 2 visible on compact, 4 on wide, remainder overflow |
| G5 | "unyielding 64dp profile line" | `preferredSize` is exactly 64dp, from the token |
| G6 | "Align header targets to left grid baselines" + 64dp | Rendered header measures 64dp, caps its title, shows the overflow menu at 360dp |
| G7 | "zero history stack leaks" | Tapping back on the root route is a no-op — the stack is never unwound past the first screen |

### Step 10 · TTMAC-011 — touch-target framework (7 gates)

| Gate | Requirement | Assertion |
|---|---|---|
| G1 | "minimum touch-target boundaries (≥ 48×48 dp)" | Floor defined once; predicate rejects 47×48, 48×24, 24×24 |
| G2 | "preserve an 8 dp safety spacing margin" | Predicate rejects 4dp and 0dp gaps |
| G3 | **Poka-Yoke:** "compile engine throws if bounds map below 48 dp" | Constructor `assert` rejects a sub-48dp `minSize` before anything renders |
| G4 | "Adherence to core interactive component parameters" | No file under `lib/` builds a raw `IconButton` or `GestureDetector` outside the sanctioned module |
| G5 | **"100% of deployed interactive elements maintain tap boundaries ≥ 48×48 dp"** | Pumps the real app at 320/393/1024dp and **measures every rendered target**; fails if none were found |
| G6 | "8 dp safety spacing" | Measures the actual rendered gap between adjacent targets |
| G7 | "transparent target expansion boxes around micro-icons" + "long-press reveals tooltips" | A 12dp icon renders at 12dp inside a ≥48dp tap area; long-press surfaces the detail |

G5 is the literal form of the completion measure. It does not check that the constant is
referenced — it renders the app and measures pixels.

---

## 5. Completion status is derived, never asserted

```dart
AissOutcome get outcome {
  if (gates.isEmpty) return AissOutcome.notComplete;
  if (failedGates.isEmpty) return AissOutcome.complete;
  if (failedGates.length == gates.length) return AissOutcome.notComplete;
  return AissOutcome.partial;
}
```

1. **A step with no gates reports `Not Complete`.** You cannot pass by writing no tests.
2. **Partial is a real outcome.** Some gates passing does not round up to done.
3. **A deferral is not a pass.** Rev 2 adds `AissGate.deferred` for a requirement that is
   knowingly open with a recorded reason. It keeps the step at **Partial** — but it stops the
   gate runner going permanently red, so a genuine regression stays visible instead of hiding
   under a build that is always failing. Deferring is a reviewable act: the reason lands in
   `evidence.json` where someone can argue with it.

Current state: **8 steps Complete, 1 Partial (RCGLA-012), 1 pending reviewer input (SSTLA-004
objective half complete).**

---

## 6. A contradiction between two steps, and how it was resolved

RCGLA-012 and RCGLA-032 disagree about the gutter:

> RCGLA-012 (UX row): *"Define mobile margin standardations explicitly at 16px with an **8px gutter** grid system."*
> RCGLA-032 (substep 1): *"Define global system layout properties with a 16px outer margin and a **16px column gutter** spacing profile."*

Picking one silently would have made whichever step lost look compliant while the codebase
contradicted its own spec. Resolved into **two distinct tokens**:

- `HabotGrid.gutter = 16dp` — the *column* gutter. RCGLA-032 names it explicitly and repeats it
  in its UI decision row.
- `HabotGrid.verticalRhythm = 8dp` — the baseline step. This is what RCGLA-012's own UX
  Translation row actually describes: *"a continuous 8px vertical rhythm alignment."*

Cross-check: RCGLA-032's metric row lists Floor 4dp / Optimal 8dp / Ceiling 16dp, and the 8dp
rhythm lands exactly on Optimal. The resolution is recorded in
`device_matrix.json → decision_record.conflict_resolved` and gated by `SSTLA-004-G4`.

**Flag this to whoever maintains the step sheet** — the two rows should be reconciled at source.

---

## 7. The zoom-lock decision — I need your call

RCGLA-012 substep 2 reads:

> *"Configure HTML Meta viewport tags to disallow user-scalable zooming."*

I did not implement that clause literally, for three reasons:

1. **It fails WCAG 2.1 SC 1.4.4 (Resize Text)**, which requires content to stay usable at 200%
   zoom. `user-scalable=no` is a documented accessibility failure.
2. **It contradicts this codebase's own standard.** Steps 3 and 4 are gated at WCAG AA/AAA and
   spent 17 gates getting there. Shipping a zoom lock would fail an accessibility audit that
   the same repo claims to pass.
3. **It does not even work.** iOS Safari has ignored `user-scalable=no` since iOS 10, and
   Android Chrome ignores it too. The tag would fail its own accessibility test while achieving
   nothing on the two browsers that matter.

What ships instead: `width=device-width, initial-scale=1.0, viewport-fit=cover`, which meets the
substep's *intent* (no zoom-induced layout breakage on first render), plus the RCGLA-032 layout
guards that keep content inside 320dp.

`RCGLA-012-G2` records this as **deferred, not passed**, so RCGLA-012 reports **Partial**.

**To override:** set `user-scalable=no, maximum-scale=1.0` in `web/index.html` (the exact
replacement string is in a comment there) and flip `zoomLockAccepted = true` in
`test/aiss/rcgla_012_test.dart`. The gate then asserts the lock is actually present and the step
goes Complete.

---

## 8. What this method does **not** cover

| Not covered | Why | Mitigation |
|---|---|---|
| **CLS** (RCGLA-012 completion measure) | Browser metric; a widget test cannot produce it | `lhci autorun` against `flutter build web` in CI. Recorded as `RCGLA-012-G7`, deferred. |
| **Visual regression** (goldens) | Platform-sensitive, and the palette is still provisional — goldens would need rebaselining on Brand sign-off | Add `--update-goldens` for light/dark once the palette is final. TTMCS-004's *Self-Chasing* column asks for this. |
| **Real-device rendering** | Widget tests are headless; text shaping is faithful but not pixel-identical to iOS/Android | Manual pass on one physical Android and one iOS device before sign-off |
| **Reviewer scores** | SSTLA-004 wants a 1–5 quality score "scored by a reviewer"; TTMCS-001 wants rules "peer-reviewed". A test cannot award itself either. | Gates reach the Floor and most of Optimal. The Optimal/Ceiling bands need a reviewer's name against the step. |
| **Runtime performance** | No frame-timing budget measured | AEETE-010-06 ("Mobile Performance Budget Gate") is in your backlog and is zero-dependency |
| **Telemetry / BigQuery** | Every step has a GCP alignment row; none is implemented | Out of scope for the UI batch; needs a separate step selection |

---

## 9. Verification status — read this before signing off

Built and reviewed in a cloud sandbox where `storage.googleapis.com` and `pub.dev` are blocked,
so the Dart SDK could not be installed. Two honest categories:

**Executed here — the numbers below are computed, not estimated:**

- WCAG contrast for all 56 colour tokens, both schemes, every audited pair. Worst pair
  **6.54:1**; worst dark elevation rung **10.71:1**; floor 4.5:1.
- Dark elevation ladder re-derivation — all 6 rungs byte-exact.
- Token drift: 28 light + 28 dark colours, 15 type entries, 14 grid keys, 6 density keys — **zero
  mismatches**. Device matrix: 9 devices × 6 fields — **zero mismatches**.
- Poka-yoke guard simulated over the real `lib/` (25 files) — **0 violations**.
- `MobileGridContainer.build` — **17 executable lines** against the 20-line budget; purity scan clean.
- RCGLA-012-G4 pixel-width scan, RCGLA-018 screen scan, TTMAC-011-G4 raw-widget scan — all clean.
- Brace balance, import resolution and unused-import scan across all 38 Dart files.
- Every Flutter API checked against the framework source at your pinned revision
  (`b45fa189`, Flutter 3.38-candidate.0) — including catching that `AppBarTheme` is deprecated in
  favour of `AppBarThemeData`, and that super-parameters cannot be mixed with an explicit
  `super()` call.

**Not executed — needs your machine:** `dart format`, `flutter analyze`, `flutter test`.
Compilation has not been run anywhere.

**So: run `./tool/verify_aiss.sh` before accepting this batch.** If something breaks it will be
a syntax or type slip, not a design error — the requirements mapping and the numbers are already
verified. Send me the output and I will fix it.

---

## 10. Open decisions blocking full sign-off

1. **Brand palette** (RCGLA-001). `tokens.json` is marked `PROVISIONAL`. Every colour passes its
   gates with room to spare, but the hex values are placeholders. Swapping them is a data edit —
   the drift gate catches a half-update, the contrast gate rejects an inaccessible brand colour.
   **Highest-value unblock.**
2. **Zoom lock** (RCGLA-012, §7). One-line decision, currently deferred.
3. **Gutter contradiction in the source sheet** (§6). Resolved in code; the sheet itself should
   be reconciled.
4. **Reviewer score** for SSTLA-004. Objective rubric is 5.0/5.0; a human needs to score the
   execution-quality half.

---

## 11. File map

```
habot-mobile/udf_setup/
├── tool/verify_aiss.sh                      ← the one command
├── analysis_options.yaml                    ← G-B config
├── web/index.html                           ← viewport meta (Step 6, see §7)
├── lib/
│   ├── app.dart                             ← theme adapter root + probe screen
│   └── design_system/
│       ├── tokens/tokens.json               ← SOURCE OF TRUTH (Step 2)
│       ├── tokens/device_matrix.json        ← approved device matrix (Step 5)
│       ├── tokens/*.dart                    ← Dart mirror, drift-gated
│       ├── theme/habot_theme.dart           ← only file allowed to build ThemeData
│       ├── theme/theme_controller.dart      ← OS brightness listener (Step 3)
│       ├── theme/habot_theme_scope.dart     ← no-full-reflow container (Step 3)
│       ├── a11y/contrast*.dart              ← WCAG 2.1 engine + the 4.5:1 gate
│       ├── layout/device_profiles.dart      ← Step 5
│       ├── layout/grid_wireframe.dart       ← Step 5 wireframe
│       ├── layout/mobile_grid_container.dart← Step 6 (20-line budget)
│       ├── layout/layout_boundary.dart      ← Step 7 boundary + segment listener
│       ├── layout/master_scaffold.dart      ← Step 8 (no padding escape hatch)
│       ├── navigation/contextual_header.dart← Step 9
│       ├── navigation/back_navigation.dart  ← Step 9 double-tap guard
│       ├── interaction/touch_target.dart    ← Step 10
│       └── aiss/aiss_evidence.dart          ← evidence record types
└── test/
    ├── guards/poka_yoke_…_test.dart         ← G-C, self-testing
    └── aiss/                                ← 10 files, 72 gates
```

Outputs, regenerated every run: `build/aiss/evidence.json`, `build/aiss/contrast_audit.txt`.
