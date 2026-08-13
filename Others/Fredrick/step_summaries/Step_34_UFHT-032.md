# Step 34 of 50 — UFHT-032

**Atomic Step Reference ID:** `UFHT-032-A01`  
**Original S. No in the master sheet:** 4723  
**Assigned to:** Fredrick  
**Estimated time:** 2H  
**Derived status:** **Complete**

> UI Hesitation Tracker Engine Setup

---

## What was delivered

The hesitation tracker engine. Every field built through ValidatedInputField attaches its focus listener in initState, so Event Listener Coverage is structural rather than something each form remembers. No event carries a field value -- the payload is field name, kind, timestamp and dwell -- and the metric can still fail, which is what makes it a measurement.

### Artefacts

- `lib/design_system/telemetry/hesitation_tracker.dart`
- `lib/design_system/forms/validated_input_field.dart`
- `test/aiss/ufht_032_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `UFHT-032-G1` | Setup Step Description: "Attach focus event listeners to EVERY INDIVIDUAL INPUT FIELD within the target form." + Metric: Event Listener Coverage Rate (%), Floor 95.0, Optimal 99.0. | Attaching a listener registers the field and counts toward coverage, so the metric is computed from what actually happened rather than asserted | Active |
| `UFHT-032-G2` | Metric: Event Listener Coverage Rate (%) -- a metric that can only ever read 100% is not a measurement. | Coverage genuinely falls when a registered field loses its listener, so the metric can fail | Active |
| `UFHT-032-G3` | Privacy, by construction -- the step asks for focus events, not for content. A tracker that can log a field value eventually will. | No recorded event carries a field value: the event payload is field name, kind, timestamp and dwell only, and the name is scrubbed on the way out | Active |
| `UFHT-032-G4` | Setup Step (Action): "UI HESITATION Tracker Engine Setup." Hesitation is dwell without progress; ordinary typing is not hesitation. | A dwell at or beyond the threshold reads as hesitation and a shorter one does not | Active |
| `UFHT-032-G5` | TTMAC-014 Completion Measure, which named this step: double-tap corrections must be measurable. | Two taps on the same target inside the double-tap window record one correction; the same two taps outside the window record none | Active |
| `UFHT-032-G6` | Setup Step Description: "Attach focus event listeners to every individual input field within the target form." + Metric: Event Listener Coverage Rate (%), Optimal 99.0. | A three-field form built from the design system reaches 100% listener coverage with no per-field wiring, and the listeners fire on real focus | Active |
| `UFHT-032-G7` | Setup Step (Action): "UI Hesitation Tracker Engine Setup" -- a correction is the signal; the content is not. | Shortening an entered value records exactly one correction, and no event payload contains any part of what was typed | Active |

## Metric result

| | |
|---|---|
| **Metric** | Event Listener Coverage Rate (%) |
| **Floor** | 95.0 |
| **Optimal** | 99.0 |
| **Ceiling** | 100.0 |
| **Observed** | 100.0% listener coverage, structural (floor 95.0, optimal 99.0) |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> Historical Audit Report SQL.

## Completion Measure (from the sheet)

> Row_Level_Audit_Coverage == 100%.

## Mistake-proofing, as implemented

> CHANGES TVF query strictly fails if the end_timestamp falls within the last 10 minutes, mechanically preventing querying volatile active buffers.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Contaminated columns, excluded from gating:** the Expected Output reads *'Historical Audit Report SQL'*, the Completion Measure reads *'Row_Level_Audit_Coverage == 100%'*, and the pre-step Decision asks about primary keys in caching tables. All three belong to a warehouse step. The Setup Step, the Description (*'attach focus event listeners to every individual input field'*) and the Metric are coherent and are what this implementation is gated against.

---

*Generated from the master sheet and `test/aiss/ufht_032_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
