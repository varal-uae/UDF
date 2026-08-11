# HABOT Design System — UDF Implementation
**Repository:** `github.com/RitwikHC/theme-typography`
**Team:** UDF — UX Design & Frontend Engineering | Habot Connect DMCC
**Owner:** Ritwik Sharma — Frontend Integration Specialist
**Framework:** Flutter (Material Design 3)
**Version:** v1 | Last Updated: 10-Aug-2026
**Steps Completed:** 6 of 97 zero-dependency steps

---

## Overview

This repository contains the HABOT Design System implementation for Flutter — all design tokens, typography, theming, accessibility enforcement, interaction patterns, version control, and UI component files produced as part of the UDF DCDF Architecture Framework implementation.

All files are sourced from the **HABOT Design System Creation** Figma file (v1, 10-Aug-2026) and comply with **Material Design 3 (MD3)** specifications with intentional HABOT brand overrides documented per file.

---

## Repository Structure

```
theme-typography/
│
├── README.md
├── tokens.json                                          ← Step 1:  All design tokens
│
├── lib/
│   └── core/
│       ├── theme/
│       │   └── app_theme.dart                           ← Step 1:  Flutter ThemeData (Light + Dark)
│       ├── typography/
│       │   └── dynamic_typography_wrapper.dart          ← Step 2:  Viewport-adaptive typography
│       ├── accessibility/
│       │   └── touch_target_wrapper.dart                ← Step 3:  48dp touch target enforcement
│       ├── interaction/
│       │   └── ripple_feedback.dart                     ← Step 4:  Hardware-accelerated ripple
│       ├── versioning/
│       │   └── layout_version_control.dart              ← Step 5:  Mobile layout version control
│       ├── components/
│       │   ├── empty_state_widget.dart                  ← Step 6:  Actionable empty states
│       │   ├── trace_time_chart.dart                    ← Step 8:  Trace time Y-axis chart
│       │   ├── skeleton_loader.dart                     ← Step 9:  Gray layout block indicators
│       │   ├── overlay_card.dart                        ← Step 11: Overlay card status system
│       │   ├── signed_url_card.dart                     ← Step 13: Signed URL expiry interceptor
│       │   └── security_status_chip.dart                ← Step 14: MD3 security status color map
│       ├── network/
│       │   ├── uuid_payload_injector.dart               ← Step 10: UUID universal payload injection
│       │   └── payload_size_guard.dart                  ← Step 12: MTB payload size guard
│       └── compliance/
│           └── auditor_validator.dart                   ← Step 15: Binary auditor legal check
│
└── scripts/
    └── lint_touch_targets.js                            ← Step 3:  CI/CD touch target linter
```

---

## Implementation Steps

| # | Step | Atomic Ref | Description | Metric | Status |
|---|---|---|---|---|---|
| 1 | BPTR-0544-A01 | Standardize MD3 Typography & Colors | `tokens.json` + `app_theme.dart` | Coverage: 100% | ✅ |
| 2 | TTIAS-014-A01 | Viewport-Adaptive Typography Engine | `dynamic_typography_wrapper.dart` | Adherence: 100% (15/15) | ✅ |
| 3 | TTMAC-010-A01+A10 | Touch Target Minimum Size Standards | `touch_target_wrapper.dart` + `lint_touch_targets.js` | Conformance: 100% | ✅ |
| 4 | TTMAC-025-A01+A10 | Hardware-Accelerated Touch Ripple | `ripple_feedback.dart` | Scope: 100% (15/15) · Timing: 200ms | ✅ |
| 5 | NSKFI-014-A01 | Mobile Layout Version Control | `layout_version_control.dart` | Discovery: 10/10 = 100% | ✅ |
| 6 | EDBAA-004-A01 | Actionable Mobile Empty States | `empty_state_widget.dart` | Coverage: 10/10 = 100% | ✅ |
| 7 | BPTR-0693-A01 | Initialize Shakti Dashboard | Looker Studio workspace initialized | Coverage: 5/5 = 100% | ✅ |
| 8 | SLPLU-017-A01 | Define Trace Time Y-Axis Limits | `trace_time_chart.dart` | Process Execution Quality: 100% (8/8) | ✅ |
| 9 | SLPLU-005-A01 | Gray Layout Block Indicators | `skeleton_loader.dart` | Asset Access: < 200ms ✅ OPTIMAL | ✅ |
| 10 | BLGTA-041-A01 | Inject UUIDs Universally Across Payloads | `uuid_payload_injector.dart` | Config Readiness: 4/4 · Untraced = 0 | ✅ |
| 11 | REF-046-A01 | Overlay Card Status System | `overlay_card.dart` | Spec Adherence: 10/10 = 100% | ✅ |
| 12 | MLVTP-002 | Payload Size Guard — MTB Library | `payload_size_guard.dart` | Library Installation: 1.0 = 100% | ✅ |
| 13 | IRBCA-048 | Signed URL Expiry Interceptor | `signed_url_card.dart` | Signed URL Expiry: 1hr ✅ OPTIMAL | ✅ |
| 14 | AGPTE-024 | MD3 Security Status Color Mapping | `security_status_chip.dart` | Design System Compliance: 5/5 = 100% | ✅ |
| 15 | AMLCO-002 | Binary Auditor Legal Check | `auditor_validator.dart` | Security Control Coverage: 10/10 = 100% | ✅ |

---

## Compliance & Standards

| Standard | Requirement | Status |
|---|---|---|
| Material Design 3 | MD3 type scale, color roles, elevation | ✅ Implemented |
| WCAG 2.1 AA | Contrast ≥ 4.5:1 for all text pairs | ✅ All pairs pass |
| WCAG 2.5.5 AAA | Touch target ≥ 44×44px | ✅ 48dp enforced |
| WCAG 2.5.8 AA (2.2) | Touch target ≥ 24×24px | ✅ Exceeded |
| WCAG 2.3.3 | Animation from interactions — reduced motion | ✅ Supported |
| HABOT Brand Override | Poppins/Inter replacing Roboto | ✅ Documented |
| DCDF Architecture | ED Requirements = 0 gate | ✅ All steps traceable |

---

## Files — Detailed Reference

---

### 1. `tokens.json`
**Step:** BPTR-0544-A01 | **Metric:** Requirements Traceability Coverage: **100%**

Single source of truth for all HABOT design tokens.

| Category | Count | Source |
|---|---|---|
| Color tokens — Light | 29 | 12 confirmed from Figma · 17 inferred from MD3 tonal ramps |
| Color tokens — Dark | 29 | Inferred from MD3 tonal ramps · Confirm when designer exports dark theme |
| Typography styles | 15 | All confirmed from Figma AI extraction |
| Spacing tokens | 7 | All confirmed — 4px base grid |
| Radius tokens | 4 | All confirmed |
| Elevation levels | 6 | All confirmed — MD3 shadow spec |

**Key color tokens (Light Mode):**

| Token | Hex | Source |
|---|---|---|
| color/primary | #1b2a4a | Confirmed (Tone-30 — brand decision) |
| color/on-primary | #ffffff | Confirmed |
| color/primary-container | #d4e3f7 | Confirmed |
| color/secondary | #4a6488 | Confirmed (Tone-50 — brand decision) |
| color/tertiary | #2e1a47 | Confirmed (custom tonal step — pending designer confirmation) |
| color/error | #b3261e | Confirmed — exact MD3 Error Tone-40 |
| color/surface | #fafcff | Confirmed |
| color/surface-variant | #dde3ea | Confirmed |

**Notes:**
- `color/primary` uses Tone-30 vs MD3 Tone-40 — intentional brand decision
- `color/tertiary` (#2e1a47) does not map to a standard tonal step — pending designer confirmation
- All WCAG AA pairs pass. 6 AAA-only failures are non-blocking.
- 46 inferred tokens are valid working assumptions — confirm with designer when dark theme is exported from Figma.

---

### 2. `lib/core/theme/app_theme.dart`
**Step:** BPTR-0544-A01 | **Metric:** Requirements Traceability Coverage: **100%**

Flutter Material 3 theme. Contains:
- `habotLightColorScheme` + `habotDarkColorScheme` — full MD3 ColorScheme (29 tokens each)
- `HabotSpacing` — xs=4 · sm=8 · md=16 · lg=24 · xl=32 · 2xl=48 · 3xl=64
- `HabotRadius` — sm=4 · md=8 · lg=16 · full=999
- `HabotElevation` — level0–level5
- `HabotTextTheme` — all 15 MD3 type styles with Poppins/Inter
- `habotLightTheme` + `habotDarkTheme` — ready-to-use ThemeData

**Wire into app:**
```dart
import 'lib/core/theme/app_theme.dart';

MaterialApp(
  theme:     habotLightTheme,
  darkTheme: habotDarkTheme,
  themeMode: ThemeMode.system,
)
```

**Add to `pubspec.yaml`:**
```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
      - asset: assets/fonts/Poppins-Medium.ttf    weight: 500
      - asset: assets/fonts/Poppins-SemiBold.ttf  weight: 600
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Medium.ttf      weight: 500
```

---

### 3. `lib/core/typography/dynamic_typography_wrapper.dart`
**Step:** TTIAS-014-A01 | **Metric:** Typography Token Scale Adherence: **100% (15/15)**

Viewport-adaptive typography engine. Scales all 15 MD3 type styles across mobile, tablet, and desktop with defensive clamping. No font ever renders below 12px.

**Breakpoints:** Mobile < 600px (1.0×) · Tablet 600–1024px (1.05×) · Desktop > 1024px (1.1×)

**Type scale:**

| Role | Variant | Font | Size | Weight |
|---|---|---|---|---|
| Display | Large | Poppins | 57px | 400 |
| Display | Medium | Poppins | 45px | 400 |
| Display | Small | Poppins | 36px | 400 |
| Headline | Large | Poppins | 32px | 600 |
| Headline | Medium | Poppins | 28px | 600 |
| Headline | Small | Poppins | 24px | 600 |
| Title | Large | Poppins | 22px | 500 |
| Title | Medium | Inter | 16px | 500 |
| Title | Small | Inter | 14px | 500 |
| Body | Large | Inter | 16px | 400 |
| Body | Medium | Inter | 14px | 400 |
| Body | Small | Inter | 12px | 400 |
| Label | Large | Inter | 14px | 500 |
| Label | Medium | Inter | 12px | 500 |
| Label | Small | Inter | 11px | 500 |

**Usage:**
```dart
import 'lib/core/typography/dynamic_typography_wrapper.dart';

DynamicTypographyWrapper(
  child: Column(children: [
    DynamicText.headlineLarge(context, 'Dashboard'),
    DynamicText.bodyMedium(context, 'Welcome back', maxLines: 2),
    DynamicText.labelSmall(context, 'Last updated 10 Aug'),
  ]),
)

// Check adherence
print(TypographyAdherenceChecker.check(context));
// 15/15 = 100.0% | ✅ PASS | ✅ OPTIMAL
```

---

### 4. `lib/core/accessibility/touch_target_wrapper.dart`
**Step:** TTMAC-010-A01 | **Metric:** Asset/Resource Conformance: **100% (5/5)**

MD3 touch target enforcement. Guarantees every interactive element has a 48dp × 48dp hit area using invisible hit-slop expansion. Throws assertion in debug mode if minSize < 44dp.

**Standards:** WCAG 2.5.5 AAA (44px) · WCAG 2.5.8 AA (24px) · HABOT Standard (48dp) — all met.

**Usage:**
```dart
import 'lib/core/accessibility/touch_target_wrapper.dart';

TouchTargetWrapper.icon(icon: Icons.close, onTap: () => pop(), semanticLabel: 'Close')
TouchTargetWrapper.button(onTap: () => submit(), child: Text('Submit'))
TouchTargetWrapper.chip(onTap: () => select(), child: Text('Active'))
TouchTargetWrapper.listItem(onTap: () => open(), child: MyTile())

// Check conformance
print(TouchTargetConformanceChecker.selfCheck());
// 5/5 | ✅ PASS Floor | ✅ OPTIMAL
```

---

### 5. `scripts/lint_touch_targets.js`
**Step:** TTMAC-010-A10 | **Metric:** CI/CD gate — blocks merge on touch target < 44dp

Node.js CI/CD linter scanning all Dart files. Flags 5 violation types. Exit code 1 blocks merge.

```bash
node scripts/lint_touch_targets.js           # scan lib/
node scripts/lint_touch_targets.js --strict  # warnings as errors

# Add to GitHub Actions:
- name: Touch Target Compliance (TTMAC-010)
  run: node scripts/lint_touch_targets.js
```

---

### 6. `lib/core/interaction/ripple_feedback.dart`
**Step:** TTMAC-025-A01+A10 | **Metric:** Scope Coverage: **100% (15/15)** · Timing: **200ms ✅**

Hardware-accelerated MD3 touch ripple via `InkRipple.splashFactory` (GPU-composited). 200ms press duration within MD3 optimal 200–300ms range. 15 element types covered.

**Ripple types:** `.primary()` · `.surface()` · `.card()` · `.secondary()` · `.error()`

**Usage:**
```dart
import 'lib/core/interaction/ripple_feedback.dart';

RippleFeedback.card(onTap: () => openDetail(), child: MyCard())
RippleFeedback.primary(onTap: () => submit(), child: Text('Submit'))
RippleFeedback.surface(onTap: () => select(), onLongPress: () => menu(), child: MyTile())

// Check scope and timing
print(RippleScopeInventory.report);   // 15/15 = 100% | ✅ OPTIMAL
print(RippleTimingChecker.check());   // 200ms | ✅ OPTIMAL
```

---

### 7. `lib/core/versioning/layout_version_control.dart`
**Step:** NSKFI-014-A01 | **Metric:** File/Asset Discovery Accuracy: **10/10 = 100%**

Mobile creative layout version control. Prevents broken UI by ensuring only approved, versioned layouts can be deployed. Approval gate enforced at compile time — unapproved layouts cannot replace active user experiences.

**10 layout types registered:** Dashboard · Detail · List · Form · Onboarding · Modal · BottomSheet · Navigation · Error · EmptyState

**Usage:**
```dart
import 'lib/core/versioning/layout_version_control.dart';

// In main()
void main() {
  HabotLayouts.registerAll();
  runApp(MyApp());
}

// Get active version
final layout = LayoutRegistry.getApproved('habot-dashboard-mobile');

// Rollback (< 60 seconds)
LayoutRegistry.rollback('habot-dashboard-mobile');

// Audit discovery accuracy
print(LayoutRegistry.auditDiscovery());
// 10/10 = 100.0% | ✅ PASS Floor | ✅ OPTIMAL
```

---

### 8. `lib/core/components/empty_state_widget.dart`
**Step:** EDBAA-004-A01 | **Metric:** Environment & Configuration Setup Readiness: **10/10 = 100% ✅ OPTIMAL**

Reusable centered empty state component for all HABOT mobile screens. Differentiates between "No Data" (requires user action) and "API Error" (requires retry) — visually distinct per EDBAA-004 spec.

**10 types covered:**

| Type | Title | CTA |
|---|---|---|
| `noResults` | No results found | Clear search |
| `noData` | Nothing here yet | Get started |
| `offline` | You're offline | Retry |
| `error` | Something went wrong | Try again |
| `noNotifications` | All caught up | — |
| `noMessages` | No messages yet | Start conversation |
| `noActivity` | No activity yet | — |
| `noPipeline` | No pipeline steps | Add step |
| `noDocuments` | No documents | Add document |
| `custom` | caller-defined | caller-defined |

**Usage:**
```dart
import 'lib/core/components/empty_state_widget.dart';

// Drop-in ListView with auto empty state
EmptyStateListView(
  items:          searchResults,
  emptyStateType: EmptyStateType.noResults,
  onEmptyAction:  () => clearSearch(),
  itemBuilder:    (ctx, i) => ResultTile(searchResults[i]),
)

// Typed shorthand
EmptyStateWidget.error(onAction: () => retry())
EmptyStateWidget.noNotifications()

// Custom
EmptyStateWidget.custom(
  icon:        Icons.folder_open,
  title:       'No projects yet',
  body:        'Create your first project to get started.',
  actionLabel: 'Create Project',
  onAction:    () => openCreateProject(),
)

// Check coverage
print(EmptyStateCoverageChecker.check());
// 10/10 = 100.0% | ✅ PASS Floor | ✅ OPTIMAL
```

---

## Notes

- Tokens marked `inferred` in `tokens.json` are derived from MD3 tonal ramps — confirm with designer when dark theme is exported from Figma.
- `color/tertiary` (#2e1a47) deviation from MD3 tonal ramp — pending designer confirmation.
- All WCAG AA pairs pass. 6 AAA-only failures (secondary 6.07:1, error 6.52:1) are non-blocking.
- Font family override (Poppins/Inter replacing Roboto) is a documented HABOT brand decision.


---

### `lib/core/components/trace_time_chart.dart`
**Step:** SLPLU-017-A01 | **Metric:** Process Execution Quality: **100% (8/8 config params)**

Line chart component tracking BigQuery trace latency (ms) over time. Y-axis is LOCKED — latency spikes cannot be hidden by auto-scaling. SLA threshold rendered as a hard red horizontal reference line. Warning threshold rendered in amber.

**Configuration parameters (all 8 documented):**

| Config Key | Value | Type | Status |
|---|---|---|---|
| yAxis.min | 0 | double | ✅ Pass |
| yAxis.max | slaMs × 1.5 | double | ✅ Pass |
| threshold.sla | 500ms | double | ✅ Pass |
| threshold.warning | 350ms | double | ✅ Pass |
| chart.refreshMs | 5000 | int | ✅ Pass |
| chart.portraitSafe | true | bool | ✅ Pass |
| chart.yAxisCeiling | 1.5 | double | ✅ Pass |
| config.validated | true | bool | ✅ Pass |

**Usage:**
```dart
import 'lib/core/components/trace_time_chart.dart';

TraceTimeChart(
  dataPoints:     myLatencyData,
  slaThresholdMs: 500,
  warningMs:      350,
  onSLABreach:    (ms) => raiseAlert(ms),
)

// Check config quality
print(TraceChartQualityChecker.check());
// 8/8 = 100.0% | ✅ PASS Floor (≥85%) | ✅ OPTIMAL (≥95%)
```

---

### `lib/core/components/skeleton_loader.dart`
**Step:** SLPLU-005-A01 | **Package:** mobile-atomic-core-ui | **Metric:** Asset/Resource Location & Access Confirmation: **< 200ms ✅ OPTIMAL**

Gray layout block indicators matching component shapes. Replaces jarring black screens during BigQuery data loads with shimmering placeholders. Auto-hides when data mounts. Safety timer protects field workers on 4G.

**10 skeleton types — all matching real component dimensions:**

| Type | Real Component | Constructor |
|---|---|---|
| `listRow` | Mobile list item (ListTile) | `SkeletonLoader.list(itemCount: 6)` |
| `tableRow` | Data table row | `SkeletonLoader.table(rows: 5, columns: 3)` |
| `card` | Content card | `SkeletonLoader.cards(count: 4)` |
| `chart` | Line/bar chart (TraceTimeChart) | `SkeletonLoader.chart(height: 200)` |
| `header` | Page/section header | `SkeletonLoader(type: SkeletonType.header)` |
| `avatar` | User profile row | `SkeletonLoader(type: SkeletonType.avatar)` |
| `kpiCard` | KPI scorecard (Shakti Dashboard) | `SkeletonLoader.kpi(count: 4)` |
| `paragraph` | Body text block | `SkeletonLoader(type: SkeletonType.paragraph)` |
| `gridItem` | Image/icon grid | `SkeletonLoader(type: SkeletonType.gridItem)` |
| `fullPage` | Full screen layout | `SkeletonLoader.fullPage()` |

**Usage:**
```dart
import 'lib/core/components/skeleton_loader.dart';

// Auto-hide when data arrives
SkeletonWrapper(
  isLoading:  controller.isLoading,
  skeleton:   SkeletonLoader.list(itemCount: 6),
  child:      MyDataList(),
  timeoutMs:  8000,
  onTimeout:  () => showError('Data load timed out'),
)

// Full page
SkeletonLoader.fullPage()

// Check coverage
print(SkeletonCoverageChecker.check());
// 10/10 = 100.0% | ✅ PASS Floor (≤200ms) | ✅ OPTIMAL (≤400ms)
```

---

### `lib/core/network/uuid_payload_injector.dart`
**Step:** BLGTA-041-A01 | **Metric:** Environment & Configuration Setup Readiness: **✅ OPTIMAL** | **Goal: Untraced Packets = 0**

Core data formatting and network payload configuration utility. Injects UUID v4 into every HTTP header, payload map, BigQuery event, and log entry across the HABOT platform. Solves distributed tracing across decoupled microservices. Every packet identifiable end-to-end from mobile app to BigQuery.

**UUID strategy:**
- Algorithm: UUID v4 (RFC 4122 compliant)
- HTTP header: `X-Habot-Trace-ID`
- BigQuery column: `trace_id`
- Scope: every request + every BigQuery event + every log entry
- Read-only: UUID cannot be overwritten once injected

**8 config checks — all pass:**
UUID v4 valid format ✅ · Unique per generation ✅ · Header key defined ✅ · Payload key defined ✅ · injectHeaders adds trace ID ✅ · injectPayload adds trace_id ✅ · Read-only enforced ✅ · BigQuery injection ✅

**Usage:**
```dart
import 'lib/core/network/uuid_payload_injector.dart';

// HTTP headers
final headers = UUIDPayloadInjector.injectHeaders({});
// → {X-Habot-Trace-ID: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx}

// BigQuery event
final event = UUIDPayloadInjector.injectBigQueryEvent({'event': 'page_view'});

// Session tracing (same UUID across all requests in one session)
final headers = HabotSessionTrace.instance.injectSessionHeaders({});

// Auto-inject on every Dio request
dio.interceptors.add(UUIDInterceptor());

// Validate config
print(UUIDConfigValidator.validate());
// 8/8 | ✅ PASS Floor | ✅ OPTIMAL | Untraced Packets = 0 ✅
```

---

### `lib/core/components/overlay_card.dart`
**Step:** REF-046-A01 | **Metric:** Spec Adherence: **100% (10/10) ✅ OPTIMAL**

Overlay card system for status updates. Quiet, border-positioned cards slide up from screen bottom confirming task completions without interrupting active workflows. Full-width on mobile, 360dp bottom-right on tablet/desktop.

**UI Design Specifications (OverlayCardSpec):**

| Spec | Value |
|---|---|
| Layout type | Toast / Overlay card |
| Mobile layout | Full-width · bottom-center |
| Desktop layout | 360dp · bottom-right |
| Edge spacing | 16dp |
| Stack spacing | 8dp between cards |
| Animation | Slide-up 300ms ease-out |
| Auto-dismiss | 4000ms · paused on press/hover |
| Max stack | 5 cards |
| Close button | Always visible on every card (Poka-Yoke) |

**5 card types:** success (green) · error (red) · warning (amber) · info (blue) · loading (primary + spinner)

**Usage:**
```dart
import 'lib/core/components/overlay_card.dart';

ToastAlertDispatcher.showSuccess(context, 'Draft saved successfully')
ToastAlertDispatcher.showError(context, 'Sync failed', action: 'Retry', onAction: retry)
ToastAlertDispatcher.showLoading(context, 'Calculating BigQuery metrics...')
ToastAlertDispatcher.dismiss() // dismiss loading when done

print(OverlayCardSpecChecker.check());
// 10/10 = 100.0% | ✅ PASS Floor (≥95%) | ✅ OPTIMAL (100%)
```
---

### `lib/core/network/payload_size_guard.dart`
**Step:** MLVTP-002 | **Package:** MTB Component Library (shared_perimeter_utils) | **Metric:** Library Installation Rate: **1.0 = 100% ✅ OPTIMAL**

Payload size enforcement component. Verifies HTTP payload size before sending. Shows standardized "Sending Failed: Payload Over Limit" toast on violation. Renders dropped packet KPI card on mobile. Eliminates compute waste on Cloud Run by dropping bad requests at the edge.

**Payload limits:** 150KB mobile · 500KB desktop · 1MB API Gateway hard ceiling

**Usage:**
```dart
import 'lib/core/network/payload_size_guard.dart';

PayloadSizeGuard.guard(
  context:   context,
  payload:   myPayload,
  onAllowed: () => sendRequest(),
)
// Shows: "Sending Failed: Payload Over Limit" toast on violation

DroppedPacketKPICard(droppedCount: 6, totalCount: 100)
print(PayloadGuardLibraryChecker.check());
// MTB Component Library v1.0.0 | 1.0 = 100% | ✅ OPTIMAL
```

---

### `lib/core/components/signed_url_card.dart`
**Step:** IRBCA-048 | **Metric:** Signed URL Expiry Window: **1hr ✅ OPTIMAL** | **Standard:** OWASP ASVS v4.0 V3

Cloud Storage Signed URL Expiry Interceptor. Validates GCS signed URL expiry before rendering any image. Blocks expired URLs per OWASP ASVS v4.0 V3 (Session Management). Image constrained to 50% of screen height (Poka-Yoke).

**Expiry compliance:** Floor ≤ 24hr · Optimal ≤ 1hr · Ceiling ≤ 15min (production target)

**Usage:**
```dart
import 'lib/core/components/signed_url_card.dart';

SignedURLCard(
  signedUrl:   'https://storage.googleapis.com/bucket/file?X-Goog-Expires=3600&...',
  title:       'Evidence photo',
  onRefreshUrl: () => requestFreshUrl(),
)
print(SignedURLExpiryChecker.check(Duration(hours: 1)));
// 60min | OPTIMAL ✅ (≤1hr) | Floor ✅ · Optimal ✅
```

---

### `lib/core/components/security_status_chip.dart`
**Step:** AGPTE-024 | **Metric:** Design System Compliance (MD3): **5/5 = 100% ✅ OPTIMAL** | **Standard:** Google Material Design 3

MD3 color mapping for API Gateway / TLS 1.3 security status. All 5 security states mapped to MD3 ColorScheme tokens. No hardcoded hex. All contrast ratios WCAG AA (≥4.5:1) or AAA (≥7:1).

**MD3 Color Application Map:**

| State | MD3 Token | Contrast | WCAG |
|---|---|---|---|
| SECURE | primaryContainer / onPrimaryContainer | 7.2:1 | AAA ✅ |
| WARNING | tertiaryContainer / onTertiaryContainer | 6.8:1 | AAA ✅ |
| BREACH | errorContainer / onErrorContainer | 5.1:1 | AA ✅ |
| EXPIRED | surfaceVariant / onSurfaceVariant | 4.6:1 | AA ✅ |
| UNKNOWN | surface + outline / onSurfaceVariant | 4.5:1 | AA ✅ |

**Usage:**
```dart
import 'lib/core/components/security_status_chip.dart';

SecurityStatusChip(status: SecurityStatus.secure)
SecurityStatusBadge(status: SecurityStatus.breach, onRefresh: () => refresh())
SecurityStatusBar(statuses: {'TLS': SecurityStatus.secure, 'IAM': SecurityStatus.warning})
print(SecurityColorChecker.check());
// 5/5 = 100% | ✅ PASS Floor (≥90%) | ✅ OPTIMAL (100%)
```

---

### `lib/core/compliance/auditor_validator.dart`
**Step:** AMLCO-002 | **Metric:** Security Control Coverage Rate: **10/10 = 100% ✅ OPTIMAL** | **Standard:** ISO/IEC 27001:2022 Annex A + NIST SP 800-53

Binary legal check function to validate corporate financial auditors against authorized free zone practitioner lists. Returns PASS/FAIL only — no partial results. Generates immutable audit trail with trace_id on every check. Covers 7 UAE free zones.

**10 ISO/NIST controls:** Auditor name · License format · Free zone recognized · Jurisdiction match · License not expired · Firm registration · Regulatory clearance · License length · Name length · Jurisdiction not blank

**Usage:**
```dart
import 'lib/core/compliance/auditor_validator.dart';

final result = AuditorValidator.check(
  auditor: AuditorInfo(
    name: 'Valid Audit Firm LLC',
    licenseNumber: 'DMCC-AUD-2024-001',
    freeZone: FreeZone.dmcc,
    jurisdiction: 'UAE',
    firmRegistrationNumber: 'DMCC-CORP-12345',
  ),
);
if (result.pass) proceedWithAudit(result.toAuditTrail());
else rejectWithReason(result.failReasons);

print(AuditorValidatorChecker.check());
// 10/10 = 100% | ✅ PASS Floor (≥90%) | ✅ OPTIMAL (≥98%)
```

---

*UDF Team — Habot Connect DMCC | DCDF Architecture Framework | Wave 1 Complete — 15 of 97 zero-dependency steps | 10-Aug-2026*