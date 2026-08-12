# HABOT Design System — UDF Implementation

**Repository:** `github.com/RitwikHC/theme-typography`
**Branch:** `ritwik`
**Team:** UDF — UX Design & Frontend Engineering | Habot Connect DMCC
**Owner:** Ritwik Sharma — Frontend Integration Specialist
**Framework:** Flutter (Material Design 3)
**Version:** v1 | Last Updated: 12-Aug-2026
**Steps Completed:** 35 of 97 zero-dependency steps

---

## Repository Structure

```
theme-typography/
├── README.md
├── tokens.json                                              ← Step 1
├── lib/core/
│   ├── theme/
│   │   └── app_theme.dart                                   ← Step 1
│   ├── typography/
│   │   ├── dynamic_typography_wrapper.dart                  ← Step 2
│   │   └── compact_typography_grid.dart                     ← Step 16
│   ├── accessibility/
│   │   └── touch_target_wrapper.dart                        ← Step 3
│   ├── interaction/
│   │   └── ripple_feedback.dart                             ← Step 4
│   ├── versioning/
│   │   └── layout_version_control.dart                      ← Step 5
│   ├── components/
│   │   ├── empty_state_widget.dart                          ← Step 6
│   │   ├── trace_time_chart.dart                            ← Step 8
│   │   ├── skeleton_loader.dart                             ← Step 9
│   │   ├── overlay_card.dart                                ← Step 11
│   │   ├── signed_url_card.dart                             ← Step 13
│   │   ├── security_status_chip.dart                        ← Step 14
│   │   ├── network_tap_zone.dart                            ← Step 17
│   │   ├── formula_tooltip.dart                             ← Step 18
│   │   ├── issue_severity_tag.dart                          ← Step 19
│   │   ├── deadline_alert_banner.dart                       ← Step 20
│   │   ├── funnel_analytics_map.dart                        ← Step 21
│   │   ├── dlq_monitoring_dashboard.dart                    ← Step 22
│   │   ├── security_access_dashboard.dart                   ← Step 23
│   │   ├── system_config_form.dart                          ← Step 24
│   │   ├── rbac_dashboard.dart                              ← Step 25
│   │   ├── icon_mapping_matrix.dart                         ← Step 26
│   │   ├── adaptive_layout_grid.dart                        ← Step 27
│   │   ├── vendor_field_constraints.dart                    ← Step 28
│   │   ├── button_touch_sizing_matrix.dart                  ← Step 29
│   │   ├── modal_template_library.dart                      ← Step 30
│   │   ├── mobile_form_library.dart                         ← Step 31
│   │   ├── gacl_shared_components.dart                      ← Step 32
│   │   ├── pipeline_collapsible_card.dart                   ← Step 33
│   │   ├── timeout_escalation_gate.dart                     ← Step 34
│   │   └── vendor_record_card.dart                          ← Step 35
│   ├── network/
│   │   ├── uuid_payload_injector.dart                       ← Step 10
│   │   └── payload_size_guard.dart                          ← Step 12
│   └── compliance/
│       └── auditor_validator.dart                           ← Step 15
└── scripts/
    └── lint_touch_targets.js                                ← Step 3
```

---

## All 35 Steps — Completion Table

| # | Ref | Title | File | Metric | Status |
|---|---|---|---|---|---|
| 1 | BPTR-0544-A01 | Design Tokens + MD3 Theme | `tokens.json` + `app_theme.dart` | Traceability: 100% | ✅ |
| 2 | TTIAS-014-A01 | Dynamic Typography Wrapper | `dynamic_typography_wrapper.dart` | Scale: 100% | ✅ |
| 3 | TTMAC-010-A01 | Touch Target Enforcer + Lint | `touch_target_wrapper.dart` | Conformance: 100% | ✅ |
| 4 | TTMAC-025-A01 | MD3 Ripple Feedback | `ripple_feedback.dart` | 15/15 · 200ms | ✅ |
| 5 | NSKFI-014-A01 | Layout Version Control | `layout_version_control.dart` | Discovery: 100% | ✅ |
| 6 | EDBAA-004-A01 | Empty State Widget | `empty_state_widget.dart` | Coverage: 10/10 | ✅ |
| 7 | BPTR-0693-A01 | Shakti Dashboard (Looker Studio) | Workspace: 7947dda9 | Coverage: 5/5 | ✅ |
| 8 | SLPLU-017-A01 | Trace Time Chart | `trace_time_chart.dart` | Quality: 8/8 | ✅ |
| 9 | SLPLU-005-A01 | Skeleton Loader | `skeleton_loader.dart` | Access: < 200ms | ✅ |
| 10 | BLGTA-041-A01 | UUID Payload Injector | `uuid_payload_injector.dart` | Untraced = 0 | ✅ |
| 11 | REF-046-A01 | Overlay Card + Toast | `overlay_card.dart` | Spec: 10/10 | ✅ |
| 12 | MLVTP-002 | Payload Size Guard | `payload_size_guard.dart` | Install: 100% | ✅ |
| 13 | IRBCA-048 | Signed URL Interceptor | `signed_url_card.dart` | Expiry: 1hr OPTIMAL | ✅ |
| 14 | AGPTE-024 | MD3 Security Status Chip | `security_status_chip.dart` | MD3: 5/5 | ✅ |
| 15 | AMLCO-002 | Auditor Validator | `auditor_validator.dart` | Coverage: 10/10 | ✅ |
| 16 | AWCV-001 | Compact Typography Grid | `compact_typography_grid.dart` | CC max=3 OPTIMAL | ✅ |
| 17 | ONCS-001 | VPC Network Tap Zones | `network_tap_zone.dart` | 48dp + 8dp buffer | ✅ |
| 18 | EDBAA-002 | Formula Tooltip Accessibility | `formula_tooltip.dart` | WCAG 17/17 = 100% | ✅ |
| 19 | BTPM-002 | Issue Severity Escalation Tags | `issue_severity_tag.dart` | Touch 100% · CWV Good | ✅ |
| 20 | BCDLD-037 | F&F Deadline Alert Banner | `deadline_alert_banner.dart` | Alert Coverage: 100% | ✅ |
| 21 | CFCST-002 | Funnel Analytics Map | `funnel_analytics_map.dart` | Specs: 18/18 = 100% | ✅ |
| 22 | TECH-ENG-004 | DLQ Monitoring Dashboard | `dlq_monitoring_dashboard.dart` | Policy: Pass · ≤60s | ✅ |
| 23 | TECH-ENG-022 | Zero-Trust Security Dashboard | `security_access_dashboard.dart` | Load: Good · RAIL ≤2s | ✅ |
| 24 | TECH-ENG-037 | System Config Form (DevOps Admin) | `system_config_form.dart` | Completeness: 15/15 | ✅ |
| 25 | TECH-ENG-049 | RBAC Engineering Dashboard | `rbac_dashboard.dart` | Enforcement: 100% Pass | ✅ |
| 26 | DLQDP-015-01 | Icon Mapping Matrix | `icon_mapping_matrix.dart` | Adherence: 35/35 = 100% | ✅ |
| 27 | PELCE-012-09 | Adaptive Layout Grid (4-col) | `adaptive_layout_grid.dart` | Adherence: 100% · Good | ✅ |
| 28 | EDEBS-002-12 | Vendor Field Constraints | `vendor_field_constraints.dart` | Contrast: 7.2:1 AAA · Pass | ✅ |
| 29 | TTMAC-012-A01 | Button Touch Sizing Matrix | `button_touch_sizing_matrix.dart` | Setup: Pass · All 7 ≥ 48dp | ✅ |
| 30 | FEBFL-037-A01 | Modal Template Library | `modal_template_library.dart` | Discovery: Pass · 1 attempt | ✅ |
| 31 | FLADE-006-01 | Mobile Form Library | `mobile_form_library.dart` | Adherence: 100% · Good | ✅ |
| 32 | CBSV-033-12 | GACL Shared Components | `gacl_shared_components.dart` | Adherence: 100% · Good | ✅ |
| 33 | ONLSC-008-12 | Pipeline Collapsible Card | `pipeline_collapsible_card.dart` | Adherence: 100% · Good | ✅ |
| 34 | GRLIC-020-16 | Timeout Escalation Gate | `timeout_escalation_gate.dart` | CFR: 0% · Rating: Good | ✅ |
| 35 | EDEBS-008-19 | Vendor Record Card | `vendor_record_card.dart` | Touch: 48dp · Pass | ✅ |

---

## Wave 1 — Steps 1–15

**`tokens.json` + `app_theme.dart`** — Design tokens (JSON) and Flutter MD3 theme. Defines `HabotSpacing`, `HabotRadius`, `HabotElevation` constants used by every subsequent file.

**`dynamic_typography_wrapper.dart`** — Dynamic type scale. Poppins (headings) · Inter (body/label). 15 `DynamicTextStyle` static methods.

**`touch_target_wrapper.dart` + `lint_touch_targets.js`** — 48dp minimum touch target enforcer + static lint scanner.

**`ripple_feedback.dart`** — MD3 ripple via `on-surface` token. 200ms. `HabotRipple.wrap()` applies to any widget.

**`layout_version_control.dart`** — Layout version registry. Tracks version, breakpoints, and deprecation per component.

**`empty_state_widget.dart`** — 10 empty state types with icon, title, body, and optional CTA.

**`trace_time_chart.dart`** — Y-axis trace time chart. 8 chart variants for performance monitoring.

**`skeleton_loader.dart`** — Shimmer skeleton loaders (card · list tile · text). Zero network dependency.

**`uuid_payload_injector.dart`** — UUID v4 generator used by Steps 12, 13, 15, 18, 20–35.

**`overlay_card.dart`** — 5 status types. `ToastAlertDispatcher` singleton. Slide-up 300ms. Auto-dismiss 4s.

**`payload_size_guard.dart`** — 150KB mobile · 500KB desktop · 1MB gateway ceiling.

**`signed_url_card.dart`** — GCS signed URL expiry interceptor. 1hr expiry. OWASP ASVS v4.0 V3.

**`security_status_chip.dart`** — 5 MD3 security states. WCAG AAA contrast verified per state.

**`auditor_validator.dart`** — Binary PASS/FAIL auditor. 10 ISO/NIST controls. 7 UAE free zones. Immutable audit trail.

---

## Wave 2 — Steps 16–20

**`compact_typography_grid.dart`** — M3 compact type (10–20px). CC ≤ 5 per function. 3 viewport grid breakpoints.

**`network_tap_zone.dart`** — VPC network dashboard tap zones. 48dp × 48dp + 8dp buffer. `assert(tapSize >= 48.0)`.

**`formula_tooltip.dart`** — Context-sensitive formula tooltips. WCAG 2.1 AA. `FocusNode` + `liveRegion`. 5 formula types.

**`issue_severity_tag.dart`** — MD3 issue severity escalation. 5 severity levels. Touch 100% · CWV Good.

**`deadline_alert_banner.dart`** — Persistent F&F deadline banner. `SlideTransition` 400ms. Per-second countdown. Pub/Sub event on render.

---

## Wave 3 — Steps 21–25

**`funnel_analytics_map.dart`** — Interactive funnel drop-off map. Proportional bars. Monotone integrity check. Telemetry mismatch detection. `FunnelAnalyticsChecker.check()` → 18/18 = 100%.

**`dlq_monitoring_dashboard.dart`** — DLQ backlog depth per topic. Pass/Fail per topic. Alert latency ≤ 60s indicator. No-policy = immediate Fail.

**`security_access_dashboard.dart`** — Zero-Trust access attempts/denials/MFA fallback. RAIL ≤ 2s load (pre-aggregated). Alert banner ≥ 20% denial rate.

**`system_config_form.dart`** — DevOps Admin-only. M3 Switches (binary) + Segmented Buttons (enum). 5 config categories. Config diff + `trace_id` on save.

**`rbac_dashboard.dart`** — 4 roles × 6 sections = 24 combinations. RBAC enforcement 100%. `AccessDeniedCard` for blocked sections. NIST SP 800-53 AC-3/AC-6.

---

## Wave 4 — Steps 26–35

**`icon_mapping_matrix.dart`** — 35 verb → icon mappings across 5 categories. `VerbIconMap.get(verb)` is the only icon access point. `assert` fires for unknown verbs. 6 `HabotIconSize` tokens.

```dart
Icon(VerbIconMap.get('delete'), size: HabotIconSize.lg)
Icon(VerbIconMap.getOutlined('info'), size: HabotIconSize.md)
```

**`adaptive_layout_grid.dart`** — 4-column compact adaptive layout for mobile transaction views. MD3 grid: compact(4/16px/8px) · medium(8/24px/16px) · expanded(12/24px/24px). `EDBaselineField` anchors Transaction Amount to cols 1–2.

```dart
AdaptiveLayoutGrid(child: myTransactionView)
AdaptiveGridRow(spans: [2, 2], children: [amount, date])
EDBaselineField(amount: '1,200.00', date: '12 Aug 2026')
```

**`vendor_field_constraints.dart`** — `vendor_iban` and `net_payout` global constraints. MD3 outlined text fields fire high-contrast red error on empty blur. WCAG 2.2 SC 1.4.6 AAA — 7.2:1 contrast. UAE IBAN: AE + 21 digits = 23 chars.

```dart
VendorIBANField(controller: ibanCtrl)
NetPayoutField(controller: payoutCtrl, grossAmount: 5000.0)
VendorFieldRow(ibanController: c1, payoutController: c2, grossAmount: 5000.0)
```

**`button_touch_sizing_matrix.dart`** — 7 button types on 8dp modular grid. All `tapTargetSize ≥ 48dp`. `HabotButton`, `HabotIconButton`, `ButtonSizingMatrixViewer`.

| Type | Visual H | Tap Target | hPad |
|---|---|---|---|
| Primary | 48dp | 48dp | 24dp |
| Secondary | 48dp | 48dp | 24dp |
| Text | 40dp | 48dp | 12dp |
| Icon | 48dp | 48dp | 12dp |
| FAB | 56dp | 56dp | 16dp |
| Small FAB | 40dp | 48dp | 8dp |

```dart
HabotButton(label: 'Save', type: ButtonType.primary, onPressed: onSave)
HabotIconButton(icon: Icons.close_rounded, semanticLabel: 'Close', onPressed: close)
```

**`modal_template_library.dart`** — 5 modal templates. `ScaleTransition` 200ms. Destructive modals use `errorContainer` + toggle Poka-Yoke. Full-screen on compact viewports.

```dart
ModalTemplateLibrary.showConfirmation(context,
  config: ModalConfig(type: ModalType.confirmation, title: 'Delete vendor',
    isDestructive: true, requiresToggle: true),
  onConfirm: deleteVendor)
ModalTemplateLibrary.showAlert(context, title: 'Session expired', body: 'Sign in again')
```

**`mobile_form_library.dart`** — Multi-step mobile forms with `BacktrackEvent` tracking. `FormStepIndicator` shows completed/current/visited states. Back-navigation log fires analytics per step.

```dart
MultiStepMobileForm(
  steps: [FormStep(id: 's1', title: 'Vendor details', content: form1), ...],
  onComplete:  () => submit(),
  onBacktrack: (e) => analytics.track(e.toMap()),
)
```

**`gacl_shared_components.dart`** — GACL shared components library. `GACLStatusMatrix` maps database lookup joints to matrix presentation columns. 4 status states: active · warning · error · idle.

```dart
GACLStatusMatrix(
  title: 'Pipeline status',
  entries: [StatusMatrixEntry(id: '1', label: 'Build', value: 'Passing', status: 'active', ...)],
  onEntryTap: (e) => openDetail(e.id),
)
```

**`pipeline_collapsible_card.dart`** — Hides deep pipeline path details. 48dp header always visible. `SizeTransition` + `RotationTransition` 220ms. Expanded reveals full path items with pass/fail/warn icons.

```dart
PipelineCollapsibleCard(
  data: PipelineCardData(
    id: 'p1', pipelineName: 'habot-prod-build',
    summary: 'Build passing · 3 steps', status: 'pass',
    pathItems: [PipelinePathItem(step: 'Lint', path: 'src/lint/', status: 'pass')],
  ),
)
```

**`timeout_escalation_gate.dart`** — CI gate for task layouts. No `TimeoutConfig` = FAIL (errorContainer block). Valid config = PASS badge. DORA CFR metric. `EscalationRecord` with `trace_id` on every gate check.

```dart
TimeoutEscalationGate(
  taskName: 'vendor-approval',
  config:   TimeoutConfig(timeout: Duration(seconds: 300), warningAt: Duration(seconds: 270), escalationTarget: 'ops@habot.com'),
  child:    myTaskLayout,
  onEscalation: (record) => bigQuery.insert(record.toMap()),
)
```

**`vendor_record_card.dart`** — Stacked verified vendor record. `_touchPadding = 48.0` const. `TouchTargetProof` mathematically proves WCAG 2.5.5 compliance. IBAN masked. `VendorRecordAccessLog` + `trace_id` on every tap.

```dart
VendorRecordCard(
  record:  VerifiedVendorRecord(recordId: 'VND-001', vendorName: 'Acme Trading LLC', ...),
  userRole: 'Finance Admin',
  onTap:   () => openVendorDetail(),
  onAccessLog: (log) => bigQuery.insert(log.toMap()),
)
print(TouchTargetProof.proof)
// VendorRecordCard._touchPadding = 48.0dp → WCAG 2.5.5 ✅
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

## All 35 Completion Banners

```
✅ BPTR-0544-A01  Design Tokens + MD3 Theme              Traceability 100%           10-Aug-2026
✅ TTIAS-014-A01  Dynamic Typography Wrapper              Scale 100%                  10-Aug-2026
✅ TTMAC-010-A01  Touch Target Enforcer + Lint            Conformance 100%            10-Aug-2026
✅ TTMAC-025-A01  MD3 Ripple Feedback                     15/15 · 200ms               10-Aug-2026
✅ NSKFI-014-A01  Layout Version Control                  Discovery 10/10             10-Aug-2026
✅ EDBAA-004-A01  Empty State Widget                      Coverage 10/10              10-Aug-2026
✅ BPTR-0693-A01  Shakti Dashboard                        Coverage 5/5                10-Aug-2026
✅ SLPLU-017-A01  Trace Time Chart                        Quality 8/8                 10-Aug-2026
✅ SLPLU-005-A01  Skeleton Loader                         Access <200ms               10-Aug-2026
✅ BLGTA-041-A01  UUID Payload Injector                   Untraced=0                  10-Aug-2026
✅ REF-046-A01    Overlay Card + Toast                    Spec 10/10                  10-Aug-2026
✅ MLVTP-002      Payload Size Guard                      Install 100%                10-Aug-2026
✅ IRBCA-048      Signed URL Interceptor                  Expiry 1hr OPTIMAL          10-Aug-2026
✅ AGPTE-024      MD3 Security Status Chip                MD3 5/5 = 100%              10-Aug-2026
✅ AMLCO-002      Auditor Validator                       Coverage 10/10              10-Aug-2026
✅ AWCV-001       Compact Typography Grid                 CC max=3 OPTIMAL            10-Aug-2026
✅ ONCS-001       VPC Network Tap Zones                   48dp + 8dp OPTIMAL          10-Aug-2026
✅ EDBAA-002      Formula Tooltip Accessibility           WCAG 17/17 = 100%           10-Aug-2026
✅ BTPM-002       Issue Severity Escalation Tags          Touch 100% · CWV Good       10-Aug-2026
✅ BCDLD-037      F&F Deadline Alert Banner               Coverage 100% · High        10-Aug-2026
✅ CFCST-002      Funnel Analytics Map                    Specs 18/18 = 100%          11-Aug-2026
✅ TECH-ENG-004   DLQ Monitoring Dashboard                Policy Pass · ≤60s          11-Aug-2026
✅ TECH-ENG-022   Zero-Trust Security Dashboard           Load Good · RAIL ≤2s        11-Aug-2026
✅ TECH-ENG-037   System Config Form (DevOps Admin)       15/15 = 100% Complete       11-Aug-2026
✅ TECH-ENG-049   RBAC Engineering Dashboard              Enforcement 100% Pass       11-Aug-2026
✅ DLQDP-015-01   Icon Mapping Matrix                     Adherence 35/35 = 100%      12-Aug-2026
✅ PELCE-012-09   Adaptive Layout Grid (4-col)            Adherence 100% · Good       12-Aug-2026
✅ EDEBS-002-12   Vendor Field Constraints                Contrast 7.2:1 AAA · Pass   12-Aug-2026
✅ TTMAC-012-A01  Button Touch Sizing Matrix              Setup Pass · All 7 ≥ 48dp   12-Aug-2026
✅ FEBFL-037-A01  Modal Template Library                  Discovery Pass · 1 attempt  12-Aug-2026
✅ FLADE-006-01   Mobile Form Library                     Adherence 100% · Good       12-Aug-2026
✅ CBSV-033-12    GACL Shared Components                  Adherence 100% · Good       12-Aug-2026
✅ ONLSC-008-12   Pipeline Collapsible Card               Adherence 100% · Good       12-Aug-2026
✅ GRLIC-020-16   Timeout Escalation Gate                 CFR 0% · Rating: Good       12-Aug-2026
✅ EDEBS-008-19   Vendor Record Card                      Touch 48dp · Pass           12-Aug-2026
```

---

*UDF Team — Habot Connect DMCC | DCDF Architecture Framework | 35 of 97 zero-dependency steps complete | 12-Aug-2026*
