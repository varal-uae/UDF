# HABOT Design System — UDF Implementation

**Repository:** `github.com/RitwikHC/theme-typography`
**Branch:** `ritwik`
**Team:** UDF — UX Design & Frontend Engineering | Habot Connect DMCC
**Owner:** Ritwik Sharma — Frontend Integration Specialist
**Framework:** Flutter (Material Design 3) · Poppins (headings) · Inter (body)
**Last Updated:** 18-Aug-2026
**Steps Completed:** 80 of 97 zero-dependency steps
**Dart Files:** 76 files (59 standalone · 17 extended) · all audited

---

## Repository Structure

```
theme-typography/
├── README.md
├── tokens.json                                                    ← Step 1
├── lib/core/
│   ├── theme/
│   │   └── app_theme.dart                                         ← Step 1
│   ├── typography/
│   │   ├── dynamic_typography_wrapper.dart                        ← Step 2
│   │   └── compact_typography_grid.dart                           ← Step 16
│   ├── accessibility/
│   │   └── touch_target_wrapper.dart                              ← Step 3
│   ├── interaction/
│   │   └── ripple_feedback.dart                                   ← Step 4
│   ├── versioning/
│   │   └── layout_version_control.dart                            ← Step 5
│   ├── compliance/
│   │   └── auditor_validator.dart                                 ← Step 15
│   ├── network/
│   │   ├── uuid_payload_injector.dart                             ← Step 10
│   │   └── payload_size_guard.dart                                ← Step 12
│   └── components/
│       ├── empty_state_widget.dart                                ← Step 6
│       ├── trace_time_chart.dart                                  ← Step 8
│       ├── skeleton_loader.dart                                   ← Step 9
│       ├── overlay_card.dart                                      ← Step 11
│       ├── signed_url_card.dart                                   ← Step 13
│       ├── security_status_chip.dart                              ← Step 14
│       ├── network_tap_zone.dart                                   ← Step 17
│       ├── formula_tooltip.dart                                   ← Step 18
│       ├── issue_severity_tag.dart                                ← Step 19
│       ├── deadline_alert_banner.dart                             ← Step 20
│       ├── funnel_analytics_map.dart                              ← Step 21
│       ├── dlq_monitoring_dashboard.dart                          ← Step 22
│       ├── security_access_dashboard.dart                         ← Step 23
│       ├── system_config_form.dart                                ← Step 24
│       ├── rbac_dashboard.dart                                    ← Step 25 + Step 78 ext
│       ├── icon_mapping_matrix.dart                               ← Step 26
│       ├── adaptive_layout_grid.dart                              ← Step 27
│       ├── vendor_field_constraints.dart                          ← Step 28
│       ├── button_touch_sizing_matrix.dart                        ← Step 29
│       ├── modal_template_library.dart                            ← Step 30
│       ├── mobile_form_library.dart                               ← Step 31
│       ├── gacl_shared_components.dart                            ← Step 32
│       ├── pipeline_collapsible_card.dart                         ← Step 33
│       ├── timeout_escalation_gate.dart                           ← Step 34
│       ├── vendor_record_card.dart                                ← Step 35
│       ├── form_schema_repository.dart                            ← Step 36
│       ├── sliding_metrics_sheet.dart                             ← Step 37
│       ├── compact_screen_template.dart                           ← Step 38 + Step 69 ext
│       ├── responsive_reflow_wrapper.dart                         ← Step 39
│       ├── mobile_progress_stepper.dart                           ← Step 40
│       ├── tablet_css_stacking.dart                               ← Step 41
│       ├── responsive_image_loader.dart                           ← Step 42
│       ├── md3_progress_stepper.dart                              ← Step 43
│       ├── side_sheet_disclosure.dart                             ← Step 44
│       ├── tooltip_dismissal.dart                                 ← Step 45 + Step 79 ext
│       ├── ec_verb_cta.dart                                       ← Step 46
│       ├── shakti_alert_panel.dart                                ← Step 47 + Step 76 ext
│       ├── image_capture_overlay.dart                             ← Step 48
│       ├── ec_verb_refactor.dart                                  ← Step 49
│       ├── context_pruning_overlay.dart                           ← Step 50
│       ├── pre_execution_boolean_check.dart                       ← Step 51
│       ├── friction_log_cascade.dart                              ← Step 52
│       ├── ec_verb_qa_test_runner.dart                            ← Step 53
│       ├── release_gate_lock.dart                                 ← Step 54
│       ├── id_suffix_linter.dart                                  ← Step 55
│       ├── peer_nomination_quota.dart                             ← Step 56
│       ├── multi_tenant_workspace_wall.dart                       ← Step 57
│       ├── dynamic_touch_target_padding.dart                      ← Step 58 + Step 70 ext
│       ├── split_screen_mirror_template.dart                      ← Step 59 + Step 66 ext
│       ├── f_pattern_dashboard.dart                               ← Step 60
│       ├── progressive_bottom_sheet.dart                          ← Step 61
│       ├── dynamic_form_assembler.dart                            ← Step 62
│       ├── vat_invoice_schema.dart                                ← Step 63
│       ├── image_ingress_animator.dart                            ← Step 64
│       ├── task_latency_monitor.dart                              ← Step 65
│       ├── infinite_scroll_manager.dart                           ← Step 67
│       ├── gamification_badge.dart                                ← Step 68
│       ├── conditional_upload_gate.dart                           ← Step 71
│       ├── format_constraint_cell.dart                            ← Step 72
│       ├── skeleton_loader_dynamic.dart                           ← Step 73
│       ├── pagination_limit_manager.dart                          ← Step 74
│       ├── jwt_task_verification.dart                             ← Step 75
│       ├── text_fragment_database.dart                            ← Step 77
│       └── hpf_attachment_indicator.dart                          ← Step 80
└── scripts/
    └── lint_touch_targets.js                                      ← Step 3
```

---

## All 80 Steps — Completion Table

| # | S.No | Ref | Title | File | Metric | Status |
|---|---|---|---|---|---|---|
| 1 | 2 | BPTR-0544 | Design Tokens + MD3 Theme | `app_theme.dart` | Traceability 100% | ✅ |
| 2 | 79 | TTIAS-014 | Dynamic Typography Wrapper | `dynamic_typography_wrapper.dart` | Scale 100% | ✅ |
| 3 | 90 | TTMAC-010 | Touch Target Enforcer + Lint | `touch_target_wrapper.dart` | Conformance 100% | ✅ |
| 4 | 112 | TTMAC-025 | MD3 Ripple Feedback | `ripple_feedback.dart` | 15/15 · 200ms | ✅ |
| 5 | 156 | NSKFI-014 | Layout Version Control | `layout_version_control.dart` | Discovery 100% | ✅ |
| 6 | 343 | EDBAA-004 | Empty State Widget | `empty_state_widget.dart` | 10/10 types | ✅ |
| 7 | 354 | BPTR-0693 | Shakti Dashboard (Looker Studio) | Workspace: 7947dda9 | 5/5 panels | ✅ |
| 8 | 365 | SLPLU-017 | Trace Time Chart | `trace_time_chart.dart` | 8/8 variants | ✅ |
| 9 | 376 | SLPLU-005 | Skeleton Loader | `skeleton_loader.dart` | < 200ms | ✅ |
| 10 | 387 | BLGTA-041 | UUID Payload Injector | `uuid_payload_injector.dart` | Untraced = 0 | ✅ |
| 11 | 398 | REF-046 | Overlay Card + Toast | `overlay_card.dart` | 10/10 specs | ✅ |
| 12 | 882 | MLVTP-002 | Payload Size Guard | `payload_size_guard.dart` | Rejection 0% | ✅ |
| 13 | 948 | IRBCA-048 | Signed URL Interceptor | `signed_url_card.dart` | 1hr expiry | ✅ |
| 14 | 1091 | AGPTE-024 | MD3 Security Status Chip | `security_status_chip.dart` | WCAG AAA 5/5 | ✅ |
| 15 | 1311 | AMLCO-002 | Auditor Validator | `auditor_validator.dart` | 10/10 controls | ✅ |
| 16 | 1366 | AWCV-001 | Compact Typography Grid | `compact_typography_grid.dart` | CC ≤ 3 | ✅ |
| 17 | 1421 | ONCS-001 | VPC Network Tap Zones | `network_tap_zone.dart` | 48dp + 8dp | ✅ |
| 18 | 1443 | EDBAA-002 | Formula Tooltip Accessibility | `formula_tooltip.dart` | WCAG 17/17 | ✅ |
| 19 | 1487 | BTPM-002 | Issue Severity Tags | `issue_severity_tag.dart` | Touch 100% | ✅ |
| 20 | 1498 | BCDLD-037 | F&F Deadline Alert Banner | `deadline_alert_banner.dart` | Countdown active | ✅ |
| 21 | 1509 | CFCST-002 | Funnel Analytics Map | `funnel_analytics_map.dart` | 18/18 specs | ✅ |
| 22 | 1520 | TECH-ENG-004 | DLQ Monitoring Dashboard | `dlq_monitoring_dashboard.dart` | Alert ≤ 60s | ✅ |
| 23 | 1531 | TECH-ENG-022 | Zero-Trust Security Dashboard | `security_access_dashboard.dart` | RAIL ≤ 2s | ✅ |
| 24 | 1542 | TECH-ENG-037 | System Config Form | `system_config_form.dart` | 15/15 fields | ✅ |
| 25 | 1553 | TECH-ENG-049 | RBAC Engineering Dashboard | `rbac_dashboard.dart` | 24/24 combos | ✅ |
| 26 | 1564 | DLQDP-015-01 | Icon Mapping Matrix | `icon_mapping_matrix.dart` | 35/35 verbs | ✅ |
| 27 | 1608 | PELCE-012-09 | Adaptive Layout Grid | `adaptive_layout_grid.dart` | Adherence 100% | ✅ |
| 28 | 1619 | EDEBS-002-12 | Vendor Field Constraints | `vendor_field_constraints.dart` | 7.2:1 AAA | ✅ |
| 29 | 1652 | TTMAC-012 | Button Touch Sizing Matrix | `button_touch_sizing_matrix.dart` | 7/7 ≥ 48dp | ✅ |
| 30 | 1784 | FEBFL-037 | Modal Template Library | `modal_template_library.dart` | 5/5 modals | ✅ |
| 31 | 1795 | FLADE-006-01 | Mobile Form Library | `mobile_form_library.dart` | BacktrackEvent | ✅ |
| 32 | 1806 | CBSV-033-12 | GACL Shared Components | `gacl_shared_components.dart` | 8/8 components | ✅ |
| 33 | 1883 | ONLSC-008-12 | Pipeline Collapsible Card | `pipeline_collapsible_card.dart` | 220ms anim | ✅ |
| 34 | 1905 | GRLIC-020-16 | Timeout Escalation Gate | `timeout_escalation_gate.dart` | CFR 0% | ✅ |
| 35 | 2026 | EDEBS-008-19 | Vendor Record Card | `vendor_record_card.dart` | 48dp proved | ✅ |
| 36 | 2037 | FIEVR-018 | Form Schema Repository | `form_schema_repository.dart` | 1 field/task | ✅ |
| 37 | 2070 | ERMWD-004-14 | Sliding Metrics Sheet | `sliding_metrics_sheet.dart` | 3 snap points | ✅ |
| 38 | 2103 | SSTLA-015 | Compact Screen Template | `compact_screen_template.dart` | 3/3 boundaries | ✅ |
| 39 | 2114 | TNRML-001 | Responsive Reflow Wrapper | `responsive_reflow_wrapper.dart` | 5/5 grids | ✅ |
| 40 | 2136 | HC-SCH-0015 | Mobile Progress Stepper | `mobile_progress_stepper.dart` | p95 < 400ms | ✅ |
| 41 | 2224 | ARCPE-016-06 | Tablet CSS Stacking | `tablet_css_stacking.dart` | 48dp WCAG AA | ✅ |
| 42 | 2301 | AEETE-030-09 | Responsive Image Loader | `responsive_image_loader.dart` | CLS = 0 | ✅ |
| 43 | 2466 | CFCST-007 | MD3 Progress Stepper | `md3_progress_stepper.dart` | CWV Good | ✅ |
| 44 | 2488 | RCGLA-004 | Side Sheet Disclosure | `side_sheet_disclosure.dart` | 250ms slide | ✅ |
| 45 | 2499 | MTVPE-021 | Tooltip Dismissal | `tooltip_dismissal.dart` | Quality 99% | ✅ |
| 46 | 2664 | PELCE-019-06 | EC System Verbs on CTAs | `ec_verb_cta.dart` | 28 verbs 100% | ✅ |
| 47 | 2686 | FLADE-011-07 | Shakti Alert Panel | `shakti_alert_panel.dart` | P1 un-ignorable | ✅ |
| 48 | 2719 | ARCPE-017-08 | Image Capture Overlay | `image_capture_overlay.dart` | Accuracy ≥ 97% | ✅ |
| 49 | 2741 | PELCE-019-08 | EC Verb Refactor | `ec_verb_refactor.dart` | 28 mappings | ✅ |
| 50 | 2752 | ARCPE-009-09 | Context Pruning Overlay | `context_pruning_overlay.dart` | 80%/95% gates | ✅ |
| 51 | 2774 | FCSES-001 | Pre-Execution Boolean Check | `pre_execution_boolean_check.dart` | MD3 100% | ✅ |
| 52 | 2818 | FLADE-008-10 | Friction Log Cascade | `friction_log_cascade.dart` | Quality ≥ 98% | ✅ |
| 53 | 2862 | PELCE-019-11 | EC Verb QA Test Runner | `ec_verb_qa_test_runner.dart` | Coverage 100% | ✅ |
| 54 | 2884 | AEETE-027-12 | Release Gate Lock | `release_gate_lock.dart` | CFR 0% | ✅ |
| 55 | 2928 | CBSV-005-13 | _ID Suffix Linter | `id_suffix_linter.dart` | Contrast 7:1 AAA | ✅ |
| 56 | 3027 | RRCVG-033 | Peer Nomination Quota | `peer_nomination_quota.dart` | Success ≥ 99.5% | ✅ |
| 57 | 3038 | RECET-008 | Multi-Tenant Workspace Wall | `multi_tenant_workspace_wall.dart` | Isolation 100% | ✅ |
| 58 | 3049 | TTMAC-016 | Dynamic Touch Target Padding | `dynamic_touch_target_padding.dart` | 48dp enforced | ✅ |
| 59 | 3060 | SSELC-013 | Split-Screen Mirror Template | `split_screen_mirror_template.dart` | 50/50 split | ✅ |
| 60 | 3071 | BPTR-0019 | F-Pattern Dashboard | `f_pattern_dashboard.dart` | Consistency ≥ 97% | ✅ |
| 61 | 3082 | BPTR-0392 | Progressive Bottom Sheet | `progressive_bottom_sheet.dart` | Mapping ≥ 99.5% | ✅ |
| 62 | 3093 | FIEVR-028 | Dynamic Form Assembler | `dynamic_form_assembler.dart` | Error rate < 0.5% | ✅ |
| 63 | 3104 | SSITI-010 | VAT Invoice Schema | `vat_invoice_schema.dart` | Query < 1.0s | ✅ |
| 64 | 3115 | MUFCE-011 | Image Ingress Animator | `image_ingress_animator.dart` | 5/5 slots · 200ms | ✅ |
| 65 | 3126 | BTPM-026 | Task Latency Monitor | `task_latency_monitor.dart` | 7/7 ops · SLA 30m | ✅ |
| 66 | 3137 | SSELC-009 | MTO Split-Screen Portrait Lock | `split_screen_mirror_template.dart` (ext) | Config 100% | ✅ |
| 67 | 3148 | SGTIM-005 | Infinite Scroll Manager | `infinite_scroll_manager.dart` | ≤ 200ms | ✅ |
| 68 | 3159 | TTCFC-006 | Gamification Badge | `gamification_badge.dart` | 8/8 catalog | ✅ |
| 69 | 3170 | SSTLA-024 | Low-Res Display Constraints | `compact_screen_template.dart` (ext) | 4/4 specs | ✅ |
| 70 | 3181 | SGTIM-008 | FAB Action Menu | `dynamic_touch_target_padding.dart` (ext) | Access 0.99 | ✅ |
| 71 | 3192 | MUFCE-019 | Conditional Upload Gate | `conditional_upload_gate.dart` | DCYN 100% | ✅ |
| 72 | 3203 | IS03-CSIVW-007-AS01 | Format Constraint Cells | `format_constraint_cell.dart` | 10/10 cells | ✅ |
| 73 | 3214 | IS41-SLPLU-016-AS01 | Skeleton Loader Dynamic | `skeleton_loader_dynamic.dart` | 10/10 mapped | ✅ |
| 74 | 3225 | SGTIM-001 | Pagination Limit Manager | `pagination_limit_manager.dart` | 10/10 lists | ✅ |
| 75 | 3236 | REF-121 | JWT Task Verification | `jwt_task_verification.dart` | Arch Complete | ✅ |
| 76 | 3247 | FLADE-011-01 | Shakti Root View Integration | `shakti_alert_panel.dart` (ext) | Adherence ≥ 95% | ✅ |
| 77 | 3258 | SIDM-008-01 | Text Fragment Database | `text_fragment_database.dart` | 8 fragments | ✅ |
| 78 | 3269 | IRBCA-028 | Analytics View Authorization | `rbac_dashboard.dart` (ext) | Reuse 85% DRY | ✅ |
| 79 | 3280 | MTVPE-013 | Feature Tour Onboarding | `tooltip_dismissal.dart` (ext) | Quality ≥ 99% | ✅ |
| 80 | 3291 | MUFCE-027 | HPF Mandatory Attachment | `hpf_attachment_indicator.dart` | Listeners 99% | ✅ |

---

## Audit Log

### 13-Aug-2026 — Structural audit (Round 1)
9 Wave 1 files patched: missing `toMap()` + checker classes, hardcoded hex → MD3 scheme tokens, import paths corrected.

### 13-Aug-2026 — Logic & code quality audit (Round 2)
6 files patched: `setState()` extracted from `build()` into named methods · `Semantics` wrappers added to all `InkWell`/`GestureDetector` elements.

### 14-Aug-2026 — Step numbering corrected (Steps 48–50)
Previous mapping had `FLADE-011-07` at Step 50. Corrected per zero-dependency tab: Steps 48–50 are now `ARCPE-017-08` · `PELCE-019-08` · `ARCPE-009-09`. Three files rebuilt.

### 17-Aug-2026 — Steps 51–70 complete
30 new/extended files. 3 files extended with new sections appended (original code intact): `split_screen_mirror_template.dart` (SSELC-009) · `compact_screen_template.dart` (SSTLA-024) · `dynamic_touch_target_padding.dart` (SGTIM-008).

### 18-Aug-2026 — Steps 71–80 complete
10 new/extended files. 3 extended: `shakti_alert_panel.dart` (FLADE-011-01) · `rbac_dashboard.dart` (IRBCA-028) · `tooltip_dismissal.dart` (MTVPE-013).

---

## Extended Files — Extension Registry

| File | Original Step | Extension Step | What was added |
|---|---|---|---|
| `split_screen_mirror_template.dart` | 59 — SSELC-013 | 66 — SSELC-009 | `MTOSplitScreen` · portrait lock · `KeyboardAvoider` |
| `compact_screen_template.dart` | 38 — SSTLA-015 | 69 — SSTLA-024 | `LowResSpecRegistry` · `LowResConstraintWrapper` · 320px constraints |
| `dynamic_touch_target_padding.dart` | 58 — TTMAC-016 | 70 — SGTIM-008 | `HabotFABActionMenu` · `@habot-core/floating-action-menu` · 220ms |
| `shakti_alert_panel.dart` | 47 — FLADE-011-07 | 76 — FLADE-011-01 | `RootViewHierarchyController` · adherence rate tracking |
| `rbac_dashboard.dart` | 25 — TECH-ENG-049 | 78 — IRBCA-028 | `AnalyticsViewAuthorization` · 3 analytics roles · 85% DRY |
| `tooltip_dismissal.dart` | 45 — MTVPE-021 | 79 — MTVPE-013 | `FeatureTourController` · 5-step feature tour · dismiss on every step |

---

## Key Usage Examples

```dart
// EC Verb CTA — only CTA button in the app (Step 46)
ECVerbCTAButton(verb: ECVerb.submit, onPressed: submitVendor)
ECVerbRow(primary: ECVerb.confirm, onPrimary: confirm,
          secondary: ECVerb.cancel, onSecondary: cancel)

// Shakti Alert Panel — global P1 breach (Step 47 + 76)
ShaktiTelemetryListener.triggerP1(context, 'P1 breach detected')

// Progressive Bottom Sheet — cascading logic tree (Step 61)
ProgressiveBottomSheet.show(context,
  title: 'Select Category',
  rootNodes: myLogicTree,
  onApply: (node) => handleSelection(node))

// Dynamic Form Assembler — data blindness (Step 62)
DynamicFormAssembler(
  formId: 'vendor-onboard',
  fieldDescriptors: [
    FieldDescriptor(id: 'iban', label: 'IBAN', type: FieldType.iban,
      validationRegex: r'^AE\d{21}$'),
    FieldDescriptor(id: 'amount', label: 'Amount', type: FieldType.currency),
  ],
  onSubmit: (values) => processForm(values))

// VAT Invoice — UAE VAT 5% auto-calc (Step 63)
VATInvoiceForm(onSubmit: (invoice) => submitToGACL(invoice))
UAEVATConstants.calculateVAT(1000.0) // → 50.0

// Infinite Scroll — pre-fetch at 80% (Step 67)
InfiniteScrollManager<Vendor>(
  listId: 'vendor-list',
  itemBuilder: (ctx, v, i) => VendorTile(vendor: v),
  onFetchMore: (cursor) => api.fetchVendors(cursor: cursor))

// Gamification Badge — real-time state (Step 68)
GamificationBadgeGrid(
  currentValues: {'tasks_under_sla': 8, 'error_free_tasks': 22})

// MTO Split-Screen — portrait lock (Step 66)
MTOSplitScreen(
  taskId: 'mto-task-001',
  evidencePanel: DocumentViewer(doc: evidence),
  inputPanel: DataEntryForm(onSubmit: submit))

// JWT Task Guard — stateless edge (Step 75)
TaskAccessGuard(token: currentToken, child: TaskWorkspace(taskId: task.id))

// Pagination — hard ceiling 20 (Step 74)
PaginationLimitManager<Transaction>(
  listId: 'PL-002',
  itemBuilder: (ctx, tx, i) => TransactionTile(tx: tx),
  onFetch: (cursor) => api.fetchTransactions(cursor: cursor))

// Conditional Upload Gate — DCYN verification (Step 71)
ConditionalUploadGate(
  label: 'Compliance Document',
  verificationQuestions: [
    UploadVerificationQuestion(id: 'q1',
      question: 'Is the document dated within 30 days?'),
  ],
  onSave: (fileName) => processUpload(fileName))

// HPF Attachment — mandatory indicator (Step 80)
HPFAttachmentIndicator(
  onAttached: (attachment) => form.setAttachment(attachment))

// Feature Tour — step-by-step onboarding (Step 79)
FeatureTourController(autoStart: isFirstLogin, child: myDashboard)
```

---

## OPS Alignment

| OPS Phase | Files |
|---|---|
| Phase 3 — System Verbs Only | `ec_verb_cta.dart` · `ec_verb_refactor.dart` · `ec_verb_qa_test_runner.dart` |
| Phase 5 — DCYN Gate | `timeout_escalation_gate.dart` · `image_capture_overlay.dart` · `conditional_upload_gate.dart` · `pre_execution_boolean_check.dart` · `modal_template_library.dart` |
| Phase 6 — Triangular Check | `vendor_field_constraints.dart` · `payload_size_guard.dart` · `format_constraint_cell.dart` |
| Phase 7 — MTB API (< 15 min) | `tooltip_dismissal.dart` · `mobile_form_library.dart` · `task_latency_monitor.dart` |
| Phase 8 — Shakti Resilience | `shakti_alert_panel.dart` · `dlq_monitoring_dashboard.dart` · `context_pruning_overlay.dart` |
| BigQuery Lineage | All 76 files — `toMap()` + `trace_id` UUID v4 per event |
| JWT / Security | `jwt_task_verification.dart` · `signed_url_card.dart` · `rbac_dashboard.dart` |
| Analytics Authorization | `rbac_dashboard.dart` (IRBCA-028 ext) — 3 analytics roles · DRY 85% |

---

## Design System Tokens

```dart
// Spacing
HabotSpacing.xs   // 4dp   HabotSpacing.sm  // 8dp
HabotSpacing.md   // 16dp  HabotSpacing.lg  // 24dp
HabotSpacing.xl   // 32dp  HabotSpacing.xxl // 48dp

// Corner radius
HabotRadius.sm    // 8dp — chips, small buttons
HabotRadius.md    // 12dp — cards, inputs
HabotRadius.lg    // 16dp — bottom sheets, modals
HabotRadius.full  // fully round — pills, circles

// Touch targets
44dp // minimum (WCAG floor)
48dp // comfortable (target for all components)
56dp // spacious (key actions)
```

---

## pubspec.yaml — Fonts

```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
      - asset: assets/fonts/Poppins-Medium.ttf     # weight: 500
      - asset: assets/fonts/Poppins-SemiBold.ttf   # weight: 600
      - asset: assets/fonts/Poppins-Bold.ttf        # weight: 700
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Medium.ttf        # weight: 500
```

> **Font decision:** HABOT Design System Reference Guide v1.0 specifies Roboto. Per Ritwik Sharma's implementation decision, **Poppins overrides Roboto** for headings and **Inter** for body/label. This is the authoritative decision for this repo.

---

## Completion Banners

```
✅ BPTR-0544       Design Tokens + MD3 Theme              S.No 2      10-Aug-2026
✅ TTIAS-014       Dynamic Typography Wrapper              S.No 79     10-Aug-2026
✅ TTMAC-010       Touch Target Enforcer + Lint            S.No 90     10-Aug-2026
✅ TTMAC-025       MD3 Ripple Feedback                     S.No 112    10-Aug-2026
✅ NSKFI-014       Layout Version Control                  S.No 156    10-Aug-2026
✅ EDBAA-004       Empty State Widget                      S.No 343    10-Aug-2026
✅ BPTR-0693       Shakti Dashboard (Looker Studio)        S.No 354    10-Aug-2026
✅ SLPLU-017       Trace Time Chart                        S.No 365    10-Aug-2026
✅ SLPLU-005       Skeleton Loader                         S.No 376    10-Aug-2026
✅ BLGTA-041       UUID Payload Injector                   S.No 387    10-Aug-2026
✅ REF-046         Overlay Card + Toast                    S.No 398    10-Aug-2026
✅ MLVTP-002       Payload Size Guard                      S.No 882    10-Aug-2026
✅ IRBCA-048       Signed URL Interceptor                  S.No 948    10-Aug-2026
✅ AGPTE-024       MD3 Security Status Chip                S.No 1091   10-Aug-2026
✅ AMLCO-002       Auditor Validator                       S.No 1311   10-Aug-2026
✅ AWCV-001        Compact Typography Grid                 S.No 1366   10-Aug-2026
✅ ONCS-001        VPC Network Tap Zones                   S.No 1421   10-Aug-2026
✅ EDBAA-002       Formula Tooltip Accessibility           S.No 1443   10-Aug-2026
✅ BTPM-002        Issue Severity Escalation Tags          S.No 1487   10-Aug-2026
✅ BCDLD-037       F&F Deadline Alert Banner               S.No 1498   10-Aug-2026
✅ CFCST-002       Funnel Analytics Map                    S.No 1509   11-Aug-2026
✅ TECH-ENG-004    DLQ Monitoring Dashboard                S.No 1520   11-Aug-2026
✅ TECH-ENG-022    Zero-Trust Security Dashboard           S.No 1531   11-Aug-2026
✅ TECH-ENG-037    System Config Form                      S.No 1542   11-Aug-2026
✅ TECH-ENG-049    RBAC Engineering Dashboard              S.No 1553   11-Aug-2026
✅ DLQDP-015-01    Icon Mapping Matrix                     S.No 1564   12-Aug-2026
✅ PELCE-012-09    Adaptive Layout Grid (4-col)            S.No 1608   12-Aug-2026
✅ EDEBS-002-12    Vendor Field Constraints                S.No 1619   12-Aug-2026
✅ TTMAC-012       Button Touch Sizing Matrix              S.No 1652   12-Aug-2026
✅ FEBFL-037       Modal Template Library                  S.No 1784   12-Aug-2026
✅ FLADE-006-01    Mobile Form Library                     S.No 1795   12-Aug-2026
✅ CBSV-033-12     GACL Shared Components                  S.No 1806   12-Aug-2026
✅ ONLSC-008-12    Pipeline Collapsible Card               S.No 1883   12-Aug-2026
✅ GRLIC-020-16    Timeout Escalation Gate                 S.No 1905   12-Aug-2026
✅ EDEBS-008-19    Vendor Record Card                      S.No 2026   12-Aug-2026
✅ FIEVR-018       Form Schema Repository                  S.No 2037   13-Aug-2026
✅ ERMWD-004-14    Sliding Metrics Sheet                   S.No 2070   13-Aug-2026
✅ SSTLA-015       Compact Screen Template                 S.No 2103   13-Aug-2026
✅ TNRML-001       Responsive Reflow Wrapper               S.No 2114   13-Aug-2026
✅ HC-SCH-0015     Mobile Progress Stepper                 S.No 2136   13-Aug-2026
✅ ARCPE-016-06    Tablet CSS Stacking                     S.No 2224   13-Aug-2026
✅ AEETE-030-09    Responsive Image Loader                 S.No 2301   13-Aug-2026
✅ CFCST-007       MD3 Progress Stepper                    S.No 2466   13-Aug-2026
✅ RCGLA-004       Side Sheet Disclosure                   S.No 2488   13-Aug-2026
✅ MTVPE-021       Tooltip Dismissal Buttons               S.No 2499   13-Aug-2026
✅ PELCE-019-06    EC System Verbs on CTAs                 S.No 2664   13-Aug-2026
✅ FLADE-011-07    Shakti Alert Panel                      S.No 2686   13-Aug-2026
✅ ARCPE-017-08    Image Capture Overlay                   S.No 2719   14-Aug-2026
✅ PELCE-019-08    EC Verb Refactor — 28 Mappings          S.No 2741   14-Aug-2026
✅ ARCPE-009-09    Context Pruning Warning Overlay         S.No 2752   14-Aug-2026
✅ FCSES-001       Pre-Execution Boolean Check             S.No 2774   17-Aug-2026
✅ FLADE-008-10    Friction Log Cascade                    S.No 2818   17-Aug-2026
✅ PELCE-019-11    EC Verb QA Test Runner                  S.No 2862   17-Aug-2026
✅ AEETE-027-12    Release Gate Lock                       S.No 2884   17-Aug-2026
✅ CBSV-005-13     _ID Suffix Linter                       S.No 2928   17-Aug-2026
✅ RRCVG-033       Peer Nomination Quota                   S.No 3027   17-Aug-2026
✅ RECET-008       Multi-Tenant Workspace Wall             S.No 3038   17-Aug-2026
✅ TTMAC-016       Dynamic Touch Target Padding            S.No 3049   17-Aug-2026
✅ SSELC-013       Split-Screen Mirror Template            S.No 3060   17-Aug-2026
✅ BPTR-0019       F-Pattern Dashboard                     S.No 3071   17-Aug-2026
✅ BPTR-0392       Progressive Bottom Sheet                S.No 3082   17-Aug-2026
✅ FIEVR-028       Dynamic Form Assembler                  S.No 3093   17-Aug-2026
✅ SSITI-010       VAT Invoice Schema                      S.No 3104   17-Aug-2026
✅ MUFCE-011       Image Ingress Animator                  S.No 3115   17-Aug-2026
✅ BTPM-026        Task Latency Monitor                    S.No 3126   17-Aug-2026
✅ SSELC-009       MTO Split-Screen Portrait Lock (ext)    S.No 3137   17-Aug-2026
✅ SGTIM-005       Infinite Scroll Manager                 S.No 3148   17-Aug-2026
✅ TTCFC-006       Gamification Badge                      S.No 3159   17-Aug-2026
✅ SSTLA-024       Low-Res Display Constraints (ext)       S.No 3170   17-Aug-2026
✅ SGTIM-008       FAB Action Menu (ext)                   S.No 3181   17-Aug-2026
✅ MUFCE-019       Conditional Upload Gate                 S.No 3192   18-Aug-2026
✅ IS03-CSIVW-007  Format Constraint Cells                 S.No 3203   18-Aug-2026
✅ IS41-SLPLU-016  Skeleton Loader Dynamic                 S.No 3214   18-Aug-2026
✅ SGTIM-001       Pagination Limit Manager                S.No 3225   18-Aug-2026
✅ REF-121         JWT Task Verification                   S.No 3236   18-Aug-2026
✅ FLADE-011-01    Shakti Root View Integration (ext)      S.No 3247   18-Aug-2026
✅ SIDM-008-01     Text Fragment Database                  S.No 3258   18-Aug-2026
✅ IRBCA-028       Analytics View Authorization (ext)      S.No 3269   18-Aug-2026
✅ MTVPE-013       Feature Tour Onboarding (ext)           S.No 3280   18-Aug-2026
✅ MUFCE-027       HPF Mandatory Attachment                S.No 3291   18-Aug-2026
```

---

## Git Commit Message — Steps 71–80

```
feat(components): steps 71-80 · upload gate · format cells · skeleton dynamic ·
pagination · JWT · shakti root · text fragments · analytics auth · feature tour ·
HPF attachment (18-Aug-2026)

MUFCE-019 (3192): ConditionalUploadGate — DCYN upload verification
CSIVW-007 (3203): FormatConstraintCell — 10 cells · Hard Lock · client-side masking
SLPLU-016 (3214): SkeletonLoaderDynamic — 10 components mapped · ShimmerPulse
SGTIM-001 (3225): PaginationLimitManager — hard ceiling 20 · cursor pagination
REF-121   (3236): JWTTaskVerification — stateless edge · epoch clock · Complete
FLADE-011-01 (3247): shakti_alert_panel.dart extended — RootViewHierarchyController
SIDM-008-01  (3258): TextFragmentDatabase — 8 fragments · real-time search
IRBCA-028    (3269): rbac_dashboard.dart extended — AnalyticsViewAuthorization
MTVPE-013    (3280): tooltip_dismissal.dart extended — FeatureTourController
MUFCE-027    (3291): HPFAttachmentIndicator — red asterisk · 5 listeners · 99%

80 of 97 steps complete · 76 dart files · 18-Aug-2026
```

---

*UDF Team — Habot Connect DMCC | DCDF Architecture Framework | **80 of 97 steps complete** | 76 dart files | Last updated 18-Aug-2026*
