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
./tool/verify_aiss.sh          # format, analyze, poka-yoke guard, 944 AISS gates, evidence roll-up
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
| 51 | LSAV-025 | Chart geometry blueprint: locked ratios, derived strokes, no clipping | 9 |
| 52 | GEN-02654 | M3 KPI card at 360dp; category decides direction, unit and delta | 7 |
| 53 | LSAV-027 | Design-token adherence measured at 100% of 123 styled properties | 7 |
| 54 | GEN-00168 | KPI stacking delegated to the Step 45 rule, not restated | 4 |
| 55 | GEN-02929 | Confidence intervals in bodySmall; never a range without its CI | 6 |
| 56 | GEN-01330 | `@habot/charts/mobile-spend` boundary; accuracy 1.0000 over 324 checks | 7 |
| 57 | GEN-02026 | Round-number axis ticks; tap overlay, never a hover tooltip | 7 |
| 58 | GEN-03039 | SLI sparklines and drift against each indicator's own objective | 6 |
| 59 | SCTSS-019 | Expiry timelines; dates immutable by type, locks derived | 7 |
| 60 | SPRLC-011 | Leaderboard masking; rank from score alone, ties share a rank | 7 |
| 61 | GEN-04803 | M3 shimmer skeletons; layout shift measured at 0dp | 6 |
| 62 | GEN-02709 | Summary strip outside the scroll view, full height on frame one | 5 |
| 63 | GEN-01441 | Filter sheet -- IS `HabotBottomSheet`, proved by source scan | 5 |
| 64 | GEN-02984 | Filter chips: secondary container + unconditional trailing check | 6 |
| 65 | GEN-04880 | Tap a KPI card to filter; 100% over 200 driven triggers | 7 |
| 66 | GEN-00692 | Dispatch alert engine: 60s clock, Accept disabled the instant it is taken | 8 |
| 67 | GEN-04561 | Payload contract; a payload whose route does not resolve cannot be built | 5 |
| 68 | GEN-00699 | `onMessageReceived`: parse, dedupe, enqueue; urgent messages never evicted | 6 |
| 69 | GEN-04374 | In-app banner, one at a time by precedence, connectivity outranking all | 6 |
| 70 | PNSAD-026 | Floating snackbar placement measured at 100.00% on the rendered rect | 4 |
| 71 | HSFVS-012 | DCYN failures through the Step 25 snackbar; exactly one `SnackBar(` in lib/ | 5 |
| 72 | EDBAA-001 | Liveness-handshake toast; diagnostic logged, never rendered | 4 |
| 73 | FLADE-011-10 | Critical panel; `AbsorbPointer` makes un-ignorable structural | 5 |
| 74 | ARCPE-009-02 | Warning overlay; touch band IS the Step 10 token, asserted equal | 4 |
| 75 | GEN-02455 | Notification centre; retention decided by kind, unread never lost | 5 |
| 76 | PNSAD-021 | Delivery routing and the push-token registry; unresolvable targets dropped | 5 |
| 77 | GEN-03017 | One-tap approval: two taps, one send, one decision | 4 |
| 78 | HC-BOG-0018 | P1-P4 sorting; record cause required by type, older P1 sorts first | 4 |
| 79 | GEN-00335 | Pub/Sub violation binding; order kept, redelivery deduped, errors survived | 4 |
| 80 | PNSAD-010 | The preference join -- nothing reaches a surface without passing it | 5 |
| 81 | MCIIM-021 | Byt-level cropping; a task type with nowhere to put a document URL | 5 |
| 82 | MCIIM-009-09 | Crop constraints as a closed set; compliance 1.0 over the matrix | 4 |
| 83 | GEN-00213 | Bounding box to container: pure, grid-sourced, pane-bounded | 3 |
| 84 | GEN-00280 | Full 4-column width; 0 regressions over 18 viewports (fits, never clips) | 3 |
| 85 | MCIIM-008 | The evidence pane IS HabotSplitRatio.balanced; frame clips, no shadow | 4 |
| 86 | GEN-00112 | Readability suite: 18/18 pass, no panning required | 3 |
| 87 | SSELC-016 | One split container in lib/; the chassis configures it | 4 |
| 88 | GEN-00610 | Peripheral element count 0, counted on a real rendered task screen | 3 |
| 89 | GEN-04042 | Unwrapped task content is refused, recorded and shown as a notice | 3 |
| 90 | ERMWD-031-01 | DLQ payload to task or recorded defect; never a blank card | 4 |
| 91 | GEN-03580 | One crop, one input, one submit; focus efficiency 1.0 | 4 |
| 92 | GEN-02896 | Worker card = Step 29 chassis, elevated, Step 78 priority badge | 3 |
| 93 | GEN-03866 | Worked vs elapsed time; 0.000ms accumulation drift | 4 |
| 94 | GEN-00843 | 5-minute reclaim from tokens; ranking identical to Step 78's | 4 |
| 95 | GEN-03591 | 15-minute SLA, escalate exactly once, through the Step 73 panel | 4 |
| 96 | GEN-02621 | WCAG 2.2 AA audit engine; 12 criteria, findings that name the file | 6 |
| 97 | GEN-04242 | Accessibility rules as executable guards, run in the same pipeline | 6 |
| 98 | GEN-02775 | Findings, remediations and pipeline config generated from the audit | 6 |
| 99 | GEN-04572 | Consequence hints on complex controls; announced, not hovered | 6 |
| 100 | GEN-02764 | Alt text required, decorative marked; no raw Image under lib/ | 6 |
| 101 | GEN-01826 | Focus trap owns both sides; a dialog you cannot swipe out of is a defect | 6 |
| 102 | GEN-04363 | Text scaling to 200%, clamped once; 1 deferred (displayLarge at 320dp) | 7 |
| 103 | GEN-04462 | Type scale audited per role group; the two M3 twins recorded as sanctioned | 6 |
| 104 | GEN-02279 | Progressive disclosure; the summary is complete without expanding | 5 |
| 105 | GEN-00368 | High-contrast schemes at the AAA floor; every pair >= 9.91:1 | 6 |
| 106 | ETMDI-020-05 | Rollback error UI: what was undone, what to do, one way back | 6 |
| 107 | GEN-01352 | OS dynamic colour mapped through the audit, never applied raw | 6 |
| 108 | GEN-00090 | Tap accuracy over thumb zones; 12 misses of 108, all top corners | 6 |
| 109 | GEN-00179 | Recovery action placed in the natural-reach arc, measured | 6 |
| 110 | GEN-01793 | Keyboard type per field requirement; a phone field cannot get text | 6 |
| 111 | GEN-00146 | Disconnect, type, reconnect: the typed data survives all three | 6 |
| 112 | GEN-03327 | Repository interfaces; durable locally before the network is involved | 6 |
| 113 | GEN-04484 | DAOs with revisions and tombstones; a deletion is a record | 8 |
| 114 | GEN-04119 | SDUI layout JSON in encrypted local storage, keyed per install | 6 |
| 115 | GEN-04429 | Mutation wrappers; state updates immutable by type, not by convention | 7 |
| 116 | GEN-02093 | Atomic commit: a unit of work lands whole or not at all | 7 |
| 117 | GEN-02819 | Durable outbox with dedupe at enqueue, dead letters and revival | 7 |
| 118 | GEN-04064 | Delta application; stale deltas rejected, local work never overwritten | 6 |
| 119 | GEN-04418 | Lifecycle observer; every registered holder released on background | 6 |
| 120 | GEN-00247 | Stream paused on background; the clocks it feeds pause with it | 6 |
| 121 | GEN-02731 | Reconnect with full-jitter backoff; capped, and it never gives up | 6 |
| 122 | GEN-03635 | Idempotent dispatch by key; an unknown outcome is not a success | 7 |
| 123 | GEN-05276 | Sync sweep over a snapshot of the queue; five named stop reasons | 7 |
| 124 | GEN-05397 | Heavy sync pauses above 1000ms RTT; interactive calls preserved | 7 |
| 125 | GEN-03105 | Offline chip 28dp painted, 48dp hit area; honest about the queue | 7 |
| 126 | GEN-02256 | wss only, host allow-list, token required, subprotocol re-checked | 7 |
| 127 | GEN-04550 | Heartbeat with four liveness bands; a late pong is not a live socket | 7 |
| 128 | GEN-02599 | Socket lifecycle: foreground, grace, detached; no unbacked socket | 7 |
| 129 | GEN-02555 | Dashboard freshness stated qualitatively; a stale figure says so | 6 |
| 130 | GEN-04737 | Submit guard: 20 taps, 1 call; every lock unlocks, timeout included | 7 |
| 131 | GEN-00190 | Rate limit at 10/s in one shared bucket; the 300ms debounce is Step 33's | 7 |
| 132 | GEN-01496 | Favourites: add, remove, map-to-collection; the BigQuery half is the server's | 7 |
| 133 | GEN-05309 | The flag dispatcher specification, written as code so it cannot drift | 7 |
| 134 | GEN-04638 | Local feature flags, synchronous; every Step 133 criterion gated | 7 |
| 135 | GEN-02544 | Variation mapping; an unaudited variant cannot be registered | 7 |
| 136 | ANSA-012-A02 | Responsive-grid conformance measured; the header module is Step 9's | 6 |
| 137 | REF-377-A02 | One global stepper transition; the row's 0.3s example breaches a gate | 6 |
| 138 | GEN-04957 | Localisation objective reviewed: Urdu is RTL, Welsh runs 30% longer | 7 |
| 139 | GEN-03470 | Locale formatters, no intl; 22 golden cases, Polish comma and space | 7 |
| 140 | GEN-00379 | cac_aed_value as exact minor units; 2 shown, 4 stored, 6 the ceiling | 7 |
| 141 | GEN-00412 | calculate_aed_conversion(); a zero rate is refused, not applied | 6 |
| 142 | GEN-00621 | Currency mask on the active locale's separator, not on "." | 7 |
| 143 | GEN-04583 | Instant language switch; below 100% coverage a language is withheld | 7 |
| 144 | GEN-05430 | Language toggle as a header action; two labels rejected for expansion | 7 |
| 145 | GEN-04968 | Language telemetry through the outbox; install-scoped, never a person | 7 |
| 146 | GEN-04759 | Single-action objective reviewed; ViewPager -> PageView, RTL traced | 7 |
| 147 | GEN-02533 | Form splitter; one decision per step, compound blocks stay whole | 6 |
| 148 | GEN-02500 | One Byt, one field; errors caught where they were made | 6 |
| 149 | GEN-01087 | Next stays enabled and says why; back is never refused | 6 |
| 150 | GEN-01396 | Swipe intent resolved from direction; refusals are not silent | 6 |
| 151 | GEN-00269 | Focus traversal walked end to end; zero manual scrolls | 6 |
| 152 | GEN-01584 | Progress node centred, never under a finger, never when visible | 6 |
| 153 | GEN-02588 | Per-field autosave with revisions; a failed save keeps the value | 6 |
| 154 | GEN-04825 | FAB hides on keyboard, enforced by the new ROGUE_FAB guard rule | 6 |
| 155 | GEN-04506 | Success haptic, fired synchronously; four moments, five kept silent | 6 |

**944 gates across 155 steps.** 152 steps Complete, RCGLA-012 Partial (2 deferred: zoom lock,
CLS), IS38-SGTIM-018 Partial (1 deferred: physical-device feel), GEN-04363 Partial (1 deferred:
displayLarge at 200% on a 320dp screen), SSTLA-004 awaiting a reviewer score. Batches 4-10 added
one deferral between them.

### MTO worker screens

A worker sees a crop, never a document. `HabotByt` has no field, parameter or factory through
which a source-document URL could travel, and the only way to build one refuses any asset the
cropping service has not stamped for that exact bounding box -- so "the worker cannot see the
whole document under any circumstance" is a property of the type rather than a rule someone
follows. The task chassis has no header, footer or floating-action slot, so a task screen scores
zero peripheral elements by construction; content rendered outside it records a violation and
shows a notice instead of the task. The queue reclaims anything held longer than five minutes and
ranks with the same comparator the alert panel uses.

### Notifications and alerts

`HabotErrorSnackbar` is still the *only* `SnackBar` construction in `lib/` -- Steps 70-72 bind
three sheet rows to it rather than adding surfaces, and two gates fail if a second one ever
appears. The critical alert panel wraps the app body in an `AbsorbPointer`, so "un-ignorable"
is structural rather than promised, and there is no parameter through which a screen can opt
out. Every notification the shell presents passes `HabotNotificationPreferenceManager.admit`
first, which is what makes the Step 50 preference screen mean anything -- with two deliberate
exceptions, `critical` and `dispatch`, recorded in the source so the decision can be argued
with.

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

### The dashboard

Steps 51-65 gave the overview real content. KPI cards (`HabotKpiCard`) stack on the rule Step 45
already gated, charts come from one package boundary (`@habot/charts/mobile-spend`), skeletons
reserve the exact size their content will take so the data arriving moves nothing, and tapping a
KPI card applies its filter through `HabotDashboardController`. The filter sheet is
`HabotBottomSheet` -- not a second modal surface. `HabotWidgetTokenAudit` measures how much of
the layer's styling came from a token and names anything that did not: currently **100% of 123
styled properties**.

### Forms

Every text input is a `ValidatedInputField` bound to a `HabotCde` (Critical Data Element). The
CDE carries its own mask, regex, keyboard type, placeholder and plain-language error message —
so a phone field cannot end up with a text keyboard, and an error message cannot be missing.
`HabotFormGate` is the single authority on whether a form may be submitted; four separate steps
in the sheet describe that rule and it is implemented once.

### Accessibility

Steps 96-105 turned WCAG 2.2 AA from a review into a build step. `HabotWcagAudit` evaluates
twelve criteria and names the file behind every finding, and the criteria that can be checked
statically are also poka-yoke guards, so an unnamed `IconButton`, a raw `Image`, a suppressed
`TextScaler` or a literal touch size fails the build rather than a later audit. Text scaling is
applied once, by `HabotTextScaleScope`, and clamped to the audited range; the one case that
genuinely fails at 200% -- `displayLarge` on a 320dp screen -- is recorded as a deferred gate
rather than hidden by narrowing the audit.

### Offline, sockets and flags

Steps 111-135 are one layer read end to end: a repository writes locally before the network is
involved, a durable outbox dedupes at enqueue and keeps dead letters, an idempotent dispatcher
makes a retry after a reconnect harmless, and a sync loop drains a snapshot of the queue with a
named reason for every stop. Above 1000ms round-trip the governor pauses heavy background sync
and lets interactive calls through; the whole client stays under ten requests a second from one
shared bucket, so a sweep and a tap draw on the same budget. Sockets are `wss` only against an
exact host allow-list, heartbeat treats a late pong as a dead socket rather than a live one, and
backgrounding moves through an explicit grace phase -- there is no code path that holds a socket
with nothing behind it. Feature flags evaluate synchronously from memory, because a flag awaited
inside `build()` is a layout that shifts under a finger already moving; the specification for
them is code, and every acceptance criterion in it is checked against the implementation by a
gate, so the two cannot drift.

### Localisation

Steps 138-145 build the framework and the English catalogue; the Welsh, Urdu, Punjabi and
Polish catalogues are a translation deliverable and are deliberately not invented in code. A
language below 100% coverage is not offered at all -- the sheet permits 95%, and one English
sentence in the middle of Welsh reads as a broken app rather than as 95% of a good one, while
per-string fallback would hide the gap from the coverage metric itself. Direction travels with
the language, so selecting Urdu mirrors the layout rather than only swapping strings.
Formatting is separate from translation and just as easy to get wrong: Polish writes
`12 345,50` where English writes `12,345.50`, and the amount field accepts whichever separator
the active language uses. Money is exact throughout -- an integer of minor units with a declared
scale, four places stored and two shown.

The expansion audit at Step 144 rejected two source strings before they shipped: "Notification
preferences" overflows the 28-character header cap in Welsh and Polish and now reads
"Notifications", and "Save and continue" wraps in every offered language against a
12-character button budget.

### The single-question form flow

Steps 146-155 turn a long form into one question per screen. Fields declared as one decision at
Step 44 stay together -- an address is four fields and one decision, and four screens for it is
worse than the page it replaced. The forward control stays enabled and refuses with a reason
rather than greying out, because a disabled button explains nothing and some screen readers skip
it entirely; back is never refused, so nobody is trapped on a step they cannot satisfy. Swipe
direction is resolved from the writing direction in one method, which is what stops the wizard
advancing backwards in Urdu. Every field saves when it settles, locally first and queued second,
carrying a revision so a correction beats the typo it replaced -- and a failed save keeps the
value rather than clearing a dirty flag over an answer that then exists nowhere.

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
5. **Field readings for the latency budgets** (Steps 44, 50, 62, 63). All are measured on the
   test host. A handset number needs a profile-mode run; the caveat is on the gates themselves.
6. **A Lighthouse run for CLS** (RCGLA-012). Step 61 builds what prevents layout shift and
   measures it at 0dp app-side, but the browser-reported figure still needs a real page load.

Closed since Steps 1-20: the double-tap-correction telemetry TTMAC-014 was Partial for is
now built (Steps 34-35). The rate is computed from recorded interactions; the production
reading still needs a release.

See the [workspace README](../README.md) for team conventions.
