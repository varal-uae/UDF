# AEETE Pipeline — Targeted Fix Punch-List (updated)
_Full scan of 204 files against the sheet. Most are sound; these are the objective defects._

## DONE
Gate asserts -> throws (fail-closed in release). CATEGORY CLOSED — 0 gate asserts remain.
  Batch 1: aeete_034, amlco_002, ansa_001_a02 (immutability) + AEETE-023 (TODO->sinks)
  Batch 2: bdae_008_a04 (RAW-secret), blgta_009 (TLS/DCDF),
           arcpe_009_15 (breaking-change), arcpe_016_06 (propagation)
  Batch 3: ansa_001_a06/a11/a15/a16, ansa_002_a06, amlco_004 (immutability)
Output-vocabulary alignment (checked against sheet column AP per row):
  - AEETE-018: conformanceOutput Optimal/Floor/Fail -> Complete/Partial/Not Complete
  - AEETE-023: coverageOutput   Optimal/Floor/Fail -> Pass/Fail
  Verified NOT mismatched (already correct; Optimal/Floor only used as color tiers):
  bdae_011_a14, bdae_015, blgta_009, blgta_010

## REMAINING — optional only
- ~20 files: assert(componentRef == '...') config guard -> throw (hardening, not a bug)
- ~8 files: header comments claim parity with an unverifiable .py twin (cosmetic)

## DELIBERATELY NOT TOUCHED
- Hardcoded PASS/Good status banners (Anik's accepted house style — converting risks
  diverging from what the validation stage accepts). Decide once the ADFA/VAL stage is known.
- ~1,400 constructor/range asserts — idiomatic Dart, correct as-is.

## CANNOT VERIFY HERE
No Flutter SDK. Edits are bracket-checked only. Run `flutter analyze` before submitting.
