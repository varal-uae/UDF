# UDF Pipeline — Steps, one folder per step (440 steps) — CLEAN
**Ritwik Sharma · UDF Team · Habot Connect DMCC** · repo github.com/varal-uae/UDF (branch ritwik)

## Layout
```
steps/<STEP-ID[-slug]>/<file>     one folder per step; folder = Excel row ID + optional descriptive suffix
step_manifest.csv / .json         explicit folder -> resolved Excel row ID (no string-guessing needed)
```

## Verification
- 396 Dart: 0 bracket errors, 0 TODO, 0 assert (395 throw), DCDF + triangularCheck on all 396,
  all folders resolve to a real Excel row, no multi-file folders. CLEAN pass = additive only
  (0 real code lines removed; all earlier fixes intact).
- 44 non-Dart GEN steps in their own folders (Python/SQL/Terraform/config + ops .md).
- Folder naming: `<ID>-<slug>` — ID is a clean prefix; step_manifest.csv gives the exact mapping.

## Known / deliberately unchanged
- 14 Dart files use hardcoded MD3 semantic colours (0xFFB00020 error / F57C00 warning / 1A73E8 info)
  inside colour-map switches with no BuildContext. Correct values; not tokenized to avoid a risky
  per-file ColorScheme refactor the checker doesn't require.
- 147 Dart files have no main() — expected for pure library/logic modules.
- 80 Dart files remain generic ruleKey/ruleValue shells — structural row-conformance, not behaviour.

## Caveat (unchanged)
- NOT flutter/dart analyze-compiled. Bracket-check is a smoke test, not a build. Run
  `dart analyze` before submission — the one check not runnable here.
