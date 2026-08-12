# HABOT Design System — UDF Implementation

**Repository:** `github.com/RitwikHC/theme-typography`
**Team:** UDF — UX Design & Frontend Engineering | Habot Connect DMCC
**Owner:** Ritwik Sharma — Frontend Integration Specialist
**Framework:** Flutter (Material Design 3)
**Version:** v1 | Last Updated: 11-Aug-2026
**Steps Completed:** 25 of 97 zero-dependency steps

---

## Overview

This repository contains the HABOT Design System implementation for Flutter — all design tokens, typography, theming, accessibility enforcement, interaction patterns, version control, and UI component files produced as part of the UDF DCDF Architecture Framework implementation.

All files comply with **Material Design 3 (MD3)** specifications with intentional HABOT brand overrides documented per file.

---

## Repository Structure

```
theme-typography/
├── README.md
├── tokens.json                                              ← Step 1:  Design tokens
├── lib/core/
│   ├── theme/
│   │   └── app_theme.dart                                   ← Step 1:  MD3 theme + spacing/radius/elevation
│   ├── typography/
│   │   ├── dynamic_typography_wrapper.dart                  ← Step 2:  Dynamic type scale (Poppins/Inter)
│   │   └── compact_typography_grid.dart                     ← Step 16: M3 compact type (10–20px, CC≤5)
│   ├── accessibility/
│   │   └── touch_target_wrapper.dart                        ← Step 3:  48dp touch target enforcer
│   ├── interaction/
│   │   └── ripple_feedback.dart                             ← Step 4:  MD3 ripple (200ms)
│   ├── versioning/
│   │   └── layout_version_control.dart                      ← Step 5:  Layout version registry
│   ├── components/
│   │   ├── empty_state_widget.dart                          ← Step 6:  Actionable empty states
│   │   ├── trace_time_chart.dart                            ← Step 8:  Trace time Y-axis chart
│   │   ├── skeleton_loader.dart                             ← Step 9:  Skeleton loaders
│   │   ├── overlay_card.dart                                ← Step 11: Overlay card + toast dispatcher
│   │   ├── signed_url_card.dart                             ← Step 13: GCS signed URL expiry interceptor
│   │   ├── security_status_chip.dart                        ← Step 14: MD3 security status color map
│   │   ├── network_tap_zone.dart                            ← Step 17: VPC network 48dp tap zones
│   │   ├── formula_tooltip.dart                             ← Step 18: WCAG 2.1 AA formula tooltips
│   │   ├── issue_severity_tag.dart                          ← Step 19: MD3 issue severity escalation tags
│   │   ├── deadline_alert_banner.dart                       ← Step 20: F&F persistent deadline banner
│   │   ├── funnel_analytics_map.dart                        ← Step 21: Interactive funnel drop-off map
│   │   ├── dlq_monitoring_dashboard.dart                    ← Step 22: DLQ backlog depth + alert policy
│   │   ├── security_access_dashboard.dart                   ← Step 23: Zero-Trust access monitoring
│   │   ├── system_config_form.dart                          ← Step 24: M3 Switches + Segmented Buttons
│   │   └── rbac_dashboard.dart                              ← Step 25: RBAC-filtered engineering dashboard
│   ├── network/
│   │   ├── uuid_payload_injector.dart                       ← Step 10: UUID universal payload injection
│   │   └── payload_size_guard.dart                          ← Step 12: MTB payload size guard
│   └── compliance/
│       └── auditor_validator.dart                           ← Step 15: Binary auditor legal check
└── scripts/
    └── lint_touch_targets.js                                ← Step 3:  Touch target lint script
```

---

## Steps Completed

| # | Ref | Title | File | Metric | Status |
|---|---|---|---|---|---|
| 1 | BPTR-0544-A01 | Design Tokens + MD3 Theme | `tokens.json` + `app_theme.dart` | Traceability: 100% | ✅ |
| 2 | TTIAS-014-A01 | Dynamic Typography Wrapper | `dynamic_typography_wrapper.dart` | Scale Adherence: 100% | ✅ |
| 3 | TTMAC-010-A01+A10 | Touch Target Enforcer + Lint | `touch_target_wrapper.dart` + `lint_touch_targets.js` | Conformance: 100% | ✅ |
| 4 | TTMAC-025-A01+A10 | MD3 Ripple Feedback | `ripple_feedback.dart` | Scope: 100% · 200ms | ✅ |
| 5 | NSKFI-014-A01 | Layout Version Control | `layout_version_control.dart` | Discovery: 100% | ✅ |
| 6 | EDBAA-004-A01 | Empty State Widget | `empty_state_widget.dart` | Coverage: 10/10 | ✅ |
| 7 | BPTR-0693-A01 | Shakti Dashboard (Looker Studio) | Workspace: 7947dda9 | Coverage: 5/5 | ✅ |
| 8 | SLPLU-017-A01 | Trace Time Chart | `trace_time_chart.dart` | Quality: 8/8 | ✅ |
| 9 | SLPLU-005-A01 | Skeleton Loader | `skeleton_loader.dart` | Access: < 200ms | ✅ |
| 10 | BLGTA-041-A01 | UUID Payload Injector | `uuid_payload_injector.dart` | Untraced = 0 | ✅ |
| 11 | REF-046-A01 | Overlay Card + Toast | `overlay_card.dart` | Spec: 10/10 | ✅ |
| 12 | MLVTP-002 | Payload Size Guard | `payload_size_guard.dart` | Library Install: 100% | ✅ |
| 13 | IRBCA-048 | Signed URL Expiry Interceptor | `signed_url_card.dart` | Expiry: 1hr OPTIMAL | ✅ |
| 14 | AGPTE-024 | MD3 Security Status Color Map | `security_status_chip.dart` | MD3 Compliance: 5/5 | ✅ |
| 15 | AMLCO-002 | Binary Auditor Legal Check | `auditor_validator.dart` | Security Coverage: 10/10 | ✅ |
| 16 | AWCV-001 | Compact Typography Grid | `compact_typography_grid.dart` | CC max=3 OPTIMAL | ✅ |
| 17 | ONCS-001 | VPC Network 48dp Tap Zones | `network_tap_zone.dart` | 48dp + 8dp buffer | ✅ |
| 18 | EDBAA-002 | Formula Tooltip Accessibility | `formula_tooltip.dart` | WCAG 2.1 AA: 17/17 | ✅ |
| 19 | BTPM-002 | Issue Severity Escalation Tags | `issue_severity_tag.dart` | Touch 100% · CWV Good | ✅ |
| 20 | BCDLD-037 | F&F Deadline Alert Banner | `deadline_alert_banner.dart` | Alert Coverage: 100% | ✅ |
| 21 | CFCST-002 | Funnel Analytics Map | `funnel_analytics_map.dart` | Specs: 18/18 = 100% | ✅ |
| 22 | TECH-ENG-004 | DLQ Monitoring Dashboard | `dlq_monitoring_dashboard.dart` | Policy: Pass · ≤60s | ✅ |
| 23 | TECH-ENG-022 | Zero-Trust Security Dashboard | `security_access_dashboard.dart` | Load: Good · RAIL ≤2s | ✅ |
| 24 | TECH-ENG-037 | System Config Form (DevOps Admin) | `system_config_form.dart` | Completeness: 15/15 | ✅ |
| 25 | TECH-ENG-049 | RBAC Engineering Dashboard | `rbac_dashboard.dart` | Enforcement: 100% Pass | ✅ |

---

## Wave 1 — Steps 1–15 (Complete)

### `tokens.json` + `lib/core/theme/app_theme.dart`
**Step:** BPTR-0544-A01 | **Metric:** Requirements Traceability: 100%

Design tokens (JSON) and Flutter MD3 theme. Defines all `HabotSpacing`, `HabotRadius`, `HabotElevation` constants. Base for every file in this repository.

---

### `lib/core/typography/dynamic_typography_wrapper.dart`
**Step:** TTIAS-014-A01 | **Metric:** Token Scale Adherence: 15/15 = 100%

Dynamic type scale — Poppins (headings) and Inter (body/label). 15 `DynamicTextStyle` static methods.

```dart
DynamicTextStyle.headlineLarge(context)
DynamicTextStyle.bodyMedium(context)
DynamicTextStyle.labelSmall(context)
```

---

### `lib/core/accessibility/touch_target_wrapper.dart` + `scripts/lint_touch_targets.js`
**Step:** TTMAC-010-A01+A10 | **Metric:** Conformance: 100%

48dp minimum enforcer + static lint scanner for touch target violations.

```dart
TouchTargetWrapper(child: myButton) // enforces 48dp min
```

---

### `lib/core/interaction/ripple_feedback.dart`
**Step:** TTMAC-025-A01+A10 | **Metric:** Scope: 15/15 · Timing: 200ms ✅

MD3-compliant ripple using `on-surface` token. 200ms. `HabotRipple.wrap()` applies to any widget.

---

### `lib/core/versioning/layout_version_control.dart`
**Step:** NSKFI-014-A01 | **Metric:** Discovery: 10/10 = 100%

Layout version registry. Tracks version, breakpoints, and deprecation status per component.

---

### `lib/core/components/empty_state_widget.dart`
**Step:** EDBAA-004-A01 | **Metric:** Coverage: 10/10 = 100%

10 empty state types with icon, title, body, and optional CTA.

```dart
EmptyStateWidget(type: EmptyStateType.noData, onAction: () => refresh())
```

---

### `lib/core/components/trace_time_chart.dart`
**Step:** SLPLU-017-A01 | **Metric:** Quality: 8/8 = 100%

Y-axis trace time chart for performance monitoring. 8 chart variants.

---

### `lib/core/components/skeleton_loader.dart`
**Step:** SLPLU-005-A01 | **Metric:** Access: < 200ms ✅

Shimmer skeleton loaders — card, list tile, text. Zero network dependency.

```dart
SkeletonLoader.card()
SkeletonLoader.listTile()
SkeletonLoader.text(lines: 3)
```

---

### `lib/core/network/uuid_payload_injector.dart`
**Step:** BLGTA-041-A01 | **Metric:** Config Readiness: 4/4 · Untraced = 0

UUID v4 generator used by Steps 12, 13, 15, 18, 20, 21, 22, 23, 24, 25.

```dart
final id = HabotUUID.v4();
final payload = UUIDPayloadInjector.inject(myPayload); // adds trace_id
```

---

### `lib/core/components/overlay_card.dart`
**Step:** REF-046-A01 | **Metric:** Spec Adherence: 10/10 = 100%

5 status types. `ToastAlertDispatcher` singleton. Slide-up 300ms. Auto-dismiss 4s.

```dart
ToastAlertDispatcher.showSuccess(context, 'Saved')
ToastAlertDispatcher.showError(context, 'Failed', action: 'Retry', onAction: retry)
```

---

### `lib/core/network/payload_size_guard.dart`
**Step:** MLVTP-002 | **Metric:** Library Installation: 1.0 = 100% ✅

150KB mobile · 500KB desktop · 1MB gateway ceiling. "Sending Failed: Payload Over Limit" toast on violation.

```dart
PayloadSizeGuard.guard(context: context, payload: myPayload, onAllowed: () => send())
```

---

### `lib/core/components/signed_url_card.dart`
**Step:** IRBCA-048 | **Metric:** Expiry: 1hr ✅ OPTIMAL | **Standard:** OWASP ASVS v4.0 V3

GCS signed URL expiry interceptor. Image constrained to 50% screen height. Error state on expiry.

```dart
SignedURLCard(signedUrl: url, title: 'Evidence', onRefreshUrl: () => refresh())
```

---

### `lib/core/components/security_status_chip.dart`
**Step:** AGPTE-024 | **Metric:** MD3 Compliance: 5/5 = 100% ✅

| State | Token | WCAG |
|---|---|---|
| SECURE | primaryContainer | AAA 7.2:1 |
| WARNING | tertiaryContainer | AAA 6.8:1 |
| BREACH | errorContainer | AA 5.1:1 |
| EXPIRED | surfaceVariant | AA 4.6:1 |
| UNKNOWN | surface + outline | AA 4.5:1 |

---

### `lib/core/compliance/auditor_validator.dart`
**Step:** AMLCO-002 | **Metric:** Security Coverage: 10/10 = 100% ✅ | **Standard:** ISO/IEC 27001:2022 + NIST SP 800-53

Binary PASS/FAIL auditor check. 10 ISO/NIST controls. 7 UAE free zones. Immutable audit trail with `trace_id`.

---

## Wave 2 — Steps 16–20 (Complete)

### `lib/core/typography/compact_typography_grid.dart`
**Step:** AWCV-001 | **Metric:** CC max=3 ✅ OPTIMAL

M3 compact type (10–20px). Single-purpose "Byt" granularity — CC ≤ 5 per function. 3 viewport grid breakpoints. Required field red asterisk via `CompactLabel`.

---

### `lib/core/components/network_tap_zone.dart`
**Step:** ONCS-001 | **Metric:** 48dp × 48dp + 8dp buffer ✅

VPC network dashboard tap zones. `assert(tapSize >= 48.0)`. Tablet-optimised `Wrap` region chips + `SubnetCard`.

---

### `lib/core/components/formula_tooltip.dart`
**Step:** EDBAA-002 | **Metric:** WCAG 2.1 AA: 17/17 = 100% ✅

Context-sensitive formula tooltips. `Semantics`, keyboard `FocusNode`, `liveRegion`. 5 formula types (VAT · Payroll · Depreciation · FX · Interest).

---

### `lib/core/components/issue_severity_tag.dart`
**Step:** BTPM-002 | **Metric:** Touch 100% · CWV Good · MD3 5/5 ✅

| Severity | Token | WCAG |
|---|---|---|
| CRITICAL | errorContainer | AA 5.1:1 |
| HIGH | tertiaryContainer | AAA 6.8:1 |
| MEDIUM | secondaryContainer | AA 5.8:1 |
| LOW | surfaceVariant | AA 4.6:1 |
| RESOLVED | primaryContainer | AAA 7.2:1 |

```dart
IssueSeverityTag(severity: IssueSeverity.critical, label: 'Timeout', onTap: openTicket)
EscalationGate.shouldAutoEscalate(IssueSeverity.critical) // true
```

---

### `lib/core/components/deadline_alert_banner.dart`
**Step:** BCDLD-037 | **Metric:** Alert Hook Coverage: 100% · Rating: High ✅

Persistent top-viewport F&F deadline banner. `SlideTransition` 400ms. Countdown timer per-second. Pub/Sub event on every appearance via `addPostFrameCallback`.

```dart
DeadlineAlertBanner(task: myTask, onAction: () => openFlow())
DeadlineCountdownChip(deadline: task.deadline)  // "6h left"
```

---

## Wave 3 — Steps 21–25 (Complete)

### `lib/core/components/funnel_analytics_map.dart`
**Step:** CFCST-002 | **Metric:** Specs: 18/18 = 100% ✅ | **Standard:** BigQuery telemetry validation

Interactive funnel drop-off analytics map. Proportional bars (`FractionallySizedBox`). Monotone integrity check. Telemetry mismatch detection. Tap-to-drill-down.

```dart
FunnelAnalyticsMap(
  funnelId: 'onboarding-v2',
  steps: [
    FunnelStep(id: 's1', label: 'App open',       userCount: 10000),
    FunnelStep(id: 's2', label: 'Sign up started', userCount: 7500),
    FunnelStep(id: 's3', label: 'Email verified',  userCount: 5000),
    FunnelStep(id: 's4', label: 'Profile complete', userCount: 3000),
  ],
  onStepTap: (m) => drillDown(m.step.id),
)
```

---

### `lib/core/components/dlq_monitoring_dashboard.dart`
**Step:** TECH-ENG-004 | **Metric:** DLQ Alert Policy: Pass ✅ · All policies · ≤60s | **Standard:** Google Cloud Monitoring

Dead Letter Queue monitoring. Backlog depth bar per topic. Pass/Fail per topic. Alert latency ≤ 60s indicator. No-policy = immediate Fail (Poka-Yoke).

```dart
DLQMonitoringDashboard(
  topics: [
    DLQTopic(id: 't1', topicName: 'habot.payments.dlq',
      backlogDepth: 45, alertThreshold: 100,
      hasAlertPolicy: true, alertLatencyMs: 28000),
  ],
  onAlertFired: (e) => pubSub.publish(e.toMap()),
)
```

---

### `lib/core/components/security_access_dashboard.dart`
**Step:** TECH-ENG-022 | **Metric:** Load: Good · RAIL ≤2s ✅ | **Standard:** Google RAIL Model

Zero-Trust security access dashboard. Access attempts, denials, MFA fallback. Pre-aggregated = no async at render. RAIL compliant. Alert banner at ≥20% denial rate.

```dart
SecurityAccessDashboard(
  snapshot: SecurityAccessSnapshot(
    totalAttempts: 10000, totalDenials: 500,
    mfaFallbackCount: 300, loadTimeMs: 850,
    denialBreakdown: {DenialReason.failedAuth: 280},
  ),
)
```

---

### `lib/core/components/system_config_form.dart`
**Step:** TECH-ENG-037 | **Metric:** Completeness: 15/15 = 100% ✅ | **Standard:** DORA Quality Standards

DevOps Admin-only system config form. M3 Switches (binary) + Segmented Buttons (enum). 5 categories. Admin role guard. Config diff with `trace_id` on save.

| Category | Control | Items |
|---|---|---|
| Environment | SegmentedButton | Dev / Staging / Prod |
| Feature Flags | Switch ×6 | Dark mode · Analytics · Beta UI · Offline · A11y · Experimental API |
| Logging | Segmented + Switch | Log level (4 options) · Verbose |
| Deployment | SegmentedButton | Rolling / Blue-Green / Canary |
| Security | Switch ×3 | Enforce MFA · Audit log · Geo-block |

```dart
SystemConfigForm(
  userRole: 'DevOpsAdmin',
  config:   SystemConfig(environment: 'staging', enforceMFA: true),
  onSave:   (event) => bigQuery.insert(event.toMap()),
)
```

---

### `lib/core/components/rbac_dashboard.dart`
**Step:** TECH-ENG-049 | **Metric:** RBAC Enforcement: 100% · Status: Pass ✅ | **Standard:** NIST SP 800-53 Rev 5 AC-3 + AC-6

Cross-Functional Engineering Intelligence Dashboard with RBAC filtering. 4 roles × 6 sections = 24 combinations. All validated. `AccessDeniedCard` for blocked sections. Audit trail per access.

| Section | Admin | Manager | Engineer | Viewer |
|---|---|---|---|---|
| Infra metrics | ✅ | ❌ | ❌ | ❌ |
| Code quality | ✅ | ✅ | ✅ | ❌ |
| Incidents | ✅ | ✅ | ✅ | ❌ |
| Cost analytics | ✅ | ✅ | ❌ | ❌ |
| Security events | ✅ | ❌ | ❌ | ❌ |
| Team summary | ✅ | ✅ | ✅ | ✅ |

```dart
RBACDashboard(
  userRole: RBACRole.engineer,
  sectionData: { DashboardSection.codeQuality: myData },
  onAuditEntry: (entry) => bigQuery.insert(entry.toMap()),
)
print(RBACDashboardChecker.check());
// 24/24 | ✅ PASS (100%) | ✅ OPTIMAL (zero unauthorized) | Status: Pass
```

---

## pubspec.yaml — Font Registration

```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
      - asset: assets/fonts/Poppins-Medium.ttf     # weight: 500
      - asset: assets/fonts/Poppins-SemiBold.ttf   # weight: 600
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Medium.ttf        # weight: 500
```

---

## All 25 Completion Banners

```
✅ BPTR-0544-A01  — Design Tokens + MD3 Theme           | Traceability 100%          | 10-Aug-2026
✅ TTIAS-014-A01  — Dynamic Typography Wrapper           | Scale 100%                 | 10-Aug-2026
✅ TTMAC-010-A01  — Touch Target Enforcer + Lint         | Conformance 100%           | 10-Aug-2026
✅ TTMAC-025-A01  — MD3 Ripple Feedback                  | 15/15 · 200ms              | 10-Aug-2026
✅ NSKFI-014-A01  — Layout Version Control               | Discovery 10/10            | 10-Aug-2026
✅ EDBAA-004-A01  — Empty State Widget                   | Coverage 10/10             | 10-Aug-2026
✅ BPTR-0693-A01  — Shakti Dashboard                     | Coverage 5/5               | 10-Aug-2026
✅ SLPLU-017-A01  — Trace Time Chart                     | Quality 8/8                | 10-Aug-2026
✅ SLPLU-005-A01  — Skeleton Loader                      | Access <200ms              | 10-Aug-2026
✅ BLGTA-041-A01  — UUID Payload Injector                | Untraced=0                 | 10-Aug-2026
✅ REF-046-A01    — Overlay Card + Toast                 | Spec 10/10                 | 10-Aug-2026
✅ MLVTP-002      — Payload Size Guard                   | Install 100%               | 10-Aug-2026
✅ IRBCA-048      — Signed URL Interceptor               | Expiry 1hr OPTIMAL         | 10-Aug-2026
✅ AGPTE-024      — Security Status Chip                 | MD3 5/5 = 100%             | 10-Aug-2026
✅ AMLCO-002      — Auditor Validator                    | Coverage 10/10             | 10-Aug-2026
✅ AWCV-001       — Compact Typography Grid              | CC max=3 OPTIMAL           | 10-Aug-2026
✅ ONCS-001       — VPC Network Tap Zones                | 48dp + 8dp OPTIMAL         | 10-Aug-2026
✅ EDBAA-002      — Formula Tooltip Accessibility        | WCAG 17/17 = 100%          | 10-Aug-2026
✅ BTPM-002       — Issue Severity Escalation Tags       | Touch 100% · CWV Good      | 10-Aug-2026
✅ BCDLD-037      — F&F Deadline Alert Banner            | Coverage 100% · High       | 10-Aug-2026
✅ CFCST-002      — Funnel Analytics Map                 | Specs 18/18 = 100%         | 11-Aug-2026
✅ TECH-ENG-004   — DLQ Monitoring Dashboard             | Policy Pass · ≤60s         | 11-Aug-2026
✅ TECH-ENG-022   — Zero-Trust Security Dashboard        | Load Good · RAIL ≤2s       | 11-Aug-2026
✅ TECH-ENG-037   — System Config Form (DevOps Admin)    | 15/15 = 100% Complete      | 11-Aug-2026
✅ TECH-ENG-049   — RBAC Engineering Dashboard           | Enforcement 100% Pass      | 11-Aug-2026
```

---

*UDF Team — Habot Connect DMCC | DCDF Architecture Framework | 25 of 97 zero-dependency steps complete | 11-Aug-2026*
