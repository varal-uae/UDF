# Step 18 of 35 — BPTR-0160

**Atomic Step Reference ID:** `BPTR-0160-A01`  
**Original S. No in the master sheet:** 3073  
**Assigned to:** Fredrick  
**Estimated time:** 2H  
**Derived status:** **Complete**

> Code and isolate mobile compound fields into distinct, standalone UI components featuring strict 48x48dp touch targets.

---

## What was delivered

Compound fields (address, date-time, contact, amount) as isolated components. Each part keeps its own 48dp target and its own CDE rule, which is what makes Invalid_Data_Type_Errors == 0 reachable at all.

### Artefacts

- `lib/design_system/forms/compound_field.dart`
- `lib/design_system/forms/field_validation.dart`
- `test/aiss/bptr_0160_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `BPTR-0160-G1` | What Standardized Must Be Done: "Global Regex mapping per CDE applied to mobile text fields." + Completion: `Invalid_Data_Type_Errors == 0`. | Every CDE has a regex rule -- the completion measure is unreachable if even one data type is unmapped | Active |
| `BPTR-0160-G2` | Setup Step Description: "Identify all compound entry fields (e.g., split address blocks, combined date-time fields) in mobile views." + Metric: Field/Element Identification Accuracy (Floor 95, Optimal 99). | The compound-field inventory is declared as data, covers the examples the spec names, and every part resolves to a real CDE rule | Active |
| `BPTR-0160-G3` | Mobile-First UX Implementation: `inputmode="numeric"` -- "Contextual keyboard triggering for faster thumb typing." | Numeric CDEs request a numeric keyboard; text CDEs do not | Active |
| `BPTR-0160-G4` | Mobile-First UI Decision: "Visual input masks (e.g., MM/DD/YYYY placeholders) inside the text field." | Every CDE whose format is not self-evident carries a placeholder, and the date placeholders match their patterns | Active |
| `BPTR-0160-G5` | Mobile-First UX Implementation: `autocomplete="off"`. | Autocomplete is off by default across every rule | Active |
| `BPTR-0160-G6` | Setup Step (Action): "isolate mobile compound fields into distinct, standalone UI components featuring strict 48x48dp touch targets." | The date-time compound stacks on a 320dp viewport and each part renders at least 48dp tall | Active |
| `BPTR-0160-G7` | Self-Chasing: "User cannot tap the submit button while the field is invalid, forcing them to fix their own typo instantly to proceed." | An address block with one bad part blocks the whole compound | Active |

## Metric result

| | |
|---|---|
| **Metric** | Field/Element Identification Accuracy |
| **Floor** | 95.0 |
| **Optimal** | 99.0 |
| **Ceiling** | 100.0 |
| **Observed** | 13 of 13 compound parts identified and mapped to a CDE regex rule = 100% |
| **Output scale** | Pass (Scale: Pass/Fail) |

## Expected Output (from the sheet)

> Coded Input Mask Components.

## Completion Measure (from the sheet)

> Invalid_Data_Type_Errors == 0.

## Mistake-proofing, as implemented

> Mobile OS physically restricts keystrokes based on the inputmode attribute.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/bptr_0160_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
