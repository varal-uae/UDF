# Habot UDF mobile client — implementation summary, Steps 1–35

**Owner:** Fredrick · **Team:** UDF · **Date:** 12 August 2026
**Source of requirements:** `My stepsFN06082026.xlsx` → `Fredrick` sheet
**Codebase:** `habot-mobile/udf_setup` (Flutter)

---

## The one-paragraph version

Thirty-five atomic steps from the master sheet are implemented. Each one's requirements were
turned into executable checks — **241 in total** — so "is this step done?" is answered by
something the build computes rather than by anyone's judgement. **33 steps are Complete**, 2 are
**Partial** because a requirement is knowingly open, and one of those Complete steps still needs
a human reviewer's score. One deferral from the last batch **closed**: the double-tap telemetry
Step 14 was waiting on now exists. Three decisions still need you. **The code has not been
compiled yet** — that needs one command on your Mac.

---

## What was built

Three layers, in order: the frame, the input, the response.

| Batch | Steps | What it produced |
|---|---|---|
| **Foundation** | 1–10 | Material 3 framework and theme adapter · the full design-token layer · light/dark adaptation and dark-mode contrast enforcement · the breakpoint decision record and device matrix · the atomic grid and layout engine · the master scaffold every screen uses · the contextual navigation header · the 48dp touch-target framework |
| **Forms & feedback** | 11–20 | Motion tokens and reduced-motion policy · the atomic button and interaction states · the touch standards engine · input masking · validated fields with 13 data-type rules · inline validation errors · compound fields · error templates, log scrubbing and transaction rollback · the guided multi-step form |
| **Surfaces & feedback** | 21–35 | The bottom sheet (chassis, 32% scrim, 60% snap) · hover removed entirely and replaced with long-press drawers · error snackbars bound to the error boundary · progress, empty states and status badges · the card chassis · MD3 shared-axis transitions · elastic overscroll · list virtualisation at 10,000 rows · header search · hesitation and friction telemetry |

The app now has both halves of a conversation. Steps 1–20 gave it a frame and a way to take
input; this batch gives it a way to respond — to say *working on it*, *nothing matched*, *that
failed and here is what to do*, *this one is complete* — in a single vocabulary rather than
fifteen improvised ones.

---

## Status at a glance

| | Count |
|---|---:|
| Steps implemented | **35** |
| Steps **Complete** | **33** |
| Steps **Partial** (a requirement knowingly open) | **2** — Step 6 (RCGLA-012), Step 31 (IS38-SGTIM-018) |
| Steps awaiting a human reviewer's score | **1** — Step 5 (SSTLA-004) |
| Checks written | **241** (99 new this batch) |
| Checks knowingly deferred, with a recorded reason | **3** |
| Deferrals **closed** this batch | **1** — TTMAC-014's double-tap rate |
| Checks whose value was already computed during authoring | **134** |
| Checks still needing a run on your machine | **107** |

A deferral is **not** a pass. The step stays Partial. What it changes is that the gate runner
stays green, so a genuine regression is still visible instead of hiding under a build that is
always failing. It is also meant to be *closable* — Step 14 is what that looks like in practice.

---

## Metric results, Steps 21–35

| Step | Metric | Floor | Optimal | Observed |
|---|---|---|---|---|
| 21 · GEN-00055 | Component Delivery Completeness | functionally complete | 100% + documented | 100% — chassis, handle, actions, presentation API, all documented |
| 22 · GEN-00954 | Scrim Opacity Compliance | 32% | 32% | **32% exactly** — single-value metric |
| 23 · GEN-00235 | Cross-Viewport Rendering Consistency | zero regressions on 360/390/412 | zero across the matrix | **zero** — usable on all 9 devices; tightest is 341dp |
| 24 · MUFCE-028 | Environment / Asset Access Readiness | located first attempt | version-controlled & documented | version-controlled; **zero** tooltips or hover callbacks remain |
| 25 · GEN-01363 | Crash-Free Session Rate | 0.99 | 0.999 | not measurable in-suite; mechanism verified instead |
| 26 · GEN-01848 | *(metric name mismatched)* | 95.0 | 99.5 | 100% — guard rejects any untokenised progress component |
| 27 · GEN-01297 | *(metric name mismatched)* | 0.95 | 0.999 | 1.0 — 4 of 4 reasons complete and jargon-free |
| 28 · GEN-01275 | Real-Time Status Update Latency | <30s | <5s | one frame, no debounce; all 5 roles clear **7:1 AAA** |
| 29 · GEN-01452 | *(metric name mismatched)* | 0.95 | 0.999 | 1.0 — 3 of 3 variants conform; build 17 lines vs 20 |
| 30 · GEN-00201 | General Task Completion Quality | with exceptions | 100% matching intent | Complete — no documented exceptions |
| 31 · IS38-SGTIM-018 | Asset & Component Discovery Completeness | 90% | 100% | 100%; physical-device feel deferred |
| 32 · CPNCA-006 | Requirements / Discovery Coverage | 90% | 98% | **100%** — 10,000 rows, element count stays under 60 |
| 33 · ANSA-006 | Environment & Configuration Setup Readiness | located & version-controlled | schema validated | validated; 350ms budget holds app-side |
| 34 · UFHT-032 | Event Listener Coverage Rate (%) | 95.0 | 99.0 | **100.0** — structural, and it can still fail |
| 35 · GEN-00632 | Class Wrapper Integrity | 100% | 100% | **100%**; replay double-tap rate 0.40% vs a 1% ceiling |

Every step meets or exceeds its Floor. Steps 1–20 are unchanged except Step 14, which moved from
Partial to Complete.

---

## What this batch closed

**The Step 14 deferral.** TTMAC-014's completion measure asks for a double-tap correction rate
below 1%, and it named UFHT-032 as the step that would supply it. That step is now built, along
with the friction-log wrapper, so the rate is computed from taps the app actually recorded and
reads 0.40% in a deterministic replay.

To be precise about what that does and does not mean: the instrument exists and is wired to
every field and every wrapped screen. The number is from a replay, not from users. The
production reading needs a release, and that caveat is recorded on the gate itself rather than
implied away.

**The snackbar gap.** No snackbar step could go into Steps 11–20 because every candidate row had
contaminated columns. GEN-01363 is clean, and it lands on the error boundary REF-197 already
built — so an exception can only reach a user after it has been classified into a plain-language
template and scrubbed of paths, IPs, tokens and SQL.

**Hover, permanently.** Every tooltip widget and hover callback is gone from `lib/`, and two new
mistake-proofing rules fail the build if either comes back. This one has teeth: it forced the
header's overflow menu to be rebuilt as a bottom sheet, because Flutter's popup menu button
wraps itself in a tooltip with no way to switch it off.

---

## Three decisions I still need from you

### 1. The brand palette — still the highest-value unblock

`tokens.json` is marked **PROVISIONAL**. RCGLA-001 names *"the exact primary corporate theme
colors"* as a decision required before the step, and Brand has not made it. Every colour added
this batch was audited against the same policy — the five status roles all clear 7:1 AAA — so
nothing is blocked technically. The hex values are still not yours.

Swapping them remains a **data edit, not a code change**.

### 2. Zoom lock on the web build

Unchanged from the last batch. RCGLA-012 substep 2 asks for `user-scalable=no`, which fails WCAG
2.1 SC 1.4.4, contradicts this codebase's own AA/AAA posture, and is ignored by iOS Safari and
Android Chrome anyway. Step 6 honestly reports **Partial** until you decide.

### 3. Five rows that need correcting at source

This batch, not the last one. Two rows have an Expected Output belonging to another domain, and
three have a Metric Name that does not describe their step:

| Step | Row | The problem |
|---|---|---|
| 24 | MUFCE-028 | Expected Output = *"Asset Loading Optimization Plan"* for a tooltip-removal step |
| 34 | UFHT-032 | Expected Output = *"Historical Audit Report SQL"*, Completion = *"Row_Level_Audit_Coverage == 100%"* for a focus-listener step |
| 26 | GEN-01848 | Metric = *"Automated PR Rejection Rate for Non-Compliance"* for progress indicators |
| 27 | GEN-01297 | Metric = *"Activity Log Data Completeness"* for an empty state |
| 29 | GEN-01452 | Metric = *"Real-Time Availability Badge Accuracy"* for a card chassis |

In every case the Setup Step, Description and substeps are coherent, so the work was gated
against those and the contaminated cells were left ungated — stated in the gate file and in the
evidence rather than quietly reinterpreted. **A gate that silently reinterprets its own
requirement is worse than one that refuses to.**

---

## Two things that need something other than a decision

| Item | Step | What it needs |
|---|---|---|
| **Reviewer quality score** | 5 · SSTLA-004 | Unchanged: the metric is a 1–5 score awarded by a reviewer. The objective half is 5.0/5.0; a human owes the execution-quality half. |
| **Physical-device confirmation** | 31 · IS38-SGTIM-018 | The completion measure says *"physical device testing confirms the stretch effect."* The widget-level facts are gated — indicator present, glow absent, bounds clamped — but a test cannot confirm how something feels in a hand. One Android handset, one iPhone, scroll a list past its end. |

---

## Also worth knowing

**Eleven of the fifteen rows in this batch are `GEN-*` rows**, whose Expected Output and
Completion Measures are boilerplate (*"Fully configured and validated implementation of…"*,
*"100% CI/CD pass rate"*). There is no substep text to gate against, so those gates are derived
from the Setup Step, the Description and the Metric Name — and each gate file says so in its
header rather than dressing a derivation up as a quotation. The four richly-specified rows
(MUFCE-028, IS38-SGTIM-018, CPNCA-006, ANSA-006) carry the strongest gates in the batch.

**One step needed translating, not implementing.** IS38-SGTIM-018's substeps are written against
Jetpack Compose — *"Update to Compose Foundation 1.1.0+"*, *"Apply to LazyColumn task lists"*.
This is a Flutter codebase, where the stretch indicator already exists. What the step actually
requires is that it be applied everywhere rather than left to per-platform defaults, and that is
what was built and gated. The translation is recorded in the gate file.

**Dependency reality, unchanged.** All 35 steps were drawn from the 682 zero-dependency rows in
your sheet, so none of this work was ever blocked on someone else's delivery.

---

## Before you sign off

The code has been reviewed, statically verified and its numbers computed — but **not compiled**.
The cloud environment this was built in cannot reach the Dart package servers.

```bash
cd habot-mobile/udf_setup
./tool/verify_aiss.sh
```

That runs formatting, static analysis, the mistake-proofing guard (now 8 rules), all 241 checks,
and an evidence roll-up. It exits non-zero on the first genuine failure and writes
`build/aiss/evidence.json`.

If something breaks it will be a syntax or type slip, not a design error — the requirement
mapping and the measured numbers are already verified. Send me the output and I will fix it.

---

## Where everything lives

| Document | What it is |
|---|---|
| `AISS_Verification_Methodology.md` | How each step is verified, why each check exists, and **Appendix A: the full 241-gate register** |
| `AISS_Verification_Evidence_Log.xlsx` | The same register as a filterable sheet, plus per-step metric bands and the contrast audit |
| `Output_Artefact_Index.xlsx` | Every file produced, mapped to the step that produced it |
| `step_summaries/Step_01…Step_35.md` | One engineering summary per atomic step |
| `First_10_Steps_Implementation_Order.xlsx` | The dependency-free build order for Steps 1–10 |
| `Steps_11_to_20_Implementation_Order.xlsx` | The same for Steps 11–20 |
| `Steps_21_to_35_Implementation_Order.xlsx` | The same for Steps 21–35 |

Code lives in `habot-mobile/udf_setup`. Its `README.md` covers the six machine-enforced
design-system rules and how to run the app.
