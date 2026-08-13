# Habot Enterprise Mobile UI Component Library & Design System

A standardized, modular Material Design 3 (M3) UI Component Library and Design System engineered for **Habot Enterprise Mobile Applications**.

All step modules are consolidated into single, self-contained Dart files inside `lib/core/` domain folders (`ui`, `network`, `interaction`, `versioning`, `accessibility`, `compliance`), allowing each module to be imported and used independently.

---

## 📁 Repository Structure & Step Code Locations

```
lib/
├── main.dart                                  # Interactive component directory & theme launcher
└── core/                                      # Self-Contained Core Modules (32/32 Steps)
    ├── accessibility/
    │   ├── smart_keyboard_field.dart       ← Step 19: NSKFI-015 (Mobile Virtual Keyboard Interceptor)
    │   └── status_badge_system_panel.dart  ← Step 23: IS29-SCTAS-007 (High-Contrast Status Badges)
    ├── compliance/
    │   ├── db_linter_entity_panel.dart     ← Step 24: CBSV-005-10 (DB Identifier _ID Linter)
    │   ├── design_compliance_validator_panel.dart ← Step 26: MUFCE-018 (DevOps Compliance Linter)
    │   ├── lineage_trace_test_panel.dart   ← Step 27: EDEBS-015-10 (Lineage Trace & Release Gate)
    │   ├── mathematical_vendor_success_panel.dart ← Step 25: EDEBS-008-15 (Mathematical Vendor Proof Engine)
    │   └── private_package_enforcement_panel.dart ← Step 30: FEBFL-005 (Private Pub Package Import)
    ├── interaction/
    │   ├── ab_testing_card_switch.dart     ← Step 14: AEETE-001 (Byte-Level A/B Testing Switcher)
    │   ├── contextual_fab.dart            ← Step 6:  SGTIM-019 (Adaptive Circular Contextual FAB)
    │   ├── swipe_approval_matrix.dart     ← Step 8:  IRBCA-055 (Swipeable Managerial Approval Queue)
    │   └── system_verb_icon_panel.dart    ← Step 32: DLQDP-015-13 (System-Verb Icon Mapping Matrix)
    ├── models/
    │   └── step_item.dart                 ← Shared StepItem model & StepCategory definitions
    ├── network/
    │   ├── bigquery_telemetry_monitor.dart ← Step 16: TECH-ENG-015 (BigQuery Telemetry Logger)
    │   ├── bottleneck_highlight_dashboard.dart ← Step 17: TECH-ENG-034 (Infrastructure Bottleneck Tool)
    │   ├── finops_budget_dashboard.dart    ← Step 18: TECH-ENG-046 (GCP FinOps Budget Dashboard)
    │   ├── multi_zone_sync_bar.dart        ← Step 11: HAZFE-001 (Multi-Zone HA Sync & Sign-Up)
    │   ├── offline_sync_indicator.dart     ← Step 3:  BPTR-0498 (Offline Sync Queue Indicator)
    │   └── sse_status_indicator.dart      ← Step 10: 168 (Server-Sent Events Connection Hook)
    ├── theme/
    │   ├── app_theme.dart                 ← Material Design 3 ThemeData Builder
    │   └── app_theme_wrapper.dart         ← Dynamic Theme Controller & InheritedWidget
    ├── tokens/
    │   ├── color_palette.dart             ← Extended AppColorPalette tokens
    │   ├── color_scheme_builder.dart      ← HSL color scheme generator
    │   ├── density_tokens.dart            ← M3 touch target & density tokens
    │   ├── elevation_tokens.dart          ← M3 Level 0 to Level 5 elevation shadows
    │   ├── spacing_tokens.dart            ← M3 AppSpacingTokens (4dp, 8dp, 12dp, 16dp, 24dp, 32dp)
    │   └── typography_tokens.dart         ← Material 3 Type Scale Token definitions
    ├── ui/
    │   ├── ai_human_split_viewport.dart    ← Step 5:  SCTSS-017 (AI Draft vs Human Edit Viewport)
    │   ├── binary_checklist_stepper.dart   ← Step 4:  RRCVG-024 (Binary Checklist Stepper)
    │   ├── brand_cta_mapping_panel.dart    ← Step 21: SCTAS-002 (Brand #2E86C1 CTA Mapping)
    │   ├── clean_kpi_performance_card.dart ← Step 15: MUFCE-024 (Clean KPI Performance Card)
    │   ├── end_document_layout.dart        ← Step 2:  EDEBS-032 (Anchor End Document UI Layout)
    │   ├── executive_performance_dashboard.dart ← Step 13: LSAV-001 (Executive Performance Summary)
    │   ├── floating_callout_overlay.dart   ← Step 9:  LSAV-024 (Floating Core Callout Overlay)
    │   ├── m3_dense_table.dart             ← Step 1:  RCGLA-014 (M3 Dense Data Table)
    │   ├── m3_fluid_media_grid.dart        ← Step 12: MUFCE-001 (Campaign Imagery Fluid Grid)
    │   ├── master_menu_page.dart           ← Step Directory Master Menu Page
    │   ├── md3_elevated_success_card.dart  ← Step 20: EDEBS-008-16 (MD3 Elevated Success Card)
    │   ├── referral_reward_injection_panel.dart ← Step 28: PDMV-016-10 (Referral Reward Injection & 56dp FAB)
    │   ├── referral_reward_matrix_panel.dart ← Step 22: PDMV-032 (Referral Reward Credit Token Matrix)
    │   ├── responsive_nav_rail_panel.dart  ← Step 29: TNRML-007 (Responsive Tablet Navigation Rail)
    │   ├── status_pill_badge.dart          ← Standalone StatusPillBadge Atomic Component
    │   └── step_detail_page.dart           ← Step Detail Page Viewport Shell
    └── versioning/
        ├── context_isolation_panel.dart    ← Step 7:  SSELC-002 (Visual Context Isolation Panel)
        └── master_library_lock_panel.dart  ← Step 31: EDBAA-015-09 (Master Component Library Lock)
```

---

## 📊 Complete Step Audit Registry (Global Ref ID & File Locations)

| Step # | Global Ref ID | Step Title & Operational Description | Domain Folder | Full Complete Code File Location |
|:---:|:---:|---|:---:|---|
| **Step 1** | `RCGLA-014` | M3 Dense Data Table & Field Definitions | `ui` | `lib/core/ui/m3_dense_table.dart` |
| **Step 2** | `EDEBS-032` | Anchor End Document UI Layout & Z-Pattern Scan | `ui` | `lib/core/ui/end_document_layout.dart` |
| **Step 3** | `BPTR-0498` | Offline Sync Queue Counter & Header Indicator | `network` | `lib/core/network/offline_sync_indicator.dart` |
| **Step 4** | `RRCVG-024` | Binary Checklist Stepper Offboarding Rules | `ui` | `lib/core/ui/binary_checklist_stepper.dart` |
| **Step 5** | `SCTSS-017` | AI Draft vs Human Edit Split Viewport | `ui` | `lib/core/ui/ai_human_split_viewport.dart` |
| **Step 6** | `SGTIM-019` | Contextual Circular Speed-Dial FAB (`<ContextualFAB>`) | `interaction` | `lib/core/interaction/contextual_fab.dart` |
| **Step 7** | `SSELC-002` | Visual Context Isolation Panel | `versioning` | `lib/core/versioning/context_isolation_panel.dart` |
| **Step 8** | `IRBCA-055` | Swipeable Managerial Approval Queue Matrix | `interaction` | `lib/core/interaction/swipe_approval_matrix.dart` |
| **Step 9** | `LSAV-024` | Floating Core Callout Overlay Card | `ui` | `lib/core/ui/floating_callout_overlay.dart` |
| **Step 10** | `168` | Server-Sent Events Connection Hook & Indicator | `network` | `lib/core/network/sse_status_indicator.dart` |
| **Step 11** | `HAZFE-001` | Multi-Zone HA Sync Bar & Auth Sign-Up Wireframe | `network` | `lib/core/network/multi_zone_sync_bar.dart` |
| **Step 12** | `MUFCE-001` | Campaign Imagery & M3 Fluid Media Grid | `ui` | `lib/core/ui/m3_fluid_media_grid.dart` |
| **Step 13** | `LSAV-001` | Mobile-View Single-Column Executive Dashboard | `ui` | `lib/core/ui/executive_performance_dashboard.dart` |
| **Step 14** | `AEETE-001` | Byte-Level A/B Testing Variant Switcher Card | `interaction` | `lib/core/interaction/ab_testing_card_switch.dart` |
| **Step 15** | `MUFCE-024` | Stripped Vanity Parameters Clean KPI Card | `ui` | `lib/core/ui/clean_kpi_performance_card.dart` |
| **Step 16** | `TECH-ENG-015` | BigQuery Event Telemetry Logger & Monitor | `network` | `lib/core/network/bigquery_telemetry_monitor.dart` |
| **Step 17** | `TECH-ENG-034` | Real-Time Infrastructure Bottleneck Dashboard | `network` | `lib/core/network/bottleneck_highlight_dashboard.dart` |
| **Step 18** | `TECH-ENG-046` | GCP FinOps Cost Tracking & Budget Dashboard | `network` | `lib/core/network/finops_budget_dashboard.dart` |
| **Step 19** | `NSKFI-015` | Mobile Virtual Keyboard Interceptors | `accessibility` | `lib/core/accessibility/smart_keyboard_field.dart` |
| **Step 20** | `EDEBS-008-16` | MD3 Elevated Success Card Component | `ui` | `lib/core/ui/md3_elevated_success_card.dart` |
| **Step 21** | `SCTAS-002` | Brand Primary #2E86C1 CTA Mapping Panel | `ui` | `lib/core/ui/brand_cta_mapping_panel.dart` |
| **Step 22** | `PDMV-032` | Referral Reward Credit Token Matrix Panel | `ui` | `lib/core/ui/referral_reward_matrix_panel.dart` |
| **Step 23** | `IS29-SCTAS-007` | High-Contrast Status Badge System Panel | `accessibility` | `lib/core/accessibility/status_badge_system_panel.dart` |
| **Step 24** | `CBSV-005-10` | DB Identifier _ID Linter & Masked Entity Panel | `compliance` | `lib/core/compliance/db_linter_entity_panel.dart` |
| **Step 25** | `EDEBS-008-15` | Mathematical Vendor Onboarding Success Panel | `compliance` | `lib/core/compliance/mathematical_vendor_success_panel.dart` |
| **Step 26** | `MUFCE-018` | DevOps CI/CD Design Compliance Validator Panel | `compliance` | `lib/core/compliance/design_compliance_validator_panel.dart` |
| **Step 27** | `EDEBS-015-10` | Lineage Trace Test & Release Gate Control Panel | `compliance` | `lib/core/compliance/lineage_trace_test_panel.dart` |
| **Step 28** | `PDMV-016-10` | Mobile Referral-First Reward Injection & 56dp FAB | `ui` | `lib/core/ui/referral_reward_injection_panel.dart` |
| **Step 29** | `TNRML-007` | Responsive Tablet Sidebar Navigation Rail Shell | `ui` | `lib/core/ui/responsive_nav_rail_panel.dart` |
| **Step 30** | `FEBFL-005` | Private Flutter Pub Package Import Enforcement | `compliance` | `lib/core/compliance/private_package_enforcement_panel.dart` |
| **Step 31** | `EDBAA-015-09` | Package & Lock Master Component Library Panel | `versioning` | `lib/core/versioning/master_library_lock_panel.dart` |
| **Step 32** | `DLQDP-015-13` | System-Verb Icon Mapping Matrix Panel | `interaction` | `lib/core/interaction/system_verb_icon_panel.dart` |

---

## 🚀 Independent Modular Usage

All step files under `lib/core/` are **completely modular and self-contained**. You can copy or import any domain folder or individual Dart file into another project directly without needing `main.dart`.

Example direct import:
```dart
import 'package:flutter_app_aiss/core/ui/m3_dense_table.dart';
import 'package:flutter_app_aiss/core/network/sse_status_indicator.dart';
import 'package:flutter_app_aiss/core/compliance/db_linter_entity_panel.dart';
```

---

## 🛡️ Quality & Design System Compliance

- **Google Material Design 3 (M3)**: 100% compliant with M3 tokens, typography scale, and color schemes.
- **Accessibility Minimums**: 48x48dp touch target standard enforced across interactive controls.
- **Single-File Encapsulation**: Record models, widgets, stateful logic, and helper tables are consolidated per step.
- **Static Analysis Status**: Clean `flutter analyze` pass (**0 errors, 0 warnings, 0 lints**).
