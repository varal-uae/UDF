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
├── tokens.json                                          ← Step 1: All design tokens
│
├── lib/
│   └── core/
│       ├── theme/
│       │   └── app_theme.dart                           ← Step 1: Flutter ThemeData
│       ├── typography/
│       │   └── dynamic_typography_wrapper.dart          ← Step 2: Viewport-adaptive typography
│       ├── accessibility/
│       │   └── touch_target_wrapper.dart                ← Step 3: 48dp touch target enforcement
│       ├── interaction/
│       │   └── ripple_feedback.dart                     ← Step 4: Hardware-accelerated ripple
│       ├── versioning/
│       │   └── layout_version_control.dart              ← Step 5: Mobile layout version control
│       └── components/
│           └── empty_state_widget.dart                  ← Step 6: Actionable empty states
│
└── scripts/
    └── lint_touch_targets.js                            ← Step 3: CI/CD touch target linter
```

---

## Implementation Steps

| # | Step | Atomic Ref | Description | Metric | Status |
|---|---|---|---|---|---|
| 1 | BPTR-0544-A01 | Standardize MD3 Typography & Colors | `tokens.json` + `app_theme.dart` | Coverage: 100% | ✅ |
| 2 | TTIAS-014-A01 | Viewport-Adaptive Typography Engine | `dynamic_typography_wrapper.dart` | Adherence: 100% | ✅ |
| 3 | TTMAC-010-A01+A10 | Touch Target Minimum Size Standards | `touch_target_wrapper.dart` + `lint_touch_targets.js` | Conformance: 100% | ✅ |
| 4 | TTMAC-025-A01+A10 | Hardware-Accelerated Touch Ripple | `ripple_feedback.dart` | Scope: 100% · Timing: 200ms | ✅ |
| 5 | NSKFI-014-A01 | Mobile Layout Version Control | `layout_version_control.dart` | Discovery: 10/10 = 100% | ✅ |
| 6 | EDBAA-004-A01 | Actionable Mobile Empty States | `empty_state_widget.dart` | Coverage: 10/10 = 100% | ✅ |

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

*UDF Team — Habot Connect DMCC | DCDF Architecture Framework | v1 — 10-Aug-2026*
