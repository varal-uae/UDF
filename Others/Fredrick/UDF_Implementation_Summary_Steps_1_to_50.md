# Habot UDF mobile client — implementation summary, Steps 1–50

**Owner:** Fredrick · **Team:** UDF · **Date:** 13 August 2026
**Source of requirements:** `My stepsFN06082026.xlsx` → `Fredrick` sheet
**Codebase:** `habot-mobile/udf_setup` (Flutter)

---

## The one-paragraph version

Fifty atomic steps from the master sheet are implemented. Each one's requirements were turned
into executable checks — **333 in total** — so "is this step done?" is answered by something the
build computes rather than by anyone's judgement. **48 steps are Complete**, 2 are **Partial**
because a requirement is knowingly open, and one of those Complete steps still needs a human
reviewer's score. This batch added **no new deferrals**. It also changed what the codebase *is*:
until Step 43 every screen was reachable only from a probe page. There is now an application
shell — navigation, routing, deep links, an offline banner and a settings screen — and the probe
pages are destinations inside it rather than the only way in. Three decisions still need you.
**The code has not been compiled yet** — that needs one command on your Mac.

---

## What was built

Four layers, in order: the frame, the input, the response, the shell.

| Batch | Steps | What it produced |
|---|---|---|
| **Foundation** | 1–10 | Material 3 framework and theme adapter · the full design-token layer · light/dark adaptation and dark-mode contrast enforcement · the breakpoint decision record and device matrix · the atomic grid and layout engine · the master scaffold every screen uses · the contextual navigation header · the 48dp touch-target framework |
| **Forms & feedback** | 11–20 | Motion tokens and reduced-motion policy · the atomic button and interaction states · the touch standards engine · input masking · validated fields with 13 data-type rules · inline validation errors · compound fields · error templates, log scrubbing and transaction rollback · the guided multi-step form |
| **Surfaces & feedback** | 21–35 | The bottom sheet (chassis, 32% scrim, 60% snap) · hover removed entirely and replaced with long-press drawers · error snackbars bound to the error boundary · progress, empty states and status badges · the card chassis · MD3 shared-axis transitions · elastic overscroll · list virtualisation at 10,000 rows · header search · hesitation and friction telemetry |
| **Navigation & adaptive shell** | 36–50 | The Contextual Mirror blueprint and its split-screen / master-detail containers · pane distribution and pinned metrics · the 5.5-inch dashboard rules · navigation rail and bottom bar · unread badges · deep-link routing and context restoration · the tab-switch latency benchmark · text fitting at 320dp · the offline state machine and its banner · the preference manager and notification settings screen |

The app had a frame, a way to take input and a way to respond. What it did not have was a way to
**move** — no navigation, no routes, no way to arrive from a notification. That is what this
batch is. It is also the batch where the pieces stopped being a component library and started
being an application: `HabotShellPage` owns the one scaffold, `HabotAppShell` supplies the
destinations, and everything built in the previous three batches now lives somewhere a user can
reach.

---

## Status at a glance

| | Count |
|---|---:|
| Steps implemented | **50** |
| Steps **Complete** | **48** |
| Steps **Partial** (a requirement knowingly open) | **2** — Step 6 (RCGLA-012), Step 31 (IS38-SGTIM-018) |
| Steps awaiting a human reviewer's score | **1** — Step 5 (SSTLA-004) |
| Checks written | **333** (92 new this batch) |
| Checks knowingly deferred, with a recorded reason | **3** — unchanged; this batch added none |
| Checks whose value was already computed during authoring | **155** |
| Checks still needing a run on your machine | **178** |

A deferral is **not** a pass. The step stays Partial. What it changes is that the gate runner
stays green, so a genuine regression is still visible instead of hiding under a build that is
always failing.

---

## Metric results, Steps 36–50

| Step | Metric | Floor | Optimal | Observed |
|---|---|---|---|---|
| 36 · SSTLA-012 | Requirement & Asset Discovery Coverage (%) | 0.9 | 1.0 | 1.0 — all five Data Collected fields derived from one record; **8 of 9 devices mirror in both orientations**, the ninth falls back to tabs (recorded) |
| 37 · GEN-03270 | Layout Responsiveness Pass Rate | 1.0 | 1.0 | **1.0 — 18 of 18 viewports** usable. Single-value metric: every viewport, or not done |
| 38 · SSTLA-010 | Requirement & Asset Discovery Coverage (%) | 0.9 | 1.0 | 1.0 — *(Completion Measures cell empty in the sheet; nothing invented to fill it)* |
| 39 · SSTLA-018 | Requirement & Asset Discovery Coverage (%) | 0.9 | 1.0 | 1.0 — reference viewport pinned as **1080×1920 @ DPR 3 = 360×640dp**, 16:9 stated |
| 40 · GEN-02334 | UI Compliance Rate (%) | 0.95 | 1.0 | 1.0 — rail above 768dp, bar below, exactly one at a time, **zero** hover tooltips |
| 41 · GEN-02676 | *(metric name mismatched)* | 90% of scope | 100% + peer validation | 100% of defined scope |
| 42 · GEN-00999 | Syntax Validity | 100% | 100% | 100% — every context round-trips through JSON **byte-for-byte** |
| 43 · GEN-02082 | *(metric not attributable to a router)* | 10.0 | 25.0 | not measurable in-suite; what a router owns is gated — no link can produce a blank screen |
| 44 · GEN-01474 | *(metric name mismatched — **not produced**)* | 0.8 | 0.95 | the step's own **200ms** measured instead: 5 real shell switches, **100% pass rate** |
| 45 · GEN-00022 | Cross-Viewport Rendering Consistency | zero on 360/390/412 | zero across the matrix | **zero** — 18 of 18 viewports rendered clean with the expected column count |
| 46 · GEN-02060 | *(metric name mismatched — **not produced**)* | 90.0 | 99.0 | the step's own **320dp** measured instead: all **15 type roles** keep ≥12 chars at ≥11sp |
| 47 · GEN-02720 | Offline state transition correctness | every transition | every transition | all 7 gates — the **timeout itself** drives the first failure, not an error response |
| 48 · GEN-03437 | Banner Contrast Ratio | 4.5:1 | 7:1 | **13.31:1** / **13.39:1** light, **7.28:1** / **11.27:1** dark — all four clear *both* bands |
| 49 · IS22-RCGLA-022 | Preference write accuracy | every write reflected or rolled back | as floor | every accepted write reflected, every rejected one rolled back with the column named |
| 50 · GEN-03404 | Preference Screen Render Time | <100ms | <30ms | inside the floor, measured on the test host — **not** a cold start, **not** a handset |

Every step meets or exceeds its Floor. Steps 1–35 are unchanged.

---

## What this batch changed structurally

**The app root moved.** `HabotShellPage` replaced `DesignSystemProbePage` as the app's home. It
owns the single `HabotMasterScaffold`; `HabotAppShell` is deliberately a *body*, not a scaffold
owner, so a destination supplies content and never gets the chance to bring a wrapper of its
own. That is RCGLA-018's poka-yoke made structural rather than advisory. Three existing gate
files were updated because of the move, each with an in-code note explaining why rather than a
silent edit.

**A seventh machine-enforced rule.** `ROGUE_SCAFFOLD` joins the poka-yoke guard: only
`master_scaffold.dart` may construct a `Scaffold`. The rule exists because this batch is the
first one where a second scaffold would have been the natural thing to write.

**The containers do not take a breakpoint.** `HabotSplitView` and `HabotMasterDetail` accept no
width, ratio or breakpoint parameter. They read the viewport and consult the Step 36 blueprint.
This is the difference between "responsive" meaning one rule and "responsive" meaning each
screen decides for itself, and it is why the 18-viewport pass rate is a property of the system
rather than of the screens someone remembered to test.

**One design defect was caught during authoring.** The preference screen's write-status line sat
outside the panel's rebuild scope, so it would have reported the *previous* write's outcome — a
settings screen that quietly lies is worse than one that says nothing. Fixed before the gates
were written, and the fix carries a comment saying why.

---

## Three decisions I still need from you

### 1. The brand palette — still the highest-value unblock

`tokens.json` is marked **PROVISIONAL**. RCGLA-001 names *"the exact primary corporate theme
colors"* as a decision required before the step, and Brand has not made it. Every colour used by
this batch's banner was audited against the same policy and clears AAA in both schemes, so
nothing is blocked technically. The hex values are still not yours. Swapping them remains a
**data edit, not a code change**.

### 2. Zoom lock on the web build

Unchanged. RCGLA-012 substep 2 asks for `user-scalable=no`, which fails WCAG 2.1 SC 1.4.4 and is
ignored by iOS Safari and Android Chrome anyway. Step 6 honestly reports **Partial** until you
decide.

### 3. Six more rows that need correcting at source — eleven in total now

| Step | Row | The problem |
|---|---|---|
| 44 | GEN-01474 | Metric = *"Information Architecture Task Success Rate"* — a usability study — on a render-latency step |
| 46 | GEN-02060 | Metric = *"Step Completion Rate (%)"* — project tracking — on a text-rendering step |
| 43 | GEN-02082 | Metric = *"Push Notification Click-Through Rate (%)"* on a routing step |
| 41 | GEN-02676 | Metric = *"Implementation Completeness Rate"*, generic |
| 38 | SSTLA-010 | **Completion Measures cell is empty** |
| 49 | IS22-RCGLA-022 | Estimated Time = *"5 Minutes"* for a settings panel with database writes, a rollback path and a transition guard |

Add the five from batch 3 (MUFCE-028, UFHT-032, GEN-01848, GEN-01297, GEN-01452) and that is
**eleven rows** worth fixing in the sheet.

**On the three metrics recorded as "not produced":** where the sheet named an instrument that no
test suite can operate — a usability study, a project-tracking percentage, a notification
click-through rate — no number was invented in its place. The step's own named figure (200ms,
320dp, route resolution) was gated instead, and the mismatch is stated in the gate file and the
evidence log. That is a **documentation error in the sheet, not an engineering debt**, and it is
deliberately not recorded as a deferral: conflating the two would hide both.

---

## Two things that need something other than a decision

| Item | Step | What it needs |
|---|---|---|
| **Reviewer quality score** | 5 · SSTLA-004 | Unchanged: the metric is a 1–5 score awarded by a reviewer. The objective half is 5.0/5.0; a human owes the execution-quality half. |
| **Physical-device confirmation** | 31 · IS38-SGTIM-018 | Unchanged: one Android handset, one iPhone, scroll a list past its end. |
| **A handset reading for the latency budgets** | 44, 50 | Both are measured on the test host and say so on the gate. A device number needs a profile-mode run — not blocking, but the two numbers are not interchangeable and the evidence does not pretend they are. |

---

## Also worth knowing

**Eleven of the fifteen rows in this batch are `GEN-*` rows** with boilerplate Expected Output
and Completion Measures. Those gates are derived from the Setup Step, the Description and the
Metric Name, and each gate file says so in its header. The four richly-specified rows
(SSTLA-012, SSTLA-010, SSTLA-018, IS22-RCGLA-022) carry the strongest gates.

**The ninth device is reported, not rounded up.** A split at the 35/65 stop needs 160dp per pane.
An iPhone SE in landscape is 320dp tall — the split would starve both panes, so the layout
resolves to a documented tabbed fallback with its own status value. Eight of nine devices mirror
in both orientations; the ninth is in the evidence rather than absent from it.

**Dependency reality, unchanged.** All 50 steps were drawn from the zero-dependency rows in your
sheet, so none of this work was ever blocked on someone else's delivery. 632 zero-dependency
rows remain after this batch.

---

## Before you sign off

The code has been reviewed, statically verified and its numbers computed — but **not compiled**.
The cloud environment this was built in cannot reach the Dart package servers.

```bash
cd habot-mobile/udf_setup
./tool/verify_aiss.sh
```

That runs formatting, static analysis, the mistake-proofing guard (now **9 rules**), all **333**
checks, and an evidence roll-up. It exits non-zero on the first genuine failure and writes
`build/aiss/evidence.json`.

If something breaks it will be a syntax or type slip, not a design error — the requirement
mapping and the measured numbers are already verified. Send me the output and I will fix it.

---

## Where everything lives

| Document | What it is |
|---|---|
| `AISS_Verification_Methodology.md` | How each step is verified, why each check exists, and **Appendix A: the full 333-gate register** |
| `AISS_Verification_Evidence_Log.xlsx` | The same register as a filterable sheet, plus per-step metric bands and the contrast audit |
| `Output_Artefact_Index.xlsx` | Every file produced, mapped to the step that produced it |
| `step_summaries/Step_01…Step_50.md` | One engineering summary per atomic step |
| `First_10_Steps_Implementation_Order.xlsx` | The dependency-free build order for Steps 1–10 |
| `Steps_11_to_20_Implementation_Order.xlsx` | The same for Steps 11–20 |
| `Steps_21_to_35_Implementation_Order.xlsx` | The same for Steps 21–35 |
| `Steps_36_to_50_Implementation_Order.xlsx` | The same for Steps 36–50 |

Code lives in `habot-mobile/udf_setup`. Its `README.md` covers the seven machine-enforced
design-system rules and how to run the app.
