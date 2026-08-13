# Step 11 of 50 — BPTR-0422

**Atomic Step Reference ID:** `BPTR-0422-A01`  
**Original S. No in the master sheet:** 257  
**Assigned to:** Fredrick  
**Estimated time:** 3 hours  
**Derived status:** **Complete**

> Define Passive Failure Motion Curves.

---

## What was delivered

The motion token library: failure duration, easing curve, dimming intensity, auto-scroll and pulse. After this step nothing in lib/ may declare a raw Duration or Curve - a new poka-yoke rule enforces it.

### Artefacts

- `lib/design_system/tokens/motion_tokens.dart`
- `lib/design_system/tokens/tokens.json`
- `test/aiss/bptr_0422_test.dart` — the gates for this step

## Requirement -> gate mapping

**8 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `BPTR-0422-G1` | 4 Substeps #1: "Set animation duration (300ms)." | Failure duration is exactly 300ms and is the emphasized rung of the shared ladder | Active |
| `BPTR-0422-G2` | 4 Substeps #2: "Define easing curve." | A failure curve is defined, is decelerating, and is distinct from the generic default | Active |
| `BPTR-0422-G3` | 4 Substeps #3: "Decide dimming intensity." + Poka-Yoke: "Animation physically locks surrounding UI until acknowledged." | Dim opacity sits in a usable band and the UI-lock flag is on | Active |
| `BPTR-0422-G4` | 4 Substeps #4: "Set auto-scroll." | Auto-scroll is decided (enabled) and has a duration no slower than the failure animation itself | Active |
| `BPTR-0422-G5` | Self-Chasing: "Failed element pulses continuously until resolved." | Pulse period and opacity bounds are defined and coherent | Active |
| `BPTR-0422-G6` | Completion Measures: "Standardized CSS transitions defined." + What Standardized Must Be Done: "Motion and animation design tokens." | The duration ladder is strictly ascending, every curve is a real curve, and no interactive transition exceeds the 200ms ceiling | Active |
| `BPTR-0422-G7` | Common Library to Store: "Motion & Animation System" -- tokens.json is the source of truth. | Every motion constant in Dart matches tokens.json exactly (no drift) | Active |
| `BPTR-0422-G8` | Atomic Reusability: "Wraps all compliance/validation failures." + Mobile-First UX Decision: "Motion draws eye to failure point on any screen." | Failure, stepper-enter, stepper-exit and standard each resolve to a distinct curve, so motion carries meaning | Active |

## Metric result

| | |
|---|---|
| **Metric** | Requirements Traceability Coverage |
| **Floor** | 90.0 |
| **Optimal** | 98.0 |
| **Ceiling** | 100.0 |
| **Observed** | 8 of 8 declared motion requirements gated = 100% |
| **Output scale** | Complete (Scale: Complete/Partial/Not Complete) |

## Expected Output (from the sheet)

> CSS motion token library.

## Completion Measure (from the sheet)

> Standardized CSS transitions defined.

## Mistake-proofing, as implemented

> Animation physically locks surrounding UI until acknowledged.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/bptr_0422_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
