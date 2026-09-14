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
./tool/verify_aiss.sh          # format, analyze, poka-yoke guard, 1,520 AISS gates, evidence roll-up
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

**1,520 gates across 235 steps.** 222 steps Complete, RCGLA-012 Partial (2 deferred: zoom lock,
CLS), IS38-SGTIM-018 Partial (1 deferred: physical-device feel), GEN-04363 Partial (1 deferred:
displayLarge at 200% on a 320dp screen), GEN-03171 Partial (3 deferred: cold start on a handset),
GEN-00291 Partial (the palette is provisional), GEN-02852 Partial (no SwiftUI target),
GEN-00599 **Not Complete** (Inter is not vendored), GEN-04275 **Fail** (the tokenisation
milestone, deliberately -- see Open decisions), GEN-01242 Partial (1 deferred: the log scrubber
has no PAN rule), GEN-04187 Partial (habot-web cannot be inspected from here), GEN-01771
**Not Complete** (a portrait lock would fail WCAG 1.3.4), GEN-05441 Partial (no owner sign-off
is obtainable from a build host), SSTLA-004 awaiting a reviewer score.

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

Closed since Steps 1-20: the double-tap-correction telemetry TTMAC-014 was Partial for is
now built (Steps 34-35). The rate is computed from recorded interactions; the production
reading still needs a release.

Half-closed: open decision 2. Step 230 delivers the tap responsiveness RCGLA-012 was after, via
`touch-action: manipulation`. The zoom suppression it asked for stays refused.

See the [workspace README](../README.md) for team conventions.
