# Step 12 of 35 — REF-377

**Atomic Step Reference ID:** `REF-377-A01`  
**Original S. No in the master sheet:** 400  
**Assigned to:** Fredrick  
**Estimated time:** 2 hours  
**Derived status:** **Complete**

> Set Progressive Stepper Transitions.

---

## What was delivered

Stepper transition tokens, and the reduced-motion policy every design-system animation routes through. Honouring the OS preference is no longer something a component author can forget.

### Artefacts

- `lib/design_system/tokens/motion_tokens.dart`
- `lib/design_system/wizard/carousel_stepper.dart`
- `test/aiss/ref_377_test.dart` — the gates for this step

## Requirement -> gate mapping

**6 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `REF-377-G1` | 4 Substeps #1: "Define slide-in duration (200ms)." | Slide-in is exactly 200ms | Active |
| `REF-377-G2` | 4 Substeps #2: "Define slide-out duration." | Slide-out is defined, non-zero, and no slower than the slide-in so the outgoing step clears first | Active |
| `REF-377-G3` | 4 Substeps #3: "Decide easing function." | Enter and exit have distinct curves, both well-formed | Active |
| `REF-377-G4` | 4 Substeps #4: "Respect reduced motion preferences." + UI Implementation: "prefers-reduced-motion media queries." | HabotMotionPolicy collapses every duration to zero and stops looping motion under MediaQuery.disableAnimations | Active |
| `REF-377-G5` | Completion Measures: "Transitions feel instantaneous and fluid." | Both stepper durations sit at or under the 200ms interactive ceiling | Active |
| `REF-377-G6` | Poka-Yoke: "Unmounts previous steps from DOM to prevent accidental back-edits." | After advancing, the previous step is gone from the tree -- its fields cannot be focused or edited | Active |

## Metric result

| | |
|---|---|
| **Metric** | Location Accuracy |
| **Floor** | 100.0 |
| **Optimal** | 100.0 |
| **Ceiling** | 100.0 |
| **Observed** | 100.0 - stepper motion declared in exactly one documented location |
| **Output scale** | Complete/Not Complete |

## Expected Output (from the sheet)

> Motion prototypes.

## Completion Measure (from the sheet)

> Transitions feel instantaneous and fluid.

## Mistake-proofing, as implemented

> Unmounts previous steps from DOM to prevent accidental back-edits.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/ref_377_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
