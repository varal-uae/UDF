# HABOT Lucky Workspace (`habot_lucky`)

**Repository Module:** `habot-mobile/Lucky`  
**Package Name:** `habot_lucky`  
**Owner:** UDF Engineering — Mobile Architecture & Design System  
**Organization:** Habot Connect DMCC  
**Progress:** **60 Steps Completed**  

---

## 📌 Overview

`habot_lucky` is a **bucket collection of implementation files** created step-by-step while exploring and adopting Flutter, Dart, and Material Design 3 (MD3) patterns simultaneously. 

Instead of a single monolithic app, this workspace serves as an organized repository of reusable code buckets corresponding to **60 completed technical steps** in the UDF implementation framework.

---

## 🗂 Workspace Structure

```
habot-mobile/Lucky/
├── lib/
│   ├── app/                         ← App entrypoint & routing (`app.dart`, `router.dart`)
│   ├── core/                        ← Implementation Buckets (Steps 1–60)
│   │   ├── accessibility/           ← WCAG & Touch Target Bucket
│   │   ├── components/              ← UI Component Bucket (28 Widgets)
│   │   ├── education/               ← Field Help Content Bucket
│   │   ├── error/                   ← Error Boundaries & Telemetry Bucket
│   │   ├── feedback/                ← Failure Reason Catalog Bucket
│   │   ├── network/                 ← Network, Auth Interceptor & Token Bucket
│   │   ├── security/                ← High-Risk Action & Step-Up MFA Bucket
│   │   ├── telemetry/               ← Audit Logging & Diagnostic Bucket
│   │   ├── theme/                   ← Tokens, Liquid Glass & Theme Bucket
│   │   ├── utils/                   ← Form Engines, Date Parsers & Mask Buckets
│   │   └── workflow/                ← Release Gates Bucket
│   ├── features/                    ← Feature Modules (Auth & Dashboard)
│   └── shared/                      ← Adaptive Split-Layout Bucket
├── scripts/                         ← Token & Verb Catalog Lint Scripts
├── test/                            ← Unit & Component Tests
└── tokens.json                      ← Source Design Tokens
```

---

## 📦 60 Steps Completed (Implementation Buckets)

| Step | Ref / Identifier | Implementation File / Component | Bucket Area |
| :--- | :--- | :--- | :--- |
| **Step 1** | BPTR-0544-A01 | `tokens.json` & `design_tokens.dart` | Theme & Design Tokens |
| **Step 2** | TTIAS-014-A01 | `dynamic_typography_wrapper.dart` & `text_theme.dart` | Theme & Typography |
| **Step 3** | TTMAC-010-A01 | `touch_target_wrapper.dart` & `semantic_form_field.dart` | Accessibility |
| **Step 4** | TTMAC-025-A01 | `ripple_feedback.dart` & `liquid_glass_config.dart` | Theme & Visual FX |
| **Step 5** | NSKFI-014-A01 | `layout_version_control.dart` & `layout_instantiation_tracker.dart` | Layout & Versioning |
| **Step 6** | EDBAA-004-A01 | `empty_state_widget.dart` | UI Components |
| **Step 7** | BPTR-0693-A01 | `shakti_alert.dart` | Security & Alerts |
| **Step 8** | SLPLU-017-A01 | `trace_time_chart.dart` & `structural_trace_view.dart` | Telemetry & Charts |
| **Step 9** | SLPLU-005-A01 | `skeleton_loader.dart` & `shimmer.dart` | Component Loaders |
| **Step 10** | BLGTA-041-A01 | `uuid_payload_injector.dart` & `byt_id.dart` | Network & Identifiers |
| **Step 11** | REF-046-A01 | `overlay_card.dart` & `field_help_popup.dart` | Component Overlays |
| **Step 12** | MLVTP-002 | `payload_size_guard.dart` | Network Middleware |
| **Step 13** | IRBCA-048 | `signed_url_card.dart` & `signed_url_asset_loader.dart` | Network & Storage |
| **Step 14** | AGPTE-024 | `security_status_chip.dart` & `status_indicators.dart` | Security & Status |
| **Step 15** | AMLCO-002 | `auditor_validator.dart` & `release_gate.dart` | Compliance & Gates |
| **Step 16** | AWCV-001 | `compact_typography_grid.dart` & `compact_task_panel.dart` | Typography & Task UI |
| **Step 17** | ONCS-001 | `network_tap_zone.dart` | Touch Target & Network |
| **Step 18** | EDBAA-002 | `formula_tooltip.dart` & `field_help_content.dart` | Accessibility & Help |
| **Step 19** | BTPM-002 | `issue_severity_tag.dart` | Status & Tags |
| **Step 20** | BCDLD-037 | `deadline_alert_banner.dart` | Alert Banners |
| **Step 21** | CFCST-002 | `funnel_analytics_map.dart` | Analytics & Telemetry |
| **Step 22** | TECH-ENG-004 | `dlq_monitoring_dashboard.dart` | Monitoring & Dashboards |
| **Step 23** | TECH-ENG-022 | `security_access_dashboard.dart` & `step_up_mfa_prompt.dart` | Zero-Trust & MFA |
| **Step 24** | TECH-ENG-037 | `system_config_form.dart` & `validated_form.dart` | Form Engines |
| **Step 25** | TECH-ENG-049 | `rbac_dashboard.dart` & `high_risk_action.dart` | RBAC & High-Risk |
| **Step 26** | ADPL-001 | `adaptive_split_layout_shell.dart` | Adaptive Layout |
| **Step 27** | ADPL-002 | `adaptive_panel_router.dart` & `split_route_controller.dart` | Adaptive Routing |
| **Step 28** | ADPL-003 | `breakpoints.dart` & `size_class.dart` | Viewport Breakpoints |
| **Step 29** | ADPL-004 | `orientation_listener.dart` & `screen_size_provider.dart` | Screen Size Engine |
| **Step 30** | ADPL-005 | `contextual_mirror_layout.dart` | RTL & Dual-Pane Mirror |
| **Step 31** | DOC-ING-001 | `document_ingestion_gateway.dart` | Ingestion Gateway |
| **Step 32** | DOC-ING-002 | `document_crop_sheet.dart` & `mto_viewport_crop.dart` | Document Cropping |
| **Step 33** | DOC-ING-003 | `ed_field_hierarchy_viewer.dart` & `ingestion_rules.dart` | Field Hierarchy |
| **Step 34** | AI-RAT-001 | `ai_rationale_accordion.dart` | AI Decision UI |
| **Step 35** | AI-RAT-002 | `prompt_template_builder.dart` | Prompt Templates |
| **Step 36** | EC-CTA-001 | `ec_cta_button.dart` & `scripts/lint_ec_verbs.js` | CTA Verb Validation |
| **Step 37** | EC-CTA-002 | `release_to_tech_button.dart` | Tech Release CTA |
| **Step 38** | FORM-ENG-001 | `form_error_focus_engine.dart` & `error_field_container.dart` | Error Focus Engine |
| **Step 39** | FORM-ENG-002 | `debounced_form_field.dart` & `debouncer.dart` | Form Debouncers |
| **Step 40** | FORM-ENG-003 | `form_auto_save_service.dart` & `form_intercept_scroll.dart` | Draft Auto-Save |
| **Step 41** | FORM-MASK-001 | `input_masks/masked_text_field.dart` & `input_mask_catalog.dart` | Input Text Masks |
| **Step 42** | FORM-MASK-002 | `regex_input_formatter.dart` & `habot_formatters.dart` | Regex Formatters |
| **Step 43** | DATE-VAL-001 | `iso8601_date_enforcer.dart` & `end_document_metadata.dart` | ISO Date Enforcer |
| **Step 44** | UI-WIDG-001 | `binary_choice_field.dart` | Binary Choice UI |
| **Step 45** | UI-WIDG-002 | `voice_search_bar.dart` & `speech_hook.dart` | Voice Search Bar |
| **Step 46** | UI-WIDG-003 | `searchable_autocomplete.dart` | Autocomplete Widget |
| **Step 47** | UI-WIDG-004 | `status_indicators.dart` & `scaling_load_shell.dart` | Status & Loaders |
| **Step 48** | UI-WIDG-005 | `byt_card.dart` & `byt_state.dart` | Byt State Cards |
| **Step 49** | UI-WIDG-006 | `edit_row.dart` & `design_reconciliation_card.dart` | Row Editing & Cards |
| **Step 50** | DIAG-FEED-001 | `low_rating_diagnostic_form.dart` & `failure_reason_catalog.dart` | Feedback Catalog |
| **Step 51** | NET-AUTH-001 | `auth_interceptor.dart` & `habot_http_client.dart` | Network Auth Client |
| **Step 52** | NET-AUTH-002 | `token_store.dart` & `auth_abandon_telemetry.dart` | Secure Token Store |
| **Step 53** | SEC-MFA-001 | `step_up_verifier.dart` | Step-Up MFA Engine |
| **Step 54** | ERR-HAND-001 | `global_error_handler.dart` & `error_boundary.dart` | Crash Boundaries |
| **Step 55** | ERR-HAND-002 | `error_fallback_screen.dart` | Fallback Screens |
| **Step 56** | TEL-AUD-001 | `upload_audit_telemetry.dart` & `data_lineage_tracker.dart` | Upload Audit Log |
| **Step 57** | TEL-AUD-002 | `rating_diagnostic_telemetry.dart` & `error_telemetry.dart` | Diagnostic Logging |
| **Step 58** | LINT-SCR-001 | `scripts/lint_design_tokens.js` | Design Token Linter |
| **Step 59** | TEST-SUITE-001 | `test/batch_components_test.dart` & `loading_button_test.dart` | Component Unit Tests |
| **Step 60** | TEST-SUITE-002 | `test/debouncer_test.dart` & `voice_search_bar_test.dart` | Interactive Unit Tests |
