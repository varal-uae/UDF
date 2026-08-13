# Step 31 of 50 — IS38-SGTIM-018-AS01

**Atomic Step Reference ID:** `IS38-SGTIM-018-AS01-A01`  
**Original S. No in the master sheet:** 1555  
**Assigned to:** Fredrick  
**Estimated time:** 1h  
**Derived status:** **Partial**

> Apply M3 Overscroll Stretch on MTOI Lists

---

## What was delivered

The elastic overscroll, applied app-wide instead of left to per-platform defaults. Android and Fuchsia stretch; iOS and macOS keep their own bounce; nothing glows. Bounds stay clamped, so the stretch is a visual effect over a scroll that has genuinely stopped.

### Artefacts

- `lib/design_system/layout/habot_scroll_behavior.dart`
- `lib/app.dart`
- `test/aiss/is38_sgtim_018_test.dart` — the gates for this step

## Requirement -> gate mapping

**8 gates.** One is deferred, with its reason recorded.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `IS38-SGTIM-018-G1` | 4 Substeps #1 and #2, translated: "Update to Compose Foundation 1.1.0+" / "Apply to LazyColumn task lists." In Flutter the stretch already exists; the requirement is that it be applied, not installed. | The behaviour declares the stretch for the Android family and only for the Android family, so no list has to opt in | Active |
| `IS38-SGTIM-018-G2` | 4 Substeps #2: "Apply to LazyColumn TASK LISTS" -- all of them. | The behaviour is installed once at the application root, so every scrollable in the app inherits it rather than remembering to ask | Active |
| `IS38-SGTIM-018-G3` | 4 Substeps #3: "Test scrolling bounds." + Poka-Yoke: "Built-in Material 3 physics prevent unnatural scrolling breaks or rigid UI halts." | Physics are clamped on the stretch platforms -- the stretch is a visual effect over a scroll that has genuinely stopped -- and bouncing where the platform itself bounces | Active |
| `IS38-SGTIM-018-G4` | Decision to be Made Before Setup Step: "How does the list feel when the user reaches the end of their task queue?" | The decision is recorded in the source next to the code it governs -- elastic, never a rigid halt, never a glow | Active |
| `IS38-SGTIM-018-G5` | Setup Step (Action): "Apply M3 Overscroll Stretch on MTOI Lists." + Poka-Yoke: "Built-in Material 3 physics prevent unnatural scrolling breaks." | A list rendered on Android carries the stretching overscroll indicator, and the pre-MD3 glow appears nowhere | Active |
| `IS38-SGTIM-018-G6` | 4 Substeps #4: "Verify physical elasticity FEEL." Elasticity on iOS is the platform bounce; imposing the Android stretch there would be the unnatural break the poka-yoke warns about. | On iOS no overscroll indicator is drawn and the scroll physics are the platform bouncing physics | Active |
| `IS38-SGTIM-018-G7` | 4 Substeps #3: "Test scrolling bounds." | At the end of the list a further drag leaves the scroll offset pinned to the maximum extent under clamping physics | Active |
| `IS38-SGTIM-018-G8` | Completion Measures: "Physical device testing confirms the stretch effect upon reaching the end of the MTOI task list." + 4 Substeps #4: "Verify physical elasticity feel on devices." | Physical-device confirmation of the stretch feel at the end of a task list | DEFERRED |

## Metric result

| | |
|---|---|
| **Metric** | Asset & Component Discovery Completeness - Material design 3 m3 ui components |
| **Floor** | 90% of target assets confirmed present |
| **Optimal** | 100% of target assets confirmed present |
| **Ceiling** | 100% (full inventory - no further discovery value beyond complete coverage) |
| **Observed** | 100% of target assets present. Physical-device confirmation outstanding (deferred gate) |
| **Output scale** | Complete/Partial/Not Complete |

## Expected Output (from the sheet)

> A polished, native-feeling list interaction.

## Completion Measure (from the sheet)

> Physical device testing confirms the stretch effect upon reaching the end of the MTOI task list.

## Mistake-proofing, as implemented

> Built-in Material 3 physics prevent unnatural scrolling breaks or rigid UI halts.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

## Decisions and open items

**Platform translation, recorded:** substeps 1 and 2 are written against Jetpack Compose (*'Update to Compose Foundation 1.1.0+'*, *'Apply to LazyColumn task lists'*). This codebase is Flutter, where the stretch indicator already exists -- what the step actually requires is that it be applied everywhere rather than left to per-platform defaults. The translation is stated in the gate file rather than quietly performed.

**Decision recorded:** *'How does the list feel when the user reaches the end of their task queue?'* -> elastic. It stretches and settles; never a rigid halt, never a glow.

**One gate deferred:** the completion measure asks for physical device testing of the stretch feel. A widget test proves the indicator is present and the bounds hold; it cannot confirm how something feels in a hand. The step stays **Partial** until someone runs it on hardware.

---

*Generated from the master sheet and `test/aiss/is38_sgtim_018_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
