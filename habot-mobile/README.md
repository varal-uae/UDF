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
./tool/verify_aiss.sh          # format, analyze, poka-yoke guard, 4,001 AISS gates, evidence roll-up
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
| 156 | GEN-03448 | The event envelope as a type; event_date and trace_id cannot be absent | 8 |
| 157 | GEN-00809 | Every redaction rule carries a value it must catch and one it must not | 8 |
| 158 | GEN-01738 | Fingerprints from frame symbols; the scrubbed-trace version collides | 8 |
| 159 | GEN-01054 | Crash-free rate counts sessions; a network timeout is not a crash | 8 |
| 160 | GEN-04649 | Abandonment inferred at the two moments the app learns about it | 7 |
| 161 | GEN-04770 | 25 events per outbox entry; drop-off rates are a server query | 8 |
| 162 | GEN-01021 | Four declared probes with reasons; healthy results stream too | 7 |
| 163 | GEN-01076 | Abandonment joined to the last field that rejected the user | 8 |
| 164 | GEN-04253 | RAIL's 100ms is for input; cold start has its own budget. p95, not mean | 7 |
| 165 | GEN-03171 | Reports 0.625, below its own floor: three checks need a handset | 10 |
| 166 | GEN-04539 | Foreground for the whole window; the naive filter scores 0.4 | 7 |
| 167 | GEN-00754 | 60fps is 16.667ms; a frame budget is a complexity claim | 6 |
| 168 | GEN-01065 | "Block" means refuse, not wrap; two columns at 360dp is 156dp each | 6 |
| 169 | GEN-00888 | Three keys read, four forbidden; nothing throws on a hostile payload | 7 |
| 170 | GEN-00522 | Web equivalent, then ancestor section, then the landing page | 7 |
| 171 | GEN-01010 | Parked before the auth flow, not after; all-or-nothing restoration | 8 |
| 172 | GEN-01187 | A directional threshold on an exact amount, through the Step 50 gate | 8 |
| 173 | GEN-00134 | The client half of the spec, so the two can be joined | 8 |
| 174 | GEN-00291 | Two roles holding one hex -- the defect nothing else here catches | 8 |
| 175 | GEN-01132 | Known catalogue terms in clear; the user's own words as a hash | 8 |
| 176 | GEN-03182 | The token package manifest; what it costs at first frame, not `npm init` | 5 |
| 177 | GEN-00033 | Canonical MD3 names for every token; brand extensions declared | 7 |
| 178 | GEN-04528 | Declared equals delivered -- the drift no existing check looks at | 6 |
| 179 | GEN-03514 | The rule catalogue as data, deliberately without the patterns | 7 |
| 180 | GEN-03602 | Already active since Step 4; now measurable, with an exemption budget | 7 |
| 181 | GEN-04275 | **Fail.** Five of eight; the palette, the type face and NPM block it | 10 |
| 182 | GEN-00599 | **Not Complete.** Inter is not vendored; renaming would be a regression | 8 |
| 183 | GEN-01661 | 96.97% on the 4dp grid, and the 6dp offender is named | 7 |
| 184 | GEN-01043 | The ceiling nobody enforced, on the short side only | 7 |
| 185 | GEN-01683 | Separation is a pair; the denominator is adjacency | 7 |
| 186 | GEN-02753 | Material You admitted only if it clears the same contrast bar | 7 |
| 187 | GEN-02852 | **Partial.** Durations port; the emphasised curve does not | 7 |
| 188 | GEN-03899 | "The left button" is a direction, not a side | 7 |
| 189 | GEN-04715 | Instant on entry, eased on exit; colour is never the only carrier | 7 |
| 190 | GEN-04913 | MD3 has no success role; never painted over an uncommitted write | 7 |
| 191 | GEN-05111 | A rung, not a colour -- and the nav-label pair nothing audited | 7 |
| 192 | GEN-03503 | Three bottoms; the bar rises with the keyboard where the FAB hides | 7 |
| 193 | GEN-04814 | Bottom-trailing, not bottom-right; handedness stated, not solved | 7 |
| 194 | GEN-04726 | A global isLoading is the defect; counted scope, no flash | 7 |
| 195 | GEN-02885 | Deciding what earns a modal; one at a time, never a bare OK | 7 |
| 196 | GEN-01110 | FRE_Completed cannot produce the rate its own row asks for | 7 |
| 197 | GEN-01419 | Suppression keyed on the account, because the flag cannot see them | 7 |
| 198 | GEN-01121 | A card is a surface, not a target; the exemption is written down | 7 |
| 199 | GEN-01430 | MD3 answers a press with a state layer, not a shadow under a finger | 7 |
| 200 | GEN-01165 | Nineteen characters against a twelve-character budget | 7 |
| 201 | GEN-01198 | A face and a tick, graded on whether the allergy field is filled | 7 |
| 202 | GEN-01507 | One tap adds and removes; the payload is derived, never accumulated | 7 |
| 203 | GEN-01209 | A cap of three over seven elects three winners | 7 |
| 204 | GEN-01518 | 50ms rules out the network; AED 4.35 is 434 fils in a double | 7 |
| 205 | GEN-01220 | Collapsed is the requirement; latched open by what it holds | 7 |
| 206 | GEN-01529 | Shape checked locally, meaning never; Apply fires once | 7 |
| 207 | GEN-01242 | The app is never in a position to hold a card number | 7 |
| 208 | GEN-01551 | The brand comes from the field, not from reading digits | 7 |
| 209 | GEN-01573 | A static pass survives a screenshot; the quiet zone is the symbol | 7 |
| 210 | GEN-01606 | An incomplete export looks complete; coverage on the document | 7 |
| 211 | GEN-01231 | Decisions are measurable; an instant re-book did not check | 7 |
| 212 | GEN-01253 | Binary is the shape that manufactures false positives | 7 |
| 213 | GEN-01562 | A pre-selected drop-down is not mandatory | 7 |
| 214 | GEN-01308 | Cycle time is not ours; intake completeness is | 7 |
| 215 | GEN-01617 | Packaging buys agreement, not reuse -- and carries no case data | 7 |
| 216 | GEN-01694 | Four declaration sites, two enums, and a 600/744 boundary conflict | 8 |
| 217 | GEN-01672 | A source-only linter reaches 75 where a constraint-aware one reaches 100 | 7 |
| 218 | GEN-04748 | The ratio belongs to the relation, not to the caller | 7 |
| 219 | GEN-04187 | **Partial.** Two codebases in scope; one of them cannot be inspected | 8 |
| 220 | AWCV-015 | Fifteen cells; the tightest leaves 10dp of margin | 7 |
| 221 | DLQDP-029-11 | A system split collapses the supporting pane the row asks for | 7 |
| 222 | ARCPE-016-14 | Five of six phones cannot stack two panes with a keyboard open | 7 |
| 223 | GEN-01771 | **Not Complete.** A portrait lock would fail WCAG 1.3.4 | 8 |
| 224 | CFCST-014 | A width-only conversion makes a blocking decision swipeable | 7 |
| 225 | GEN-04297 | The band was already declared; the ceiling is the right bound | 7 |
| 226 | GEN-02356 | The sheet's band units are a defect; four snackbars are well formed | 7 |
| 227 | GEN-04286 | Three rows, three ceilings, and a WCAG citation that is wrong | 7 |
| 228 | GEN-03259 | 320/5 = 64dp, so geometry allows six and MD3 caps it at five | 7 |
| 229 | GEN-04164 | A token resolving to 24dp passes the rule that reads literals | 7 |
| 230 | GEN-05144 | Half of open decision 2 closes: responsiveness without the lock | 7 |
| 231 | GEN-01970 | "Only visible" is false by design; 6 of 12 built and not visible | 7 |
| 232 | GEN-01760 | Nodes are not where the memory goes -- a factor of 406 is | 7 |
| 233 | GEN-03338 | No worklets, and 16,667us was a 60Hz figure nobody wrote down | 7 |
| 234 | GEN-04108 | The crash reporter is the one thing that must not be deferred | 7 |
| 235 | GEN-05441 | **Partial.** Two of three budgets have been in force since Step 165 | 7 |
| 236 | GEN-00066 | Thirteen field rules and no compliance fields | 7 |
| 237 | USMBL-013 | Three of the five modes already existed under other names | 7 |
| 238 | GEN-02290 | **Fail.** Three fields have a mask that eats their own separator | 7 |
| 239 | GEN-02185 | A formatter may move separators and never digits | 7 |
| 240 | GEN-04009 | Every field is bound; two of five rule kinds are regexes | 7 |
| 241 | GEN-03558 | **Fail.** Standardising on a broken component | 7 |
| 242 | GEN-01947 | The logic is already stored; a manifest, not a copy | 7 |
| 243 | GEN-03393 | Structure gets 5 of 10; only mod-97 gets all ten | 7 |
| 244 | GEN-03281 | A form is not an identifier, and this is not a US app | 7 |
| 245 | GEN-03360 | A space is populated; seven of eight vectors prove it | 7 |
| 246 | GEN-04020 | Three DOM names, three mechanisms, four moments | 7 |
| 247 | FLADE-006-03 | Counts, never captures; refused on three of six fields | 7 |
| 248 | HC-CMP-0054 | **Partial.** The disrupted sort order is refused outright | 7 |
| 249 | GEN-05298 | **Partial.** Coverage needs a toolchain this host lacks | 7 |
| 250 | GEN-02071 | **Low.** A suggestion the field prevents you from following | 7 |
| 251 | PELCE-039-11 | On a timeout the client does not know if it went through | 7 |
| 252 | GEN-03569 | A double refuses a correct split of seventy fils | 7 |
| 253 | GEN-02117 | "Impenetrable client-side" is refused; OWASP says so | 7 |
| 254 | GEN-01992 | Strict True as a sealed result with no third case | 7 |
| 255 | IRBCA-034-09 | Which updates may be optimistic, and which may not | 7 |
| 256 | GEN-03877 | Twelve rows for thirty-two directories; the metric times a person | 7 |
| 257 | GEN-03965 | There is no lib/screens, because this application has panes | 7 |
| 258 | GEN-03921 | AppRouter.tsx is the fifth row written for another stack | 7 |
| 259 | GEN-04473 | A custom scheme is unverified, so it is the fallback | 7 |
| 260 | GEN-05386 | The named API covers one of three targets; type is not quality | 8 |
| 261 | GEN-04495 | A grant rate measures people; two routes need no camera | 7 |
| 262 | GEN-04308 | An extension is a claim -- 1.0 by bytes against 0.875 by name | 8 |
| 263 | GEN-00988 | **Fail**: zero bundled assets, and a ratio with no direction | 8 |
| 264 | HAZFE-020-09 | A frame secures nothing; the snapshot and the cache do | 8 |
| 265 | MCIIM-010-10 | One figure per document hides which three fields are wrong | 8 |
| 266 | GEN-04627 | "All" scores 75% and the census scores 100% | 8 |
| 267 | GEN-04594 | Masking for display leaves four other copies | 8 |
| 268 | GEN-01595 | **Poor**: 3 of 11 intercepted, 2 of those by accident | 9 |
| 269 | GEN-00820 | No field type can hold free text, so the zero is structural | 9 |
| 270 | GEN-04902 | **Partial**: withdrawal and deletion of the record are opposites | 8 |
| 271 | GEN-02808 | **Fail**: no cipher ships, so the badge's honest state is failed | 10 |
| 272 | GEN-03536 | The detector and the thing detected share an address space | 9 |
| 273 | TSIP-023 | Six subjects on one row; 30s is fifteen client budgets | 10 |
| 274 | GEN-04517 | "No clean exit" is three events wearing one face | 10 |
| 275 | GEN-02698 | axe-core cannot walk a widget tree; 3 errors is not evidence | 10 |
| 276 | ARCPE-004-05 | Two handlers that are one gesture; the band mis-names both WCAG levels | 8 |
| 277 | ARCPE-004-08 | A height cap is a nested scroller, and it hides from short tests | 9 |
| 278 | DSDD-003-14 | Collapsing the mistakes hides them from everyone but the worried | 8 |
| 279 | GEN-03006 | "Drawer" would have spent the gesture Step 226 gave to back | 9 |
| 280 | ERMWD-029-07 | A focus trap is not a touch construct; both are needed | 9 |
| 281 | HSFVS-011-15 | A hard stop is in neither vocabulary -- as Step 272 found | 8 |
| 282 | EDEBS-019-13 | "Action Failed" passes every check and says nothing | 8 |
| 283 | GEN-00854 | Two rows, one metric, bands 10x and 25x apart | 8 |
| 284 | RRCVG-002 | An HTML tag, a touch metric on something nobody presses | 8 |
| 285 | BDAE-003 | A gap is the way out of the size rule, not a second rule | 9 |
| 286 | HSCPE-019 | The floor is "no token system", so the band cannot fail | 9 |
| 287 | CBSV-004-13 | Two hex literals the guard would refuse; seven emirates | 9 |
| 288 | IS05-CSIVW-026-AS01 | The first row in nine batches whose metric fits its action | 9 |
| 289 | ETMDI-016-11 | Stripping without a destination is deleting; one has none | 8 |
| 290 | GEN-00101 | Dwell and hesitation are different; the limits span 45x | 8 |
| 291 | PELCE-029-16 | The row already contains the antidote to the next one | 8 |
| 292 | PELCE-029-17 | "Permanently" refused; the floor forbids what the rule allows | 9 |
| 293 | PCDE-019 | The remedy and the repeat, two lines apart in one row | 9 |
| 294 | BLGTA-033 | Disabled is a hint; "unverified" is three states | 9 |
| 295 | LSAV-002 | "Interface permissions" is a contradiction; read-only is three | 10 |
| 296 | ETMDI-021-12 | Shown on every route, four of six indicators flash | 10 |
| 297 | CRSSS-004-18 | The Setup Step caps text scaling below SC 1.4.4, silently | 10 |
| 298 | ACRAE-032-15 | Three obligations, one metric -- and two of the three are one | 10 |
| 299 | CRSSS-007-16 | The splash is drawn before the engine starts; the row depends on itself | 11 |
| 300 | BTPM-025-13 | "Continuous" is 240x the SC 2.2.2 threshold -- a Level A failure | 10 |
| 301 | GEN-04946 | A slider on the amount field moves AED 304.88 per point | 10 |
| 302 | GEN-03910 | The optimal is one microsecond; two empty strings survive trim | 10 |
| 303 | VPVMP-004-01 | Splitting the sentence is the defect; 11 of 16 forms have nowhere to go | 10 |
| 304 | GEN-02049 | Full success makes the metric undefined | 10 |
| 305 | DLQDP-015-11 | A rate per thousand over twelve things | 10 |
| 306 | ERMWD-025-15 | One error hue asked to carry three severities | 10 |
| 307 | GEN-02444 | Nine file types, four silhouettes, three units in one band | 10 |
| 308 | GEN-01098 | Stricter than ISO 9186, and unmeasurable from code | 11 |
| 309 | BLGTA-002-10 | 300 interruptions or 3, from one decision about when to look | 10 |
| 310 | HSCPE-006 | Step 286's instruction and Step 286's band, verbatim | 10 |
| 311 | ACRAE-032-14 | A list keeps 11 of 13 relations and says which two it drops | 10 |
| 312 | RTSET-033 | The ceiling is below the optimal | 10 |
| 313 | GEN-01374 | The verification has run for 84 steps; the limits had not been written | 10 |
| 314 | GEN-04979 | A screen-reader fallback list is the defect, not the fix | 10 |
| 315 | RTVMA-016 | A metric named for the one ratio at which nothing is visible | 11 |
| 316 | GEN-00445 | Null, Error and False are three facts; two of them are ours | 10 |
| 317 | ERMWD-029-03 | Five refusal states, five designs, and no state without one | 10 |
| 318 | AWCV-007-08 | The sum of the parts is not the total, in doubles | 10 |
| 319 | ONCS-002 | Twenty-one denies, so the emphasis goes to the three allows | 10 |
| 320 | GEN-03028 | Step 292's missing remedy: a way out of a greyed control | 10 |
| 321 | GEN-03426 | A 25m accuracy radius straddling a 50m fence | 10 |
| 322 | GEN-03459 | Who did this, and on whose behalf, from the record itself | 10 |
| 323 | GEN-04330 | The best-formed ceiling in the track, aimed at the wrong subject | 10 |
| 324 | MUFCE-026-A01 | The extension is right four times in six; the bytes, six | 10 |
| 325 | CCPME-016 | An inverted band, under Step 315's narrative verbatim | 10 |
| 326 | GEN-03712 | The step-up names two people; dispatch is 0.208% of the wait | 10 |
| 327 | GEN-00077 | Reports **Fail**: six of eight criteria against a 95% floor | 10 |
| 328 | GEN-05188 | Four of eight evasion forms caught, against a 90% floor | 10 |
| 329 | GEN-03050 | HIPAA in a UAE app, and a gateway that sees one exit of three | 10 |
| 330 | GEN-00123 | The floor and the ceiling are the same number, twice named | 10 |
| 331 | GEN-00224 | "Real-time" on a surface the same row polls every 30 seconds | 10 |
| 332 | HSFVS-013-17 | The ceiling is the optimal with an inequality in front of it | 10 |
| 333 | GEN-01981 | 483 events become 12 triples become 5 alerts | 10 |
| 334 | GEN-03481 | An open circuit answers three and a half seconds sooner | 10 |
| 335 | GEN-03237 | Ten crashes is a floor on one day and ten times a ceiling on another | 10 |
| 336 | CBSV-006-15 | Three routes to one function; the row names only the path | 10 |
| 337 | SGTIM-015 | An incident-response metric on a 200ms finger movement | 10 |
| 338 | GEN-04858 | The row's own requirement fails the row's own floor | 10 |
| 339 | GEN-02863 | Friction that keeps its Level A alternative | 10 |
| 340 | GEN-05012 | Drag-to-reorder is SC 2.5.7's own worked example | 10 |
| 341 | GEN-05023 | A row that says poka-yoke and earns it | 10 |
| 342 | MCIIM-014-11 | "48dp (44px)" is two standards, not one conversion | 10 |
| 343 | CBSV-005-14 | The gap between targets, after nine rows about size | 10 |
| 344 | VPVMP-015 | Nine control classes, seven proven; the guard runs | 10 |
| 345 | MTVPE-018 | A ring that is not the focus indicator | 10 |
| 346 | MTVPE-004 | CSS transitions in an application with no CSS | 10 |
| 347 | MTVPE-020 | The cell that reports the generator's own miss | 10 |
| 348 | GEN-04660 | A hover construct on a touch surface, in three units | 10 |
| 349 | GEN-05342 | Reports **Fail**: two of three criteria never observed | 10 |
| 350 | GEN-01815 | Six promises, five of them invisible to review | 10 |
| 351 | GEN-03215 | Both of the previous batch's defects, on one row | 10 |
| 352 | GEN-02511 | Five locales, five confirmation words | 10 |
| 353 | GEN-04031 | A band of 1/1/1 on a measure with a distribution | 10 |
| 354 | EDEBS-013-11 | A stepper promises a denominator; a bar cannot | 10 |
| 355 | EDEBS-019-12 | "N/A (Backend database setup)", four times, on a UI row | 10 |
| 356 | GEN-00932 | Four sources say "verified"; one of them is a bank | 10 |
| 357 | GEN-02301 | Reports **Fail**: four meanings of "Verified", three held | 10 |
| 358 | GEN-01407 | A ratio with no denominator, on the sixth copy of one band | 10 |
| 359 | ACRAE-004 | The two ratings the control exists for score highest | 10 |
| 360 | GEN-02466 | "Swept" is a verb: examined, quarantined, removed | 10 |
| 361 | GEN-01540 | A forecast and a count, rendered as the same kind of fact | 10 |
| 362 | GEN-01143 | A search log is a record of people; anonymity floor 10 | 10 |
| 363 | OPMV-006 | A cap nobody can see is a wrong answer that renders fast | 10 |
| 364 | FLADE-016-10 | The fifteenth foreign stack, and four properties lost | 10 |
| 365 | GEN-00876 | The second LaTeX-typeset band in one batch | 10 |
| 366 | EDEBS-011-09 | A finger is 12.5 times a cursor and sits on the target | 10 |
| 367 | OFBSE-013-04 | Boundary cells holding two measures each | 10 |
| 368 | GEN-02411 | A ceiling inside its own optimal; a lock on no door | 10 |
| 369 | HC-SCH-0179 | The generator-miss cell, for the second time | 10 |
| 370 | SIDM-016 | Ceiling 0.98 below an optimal of 1 -- the second such band | 10 |
| 371 | HSCPE-009 | An ordinal is an address, not an identity | 10 |
| 372 | GEN-02478 | One tap, and the four decisions it makes on your behalf | 10 |
| 373 | GEN-02577 | "Instantly", on a screen nobody is looking at | 10 |
| 374 | GEN-01628 | A widget that names its warehouse holds its credentials | 10 |
| 375 | GEN-01319 | A package name is a dependency direction | 10 |
| 376 | REF-106 | Hidden and disabled are different answers | 10 |
| 377 | GEN-02014 | "Automatically" is the whole of the step | 10 |
| 378 | GEN-01892 | Segments or switches: an "or" between different questions | 10 |
| 379 | GEN-04385 | Sixteen inline states become six named branches | 10 |
| 380 | GEN-02665 | Step 368's instruction again, twelve rows later | 10 |
| 381 | GEN-03072 | "Detected" is an inference, and the lock is for somebody else | 10 |
| 382 | GEN-03061 | The release button Step 292 already disabled | 10 |
| 383 | GEN-03204 | A disabled clock-in with no route through is an unpaid hour | 10 |
| 384 | GEN-04781 | Three strikes the platform already counts | 10 |
| 385 | GEN-02422 | An acceptance is evidence about a moment | 10 |
| 386 | GEN-02378 | A blocked Next button is the worst place for a requirement | 10 |
| 387 | GEN-01727 | "Localized" is the load-bearing word | 10 |
| 388 | ARCPE-013-12 | Three columns, three subjects, and the fields are the design | 10 |
| 389 | PELCE-036-13 | A freeze on a rate the row never names | 10 |
| 390 | BCDLD-022 | Two features in one row; the asymmetry is in a parenthesis | 10 |
| 391 | GEN-04097 | The only row that tests a refusal instead of building one | 10 |
| 392 | GEN-02115 | The answer is not to have the error | 10 |
| 393 | GEN-04440 | An empty box is worse than a crash | 10 |
| 394 | GEN-01782 | Step 194's counter-example, requested as a feature | 10 |
| 395 | GEN-03226 | Collapsed at one end, inverted at the other | 10 |
| 396 | ETMDI-016-02 | An audit tool that does not exist, counting something the row does not define | 10 |
| 397 | ETMDI-016-07 | Three words for one rule, doing three different jobs | 10 |
| 398 | ETMDI-003 | Three subjects in one row, and five cells from a TLS row | 10 |
| 399 | BTPM-032-05 | An access question joined to a content question | 10 |
| 400 | TECH-ENG-040 | A band written in sentences, and one of them describes failure | 10 |
| 401 | FEBFL-027-03 | A layout grammar that is useful for what it refuses | 10 |
| 402 | CBSV-036-03 | Two identical strings, kept apart on purpose | 10 |
| 403 | FEBFL-027-08 | A mapping table exactly as wide as the schema | 10 |
| 404 | GEN-01749 | The row calls it an AST; it is a parse tree | 10 |
| 405 | FEBFL-027-12 | A route surrenders its body and keeps its guards | 10 |
| 406 | DLQDP-024-08 | "Use score as a quality gate" -- which score? | 10 |
| 407 | ETMDI-008-10 | Show the working, and refuse colour as the only carrier | 10 |
| 408 | GEN-02037 | "All components" -- and the two that must not snap | 10 |
| 409 | GEN-00044 | A CSS linter for an application with no CSS | 10 |
| 410 | GEN-03193 | The same instruction as the previous row | 10 |
| 411 | GEN-04220 | A band whose floor and ceiling both read "N/A" | 10 |
| 412 | GEN-01837 | The twenty-line limit Step 296 already set | 10 |
| 413 | GEN-04407 | Type safety, scored on how long the build takes | 10 |
| 414 | GEN-04605 | Coverage as a fraction where the track uses percentages | 10 |
| 415 | GEN-03943 | Import View and Text from React Native, in Flutter | 10 |
| 416 | FEBFL-016-A01 | A review of guidelines for a framework that was never written | 10 |
| 417 | UFHT-019 | No metric name at all, and an output column written backwards | 10 |
| 418 | GEN-03127 | Where the band pattern becomes legible | 10 |
| 419 | GEN-02199 | "The tracking SDK" -- which one is never said | 10 |
| 420 | BLGTA-017-06 | A device ID the platforms will not give you | 10 |
| 421 | GEN-03954 | An average over a distribution that has no useful average | 10 |
| 422 | UFHT-025-12 | The touch-target band, for the third time | 10 |
| 423 | SIDM-017 | A delta against targets that are never stated | 10 |
| 424 | GEN-02244 | What makes a bottleneck hidden is that nobody looks | 10 |
| 425 | GEN-04130 | Red, where red already means something else | 10 |
| 426 | GEN-02907 | The same mark, for a reader who can act today | 10 |
| 427 | GEN-02786 | A test written to an architecture nobody built | 10 |
| 428 | GEN-03304 | Likes and comments in a shift-management application | 10 |
| 429 | RTSET-013 | Channels per scope rather than per card | 10 |
| 430 | GEN-04869 | A socket and a warehouse, only one of which is live | 10 |
| 431 | GEN-04086 | A reference standard that is the row’s own floor | 10 |
| 432 | GEN-01286 | An instruction that contradicts its own band | 10 |
| 433 | GEN-04352 | Four delivery states where a message has five | 10 |
| 434 | GEN-04075 | A fast 202 measures a queue, not the work | 10 |
| 435 | GEN-02003 | "Guarantee" under a floor of 99.5 | 10 |
| 436 | GEN-02127 | What "complete" means, and a charter for scoring people | 10 |
| 437 | GEN-00721 | The client receives a level-up; it does not decide one | 10 |
| 438 | GEN-02104 | The accounting metric finally fits: points are a ledger | 10 |
| 439 | GEN-05221 | A level, not a "performance tier" | 10 |
| 440 | GEN-02489 | The first zero floor, and only the person's own card recoloured | 10 |
| 441 | GEN-02687 | A scorecard contract where every figure carries its working | 10 |
| 442 | GEN-05232 | Thanks is worth zero points, and publication is the person's choice | 10 |
| 443 | GEN-05243 | The first true ceiling: Goodhart's law in a cell | 10 |
| 444 | GEN-03248 | A slider that behaves like five labelled choices | 10 |
| 445 | GEN-02161 | NPS measures the respondents, not the form | 10 |
| 446 | GEN-05122 | The longest band cell in the track is a template | 10 |
| 447 | GEN-05133 | A lost comparison sign decides the result | 10 |
| 448 | GEN-05254 | Factor notes before scores | 10 |
| 449 | GEN-05265 | Distribution reported, never enforced | 10 |
| 450 | GEN-05331 | Rules before questions | 10 |
| 451 | GEN-01936 | The row that judges the video, not the worker | 10 |
| 452 | GEN-02172 | Functional escalation before hierarchical | 10 |
| 453 | GEN-05364 | Documented, not confirmed, so Partial | 10 |
| 454 | GEN-05375 | Claimed savings are not savings | 10 |
| 455 | GEN-03415 | A projection that tells you what you will lose | 10 |
| 456 | GEN-04704 | A floor and a ceiling that are one number | 10 |
| 457 | GEN-04792 | Verified is not signed | 10 |
| 458 | GEN-04836 | "All four substeps above", on a flat sheet | 10 |
| 459 | GEN-04847 | 95 per cent, and no exceptions | 10 |
| 460 | GEN-04891 | A module named twice | 10 |
| 461 | GEN-04924 | One comma, two records | 10 |
| 462 | GEN-04935 | The lost comparison sign, confirmed | 10 |
| 463 | GEN-04990 | A row that asked for its own fallback | 10 |
| 464 | GEN-05001 | An instruction that fails its own metric | 10 |
| 465 | GEN-05034 | Step 458 again, character for character | 10 |
| 466 | GEN-05045 | One digit, and two stamped columns | 10 |
| 467 | GEN-05056 | A band that claims to match, at three times the number | 10 |
| 468 | GEN-05067 | A norm is a range, not a pass mark | 10 |
| 469 | GEN-05078 | Every point opens the document it came from | 10 |
| 470 | GEN-05089 | A version number inside a child's record | 10 |
| 471 | GEN-05100 | What each role sees first | 10 |
| 472 | GEN-05155 | A place, not a position | 10 |
| 473 | GEN-05166 | "Real-time" given a number | 10 |
| 474 | GEN-05199 | A 95 per cent floor on a safeguarding check | 10 |
| 475 | GEN-05210 | Three instructions, two measures | 10 |
| 476 | GEN-04616 | A ceiling that is one vulnerability | 10 |
| 477 | GEN-04671 | Three bare decimals, and a number about people | 10 |
| 478 | GEN-04693 | The same three packaging defects, a third time | 10 |
| 479 | RRCVG-045-A08 | Three subjects in three columns of one row | 10 |
| 480 | BPTR-0176-A14 | A cell that admits nothing matched | 10 |
| 481 | GEN-01032 | Floor, optimal and ceiling are the same word | 10 |
| 482 | RCGLA-016-A20 | The first strictly nested band in the track | 10 |
| 483 | DRVUT-010-A18 | A floor fifty releases wide | 10 |
| 484 | GEN-05320 | Instantly, for the thing that can be known instantly | 10 |
| 485 | GEN-00478 | A band holding its own alert condition | 10 |
| 486 | GEN-00687 | A ceiling slower than its floor, and a measure with two names | 10 |
| 487 | GEN-00921 | Fifteen per cent of forty-seven people | 10 |
| 488 | GEN-05452 | Paint time and contrast in one cell | 10 |
| 489 | RCGLA-018-A20 | Signal in the wrong column | 10 |
| 490 | GEN-00943 | A question, and a statement about people | 10 |
| 491 | GEN-05353 | A sixth noun for one idea | 10 |
| 492 | GEN-05408 | A heatmap that at street zoom is a list of addresses | 10 |
| 493 | GEN-04682 | One quantity written two ways | 10 |
| 494 | GEN-05287 | Two ordinals, and a band in the singular | 10 |
| 495 | GEN-05419 | Step 475 again, and a ledger that reopens | 10 |

**4,001 gates across 495 steps.** Every step reports Complete except the following, each of
which is the measurement the row asked for reported as it came out. RCGLA-012 Partial (2 deferred: zoom lock,
CLS), IS38-SGTIM-018 Partial (1 deferred: physical-device feel), GEN-04363 Partial (1 deferred:
displayLarge at 200% on a 320dp screen), GEN-03171 Partial (3 deferred: cold start on a handset),
GEN-00291 Partial (the palette is provisional), GEN-02852 Partial (no SwiftUI target),
GEN-00599 **Not Complete** (Inter is not vendored), GEN-04275 **Fail** (the tokenisation
milestone, deliberately -- see Open decisions), GEN-01242 Partial (1 deferred: the log scrubber
has no PAN rule), GEN-04187 Partial (habot-web cannot be inspected from here), GEN-01771
**Not Complete** (a portrait lock would fail WCAG 1.3.4), GEN-05441 Partial (no owner sign-off
is obtainable from a build host), GEN-02290 **Fail** and GEN-03558 **Fail** and GEN-02071 **Low**
(one defect, three metrics -- see below; a correction is built and not yet wired in), HC-CMP-0054
Partial (two of three friction devices refused), GEN-05298 Partial (code coverage needs a
toolchain), SSTLA-004 awaiting a reviewer score. From Steps 256-275: GEN-00988 **Fail** (there are no
bundled assets to compress, so the ratio has an empty population), GEN-01595 **Poor** (the log
scrubber intercepts three of eleven contact strings), GEN-04902 Partial (a cycle time from
convening to ratification measures a meeting), GEN-02808 **Fail** (no cipher ships in `lib/`, so
an encryption health badge's honest state is failed). Each of those four is the measurement the
row asked for, reported as it came out. Steps 276-295 report clean throughout -- no Fail, no
Partial, no deferred gate -- which is the first batch in nine to do so, and is a property of the
rows rather than of the effort: every one of the twenty had something a client could actually
build. From Steps 296-315: CRSSS-007-16 **Partial** (1 deferred -- the splash surface is drawn by
the operating system before the Flutter engine starts, so no frame of it is observable from
`lib/`; what a real measurement needs is written out) and GEN-01098 Good with 1 deferred (icon
recognition accuracy is a number about people, and the ISO 9186-1 protocol is specified rather
than approximated by the easier question this repository already passes). The other eighteen
report clean. From Steps 316-335: GEN-00077 **Fail** -- six of the eight defined acceptance
criteria for the masked field are confirmed, which is 75% against a 95% floor, and the two that
are not confirmed need a screen reader on a handset and the platform secure-entry flag observed
under recording. It is reported as Fail rather than rounded into a Partial. The other nineteen
report clean, and the batch carries no deferred gate. From Steps 336-355: GEN-05342 **Fail**
-- its composite rule is an AND over three completion criteria, one of which was observed and
met while two were never observed, because a completion rate needs a cohort and a window and
an average application duration needs a definition of when the clock starts, and neither
exists in the sheet. Nothing fell short; the failure is absence, which the row's Pass/Fail
output cannot express. The other nineteen report clean, and this batch too carries no
deferred gate. From Steps 356-375: GEN-02301 **Fail** -- "Verified" on
that row means four different things checked by four different actors, and the worked payroll
run holds three of the four, so the badge is refused rather than shown on a partial. The other
nineteen report clean, and the batch carries no deferred gate. Steps 376-395 report clean
throughout -- no Fail, no Partial, no deferred gate -- the second batch in
twenty to do so, and, like Steps 276-295 before it, a property of the rows:
every one of the twenty had something a client could actually build. Steps
396-415 report clean as well -- no Fail, no Partial, no deferred gate -- the third such batch
and the first time two have run back to back. That is not because these rows were well
written: four of them ask for rules the build already enforces, and a row that asks for
something already in the repository is easy to satisfy honestly and worth nothing. Steps
416-435 break the run: Step 430 reports **Partial** and Steps 432 and 433 report **Average**,
each because its own band says so -- 94 per cent coverage against an optimal of 95, and a
worst-case p99 above the optimal on two latency rows. Nothing was rounded up to keep a streak.
Steps 436-455 report one **Fail** (GEN-05133: a response-rate target lost its comparison sign
in export, and under the intended reading 27 per cent misses 30), one **Partial** (GEN-05364:
the objective is documented but no stakeholder here can confirm it) and one **Average**
(GEN-02161: an NPS of 14).

Steps 456-475 report one **Fail** (GEN-04935: the second row in the track whose target lost
its comparison sign in export, where an aggregate speech-recognition accuracy of 94.3 per cent
misses a target that should read "at least 95") and four **Partial** (GEN-04792, GEN-04990,
GEN-05155 and GEN-05210), each because the top of its band is a formal signature from an
accountable owner and no such person exists in a build session. The four Partials are one
finding rather than four: naming the owners turns all of them into Complete with no code
changing. The other fifteen report clean.

Steps 476-495 report three **Fail** and one **Partial**, each the row's own band read as
written. GEN-04935's successor is not among them: the failures here are a staging smoke-pass
rate of 75 per cent against a floor of 95 (BPTR-0176-A14), a change-failure rate of 25 per cent
against a floor of 2 (DRVUT-010-A18), and a first-contentful-paint breach on the oldest declared
device found by the very subroutine the row asked for (GEN-05452). The Partial is GEN-05419,
which is GEN-05210 character for character and stops, as GEN-05210 did, at a signature nobody
has been named to give. The other sixteen report clean.

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

### Instrumentation

Steps 156-166 build the telemetry layer, and Step 156 comes first because everything after it
emits events. The envelope is a type rather than a convention -- seven fields on every event,
with `event_date` and `trace_id` on the envelope rather than in the payload, so the partition key
and the cluster key cannot be missing from a kind whose author forgot them. No payload field may
hold free text, because free text is how personal data reaches a warehouse and no amount of
downstream sanitising reliably gets it out.

What the client owns stops at handover. Events batch twenty-five to an outbox entry and carry the
destination table; landing the rows is the server's, as it was at Steps 132 and 145. A drop-off
rate is a ratio across many users, so the client sends the events it is computed from rather than
a ratio with a denominator of one. Mean time to detect a price change is the backend's figure for
the same reason -- no phone is watching a price.

Two readings in this batch are worth keeping. RAIL's 100ms is the budget for a response to an
input; a cold start is not one, and applying the RAIL bands to it would report every launch this
app will ever make as a failure -- the same 1,100ms figure bands Good against the startup budget
and Poor against RAIL. And a performance trace is kept only if the app was in the foreground for
the *whole* window: checking at capture time passes the case everyone tests and keeps exactly the
traces that carry suspended seconds in their elapsed time.

### The token pipeline

Steps 176-195 build the pipeline around the Step 174 validator, and a fair amount of the work is
finding out how much of it was already true and never measured. The poka-yoke guard has failed the
build on an untokenised value since Step 4; what did not exist was any way to ask how many
exemptions it carries or whether that number went up, so the exemption count is now a declared
budget and an addition shows up as a diff. The 4dp grid was asserted at Step 2 and never measured;
measuring it puts the token set at 96.97% and names the one value that is off it -- a 6dp padding
bound that nobody noticed because it is a real Material density figure and looks like it belongs.

Two findings are defects nothing else here would have caught. A colour role declared in
`HabotColorScheme` but missed in the theme's override list resolves to a tonal value derived from
the seed: valid Material, not obviously wrong, and never audited, because the Step 4 contrast
engine reads the token declaration rather than the built theme. And the navigation shell renders
`onSurfaceVariant` on `surfaceContainer`, which is the pair every navigation label in the product
uses and which no pair in `ContrastAudit` covers -- measured here at 8.22:1 and 9.35:1, so the gap
was a hole in the gate rather than a defect in the palette.

Three rows asked for things that would have been wrong to do literally. "The left button" and
"bottom-right" are both positions, and in Urdu they name the other control -- the third and fourth
time this has come up after Step 150's swipe direction and Step 167's frozen column. And
`isLoading = true` is the defect rather than the requirement: one boolean cannot hold two
concurrent operations, and the symptom is reported as "the spinner disappears too early", which
sends people looking somewhere else entirely.

### The parent booking journey

Steps 196-215 follow one parent from first run to a dispute, and the pattern across them is that
the metric on a row is usually a better instruction than the row. Step 196 asks for an
`FRE_Completed` boolean and is graded on a completion rate; the boolean is written on completion
and on skip, so once both write the same value the rate is 1.0 for every install past the first
screen -- measured on ten constructed installs, 0.40 by outcome against 0.70 by boolean. Step 201
describes an avatar and a checkmark and is graded on whether allergies and medication were
captured; a card showing a face lets a parent select in a second and never see the empty field,
so the card carries completeness and the measured figure is 0.72 where "did the card get
selected" is 1.0. Step 210 asks for an export button and is graded on completeness; the failure
mode of an export is that it looks complete, so the coverage statement is stamped on the
document rather than announced in a toast that is gone before anyone opens the file.

Two rows argue against themselves. Step 212 asks for binary Approve/Reject and is graded on the
false-positive rate -- and binary is exactly the shape that manufactures false positives, because
a reviewer who is unsure has to pick one and the incentive always points at reject. A third
outcome that costs nothing to choose is the cheapest available reduction in that number. Step 213
asks for a mandatory reason-code drop-down; a drop-down showing a value satisfies every validation
that checks for a value, and the reviewer never touched it. Named here: a pre-selected one would
have submitted `PAY_AVS_MISMATCH` on every rejection, which is the code the false-positive rate
would then be grouped by.

Steps 207 and 208 point in opposite directions and both are right. Brand detection reads the first
digits of a card number; the PCI requirement is that the app is never in a position to see any of
them. The reconciliation is the callback every hosted-field SDK emits, and the IIN table in the
repo is the contract handed to the provider rather than a code path here. Checking the defence in
depth found a real gap: the Step 68 log scrubber redacts a sixteen-digit PAN only incidentally,
through a rule about hex hashes, and misses a fifteen-digit American Express number and any PAN
written with spaces or dashes -- coverage measured at 0.25. The rule is proposed rather than
copied, because Step 179 already said what two copies of a rule with one of them executed is.

Two collisions with earlier work. "Contact for Details" is nineteen characters against Step 144's
twelve-character button budget, in English, before translation; the budget is now declared per
placement, because a twelve-character limit on a full-width button is a rule with no reason behind
it. And a 144x160dp category card is three times Step 184's touch-target ceiling -- the band
governs controls, a card is an item surface, and the exemption is written down with its rationale
because an exemption that exists only as the absence of a check is indistinguishable from an
oversight.

Step 204 is where Step 140's exact-money type finally pays: AED 4.35 converted to fils through a
double gives 434 rather than 435, and rounding VAT per line rather than once moves a three-line
order by a fils. The 50ms budget on that row is doing real work -- it rules out a round trip,
which means the total shown while a parent is choosing is the device's, and that creates two
totals. The server's charges; a disagreement is disclosed before a card is taken.


### Adaptive layout, touch targets and performance budgets

Steps 216-235 are three clusters, and each one starts by counting what is already declared. Step
216 asks for the MD3 window size classes and finds four declaration sites and two different enums
already holding them; the answer is a census rather than a fifth. The same shape recurs at Step
227, where three separate rows -- one in this batch and two more beside it -- ask for a 48dp touch
target that six earlier steps already built, and the three rows disagree about the ceiling: 56, 64,
56. That is resolved per control class, with 64 honoured for navigation destinations where the
sheet meant it, and one coincidence is written down: `HabotSpacing.xxxl` is 48 and
`HabotDensity.minTouchTarget` is 48, and they are not the same fact.

Three rows are false as written and are measured to prove it. "Only visible components consume
rendering resources" (Step 231) is false by design -- a `ListView.builder` builds a cache extent
beyond the viewport so a flick does not hitch, and on the shortest declared phone with a 96dp item
that is 6 items built and not visible out of 12. Setting the cache extent to zero satisfies the row
exactly and produces a list that stutters. "Block OOM by limiting concurrent DOM nodes" (Step 232)
names a platform this app does not run on, and nodes are not where the memory goes: a 4032x3024
photograph decoded at source resolution is 48,771,072 bytes against 120,000 at its display size, a
factor of 406, and eight thumbnails at source resolution overflow Flutter's 100 MiB image cache and
start evicting the pictures the user is looking at. "Worklet-based animation runners" (Step 233)
describes a React Native and CSS Houdini construct; Flutter's UI and raster threads are already
separate, and what actually blocks a frame is a JSON decode called from `build`.

Two findings are about instrumentation rather than layout. Step 229 adds
`A11Y_TOUCH_TARGET_BELOW_BAND` because the existing `A11Y_LITERAL_TOUCH_SIZE` rule reads source
text and cannot see the value a token resolves to -- a control sized from `HabotSpacing.lg` passes
the guard at 24dp and fails WCAG. Each rule is demonstrated catching something the other passes,
so neither replaces the other. And Step 234 refuses the blanket reading of its own row: deferring
the crash reporter means crashes during startup go unreported, and those are the ones that matter
most, because to the user they are not a crash, they are an app that does not open.

Three steps report less than Complete and say why. Step 219's scope names two codebases and
habot-web cannot be inspected from here. Step 223 would have to lock orientation to report
Complete, and a portrait lock fails WCAG 2.1 SC 1.3.4. Step 235 asks for a decision record with
"rationale & owner sign-off"; the record is authored and every figure carries its rationale and
the conditions it holds under, but a sign-off is a person and one cannot be obtained from a build
host. The finding underneath it is that two of the three SLAs the row asks to establish --
FCP <= 1.2s and TTI <= 2.0s -- have been in force to the millisecond since Step 165 as
`coldStartBudget` and `interactiveOn3g`. What was missing was the record, not the number.

Step 230 closes half of open decision 2. RCGLA-012 wanted `user-scalable=no` and was deferred for
failing SC 1.4.4; this row asks for something different and achievable -- disabling *accidental*
double-tap zoom -- which `touch-action: manipulation` does, removing the gesture and the ~300ms tap
delay while leaving pinch zoom intact. The meta tag is assembled from the directive list rather
than written out, so a refusal cannot be re-added by editing a string.


### Form input, validation and the submit gate

Steps 236-255 are the validation layer, and the first thing they did was find that it already
exists: `HabotMask`, `HabotFieldRules`, `HabotFormGate`, `HabotValidationStateColor` and
`HabotSubmitGuard` between them already carry masks, patterns, touched-state, error cues and submit
locking. So this batch is a census, three genuine gaps, and one real defect measured three
different ways.

**The defect.** Three of the thirteen declared field rules carry a mask that filters out a
character their own pattern requires. `dateIso` needs a hyphen and is masked `decimal`; `dateUs`
needs a slash and `timeOfDay` needs a colon, and both are masked `numeric`. `ValidatedInputField`
wires `rule.formatters`, which is `HabotMask.formattersFor(rule.mask)`, so those three fields
cannot be typed into a state their own validator accepts — the separator is swallowed as the person
types it. The error message on `dateUs` says "Enter a date as MM/DD/YYYY" and the field deletes the
slash. Three rows' metrics detect it independently: mask/pattern agreement at 0.769 against a floor
of 0.95 (Step 238), cross-surface standardisation at 0.867 against 0.99 (Step 241), and error
recovery at 76.9 against 90 (Step 250). A correction is built and gated —
`HabotMaskBinding.correctedFormattersFor`, derived from each field's own declared pattern rather
than from a second table, so it adds no duplicate rule — and it takes all three measurements to
their ceiling. It is not wired in: that is a one-line change in BPTR-0160's gated file and this
host has no toolchain to re-run those gates.

**Three rows are about arithmetic a regular expression cannot do.** An IBAN's check digits are
mod-97 over the rearranged value, so a pattern can say what an IBAN looks like and only arithmetic
can say whether it is one: over ten vectors, structure alone classifies five, adding the country
registry and its length reaches eight, and mod-97 reaches ten. The two it adds are the two errors
people actually make — a transposed pair of digits and one mistyped digit. Step 252 is the mirror
image: `0.7 - (0.1 + 0.2 + 0.4)` is `-1.1e-16` in binary floating point, so a gate written in
doubles *refuses a correct split* and there is nothing the person can type to fix it. The failure
mode of a client-side balance check is rejecting good data, not accepting bad, and Step 140's exact
type is what prevents it.

**Two refusals, and they are the same ruling.** Step 248 asks for a "glaring red badge and
disrupted sort order to create visual friction". The sort-order disruption is refused outright: a
list's order is a promise, and the cost of breaking it lands hardest on a person navigating by
position. The badge is refused as specified — colour alone fails SC 1.4.1 — and reinstated with the
four cues the error state already carries. What is built is a deliberate pause, scoped to actions
that cannot be undone, which is the one place where the row's ">5 sec dwell" optimal is a good
number rather than a symptom. Step 249 asks for a "delayed progress bar" by name and gets the same
answer: a progress indicator slowed on purpose lies about system state.

**Two steps found things about other people's data.** Step 244's row asks for Form I-9 and US Tax
ID formats — a form is not an identifier, and this is an application whose money CDE is
`cac_aed_value`. Step 236 had already recorded that the phone rule's placeholder is a Kenyan
dialling code, so the repository was carrying two jurisdictions before this row added a third.
Every identifier rule now names its own. And Step 251 found the one backend failure where the
client does not know what happened: on a timeout the request may have been received, processed and
committed with only the response lost, so retrying a payment there charges a parent twice. The
retry rule is now a function of two things — what failed, and whether the call was safe to repeat.

### The repository, the network edge and what a client may attest to

Steps 256-275 are the batch where the sheet asked the repository to describe itself and then asked
the client to vouch for things that happen somewhere else. Both halves produced findings.

**Three rows asked for files that are not there.** Step 256 maps thirty-two real directories in
twelve rows, 267 Dart files, four hops from the repository root to a component. Step 257 asks for
`lib/screens` and there is none, because this application has panes rather than pages -- five
routes served by one adaptive shell, so there are more routes than screen files. Step 258 asks to
open `src/navigation/AppRouter.tsx`, which is TypeScript in a Dart application, and is the fifth
row in this track written for a stack that was never used. None of the three was answered by
creating a file so the sentence would come true; each was answered with what is actually there and
a note about the gap.

**The three metrics on those rows are stopwatches on a human.** "Path Navigation Overhead",
"Directory Navigation Time" and "Router Module Open Latency" all time a person opening something,
which no build host can do. The substitution in each case is the search space: thirty-two
directories average 8.34 files each, so finding one file means reading about a thirtieth of the
tree. Steps 256 and 257 carry the identical band -- 1.0s / 0.1s / 2.0s -- under two different
metric names, transcribed independently so the twin shows up as a finding rather than as a shared
constant.

**Four rows measured something and the measurement came out badly.** Step 263 found zero bundled
image assets: `assets:` is commented out in `pubspec.yaml`, there is no `assets/` directory, and
all thirty-five image files in the repository are platform launcher icons and favicons -- 71% of
the bytes are macOS. It reports **Fail**, because reporting Pass over an empty population is how a
metric stops being able to fail. The same row's band, "Asset Compression Ratio >= 90%", has no
direction: on one reading the ceiling is the best outcome and on the other the floor is, and both
are computed on one worked pair rather than argued about.

Step 268 put fifteen strings through the log scrubber that actually ships. It intercepts three of
eleven personal contact strings, and two of those three are collateral from a rule written for
something else -- so the deliberate rate is one in eleven. Four proposed rules reach nine of
eleven with no control redacted, and are not merged, because the scrubber is an earlier step's
gated file and no host here has a Dart toolchain. The ceiling is not one either: the two still
missed are a personal name and a street address, which no pattern recognises.

Step 271 asked for an encryption health badge. Six facts a reader would take such a badge to cover
are enumerated; three are knowable on the device and **none of the three key-management facts is**
-- custody, rotation and access audit all live where the keys are, and that is the subject the
metric is named after. Worse, `HabotEncryptedStore` requires a `HabotCipher` and none ships in
`lib/`, so the badge's honest state on this build is **failed**. It has three states rather than
two, because green and red leave no room for "I have not heard recently", which is the client's
ordinary condition; staleness lands on unknown rather than red, because a badge that goes red on a
bad network is a badge people learn to ignore.

Step 270 reports **Partial**: a Decision Governance Cycle Time measures a meeting, and no build
host can convene or time one. What is produced instead is the decision record -- two clauses
settled, three left open with what each needs. The first clause is the counter-intuitive one:
withdrawing consent and deleting the consent record are opposites, because the obligation is to
demonstrate that consent *was* given, so somebody implementing "delete everything on withdrawal"
deletes the evidence that the collection had been lawful.

**Five rows are about the boundary between what a client may claim and what it may only report.**
Step 269's Cloud DLP scan runs against a warehouse this application has no credentials for -- and
should not have. Step 272's execution blocks depend on detectors that run inside the environment
they are judging, so four of the five signals are evidence rather than verdicts and the block is
the server's decision that the dialog explains. Step 273's TLS floor is met structurally, because
the socket policy declares `wss` and refuses anything else, while the negotiated version and
cipher suite belong to the platform stack. Step 274's crash-free session rate needs a denominator
the device does not hold. Step 275's rollback is a change to a flag the server owns. In each case
the client half is built and the other half is named rather than claimed.

**And three rows were about the same word meaning two things.** Step 266: "alt descriptions for
all non-text content" scores 75% on the row's own metric if taken literally, because alt text on a
decorative divider makes a screen reader announce a divider; marking the decorative classes
decorative scores 100%. Step 267: "masking displayed sensitive values" leaves the value in process
memory, in the app-switcher snapshot, on the clipboard and in anything emitted -- five surfaces are
ruled on and exactly one sees the whole value. Step 275: "elevated error rates" with no threshold
would roll a release back on three unhappy sessions out of forty, which reads as four and a half
times the control rate and is three people.

**Arithmetic worth keeping.** Thirty seconds of server patience is fifteen client interactive
budgets (Step 273). An encryption badge polled every thirty seconds asks 2,880 times inside one
24-hour freshness window (Step 271). A crash-free ceiling of 0.9999 needs a hundred times the
evidence its floor does -- ten thousand sessions against a hundred (Step 274). Reading a file's
first four bytes moves attachment validation accuracy from 0.875, below the row's floor, to 1.0
(Step 262).

### Disclosure, density, and the five jobs the word "disabled" is doing

Steps 276-295 are one arc with three movements: what the interface reveals, how dense it is
allowed to be, and what it does when it will not let you act. The third movement is the finding.

**"Disabled" names five different things across five adjacent rows, and only one of them is
enforceable here.** Step 291 binds a button to a reconciliation result and reuses Step 254's
sealed gate, so every refusal carries a reason and a field to focus. Step 292 asks to
*permanently* disable the same button on a score that changes -- implemented literally, the first
non-zero score latches it off and the person closes every gap and watches nothing happen; the word
is refused and the latched kind is declared-but-unused so that choosing it would be visible. Step
293 disables payout buttons on a server flag and, in its own design notes, both supplies the
recovery dialogue Step 292 was missing *and* repeats "permanently disabled" two lines later. Step
294 locks pathways on unverified authorisation, where the point is that a disabled control is a
hint and not a boundary. Step 295 blocks cell editing under the name "interface permissions",
which is a contradiction: permissions are enforced where the data is.

**Two of those rows contain the cure for the others, and none of them knows it.** Step 291's
design notes say "tap the widget to see exactly which logic chunk is missing" -- exactly what Step
292's greyed-out button lacks. Step 293's say "tapping the suspended chip opens a dialogue
explaining recovery steps" -- the same fix again, on the row that also repeats the defect. All
three are adjacent in the sheet, assigned as separate steps, cross-referencing nothing. The remedy
is implemented for all of them and the adjacency is recorded, because a reader who implements 292
alone builds the dead end.

**"Unverified" is three states.** Verified-and-allowed, verified-and-refused, and not-yet-known.
Collapsing the third into the second means a slow authorisation check reads as a refusal, so the
person on the worst connection is the one told they may not do something they may. Step 271 gave
the encryption badge the same three-valued shape a fortnight ago for the same reason: silence is
not a verdict.

**The disclosure rows found a scrolling hazard that hides from tests.** Step 277 asks for a
maximum height on an expanded accordion panel. A capped panel with more content than fits is a
second vertical scroller inside a vertical page, and the inner one takes the gesture -- the bug
arrives as "the screen is stuck", not as anything about scrolling. It is also intermittent by
construction: the cap does nothing until the content is long, so it passes every short test case.
The constraint moved onto the content instead: six rows inline, the rest on a surface of its own.

**Step 282 is the batch's cleanest measurement.** The row asks for a snackbar reading "Action
Failed". That string passes `HabotErrorSnackbar.isPresentable` -- the gate built to stop stack
traces and HTTP codes reaching users -- because it leaks nothing. It is also useless: it names
neither the action nor a next move, so a person with a booking saving and a photo uploading learns
that one of them stopped. Leakage and emptiness are different failures, the old gate is not at
fault for missing the second, and the corpus here contains all four combinations so neither test
can pass on the strength of the other.

**Two rows cite the same standard on the same day and disagree.** Step 276 gives 44px as the WCAG
AA touch-target floor; Step 285 gives 24x24px. SC 2.5.8 (AA) is 24 and SC 2.5.5 (AAA) is 44, so
Step 285 is right and Step 276's floor is the AAA figure wearing an AA label -- and its 56px
ceiling is in neither level. Step 285 also turned out to be the more interesting row: a gap is not
a second requirement, it is the *exception* to the first, so target size is one predicate with two
branches and an 18-point link with 12 points around it passes where two 20-point chips two points
apart do not.

**Two bands for one metric.** Step 283's haptic delay band is 10ms / 2ms / 16ms; the band already
declared for the same tap-to-motor interval is 100ms / 50ms / 16ms. They agree only on the
ceiling, which is the one figure that is a fact about anything -- 16ms is a frame. Two
milliseconds across a platform channel is not a harder target, it is an unmeetable one.

**And one band cannot fail at all.** Step 286's MD3 Token Compliance floor is "ad-hoc custom
styling, no token system" -- the condition a token system exists to end. Every repository meets
it, including one that has never heard of tokens. Step 263 refused to report Pass over an empty
population; this is the same defect written into a band.

**Eight rows written for other stacks.** CSS at 276, 277 and 291; React Native props at 280;
`md-linear-progress`, a Material Web Components custom element, at 284; `Arrangement.Center` from
Jetpack Compose at 289; a JavaScript function at 295. Step 258 keeps the running list.

### Waiting, absence, and the ceiling below its own optimal

Steps 296-315 are one arc about what a screen shows when it has little or nothing to show:
waiting states (296-301), absent and empty values (302-304), icons and severity (305-309),
density and lists (310-312), and reach and verification (313-315).

**Step 312 carries the first band in this track that is false on its own terms.** Its floor is
0.98, its optimal is 1, and its **ceiling is 0.999** -- the value the row calls best sits outside
the range the row calls acceptable, by a thousandth. Every band defect recorded in the eleven
batches before it was a unit mismatch, an unfailable floor, or a boundary about another subject.
And the population makes it worse: the thing being scored is five status badges, so the index
moves in fifths and neither 0.98 nor 0.999 is a value the measurement can take. One attainable
value clears the floor. Step 305 has the same shape at a different scale -- a banned-term rate of
"<=1 per 1,000" over twelve asset ids, where the smallest expressible non-zero rate is 83.33 per
thousand, eighty-three times the floor.

**One adjective in Step 300 costs a Level A criterion.** "Display subtle animation hints ... to
signify *continuous* background tracking" is, taken literally, motion that starts automatically
and never stops: 72,000 frames across a twenty-minute session, 240 times the five-second threshold
at which SC 2.2.2 Pause, Stop, Hide applies. Nearly every accessibility defect this track has
recorded sits at AA or AAA; this one is at the lowest level there is. The element animates once on
the transition and then says, in words, what is being collected and how to stop it -- which is
also the honest answer to a tracking disclosure being attempted by a shimmer.

**Steps 303 and 309 are the same subject six rows apart and neither knows.** 303 asks that
combined text strings be broken into "separate atomic variables"; 309 asks that compound syntax be
painted red while somebody is typing it. 303's instruction, followed literally, produces the harm
it is reaching for: a concatenation has one shape, so it offers one plural form per locale, and
the five locales this application already ships need sixteen between them -- Welsh six, Polish
four. Eleven of those sixteen have nowhere to go. The cure is the opposite move, one whole
parameterised message per sentence, which also leaves the parameter separate enough to wrap in
the bidi isolates Step 139 already shipped for Urdu.

**Step 309's own finding is about when, not what.** At 200 characters a minute a ninety-second
draft is 300 keystrokes. Highlighting on each one paints and unpaints up to 300 times and tells
somebody their sentence is wrong before they have finished it; running on the two-second dwell
Step 290 declared gives three evaluations. A hundredfold difference in how often a person is
interrupted, out of one decision about when to look -- and the people who meet it most often are
the slowest typists.

**Step 302's metric times a trim, and the trim is not the problem.** The optimal is 0.001 ms --
one microsecond, at the resolution of the clock that would measure it -- for an operation that
takes tens of nanoseconds. Meanwhile the check the row describes accepts two strings that render
as nothing: U+200B ZERO WIDTH SPACE and U+2060 WORD JOINER have no Unicode White_Space property,
so `trim()` leaves them and the field is "not empty". The person is looking at an empty box the
application insists is filled, and there is no edit that fixes it except deleting a character
they cannot see.

**Two rows in this batch cite different criteria for the same number, and the codebase had
already settled it.** Step 298 gives 44dp as WCAG 2.2 SC 2.5.8; Step 313, fifteen rows later,
gives the same figure as WCAG 2.1 SC 2.5.5. SC 2.5.8 Target Size (Minimum) is 24x24 at Level AA
and SC 2.5.5 is 44x44 at Level AAA, so Step 313 is right -- and Step 227 recorded and resolved
that exact confusion in this repository ninety steps ago. The sheet has reproduced a defect the
code had fixed.

**Step 313's contribution is a boundary, not a check.** The row asks somebody to verify that all
interactive targets meet the minimum. That verification has run at stage G-C of `verify_aiss.sh`,
before the tests, on every commit since Step 229 -- the same shape as Step 180, where the
mechanism the row asked to activate had been running for 176 steps. What was missing is what the
guard cannot see: four of six control classes declare a size and two compose one at run time, from
a translated label and from the text scale, and those two are exactly the ones that move under the
conditions people actually use the app in.

**Step 310 repeats Step 286 verbatim, band and all.** Same instruction -- condense a dense table
into a scannable summary -- and the same three MD3 Token Compliance boundary strings, twenty-four
rows apart, cross-referencing nothing. The transform is imported from Step 286 rather than written
a second time, because a repository with two data-summary components has a drift problem rather
than a design. The hardware table also showed something Step 286's did not: its truncation and its
summary happen to pick the same three columns, so it looks right in review and is right by luck --
one longer device name takes the table to two columns while the summary stays at three.

**Step 314 asks for the anti-pattern by name.** A "screen-reader fallback list" is a second
structure holding the same nine categories: eighteen places to change, nine pairs that can
disagree, and every disagreement invisible to everybody except the person it was built for. One
structure that is accessible is the answer, and the metric's own instrument cannot see the
difference -- a row with no semantic label executes exactly the lines a labelled row executes, so
a suite at 100% coverage passes over a control that announces nothing.

**Four rows reach SC 1.4.1 from four directions.** Step 300's tone swap for a spending threshold,
Step 306's error colour asked to signify three severities when Material has one error hue, Step
309's red highlight, and Step 315's "red-highlighting". Step 315 also carries the batch's other
impossible cell: a metric named **"WCAG Contrast Ratio (1:1)"**, which is two identical colours,
on a row whose own floor is 4.5 -- and a *cross-browser* accessibility test in an application that
renders its own text and has no browser.

**Two gates are deferred, both with their protocol written out.** Step 299's splash animation is
drawn by the operating system before the Flutter engine starts, so no frame of it is observable
from `lib/` by any amount of effort; what is observable, and what people actually complain about,
is the handoff to the first Flutter frame, and that is budgeted at one frame. Step 308's icon
recognition accuracy is a number about people -- an ISO 9186-1 comprehension test -- and the
tempting substitute, the share of icons carrying labels, is a different and easier question this
repository already passes at 100%.

**Four more rows written for other stacks**, bringing the running list to twelve: CSS with a
z-index at 299, Jetpack Compose at 297, the DOM at 308, and cross-browser testing at 315.

**The exception worth naming.** Step 288 asks to identify ENUM fields needing chip presentation
and is scored on Asset & Component Discovery Completeness. After nine batches of metrics belonging
to other rows, that one measures its own action -- and its ceiling, "100% (full inventory -- no
further discovery value beyond complete coverage)", is the only ceiling in this batch that
explains itself and is right.

**Arithmetic worth keeping.** Eight columns of scheduling data need 690dp and a phone has 328, so
five go past the edge unseen (286). Dwell thresholds span 45x across input kinds, from four
seconds on an empty numeric field to three minutes on a note (290). Two thirds of a single-task
screen leaves it, and one of the nine elements has nowhere to go (289). A greyed label at MD3's
0.38 opacity keeps about 2.7:1 of a 7:1 contrast (292). 99.99% payout accuracy is one person in
ten thousand (293).

### Refusal, and what gets written down

Steps 316-335 are about the word no. What the application refuses, how it refuses, whether the
person refused has anywhere to go, and what is left in the record afterwards. Twenty rows, and
the shape they share is that a refusal is easy to implement and hard to finish: the stopping is
one line, and everything after it -- the reason, the remedy, the log entry, the alert that fires
because of it -- is the rest of the work.

**Fail-closed is three facts, and two of them are ours.** Step 316 asks for Null, Error and False
to be treated as a hard stop. It is the first collapsed band in this track that is the right
shape: those three are genuinely one category at the decision point, because none of them is a
yes. They are not one category anywhere else. Null is a question that was never answered, Error
is a question that could not be answered, and False is an answer. Two of the three are the
system's own failure and one is the subject's, so the stop is identical and the sentence shown to
the person cannot be. Step 317 turns that into five states with five designs and proves the map
is bijective: no state without a design, no design without a state. The state a person meets most
often -- the one where our own service is down -- is the one where they have done nothing wrong,
and it is the state a single generic error message erases.

**Money does not balance in doubles.** Step 318 is a submit gate that will not accept a form whose
parts do not sum to its total. AED 350.21 plus AED 454.47 is AED 804.68, and in IEEE 754 binary
it is not: the residual is 1.14e-13, small enough to look like nothing and large enough to refuse
a correct form. The gate reconciles in fils, as integers, and the decimal strings are parsed
rather than the doubles compared. This is the same refusal Step 168's strict-true gate makes, and
it is worth naming twice: a currency is a count of minor units, and the moment it becomes a
floating point number, a person who typed the right thing gets told they did not.

**Three floors that cannot be failed, of three different kinds.** Step 319's floor is
"default-allow", which is the insecure configuration described as the minimum acceptable one --
a floor that a correctly built perimeter passes by being wrong. Step 329's band puts a gradient
on a fail-closed control, so a gateway that lets some data out scores partial credit on a
question that has two answers. Step 331's floor is a sentence: "Matches MD3 spec with minor
documented variance", where "minor" and "documented" are both undefined and between them cover
any variance somebody is willing to write down. Three rows, three mechanisms, and the same
consequence -- a measure that no implementation can fall below is not a measure.

**Four inverted latency bands, and the one that is not.** Steps 325, 326, 334 and 335 each give a
lower-is-better latency measure a ceiling worse than its floor: 5s over 2s, 60s over 30s. Step 333
gives the same kind of measure a floor of 60 seconds, an optimal of 10 and a ceiling of 5 --
ordered correctly, the worst tolerable value at the floor and the best at the ceiling. That single
correct instance is the finding. If all five ran the same way, the reading would be that this
sheet writes latency bands upside down and every consumer should invert them. One ordered
correctly means the other four are mistakes in four particular cells, and the sheet cannot be
read by convention at all.

**Four output columns with one value in them.** Steps 321, 322, 334 and 335 have a Best
Qualitative Output column that reads "Pass" and nothing else. A column with one value cannot
express the outcome it exists to record; a row scored on it reports Pass whether it passed or
not. Two more band defects sit beside those: Step 330's floor and ceiling are the same 300
seconds under two different names, and Step 332's ceiling is its optimal with an inequality
written in front of it. Five distinct band defects in twenty rows.

**One row reports Fail.** Step 327 asks for a masked text field and scores it on the share of
defined acceptance criteria confirmed, floor 95%. Six of the eight criteria are confirmed. That is
75%, it is below the floor, and it is reported as Fail rather than rounded into a Partial. The two
that are not confirmed are not confirmable from `lib/`: one needs a screen reader on a handset and
one needs the platform's own secure-entry flag observed under recording. The word "masked" is also
doing three jobs on that row -- input formatting, visual obscuring, and redaction in logs -- and
the three have different threat models and different failure modes.

**A refusal with no way out is an abandonment.** Step 320 is the remedy Step 292 needed and did
not have: a greyed control that a person cannot use is a dead end unless something on the screen
says what would ungrey it and offers the request. Four of the five fields in the elevation request
are pre-filled from what the application already knows, so the ask costs one sentence. Step 324 is
the same failure in the other direction -- a claimant blocked at the DOM from submitting evidence
during a force-majeure event, with no channel left. The file check there is the ordinary lesson
about trusting an extension: the declared extension is right four times in six, and the magic
bytes six times in six.

**What gets written down is a volume problem.** Step 333's row says alert on "any unauthorized
modification attempt". A day of real telemetry is 483 such events. Deduplicated by actor,
resource and kind they are 12 distinct triples; escalating refusals on rate rather than on
occurrence, and a successful unauthorised change on its own occurrence, gives 5 alerts. The
reduction is 97.5%, and it is not a filter -- the difference between a refused modification and a
successful one is the difference between the control working and the control failing, so
"any attempt" puts the loudest signal on the quietest available news. Step 335 makes the
denominator point: ten crashes in a thousand sessions is a hundred sessions per crash, the floor
of the Step 274 band, and ten crashes in a million sessions is a hundred thousand, ten times its
ceiling. The same numerator, opposite verdicts, which is why the rule is a rate against the same
weekday's baseline and refuses to fire below five hundred sessions.

**An outage is the one time the application is fast.** Step 334's page is what a client shows
while a circuit is open. A closed circuit working through a retry policy of 500ms, 1s and 2s
takes three and a half seconds to know anything, which is a spinner before any sentence. An open
circuit knows immediately. The one occasion a person gets a straight answer at once is the
occasion when everything is broken, and that is worth building on purpose rather than treating
as an accident of the failure path.

Numbers worth carrying out of this batch: the residual on a three-part AED sum in doubles is
1.14e-13 (318). Twenty-one of twenty-four perimeter rules are denies, so 87.5% of the list is the
default and 12.5% is the exception worth seeing (319). A 60-metre position with a 25-metre
accuracy radius straddles a 50-metre geofence, and the badge has three verdicts rather than two
(321). A panic button's dispatch decision is 0.208% of a four-minute wait (326). Four of eight
evasion forms are caught by text matching, against a 90% floor, which makes it an enforcement
problem rather than a matching one (328). A PHI egress gateway sees one of three exits (329). A
thirty-second poll is up to thirty seconds stale on a counter the row calls real-time (331).

### The gesture nobody was taught

Steps 336-355 are about direct manipulation: what a person is expected to already know, how the
interface tries to teach it, and what it costs when a gesture is the only way in. Twenty rows,
and the thing they share is that a gesture is cheap to specify and expensive to make reachable.

**A row that fails its own floor.** Step 338's Atomic Step asks for a swipe-threshold snap
animation under **150 ms**. The band that scores it sets a floor of **100 ms**. Build exactly what
the row asks for -- 149 ms -- and it misses the floor by 49 per cent. Every band defect this track
has recorded in eleven batches was internal to the band: ends inverted, ends collapsed, units
mismatched, floors that cannot be failed. This is the first time a row's *instruction* and a row's
*boundary* contradict each other, which means the row cannot be satisfied and scored at the same
time. Its ceiling compounds it: ">100ms begins to feel laggy to users" is the definition of being
past the floor, written in the cell where the best attainable value belongs.

**Five gesture rows, five accessibility exposures.** WCAG 2.2 SC 2.5.1 Pointer Gestures is
**Level A** -- the lowest bar in the standard -- and requires that anything operable by a
path-based gesture also be operable by a single pointer without a path. SC 2.5.7 Dragging
Movements is AA and uses drag-to-reorder as its own worked example. Steps 336 (swipe between
viewports), 337 (drag a card layer), 339 (swipe to confirm a destructive action), 340 (drag to
reorder) and 343 (long-press to copy) each specify the gesture and name no alternative. None of
the five is wrong to want the gesture; all five are wrong to stop there. Step 339 is the sharpest:
a slide-to-confirm control guarding an irreversible action, where the accessible alternative
cannot be a plain button or the person using a switch gets the dangerous one-tap version and
everybody else gets the careful one. The answer is a second *cost* rather than a second *route* --
typing the action word (Step 352), or holding for the declared dwell.

**A new guard, specified where the need appeared and enabled where it could run.**
`A11Y_GESTURE_WITHOUT_ALTERNATIVE` is declared at Step 336 with an id and a description and left
off, because the census that would run it did not exist. It runs at Step 344 over nine control
classes, four of which use a path gesture. All four declare a single-pointer route, so the rule
starts with nothing to report -- which is the only honest way for a new rule to start.

**The counts that did not close.** Batch K ended by recording that its two repeated defects --
inverted latency bands and one-valued output columns -- had closed. They closed for that batch.
Step 351 carries both again: a ceiling of 150 ms against a floor of 100 ms, and a Best Qualitative
Output column reading "Complete" with no failing value. With Step 338 that makes **six inverted
bands** and **five one-valued columns** across the track. Two consecutive batches is where these
stop being incidents in particular cells and become a property of how the sheet is written.

**Four more shapes of band defect.** Four rows put the same number in the optimal and the ceiling
(336, 339, 346, 352), so the band has two ends and three labels. Five mix a percentage floor with
a bare-ratio ceiling (336, 343, 348, 354, 355). Step 348 manages three unit systems in one band --
0.6, 0.8, and "90%+ (diminishing returns)" -- with a ceiling that cannot be parsed as a number;
read literally it spans a factor of 150. And Step 349's floor is the *failure condition*: "Any
single stated criterion unmet", written in the cell for the minimum acceptable value, which says
the minimum acceptable outcome is failure.

**Two collapsed bands, one of which is right.** Step 341's floor, optimal and ceiling are all
100%, and its ceiling cell explains why: poka-yoke coverage is binary. That is the second
collapsed band this track has been able to endorse, after Step 316's. Step 353's is also 1/1/1,
and is not the same case -- haptic trigger precision is a timing accuracy, which has a
distribution, and no scheduler fires a callback exactly on a boundary every time. What is measured
there instead is what can be guaranteed: the pulse fires once, at the declared moment, and never
twice.

**Two metrics from other disciplines.** Step 337 scores a horizontal card drag on **Mean Time to
Detect**, cited to the Google SRE book -- an on-call number whose floor of fifteen minutes is
4,500 times the duration of the interaction it measures. Step 344 scores 48dp touch targets on
**Core Web Vitals INP**, which is defined over DOM events and collected by the browser Event
Timing API, in an application that rasterises its own widgets. Its floor cell reads "<200 ms
(needs improvement ceiling)" -- the right boundary with the band on the wrong side of it, since
below 200 ms is the *good* band.

**Three cells that are the generator talking.** Step 347's Data Requirement column reads "No
matched reference row in Setup Implementation master list ... verify manually" -- the generator
reporting its own miss, printed as a requirement. It is the first cell this track has met that
documents its own absence, and it is worth more than most of the cells that are filled in, because
a stated gap can be closed. Step 352's artefact cell is the word **DEACTIVATE**, lifted out of the
Atomic Step's parenthesis. Step 355's reads "N/A (Backend database setup). | N/A. | N/A. | N/A."
on a row about restoring a user interface -- the second such cell in two batches, after Step 332.

**"48dp (44px)" is not a unit conversion** (342). At the baseline density 48dp is 48px. 44 is
Apple's Human Interface Guidelines figure, and separately the WCAG 2.1 SC 2.5.5 number at Level
AAA. Two vendors' specifications printed as one figure in two units, four points apart -- nine per
cent on a side and nineteen per cent of area. In this repository they are already the floor and
the optimal of the band Step 184 built.

**The half of touch accuracy nobody wrote a row for.** Nine rows in this track have asked about
touch *size*; Step 343 is the first about the *gap*. Two 48dp targets sharing an edge each pass
every size rule this repository enforces, and a finger landing on the seam hits one of them at
random. The gap is 8dp, from the spacing scale declared at Step 2, and it does not separate the
fingers -- a contact patch is about 50dp across -- it separates the reported centroids.

**And one row reports Fail, for a reason worth reading.** Step 349 verifies three completion
criteria with an AND: a 70 per cent onboarding rate, a 15-minute average application, and 100 ms
grading latency. One is observable from this repository and was met. Two were never observed,
because a completion rate needs a cohort and a window and an average duration needs a definition
of when the clock starts -- and neither definition exists anywhere in the sheet. So the composite
does not pass, and nothing failed. A Pass/Fail output cannot say that, and it is the only thing
worth saying when somebody asks why the gate is red.

Numbers worth carrying out of this batch: a snap built to the row's own 149 ms misses the row's
own 100 ms floor by 49 per cent (338). MTTD's fifteen-minute floor is 4,500 times a 200 ms drag
(337). A long move costs one drag or five taps; the adjacent move -- the commonest -- costs one of
either (340). 48dp against 44dp is 19 per cent of area (342). Four labels across 328dp is 82dp
each (354). Four hundred and eighty-three is Batch K's number; this batch's is nine control
classes, seven of them statically provable (344).

### The claim, and what is behind it

Steps 356-375 are about assertion. A verified badge, a confidence rating, a swept-records count,
a safety ratio, an anomaly flag, a status panel that says "Healthy": twenty rows in which the
interface tells somebody that something is true. The question each one raises is the same --
what is behind the claim, and does the reader get to see it.

**Four meanings of one word.** Step 356 renders "Bank Verified Revenue" and Step 357 renders
"Payroll Verified". Between them the sheet uses "verified" for four different checks performed
by four different actors: a bank confirming a deposit, a payroll system confirming a run, an
operator confirming a document, and a model scoring a likelihood. Step 357 reports **Fail**
because the worked run holds three of the four and a badge that means four things cannot be
shown when one of them is missing. Step 359 is the sharpest version: the confidence indicator's
four worked ratings include one outside the model's calibrated range and one with nothing to
cite -- and both score above 0.9. The scoring function is confident in exactly the two cases
where the interface should not be, which is the argument for rendering a named band rather than
a number.

**A band carried by six rows is a template, not six mistakes.** Steps 358, 362, 374 and 375 all
carry the identical refresh-latency cells -- floor `<1 hour`, optimal `<5 minutes`, ceiling
`<24 hours` -- and so do Steps 163 and 175, which tokenised them long before this batch. The
ceiling is twenty-four times the floor on a lower-is-better measure, which reads the ceiling as
the worst bound and every other latency band in the sheet as the best. Open decision 47 asked
whether the inverted bands were incidents or a property of the sheet; six identical copies of one
cell answers it.

**The second band false on its own terms.** Step 370 sets a floor of 0.9, an optimal of 1 and a
ceiling of **0.98**. The value the row calls best sits outside the range the row calls attainable.
Step 312 carried the identical shape fifty-eight rows earlier with a gap of one thousandth; this
gap is two hundredths, twenty times as large. Step 368 adds a third shape to the family: an
optimal written `"0-1"` with a ceiling of 1 sitting inside it, so three cells hold two distinct
positions.

**And a band that is not a number at all.** Steps 356 and 365 write all three of their boundary
cells as `$60\text{ fps}$` -- LaTeX math mode, in a spreadsheet column a consumer will parse.
Two rows in one batch is a pipeline rendering numbers with a typesetting wrapper, not a
keystroke. Step 367 adds a fourth shape by joining two measures with a slash in every cell
(`95% cov. / <15 min`), so a reading of 99 per cent coverage at twelve minutes clears the
coverage optimal and misses the latency floor at the same time, and the cell cannot say which
verdict wins. Split apart, both halves are well formed, which is the argument for splitting them
rather than discarding them.

**A truncation nobody can see is a wrong answer with a fast render time.** Step 363 caps a
listing at five hundred rows over a table of 3,120: the list says `Showing 500 of 3120` and the
complete one says `Showing all 84`, because an unqualified count leaves a reader unable to tell
the two apart. 2,620 rows are named as not drawn. Step 365 applies the same rule to a graph,
which is harder because a graph has no scrollbar to be short. Step 370 applies it to a format:
four fields fit in 296dp of a 328dp screen with 32dp to spare, the fifth is 120dp and does not,
and the one that is dropped is named along with where it can still be found.

**Aggregation is a privacy control before it is a performance one.** Step 362's search-trends
panel publishes three of five filter combinations and holds two back below an anonymity floor of
ten distinct searchers -- the two suppressed ones being "overnight, medical needs,
postcode-level" and "Arabic-speaking carer, infant, specific street", in which no field is a
name. Twenty-three searches sit behind them and are counted on the face of the panel rather than
dropped. Step 374 reuses the same floor on a telemetry series: a bucket with four contributors is
four people, and drawing it as a very short bar publishes them, while drawing it as zero would
read as a collapse in activity. Step 373 carries the consequence into HR: an anomaly flag is a
claim about a person, and two of its four worked flags are unusual against one baseline and
ordinary against another.

**The word that keeps not surviving contact.** "Instantly" (373), "clearly" (369) and
"single-tap" (372) are each a requirement only once somebody says what they exclude. A dashboard
cannot display anything instantly to a person who is not looking at it, so "instantly" on a pull
surface means "as soon as they open it" -- the same finding Steps 331 and 371 record about a
counter and a warning indicator, and none of the three rows asks for the push that would close
the gap. "Clearly" excludes colour alone, an icon alone and an abbreviation, which is three of
the four available presentations. And a single tap answers four questions about an export --
which period, which people, which format, where it goes -- so the button keeps its one tap and
puts the four answers on its face.

**Two cells in this sheet now document their own absence.** Step 369's Data Requirement column
reads "No matched reference row in Setup Implementation master list ... verify manually",
identical to Step 347's twenty-two rows earlier. A first occurrence is an accident; a second with
the same wording is a template -- and it remains more useful than most of the cells that are
filled in, because a stated gap can be closed and an invented requirement cannot be told apart
from a real one.

Numbers worth carrying out of this batch: one band, six rows, and a ceiling twenty-four times its
floor (358, 362, 374, 375). A ceiling two hundredths below its own optimal, twenty times the gap
of the first such band (370). 2,620 rows named as not drawn (363). Seventy records touched out of
two million, which is thirty-five per million (360). A fingertip at 12.5 times the width of a
cursor, and four plotted points resolving to three selections (366). Four fields in 296dp with
32dp spare and a fifth at 120dp (370). Four export decisions on one button, and forty-eight
people in the worked run (372).

### The interface that says no

Steps 376-395 are about refusal: who gets stopped, how they are told, and what it
costs. Hidden and disabled elements, out-of-bounds actions, a station lock, a rubric lock,
a release gate, a clock-in gate, a spend freeze, edge validation, error boundaries, and a
countdown to a consequence. Twenty rows, and what they share is that saying no is easy and
saying it *usefully* is the whole of the work.

**Three rows in this batch ask for work that already exists.** Step 380 repeats Step 368's
read-only dashboard instruction twelve rows later under a different reference id, a
different metric, a different standard and a different team, and neither row mentions the
other. Step 382 disables a release control Step 292 already disables, under a different
condition and a different button name -- so if it is one button it has two gates and each
row knows about one. Step 394 repeats Step 194's `isLoading = true` two hundred rows later,
and Step 194 keeps a naive single flag in the repository *as a recorded counter-example*,
which means this row asks for the counter-example by name. Every previous repeat this track
has recorded was a duplicated **defect**; these are duplicated **work**, and a reader
following the sheet in order builds each of them twice.

**What a refusal owes the person it stops.** A disabled control with no reason is the
failure the whole batch exists to prevent, and Step 292 settled where the reason lives --
beside the control, never inside it, because a greyed label is the one place nobody looks.
Step 377 extends that: "out of bounds" is five different things (above a ceiling, below a
floor, a precondition unmet, a role refused, a state already reached), only two of which are
bounds in the arithmetic sense, and a renderer that calls all five "invalid" produces one
grey button and one silence for all of them. Step 376 adds the question before it -- whether
to disable at all, or to render nothing: a disabled control teaches the reader the limit,
the threshold and the role that clears it, which is exactly right for a report they may not
run and exactly wrong for a refund ceiling that is a fact about somebody's authority.

**The costliest refusal in the batch stops somebody starting work.** Step 383 disables
clock-in when location is unavailable, and the person it stops is paid by the hour and
standing at the door. A disabled clock-in with no route through is an unpaid hour, so the
route is the step: clock in without a location, recorded as missing and flagged for a
supervisor. The row names one location state and there are four that are not a usable fix --
off for the device, denied to this app, no fix yet, and a fix too coarse to place somebody
at a site -- and treating all four as "GPS off" tells somebody in a basement to turn on a
setting that is already on.

**Three rows refuse to refuse the way they were asked to.** Step 386's blocked Next button
becomes a live button whose tap moves focus to the unanswered question, because "physically
blocked" is enforced more completely by a focus move than by a grey rectangle -- and the
grey rectangle does not say why. Step 387's block applies to the submit and never to the
typing or the saving, because a form that refuses everything until every field is perfect
loses the work that took longest. Step 380's sweep removes the two controls that write and
keeps the three that only change what one person is looking at, because a dashboard with no
filters is a poster.

**Five band shapes, three of them new.** Step 395 is collapsed at one end and inverted at
the other -- floor 1s, optimal 1s, ceiling 2s on a refresh interval -- which no previous
band managed, so neither defect can be read as the other one's rounding. Step 384's three
boundary cells are sentences, and its ceiling holds an *argument*: "100% (coverage beyond
100% is not meaningful; further effort has diminishing return)", a cell reasoning with its
reader instead of holding a value. Step 380's three cells hold three different types, a
string, a string with a process condition, and a bare `1`. Step 390 puts the one genuinely
useful thing on the row -- that a false negative (a bad value accepted) is worse than a
false positive (a good value refused) -- inside a parenthesis in a cell that does not parse.
And the familiar shapes recur: two collapsed 1/1/1 bands (383, 391), three mixed-unit bands
(364, 389, 393), and one-valued output columns reaching nine.

**A cell that annotates itself.** Step 389's Best Qualitative Output reads
`Good/Average/Poor -> Best = Good (100%)`: a scale, an arrow, a note naming which value is
best and a percentage gloss, in one cell. A consumer parsing that column for a scale gets a
sentence. The same row freezes marketing spend when "rate" drops below 98% and never says
which rate -- and the metric on the row is a *design-system adherence rate*, so read
literally a budget freezes because somebody shipped a component with the wrong padding.

**Two rows are spliced.** Step 388's Atomic Step builds a finalisation button, its Data
Requirement column describes a glossary screen, and its Setup Step column asks for a
code-splitting regression check: three subjects, one row -- and its five lock data fields
(Lock Type, Locked By, Lock Timestamp, Lock Reason) describe the design the instruction does
not ask for, so a reader who implements only the Atomic Step builds a lock nobody can safely
undo. Step 390 is the same shape with two halves: validation above, and masking salaries,
blocking the clipboard and padlock markers below -- a real requirement that now has no row
of its own.

Numbers worth carrying out of this batch: three duplicated instructions, twelve, ninety and
two hundred rows apart (380, 382, 394). Five reasons an action can be out of bounds, two of
them arithmetic (377). Four location states where the row names one (383). Seven of eight
widgets surviving one failure (393). Seven malformation classes, four invisible on screen
(391). AED 100 split three ways as 3334/3333/3333 fils, against a naive 99.99 (392). Fifty-
nine redraws a minute per card not taken (395).

### The screen you can count, and the screen you can generate

Steps 396-415 begin with the screen as a thing you can count -- an inventory, a transaction
per screen, a scope, a census -- move through the screen as a thing you can generate -- a JSON
layout grammar, a field extraction, an instantiation engine, a recursive tree, a route binding,
a quality gate -- and end in nine tooling rows, four of which ask for rules that have been
blocking merges for four hundred steps.

**Counting is where the disagreements live.** Step 396 asks for an audit of "each screen's
designated user actions" and the word *action* is doing more work than it looks: five screens
carry seven declared actions and twenty-three interactive elements, and the only difference
between a five-screen application that reports seven and one that reports twenty-three is
which noun somebody used. Step 397 then asks for "exactly one atomic, singular system
transaction" per screen -- three words for one rule, doing three different jobs. *Exactly one*
counts. *Atomic* describes how a write fails. *Singular* describes what the screen is about. A
screen can satisfy any one of the three while failing the others, and the overtime approval
screen is the case: one transaction, three writes, and it is right on all three readings. One
screen split; approve and decline stayed together, because they are two answers to one
question and splitting them would satisfy a single-action count while making declining the
longer path.

**The layout engine is a grammar, and grammars are useful for what they refuse.** Step 401
declares six component types, three layout types and four things the schema cannot express:
expressions, raw colour literals, conditionals and imports. Each refusal names what it
protects, and they are not interchangeable -- a raw colour defeats the token rules, an
expression makes the packet a program, an import makes it a fetch, and a conditional would let
a layout place a control the access map hides. Step 403's mapping table is exactly as wide as
that grammar, with no reflection and no generic fallback, so an unmapped type is skipped and
reported rather than rendered as something plausible. Step 404 asks for trees "based on the
AST" and the noun is wrong: there is no source code and no expressions, so it is a parse tree,
and the wrong noun quietly re-opens what Step 401 closed. Three defences bound the walk -- a
depth limit, a node budget and a visited set -- because a cycle exhausts neither of the other
two in any useful time.

**Four rows ask for rules already in force, and three of them are consecutive.** Step 409 asks
for a CSS linter to block hex colours, Step 410 for static analysis rules to reject hardcoded
hex colours, Step 411 for CI/CD to block local custom styling: one instruction, three
vocabularies, three metrics, three rows, and none of the three citing either of the others.
Step 410 is *one row* after Step 409 -- the closest duplicated pair this track has recorded,
against gaps of twelve, ninety and two hundred in the previous batch. Step 412 then asks for
the twenty-line function limit Step 296 set a hundred steps ago and Step 379 already relies
on. None was rebuilt. `RAW_COLOR_LITERAL` and `UNTOKENISED_MATERIAL_COLOR` have been blocking
since Step 4; a second check would be a second answer to one question, and the only thing
worse than a rule nobody enforces is three rules that disagree at the margins.

**Two rows swapped metrics.** Step 409 carries "Function Complexity / Size Limit Compliance"
with a band about lines and cyclomatic complexity, on a row about hex colours. Step 412, three
rows later and about function length, carries a generic step completion rate. Each row holds
the other's metric. The track has recorded wrong metrics before; a metric that is not wrong but
*right for a different row in the same batch* is new, and only reading both rows makes either
legible.

**And one band declines to be a band.** Step 411's floor and ceiling are both the string
"N/A - Binary Governance Gate" and its optimal is a sentence. Every previous band defect in
this track attempted a value -- inverted, collapsed, typeset in LaTeX, annotated with an
argument, holding three different types. This one says the question does not apply, and it is
right: the row describes a binary gate, a binary gate has no band, the honest answer is one
cell, and the sheet has no way to write it. Step 415 then supplies the seventh distinct shape:
a floor of "< 20 ms" and a ceiling of "50 ms" describing the interval twenty to fifty, with an
optimal of "< 2 ms" sitting below both -- a target outside the range its own boundaries define.

Numbers worth carrying out of this batch: seven declared actions against twenty-three
interactive elements (396). Three subjects in one row and five cells belonging to a TLS
hardening row (398). Fourteen string occurrences reduced to nine entries, with two "Save"s kept
apart by context (402). A composite of 93.5 that clears every threshold while one of its four
inputs sits seventeen points short (406). Five calculation lines summing in integer fils to
174,100 (407). Six of seven components on the eight-point rhythm and one exempt with a stated
reason (408). Six rows sharing one metric (389, 401, 403, 405, 406, 407). Nineteen foreign
stacks on the register Step 258 keeps -- CSS at 409, NPM at 411, React Native at 415.

### What the application records, and what you can watch change

Steps 416-435 have two halves that turn out to be one subject. The first ten rows instrument
the person using the application -- how long they hesitate on a field, where they abandon a
form, which screens they struggle with. The last seven put state on the screen that changes
while they are looking at it -- sockets, streaming numbers, clocks, delivery states. Between
them sit three rows about showing a bottleneck to somebody who can do something about it. The
question underneath all twenty is the same: what does a number mean when the person it is
about did not know it was being taken?

**Six rows put the Optimal below both the Floor and the Ceiling, and that settles something.**
Step 415 met this shape last batch and recorded it as new. It is not new and it is not a
defect in one row. On a lower-is-better measure this sheet writes the floor as the acceptable
threshold, the ceiling as the *worst tolerable* value, and the optimal as the aspiration
beneath both -- seven rows across two batches are written that way. Then Steps 432 and 433
close the argument: they measure the same thing, message delivery latency, they share an
optimal of 500ms, and one row apart they use the Ceiling column in **opposite directions** --
"<5s" as the worst value, "<100ms" as the best. After that pair the column cannot be read from
its name at all. The defect has never been in the rows; it is in the headings, and every
latency target in the sheet is being read backwards by somebody.

**Step 417 has no metric.** The Metric Name cell is empty -- the first in four hundred and
seventeen rows -- and the band still reads 0.8, 0.95, 1, to two decimal places, measuring
nothing the row names. Its output column reads "Not Complete / Partial / Complete", the only
row in the track written worst-first, which under the positional convention six other rows
state outright would make failure its best outcome. It does not mean that; what it shows is
that the column is read by position rather than by value, so any row listed in an unusual order
is silently mis-scored.

**Two rows contradict themselves.** Step 432's Atomic Step targets sub-100ms transit under a
band whose optimal is 500ms -- an instruction disagreeing with its own metric by five times,
which the track had not seen. Step 435 says "guarantee mathematically" under a floor of 99.5,
which permits one user in two hundred to be handed the other variant halfway through a task --
the exact failure the instruction exists to prevent. The second is the sharper of the two,
because the guarantee is achievable by construction: a hash of a stable key gives the same
answer every time, on every device, with no storage and no network call. The mechanism is 100
per cent, so the band is what is wrong.

**Three instructions were met without building what they literally asked for.** Step 417 asks
for friction indicators to be "silently logged"; silence as an engineering property -- no
layout shift, no main-thread work -- is built, and silence as secrecy is refused, with every
indicator listed on a disclosure surface. Step 420 asks the gateway to "silently capture the
unique mobile device ID", which neither platform supplies to an ordinary application; an
app-scoped install identifier answers the duplicate-submission question the gateway actually
has, and nothing else. Step 428 asks for hesitation heatmaps, which at coordinate granularity
would put a near-signature into the payload -- which hand holds the phone, how far a tap
overshoots -- so the heatmap is built over fields instead. In all three the requirement
survives and only the mechanism changes. Fifteen rows later Step 420's replacement turns out
to be exactly the assignment key Step 435 needs, which is the argument for making refusals
constructively rather than simply declining.

**Step 417's lower half is about dismissing people.** Its Poka-Yoke, Completion Measures,
Expected Output, Common Library and Decision Group cells all describe a scheduled script that
removes a worker's access when they fall below a threshold, with managers explicitly prevented
from intervening -- on a row whose instruction is about logging friction. It is the fifth
spliced row in the track and the first whose two halves fit together into something coherent,
which is precisely why it is recorded and refused rather than built. Step 416 had already fixed
the unit of analysis at a screen and forbidden attributing an indicator to an individual; that
limit was written for this case, one row before it arrived.

Numbers worth carrying out of this batch: seven declared actions of friction against
twenty-three interactive elements (418's listeners see all of it without wrapping a single
widget). Fourteen occurrences of a mean sitting above its own ninetieth percentile, carried by
one interrupted session (421). The reason-code field found independently by three rows taking
three different routes (421, 423, 424). Eight fields on the telemetry allowlist, none of which
identifies a person (419). Three refusals, each naming its replacement (417, 420, 428). Five
nouns in one batch for one concept -- friction, hesitation, drop-off, bottleneck, complexity
bottleneck (426). Three clocks that do not tick once a second (431). A p99 of 2.4 seconds in
the cold store against a median of 38 milliseconds in the depot office (432).

### Scoring people

Batch P fixed the unit of analysis at a screen and forbade attributing friction to a person.
Steps 436-455 are the rows where that rule cannot apply, because the person is the point:
points, streaks and levels; thanks and recognition; feedback prompts and rating controls;
monthly evaluations, skill quizzes and an escalation timer; a suggestion scheme; and, last, a
projection of somebody's own leave. So Step 436, which defines what "complete" means before
anything can be awarded for it, also writes a four-rule charter for whenever a person is
legitimately the subject: they see their own score and how it was computed; any score can be
contested and a contest pauses its use; no score triggers a consequence without a named
person deciding; and telemetry about how somebody used a screen can never feed a score.
Every later row in the batch binds to it.

**Step 443 has the best cell in the sheet.** Its ceiling reads "<= 50% (gaming-risk
ceiling)": recognition engagement above half is not better but worse, because past that point
thanks is being given because it is counted. It is Goodhart's law written into a band, and it
is the first ceiling in the track used as a true upper bound -- two-sided, with a failure at
each end. After Batch P showed the Ceiling column holding the *worst* value on latency rows,
this row uses it exactly as a ceiling should be used.

**Step 447 fails on a character nobody can see.** Its completion measure reads "\30% user
response rate": a comparison sign lost in export, replaced by the backslash that tried to
carry it, and the same defect sits on another row still in the pool. Read as "at least 30%",
the only sensible reading of a response-rate target, the observed 27% fails; read as "at
most" it would pass. The row reports Fail, and the fix is explicitly not to prompt more --
Step 446 capped prompts at one a week and never after a refusal, and relaxing either would hit
the number and make the prompts worse.

**The slide from game to appraisal is caught twice.** Step 439's instruction says "level" and
its metric says "performance tier"; a level counts completions and ignores the quality,
difficulty and circumstances a rating must weigh, so the card says level. Step 449 asks for
"automated performance distribution tracking" in a manager evaluation tool, which is the
machinery of a forced curve; the distribution is reported to each manager beside the
organisation's and never enforced -- no quota, no rescaling, no curve.

**Some rows get things right, and the track records that too.** Step 438 carries the A - B = 0
metric that Step 435 misapplied, and here it fits: points are a ledger. Step 451 says outright
that worker failures are evidence about the *training video*, the first row in two batches to
point its measurement at the material unprompted. Step 452's band descends correctly and its
best value is the five minutes its instruction names -- the first row in two batches whose
words and numbers agree -- and its cited standard, ITIL, contains the correction to its own
instruction: functional escalation to a colleague who can pick the work up, not hierarchical
escalation to the HR Director every five minutes.

Numbers worth carrying out of this batch: four charter rules (436). Sixty points awarded and
sixty backed by validated completions (438). Forty points written as four overtime
completions (439). Zero points for a thank-you (442). Engagement of 34.7 per cent inside a
two-sided band, with one team of two suppressed (443). An NPS of 14 from fifty anonymous
responses (445). Eleven of twelve ratings "exceeds" against 29 per cent across the
organisation, shown and not corrected (449). One quiz question in four flagged as a bad
question (450). AED 4,700 claimed against AED 1,150 verified (454). And 9.7 days of leave
that will be lost unless booked, said plainly to the person they belong to (455).

### The child's record, and a sheet copying itself

Batch Q wrote a charter for scoring people. Steps 456-475 are about the record those scores
would sit next to: what a service writes down about a child -- speech turned into notes, a
drawing, a sensory map, an assessment plotted against a norm -- and who is allowed near it. The
supporting rows decide how a child is identified (456), how somebody gets back into the
application (457), what each role sees first (471), when a worker can work and where (472, 473),
and which adults may be shown to a family at all (474).

**Twelve of the twenty rows have a twin.** Six pairs inside one batch share a metric and its
three band values: 456 with 471, 457 with 463, 458 with 465, 459 with 466, 460 with 470, 461
with 468. One of those pairs, 458 and 465, shares its Atomic Step *character for character* --
same words, same punctuation, same missing referent, seven rows apart. Another, 459 and 466,
differs by a single digit: "(Step 2)" against "(Step 8)". Two further rows carry bands first
seen in the previous batch. Batch Q recorded, as open decision 90, a suspicion that band blocks
were being pasted onto rows by name; this batch is the evidence. The register lives at Step 458
and both members of every pair are implemented, because skipping one of a pair would make the
count of implemented steps a lie.

**The lost comparison sign is confirmed as a class of defect.** Step 447 read "\30% user
response rate"; Step 462 reads "\95% speech recognition accuracy" -- same column, different
team, fifteen steps apart. Under the intended reading Step 462 fails, and the more useful
finding is underneath it: the test set is 320 utterances of which 200 come from staff whose
first language matches the recogniser's training data and 40 from children with speech and
language differences, who score 97.1 and 84.2 per cent. Dropping the children lifts the
aggregate above 95 immediately, which is the trade an aggregate target invites and the trade
Step 447 refused. They stay, accuracy is reported per cohort, and low-confidence text is marked
unverified rather than stored as something a child said.

**Step 474 is the sharpest band defect in the track.** It puts a floor of 95 per cent on a
check that verifies a support worker's certification before that worker is shown to a family.
Read as the filter's accuracy, a 95 per cent floor is one uncertified adult in twenty reaching
a family's screen -- which is the thing the filter exists to prevent, and which nobody would
sign if it were written in words instead of a percentage. The filter is built as a hard gate
instead: the flag, a verified certificate and an unexpired date, or the person is not shown.
The band's 95 and 99 are re-read as the accuracy of the automated document reader, which is a
thing a percentage can honestly describe, and everything the reader cannot confirm goes to a
person rather than through. "Indisputable" is replaced by a decision that is recorded and
reviewable, with a human override that can only exclude.

**Two rows argue with themselves.** Step 464 instructs a "pulsing red recording indicator" on a
row whose optimal is "100% token compliance, zero raw hex/pixel overrides" -- the first row in
the track whose own words would break its own band; the error colour role is red in both themes
and is a token, so both hold. Step 467 asks for a drawing stroke under 16 ms and offers an
optimal of 50 ms that asserts, in its own parenthesis, that it "matches or exceeds the stated
requirement". It is 3.13 times looser. Step 432 disagreed with its instruction by a factor of
five and said nothing about it; this is the first row to state an agreement its numbers deny.

**Four rows stop at a signature.** Steps 457, 463, 472 and 475 each reach their floor and stop
short of their optimal because the optimal is a formal sign-off from an accountable owner or a
stakeholder. A build can verify acceptance criteria; it cannot sign. The ledger opens at Step
457, carries all four, and closes at Step 475 unsigned -- and one list of four named owners
clears it.

**Some rows arrive already right.** Step 463's expected output names an accessible list
fallback without anybody asking, the second such row after Step 451, and the fallback is built
equal rather than lighter: every place the map draws, the same two actions, one record behind
both. Step 469 asks that tapping any data point open the exact assessment document from that
date, which is Step 441's rule -- every figure carries its working -- arriving as a gesture
instead of as a correction. Its one reliability percentage cannot tell a document that failed
to open from the wrong document opening, so those are counted apart with a wrong-document floor
of zero.

Numbers worth carrying out of this batch: six paired bands over twelve of twenty rows (458).
One character between Step 459 and Step 466. Two columns -- Mistake-Proofing and Self-Chasing
-- holding one sentence each across all twenty rows (466). An aggregate speech accuracy of 94.3
per cent hiding a cohort at 84.2 (462). A norm band drawn from a sample of 2,560 rather than as
a line somebody can be below (468). Zero wrong documents in three source-open attempts (469).
Three module versions inside one child's three-point chart (470). Four role defaults, none of
which ranks anybody (471). Four service areas in place of a coordinate (472). A twenty-second
lag budget where the row said "real-time" (473). Five worked credential records, two displayed
and three excluded (474). And four rows closing unsigned, which is one sentence away from none.

### Shipping it, and what comes back

Steps 476-495 leave the product and follow the release: the build is hardened and obfuscated
(476), an over-the-air channel is integrated (477), the shared component package is published
(478, 482), release gates are configured (479), staging and the store receive the artefact (480,
481), a variant halt rule is written (484), four kinds of alert are built (485-488), and then
the field answers back -- layout regressions (489), sentiment by build (490), a friction
specification (491), a demand heatmap (492) and a continuous improvement roadmap (493). Two
closing rows confirm prerequisites and ask for a signature (494, 495).

**Two bands in this batch hold one value in all three cells.** Step 481's floor, optimal and
ceiling all read "Deployed"; Step 485's all read the same typeset LaTeX fragment. Step 456 had
already collapsed a floor into a ceiling and Step 460 a floor into an optimal; this batch
collapses all three, twice. A band that holds one value is not a measure, it is a condition --
and at Step 481 it is a condition decided by a store reviewer rather than by anybody here, so
four things the team does control are measured instead, including a field-by-field comparison of
the store privacy declaration against the Step 419 telemetry allowlist.

**The Ceiling column acquires a fourth meaning.** Step 476 sets it to 1 on a vulnerability count
whose floor and optimal are both zero, so the band ascends into failure. With the worst value
(418), a true upper bound (443) and the negation of the floor (456), the column now means four
different things, which is why Step 493's roadmap carries "rewrite the ceiling column heading"
as an item with a named owner. Three further rows in this batch -- 486, 487 and 490 -- put a
latency ceiling slower than the floor, the pattern Batch P first recorded.

**Two rows show what a band should look like.** Step 482's three tiers are strictly nested:
manual smoke, then automated smoke plus twenty-four hours of monitoring plus zero critical
regressions, then progressive rollout plus a rollback path that has been tested. Each tier keeps
everything below it and adds one thing, and the ceiling is genuinely better than the optimal.
Step 489's does the same for implementation completeness. Both are on rows about releasing
rather than about the product, which may be a clue about who wrote them.

**Step 479 carries three distinct subjects in three columns.** Its instruction is about release
gate configuration, its metric about Material 3 token conformity, and its Setup Step cell asks
for "the data linkage between training completion metrics and the enterprise promotion
evaluation engine". Eleven rows in this track have carried a spliced half; this is the first
with three subjects at once. The Setup Step cell is recorded verbatim and refused: a score about
a person driving a consequence without a person deciding is what the Step 436 charter forbids.

**Arithmetic that makes a floor unreachable, twice.** Step 458 found that a 95 per cent floor on
a twelve-case suite means 100 per cent. Step 483's 98 per cent floor on a release success rate
needs fifty releases before it can be cleared with any failure in it, so for a team releasing
fortnightly it means no failures at all -- and a team can reach it by releasing more often
rather than by failing less. Step 487's fifteen per cent funnel-drop threshold has the opposite
problem: on a step forty-seven people reach, fifteen per cent is eight people, so the rule fires
every week until a minimum weekly volume is added.

**Where the work happens is where people live.** Step 492 asks for a geo-density heatmap.
At city zoom that is a planning tool; at street zoom it is a list of home addresses drawn as
colour. The aggregation is fixed to the named service areas Step 472 established rather than
clustered dynamically, a cell under five records is not drawn, there is no zoom level below the
area boundary, and nothing is interpolated between cells. Step 490 draws the same line through
a different column: cutting sentiment by build hash asks whether a release made things worse,
and cutting it by acquisition channel produces statements about the people who arrived a
particular way, so the channel cut stays aggregate with a minimum cohort of twenty-five.

**Step 495 is Step 475 character for character.** Eight cells identical, twenty rows apart,
across a batch boundary -- the second instruction-identical pair in the track after Steps 458
and 465, and the first to cross batches. The duplicate register opened at Step 458 therefore has
to span batches. So does the signature ledger: Step 475 closed with four rows awaiting a named
accountable owner and the remark that one list would clear them. Nobody was named, so Step 495
is the fifth.

Numbers worth carrying out of this batch: a ceiling of one vulnerability (476). An adoption rate
of 0.83 that says more about a four-on-four-off rota than about an SDK (477). Three rows sharing
the SemVer band and all three of its defects (478). Four gate settings, one of them waivable,
by a named role (479). A repeated word -- "a staging environment environment" -- and the first
cell in 480 rows to admit that nothing matched (480). A rollback rehearsed and timed at 214
seconds (482). A change-failure rate of 25 per cent over four releases (483). Five hundred
sessions per arm before a variant is judged on performance, and one occurrence before it is
judged on being broken (484). Sixty-five minutes as sixty plus five, said out loud (485). One
message from forty retries (486). Nineteen hundred people on the step that fired and forty-seven
on the step that did not (487). Body text held at 4.5:1 where the band offered 3:1 (488). Four
golden-layout comparisons across three breakpoints (489). A sentiment cell holding three people,
suppressed and shown as suppressed (490). Six nouns now in use for a place where people stop
(491). Three of four heatmap cells drawn (492). A closure rate of 0.75 on a backlog whose every
item cites the step that raised it (493). Six output vocabularies across 494 rows (494). And a
signature ledger that reopens at five.

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
7. **Cold start on a handset** (Step 165). Five of the verification's eight checks run on a CI
   host; three need a profile-mode build on the declared floor device. Step 165 reports 0.625 --
   below its own floor of 0.8 -- rather than a green number a release decision would rest on.
8. **No crash reporter is wired** (Step 159). The capture filter is built against
   `HabotCrashReporter`, an interface with no implementation, so the absence is a compile-time
   obstacle. Choosing a vendor is a decision about what may be attached to a report, not an
   integration task.
9. **The OpenAPI document itself** (Step 173). Authored and served by whoever owns the endpoints;
   a copy here would be a second source of truth and would drift within a release. What this repo
   declares is the set of endpoints the app calls, so the two can be joined.
10. **The tokenisation milestone is Fail** (Step 181), and deliberately. It is a binary governance
    gate with no partial credit; five of its eight criteria hold and three do not -- the palette is
    still `PROVISIONAL`, the body type face is Roboto where the spec asks for Inter, and "NPM Token
    Integration" has no meaning in a Flutter app. A sign-off that passed because the work leading
    to it was substantial would not be a gate.
11. **Inter is not vendored** (Step 182). The spec asks for it; the tokens are bound to Roboto.
    Renaming the family without shipping the font produces a per-device platform fallback and
    silently invalidates Step 102's text-fit audit, Step 138's expansion factor, Step 144's button
    budget and Step 167's column widths. Four preconditions are recorded on the binding.
12. **No `success` colour role** (Step 190). MD3 does not specify one. `tertiary` carries it today
    because `tertiary` happens to be unused, which is a coincidence rather than a design; a proper
    role set is requested through the Step 177 brand-extension mechanism and needs the palette
    signed off first.
13. **The poka-yoke scanner still holds its own patterns** (Step 179). The catalogue deliberately
    does not duplicate them -- two copies, only one executed, is drift by construction -- so the
    gate asserts the two id sets match until the scanner is migrated to consume the catalogue the
    way `a11y_rules_test.dart` already consumes `HabotA11yRules`.
14. **`onSurfaceVariant` on `surfaceContainer` belongs in `ContrastAudit`** (Step 191). Measured
    and passing at AAA, but that gate is what every earlier step's evidence rests on, so the pair
    is raised rather than added through a styling row.

15. **The log scrubber has no PAN rule** (Step 207). A sixteen-digit card number is redacted by
    the `hex` rule, which matches sixteen or more hexadecimal characters -- decimal digits are
    hexadecimal characters -- so the coverage is real and accidental. A fifteen-digit American
    Express number is one character short of it, and a PAN with spaces or dashes matches nothing.
    The rule belongs in `resilience/log_scrubber.dart`, which Step 68 owns; the regular expression
    and its four test vectors are declared in `payments/card_form_contract.dart` as a proposal.
    The contract means no PAN should reach a log at all; this is the layer that assumes one did.
16. **Card brand artwork** (Step 208). Brand marks are trademarks and a redrawn approximation is
    a legal problem and a recognition problem at once. Each asset key points at artwork from that
    network's own brand kit; supplying those files is a delivery dependency, not a code task.
17. **Single-use enforcement at the door** (Step 209). The pass payload rotates, so a forwarded
    screenshot expires. Rotation bounds the exposure; it does not make the pass single-use, and
    within the validity window a photograph works as well as the phone it came from. Single use
    is the scanner's job and needs the venue side to agree to it.
18. **Business days are not durations** (Steps 214-215). The dispute cycle-time floor and ceiling
    are "<5 business days" and "<10 business days", which is seven to nine calendar days depending
    on when it starts, and the weekend is not the same two days for every counterparty in this
    market. They are held as business-day counts with the calendar left to whoever owns it.
19. **The add-on ranking is an election** (Step 203). A cap of three over a catalogue of seven
    decides which three get every attachment, and the attach rate then measures the ordering
    rather than the catalogue. The ordering is declared and stable, but who sets `operatorPriority`
    -- and on what evidence -- is an operations decision this repo cannot make.

20. **The 600dp and 744dp boundaries disagree** (Step 216). MD3 puts the compact/medium
    boundary at 600dp; the repository's navigation collapse sits at 768dp and the expanded rail
    guidance implies 744dp. Only one declared device -- the iPad Mini -- falls in the conflict
    band, so nothing is broken today and the ladder is declared with both numbers visible rather
    than one of them quietly winning.
21. **Who owns the API latency SLA** (Step 235). `apiLatencySla` is 200ms at the 95th percentile,
    server-side, excluding the network. The client can measure it and cannot meet it, so the
    obligation recorded here is to report honestly. The owner is on the other side of the
    contract, and no owner has signed any of the three budgets.
22. **Nothing alerts on the SLAs yet** (Step 235). GEN-05452 -- "create an automated performance
    alert subroutine flagging UI components that breach targets" -- is the row that acts on these
    figures. It is in the remaining pool and not in this batch, so the record exists and the
    alerting does not.
23. **The Step 63 chunk controller has no eviction policy** (Step 232). It keeps every chunk it
    has loaded for the life of the list, and it is the one retained memory source with no
    declared bound. Raised rather than changed: eviction is Step 63's decision, and a chunk
    evicted while the user is scrolling back through it is a worse bug than the memory it saves.

24. **The corrected mask binding is not wired in** (Steps 238, 241, 250). Three declared fields
    carry a mask that filters out a character their own pattern requires, so they cannot be typed
    into a state their validator accepts. `HabotMaskBinding.correctedFormattersFor` fixes it and is
    gated. Adopting it means changing one line in `ValidatedInputField`, which is BPTR-0160's file
    and carries its own gates, and no host in this track has a Dart toolchain to re-run them. The
    correction is ready; somebody with a toolchain should make the edit and run the suite.
25. **Two of the thirteen field rules are jurisdictional and neither says so** (Steps 236, 244).
    `dateUs` is a US date ordering that no surface uses, and the phone rule's placeholder is a
    Kenyan dialling code, in an application whose money is AED. One of them is wrong, or the
    application is multi-market and neither should be a constant in a field rule.
26. **The error templates say every category is retryable** (Step 251). Templates are keyed by
    error category and retryability depends on the situation, so a 200 with a failure in its body
    — which maps onto `unknown` — offers a retry button that reproduces the failure exactly.
    Whether `retryable` belongs on a template at all is a decision, not a patch.
27. **The reconciliation assumes one currency** (Step 253). Two numerically equal amounts in
    different currencies balance and are wrong, and the subtraction cannot see it. Sound while
    every amount is AED; written down now rather than discovered by the first multi-currency order.
28. **No cipher ships in `lib/`** (Steps 122, 271). `HabotEncryptedStore` requires a `HabotCipher`
    and declares no default, because the platform keystore is behind a plugin this environment
    cannot resolve. Until somebody supplies one, an encryption health badge cannot honestly render
    anything but failed -- which is what Step 271 reports.
29. **The log scrubber intercepts three of eleven personal contact strings** (Step 268), and two
    of those three by accident. Four proposed rules reach nine of eleven with no false positives
    and are gated here, not merged: `log_scrubber.dart` belongs to an earlier step and carries its
    own gates, and no host in this track has a toolchain to re-run them. Same shape as decision 24.
30. **There are no bundled assets at all** (Step 263). `assets:` is commented out in
    `pubspec.yaml`, there is no `assets/` directory, and the compression row therefore has an
    empty population. Somebody should decide whether that is intended -- and if it is, the row is
    not measurable until it changes.
31. **`lib/screens` does not exist and routing has no single entry point** (Steps 257, 258). Five
    routes are served by one adaptive shell across four Dart declarations. The pane architecture
    looks deliberate; it is not written down anywhere, so the next person to read the sheet will
    find the folder missing and create it. The convention a screens folder would need is recorded
    at Step 257 against that day.
32. **Three consent clauses need an owner** (Step 270): the deletion schedule for data collected
    under a withdrawn consent, the identity standard for digital signatures -- a drawn signature
    identifies nobody -- and who owns the decision. No placeholder owner was invented, because a
    decision record with an invented owner is one nobody checks.
33. **A terminal state has no slot in either vocabulary** (Steps 272, 281). `HabotErrorCategory`
    has nine members and every one describes something that went wrong on the way to an outcome;
    `HabotSurfaceIntent` has four and every one assumes the flow continues. A hard stop is neither.
    Two rows reached the same hole from different directions; adding a terminal kind to both
    touches gated files from earlier steps, so it is recorded rather than done quietly.
34. **Two bands for the haptic delay metric** (Step 283). 100/50/16 ms was declared earlier;
    GEN-00854 says 10/2/16 ms for the same interval. Only the ceiling matches. Somebody should
    pick one, and the 2 ms optimal is not reachable across a platform channel.
35. **Nothing can read the OS haptic setting** (Step 283). Flutter exposes no API for it, so a
    person who turned haptics off at the system level still gets them until they find the in-app
    switch. Either the in-app default flips to off, or a plugin that can read the platform setting
    is added. Both have a cost; neither is free to keep deferring.
36. **Two rows disagree about the WCAG AA touch-target figure** (Steps 276, 285). 44px against
    24x24px, same standard, same batch. SC 2.5.8 (AA) is 24 and SC 2.5.5 (AAA) is 44, so Step 285
    is correct -- but the sheet now contains both and somebody will read the wrong one.
37. **A referral code nobody owns** (Step 289). It is on the confirmation screen, nothing reads
    it, and no other surface has a place for it. Stripping it from the screen would delete it, so
    it is reported instead: either something should consume it, or it should be removed
    deliberately.

38. **An eleventh poka-yoke rule is specified and switched off** (Step 304). `HARDCODED_HELP_TEXT`
    has its id, its four matched parameters and its three exempt paths declared in
    `help_text_registry.dart`. The guard file it belongs in is gated by an earlier step, so
    enabling it edits work already signed off. Somebody should turn it on deliberately.

39. **Steps 298 and 313 disagree about which WCAG criterion says 44dp** (this batch), and Step 227
    had already resolved it. 2.5.8 is 24x24 at AA, 2.5.5 is 44x44 at AAA, and this project
    enforces 48. The sheet now carries both readings; the resolution lives in the code.

40. **Two control classes are outside the touch-target guard** (Step 313): a chip sized to a
    translated label, and an inline link sized by the text scale. A widget test at the audited
    scales is what would cover them, and it does not exist yet.

41. **Two measurements cannot be taken from this repository** (Steps 299, 308). The splash
    animation's frame metrics need a platform-side trace in the host project, on a physical device
    in a release build. Icon recognition accuracy needs an ISO 9186-1 comprehension test with
    people. Both are specified in their gate files; neither is work a build host can do.

42. **Four latency bands in the sheet are inverted** (Steps 325, 326, 334, 335): the ceiling is a
    worse value than the floor on a lower-is-better measure. Step 333's equivalent band is ordered
    correctly, which is why these are four cell-level errors rather than a house convention, and
    why the sheet cannot be read by convention at all. Worth correcting at source before anything
    downstream consumes the bands numerically.

43. **Four Best Qualitative Output columns hold a single value** (Steps 321, 322, 334, 335): they
    read "Pass" with no failing value, so a row scored on them reports Pass whether it passed or
    not. Each is recorded in its gate file and in the evidence; none is gated, because there is
    nothing to gate against.

44. **Two of Step 327's eight acceptance criteria cannot be confirmed from `lib/`**: the screen
    reader's announcement of a masked field needs a handset, and the platform's own secure-entry
    flag needs to be observed under screen recording. Until both are taken, the row reports Fail
    at 75% against a 95% floor, which is the honest reading rather than a blocked one.

45. **A row that fails its own floor** (Step 338). The Atomic Step asks for a snap animation under
    150ms; the band that scores it sets a floor of 100ms. Built exactly to specification the row
    misses its own floor by 49 per cent, so it cannot be satisfied and scored at the same time.
    First contradiction in this track between a row's instruction and its own boundary; worth
    correcting at source before anything downstream reads either number.

46. **Five gesture rows specify no single-pointer alternative** (Steps 336, 337, 339, 340, 343).
    SC 2.5.1 Pointer Gestures is Level A and SC 2.5.7 Dragging Movements is AA. The alternatives
    are built here and `A11Y_GESTURE_WITHOUT_ALTERNATIVE` now enforces them, but the rows
    themselves name only the gesture, and a future row written the same way will ship without one.

47. **The inverted-band and one-valued-column counts did not close** (Steps 338, 351). Batch K
    recorded both as closed for that batch; two consecutive batches carrying the same two defects
    makes six inverted bands and five one-valued output columns across the track, and makes them a
    property of the sheet rather than incidents in particular cells.

48. **Two of Step 349's three completion criteria are undefined, not merely unmeasured.** A
    mobile onboarding completion rate needs a cohort and a window; an average application duration
    needs a decision about when the clock starts and whether abandonment counts. Neither definition
    appears anywhere in the sheet, so the row reports Fail on absence rather than shortfall.

49. **The inverted refresh-latency band is a template** (Steps 358, 362, 374, 375, with 163 and
    175). Six rows carry the identical three cells -- floor `<1 hour`, optimal `<5 minutes`,
    ceiling `<24 hours` -- with the ceiling twenty-four times the floor on a lower-is-better
    measure. Open decision 47 asked whether the inverted bands were incidents or a property of the
    sheet; six identical copies of one cell settles it. The tokenised constants already carry the
    correct reading; the sheet still does not.

50. **A second band false on its own terms** (Step 370). Floor 0.9, optimal 1, ceiling **0.98**:
    the value the row calls best sits outside the range the row calls attainable. Step 312 carried
    the same shape fifty-eight rows earlier with a gap twenty times smaller. Two occurrences with
    nothing linking them makes it a class rather than a typo.

51. **Two band cells are LaTeX, not numbers** (Steps 356, 365). All six boundary cells across the
    two rows hold `$60\text{ fps}$` in math mode, and none parses as a number. Two rows in one
    batch points at the pipeline that produced the sheet rather than at a keystroke. The first
    *encoding* defect this track has recorded; worth correcting at source before anything reads
    the bands numerically.

52. **Two more band shapes with no honest reading** (Steps 367, 368). Step 367 joins a coverage
    percentage and a latency with a slash in every boundary cell, so a reading can satisfy half a
    boundary and the cell cannot say which verdict wins; split apart, both halves are well formed.
    Step 368's optimal is the range `"0-1"` with a ceiling of 1 inside it, so three cells hold two
    distinct positions.

53. **The generator-miss cell is a template too** (Steps 347, 369). Both rows carry the identical
    "No matched reference row in Setup Implementation master list ... verify manually" text where a
    data requirement belongs. It is the most useful cell on either row and it is still an absence;
    what closes it is the source rows, not a build.

54. **One-valued output columns reach seven** (Steps 370, 371, after 321, 322, 334, 335, 351). Two
    more Best Qualitative Output cells hold a single value -- "High" and "Pass" -- so a row scored
    on either reports success whether it succeeded or not. Recorded, not gated: there is nothing to
    gate against.

55. **Four rows are scored on a metric belonging to another subject** (Steps 360, 363, 366, 375):
    an RBAC enforcement rate on a counting tile, Largest Contentful Paint on a row cap, an SRE
    alert-coverage measure on a chart, and a dashboard refresh latency on a package. Three of the
    batch's citations are Google Core Web Vitals (344, 363, 369) in an application with no DOM.
    What each metric points at is usually real; none of them is what the row builds.

56. **Nothing pushes** (Steps 331, 371, 373). Three rows now ask a dashboard to tell somebody
    something promptly -- a real-time counter, a warning indicator scored on Mean Time to Detect,
    and an anomaly surface that should display "instantly". A pull surface shortens only the
    interval after a person looks. No row in the pool asks for the notification that would close
    the first part, so the honest claim for all three is readability on arrival.

57. **Step 357 reports Fail, and the reason is vocabulary.** "Verified" on that row means four
    different checks performed by four different actors. The worked payroll run holds three of the
    four, so the badge is refused rather than shown on a partial. Deciding which of the four the
    badge is allowed to assert is a product decision this repository cannot make.

58. **Three rows ask for work the repository already contains** (Steps 380, 382, 394). Step
    380 repeats Step 368's read-only dashboard instruction; Step 382 disables the release
    control Step 292 disables, under a second condition and a second name; Step 394 repeats
    Step 194's `isLoading = true`. None of the three cites the row it repeats. Previous
    repeats in this track were duplicated defects; these are duplicated work, and whoever
    owns the sheet is the only person who can collapse them.

59. **A band that is collapsed and inverted at once** (Step 395). Floor 1s, optimal 1s,
    ceiling 2s on a refresh interval: the floor equals the optimal and the ceiling is the
    worst of the three. Every previous inversion had three distinct values and every previous
    collapse was flat, so this is the first cell group where neither defect can be read as
    the other one's rounding.

60. **Boundary cells that are sentences, arguments and annotations** (Steps 384, 389, 390).
    Step 384's three cells are prose and its ceiling contains a justification for itself;
    Step 389's output cell holds a scale, an arrow and a gloss; Step 390's ceiling hides the
    row's one useful statement -- zero false negatives -- inside a parenthesis. None of the
    seven cells parses as a value. This is now a class alongside the LaTeX-encoded bands of
    Steps 356 and 365.

61. **Two rows describe more than one feature** (Steps 388, 390). Step 388 spans a
    finalisation button, a glossary screen and a code-splitting check across three columns;
    Step 390's lower half describes masked fields, a blocked clipboard and padlock markers
    -- a real requirement, now with no row of its own. Worth splitting at source before the
    second feature is lost.

62. **One metric scores two unrelated rows five apart** (Steps 387, 392). An automated
    pull-request rejection rate, identical in name and band, on a row about blocking somebody
    in a form and a row about floating-point arithmetic. Neither subject is a pull request.

63. **The generator-miss sentence now decorates a populated cell** (Step 376, after 347 and
    369). Five real data fields, then "No matched reference row in Setup Implementation
    master list ... verify manually" appended after a double pipe. Third occurrence, first
    hybrid -- which means a cell that looks filled in can still be reporting that nothing was
    found.

64. **One-valued output columns reach nine** (Steps 383, 389, 395, after 321, 322, 334, 335,
    351, 370, 371). Three in one batch of twenty is a higher rate than any earlier batch. A
    column with one value reports success whether or not anything succeeded.

65. **A usability metric on a safety interlock runs backwards** (Step 381). A task success
    rate asks whether people complete what they set out to do; an interlock exists so that
    some attempts do not. A lock working perfectly lowers the score, so the row cannot be
    scored honestly against its own metric.

66. **The clock-in refusal needs a supervisor workflow that does not exist here** (Step 383).
    The manual clock-in is flagged, which is the right client-side behaviour and is only half
    the answer: somebody has to see the flag and resolve it, and no row in the pool builds
    that queue. Until it exists, the flag is a record rather than a route.

67. **Three rows ask for one colour lint, consecutively** (Steps 409, 410, 411). Three
    vocabularies, three metrics, no cross-references, and one instruction. Step 410 is one row
    after Step 409, the closest duplicated pair in the track. Step 410's wording is the best of
    the three -- "static analysis" is what a Dart project has, and "flag and reject"
    distinguishes advisory from blocking -- and is worth keeping if the three are ever
    collapsed, because the usual outcome of a duplicate is that the first one wins.

68. **Steps 409 and 412 have swapped metrics.** Each carries a band that belongs to the other.
    This is a failure mode the track has not recorded: a metric that is not merely wrong for
    its row but correct for a different row three rows away. Both rows are gated against what
    they actually ask for, with the swap recorded; the sheet needs the two cells exchanged.

69. **A band that declines to be a band** (Step 411). Floor and ceiling both "N/A - Binary
    Governance Gate", optimal a sentence. The row is right that a binary gate has no band. The
    sheet has no way to express a one-cell measure, which is the thing to fix -- every gate row
    after this one will hit it.

70. **An optimal outside its own boundaries** (Step 415). Floor "< 20 ms", ceiling "50 ms",
    optimal "< 2 ms". Two cells are inequalities and the third is not. Separately, there is no
    run-time import cost in a compiled Dart binary to measure at all, so the metric names a
    quantity that does not exist; the import count, the unused count and the first-frame budget
    are published in its place.

71. **Six rows share one metric** (Steps 389, 401, 403, 405, 406, 407). "UI Design-System
    Adherence Rate" with the same mixed-unit band appears across a JSON grammar, an
    instantiation engine, a route binding, a quality gate and a calculation disclosure. A metric
    that fits six subjects is measuring none of them.

72. **The most spliced row in the track** (Step 398). Three subjects in one row -- counting
    screens, TLS 1.3 hardening at the edge, and a SmartKeyboardField component -- with five
    cells belonging outright to the TLS row. Steps 388 and 390 each joined two subjects. There
    is a real TLS requirement in those five cells that now has no row of its own.

73. **Two rows name a subject with no antecedent** (Steps 398 and 406). "The count" and
    "score" are used as though defined, and neither row says of what. Both readings are stated
    as assumptions in the gate files rather than presented as the meaning; both need a word
    adding at source.

74. **Seven rows across two batches ask for work the repository already contains** (Steps 380,
    382, 394, 409, 410, 411, 412). The rate is rising: three in the previous twenty, four in
    this twenty, three of those four consecutive. Worth a de-duplication pass over the
    remaining pool before it grows further.


75. **The Ceiling Boundary column has no fixed meaning** (Steps 415, 418, 421, 425, 431, 432,
    434 against Step 433). Seven rows use it as the worst tolerable value on a lower-is-better
    measure; one uses it as the best. Steps 432 and 433 are one row apart, measure the same
    thing and share an optimal, and point opposite ways. This is the largest single correction
    the sheet needs: either the column is renamed on duration rows, or the seven rows are
    rewritten. Until then every latency target is ambiguous.

76. **Step 417 has no metric name at all.** The cell is empty and the band is not. First in
    four hundred and seventeen rows. A substituted metric is used and named as substituted in
    the gate file; the sheet needs the cell filled.

77. **Step 417's output column is written worst-first**, the only row in the track. Under the
    positional convention six rows state outright, it declares failure to be its best outcome.
    Worth fixing at source, and worth checking every other row for order rather than content.

78. **Step 432's instruction and its own band disagree by five times.** Sub-100ms in the Atomic
    Step, 500ms in the optimal, with nothing to say which is the requirement. Both are
    published; the sheet needs one of them changed.

79. **Step 435 promises a guarantee under a floor of 99.5.** The guarantee is achievable by
    construction, so the band is the error and the honest band is one cell -- the second such
    row after Step 411's binary gate. The sheet still cannot express a one-cell measure.

80. **Step 430's ceiling is the longest band cell in the track** and holds a semicolon and two
    clauses of argument; its floor joins two criteria with an oblique that could be "and" or
    "or". Read as "and" here and recorded as a choice. Both cells need rewriting.

81. **Step 417's lower half describes automatic dismissal of low performers.** Five cells from
    another row entirely, on a row about friction logging. Recorded and refused. The real
    requirement in those cells -- whatever workflow they belong to -- has no row of its own, and
    if it is genuinely wanted it needs one, with the people affected named in it.

82. **Four more spliced rows** (416, 417, 423, 429), bringing the track to seven. Step 429's
    lower half is a complete CORS specification requirement with no row of its own.

83. **"Silently" is used twice in this batch to mean two different things** (417, 420). The
    engineering sense is a real requirement; the secrecy sense is not something the sheet should
    be asking for in an application used by employees. Worth a wording pass across the remaining
    pool for the same word.


84. **Export has dropped comparison signs** (Step 447, GEN-04935). "\30%" and "\95%" where a
    greater-than-or-equal sign belonged. On Step 447 the missing character decides whether the
    row passes. Worth a scan of every cell for a backslash before a digit, and a fix at export.

85. **A scoring charter is now in force** (Step 436). Any future row that scores a person binds
    to its four rules. If the organisation wants different rules, that is a decision for a
    named owner, not something a later row should quietly override.

86. **Step 439 relabels a level as a performance tier; Step 441 serves a "performance
    scorecard".** The word is kept where it is honest and refused where it is not. Worth a
    wording decision before gamification and appraisal share a data model.

87. **Step 449's distribution tracking must stay a report.** If anybody later asks for quotas
    per rating band or automatic rescaling, it is a forced curve and needs an explicit policy
    decision with the people affected consulted.

88. **The reward for an adopted improvement is undecided** (Step 453). Peer thanks is worth
    zero points (Step 442); rewarding suggestions is a separate decision with an owner named.
    Step 453 reports Partial until a stakeholder confirms its four open questions.

89. **Two rows design one rating control two ways** (Steps 444 and 447): a labelled slider and a
    row of stars. One needs to win.

90. **Step 446 repeats Step 430's band character for character**, and Steps 450 and 454 share
    theirs. Blocks are being pasted onto rows by name ("substep", "design the approach"); the
    remaining pool should be checked for more.



91. **The Completion Measures column has lost comparison signs in at least two places** (Steps
    447 and 462). This is now a confirmed class of defect rather than a one-off. Every cell in
    that column should be scanned for a backslash before a digit and fixed at export, before
    any row carrying one is scored.

92. **Six metric-and-band pairs sit inside one batch of twenty** (456/471, 457/463, 458/465,
    459/466, 460/470, 461/468), one of them sharing its Atomic Step character for character and
    another differing by a single digit. The remaining 839 rows need the same check: where two
    rows are indistinguishable, either one should be removed or they should be told apart.

93. **Four rows top out at a human signature and nobody is named** (457, 463, 472, 475). A list
    of accountable owners against those four rows turns four Partials into four Completes with
    no code changing. This is the single highest-value item in this batch.

94. **Step 474 puts a statistical floor on a safeguarding check.** A 95 per cent floor on
    credential verification, read as the filter's accuracy, permits one uncertified adult in
    twenty. The filter is built as a hard gate and the percentages re-read as reader accuracy,
    but the band itself needs rewriting before anybody signs it.

95. **Three abbreviations are used and never expanded** (ZII at 453, LSA at 472, DCYN at 474).
    DCYN gates who is shown to a family, so what it stands for is not a documentation
    nicety. Each is recorded with a named confirmer and none is guessed at.

96. **The Mistake-Proofing and Self-Chasing columns are one sentence each across all twenty
    rows** (466), promising a CI/CD block and a thirty-second rollback that cannot apply to
    rows whose subject is an ordinal into a list the sheet does not contain. Either the columns
    should say something per row or they should be dropped.

97. **Two rows name two registries each** (460 and 470): @Universal-Library/... in the Atomic
    Step and @habot/shared-library in the Common Library column. Both names are recorded and
    neither is chosen over the other; where these modules actually publish is a decision for
    the owner of the registries.


98. **The Ceiling column now means four different things** (418, 443, 456, 476): the worst
    tolerated value, a true upper bound, the negation of the floor, and a quantity of harm. One
    proposal covering all four readings is the item Step 493's roadmap is holding open.

99. **Three bands hold one value in all their cells** (456, 460, 481, 485). A band that cannot
    distinguish success from failure is a heading, not a measure. These four rows need bands
    written, or the column dropped for them.

100. **Percentage floors on small populations** (458, 483, 487). A 98 per cent release floor
     needs fifty releases; a fifteen per cent funnel threshold needs a minimum weekly volume.
     Every percentage band in the remaining pool should be checked against the size of the thing
     it divides.

101. **Step 479's Setup Step cell asks for training completion to feed a promotion engine.**
     Recorded verbatim and refused. If the organisation wants training to inform promotion, that
     is a decision with a named owner and the people affected consulted, not a data linkage.

102. **Two registries are still named on every packaging row** (460, 470, 478). Three rows now.
     Where @Universal-Library actually publishes is one sentence from somebody who knows.

103. **The signature ledger is five rows and spans two batches** (457, 463, 472, 475, 495). The
     remedy has not changed: a list of named accountable owners.

104. **The duplicate register has to span batches** (458/465 inside one; 475/495 across two).
     Any de-duplication pass over the remaining 819 rows has to compare against what is already
     implemented, not only within a batch.

Closed since Steps 1-20: the double-tap-correction telemetry TTMAC-014 was Partial for is
now built (Steps 34-35). The rate is computed from recorded interactions; the production
reading still needs a release.

Half-closed: open decision 2. Step 230 delivers the tap responsiveness RCGLA-012 was after, via
`touch-action: manipulation`. The zoom suppression it asked for stays refused.

See the [workspace README](../README.md) for team conventions.
