# habot-mobile

Cross-platform mobile app for Habot, built with **Flutter** and maintained by the **UDF** team.

The Flutter project lives in [`udf_setup/`](udf_setup).

## Getting started

```bash
cd udf_setup
flutter pub get     # install dependencies
flutter run         # run on a connected device / emulator
```

`flutter run` opens a design-system probe screen that exercises every primitive built so far.
Tap the grid icon in the header to overlay the live column/gutter/rhythm wireframe.

## Verify before you commit

```bash
cd udf_setup
./tool/verify_aiss.sh          # format, analyze, poka-yoke guard, 333 AISS gates, evidence roll-up
./tool/verify_aiss.sh --check  # CI mode: fails on unformatted code instead of formatting it
```

Exits non-zero on the first failure and writes `build/aiss/evidence.json` plus
`build/aiss/contrast_audit.txt`. Deferred gates (recorded open decisions) are listed separately
and do **not** fail the run — only unexplained breakage does.

Full explanation of what each gate defends and why:
`../Others/Fredrick/AISS_Verification_Methodology.md`.

## Design system

Everything visual comes from `udf_setup/lib/design_system`. Seven rules, all machine-enforced:

1. **No raw values in `lib/`.** No hex colours, no bare numbers inside `EdgeInsets`,
   `BorderRadius` or `SizedBox`, **no raw `Duration` or `Curves.*`**. Import a token instead.
2. **`tokens.json` is the source of truth.** The Dart constants mirror it, and `RCGLA-001-G6`
   fails the build if the two drift apart. Change both, or change neither.
3. **Only `theme/habot_theme.dart` may construct a `ThemeData`.**
4. **Every screen uses `HabotMasterScaffold`.** It exposes no padding parameter — spacing comes
   from tokens or it does not exist. `RCGLA-018-G4` scans for screens that skip it.
5. **Every interactive element goes through `AtomicButton` or `HabotTouchTarget`.** Raw
   `IconButton` and `GestureDetector` are banned in `lib/` (`TTMAC-011-G4`).
6. **No hover affordances.** No tooltip widgets, no `onHover` callbacks anywhere in `lib/`
   (`MUFCE-028-G1`). Rich metadata goes to a bottom drawer through
   `HabotMetadataDisclosure` -- long-press, or a quick tap on the trailing icon. A hover
   tooltip is unreachable on a phone, so information that only appears on hover does not
   exist there.
7. **One `Scaffold` in the codebase.** Only `layout/master_scaffold.dart` may construct one
   (`ROGUE_SCAFFOLD`). `HabotAppShell` is deliberately a *body*, not a scaffold owner, so a
   destination supplies content and never gets the chance to bring a wrapper of its own.

### Layout

| Window class | Width | Columns |
|---|---|---|
| compact | < 600dp (`xs`/`sm`) | 4 |
| medium | 600–839dp | 8 |
| expanded | ≥ 840dp | 12 |

Outer margin 16dp · **column gutter 16dp** · **vertical rhythm 8dp** · minimum supported width
320dp · side navigation collapses below 768dp · maximum 4 vertical segments on compact.

> The two gutter values are deliberate. RCGLA-012 and RCGLA-032 contradict each other in the
> step sheet; the resolution is recorded in `tokens/device_matrix.json` and gated by
> `SSTLA-004-G4`. See §6 of the methodology doc.

### Interaction

Every interactive element goes through `HabotTouchTarget`: minimum 48×48dp tap area, transparent
expansion around small icons, 8dp safety margin between neighbours, long-press for detail. Raw
`IconButton` and `GestureDetector` are banned in `lib/` (`TTMAC-011-G4`).

### Implemented steps

| # | Ref | What it delivered | Gates |
|---|---|---|---|
| 1 | TTMCS-001 | Material 3 framework + global theme adapter, fluid containers, page frame | 7 |
| 2 | RCGLA-001 | Colour / typography / spacing / elevation / shape tokens + `tokens.json` | 6 |
| 3 | TTMCS-004 | Light/dark adaptation tokens, OS brightness listener, no-full-reflow theme scope | 9 |
| 4 | TTMCS-005 | Dark surface elevation ladder, WCAG contrast enforcement | 8 |
| 5 | SSTLA-004 | Breakpoint/column/margin/gutter decision record, device matrix, grid wireframe | 8 |
| 6 | RCGLA-012 | xs/sm breakpoints, viewport meta, `MobileGridContainer`, pixel-width lint | 7 |
| 7 | RCGLA-032 | Global layout boundary, segment listener, compact viewport checks | 7 |
| 8 | RCGLA-018 | `HabotMasterScaffold` with locked metrics and no padding escape hatch | 6 |
| 9 | ANSA-012 | 64dp contextual header, title cap, scroll elevation, double-tap-safe back | 7 |
| 10 | TTMAC-011 | 48dp touch-target framework, safety margins, long-press detail | 7 |
| 11 | BPTR-0422 | Passive failure motion curves (300ms, easing, dimming, auto-scroll) | 8 |
| 12 | REF-377 | Progressive stepper transitions, reduced-motion honoured everywhere | 6 |
| 13 | BPTR-0128 | `AtomicButton` (13 lines) + MD3 interaction state layers | 7 |
| 14 | TTMAC-014 | Touch standards engine: protective padding, icon sizes, clearance | 7 |
| 15 | CSIVW-001 | Input masking: keystroke filter, ASCII hygiene, paste caps | 7 |
| 16 | IS12-CSIVW-011 | `ValidatedInputField`, 13 CDE rules, quick-clear, submit gating | 7 |
| 17 | IS02-CSIVW-005 | Blur-bound inline errors, submission freeze | 6 |
| 18 | BPTR-0160 | Compound fields as isolated 48dp components, global regex map | 7 |
| 19 | REF-197 | Error templates, log scrubber, rollback boundary | 7 |
| 20 | FIEVR-033 | `WizardStepMachine` + `CarouselStepper` (17 lines) with progress dots | 8 |
| 21 | GEN-00055 | `HabotBottomSheet` chassis: drag handle, MD3 corners, tokenised padding | 7 |
| 22 | GEN-00954 | 32% black scrim, one standard sheet presentation, reduced-motion aware | 6 |
| 23 | GEN-00235 | 60% viewport snap point, verified across all 9 matrix devices | 6 |
| 24 | MUFCE-028 | Hover removal; `HabotMetadataDisclosure` long-press drawer; overflow sheet | 7 |
| 25 | GEN-01363 | `HabotErrorSnackbar` bound to the error boundary, scrubbed and retryable | 7 |
| 26 | GEN-01848 | Determinate progress bar, spinner and step progress; reduced-motion safe | 7 |
| 27 | GEN-01297 | `HabotEmptyState`: 4 reasons, own illustration and copy each | 6 |
| 28 | GEN-01275 | `HabotStatusBadge` / `HabotMilestoneNode`, icon + label + colour (SC 1.4.1) | 6 |
| 29 | GEN-01452 | `HabotCard` chassis: filled / outlined / elevated, never border + shadow | 7 |
| 30 | GEN-00201 | MD3 shared-axis transitions with a disjoint fade-through | 6 |
| 31 | IS38-SGTIM-018 | `HabotScrollBehavior`: stretch on Android family, bounce on iOS | 8 |
| 32 | CPNCA-006 | `HabotVirtualList` + chunking: 10,000 rows, flat element count | 7 |
| 33 | ANSA-006 | Header search: debounce, punctuation filter, grouped results, history | 7 |
| 34 | UFHT-032 | Hesitation tracker: focus listeners on every field, value-free events | 7 |
| 35 | GEN-00632 | `FrictionTracker` wrapper and friction report | 5 |
| 36 | SSTLA-012 | The Contextual Mirror blueprint; 8 of 9 devices mirror in both orientations | 7 |
| 37 | GEN-03270 | `HabotSplitView` + `HabotMasterDetail`; 18 of 18 viewports usable | 6 |
| 38 | SSTLA-010 | Pane distribution and the pinned metric strip (outside the scroll view) | 5 |
| 39 | SSTLA-018 | 5.5-inch reference viewport, thumb band, section locking by prerequisite | 6 |
| 40 | GEN-02334 | Navigation rail above 768dp, bottom bar below, never both | 6 |
| 41 | GEN-02676 | Unread badge: 99+ cap, zero hides, spoken label | 5 |
| 42 | GEN-00999 | Deep-link context restoration, LRU-capped at 16, JSON round-trip | 6 |
| 43 | GEN-02082 | Route table and app shell; the router never throws | 5 |
| 44 | GEN-01474 | 200ms tab-switch benchmark, measured through the real shell | 5 |
| 45 | GEN-00022 | Dashboard stacking: 1 column compact, 2 above; 18 viewports rendered | 6 |
| 46 | GEN-02060 | Text fit at 320dp: body wraps, labels keep 12 chars, floor 11sp | 8 |
| 47 | GEN-02720 | Connectivity state machine driven by the poll *timeout* | 7 |
| 48 | GEN-03437 | Offline banner + queue counter; contrast measured 7.28-13.39:1 | 7 |
| 49 | IS22-RCGLA-022 | Preference manager: optimistic write, rollback, transition guard | 8 |
| 50 | GEN-03404 | Notification preference screen and its reusable sheet wrapper | 5 |

**333 gates across 50 steps.** 48 steps Complete, RCGLA-012 Partial (2 deferred: zoom lock,
CLS), IS38-SGTIM-018 Partial (1 deferred: physical-device feel), SSTLA-004 awaiting a
reviewer score. Batch 4 added no deferrals.

### Surfaces and feedback

`HabotBottomSheet` is the only modal surface: it owns the 32% scrim, the 60% snap point and
the motion, so no flow re-decides them. `HabotMetadataDisclosure` is the only route by which
metadata reaches the screen. `HabotErrorSnackbar` is bound to the REF-197 error boundary, so
an exception can only reach a user after it has been classified into a plain-language
template and scrubbed. `HabotEmptyState` distinguishes "no results" from "could not load" --
telling a user there is nothing when the fetch failed is a lie the type system now prevents.

### Telemetry

`HabotHesitationTracker` attaches a focus listener to every `ValidatedInputField` in
`initState`, so listener coverage is structural rather than something each form remembers.
No event carries a field value -- the payload is field name, kind, timestamp and dwell.
`FrictionTracker` wraps a screen and turns those events into a friction report, including
the double-tap correction rate that TTMAC-014 (Step 14) was Partial for.

### The shell

`HabotShellPage` is the app root and owns the single `HabotMasterScaffold`. `HabotAppShell`
supplies the destinations, the offline banner and the restored deep-link context, and times
every destination switch against the 200ms interactive ceiling. `HabotSplitView` and
`HabotMasterDetail` take no width, ratio or breakpoint parameter -- they read the viewport and
consult the Step 36 blueprint, which is what stops "responsive" from meaning "each screen
decides for itself". Before Step 43 every screen in this codebase was reachable only from a
probe page.

### Forms

Every text input is a `ValidatedInputField` bound to a `HabotCde` (Critical Data Element). The
CDE carries its own mask, regex, keyboard type, placeholder and plain-language error message —
so a phone field cannot end up with a text keyboard, and an error message cannot be missing.
`HabotFormGate` is the single authority on whether a form may be submitted; four separate steps
in the sheet describe that rule and it is implemented once.

### Open decisions

1. **Brand palette** — `tokens.json` is `PROVISIONAL` pending Brand sign-off. All colours pass
   their accessibility gates; the hex values are placeholders.
2. **Zoom lock** — RCGLA-012 substep 2 asks for `user-scalable=no`, which fails WCAG 2.1
   SC 1.4.4 and is ignored by modern iOS/Android browsers anyway. Deferred; see the comment
   block in `udf_setup/web/index.html` for the one-line override.
3. **Physical-device feel** — IS38-SGTIM-018's completion measure asks for physical device
   testing of the overscroll stretch. The widget-level facts are gated; the feel needs a hand
   and a handset.

4. **Eleven mismatched columns in the source sheet** (batches 3 and 4). Four metric names name
   the wrong instrument, one Completion Measures cell is empty, and one row estimates a
   settings panel with database writes at "5 Minutes". None are gated; all are recorded in the
   gate file and the evidence. Worth correcting at source.
5. **Field readings for the latency budgets** (Steps 44, 50). Both are measured on the test
   host. A handset number needs a profile-mode run; the caveat is on the gates themselves.

Closed since Steps 1-20: the double-tap-correction telemetry TTMAC-014 was Partial for is
now built (Steps 34-35). The rate is computed from recorded interactions; the production
reading still needs a release.

See the [workspace README](../README.md) for team conventions.
