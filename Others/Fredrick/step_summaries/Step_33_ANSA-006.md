# Step 33 of 50 — ANSA-006

**Atomic Step Reference ID:** `ANSA-006-A01`  
**Original S. No in the master sheet:** 3194  
**Assigned to:** Fredrick  
**Estimated time:** 5 Hours  
**Derived status:** **Complete**

> Implementation Step 15: Build an expandable search text line inside primary system headers. (ANSA-006)

---

## What was delivered

The expandable header search: a debounce that collapses a burst of keystrokes into one query, a punctuation filter that removes the characters which turn a search box into an injection vector, results grouped by category below the field, and a local keyword history that only remembers searches that found something.

### Artefacts

- `lib/design_system/navigation/header_search.dart`
- `lib/design_system/tokens/surface_tokens.dart`
- `test/aiss/ansa_006_test.dart` — the gates for this step

## Requirement -> gate mapping

**7 gates.** Each defends a named column of the step sheet.

| Gate | Requirement defended (verbatim) | What it asserts | Status |
|---|---|---|---|
| `ANSA-006-G1` | Poka-Yoke: "Filter out invalid code punctuation marks from search inputs automatically to prevent database query errors." | Quotes, escapes, statement separators, wildcards and bracket forms are stripped from the query before it can reach a data source, and the remaining text is preserved intact | Active |
| `ANSA-006-G2` | 4 Substeps #2: "wait for typing pauses BEFORE RUNNING QUERIES." A query per keystroke is the failure this substep exists to prevent. | A query shorter than the minimum never runs at all, and the debounce window is a motion token rather than a number in the widget | Active |
| `ANSA-006-G3` | 4 Substeps #4: "Save successful lookup keyword values locally to provide quick repeat lookups." | The local keyword history keeps the most recent entries only, without duplicates, capped at the documented limit | Active |
| `ANSA-006-G4` | 4 Substeps #4: "Save SUCCESSFUL lookup keyword values locally." A history of searches that found nothing is a list of dead ends. | A zero-result query leaves the local history untouched | Active |
| `ANSA-006-G5` | 4 Substeps #2: "Setup brief keypress delay timers to wait for typing pauses before running queries." | Four keystrokes inside the debounce window produce exactly one query, issued with the final text | Active |
| `ANSA-006-G6` | 4 Substeps #3: "Render clear category match dropdown grids directly below the header search bar." | Matches render grouped by category in a panel positioned below the search line, and a tap returns the selected result | Active |
| `ANSA-006-G7` | Completion Measures: "Entering valid search terms returns matching assets inside dropdown lists under 350ms." + GEN-01297, consumed for the zero-result case. | The client-side query completes inside the 350ms budget and a query with no matches renders the empty state rather than a blank panel | Active |

## Metric result

| | |
|---|---|
| **Metric** | Environment & Configuration Setup Readiness |
| **Floor** | Config file located & version-controlled |
| **Optimal** | Config file opened in correct branch with schema validated pre-edit |
| **Ceiling** | N/A (gate, not a range) |
| **Observed** | Config version-controlled and schema-validated; the 350ms completion budget holds app-side |
| **Output scale** | Pass/Fail |

## Expected Output (from the sheet)

> Full-screen expanding search handlers and quick filtered result lists.

## Completion Measure (from the sheet)

> Entering valid search terms returns matching assets inside dropdown lists under 350ms.

## Mistake-proofing, as implemented

> Filter out invalid code punctuation marks from search inputs automatically to prevent database query errors.

Enforced by the gates above and, where it is a code rule, by the poka-yoke guard in
`test/guards/poka_yoke_no_hardcoded_values_test.dart`.

---

*Generated from the master sheet and `test/aiss/ansa_006_test.dart`. Regenerate with `./tool/verify_aiss.sh`.*
